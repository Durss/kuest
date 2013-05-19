<?php
	header("Cache-Control: no-cache, must-revalidate");
	header("Expires: Mon, 26 Jul 1997 05:00:00 GMT");
	
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
	
	if (!isset($_SESSION['uid'])) {
		header("location: http://muxxu.com/a/kuest/?act=k_kid=".$_GET["id"]);
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
	$infoContent["fr"] = "Voici les étapes à suivre pour pouvoir charger une quête dans le jeu.<br /><ul><li>Si vous utilisez Firefox, <a href='https://addons.mozilla.org/firefox/addon/greasemonkey/' target='_blank'>installez GreaseMonkey</a> et cliquez sur <a href='/kuest/js/kuest.user.js' target='_blank'>ce lien</a>.</li><li>Si vous utilisez Google Chrome, faites de même mais en installant d'abord <a href='https://chrome.google.com/webstore/detail/tampermonkey/dhdgffkkebhmkfjojejmpbldmpobfkfo' target='_blank'>TamperMonkey</a>.<br />Ou bien rendez-vous à l'adresse <b>chrome://extensions</b> et glissez déposez le fichier <a href='/kuest/js/kuest.user.js' target='_blank'>Kuest.user.js</a> dans la page.</li><li>Le script n'a pas été testé sous Opéra</li><li>Sous Internet Explorer il n'est pas possible d'installer ce script.</li></ul>Une fois le script installé, il vous suffit de cliquer sur le bouton \"<b>".$load['fr']."</b>\" ci-dessous pour commencer la quête.";
	$infoContent["en"] = "TODO";
	
	$notFoundTitle = array();
	$notFoundTitle["fr"] = "Quête introuvable";
	$notFoundTitle["en"] = "Quest not found";
	
	$notFoundContent = array();
	$notFoundContent["fr"] = "<img src='/kuest/img/error.png' alt='error'/> La quête que vous avez demandé n'existe pas.<br /><br />Assurez-vous que le lien qui vous a amené ici est valide.";
	$notFoundContent["en"] = "<img src='/kuest/img/error.png' alt='error'/> Quest not found";
	
	if(!$notFoundTitle[ $lang ]) $lang = "en";
	
	//Loading kuest details
	$sql = "SELECT * FROM kuests WHERE guid=:guid AND published=1";
	$params = array(':guid' => $_GET["id"]);
	$req = DBConnection::getLink()->prepare($sql);
	if (!$req->execute($params)) {
		$error = "SQL Error";
	}else{
		$tot = $req->rowCount();
		$res = $req->fetch();
		$dir = "./kuests/published/";
		if ($tot == 0) {
			$title = $notFoundTitle[ $lang ];
			$description = $notFoundContent[ $lang ];
		}else{
			$title = utf8_encode($res["name"]);
			$description = $description[ $lang ]."<div class='description'>".utf8_encode($res["description"])."</div>";
			$description .= "<br /><strong class='collapser'>".$infoTitle[$lang]."</strong><div class='description collapsed'>".$infoContent[ $lang ]."</div>";
			$description .= "<br /><center><button class='button' onClick='window.location = \"/kuest/redirect?kuest=".htmlspecialchars($_GET['id'])."\";'><img src='/kuest/img/submit.png'/>".$load[$lang]."</button></center>";
		}
	}
?>
<!DOCTYPE html>
<html lang="fr">
	<head>
		<title>Kuest : <?php echo $title; ?></title>
		<link rel="shortcut icon" href="favicon.ico" />
		<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
		<meta name="language" content="fr" />
		<meta name="description" content="" />
		<meta name="keywords" content="" />
		
		<link rel="stylesheet" type="text/css" href="/kuest/css/stylesheet.css"/>
	</head>
	<body>
		<div class="window">
			<div class="title"><?php echo $title; ?></div>
			<div class="content">
				<div class="inner">
					<?php echo $description; ?>
				</div>
			</div>
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