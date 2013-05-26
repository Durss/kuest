// ==UserScript==
// @name                Kuest
// @namespace	        http://fevermap.org/kuest
// @description	        Adds the possibility to play a quest inside the game Kube aswell as some connections with the editor.
// @include	            http://kube.muxxu.com/
// @include	            http://kube.muxxu.com/zone/choose
// @include	            http://kube.muxxu.com/?z=*
// @include	            http://kube.muxxu.com/?kuest=*
// ==/UserScript==

//Gets the query's parameters as an anonymous object
function getQueryString(target) {
	//Auto executed method
  var query_string = {};
  var query = target.substring(target.indexOf("?")+1);
  var vars = query.split("&");
  for (var i=0;i<vars.length;i++) {
    var pair = vars[i].split("=");
    // If first entry with this name
    if (typeof query_string[pair[0]] === "undefined") {
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

//Injects a method to the page's scope
function inject(source) {
	// Create a script node holding this  source code.
	var script = document.createElement('script');
	script.setAttribute("type", "application/javascript");
	script.textContent = source;

	// Insert the script node into the page.
	document.body.appendChild(script);
}

var lang		= "";
var local		= 'local' in getQueryString(window.location.href);
var kuestID		= getQueryString(window.location.href)['kuest'];
var testMode	= 'test' in getQueryString(window.location.href);
if(lang.length == 0) {//Get browser's language
	lang = (navigator.language) ? navigator.language : navigator.userLanguage;
	lang = lang.split("-")[0];
}
if(lang != "fr" && lang != "en") lang = "en";//Restrict to defaults

//Rewrite spawn URls if on zone selection page.
if(/zone\/choose/gi.test(window.location.href)) {
	kuestID = getQueryString(document.referrer)['kuest'];
	testMode = 'test' in getQueryString(document.referrer);
	if(kuestID) {
		var buttons = document.getElementsByClassName("button");
		for(var i=0; i < buttons.length; i++) {
			var href = buttons[i].getAttribute("href");
			if(href && /\?z=[0-9]+/gi.test(href)) {
				var url = href+"&kuest="+kuestID;
				if(testMode) url += "&test";
				buttons[i].setAttribute("href", url);
			}
		}
	}
	
}else{
	//Add SWF module
	var server = local? "localhost" : "fevermap.org";
	var gameDiv = unsafeWindow.document.getElementsByClassName("game")[0];
	var url = "http://"+server+"/kuest/swf/player.swf?";
	var kuestApp = unsafeWindow.document.createElement('div');
	if(kuestID) url += "kuestID="+kuestID;
	if(testMode) url += "&testMode=true";
	url += "&version=" + Math.round( Math.round( new Date().getTime() / 1000 )  / 3600 ) * 3600;//bypass cache every hour
	url += "&lang="+lang;
	url += "&configXml=http://"+server+"/kuest/xml/config.xml";

	//Gets the current's session user's ID.
	//If the fevermap server's UID isn't the same, the user will be disconnected.
	var menu = unsafeWindow.document.getElementsByClassName("mxmainmenu")[0];
	var links = menu.getElementsByTagName("a");
	var reg = /\/user\/([0-9]+)/;
	var currentUID = -1;
	for(var i = 0; i < links.length; ++i) {
		reg.lastIndex = 0;
		if(reg.test(links[i].getAttribute("href"))) {
			currentUID = links[i].getAttribute("href").match(reg)[1];
		}
	}
	url += "&currentUID="+currentUID;

	kuestApp.innerHTML = '<embed type="application/x-shockwave-flash" src="'+url+'" width="812" height="1" allowScriptAccess="always" bgcolor="#4CA5CD" id="kuestSWF" />';
	kuestApp.setAttribute("id", "kuestApp");
	kuestApp.style.position = "relative";
	kuestApp.style.left = "0px";
	kuestApp.style.width = "812px";
	kuestApp.style.marginTop = "25px";
	kuestApp.style.marginLeft = "34px";
	gameDiv.parentNode.appendChild(kuestApp);
	
	var app = document.getElementById("kuestApp");
	app.style.overflow = "hidden";
	app.style.transition = "all .35s ease-in-out";
	app.style.webkitTransition = "all .35s ease-in-out";
	if(!kuestID) {
		var btLabel = [];
		btLabel["fr"] = "Choisir une quête";
		btLabel["en"] = "Choisir a quest";
		btLabel["es"] = "Elegir una búsqueda";
		btLabel["de"] = "Wählen eine quest";
		var link = unsafeWindow.document.createElement('div');
		link.style.position = "relative";
		link.innerHTML = "<a href=\"http://muxxu.com/a/kuest/?act=browse\" target=\"_self\" class=\"button\">"+btLabel[lang]+"</a>";
		gameDiv.parentNode.appendChild(link);
	}

	function resizeSWF(height) {
		var app = document.getElementById("kuestSWF");
		var h = parseInt(app.style.height);
		if(document.kuestResizeTimeout) clearTimeout(document.kuestResizeTimeout);
		if(height < h) {
			document.kuestResizeTimeout = setTimeout(function(){ app.style.height = height + "px"; }, 350);
		}else{
			app.style.height = height + "px";
		}
		
		//Resize the div holder smoothly instead of the flash directly which would be source of glitches.
		document.getElementById("kuestApp").style.height = height+"px";
	}

	inject(resizeSWF);
}
