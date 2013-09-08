/************************************** 
*@Name: addremoveevents.js 
*  this is an code that determine if an event support bubbling 
*@Summary 
*  
* @todo: 
*   Test 
***************************************/  
  
function isEventSupported(eventName) {  
  var el = document.createElement('div'), isSupported;  
  
  eventName = 'on' + eventName;  
  
  isSupported = (eventName in el); // this is a special use of in operator  
  
  if (!isSupported) {  
    el.setAttribute(eventName, 'return;');  
    isSupported = typeof el[eventName] == 'function';  
  }  
  
  el = null;  
  return isSupported;  
}  