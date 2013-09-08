(function Browser() {
	var loader1, loader2;
	var error1, error2;
	var noRes1, noRes2;
	var res1, res2;
	var onload = function () {
		var target = document.getElementsByClassName("browse")[0];
		loader1 = target.getElementsByClassName("loader")[0];
		loader2 = target.getElementsByClassName("loader")[1];
		error1 = target.getElementsByClassName("serverError")[0];
		error2 = target.getElementsByClassName("serverError")[1];
		noRes1 = target.getElementsByClassName("noResult")[0];
		noRes2 = target.getElementsByClassName("noResult")[1];
		res1 = target.getElementsByClassName("kuestsList")[0];
		res2 = target.getElementsByClassName("kuestsList")[1];
		loadQuests(false);
		loadQuests(true);
	}

	addEvent(window, 'load', onload);

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

	function loadQuests(topMode) {
		loader1.style.display = "block";
		loader2.style.display = "block";
		error1.style.display = "none";
		error2.style.display = "none";
		noRes1.style.display = "none";
		noRes2.style.display = "none";
		sendRequest(topMode? "top=true" : "top=false", "/kuest/php/services/loadKuests.php", requestCallback);
	}
})()