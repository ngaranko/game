-module(stats).
-compile(export_all).
-include("records.hrl").

users(Pid, Users) ->
    Data = users(Pid, Users, []),
    Msg = io_lib:format("{\"users\": ~p}", [Data]),
    messaging:send(Pid, Msg).

users(Pid, [], Data) ->
    Data;
users(Pid, [{Pid, User} | Users], Data) ->
    users(Pid, Users, [[User#user.uid, User#user.name, User#user.kills] | Data]).
    
