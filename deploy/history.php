<?php
	require_once("php/db/DBConnection.php");
	require_once("php/out/Out.php");
	require_once("php/log/Logger.php");
	require_once("php/utils/OAuth.php");
	require_once("php/l10n/labels.php");
	
	header("Cache-Control: no-cache, must-revalidate");
	header("Expires: Mon, 26 Jul 1997 05:00:00 GMT");
	
	//Redirect the user if "www" are on the address. Prevents from SharedObject problems.
	if (strpos($_SERVER["SERVER_NAME"], "www") > -1) {
		header("location: http://fevermap.org/kuest");
		die;
	}
	
	//Connect to database
	try {
		DBConnection::connect();
	}catch (Exception $loadingError) {
		header("location: /kuest/error?e=dbconnect");
		die;
	}
	
	//session_destroy(); die;
	OAuth::connect();
	
?>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html>
	<head>
		<title>Kuests</title>
		<link rel="shortcut icon" href="/kuest/favicon.ico" />
		<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
		<meta name="language" content="en" />
		<meta name="description" content="Tool to create quests for the game Kube." />
		<meta name="keywords" content="kube, kuest, quest, durss" />
		
		<link rel="stylesheet" type="text/css" href="/kuest/css/stylesheet.css"/>
		<link rel="stylesheet" type="text/css" href="/kuest/css/browse.css"/>
		<link rel="stylesheet" type="text/css" href="/kuest/css/opentip.css"/>
		
		<script type="text/javascript" src="/kuest/js/plugins/CSSPlugin.min.js"></script>
		<script type="text/javascript" src="/kuest/js/easing/EasePack.min.js"></script>
		<script type="text/javascript" src="/kuest/js/TweenLite.min.js"></script>
		<script type="text/javascript" src="/kuest/js/sendRequest.js"></script>
		<script type="text/javascript" src="/kuest/js/addRemoveEvent.js"></script>
		<script type="text/javascript" src="/kuest/js/isEventSupported.js"></script>
		<script type="text/javascript" src="/kuest/js/mouse.js"></script>
		<script type="text/javascript" src="/kuest/js/utils.js"></script>
		<script type="text/javascript" src="/kuest/js/history.js"></script>
		<script type="text/javascript" src="/kuest/js/opentip.js"></script>
		<script type="text/javascript" src="/kuest/js/appear.js"></script>
	</head>
	<body>
		<!-- Template used for items creation. Modify it to update all the items rendering -->
		<div class="template item">
			{COMPLETE_ICON}{TITLE} <i>(<a href="http://twinoid.com/user/{UID}" onclick="openUserSheet()" target="_blank">{PSEUDO}</a>)</i>
		</div>
		
		<div class="banner"></div>
		
		<div id="content">
<?php include('menu.php'); ?>

			<div class="browse">
				<div class="window">
					<div class="title"><?php echo $history_titleRight; ?></div>
					<div class="content">
						<div class="inner">
							<div class="loader"><?php echo $loading; ?></div>
							<div class="serverError"><?php echo $loadingError; ?></div>
							<div class="noResult"><?php echo $history_noResults; ?></div>
							<div class="kuestsList"></div>
						</div>
					</div>
					<div class="bottom"></div>
				</div>
			</div>
		</div>
	</body>
</html>