// strongly based on: http://www.coova.org/CoovaChilli/JSON
// adapted by Guido De Rosa <guido.derosa@vemarsas.it>

function showUserStatus(h) {

  // If you use non standard configuration, define your configuration
  if (h.uamip)
    chilliController.host = h.uamip;    // default: ?
  if (h.uamport)
    chilliController.port = h.uamport;  // default: 3990 

  // chilliController.interval = 60    ; // keep default: 30 seconds

  // then define event handler functions
  chilliController.onError  = handleErrors;
  chilliController.onUpdate = updateUI ;

  // when the reply is ready, this handler function is called
  function updateUI( cmd ) {
    document.getElementById('status-window').innerHTML = (
      'Command = ' + cmd + '\n' +
      'Updated every ' + chilliController.interval + ' seconds\n'         +
      'Your current state is = ' + chilliController.clientState + '\n'    +
      'Session time = ' + chilliController.accounting.sessionTime + '\n'
    );
  }

  // If an error occurs, this handler will be called instead
  function handleErrors ( code ) {

   alert ( 'The last contact with the Controller failed. Error code =' + code );

  }
  //  finally, get current state
  chilliController.refresh() ;
}
