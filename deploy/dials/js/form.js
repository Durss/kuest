(function DialForm() {
	var onload = function () {
		var form = document.getElementsByTagName('form')[0];
		var submit = document.getElementById('submitButton');
		var zoneX = document.getElementById('zoneX');
		var zoneY = document.getElementById('zoneY');
		var uid = document.getElementById('uid');
		var avatar = document.getElementsByClassName('avatar')[0];
		var nickname = document.getElementsByClassName('nickname')[0];
		var dialogue = document.getElementById('dialogue');
		var isError;
		form.onsubmit = function () {
			isError = false;
			if(trim(zoneX.value).length == 0 || parseInt(zoneX.value) < -100 || parseInt(zoneX.value) > 100) {
				displayError(zoneX);
			}
			if(trim(zoneY.value).length == 0 || parseInt(zoneY.value) < -100 || parseInt(zoneY.value) > 100) {
				displayError(zoneY);
			}
			if(trim(uid.value).length == 0 || parseInt(uid.value) <= 0) {
				displayError(uid);
			}
			if(trim(dialogue.value).length < 20) {
				displayError(dialogue);
			}
			
			return !isError;
		}
		
		function displayError(target) {
			if(!isError) target.focus();
			isError = true;
			if(!hasClass(target, 'errorInput')) {
				addClass(target, 'errorInput');
			}
		}
		
		zoneX.onblur = zoneY.onblur = uid.onblur = dialogue.onblur = function () {
			if(this == zoneX || this == zoneY) {
				var v = parseInt(this.value);
				this.value = Math.min(Math.max(this.value, -100), 100);
			}
			removeClass(this, 'errorInput');
		}
		
		var timeout;
		uid.onkeyup = function() {
			clearTimeout(timeout);
			timeout = setTimeout(refreshAvatar, 500);
		}
		
		var prevID;
		function refreshAvatar() {
			var id = parseInt(uid.value);
			if(id == prevID) return;
			prevID = id;
			
			var url = 'getProfilePic.php?pic=' + id;
			ajaxLoader(url, onProfileData);
		}
		
		function onProfileData(data) {
			var chunks=data.split('\n');
			if((/^http:\/\/.*\.(jpg|png)$/i.test(chunks[0]))) {
				avatar.src = chunks[0];
			}else{
				avatar.src = 'img/thanks.png';
			}
			if(chunks[1].length > 20) {
				chunks[1] = chunks[1].substr(0, 20)+'…';
			}
			nickname.innerHTML = chunks[1];
		}
		
		if(trim(uid.value).length > 0 && parseInt(uid.value) > 0) {
			refreshAvatar();
		}
		
		
		var isFirefox = typeof InstallTrigger !== 'undefined'; // Firefox 1.0+
		var isOpera = !!window.opera || navigator.userAgent.indexOf(' OPR/') >= 0;// Opera 8.0+ (UA detection to detect Blink/v8-powered Opera)
		var isChrome = !!window.chrome && !isOpera; // Chrome 1+
		if(isFirefox) {
			document.getElementById('GM').style.display = 'inline';
		}else
		if(isChrome) {
			document.getElementById('TM').style.display = 'inline';
		}else {
			document.getElementById('gmLink').style.display = 'none';
		}
		
	}
	addEvent(window, 'load', onload);
})()