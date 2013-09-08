(function Search() {
	var submit, input, loader, error, noRes, res, searchHolder, content, resultsHolder, timeout;
	var onload = function () {
		var target = document.getElementsByClassName("search")[0];
		searchHolder = target.getElementsByClassName("window")[0];
		submit = document.getElementById('submitButton');
		input = document.getElementById('searchInput');
		content = target.getElementsByClassName('content')[0];
		
		target = document.getElementsByClassName("resultsHidden")[0];
		resultsHolder = target;
		loader = target.getElementsByClassName("loader")[0];
		error = target.getElementsByClassName("serverError")[0];
		noRes = target.getElementsByClassName("noResult")[0];
		res = target.getElementsByClassName("kuestsList")[0];
		
		addEvent(submit, 'click', onSubmit);
		addEvent(input, 'keyup', onKeyUp);
		
        hover(searchHolder, function (type) { if (type === "mouseenter") overHandler();  else outHandler(); });  
	}
	addEvent(window, 'load', onload);

	//Called when search box is rolled over
	function overHandler(event) {
		if(hasClass(content, 'close')) {
			removeClass(content, 'close');
			addClass(content, 'open');
			input.focus();
		}
	}

	//Called when search box is rolled out
	function outHandler(event) {
		if(hasClass(content, 'open')) {
			removeClass(content, 'open');
			addClass(content, 'close');
		}
	}

	//Called when a key is released inside the input
	function onKeyUp(e) {
		if(e.keyCode == 13) {//Enter submit form
			onSubmit();
		}
		if(e.keyCode == 27) {//Escape, close results
			input.value = '';
			resultsHolder.className = 'resultsHidden';
		}
	}

	//Submit form
	function onSubmit() {
		//If there are less than 3 letters written
		if(trim(input.value).length < '3') {
			input.focus();
			return;
		}
		
		clearTimeout(timeout);
		loader.style.display = "block";
		error.style.display = "none";
		noRes.style.display = "none";
		sendRequest("search="+trim(input.value), "/kuest/php/services/search.php", requestCallback);
		resultsHolder.className = 'resultsVisible';
	}



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
				timeout = setTimeout(hideResults, 2000);
			}
		}else{
			error.style.display = "block";
			error.style.display = "block";
		}
	}
	
	/**
	 * Hides the results
	 */
	function hideResults() {
		resultsHolder.className = 'resultsHidden';
	}
})();