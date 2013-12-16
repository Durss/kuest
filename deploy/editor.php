<?php
	require_once("php/db/DBConnection.php");
	require_once("php/utils/OAuth.php");
	require_once("php/l10n/labels.php");
	
	header("Cache-Control: no-cache, must-revalidate");
	header("Expires: Mon, 26 Jul 1997 05:00:00 GMT");
	
	//Redirect the user if "www" are on the address. Prevents from SharedObject problems.
	if (strpos($_SERVER["SERVER_NAME"], "www") > -1) {
		header("location: http://fevermap.org/kuest/editor");
		die;
	}
	
	DBConnection::connect();
	
	//session_destroy(); die;
	OAuth::connect();
	
?>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html>
	<head>
		<title>Kuest</title>
		<link rel="shortcut icon" href="/kuest/favicon.ico" />
		<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
		<meta name="language" content="en" />
		<meta name="description" content="Tool to create quests for the game Kube." />
		<meta name="keywords" content="kube, quest, durss" />
		
		<link rel="stylesheet" type="text/css" href="/kuest/css/stylesheet.css"/>
		
		<script type="text/javascript" src="/kuest/js/swfobject.js"></script>
		<script type="text/javascript" src="/kuest/js/SWFAddress.js"></script>
		<script type="text/javascript" src="/kuest/js/swfwheel.js"></script>
		<script type="text/javascript" src="/kuest/js/swffit.js"></script>
		<STYLE type="text/css">
		  <!--
		  body, html {
			overflow:hidden;
			height:100%;
		  }
		  -->
		  </STYLE>
	</head>
	<body>
		<div id="content">
			<p>In order to view this page you need JavaScript and Flash Player 11+ support!</p>
			<a href="http://get.adobe.com/fr/flashplayer/">Install flash</a>
		</div>
		
		<script type="text/javascript">
			var lang = "<?php echo $lang ?>";
			if(lang.length == 0) {//Get browser's language if we couldn't get the user's language from Twinoid's API because ... dunno.
				lang = (navigator.language) ? navigator.language : navigator.userLanguage;
				lang = lang.split("-")[0];
			}
			//Compute this languages list via PHP depending on the folder's content.
			if(lang != "fr" && lang != "en") lang = "en";
			
			var flashvars = {};
			flashvars["version"] = "75";
			flashvars["configXml"] = "./xml/config.xml?v="+flashvars["version"];
			flashvars["lang"] = lang;
			var attributes = {};
			attributes["id"] = "externalDynamicContent";
			attributes["name"] = "externalDynamicContent";
			
			var params = {};
			params['allowFullScreen'] = 'true';
			params['menu'] = 'false';
			
			swfobject.embedSWF("/kuest/swf/application.swf?v="+flashvars["version"], "content", "100%", "100%", "11", "/kuest/swf/expressinstall.swf", flashvars, params, attributes);
			
			swffit.fit("externalDynamicContent", 800, 600, 3000, 3000, true, true);
		</script>
	</body>
</html>