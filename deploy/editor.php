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
		<meta name="keywords" content="kube, kuest, quest, durss" />
		
		<link rel="stylesheet" type="text/css" href="/kuest/css/stylesheet.css"/>
		<STYLE type="text/css">
		  <!--
		  body, html {
			overflow:hidden;
			height:100%;
		  }
		  -->
		  </STYLE>
		
		<script type="text/javascript" src="/kuest/js/isEventSupported.js"></script>
		<script type="text/javascript" src="/kuest/js/addRemoveEvent.js"></script>
        <script type="text/javascript" src="/kuest/js/swfobject.js"></script>
		<script type="text/javascript" src="/kuest/js/SWFAddress.js"></script>
		<script type="text/javascript" src="/kuest/js/swfwheel.js"></script>
		<script type="text/javascript" src="/kuest/js/swffit.js"></script>
		<script type="text/javascript" src="/kuest/js/editor.js"></script>
	</head>
	<body>
		<div id="content">
			<p>In order to view this page you need JavaScript and Flash Player 11+ support!</p>
			<a href="http://get.adobe.com/fr/flashplayer/">Install flash</a>
		</div>
		
		<script type="text/javascript">
			var lang = "<?php echo $lang ?>";
			var prompt = "<?php echo $editor_prompt; ?>";
            var Editor = new Editor();
		</script>
	</body>
</html>