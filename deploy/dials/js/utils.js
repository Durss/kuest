function addEvent(element, evnt, funct){
  if (element.attachEvent)
   return element.attachEvent('on'+evnt, funct);
  else
   return element.addEventListener(evnt, funct, false);
}

function trim (src) {
	return src.replace(/^\s+/g,'').replace(/\s+$/g,'')
}

var onload = function () {
	parseExpandableBlocks();
	
	var flash = document.getElementsByClassName("flash");
	if(flash.length > 0) {
		if(flash[0].getElementsByTagName('pre').length == 0) {//a <pre> is present if displaying an error. Don't hide in this case
			function removeNode(node) {
				node.parentNode.removeChild(node);
			}
			TweenLite.to(flash[0], .25, {alpha:0, y:"-20", height:0, delay:2, onComplete:removeNode, onCompleteParams:[flash[0]]});
		}
	}
}

addEvent(window, 'load', onload);


function hasClass(el, name) {
   return new RegExp('(\\s|^)'+name+'(\\s|$)').test(el.className);
}
function addClass(el, name) {
   if (!hasClass(el, name)) { el.className += (el.className ? ' ' : '') +name; }
}
function removeClass(el, name) {
   if (hasClass(el, name)) {
	  el.className=el.className.replace(new RegExp('(\\s|^)'+name+'(\\s|$)'),' ').replace(/^\s+|\s+$/g, '');
   }
}

function parseExpandableBlocks() {
	var elements = document.getElementsByClassName("collapser");
	for(var i = 0; i < elements.length; i++) {
		elements[i].style.cursor = "pointer";
		elements[i].onclick = function() {
			var target = this.nextSibling;
			var secureLoop = 0;
			while(target.nodeName != "DIV" && secureLoop < 100) {
				target = target.nextSibling;
				secureLoop ++;
			}
			if(hasClass(target, "collapsed")) {
				addClass(this, "collapserOpen");
				removeClass(target, "collapsed");
			}else{
				removeClass(this, "collapserOpen");
				addClass(target, "collapsed");
			}
		}
	}
}



function ajaxLoader(url, callback)
{
	var x = (window.ActiveXObject) ? new ActiveXObject("Microsoft.XMLHTTP") : new XMLHttpRequest();
	if (x)
	{
		x.onreadystatechange = function()
		{
			if (x.readyState == 4 && x.status == 200)
			{
				callback(x.responseText);
			}
		}
		x.open("GET", url, true);
		x.send(null);
	}
}