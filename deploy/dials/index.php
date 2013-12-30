<?php
	if ($_SERVER['HTTP_HOST'] == "fevermap.org") {
		require_once("../kuest/php/db/DBConnection.php");
		require_once("../kuest/php/out/Out.php");
		require_once("../kuest/php/log/Logger.php");
	}else{
		require_once("../php/db/DBConnection.php");
		require_once("../php/out/Out.php");
		require_once("../php/log/Logger.php");
	}
	
	header("Cache-Control: no-cache, must-revalidate");
	header("Expires: Mon, 26 Jul 1997 05:00:00 GMT");
	header("Access-Control-Allow-Origin: http://kube.muxxu.com");
	header('content-type: text/html; charset=UTF-8'); 
	
	//Redirect the user if "www" are on the address. Prevents from SharedObject problems.
	if (strpos($_SERVER["SERVER_NAME"], "www") > -1) {
		header("location: http://fevermap.org/dials");
		die;
	}
	
	//Connect to database
	try {
		DBConnection::connect();
	}catch (Exception $loadingError) {
		echo 'Unable to contact database... :(';
		die;
	}
	
	
	$flash = '';
	if (isset($_POST['zoneX'], $_POST['zoneY'], $_POST['dialogue'], $_POST['uid'])) {
		$url = 'http://twinoid.com/user/' .(int)$_POST['uid'];
		$fh = fopen($url, "rb") or die("cannot open remote file");
		$contents = stream_get_contents($fh);
		fclose($fh);

		$matches = array();
		preg_match('/.*<span onEdit="window.location=.*?">(.*?)<\/span>.*/i', $contents, $matches);
		$pseudo = $matches[1];
		
		$matches = array();
		preg_match('/.*<img class="tid_avatarImg" src="(.*?)".*/i', $contents, $matches);
		$avatar = $matches[1];
		
		//Insert into DB
		$sql = "INSERT into kuestDialogues (uid, zoneX, zoneY, text, pseudo, avatar, date) VALUES (:uid, :zoneX, :zoneY, :text, :pseudo, :avatar, NOW())";
		//var_dump($_POST["dialogue"]); die;
		/*if (isset($_POST['gm'])) {
			$dialogue = mb_convert_encoding (urldecode($_POST['dialogue']), 'ISO-8859-1', 'UTF-8');
			//$dialogue = utf8_decode(urldecode($_POST["dialogue"]))
			$params = array(':uid' => $_POST['uid'], ':zoneX' => $_POST['zoneX'], ':zoneY' => $_POST["zoneY"], ':text' => $dialogue, ':pseudo' => $pseudo, ':avatar' => $avatar);
		}else {*/
			$params = array(':uid' => $_POST['uid'], ':zoneX' => $_POST['zoneX'], ':zoneY' => $_POST["zoneY"], ':text' => utf8_decode($_POST["dialogue"]), ':pseudo' => utf8_decode($pseudo), ':avatar' => utf8_decode($avatar));
		//}
		$_SESSION['kuest_dial_uid'] = (int) $_POST['uid'];
		$_SESSION['kuest_dial_zoneX'] = (int) $_POST['zoneX'];
		$_SESSION['kuest_dial_zoneY'] = (int) $_POST['zoneY'];
		$_SESSION['kuest_dial_text'] = $_POST['dialogue'];
		$req = DBConnection::getLink()->prepare($sql);
		if (!$req->execute($params)) {
			$error = $req->errorInfo();
			$error = $error[2];
			$flash = '<div class="flash">Woops... ça a chié :(<br /><pre>'.$error.'</pre></div>';
			if (isset($_POST['gm'])) {
				Out::printOut(false, '', 'SQL ERROR', $error);
				die;
			}
		}else {
			$_SESSION['kuest_dial_text'] = '';
			$_SESSION['kuest_dial_thanks'] = true;
			if (isset($_POST['gm'])) {
				Out::printOut(true);
				die;
			}else{
				header("location: .");
				die;
			}
		}
	}
	
	$uid = isset($_SESSION['kuest_dial_uid'])? $_SESSION['kuest_dial_uid'] : '';
	$zoneX = isset($_SESSION['kuest_dial_zoneX'])? $_SESSION['kuest_dial_zoneX'] : '';
	$zoneY = isset($_SESSION['kuest_dial_zoneY'])? $_SESSION['kuest_dial_zoneY'] : '';
	$dialogue = isset($_SESSION['kuest_dial_text'])? $_SESSION['kuest_dial_text'] : '';
	if(isset($_SESSION['kuest_dial_thanks']) && $_SESSION['kuest_dial_thanks'] === true) {
		$thanks = array();
		$thanks[] = "Tu es une personne merveilleuse !";
		$thanks[] = "Merci d'être l'incarnation de la perfection <3";
		$thanks[] = "Comment t'es trop choux *o*";
		$thanks[] = "Vous êtes tout à fait formidable !";
		$thanks[] = "Tu as toujours été mon/ma préféré/e <3";
		$thanks[] = "De toi à moi, j'ai toujours su que tu étais au top !";
		$thanks[] = "Sans toi, le monde serait vachement moins beau...";
		$thanks[] = "Tu es adorable.";
		$thanks[] = "Merci d'être toi <3";
		$thanks[] = "Tu es si merveilleux/se...";
		$thanks[] = "Que ferais-je sans toi... <3";
		$thanks[] = "Si tes parents ne t'avaient pas fait, je m'en serais chargé ! <3";
		$thanks[] = "Des millions de poutoux pour te remercier ! COEUR !";
		$thanks[] = "<3 <3 <3 <3 <3 <3";
		$thanks[] = "Avalanche d'amour sur toi <3 !";
		$thanks[] = "Tu es formidable ! Reste comme t'es !";
		$thanks[] = "Tu es une très belle personne !";
		$thanks[] = "En toute honnêteté, tu es super !";
		$thanks[] = "Reste comme t'es, change rien ;)";
		
		$xxx = $thanks[ round(rand(0, count($thanks) - 1)) ];
		$flash = '<div class="flash">Votre dialogue a bien été enregistré!<br /><img src="img/thanks.png"/><br /><b>Merci</b><br />'.$xxx.'</div>';
		
		$_SESSION['kuest_dial_thanks'] = false;
	}
	
	
	$sql = "SELECT `uid`, `avatar`, `pseudo`, COUNT(*) as `total`, MIN(date) as `date` FROM kuestDialogues GROUP BY uid ORDER BY `total` DESC, date DESC";
	$params = array();
	$req = DBConnection::getLink()->prepare($sql);
	if (!$req->execute($params)) {
		$users = array();
		$tot = '?';
	}else{
		$tot = 0;
		$users = $req->fetchAll();
		for ($i = 0; $i < count($users); $i++) {
			$tot += $users[$i]['total'];
		}
	}
	
?>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html>
	<head>
		<title>Dials project</title>
		<link rel="shortcut icon" href="img/favicon.ico" />
		<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
		<meta name="language" content="en" />
		<meta name="description" content="Register dialogues on kube's zones." />
		<meta name="keywords" content="kube, dials, durss" />
		
		<script type="text/javascript" src="/kuest/js/plugins/CSSPlugin.min.js?v=1"></script>
		<script type="text/javascript" src="/kuest/js/easing/EasePack.min.js?v=1"></script>
		<script type="text/javascript" src="/kuest/js/TweenLite.min.js?v=1"></script>
		<link rel="stylesheet" type="text/css" href="css/stylesheet.css?v=5"/>
		<link rel="stylesheet" type="text/css" href="css/opentip.css?v=1"/>
		
		<script type="text/javascript" src="js/opentip.js?v=1"></script>
		<script type="text/javascript" src="js/utils.js?v=2"></script>
		<script type="text/javascript" src="js/form.js?v=5"></script>
	</head>
	<body>
		<div class="banner"></div>
		<?php echo $flash; ?>
		<div class="window">
			<div class="title">Ajouter un dialogue</div>
			<div class="content">
				<div class="inner">
					<form method="POST" action="?">
						<div class="user">
						<img src="img/thanks.png" class="avatar" /><br />
						<span class="nickname"></span>
						</div>
						<label>Zone : &nbsp;&nbsp;&nbsp;<input type="number" min="-100" max="100" id="zoneX" name="zoneX" placeholder="X" class="inputZone" value="<?php echo $zoneX; ?>" /></label><input type="number" min="-100" max="100" id="zoneY" name="zoneY" placeholder="Y" class="inputZone" value="<?php echo $zoneY; ?>" /><br />
						<label>User ID : <input type="text" id="uid" name="uid" placeholder="ID" value="<?php echo $uid; ?>" /></label> <img src="img/help.png" id="help" data-ot="Vous trouverez votre ID dans la barre d'adresse lorsque vous vous trouverez sur votre profil Twinoid.<br /><br /><b>Exemple :</b><br /><img src='img/uidExample.png' width='316' height='139' />" data-ot-tip-joint="top" data-ot-target="#help" data-ot-delay="0"/><br />
						<label>
							Dialogue <i>(20 caractères minimum)</i> :
							<textarea id="dialogue" name="dialogue" cols="34" rows="10" placeholder="Dialogue..."><?php echo $dialogue; ?></textarea>
						</label>
						<br />
						<center><button id="submitButton">Soumettre</button></center>
						<div class="count"><?php echo $tot; ?> dialogues</div>
					</form>
					<br /><a href="js/kubeDials.user.js" id="gmLink" data-ot="En installant ce script vous pourrez ajouter un dialogue lié à la zone sur laquelle vous vous trouvez en jeu sans avoir à saisir les coordonnées de la zone ni votre UID.<br />Un formulaire sera affiché sous le jeu à cet effet comme ceci :<br /><img src='img/gmSample.png' width='316' height='200' />" data-ot-tip-joint="bottom" data-ot-target="#gmLink" data-ot-delay="0">Installer le script Greasemonkey</a><br /><i>
					<span style="display:none" id="GM"><a href="https://addons.mozilla.org/firefox/addon/greasemonkey/" target="_blank"><img src="img/icon-greasemonkey-16.png"/> Installer GreaseMonkey</a> au préalable !</span>
					<span style="display:none" id="TM"><a href="https://chrome.google.com/webstore/detail/tampermonkey/dhdgffkkebhmkfjojejmpbldmpobfkfo" target="_blank"><img src="img/icon-tampermonkey.png"/> Installer TamperMonkey</a> au préalable !</span></i>
				</div>
			</div>
			<div class="bottom"></div>
		</div>
		
		<?php
			if($tot > 0) {
		?>
		
		<div class="window">
			<div class="title">Top contributeurs</div>
			<div class="content">
				<div style="width:360px;"><!-- yep, that's shit. Thank you HTMLFIVEOHMYGOD for not considerating the "before" CSS property when placing things... -->
			<?php

				for ($i = 0; $i < count($users); $i++) {
			?>
					<a href="http://twinoid.com/user/<?php echo $users[$i]['uid']; ?>" target="_blank" class='pseudo'><?php echo utf8_encode($users[$i]['pseudo']); ?></a>
			<?php
				}
			?>
				</div>
			</div>
			<div class="bottom"></div>
		</div>
		
		<?php
			}

			$admins = array();
			$admins[] = 48;
			$admins[] = 1875;
			$admins[] = 338;
			$admins[] = 32215;
			$admins[] = 45643;
			$admins[] = 41997;
			$admins[] = 7610252;
			if (isset($_SESSION['kuest_uid']) && in_array($_SESSION['kuest_uid'], $admins)) {
				echo '<center><a href="admin"><button>Admin</button></a></center>';
			}
		?>
	</body>
</html>