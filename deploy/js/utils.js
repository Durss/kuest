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
	var div = document.createElement('div');
	div.onclick = (function () {
						var id = entry['guid'];
						return function (e) {
							//If not in muxxu's context, just redirect
							//if(window.parent == window) {
								var details = window.location.host == 'localhost'? "/kuest/syncer.php?id="+id : "/kuest/k/"+id;
								window.location = (e.layerX < 30)? "/kuest/redirect.php?kuest="+id : details;
							/*}else{
								//If in muxxu's contest, rewrite main URL if we watch details
								if(e.layerX > 30) {
									window.location = "/kuest/redirect.php?kuest="+id;
								} else {
									window.parent.location = "http://muxxu.com/a/kuest/?act=k_kid="+id;
								}
							}*/
						}
					})();
	div.onmouseover = (function (div, description, options) { return function () { tooltip.pop(div, description, options); }; })(div, entry['description'], {position:0, calloutPosition:.5, offsetY:10});
	div.className = i%2 == 0? "item" : "item mod";
	div.innerHTML = template.replace(/\{GUID\}/gi, entry['guid']).replace(/\{PSEUDO\}/gi, entry['uname']).replace(/\{TITLE\}/gi, entry['title']).replace(/\{UID\}/gi, entry['uid']);
	holder.appendChild(div);
}

var template;
var onload = function () {
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