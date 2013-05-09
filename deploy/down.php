<?php
	session_start();
	if(isset($_SESSION["lang"])) 
		$lang = $_SESSION["lang"];
	else
		$lang = substr($_SERVER['HTTP_ACCEPT_LANGUAGE'], 0, 2);
	
	$title = array();
	$title["fr"] = "Erreur serveur";
	$title["en"] = "Server error";
	
	$content = array();
	$content["fr"] = "Muxxu est actuellement indisponible rendant cette application hors service.<br /><br />Essayez à nouveau un peu plus tard.<br /><br /><i>Désolé pour la gêne occasionnée.</i>";
	$content["en"] = "Muxxu is unavailable for the moment, which makes this application unusable.<br /><br />Please try again later.<br /><br /><i>Sorry for the inconvenience.</i>";
	if(!$content[ $lang ])
		$lang = "en";
?>
<!DOCTYPE html>
<html lang="fr">
	<head>
		<title>Kuest, server error</title>
		<link rel="shortcut icon" href="favicon.ico" />
		<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
		<meta name="language" content="fr" />
		<meta name="description" content="" />
		<meta name="keywords" content="" />
		
		<link rel="stylesheet" type="text/css" href="css/stylesheet.css"/>
		<script type="text/javascript" src="js/ZeroClipboard.js"></script>
	</head>
	<body>
		<div class="window">
			<div class="title"><?php echo $title[$lang]; ?></div>
			<div class="content" style="min-height:140px;"><img src="img/down.png" alt="Error" height="137" /><?php echo $content[$lang]; ?></div>
			<div class="bottom"></div>
		</div>
	</body>
</html>