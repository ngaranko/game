
function User(uid, name, position) {
    var self = this;
    self.uid = uid;
    self.name = name;
    self.me = UID == uid;
    self.position = position;
    self.alive = true;

    self.timer;

    self.el;

    self.move = function(position) {
        self.position = position;
        self.draw();
    }
    self.is_dead = function() {
        self.dead = true;
        self.timer = setTimeout("Arena.dood({uid: " + self.uid + "});", 2000);
        self.draw();
    }

    self.draw = function() {
        if (self.el == undefined) {
            self.el = document.createElement('div');
            self.el.innerHTML = self.uid;
            self.el.className = 'user';
            if (self.me) {
                self.el.className += ' me';
            }
            //document.body.appendChild(self.el);
            Grid.add(self.el);
        }
        if (self.dead) {
            self.el.innerHTML = 'x';
        }
        // Positioning
        Grid.position(self);
    }

    self.draw();

}