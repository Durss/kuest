<?php
	header("Cache-Control: no-cache, must-revalidate");
	header("Expires: Mon, 26 Jul 1997 05:00:00 GMT");
	
	require_once("php/db/DBConnection.php");
	require_once("php/out/Out.php");
	require_once("php/log/Logger.php");
	require_once("php/l10n/labels.php");
	
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
			$title = $syncer_notFoundTitle;
			$syncer_description = $syncer_notFoundContent;
		}else{
			$title = utf8_encode($res["name"]);
			$syncer_description = $syncer_description."<div class='description'>".utf8_encode($res["description"])."</div>";
			$syncer_description .= "<br /><strong class='collapser'>".$syncer_infoTitle."</strong><div class='description collapsed'>".$syncer_infoContent."</div>";
			$syncer_description .= "<br /><center><button class='button' onClick='window.location = \"/kuest/redirect?kuest=".htmlspecialchars($_GET['id'])."\";'><img src='/kuest/img/submit.png'/>".$syncer_load."</button></center>";
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
		<link rel="stylesheet" type="text/css" href="/kuest/css/tooltip.css"/>
		
		<script type="text/javascript" src="/kuest/js/sendRequest.js"></script>
		<script type="text/javascript" src="/kuest/js/addRemoveEvent.js"></script>
		<script type="text/javascript" src="/kuest/js/isEventSupported.js"></script>
		<script type="text/javascript" src="/kuest/js/mouse.js"></script>
		<script type="text/javascript" src="/kuest/js/utils.js"></script>
		<script type="text/javascript" src="/kuest/js/tooltip.js"></script>
	</head>
	<body>
		<div class="banner"></div>
		
		<div class="menu">
			<button class="big twinoid" onclick="window.location='http://twinoid.com'" onmouseover="tooltip.pop(this, 'Twinoid.', {position:1, calloutPosition:.5})"><img src="/kuest/img/twinoid_logo.png"/></button>
			<button class="big" onclick="window.location=(window.location.host=='localhost'? 'index.php' : '/kuest/browse' )" onmouseover="tooltip.pop(this, '<?php echo $menu_kuestsTT; ?>', {position:2, calloutPosition:.5})"/><img src="/kuest/img/list.png"> <?php echo $menu_kuests; ?></button>
			<button class="big" onclick="window.location='editor'" onmouseover="tooltip.pop(this, '<?php echo $menu_createButtonTT; ?>', {position:2, calloutPosition:.5})"/><img src="/kuest/img/feather.png"> <?php echo $menu_createButton; ?></button>
		</div>
		
		<div class="window">
			<div class="title"><?php echo $title; ?></div>
			<div class="content">
				<div class="inner">
					<?php echo $syncer_description; ?>
				</div>
			</div>
			<div class="bottom"></div>
		</div>
		
		<script language="JavaScript">
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