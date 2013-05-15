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
	xhReq.setRequestHeader('Content-Type','application/x-www-form-urlencoded');
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