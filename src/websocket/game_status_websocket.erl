-module(game_status_websocket).
-behaviour(boss_service_handler).


%% API
-export([init/1,
    handle_incoming/5,
    handle_join/5,
    handle_close/5,
    handle_info/2,
    terminate/2]).

%%--------------------------------------------------------------------
%% Function: init(Args) -> {ok, State} |
%%                         {ok, State, Timeout} |
%%                         ignore               |
%%                         {stop, Reason}
%% Description: Initiates the server
%%--------------------------------------------------------------------
init(_) ->
  io:format("~p (~p) starting...~n", [?MODULE, self()]),
  %timer:send_interval(1000, ping),
  {ok, []}.

%%--------------------------------------------------------------------
%% to handle a connection to your service
%%--------------------------------------------------------------------
handle_join(_ServiceName, WebSocketId, SessionId, State, _) ->
    {noreply, []}.
%%--------------------------------------------------------------------


%%--------------------------------------------------------------------
%% to handle a close connection to you service
%%--------------------------------------------------------------------
handle_close(_ServiceName, WebSocketId, _SessionId, State, _) ->
    {noreply, []}.
%%--------------------------------------------------------------------


%%--------------------------------------------------------------------
%% to handle incoming message to your service
%% here is simple copy to all
%%--------------------------------------------------------------------
handle_incoming(_ServiceName, WebSocketId, <<"1">>, State, _) ->
    Users = arena:stat_users(),
    stats:users(WebSocketId, Users),
    %%WebSocketId ! {text, <<"{msg: 'ok'}">>},
    {noreply, State};

handle_incoming(_ServiceName, WebSocketId, Message, State, _) ->
    io:format("Message: ~p.~n", [Message]),

    WebSocketId ! {text, <<"{msg: 'ok'}">>},
    %% end,
    {noreply, State}.
%%--------------------------------------------------------------------


handle_info(ping, State) ->
    error_logger:info_msg("pong:~p~n", [now()]),
    {noreply, State};

handle_info(state, State) ->
    error_logger:info_msg("state:~p~n", [State]),
    {noreply, State};

handle_info(_Info, State) ->
    {noreply, State}.

terminate(_Reason, _State) ->
   %call boss_service:unregister(?SERVER),
  ok.

