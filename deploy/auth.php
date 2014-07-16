<?php
	session_start();
	require_once("php/l10n/labels.php");
	
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
		
		<script type="text/javascript" src="/kuest/js/plugins/CSSPlugin.min.js"></script>
		<script type="text/javascript" src="/kuest/js/easing/EasePack.min.js"></script>
		<script type="text/javascript" src="/kuest/js/TweenLite.min.js"></script>
		<script type="text/javascript" src="/kuest/js/utils.js"></script>
		<script type="text/javascript" src="/kuest/js/appear.js"></script>
	</head>
	<body>
		<div class="banner"></div>
		<div id="content">
			<div class="menu">
				<button class="big" onclick="window.location='/kuest?connect'"><img src="/kuest/img/twinoid_logo.png"/> <?php echo $menu_connect; ?></button>
			</div>
			<div class="window">
				<div class="title"><?php echo $auth_title; ?></div>
				<div class="content" style="min-height:140px;">
					<div class="inner">
						<img src="img/faces/<?php echo rand(1, 12); ?>.jpg" alt="Kuest" class="authImage" /><?php echo $auth_content; ?></div>
						<br/>
						<div class="buttonCenterWrapper">
							<button onclick="window.location='/kuest?connect'" style="line-height:30px"><img src="/kuest/img/twinoid_logo.png"/><?php echo $menu_connect; ?></button>
						</div>
					</div>
				<div class="bottom"></div>
			</div>
		</div>
	</body>
</html>