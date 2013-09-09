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
		<script type="text/javascript" src="js/ZeroClipboard.js"></script>
	</head>
	<body>
		<div class="banner"></div>
		<?php
		if ($_GET['e'] == 'cancel') {
		?>
		<div class="menu">
			<button class="big" onclick="window.location='/kuest'"><img src="/kuest/img/twinoid_logo.png"/> <?php echo $menu_connect; ?></button>
		</div>
		<?php
		}
		?>
		<div class="window">
			<div class="title"><?php echo $error_title; ?></div>
			<div class="content" style="min-height:140px;">
				<div class="inner">
					<img src="img/down.png" alt="Error" height="137" style="float:right" /><?php echo $error_content; ?></div>
				</div>
			<div class="bottom"></div>
		</div>
	</body>
</html>