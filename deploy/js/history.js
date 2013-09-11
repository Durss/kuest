(function History() {
	var submit, input, loader, error, noRes, res, searchHolder, content, resultsHolder, timeout;
	var onload = function () {
		var target = document.getElementsByClassName("browse")[0];
		searchHolder = target.getElementsByClassName("window")[0];
		submit = document.getElementById('submitButton');
		input = document.getElementById('searchInput');
		content = target.getElementsByClassName('content')[0];
		
		resultsHolder = target;
		loader = target.getElementsByClassName("loader")[0];
		error = target.getElementsByClassName("serverError")[0];
		noRes = target.getElementsByClassName("noResult")[0];
		res = target.getElementsByClassName("kuestsList")[0];
		
		loader.style.display = "block";
		error.style.display = "none";
		noRes.style.display = "none";
		sendRequest("", "/kuest/php/services/history.php", requestCallback);
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
				var suggestion = xml.documentElement.getElementsByTagName("suggestion")[0];
				addItem(0, suggestion, res);
			}
		}else{
			error.style.display = "block";
			error.style.display = "block";
		}
	}
})();