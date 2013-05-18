var loader1, loader2;
var error1, error2;
var noRes1, noRes2;
var res1, res2;
var template;
window.onload = function () {
	loader1 = document.getElementsByClassName("loader")[0];
	loader2 = document.getElementsByClassName("loader")[1];
	error1 = document.getElementsByClassName("serverError")[0];
	error2 = document.getElementsByClassName("serverError")[1];
	noRes1 = document.getElementsByClassName("noResult")[0];
	noRes2 = document.getElementsByClassName("noResult")[1];
	res1 = document.getElementsByClassName("results")[0];
	res2 = document.getElementsByClassName("results")[1];
	template = document.getElementsByClassName("template")[0].innerHTML;
	loadQuests();
	loadQuests(true);
}

/**
 * Called on server's answer.
 * 
 * @param success	get if the webservice returned a success (see success node)
 * @param xml		XML document returned by the service
 * @param errorID	error ID if the success is false
 */
function requestCallback(success, xml, errorID) {
	var topMode	= xml.documentElement.getElementsByTagName("kuests")[0].attributes.getNamedItem("top").nodeValue == "true";
	var loader	= topMode? loader1 : loader2;
	var error	= topMode? error1 : error2;
	var noRes	= topMode? noRes1 : noRes2;
	var res		= topMode? res1 : res2;
	loader.style.display = "none";
	if(success) {
		var nodes = xml.documentElement.getElementsByTagName("kuests")[0].getElementsByTagName("k");
		res.innerHTML = "";
		var len = nodes.length;
		for(var i = 0; i < len; ++i) {
			addItem(i, nodes[i%len], res);
		}
		if(nodes.length == 0) {
			noRes.style.display = "block";
			noRes.style.display = "block";
		}
	}else{
		error.style.display = "block";
		error.style.display = "block";
	}
}

function addItem(i, node, holder) {
	entry = {};
	entry['guid']	= node.attributes.getNamedItem("guid").nodeValue;
	entry['uid']	= node.getElementsByTagName("u")[0].attributes.getNamedItem("id").nodeValue;
	entry['uname']	= node.getElementsByTagName("u")[0].childNodes[0].nodeValue
	entry['title']	= node.getElementsByTagName("title")[0].childNodes[0].nodeValue
	var div = document.createElement('div');
	div.onclick = (function () { var id = entry['guid']; return function (e) { window.location = (e.layerX > 30)? "/kuest/redirect.php?kuest="+id : "/kuest/k/"+id; } })();
	div.className = i%2 == 0? "item" : "item mod";
	div.innerHTML = template.replace(/\{GUID\}/gi, entry['guid']).replace(/\{PSEUDO\}/gi, entry['uname']).replace(/\{TITLE\}/gi, entry['title']).replace(/\{UID\}/gi, entry['uid']);
	holder.appendChild(div);
}


function loadQuests() {
	var topMode = arguments[0];
	loader1.style.display = "block";
	loader2.style.display = "block";
	error1.style.display = "none";
	error2.style.display = "none";
	noRes1.style.display = "none";
	noRes2.style.display = "none";
	sendRequest(topMode? "top=true" : "", "/kuest/php/services/loadKuests.php", requestCallback);
}

function openUserSheet(event) {
	if(!event) event = window.event;
	if(event.stopPropagation) {
		event.stopPropagation();
	}else{
		event.cancelBubble = true;
	}
}