-module(armory).
-export([start_link/0]).

-record(bomb, {position, range}).

start_link() ->
    spawn_link(fun init/0).

init() ->
    loop([]).

loop(Bombs) ->
    receive
        {add, Position, Range} ->
            NewBombs = lists:append(Bombs, [#bomb{position=Position, range=Range}]),
            io:format("Bombs ~p~n", [NewBombs]),
            loop(NewBombs);
        Msg ->
            io:format("123 ~p~n", [Msg]),
            loop(Bombs)
    after 100 ->
            loop(Bombs)
    end.

