<?php
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
	
	if(isset($_SESSION["lang"])) 
		$lang = $_SESSION["lang"];
	else
		$lang = substr($_SERVER['HTTP_ACCEPT_LANGUAGE'], 0, 2);
	
	$description = array();
	$description["fr"] = "<strong class='collapser collapserOpen'>Description de la quête :</strong>";
	$description["en"] = "<strong class='collapser collapserOpen'>Quest description :</strong>";
	
	$load = array();
	$load["fr"] = "Lancer cette quête";
	$load["en"] = "Launch this quest";
	
	$infoTitle = array();
	$infoTitle["fr"] = "Aide :";
	$infoTitle["en"] = "Help :";
	
	$infoContent = array();
	$infoContent["fr"] = "Pour charger une quête dans le jeu kube vous devez installer le script GreaseMonkey <a href='js/kuest.user.js'>Kuest</a>.<br />Pour cela, commencez par télécharger <a href='js/kuest.user.js'>ce fichier</a>. Si vous êtes dans Firefox, glissez/déposez-le sur le navigateur. Si vous utilisez Google Chrome, rendez-vous à l'adresse <b>chrome://extensions</b> et faites de même.<br /><br />Une fois installé, il vous suffit de cliquer sur le bouton \"<b>".$load['fr']."</b>\" ci-dessous pour commencer la quête.<br /><br /><b>Attention</b>, vous devez avoir choisi une zone de départ pour que l'action fonctionne !";
	$infoContent["en"] = "TODO";
	
	$notFoundTitle = array();
	$notFoundTitle["fr"] = "Quête introuvable";
	$notFoundTitle["en"] = "Quest not found";
	
	$notFoundContent = array();
	$notFoundContent["fr"] = "<img src='img/error.png' alt='error'/> La quête que vous avez demandé n'existe pas.<br /><br />Assurez-vous que le lien qui vous a amené ici est valide.";
	$notFoundContent["en"] = "<img src='img/error.png' alt='error'/> Quest not found";
	
	if(!$notFoundTitle[ $lang ]) $lang = "en";
	
	//Loading kuest details
	$sql = "SELECT * FROM kuests WHERE guid=:id";
	$params = array(':id' => $_GET["id"]);
	$req = DBConnection::getLink()->prepare($sql);
	if (!$req->execute($params)) {
		$error = "SQL Error";
	}else{
		$tot = $req->rowCount();
		if ($tot == 0) {
			$title = $notFoundTitle[ $lang ];
			$description = $notFoundContent[ $lang ];
		}else{
			$res = $req->fetch();
			$title = utf8_encode($res["name"]);
			$description = $description[ $lang ]."<div class='description'>".utf8_encode($res["description"])."</div>";
			$description .= "<br /><strong class='collapser'>".$infoTitle[$lang]."</strong><div class='description collapsed'>".$infoContent[ $lang ]."</div>";
			$description .= "<br /><center><button class='button' onClick='window.open(\"http://kube.muxxu.com/?kuest=".htmlspecialchars($_GET['id'])."\");'><img src='img/submit.png'/>".$load[$lang]."</button></center>";
		}
	}
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
			<div class="title"><?php echo $title; ?></div>
			<div class="content"><?php echo $description; ?></div>
			<div class="bottom"></div>
		</div>
		
		<script language="JavaScript">
			function hasClass(el, name) {
			   return new RegExp('(\\s|^)'+name+'(\\s|$)').test(el.className);
			}
			function addClass(el, name) {
			   if (!hasClass(el, name)) { el.className += (el.className ? ' ' : '') +name; }
			}
			function removeClass(el, name) {
			   if (hasClass(el, name)) {
				  el.className=el.className.replace(new RegExp('(\\s|^)'+name+'(\\s|$)'),' ').replace(/^\s+|\s+$/g, '');
			   }
			}
			var elements = document.getElementsByClassName("collapser");
			for(var i = 0; i < elements.length; i++) {
				elements[i].style.cursor = "pointer";
				elements[i].onclick = function() {
					var target = this.nextSibling;
					var secureLoop = 0;
					while(target.nodeName != "DIV" && secureLoop < 100) {
						target = target.nextSibling;
						secureLoop ++;
					}
					if(hasClass(target, "collapsed")) {
						addClass(this, "collapserOpen");
						removeClass(target, "collapsed");
					}else{
						removeClass(this, "collapserOpen");
						addClass(target, "collapsed");
					}
				}
			}
		</script>
	</body>
</html>