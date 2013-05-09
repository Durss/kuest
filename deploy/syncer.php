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
	$description["fr"] = "<strong>Description de la quête :</strong><br />";
	$description["en"] = "<strong>Quest description :</strong><br />";
	
	$load = array();
	$load["fr"] = "Charger cette quête";
	$load["en"] = "Load this quest";
	
	$infoTitle = array();
	$infoTitle["fr"] = "Informations :";
	$infoTitle["en"] = "Informations :";
	
	$infoContent = array();
	$infoContent["fr"] = "Pour charger une quête dans le jeu kube vous devez installer le script GreaseMonkey <a href='http://perdu.com'>Kuest</a>.<br />Une fois installé, il vous suffit de cliquer sur le bouton \"<b>".$load['fr']."</b>\" pour commencer à l'utiliser.";
	$infoContent["en"] = "TODO";
	
	$problemTitle = array();
	$problemTitle["fr"] = "En cas de problème :";
	$problemTitle["en"] = "In case of troubles :";
	
	$problemContent = array();
	$problemContent["fr"] = "Si le bouton ne fonctionne pas vous pouvez copier/coller l'ID suivant :<br /><div class='questID'>".htmlspecialchars($_GET['id'])."</div>";
	$problemContent["en"] = "TODO";
	
	$notFoundTitle = array();
	$notFoundTitle["fr"] = "Quête introuvable";
	$notFoundTitle["en"] = "Quest not found";
	
	$notFoundContent = array();
	$notFoundContent["fr"] = "<img src='img/error.png' alt='error'/> La quête que vous avez demandé n'existe pas.<br /><br />Assurez-vous que le lien qui vous a amené ici est valide.";
	$notFoundContent["en"] = "<img src='img/error.png' alt='error'/> Quest not found";
	
	if(!$notFoundTitle[ $lang ]) $lang = "en";
	
	//Loading kuest details
	$sql = "SELECT * FROM kuests WHERE id=:id";
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
			$description .= "<br /><strong>".$infoTitle[$lang]."</strong><div class='description collapsed'>".$infoContent[ $lang ]."</div>";
			$description .= "<br /><strong>".$problemTitle[$lang]."</strong><div class='description collapsed'>".$problemContent[ $lang ]."</div>";
			$description .= "<br /><center><button class='button'><img src='img/submit.png'/>".$load[$lang]."</button></center>";
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
			var elements = document.getElementsByTagName("strong");
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
						removeClass(target, "collapsed");
					}else{
						addClass(target, "collapsed");
					}
				}
			}
		</script>
	</body>
</html>