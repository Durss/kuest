<?php
	//Redirect the user if "www" are on the address. Prevents from SharedObject problems.
	if (strpos($_SERVER["SERVER_NAME"], "www") > -1) {
		header("location: http://fevermap.org/kuest/browse");
		die;
	}
	
	require_once("php/db/DBConnection.php");
	require_once("php/out/Out.php");
	require_once("php/log/Logger.php");
	
	//Connect to database
	try {
		DBConnection::connect();
	}catch (Exception $error) {
		$error = "Unable to connect DataBase...";
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
	
	$lang = "";
	if (isset($_GET['uid'], $_GET['pubkey']) && strlen($_GET['uid']) > 0 && strlen($_GET['pubkey']) > 0) {
		$key = ($_SERVER['HTTP_HOST'] == "localhost")? "f98dad718d97ee01a886fbd7f2dffcaa" : "34e2f927f72b024cd9d1cf0099b097ab";
		$app = ($_SERVER['HTTP_HOST'] == "localhost")? "kuest-dev" : "kuest";
		$url = "http://muxxu.com/app/xml?app=".$app."&xml=user&id=".$_GET['uid']."&key=".md5($key . $_GET["pubkey"]);
		$xml = @simplexml_load_file($url);
		
		if ($xml !== false) {
			if ($xml->getName() != "error") {
				$pseudo	= (string) $xml->attributes()->name;
				$lang = (string)$xml->attributes()->lang;
				$_SESSION['lang']	= $lang;
				$_SESSION['uid']	= $_GET['uid'];
				$_SESSION['name']	= $pseudo;
				$_SESSION["pubkey"]	= $_GET["pubkey"];
			}
		}else {
			header("location: /kuest/down");
		}
	}else {
		if (isset($_SESSION['lang'])) $lang = $_SESSION['lang'];
	}
	
	if (!isset($_SESSION['uid'])) {
		header("location: http://muxxu.com/a/kuest/?act=browse");
	}
	
	$titleLeft = array();
	$titleLeft["fr"] = "Meilleures quêtes";
	$titleLeft["en"] = "Best quests";
	
	$titleRight = array();
	$titleRight["fr"] = "Toutes les quêtes";
	$titleRight["en"] = "All the quests";
	
	$loading = array();
	$loading["fr"] = "Chargement...";
	$loading["en"] = "Loading...";
	
	$noResults = array();
	$noResults["fr"] = "Aucun résultat.";
	$noResults["en"] = "No result.";
	
	$error = array();
	$error["fr"] = "Oops... une erreur est survenue durant le chargement des quêtes.<br /><button class='button' onClick='loadQuests()'><img src='/kuest/img/submit.png'/>Ré-essayer</button>";
	$error["en"] = "Woops... an error has occurred while loading quests list.<br /><button class='button' onClick='loadQuests()'><img src='/kuest/img/submit.png'/>Try again</button>";
	
	//Check if the application is localized in this lang or not. If not, use english.
	if ($lang != "" && !$titleLeft[$lang]) $lang = "en";
	
?>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html>
	<head>
		<title>Kuests</title>
		<link rel="shortcut icon" href="favicon.ico" />
		<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
		<meta name="language" content="en" />
		<meta name="description" content="Tool to create quests for the game Kube." />
		<meta name="keywords" content="kube, quest, durss" />
		
		<link rel="stylesheet" type="text/css" href="css/stylesheet.css"/>
		<link rel="stylesheet" type="text/css" href="css/browse.css"/>
		
		<script type="text/javascript" src="js/sendRequest.js"></script>
		<script type="text/javascript" src="js/browse.js"></script>
	</head>
	<body>
		<div class="template item">
			{TITLE} <i>(par <a href="http://muxxu.com/user/{UID}" onclick="openUserSheet()" target="_blank">{PSEUDO}</a>)</i>
		</div>
		<div style="display:table; margin:auto;">
			<div class="window" style="display:table-cell;">
				<div class="title"><?php echo $titleLeft[ $lang ]; ?></div>
				<div class="content">
					<div class="inner">
						<div class="loader"><?php echo $loading[$lang]; ?></div>
						<div class="serverError"><?php echo $error[$lang]; ?></div>
						<div class="noResult"><?php echo $noResults[$lang]; ?></div>
						<div class="results"></div>
					</div>
				</div>
				<div class="bottom"></div>
			</div>
			<div class="window" style="display:table-cell;">
				<div class="title"><?php echo $titleRight[ $lang ]; ?></div>
				<div class="content">
					<div class="inner">
						<div class="loader"><?php echo $loading[$lang]; ?></div>
						<div class="serverError"><?php echo $error[$lang]; ?></div>
						<div class="noResult"><?php echo $noResults[$lang]; ?></div>
						<div class="results"></div>
					</div>
				</div>
				<div class="bottom"></div>
			</div>
		</div>
	</body>
</html>