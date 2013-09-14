function addEvent(element, evnt, funct){
  if (element.attachEvent)
   return element.attachEvent('on'+evnt, funct);
  else
   return element.addEventListener(evnt, funct, false);
}

function trim (src) {
	return src.replace(/^\s+/g,'').replace(/\s+$/g,'')
}


function openUserSheet(event) {
	if(!event) event = window.event;
	if(event.stopPropagation) {
		event.stopPropagation();
	}else{
		event.cancelBubble = true;
	}
}


function addItem(i, node, holder) {
	entry = {};
	entry['guid']			= node.attributes.getNamedItem("guid").nodeValue;
	entry['uid']			= node.getElementsByTagName("u")[0].attributes.getNamedItem("id").nodeValue;
	entry['uname']			= node.getElementsByTagName("u")[0].childNodes[0].nodeValue;
	entry['title']			= node.getElementsByTagName("title")[0].childNodes[0].nodeValue;
	entry['description']	= node.getElementsByTagName("description")[0].childNodes[0].nodeValue;
	entry['description']	= entry['description'].replace("'", "\'");
	entry['complete']		= node.attributes.getNamedItem("complete") != null && node.attributes.getNamedItem("complete").nodeValue == 'true';
	var div = document.createElement('div');
	div.onclick = (function () {
						var id = entry['guid'];
						return function (e) {
							window.location = (e.layerX < 30)? "/kuest/redirect.php?kuest="+id : "/kuest/k/"+id;
						}
					})();
	new Opentip(div, entry['description'].replace('"', '\"'), { target: div, tipJoint: "bottom" });
	div.className = i%2 == 0? "item" : "item mod";
	if(entry['complete'] === true) addClass(div, 'complete');
	else addClass(div, 'notcomplete');
	var templateTmp	= template.replace(/\{GUID\}/gi, entry['guid']);
	templateTmp		= templateTmp.replace(/\{PSEUDO\}/gi, entry['uname'])
	templateTmp		= templateTmp.replace(/\{TITLE\}/gi, entry['title'])
	templateTmp		= templateTmp.replace(/\{UID\}/gi, entry['uid']);
	if(node.attributes.getNamedItem("complete") != null) {
		templateTmp	= templateTmp.replace(/\{COMPLETE_ICON\}/gi, ((entry['complete'] === true)? '<img src="/kuest/img/checkMark.png" alt="OK"/>' : '<img src="/kuest/img/hourglass.png" alt="..."/>'));
	}else{
		templateTmp	= templateTmp.replace(/\{COMPLETE_ICON\}/gi, '');
	}
	
	div.innerHTML = templateTmp;
	holder.appendChild(div);
}

var template;
var onload = function () {
	parseExpandableBlocks();
	if(document.getElementsByClassName("template").length == 0) return;
	template = document.getElementsByClassName("template")[0].innerHTML;
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