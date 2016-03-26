function connect(host) {
  try {
    socket = new WebSocket(host);

    addMessage("Socket State: " + socket.readyState);

    socket.onopen = function() {
      addMessage("Socket Status: " + socket.readyState + " (open)");
    }

    socket.onclose = function() {
      addMessage("Socket Status: " + socket.readyState + " (closed)");
    }

    socket.onmessage = function(msg) {
     readMessage(msg.data);
    }
    
  } catch(exception) {
    addMessage("Error: " + exception);
  }
}

function readMessage(msg) {
  var obj = JSON.parse(msg);
  switch (obj.type) {

    case "text":
      addMessage(obj.text);
      break;

    case "codeSave":

      break;

    case "codeRun":

      break;

    case "codeInputReceive":
      addCodeInput(obj.text);
      break;

    case "codeOutputReceive":
      console.log("got it")
      addCodeOutput(obj.text);
      break;

    case "authError":
      $('body').html('AUTHENTICATION ERROR');
      break;

    case "alreadyConnected":
      $('body').html('ALREADY CONNECTED');
      break;

    default:

    break;
  }
}

function createMessage(type, text) {
  console.log("making msg")
  var msg =  {
    type: type,     
    text: text
  };
  return JSON.stringify(msg);
}

function send(type, text) {  
  try {
    msg = createMessage(type, text);
    socket.send(msg);
  } catch(exception) {
    return false;
  }

  return true;
}