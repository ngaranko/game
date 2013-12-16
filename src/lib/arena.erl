%%%-------------------------------------------------------------------
%%% File    : arena.erl
%%% Author  : Nikolay Garanko <ngaranko@gmail.com>
%%% Description : Base server for Bomberman.
%%%
%%% Created :  4 Aug 2013 by Nikolay Garanko <ngaranko@gmail.com>
%%%-------------------------------------------------------------------
-module(arena).

-behaviour(gen_server).

%% API
-export([start_link/0]).

%% gen_server callbacks
-export([init/1, handle_call/3, handle_cast/2, handle_info/2,
         terminate/2, code_change/3]).

%% Public API
-export([join/2, move/2, bomb/1, dood/1]).

%% Stats API
-export([stat_users/0]).

-include("records.hrl").
-define(ARENA_SERVER, ?MODULE).

%%====================================================================
%% API
%%====================================================================
%%--------------------------------------------------------------------
%% Function: start_link() -> {ok,Pid} | ignore | {error,Error}
%% Description: Starts the server
%%--------------------------------------------------------------------
start_link() ->
    io:format("START!!#!@#"),
    gen_server:start_link({local, ?ARENA_SERVER}, ?MODULE, [], []).

%%====================================================================
%% gen_server callbacks
%%====================================================================

%%--------------------------------------------------------------------
%% Function: init(Args) -> {ok, State} |
%%                         {ok, State, Timeout} |
%%                         ignore               |
%%                         {stop, Reason}
%% Description: Initiates the server
%%--------------------------------------------------------------------
init([]) ->
    {ok, #state{bombs=[], users=[]}}.

join(Pid, Name) ->
    gen_server:call(?MODULE, {join, Pid, Name}).

dood(Pid) ->
    %%get_sever:call(?ARENA_SERVER, {dood, Pid}).
    ?MODULE ! {dood, Pid},
    ok.

move(Pid, Direction) ->
    gen_server:cast(?ARENA_SERVER, {move, Pid, Direction}).

bomb(Pid) ->
    gen_server:cast(?ARENA_SERVER, {bomb, Pid}).


stat_users() ->
    gen_server:call(?ARENA_SERVER, stat_users).

%%--------------------------------------------------------------------
%% Function: %% handle_call(Request, From, State) -> {reply, Reply, State} |
%%                                      {reply, Reply, State, Timeout} |
%%                                      {noreply, State} |
%%                                      {noreply, State, Timeout} |
%%                                      {stop, Reason, Reply, State} |
%%                                      {stop, Reason, State}
%% Description: Handling call messages
%%--------------------------------------------------------------------
handle_call({join, From, Name}, _From, State) ->
    io:format("Users: ~p ~p~n", [State#state.users, From]),
    case proplists:lookup(From, State#state.users) of
        none ->
            {User, NewState} = user_join(State, From, Name),
            messaging:welcome(From, NewState#state.users, User#user.uid),
            messaging:join(NewState#state.users, User),
            io:format("End up ~p~n", [NewState#state.users]),
            {reply, {ok, User#user.uid}, NewState};
        _Some ->
            {reply, {error, already_joined}, State}
    end;

handle_call({dood, Pid}, _From, State) ->

    io:format("Disconnect, ~p~n", [Pid]),
    {reply, ok, State};

%% Stats
handle_call(stat_users, _From, State) ->
    {reply, State#state.users, State};

handle_call(_Request, _From, State) ->
    {reply, ok, State}.

%%--------------------------------------------------------------------
%% Function: handle_cast(Msg, State) -> {noreply, State} |
%%                                      {noreply, State, Timeout} |
%%                                      {stop, Reason, State}
%% Description: Handling cast messages
%%--------------------------------------------------------------------
handle_cast({move, Pid, Direction}, State) ->
    case proplists:lookup(Pid, State#state.users) of
        none ->
            {noreply, State};
        {Pid, User} ->
            case User#user.alive of
                true ->
                    MovedUser = users:move(User, Direction),
                    NewUsers = [{Pid, MovedUser} | 
                                proplists:delete(Pid, State#state.users)],
                    messaging:move(NewUsers, MovedUser),
                    {noreply, State#state{users=NewUsers}};
                false ->
                    {noreply, State}
            end
    end;

handle_cast({bomb, Pid}, State) ->
    case proplists:lookup(Pid, State#state.users) of
        none ->
            {noreply, State};
        {Pid, User} ->
            case User#user.alive of
                true ->
                    NewState = State#state{bombs=[{User#user.position,
                                                   bomb:place(?ARENA_SERVER, User)} | State#state.bombs]},
                    messaging:bomb(NewState#state.users, User#user.position),
                    {noreply, NewState};
                false ->
                    {noreply, State}
            end
    end;

handle_cast({close, Pid}, State) ->
    io:format("Disconnect, ~p~n", [Pid]),
    {noreply, State};

handle_cast(_Msg, State) ->
  {noreply, State}.

%%--------------------------------------------------------------------
%% Function: handle_info(Info, State) -> {noreply, State} |
%%                                       {noreply, State, Timeout} |
%%                                       {stop, Reason, State}
%% Description: Handling all non call/cast messages
%%--------------------------------------------------------------------
handle_info({fire, Positions, Pid}, State) ->
    NewState = fireon(State, Positions, Pid),
    {noreply, NewState};

handle_info({dood, Pid}, State) ->
    case proplists:get_value(Pid, State#state.users) of
        undefined ->
            ok;
        User ->
            messaging:dood(State#state.users, User)
    end,
    Users = proplists:delete(Pid, State#state.users),
    {noreply, State#state{users=Users}};

handle_info(_Info, State) ->
    io:format("State: ~p~n", [State]),
    {noreply, State}.

%%--------------------------------------------------------------------
%% Function: terminate(Reason, State) -> void()
%% Description: This function is called by a gen_server when it is about to
%% terminate. It should be the opposite of Module:init/1 and do any necessary
%% cleaning up. When it returns, the gen_server terminates with Reason.
%% The return value is ignored.
%%--------------------------------------------------------------------
terminate(_Reason, _State) ->
  ok.

%%--------------------------------------------------------------------
%% Func: code_change(OldVsn, State, Extra) -> {ok, NewState}
%% Description: Convert process state when code is changed
%%--------------------------------------------------------------------
code_change(_OldVsn, State, _Extra) ->
  {ok, State}.

%%--------------------------------------------------------------------
%%% Internal functions
%%--------------------------------------------------------------------

user_join(State, Pid, Name) ->
    Uid = random:uniform(30),
    case check_uid(Uid, State#state.users) of
        ok ->
            User = users:create(Pid, Uid, Name),
            NewState = State#state{users=[{Pid, User} | State#state.users]},
            {User, NewState};
        taken ->
            user_join(State, Pid, Name)
    end.

check_uid(_Uid, []) ->
    ok;
check_uid(Uid, [#user{uid=Uid} | _Users]) ->
    taken;
check_uid(Uid, [_User | Users]) ->
    check_uid(Uid, Users).

fireon(State, [], _Pid) ->
    State;
fireon(State, [Position | Positions], Pid) ->
    messaging:fire(State#state.users, Position),
    {NewUsers, DeadUids} = users:check_fire(Position, State#state.users),
    messaging:dead(NewUsers, DeadUids),
    FinalUsers = users:set_kills(Pid, length(DeadUids), NewUsers),
    NewBombs = bomb:check_fire(Position, State#state.bombs),
    fireon(State#state{users=FinalUsers, bombs=NewBombs}, Positions, Pid).

