(function Appear() {
	var onload = function () {
		document.getElementById('content').style.display = 'block';
		
		var nodes = document.getElementsByClassName('big');
		var delay = 0;
		//Do menu transition only once a day not to be borring as hell
		if(localStorage['lastVisiteDate'] == undefined || localStorage['lastVisiteDate'] != new Date().getDate()) {
			for(var i = 0; i < nodes.length; ++i) {
				if(nodes[i].style.display == "none") continue;
				//nodes[i].style.top = -80px;
				TweenLite.from(nodes[i], .5, {alpha:0, y:"-60", delay:delay, onComplete:onComplete, onCompleteParams:[nodes[i]]});
				delay += .1;
			}
			
			setTimeout(writeCookie, 1000);
		}else{
			for(var i = 0; i < nodes.length; ++i) {
				onComplete(nodes[i]);
			}
		}
		
		//Windows transition
		nodes = document.getElementsByClassName('window');
		for(var i = 0; i < nodes.length; ++i) {
			if(nodes[i].style.display == "none") continue;
			TweenLite.from(nodes[i], .25, {alpha:0, y:"-20", delay:delay});
			delay += .1;
		}
	}
	addEvent(window, 'load', onload);
	
	//Put CSS transition on buttons to get transitions on rolls
	function onComplete(target) {
		target.style.setProperty('-webkit-transition', ".25s all ease-out");
		target.style.setProperty('-o-transition', ".25s all ease-out");
		target.style.setProperty('-moz-transition', ".25s all ease-out");
		target.style.setProperty('transition', ".25s all ease-out");
	}
	
	function writeCookie() {
		localStorage['lastVisiteDate'] = new Date().getDate();
	}
})()