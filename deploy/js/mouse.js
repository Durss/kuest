/**************************************
*@Name: mouses.js
*  Mouse enter and MouseLeave event are more easier to use to determine when the mouse is currently positioned within an elment, or outside it.
*@Summary
* there are conterparts in almost every browser, which is called  mouseover and mouseout; the problem with them is that 
* @NOTE:
*   this has dependencies on other js files
*     1. isEventSupported.js
*     2. addremoveevents.js
* @todo:
*   Test and add them to the docs
***************************************/

(function () {
  if (isEventSupported("mouseenter")) { 
    this.hover = function(elem, fn) {
      addEvent(elem, "mouseenter", function() { 
        fn.call(elem, "mouseenter");
      });

      addEvent(elem, "mouseleave", function() {
        fn.call(elem, "mouseleave");
      });
    };
  } else {
    this.hover = function(elem, fn) { 
      addEvent(elem, "mouseover", function(e) { 
        withinElement(this, e, "mouseenter", fn);
      });
      addEvent( elem, "mouseout", function(e){
        withinElement( this, e, "mouseleave", fn );
      });
    };
  }

  function withinElement(elem, event, type, handle) {
    // Check if mouse(over|out) are still
    // within the same parent element
    var parent = event.relatedTarget; // this is non-ie, but the event withinEvent is mean to work on non-ie only

    // Traverse up the tree 
    while (parent && parent != elem) { 
      // Firefox sometimes assigns relatedTarget a XUL element
      // which we cannot access the parentNode property of
      try { 
        parent =  parent.parentNode;
      } catch (e) { break; }
    }

    if (parent != elem) { 
       // handle event if we actually just 
       // mouse oon to a non sub-element
       handle.call(elem, type);
    }
  }
})();