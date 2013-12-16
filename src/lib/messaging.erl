-module(messaging).
-compile(export_all).

-include("records.hrl").


join(Users, User) ->
    Msg = io_lib:format("{\"msg\": \"join\", \"uid\": \"~p\", \"name\": ~p, \"pos\": ~p}", [User#user.uid, User#user.name, User#user.position]),
    mass_send(Users, Msg).

welcome(Pid, Users, Uid) ->
    welcome(Pid, Users, Uid, []).

welcome(Pid, [], Uid, Msgs) ->
    Msg = io_lib:format("{\"msg\": \"welcome\", \"uid\": ~p, \"users\": ~p}", [Uid, Msgs]),
    send(Pid, Msg);
welcome(Pid, [{_Pid, User} | Users], Uid, Msgs) when User#user.alive =:= true ->
    UserMsg = [User#user.uid, User#user.name, User#user.position],
    welcome(Pid, Users, Uid, [UserMsg | Msgs]);
welcome(Pid, [_User | Users], Uid, Msgs) ->
    welcome(Pid, Users, Uid, Msgs).



move(Users, User) ->
    Msg = io_lib:format("{\"msg\": \"move\", \"uid\": ~p, \"pos\": ~p}", [User#user.uid, User#user.position]),
    mass_send(Users, Msg).

bomb(Users, Location) ->
    Msg = io_lib:format("{\"msg\": \"bomb\", \"pos\": ~p}", [Location]),
    mass_send(Users, Msg).

dood(Users, User) ->
    Msg = io_lib:format("{\"msg\": \"dood\", \"uid\": ~p}", [User#user.uid]),
    mass_send(Users, Msg).

fire(Users, Position) ->
    Msg = io_lib:format("{\"msg\": \"fire\", \"pos\": ~p}", [Position]),
    mass_send(Users, Msg).

dead(_Users, []) ->
    ok;
dead(Users, [Uid | DeadUids]) ->
    Msg = io_lib:format("{\"msg\": \"dead\", \"uid\": ~p}", [Uid]),
    mass_send(Users, Msg).

%% Senders

mass_send([], Msg) ->
    ok;
mass_send([{Pid, _User} | Users], Msg) ->
    send(Pid, Msg),
    mass_send(Users, Msg).

send(Pid, Msg) ->
    Pid ! {text, erlang:list_to_binary(Msg)}.

