var stats_wsc;
$(function() {
    stats_wsc = new WebSocket("ws://localhost:8001/websocket/status", "status");
    stats_wsc.onopen = function() { 
        console.log("Status connected.");
    };

    stats_wsc.onclose = function(event) { 
        if (event.wasClean) {
            alert('Cleanly closed');
        } else {
            alert('Connection closed');
        }
        alert('Code: ' + event.code + ' reason: ' + event.reason);
    };
 
    stats_wsc.onmessage = function(event) { 
        console.log(event.data);
    };

    stats_wsc.onerror = function(error) { 
        alert("Error: " + error.message); 
    };

});

