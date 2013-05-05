<?php
	session_start();
	header("Cache-Control: no-cache, must-revalidate");
	header("Expires: Mon, 26 Jul 1997 05:00:00 GMT");
	
	//Redirect the user if "www" are on the address. Prevents from SharedObject problems.
	if (strpos($_SERVER["SERVER_NAME"], "www") > -1) {
		header("location: http://fevermap.org/kuest");
		die;
	}
	if (isset($_GET["act"]) && $_GET["act"] == "ids") {
		header("location:ids.php?uid=".$_GET['uid']."&pubkey=".$_GET['pubkey']);
		die;
	}
	
	$lang = "";
	if(isset($_GET['uid'], $_GET['pubkey'])) {
		$url = "http://muxxu.com/app/xml?app=kuest&xml=user&id=".$_GET['uid']."&key=".md5("34e2f927f72b024cd9d1cf0099b097ab" . $_GET["pubkey"]);
		$xml = simplexml_load_file($url);
		preg_match('/name="(.*?)"/i', $xml, $matches, PREG_OFFSET_CAPTURE); //*? = quantificateur non gourmand
		if ($xml->getName() != "error") {
			$pseudo	= (string) $xml->attributes()->name;
			$lang = (string)$xml->attributes()->lang;
			$_SESSION['lang'] = $lang;
		}
	}else {
		if (isset($_SESSION['lang'])) $lang = $_SESSION['lang'];
	}
	
	//Check if the application is localized in this lang or not. If not, use english.
	if ($lang != "" && !file_exists("xml/i18n/labels_".$lang.".xml")) $lang = "en";
?>	
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html>
	<head>
		<title>Kuest</title>
		<link rel="shortcut icon" href="favicon.ico" />
		<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
		<meta name="language" content="en" />
		<meta name="description" content="Tool to create quests for the game Kube." />
		<meta name="keywords" content="kube, quest, durss" />
		
		<link rel="stylesheet" type="text/css" href="css/stylesheet.css"/>
		
		<script type="text/javascript" src="js/swfobject.js"></script>
		<script type="text/javascript" src="js/SWFAddress.js"></script>
		<script type="text/javascript" src="js/swfwheel.js"></script>
		<script type="text/javascript" src="js/swffit.js"></script>
	</head>
	<body>
		<div id="content">
			<p>In order to view this page you need JavaScript and Flash Player 11+ support!</p>
			<a href="http://get.adobe.com/fr/flashplayer/">Install flash</a>
		</div>
		
		<script type="text/javascript">
			var lang = "<?php echo $lang ?>";
			if(lang.length == 0) {//Get browser's language if we couldn't get the user's language from muxxu XML API because user isn't logged-in.
				lang = (navigator.language) ? navigator.language : navigator.userLanguage;
				lang = lang.split("-")[0];
			}
			//Compute this languages list via PHP depending on the folder's content.
			if(lang != "fr" && lang != "en") lang = "en";
			
			var flashvars = {};
			flashvars["version"] = "11";
			flashvars["configXml"] = "./xml/config.xml?v="+flashvars["version"];
			flashvars["lang"] = lang;
<?php
	if (isset($_GET["uid"], $_GET["pubkey"])) {
		echo "\t\t\tflashvars['uid'] = '".htmlentities($_GET["uid"])."';\r\n";
		echo "\t\t\tflashvars['pubkey'] = '".htmlentities($_GET["pubkey"])."';\r\n";
	}
?>
			
			var attributes = {};
			attributes["id"] = "externalDynamicContent";
			attributes["name"] = "externalDynamicContent";
			
			var params = {};
			params['allowFullScreen'] = 'true';
			params['menu'] = 'false';
			
			swfobject.embedSWF("swf/application.swf?v="+flashvars["version"], "content", "100%", "100%", "11", "swf/expressinstall.swf", flashvars, params, attributes);
			
			swffit.fit("externalDynamicContent", 800, 600, 3000, 3000, true, true);
		</script>
	</body>
</html>