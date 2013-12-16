var UID;
var Users = {};
var Bombs = {};
var Flames = {};

var Grid = {
    add: function (element) {
        document.body.appendChild(element);
    },
    remove: function (element) {
        document.body.removeChild(element);
    },

    position: function (obj) {
        var _X = obj.position[0];
        var _Y = obj.position[1];
        obj.el.style.left = (_X * 20) + 'px';
        obj.el.style.top = (_Y * -20) + 'px';
    }
}


var Arena = {
    welcome: function (data) {
        if (data.users.length) {
            $(data.users).each(function(i, k) {
                var _data = {'uid':  k[0],
                             'name': k[1],
                             'pos':  k[2]};
                Arena.join(_data);
            });
        }
    },

    join: function (data) {
        if (Users[data.uid] == undefined) {
            Users[data.uid] = new User(data.uid, data.name, data.pos);
        }
    },
    move: function (data) {
        if (Users[data.uid] !== undefined) {
            Users[data.uid].move(data.pos);
        }
    },

    dead: function (data) {
        if (Users[data.uid] !== undefined) {
            Users[data.uid].is_dead();
        }
    },

    dood: function (data) {
        if (Users[data.uid] !== undefined) {
            document.body.removeChild(Users[data.uid].el);
            delete Users[data.uid];
        }
    },
    bomb: function(data) {
        if (Bombs[data.pos] == undefined) {
            Bombs[data.pos] = [];
        }

        Bombs[data.pos].push(new Bomb(data.pos));
    },

    fire: function(data) {
        if (Flames[data.pos] !== undefined) {
            Arena.stop_fire(data.pos[0], data.pos[1]);
        }
        Flames[data.pos] = new Fire(data.pos);

        if (Bombs[data.pos] !== undefined) {
            $(Bombs[data.pos]).each(function (i, bomb) {
                Grid.remove(bomb.el);
            });
            delete Bombs[data.pos];
        }
    },
    stop_fire: function(x, y) {
        var position = [x, y];
        if (Flames[position] !== undefined) {
            Grid.remove(Flames[position].el);
            delete Flames[position];
        }
    }
}
