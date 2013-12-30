// ==UserScript==
// @name                KubeDials
// @namespace	        http://fevermap.org/dials
// @description	        Allows to express yourself on any zone while walking acrosse kube's world
// @include	            http://kube.muxxu.com/
// @include	            http://kube.muxxu.com/?z=*
// ==/UserScript==

var link = window.document.createElement('link');
link.rel = 'stylesheet';
link.type = 'text/css';
link.href = 'http://fevermap.org/dials/css/gm.css';
document.getElementsByTagName("HEAD")[0].appendChild(link);

//Gets the query's parameters as an anonymous object
function getQueryString(target) {
	//Auto executed method
  var query_string = {};
  var query = target.substring(target.indexOf("?")+1);
  var vars = query.split("&");
  for (var i=0;i<vars.length;i++) {
    var pair = vars[i].split("=");
    // If first entry with this name
    if (query_string[pair[0]] === "undefined") {
      query_string[pair[0]] = pair[1];
	  
    // If second entry with this name
    } else if (typeof query_string[pair[0]] === "string") {
      var arr = [ query_string[pair[0]], pair[1] ];
      query_string[pair[0]] = arr;
	  
    // If third or later entry with this name
    } else {
      query_string[pair[0]].push(pair[1]);
    }
  } 
  return query_string;
}


var gameDiv;
var currentUID = -1;
function getUIDAndCreateForm() {
	gameDiv = unsafeWindow.document.getElementsByClassName("game")[0];
    if(gameDiv == undefined) return;
    
    var ctn = document.body.innerHTML;
    var reg = /twinoid\..+\/user\/[0-9]+/i;
    if(reg.test(ctn) === true) {
        reg.index = 0;
        currentUID = ctn.match(reg)[0];
        currentUID = currentUID.substr(currentUID.lastIndexOf('/')+1);
    }
    //UID not found, try again later.
    if(currentUID == -1) {
        setTimeout(getUIDAndCreateForm, 500);
        return;
    }
    createDialForm();
	window.setInterval(checkText, 250);
}

var px = -10000000;
var py = -10000000;
var prevText;
function checkText() {
	var html = unsafeWindow.document.getElementById("infos").innerHTML;
	if(html == prevText) return;
	prevText = html;
	var regZone = /\[ ?(-?[0-9]+) ?\]\[ ?(-?[0-9]+) ?\]/i;
	if(regZone.test(html) && currentUID != -1) {
		var matches = regZone.exec(html);
		if(parseInt(matches[1]) != px || parseInt(matches[2]) != py) {
			px = parseInt(matches[1]);
			py = parseInt(matches[2]);
			console.log(px, py);
			unsafeWindow.document.getElementById('dial_title').innerHTML = "<b>Zone : </b>["+px+"]["+py+"]";
		}
	}
	
	if(px != -10000000 && py != -10000000){
		document.getElementById('submitButton').removeAttribute('disabled');
	}else{
		document.getElementById('submitButton').setAttribute('disabled', 'disabled');
	}
}

function createDialForm() {
    var form = unsafeWindow.document.createElement('div');
    form.innerHTML = '<div class="gmDial_holder">Module d\'ajout de dialogues pour un <a href="http://twinoid.com/fr/tid/forum#!view/492|thread/34318299">projet communautaire</a>.<br /><div id="dial_title"><b>Zone : </b>[?][?]</div><textarea id="dialogue" name="dialogue" placeholder="Dialogue... (20 caractères minimum)" class="dial_textarea"></textarea><br /><center><input type="button" id="submitButton" class="dial_button" value="Soumettre" /><div id="requestResult" /></center></div>';
    gameDiv.parentNode.appendChild(form);
	
	unsafeWindow.document.getElementById("dialogue").onkeydown = 
	unsafeWindow.document.getElementById("dialogue").onkeyup = function(e) { e.stopPropagation(); }
	unsafeWindow.document.getElementById("submitButton").onclick = function(e) {
		if(unsafeWindow.document.getElementById("dialogue").value.length < 20) {
			unsafeWindow.document.getElementById("requestResult").innerHTML = "<font color='#cc0000'>20 caractères minimum !</font><br />Encore un petit effort sitoplé :D";
			clearTimeout(clearTimeoutID);
			clearTimeoutID = setTimeout(clearResult, 3000);
			return;
		}
		clearResult();
		document.getElementById('submitButton').setAttribute('disabled', 'disabled');
		sendRequest('gm=true&uid='+encodeURIComponent(currentUID)+'&zoneX='+encodeURIComponent(px)+'&zoneY='+encodeURIComponent(py)+'&dialogue='+encodeURIComponent(unsafeWindow.document.getElementById("dialogue").value), 'http://fevermap.org/dials/', requestCallback);
	}
}

/**
 * Called on server's answer.
 * 
 * @param success	get if the webservice returned a success (see success node)
 * @param xml		XML document returned by the service
 * @param errorID	error ID if the success is false
 */
var clearTimeoutID;
function requestCallback(success, xml, errorID) {
	document.getElementById('submitButton').removeAttribute('disabled');
	if(success) {
		var thanks = [];
		thanks.push("Tu es une personne merveilleuse !");
		thanks.push("Merci d'être l'incarnation de la perfection <3");
		thanks.push("Comment t'es trop choux *o*");
		thanks.push("Vous êtes tout à fait formidable !");
		thanks.push("Tu as toujours été mon/ma préféré/e <3");
		thanks.push("De toi à moi, j'ai toujours su que tu étais au top !");
		thanks.push("Sans toi, le monde serait vachement moins beau...");
		thanks.push("Tu es adorable.");
		thanks.push("Merci d'être toi <3");
		thanks.push("Tu es si merveilleux/se...");
		thanks.push("Que ferais-je sans toi... <3");
		thanks.push("Si tes parents ne t'avaient pas fait, je m'en serais chargé ! <3");
		thanks.push("Des millions de poutoux pour te remercier ! COEUR !");
		thanks.push("<3 <3 <3 <3 <3 <3");
		thanks.push("Avalanche d'amour sur toi <3 !");
		thanks.push("Tu es formidable ! Reste comme t'es !");
		thanks.push("Tu es une très belle personne !");
		thanks.push("En toute honnêteté, tu es super !");
		thanks.push("Reste comme t'es, change rien ;)");
		unsafeWindow.document.getElementById("requestResult").innerHTML = "✓ Dialogue envoyé, merci :) !<br />"+thanks[ Math.round(Math.random() * (thanks.length-1)) ];
		clearTimeout(clearTimeoutID);
		clearTimeoutID = setTimeout(clearResult, 5000);
	}else{
		unsafeWindow.document.getElementById("requestResult").innerHTML = "<font color='#cc0000'>Une erreur s\'est produite ... :(</font><br />ERROR ID : "+errorID;
	}
}

function clearResult() {
	clearTimeout(clearTimeoutID);
	unsafeWindow.document.getElementById("requestResult").innerHTML = "";
}

//Injects a method to the page's scope
function inject(source) {
	// Create a script node holding this  source code.
	var script = document.createElement('script');
	script.setAttribute("type", "application/javascript");
	script.textContent = source;

	// Insert the script node into the page.
	document.body.appendChild(script);
}

getUIDAndCreateForm();
















/**
 * Sends an AJAX request.
 * 
 * @param vars		POST vars to send. Example : "var1=value1&var2=value2";
 * @param callback	Function called when request completes. Callback signature : callback(success:boolean, xml:document, errorID:String);
 **/
function sendRequest(vars, url, callback) {
	//Send server request
	if (window.XMLHttpRequest) {// code for IE7+, Firefox, Chrome, Opera, Safari
		var xhReq = new XMLHttpRequest();
	} else {// code for IE6, IE5
		var xhReq = new ActiveXObject("Microsoft.XMLHTTP");
	}
	xhReq.open("POST", url, true);
	xhReq.setRequestHeader('Content-Type','application/x-www-form-urlencoded; charset=UTF-8');
	xhReq.onreadystatechange = function() {
		if (xhReq.readyState == 4) {
			if(xhReq.status == 200) {
				//parse result
				if (window.DOMParser) {
					var parser = new DOMParser();
					var xmlDoc = parser.parseFromString(xhReq.responseText, "text/xml");
				}else{
					var xmlDoc =new ActiveXObject("Microsoft.XMLDOM");
					xmlDoc.async=false;
					xmlDoc.loadXML(xhReq.responseText);
				}
				
				if(xmlDoc.documentElement.getElementsByTagName("result").length == 0) {
					var success = false;
				}else{
					var success = xmlDoc.documentElement.getElementsByTagName("result")[0].attributes.getNamedItem("success").nodeValue;
				}
				
				//Server returns a success
				if(success == 'true') {
					callback(true, xmlDoc, '');
				}else{
					//an error occurred
					if(xmlDoc.documentElement.getElementsByTagName("error")[0] != undefined) {
						var errorCode = xmlDoc.documentElement.getElementsByTagName("error")[0].attributes.getNamedItem("id").nodeValue;
					}else{
						var errorCode = "";
					}
					callback(false, xmlDoc, errorCode);
				}
			}else{
				callback(false, null, '404');
			}
		}
	}
	xhReq.send(vars);
}