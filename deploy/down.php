<?php
	session_start();
	require_once("php/l10n/labels.php");
?>
<!DOCTYPE html>
<html lang="fr">
	<head>
		<title>Kuest, server error</title>
		<link rel="shortcut icon" href="/kuest/favicon.ico" />
		<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
		<meta name="language" content="fr" />
		<meta name="description" content="" />
		<meta name="keywords" content="" />
		
		<link rel="stylesheet" type="text/css" href="/kuest/css/stylesheet.css"/>
		
		<script type="text/javascript" src="/kuest/js/plugins/CSSPlugin.min.js"></script>
		<script type="text/javascript" src="/kuest/js/easing/EasePack.min.js"></script>
		<script type="text/javascript" src="/kuest/js/TweenLite.min.js"></script>
		<script type="text/javascript" src="/kuest/js/utils.js"></script>
		<script type="text/javascript" src="/kuest/js/appear.js"></script>
	</head>
	<body>
		<div class="banner"></div>
		<div class="window">
			<div id="content">
				<div class="title"><?php echo $down_title; ?></div>
				<div class="content" style="min-height:140px;">
					<div class="inner">
						<img src="img/down.png" alt="Error" height="137" /><?php echo $down_content; ?></div>
					</div>
				<div class="bottom"></div>
			</div>
		</div>
	</body>
</html>