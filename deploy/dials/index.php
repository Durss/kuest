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
		$params = array(':uid' => $_POST['uid'], ':zoneX' => $_POST['zoneX'], ':zoneY' => $_POST["zoneY"], ':text' => utf8_decode($_POST["dialogue"]), ':pseudo' => utf8_decode($pseudo), ':avatar' => utf8_decode($avatar));
		$_SESSION['kuest_dial_uid'] = (int) $_POST['uid'];
		$_SESSION['kuest_dial_zoneX'] = (int) $_POST['zoneX'];
		$_SESSION['kuest_dial_zoneY'] = (int) $_POST['zoneY'];
		$_SESSION['kuest_dial_text'] = $_POST['dialogue'];
		$req = DBConnection::getLink()->prepare($sql);
		if (!$req->execute($params)) {
			$error = $req->errorInfo();
			$error = $error[2];
			$flash = '<div class="flash">Woops... ça a chié :(<br /><pre>'.$error.'</pre></div>';
		}else {
			$_SESSION['kuest_dial_text'] = '';
			$_SESSION['kuest_dial_thanks'] = true;
			header("location: .");
			die;
		}
	}
	
	$uid = isset($_SESSION['kuest_dial_uid'])? $_SESSION['kuest_dial_uid'] : '';
	$zoneX = isset($_SESSION['kuest_dial_zoneX'])? $_SESSION['kuest_dial_zoneX'] : '';
	$zoneY = isset($_SESSION['kuest_dial_zoneY'])? $_SESSION['kuest_dial_zoneY'] : '';
	$dialogue = isset($_SESSION['kuest_dial_text'])? $_SESSION['kuest_dial_text'] : '';
	if(isset($_SESSION['kuest_dial_thanks']) && $_SESSION['kuest_dial_thanks'] === true) {
		$flash = '<div class="flash">Votre dialogue a bien été enregistré!<br /><img src="img/thanks.png"/><br /><b>Merci</b></div>';
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
		<link rel="stylesheet" type="text/css" href="css/stylesheet.css?v=4"/>
		<link rel="stylesheet" type="text/css" href="css/opentip.css?v=1"/>
		
		<script type="text/javascript" src="js/opentip.js?v=1"></script>
		<script type="text/javascript" src="js/utils.js?v=1"></script>
		<script type="text/javascript" src="js/form.js?v=4"></script>
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

			if (isset($_SESSION['kuest_uid']) && ($_SESSION['kuest_uid'] == 48 || $_SESSION['kuest_uid'] == 1875)) {
				echo '<center><a href="admin"><button>Admin</button></a></center>';
			}
		?>
	</body>
</html>