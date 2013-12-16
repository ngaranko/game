-module(bomb).
-export([place/2, check_fire/2]).

-include("records.hrl").


place(Owner, User) ->
    Bomb = #bomb{position=User#user.position,
                 range=User#user.range,
                 pid=User#user.pid},
    spawn_link(fun() -> loop(Owner, Bomb) end).

loop(Owner, Bomb) when Bomb#bomb.timer =:= 0 ->
    blow(Owner, Bomb);

loop(Owner, Bomb) ->
    receive
        boom ->
            blow(Owner, Bomb)
    after 1000 ->
            io:format("Tik~n"),
            loop(Owner, Bomb#bomb{timer=Bomb#bomb.timer - 1})
    end.

blow(Owner, Bomb) ->
    [X, Y] = Bomb#bomb.position,
    Owner ! {fire, [[X, Y],
                    [X-1, Y],
                    [X+1, Y],
                    [X, Y-1],
                    [X, Y+1]], Bomb#bomb.pid}.

check_fire(Position, Bombs) ->
    check_fire(Position, Bombs, []).

check_fire(_Position, [], UpdatedBombs) ->
    UpdatedBombs;
check_fire(Position, [{Position, Bomb} | Bombs], UpdatedBombs) ->
    Bomb ! boom,
    check_fire(Position, Bombs, UpdatedBombs);
check_fire(Position, [Bomb | Bombs], UpdatedBombs) ->
    check_fire(Position, Bombs, [Bomb | UpdatedBombs]).
