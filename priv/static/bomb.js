
function Bomb(position) {
    var self = this;
    this.position = position;

    this.draw = function() {
        if (self.el == undefined) {
            self.el = document.createElement('div');
            self.el.className = 'bomb';
            self.el.innerHTML = self.position;
            //document.body.appendChild(self.el);
            Grid.add(self.el);
        }

        Grid.position(self);
    }

    this.draw();
}

function Fire(position) {
    var self = this;
    this.position = position;
    this.timer;

    this.draw = function() {
        if (self.el == undefined) {
            self.el = document.createElement('div');
            self.el.className = 'fire';
            self.el.innerHTML = self.position;
            //document.body.appendChild(self.el);
            Grid.add(self.el);
        }

        Grid.position(self);
    }

    this.draw();
    this.timer = setTimeout('Arena.stop_fire(' + self.position[0] +', ' + self.position[1] + ');', 1000);
}