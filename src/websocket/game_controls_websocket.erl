-module(game_controls_websocket).
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
    io:format("AREANA!!!~n~n~p (~p) starting...~n", [?MODULE, self()]),
    {ok, A} = arena:start_link(),
    io:format("Arena ~p~n", [A]),
    {ok, [{arena, A}]}.

%%--------------------------------------------------------------------
%% to handle a connection to your service
%%--------------------------------------------------------------------
handle_join(_ServiceName, WebSocketId, SessionId, State, _) ->
    User = boss_session:get_session_data(erlang:binary_to_list(SessionId), user),
    arena:join(WebSocketId, proplists:get_value(username, User)),
    {noreply, State}.
%%--------------------------------------------------------------------


%%--------------------------------------------------------------------
%% to handle a close connection to you service
%%--------------------------------------------------------------------
handle_close(_Reason, _ServiceName, WebSocketId, SessionId, State) ->
    arena:dood(WebSocketId),
    {noreply, State}.
%%--------------------------------------------------------------------


%%--------------------------------------------------------------------
%% to handle incoming message to your service
%% here is simple copy to all
%%--------------------------------------------------------------------
handle_incoming(_ServiceName, WebSocketId, <<"1">>, State, _) ->
    arena:move(WebSocketId, 1),
    {noreply, State};
handle_incoming(_ServiceName, WebSocketId, <<"2">>, State, _) ->
    arena:move(WebSocketId, 2),
    {noreply, State};
handle_incoming(_ServiceName, WebSocketId, <<"3">>, State, _) ->
    arena:move(WebSocketId, 3),
    {noreply, State};
handle_incoming(_ServiceName, WebSocketId, <<"5">>, State, _) ->
    arena:move(WebSocketId, 5),
    {noreply, State};
handle_incoming(_ServiceName, WebSocketId, <<"0">>, State, _) ->
    %arena:move(WebSocketId, 3),
    arena:bomb(WebSocketId),
    {noreply, State};
handle_incoming(_ServiceName, WebSocketId, Message, State, _) ->
    io:format("Message: ~p.~n", [Message]),

    %%WebSocketId ! {text, <<"{msg: 'ok'}">>},
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

