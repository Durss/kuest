/************************************** 
*@Name: addremoveevents.js 
*  the code of the centralobjectsstore.js, which has the central data store, together with the fixevents.js ,which contains the method that simulat the DOM events.  
*  with the data store we can create new set of addEvent and removeEvent methods that work closer to our desired outcome in all browsers, as seen in List 13 - 4 
*@Summary 
*  
* @todo: 
*   Test 
***************************************/  
  
/**  
* below is the code of centralizedatastore.js 
*/  
(function () {  
  var cache = {}, guid = 1, expando = "data" + (new Date).getTime();  
  this.getData = function (elem) {  
    var id = elem[expando];  
    if (!id) {  
      id = elem[expando] = guid++;  
      cache[id] = {};  
    }  
    return cache[id];  
  };  
  this.removeData = function (elem) {  
    var id = elem[expando];  
    if (!id) {  
      return;  
    }  
    // Remove all stored data  
    delete cache[id];  
    // Remove the expando property from the DOM node  
    try {  
      delete elem[expando];  
    } catch (e) {  
      if (elem.removeAttribute) {  
        elem.removeAttribute(expando);  
      }  
    }  
  };  
})();  
  
  
  
/** 
* below is the code of fixEvent.js 
*/  
function fixEvent(event) {  
  
  if (!event || !event.stopPropagation) {  
    alert("inside fixing event");  
    var old = event || window.event;  
    // Clone the old object so that we can modify the values  
    event = {};  
    for (var prop in old) {  
      event[prop] = old[prop];  
    }  
    // The event occurred on this element  
    if (!event.target) {  
      event.target = event.srcElement || document;  
    }  
    // Handle which other element the event is related to  
    event.relatedTarget = event.fromElement === event.target ?  
      event.toElement :  
      event.fromElement;  
    // Stop the default browser action  
    event.preventDefault = function () {  
      event.returnValue = false;  
      event.isDefaultPrevented = returnTrue;  
    };  
    event.isDefaultPrevented = returnFalse;  
    // Stop the event from bubbling  
    event.stopPropagation = function () {  
      event.cancelBubble = true;  
      event.isPropagationStopped = returnTrue;  
    };  
    event.isPropagationStopped = returnFalse;  
    // Stop the event from bubbling and executing other handlers  
    event.stopImmediatePropagation = function () {  
      this.isImmediatePropagationStopped = returnTrue;  
      this.stopPropagation();  
    };  
    event.isImmediatePropagationStopped = returnFalse;  
  
    // Handle mouse position  
    if (event.clientX != null) {  
      var doc = document.documentElement, body = document.body;  
      event.pageX = event.clientX +  
        (doc && doc.scrollLeft || body && body.scrollLeft || 0) -  
        (doc && doc.clientLeft || body && body.clientLeft || 0);  
      event.pageY = event.clientY +  
        (doc && doc.scrollTop || body && body.scrollTop || 0) -  
        (doc && doc.clientTop || body && body.clientTop || 0);  
    }  
    // Handle key presses  
    event.which = event.charCode || event.keyCode;  
    // Fix button for mouse clicks:  
    // 0 == left; 1 == middle; 2 == right  
    if (event.button != null) {  
      event.button = (event.button & 1 ? 0 :  
        (event.button & 4 ? 1 :  
        (event.button & 2 ? 2 : 0)));  
    }  
  }  
  return event;  
  
  // move the following code from the end of function  
  //  fixEvent(event)   
  function returnTrue() {  
    return true;  
  }  
  function returnFalse() {  
    return false;  
  }  
}  
  
(function () {  
  var guid = 1;  
  this.addEvent = function (elem, type, fn) {  
    var data = getData(elem), handlers;  
  
    // We only need to generate one handler per element  
    if (!data.handler) {  
      // Our new meta-handler that fixes  
      // the event object and the context  
      data.handler = function (event) { // - the event is given the value when the actual event is fired.   
        event = fixEvent(event);  
          
        var handlers = getData(elem).events[event.type];  
        // Go through and call all the real bound handlers  
        for (var i = 0, l = handlers.length; i < l; i++) {  
          handlers[i].call(elem, event); 
          // Stop executing handlers since the user requested it  
          if (event.isImmediatePropagationStopped != undefined && event.isImmediatePropagationStopped()) {  
            break;  
          }  
        }  
      };  
    }  
    // We need a place to store all our event data  
    if (!data.events) {  
      data.events = {};  
    }  
    // And a place to store the handlers for this event type  
    handlers = data.events[type];  
    if (!handlers) {  
      handlers = data.events[type] = [];  
      // Attach our meta-handler to the element,  
      // since one doesn't exist  
      if (document.addEventListener) {  
        elem.addEventListener(type, data.handler, false);  
      } else if (document.attachEvent) {  
        elem.attachEvent("on" + type, data.handler);  
      }  
    }  
    if (!fn.guid) {  
      fn.guid = guid++;  
    }  
    handlers.push(fn);  
  
  
  };  
  
  this.removeEvent = function (elem, type, fn) {  
    var data = getData(elem), handlers;  
    // If no events exist, nothing to unbind  
    if (!data.events) {  
      return  
    }  
    // Are we removing all bound events?  
    if (!type) {  
      for (type in data.events) {  
        cleanUpEvents(elem, type);  
      }  
      return;  
    }  
    // And a place to store the handlers for this event type  
    handlers = data.events[type];  
    // If nohandlers exist, nothing to unbind  
    if (!handlers) {  
      return;  
    }  
    // See if we're only removing a single handler  
    if (fn && fn.guid) {  
      for (var i = 0; i < handlers.length; i++) {  
        // We found a match  
        // (don't stop here, there could be a couple bound)  
        if (handlers[i].guid === fn.guid) {  
          // Remove the handler from the array of handlers  
          handlers.splice(i--, 1);  
        }  
      }  
    }  
    cleanUpEvents(elem, type);  
  };  
  // A simple method for changing the context of a function  
  this.proxy = function (context, fn) {  
    // Make sure the function has a unique ID  
    if (!fn.guid) {  
      fn.guid = guid++;  
    }  
    // Create the new function that changes the context  
    var ret = function () {  
      return fn.apply(context, arguments);  
    };  
    // Give the new function the same ID  
    // (so that they are equivalent and can be easily removed)  
    ret.guid = fn.guid;  
    return ret;  
  };  
  function cleanUpEvents(elem, type) {  
    var data = getData(elem);  
    // Remove the events of a particular type if there are none left  
    if (data.events[type].length === 0) {  
      delete data.events[type];  
      // Remove the meta-handler from the element  
      if (document.removeEventListener) {  
        elem.removeEventListener(type, data.handler, false);  
      } else if (document.detachEvent) {  
        elem.detachEvent("on" + type, data.handler);  
      }  
    }  
    // Remove the events object if there are no types left  
    if (isEmpty(data.events)) {  
      delete data.events;  
      delete data.handler;  
    }  
    // Finally remove the expando if there is no data left  
    if (isEmpty(data)) {  
      removeData(elem);  
    }  
  }  
  function isEmpty(object) {  
    for (var prop in object) {  
      return false;  
    }  
    return true;  
  }  
})();  
  
  
function triggerEvent(elem, event) {  
  var handler = getData(elem).handler, parent = elem.parentNode || elem.ownerDocument;  
  if (typeof event === 'string') {  
    event = { type: event, target: elem };  
  }  
  
  if (handler) {  
    handler.call(elem, event);  
  }  
  
  
  // Bubble the event up the tree to the document,  
  // Unless it's been explicitly stopped  
  if (parent && !event.isPropagationStopped()) {  
    triggerEvent(parent, event);  
  // We're at the top document so trigger the default action  
  } else if (!parent && !event.isDefaultPrevented()) {  
    var targetData = getData(event.target), targetHandler = targetData.handler;  
    // so if there is handler to the defalt handler , we execute it   
    if (event.target[event.type]) {  // I Suppose that it is the event.type rather than just the type  
      // Temporarily disable the bound handler,   
      // don't want to execute it twice  
      if (targetHandler) {  
        targetData.handler = function () { };  
      }  
      // Trigger the native event (click, focus, blur)  
      event.target[event.type](); // I suppose that it is the event.type rather than the type   
  
      // restore the handler  
      if (targetHandler) {  
        targetData.handler = targetHandler;  
      }  
    }  
  }  
}  