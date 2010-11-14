// requires ChilliLibrary.js
// See: http://www.coova.org/CoovaChilli/JSON
//
// Copyright(c) 2010, Guido De Rosa <guido.derosa@vemarsas.it>
// License: MIT

chilliController.timeLeft = function() {
  return Math.max(
    (
      chilliController.session.sessionTimeout -
      chilliController.accounting.sessionTime
    ),
    0
  );
}

chilliController.scheduleTimeoutAutorefresh = function() {
  if (chilliController.timeLeft() && !chilliController.timeoutTimer) {
    chilliController.timeoutTimer = {
      preLogoff:  setTimeout(
        'chilliController.refresh()', 1000 * chilliController.timeLeft()
      ),
      atLogoff:   setTimeout( // 3 seconds delay looks fair
        'chilliController.refresh()', 1000 * (3 + chilliController.timeLeft())
      )
    }
  }
}

function showUserStatus(h) {

  // Utility functions and objects
  //
  function formatStateCode(code) {
    switch(code) {
      case chilliController.stateCodes.UNKNOWN:
        return 'Unknown';
      case chilliController.stateCodes.NOT_AUTH:
        return 'Not Authorized';
      case chilliController.stateCodes.AUTH:
        return 'Authorized';
      case chilliController.stateCodes.AUTH_PENDING:
        return 'Authorization Pending';
      case chilliController.stateCodes.AUTH_SPLASH:
        return 'AUTH_SPLASH'; // What does it mean?
      default:
        return code;
    }
  }

  // CoovaChilli JSON interface only supports CHAP... don't use JSON to login.
  // TODO: support https://
  function loginURL() {
    return 'http://' + h.uamip + ':' + h.uamport;
  }
  
  // chilliController.debug = true;

  // If you use non standard configuration, define your configuration
  if (h.uamip)
    chilliController.host = h.uamip;    // default: 192.168.182.1
  if (h.uamport)
    chilliController.port = h.uamport;  // default: 3990 

  // We choose 5 minutes because is the default interval of Chilli->Radius
  // accounting updates, and looks reasonable for busy sites (avoiding too
  // much load on the network infrastructure and servers) .
  chilliController.interval = h.updateInterval || 300;  // default = 30

  // then define event handler functions
  chilliController.onError  = handleErrors;
  chilliController.onUpdate = updateUI ;

  // get current state
  chilliController.refresh() ;

  // schedule a refresh if there's a sessionTimeout
  ms = chilliController.timeLeft() * 1000;
  setTimeout('chilliController.refresh()', ms);

  function updateHeadings(clientState) {
    txt = null;
    switch(clientState) {
      case chilliController.stateCodes.NOT_AUTH:
        txt = 'Logged out from HotSpot';
        break;
      case chilliController.stateCodes.AUTH:
        txt = 'Logged in to HotSpot';
        break;
    }
    if (txt) {
      document.title = txt;
      if (document.getElementById('headline')) 
        document.getElementById('headline').innerHTML = txt;
    }
  }

  function updateLinks(clientState) {
    if (clientState == chilliController.stateCodes.NOT_AUTH) 
      document.getElementById('logInLogOut').innerHTML = 
          '<a href="' + loginURL(chilliController) + '">' + 'Login</a>';
  }

  // when the reply is ready, this handler function is called
  function updateUI( cmd ) {
    updateHeadings( chilliController.clientState);
    updateLinks(    chilliController.clientState);
    document.getElementById('userName').innerHTML = (
        chilliController.session.userName
    );
    document.getElementById('clientState').innerHTML = (
      formatStateCode(chilliController.clientState) 
    );
    document.getElementById('sessionTime').innerHTML = (
      chilliController.formatTime(
        chilliController.accounting.sessionTime, '0')
    );
    if (chilliController.session.sessionTimeout) {
      document.getElementById('timeLeft').innerHTML = (
        chilliController.formatTime(chilliController.timeLeft(), 0) 
      );
    } else {
      document.getElementById('timeLeft').innerHTML = ''
    }
    var download_bytes = 
      chilliController.accounting.inputOctets +
      Math.pow(2, 32) * chilliController.accounting.inputGigawords; 
    var upload_bytes = 
      chilliController.accounting.outputOctets +
      Math.pow(2, 32) * chilliController.accounting.outputGigawords;    
    document.getElementById('download').innerHTML = (
      chilliController.formatBytes(download_bytes, 0)
    );
    document.getElementById('upload').innerHTML = (
      chilliController.formatBytes(upload_bytes, 0)
    );
    document.getElementById('interval').innerHTML = (
      chilliController.formatTime(chilliController.interval, 0)
    );
    
    // (re)-schedule a refresh at sessionTimeout
    chilliController.scheduleTimeoutAutorefresh();
  }

  // If an error occurs, this handler will be called instead
  function handleErrors ( code ) {
    alert('The last contact with the Controller failed. Error code =' + code);
  }


}

