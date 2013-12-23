<?php
	header("Cache-Control: no-cache, must-revalidate");
	header("Expires: Mon, 26 Jul 1997 05:00:00 GMT");
	
	require_once("php/db/DBConnection.php");
	require_once("php/out/Out.php");
	require_once("php/log/Logger.php");
	require_once("php/utils/OAuth.php");
	require_once("php/l10n/labels.php");
	
	//Connect to database
	try {
		DBConnection::connect();
	}catch (Exception $error) {
		$error = 'Unable to connect DataBase...';
		die;
	}
	
	if (!isset($_SESSION['uid'])) {
		OAuth::connect();
	}
	
	//Loading kuest details
	$sql = 'SELECT kuests.name as `name`, kuests.description as `description`, kuestUsers.name as `pseudo`, kuestUsers.uid as `uid`
	FROM `kuests`
	INNER JOIN `kuestUsers` ON kuestUsers.uid = kuests.uid
	WHERE kuests.guid=:guid AND published=1';
	$params = array(':guid' => $_GET["id"]);
	$req = DBConnection::getLink()->prepare($sql);
	if (!$req->execute($params)) {
		$error = 'SQL Error';
		$title = '';
		$errorInfo = $req->errorInfo();
		$syncer_description = $error.'<br />'.$errorInfo[2];
	}else{
		$tot = $req->rowCount();
		$res = $req->fetch();
		$dir = './kuests/published/';
		if ($tot == 0) {
			$title = $syncer_notFoundTitle;
			$syncer_description = $syncer_notFoundContent;
		}else {
			$title = utf8_encode(htmlspecialchars($res["name"]));
			$syncer_description = $syncer_description.'<div class="description">'.utf8_encode(htmlspecialchars($res["description"])).'<br /><a href="http://twinoid.com/user/'.$res['uid'].'" target="_blank" class="pseudo author">'.$res['pseudo'].'</a></div>';
			$syncer_description .= '<br /><strong class="collapser">'.$syncer_infoTitle.'</strong><div class="description collapsed">'.$syncer_infoContent.'</div>';
			$syncer_description .= '<div class="instructions-holder">';
			$syncer_description .= '	<div class="syncer-buttons-holder">';
			$syncer_description .= '		<div id="playButton">';
			$syncer_description .= '			<button class="button syncer" onClick="window.location = \'/kuest/redirect?kuest='.htmlspecialchars($_GET['id']).'\';"><img src="/kuest/img/submit.png"/>'.$syncer_load.'</button>';
			$syncer_description .= '		</div>';
			$syncer_description .= '		<div id="installInstructions">';
			$syncer_description .= '			<div class="installInstructions">'.$syncer_installInstructions.'<br /></div>';
			$syncer_description .= '			<a href="https://addons.mozilla.org/firefox/addon/greasemonkey/" target="_blank"><button id="install_gm_ff" class="button syncer"><img src="/kuest/img/icon-greasemonkey-16.png"/>'.$syncer_installGM.'</button></a>';
			$syncer_description .= '			<a href="https://chrome.google.com/webstore/detail/tampermonkey/dhdgffkkebhmkfjojejmpbldmpobfkfo" target="_blank"><button id="install_gm_chrome" class="button syncer"><img src="/kuest/img/icon-tampermonkey.png"/>'.$syncer_installTM.'</button></a>';
			$syncer_description .= '			<a href="/kuest/js/kuest.user.js" target="_blank"><button id="install_script" class="button syncer"><img src="/kuest/img/app_logo_icon.jpg"/>'.$syncer_installScript.'</button></a>';
			$syncer_description .= '		</div>';
			$syncer_description .= '	</div>';
			$syncer_description .= '	<img id="syncer-loader" src="/kuest/img/loader.gif"/>';
			$syncer_description .= '</div>';
		}
	}
	
	//Loading kuest players
	
	$sql = 'SELECT kuestUsers.name as `pseudo`, kuestUsers.uid as `uid`
	FROM `kuestEvaluations`
	INNER JOIN `kuests` ON kuests.id = kuestEvaluations.kid
	INNER JOIN `kuestUsers` ON kuestUsers.uid = kuestEvaluations.uid
	WHERE kuests.guid = :guid';
	$params = array(':guid' => $_GET["id"]);
	$req = DBConnection::getLink()->prepare($sql);
	if (!$req->execute($params)) {
		$error = 'SQL Error';
		$errorInfo = $req->errorInfo();
		$players_content = $error.'<br />'.$errorInfo[2];
	}else{
		$tot = $req->rowCount();
		$players_content = '';
		$res = $req->fetchAll();
		for ($i = 0; $i < $tot; $i++) {
			$players_content .= '<a href="http://twinoid.com/user/'.$res[$i]['uid'].'" target="_blank" class="pseudo">'.$res[$i]['pseudo'].'</a> ';
		}
		if($tot == 0) {
			$players_content = $syncer_playersContent;
		}
	}
?>
<!DOCTYPE html>
<html lang="fr">
	<head>
		<title>Kuest : <?php echo $title; ?></title>
		<link rel="shortcut icon" href="/kuest/favicon.ico" />
		<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
		<meta name="language" content="fr" />
		<meta name="description" content="" />
		<meta name="keywords" content="" />
		
		<link rel="stylesheet" type="text/css" href="/kuest/css/stylesheet.css"/>
		<link rel="stylesheet" type="text/css" href="/kuest/css/browse.css"/>
		<link rel="stylesheet" type="text/css" href="/kuest/css/syncer.css"/>
		<link rel="stylesheet" type="text/css" href="/kuest/css/opentip.css"/>
		
		<script type="text/javascript" src="/kuest/js/plugins/CSSPlugin.min.js"></script>
		<script type="text/javascript" src="/kuest/js/easing/EasePack.min.js"></script>
		<script type="text/javascript" src="/kuest/js/TweenLite.min.js"></script>
		<script type="text/javascript" src="/kuest/js/sendRequest.js"></script>
		<script type="text/javascript" src="/kuest/js/addRemoveEvent.js"></script>
		<script type="text/javascript" src="/kuest/js/isEventSupported.js"></script>
		<script type="text/javascript" src="/kuest/js/mouse.js"></script>
		<script type="text/javascript" src="/kuest/js/utils.js"></script>
		<script type="text/javascript" src="/kuest/js/opentip.js"></script>
		<script type="text/javascript" src="/kuest/js/appear.js"></script>
		<script type="text/javascript" src="/kuest/js/syncer.js"></script>
	</head>
	<body>
		<div class="banner"></div>
		
		<div id="content">
<?php include('menu.php'); ?>
		
			<div class="window">
				<div class="title"><?php echo $title; ?></div>
				<div class="content">
					<div class="inner">
						<?php echo $syncer_description; ?>
					</div>
				</div>
				<div class="bottom"></div>
			</div>
		
			<div class="window">
				<div class="title"><?php echo $syncer_players; ?></div>
				<div class="content">
					<div class="inner">
						<?php echo $players_content; ?>
					</div>
				</div>
				<div class="bottom"></div>
			</div>
		</div>
	</body>
</html>