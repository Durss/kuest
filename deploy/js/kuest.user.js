// ==UserScript==
// @name                Kuest
// @namespace	        http://fevermap.org/kuest
// @description	        
// @include		http://kube.muxxu.com/
// @include		http://kube.muxxu.com/?*
// ==/UserScript==

//Gets the query's parameters as an anonymous object
var queryString = function () {
	//Auto executed method
  var query_string = {};
  var query = window.location.search.substring(1);
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
} ();

var kuestID = queryString['kuest'];
var gameDiv = unsafeWindow.document.getElementsByClassName("game")[0];
var url = "http://localhost/kuest/swf/player.swf";
var kuestApp = unsafeWindow.document.createElement('div');
url += "?id="+kuestID;
url += "&version=1";
url += "&configXml=http://localhost/kuest/xml/config.xml";

kuestApp.innerHTML = '<embed type="application/x-shockwave-flash" src="'+url+'" width="812" height="'+(kuestID? 200 : 1)+'" allowScriptAccess="always" bgcolor="#4CA5CD" id="kuestSWF" />';
kuestApp.setAttribute("id", "kuestApp");
kuestApp.style.position = "relative";
kuestApp.style.left = "0px";
kuestApp.style.width = "812px";
kuestApp.style.height = kuestID? "200px" : "1px";
kuestApp.style.marginTop = "50px";
kuestApp.style.marginLeft = "34px";
gameDiv.parentNode.appendChild(kuestApp);