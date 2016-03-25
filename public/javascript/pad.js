function addMessage(msg) {
  $("#chat-log").append("<p>" + msg + "</p>");
}

function addCodeOutput(msg) {
  var display_txt = (msg).replace("\n", "<br />");
  $("#code-output").html(display_txt);
}

function addCodeInput(msg) {        
      $("#mycode").val(obj.text);
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
  send("codeRun", $("#mycode").val());
});

$('#mycode').keyup(function() {
  console.log( $("#mycode").val());
  send("codeInputReceive",  $("#mycode").val());
});

$("#disconnect").click(function() {
  socket.close()
});