-module(users).
-compile(export_all).

-include("records.hrl").

create(Pid, Uid, Name) ->
    #user{pid=Pid, uid=Uid, name=Name, position=[0, 0]}.

move(User, 1) ->
    [X, Y] = User#user.position,
    User#user{position=[X-1, Y]};

move(User, 3) ->
    [X, Y] = User#user.position,
    User#user{position=[X+1, Y]};

move(User, 2) ->
    [X, Y] = User#user.position,
    User#user{position=[X, Y-1]};

move(User, 5) ->
    [X, Y] = User#user.position,
    User#user{position=[X, Y+1]}.

dead(User) ->
    User#user{alive=false}.


check_fire(Position, Users) ->
    check_fire(Position, Users, [], []).

check_fire(_Position, [], UpdatedUsers, DeadUids) ->
    {UpdatedUsers, DeadUids};
check_fire(Position, [{Pid, User} | Users], UpdatedUsers, DeadUids) when Position =:= User#user.position, User#user.alive =:= true ->
    %% User dood now
    check_fire(Position, Users, [{Pid, dead(User)} | UpdatedUsers], [User#user.uid | DeadUids]);
check_fire(Position, [UserData | Users], UpdatedUsers, DeadUids) ->
    check_fire(Position, Users, [UserData | UpdatedUsers], DeadUids).

set_kills(Pid, Count, Users) ->
    case proplists:get_value(Pid, Users) of
        undefined ->
            Users;
        User ->
            [{Pid, User#user{kills=User#user.kills + Count}} | proplists:delete(Pid, Users)]
    end.

