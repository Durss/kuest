<?php
	session_start();
	header("Cache-Control: no-cache, must-revalidate");
	header("Expires: Mon, 26 Jul 1997 05:00:00 GMT");
	
	//Redirect the user if "www" are on the address. Prevents from SharedObject problems.
	if (strpos($_SERVER["SERVER_NAME"], "www") > -1) {
		header("location: http://fevermap.org/kuest");
		die;
	}
	
	//Converts act var into multiple GET vars if necessary.
	//If the following act var is past :
	//act=value_var1=value1_var2=value2
	//then $_GET["act"] value will only be "value" and two
	//GET vars named "var1" and "var2" will be created with
	//the corresponding value.
	$rawAct = "";
	if (isset($_GET["act"])) {
		$rawAct = $_GET["act"];
		$params = explode("_", $_GET["act"]);
		$_GET["act"] = $params[0];
		for ($i = 1; $i < count($params); $i++) {
			if(strpos($params[$i], "=") > -1) {
				list($var, $value) = explode("=", $params[$i]);
			}else {
				$var = $params[$i];
				$value = 0;
			}
			$_GET[$var] = $value;
		}
	}
	
	if (isset($_GET["act"]) && $_GET["act"] == "ids") {
		header("location:ids.php?uid=".$_GET['uid']."&pubkey=".$_GET['pubkey']);
		die;
	}
	
	if (isset($_GET["act"]) && $_GET["act"] == "k") {
		header("location:syncer.php?id=".$_GET['kid']);
		die;
	}
	
	if (isset($_GET["act"]) && $_GET["act"] != "editor") {
		header("location:browse.php?uid=".$_GET['uid']."&pubkey=".$_GET['pubkey']);
		die;
	}
	
	$lang = "";
	if(isset($_GET['uid'], $_GET['pubkey'])) {
		$key = ($_SERVER['HTTP_HOST'] == "localhost")? "f98dad718d97ee01a886fbd7f2dffcaa" : "34e2f927f72b024cd9d1cf0099b097ab";
		$app = ($_SERVER['HTTP_HOST'] == "localhost")? "kuest-dev" : "kuest";
		$url = "http://muxxu.com/app/xml?app=".$app."&xml=user&id=".$_GET['uid']."&key=".md5($key . $_GET["pubkey"]);
		$xml = @simplexml_load_file($url);
		$xml = @simplexml_load_file($url);
		if ($xml !== false) {
			if ($xml->getName() != "error") {
				$pseudo	= (string) $xml->attributes()->name;
				$lang = (string)$xml->attributes()->lang;
				$_SESSION['lang'] = $lang;
				$_SESSION['uid'] = $_GET['uid'];
				$_SESSION['name'] = $pseudo;
				$_SESSION["pubkey"]	= $_GET["pubkey"];
			}
		}else {
			header("location: /kuest/down");
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
			if(lang.length == 0) {//Get browser's language if we couldn't get the user's language from muxxu XML API because user isn't logged-in.
				lang = (navigator.language) ? navigator.language : navigator.userLanguage;
				lang = lang.split("-")[0];
			}
			//Compute this languages list via PHP depending on the folder's content.
			if(lang != "fr" && lang != "en") lang = "en";
			
			var flashvars = {};
			flashvars["version"] = "42";
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