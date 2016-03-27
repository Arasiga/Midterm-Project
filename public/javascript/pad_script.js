var inputCode = $('.CodeMirror')[0].CodeMirror;
var outputCode = $('.CodeMirror')[1].CodeMirror;
var chat = $('.CodeMirror')[2].CodeMirror;

function addMessage(msg) {
  // $("#chat-log").append("<p>" + msg + "</p>");
  // chat.setValue(msg);
  chat.replaceRange(msg + '\n', CodeMirror.Pos(chat.lastLine()));
}

function addCodeOutput(msg) {
  // var display_txt = (msg).replace("\n", "<br />");
  // $("#code-output").html(display_txt);
  outputCode.setValue(msg);
}

function addCodeInput(msg) {        
      // $("#mycode").val(obj.text);
      inputCode.setValue(msg);
}

function modUserList(msg) {
  $('#userList').html(" ");
  var stuff = "<ul>";
  for (var i = 0; i < msg.length; i++) {
    stuff += "<li>" + msg[i] + "</li><br>"
  }
   stuff += "</ul>"
  $('#userList').html(stuff);
}



$('#message').keypress(function(event) {
  text = $("#message").val();
  if (event.keyCode == '13' & text != '') { 
    success = send("text", text); 
    if (!success) {
     addMessage("Failed To Send");
    } else {
      addMessage('Me:  ' + text)
    }
    $("#message").val('');
  }
});

$('#runcode').click(function() {
  console.log(inputCode.getValue());
  send("codeRun", inputCode.getValue());

});

inputCode.on('keyup', function(cMirror) {
      console.log( cMirror.getValue() );
      send("codeInputReceive",  cMirror.getValue());
});

$("#disconnect").click(function() {
  socket.close()
});