// ==UserScript==
// @name                Kuest
// @namespace	        http://fevermap.org/kuest
// @description	        Adds the possibility to play a quest inside the game Kube aswell as some connections with the editor.
// @include	            http://kube.muxxu.com/
// @include	            http://kube.muxxu.com/zone/choose
// @include	            http://kube.muxxu.com/?z=*
// @include	            http://kube.muxxu.com/?kuest=*
// @include	            http://fevermap.org/kuest/*
// @include	            http://local.kuest/*
// ==/UserScript==

unsafeWindow.KuestExtensionInstalled = true;

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
document._kuestLang = lang;

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
	var server = local? "local.kuest" : "fevermap.org/kuest";
	var gameDiv = unsafeWindow.document.getElementsByClassName("game")[0];
	var url = "http://"+server+"/swf/player.swf?";
	var kuestApp = unsafeWindow.document.createElement('div');
    var params = [];
	if(kuestID)    params.push("kuestID="+kuestID);
	if(testMode)   params.push("testMode=true");
	params.push("version=" + Math.round( Math.round( new Date().getTime() / 1000 )  / 3600 ) * 3600);//bypass cache every hour
	params.push("lang="+lang);
	params.push("configXml=http://"+server+"/xml/config.xml");
	params.push("root=http://"+server);
    url += params.join('&');

	//Gets the current's session user's ID.
	//Searches for UID inside page's source.
	//If the fevermap server's UID isn't the same, the user will be disconnected.
	function getUIDAndInstanciateApp() {
		if(gameDiv == undefined) return;
		var offset = 0;
		var currentUID = -1;
		var ctn = document.body.innerHTML;
		var reg = /twinoid\..+\/user\/[0-9]+/i;
		if(reg.test(ctn) === true) {
			reg.index = 0;
			currentUID = ctn.match(reg)[0];
			currentUID = currentUID.substr(currentUID.lastIndexOf('/')+1);
		}
		//UID not found, try again later.
		if(currentUID == -1) {
			setTimeout(getUIDAndInstanciateApp, 500);
			return;
		}
		url += "&currentUID="+currentUID;

		kuestApp.innerHTML = '<iframe src="http://'+server+'/?bpAuth" width="0" height="0" style="border: 0px none transparent; padding: 0px; overflow: hidden;"></iframe><embed type="application/x-shockwave-flash" src="'+url+'" width="812" height="1" allowScriptAccess="always" bgcolor="#4CA5CD" id="kuestSWF" />';
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
	}

	//Resizes the flash app to the size asked by it.
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
	
	//Called if no quest are loaded
	function noQuest() {
		var gameDiv = document.getElementsByClassName("game")[0];
		var btLabel = [];
		btLabel["fr"] = "Choisir une quête";
		btLabel["en"] = "Choose a quest";
		btLabel["es"] = "Elegir una búsqueda";
		btLabel["de"] = "Wählen eine quest";
		var link = document.createElement('div');
		link.style.position = "relative";
		link.innerHTML = "<a href=\"http://fevermap.org/kuest/?act=browse\" target=\"_self\" class=\"button\">"+btLabel[document._kuestLang]+"</a>";
		gameDiv.parentNode.appendChild(link);
		resizeSWF(0);
	}

	inject(noQuest);
	inject(resizeSWF);
	getUIDAndInstanciateApp();
}