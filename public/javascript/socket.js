function connect(host) {
  try {
    socket = new WebSocket(host);

    addMessage("Attempting to connect...");

    socket.onopen = function() {
      addMessage("Connection established.");
      send("sendCurrCode", "");

    }

    socket.onclose = function() {
      addMessage("Disconnected.");
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

    case "sendCurrCode":
      send("codeInputReceive",  inputCode.getValue());
      break;

    case "userList":
      modUserList(obj.text);
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