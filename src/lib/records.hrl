
-record(state, {bombs=[], users=[]}).

-record(user, {pid, uid, name, position, range=1, alive=true, kills=0}).
-record(bomb, {position, range, pid, timer=3}).
