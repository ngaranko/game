var wsc;

$(function() {
    wsc = new WebSocket("ws://localhost:8001/websocket/controls", "controls");
    wsc.onopen = function() { 
        console.log("Controls connected.");
    };

    wsc.onclose = function(event) { 
        if (event.wasClean) {
            alert('Cleanly closed');
        } else {
            alert('Connection closed');
        }
        alert('Code: ' + event.code + ' reason: ' + event.reason);
    };
 
    wsc.onmessage = function(event) { 
        var data = jQuery.parseJSON(event.data);
        if (data.msg == "welcome") {
            UID = data.uid;
            Arena.welcome(data);
        } else if (data.msg == "join") {
            Arena.join(data);
        } else if (data.msg == "move") {
            Arena.move(data);
        } else if (data.msg == "dood") {
            Arena.dood(data);
        } else if (data.msg =="bomb") {
            Arena.bomb(data);
        } else if (data.msg == "fire") {
            Arena.fire(data);
        } else if (data.msg == "dead") {
            Arena.dead(data);
        } else {
            console.log(data);
        }
    };

    wsc.onerror = function(error) { 
        alert("Error: " + error.message); 
    };

    $(window).on('keydown', function(e) {
        var move;
        if (e.keyCode == 65 || e.keyCode == 37) {
            move = 1;
        }
        else if (e.keyCode == 83 || e.keyCode == 40) {
            move = 2;
        }
        else if (e.keyCode == 68 || e.keyCode == 39) {
            move = 3;
        } else if (e.keyCode == 87 || e.keyCode == 38) {
            move = 5;
        } else if (e.keyCode == 32) {
            move = 0;
        } else {
            //console.log(e.keyCode);
        }

        if (move !== undefined) {
            wsc.send(move);
        }
    });
});

