(function Syncer() {
	function checkInstall() {
		var isFirefox = typeof InstallTrigger !== 'undefined'; // Firefox 1.0+
		var isOpera = !!window.opera || navigator.userAgent.indexOf(' OPR/') >= 0;// Opera 8.0+ (UA detection to detect Blink/v8-powered Opera)
		var isChrome = !!window.chrome && !isOpera; // Chrome 1+
		document.getElementById('syncer-loader').style.display = 'none';//Hide loader
		document.getElementsByClassName('syncer-buttons-holder')[0].style.display = 'block';//Show holder
		
		if(typeof KuestExtensionInstalled === 'undefined') {
			//GM script isn't installed
			document.getElementById('playButton').style.display = 'none';//Hide play button
			document.getElementById('install_gm_chrome').style.display = (isChrome)? 'inline' : 'none';
			document.getElementById('extension-TM').style.display = (isChrome)? 'inline' : 'none';
			document.getElementById('install_gm_ff').style.display = (isFirefox)? 'inline' : 'none';
			document.getElementById('extension-GM').style.display = (isFirefox)? 'inline' : 'none';
		}else{
			//GM script is installed
			document.getElementById('installInstructions').style.display = 'none';//Hide install instruction
		}
	}
	var onload = function () {
		setTimeout(checkInstall, 1000);
	}

	addEvent(window, 'load', onload);
})()