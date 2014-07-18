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
		exit();
	}
	
	//Connect to database
	try {
		DBConnection::connect();
	}catch (Exception $loadingError) {
		header("location: /kuest/error?e=dbconnect");
		exit();
	}
	
	//session_destroy(); die;
	if ((!isset($_SESSION['kuest_logged']) || $_SESSION['kuest_logged'] === false) && !isset($_GET['bpAuth'])) {
		if (!isset($_COOKIE['kuestAppAuthorized_'.CLIENT_ID]) || $_COOKIE['kuestAppAuthorized_'.CLIENT_ID] !== 'true') {
			if (isset($_GET['connect']) || isset($_GET['state']) || (isset($_GET['error']) && $_GET['error'] == 'access_denied')) {
				OAuth::connect();
			}else{
				header("location: /kuest/auth");
				exit();
			}
		}else {
			OAuth::connect();
		}
	}else{
		OAuth::connect();
	}

//Parameter "bpAuth" is here to ByPass the auth view ( http://fevermap.org/kuest/auth )
//It's used by the user script. An hidden iFrame is created by the user script to log the
//user in the background without asking him to manually connect from the application which
//would be a nightmare.
//Moreover, if this var is set we just return a simple XML stating the request succeed.
//We don't want to have an "heavy" HTML page that takes ressources for nothing in the background.
if(isset($_GET['bpAuth'])) {
    Out::printOut(true);
    die;
}
	
?>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html>
	<head>
		<title>Kuest</title>
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
		<script type="text/javascript" src="/kuest/js/search.js"></script>
		<script type="text/javascript" src="/kuest/js/browse.js"></script>
		<script type="text/javascript" src="/kuest/js/opentip.js"></script>
		<script type="text/javascript" src="/kuest/js/appear.js"></script>
	</head>
	<body>
		<!-- Template used for items creation. Modify it to update all the items rendering -->
		<div class="template item">
			{TITLE} <i>(<a href="http://twinoid.com/user/{UID}" onclick="openUserSheet()" target="_blank">{PSEUDO}</a>) (<span id="test">►x{PLAYS}</span>)</i>
		</div>
		
		<div class="banner"></div>
		<div id="content">
<?php include('menu.php'); ?>
		
			<div class="search">
				<div class="window">
					<div class="title"><?php echo $browse_search; ?></div>
					<div class="content close">
						<div class="inner">
							<input type="text" id="searchInput" name="search" placeholder="<?php echo $browse_searchPlaceholder; ?>" /><br />
							<button id="submitButton"><?php echo $browse_searchSubmit; ?></button>
						</div>
					</div>
					<div class="bottom"></div>
				</div>
			</div>
			
			<div class="resultsHidden">
				<div class="window">
					<div class="title"><?php echo $browse_results; ?></div>
					<div class="content">
						<div class="inner">
							<div class="loader"><?php echo $loading; ?></div>
							<div class="serverError"><?php echo $loadingError; ?></div>
							<div class="noResult"><?php echo $noResults; ?></div>
							<div class="kuestsList"></div>
						</div>
					</div>
					<div class="bottom"></div>
				</div>
			</div>
			
			<div class="browse">
				<div class="window cell">
					<div class="title"><?php echo $browse_titleLeft; ?></div>
					<div class="content">
						<div class="inner">
							<div class="loader"><?php echo $loading; ?></div>
							<div class="serverError"><?php echo $loadingError; ?></div>
							<div class="noResult"><?php echo $noResults; ?></div>
							<div class="kuestsList"></div>
						</div>
					</div>
					<div class="bottom"></div>
				</div>
				<div class="window cell">
					<div class="title"><?php echo $browse_titleRight; ?></div>
					<div class="content">
						<div class="inner">
							<div class="loader"><?php echo $loading; ?></div>
							<div class="serverError"><?php echo $loadingError; ?></div>
							<div class="noResult"><?php echo $noResults; ?></div>
							<div class="kuestsList"></div>
						</div>
					</div>
					<div class="bottom"></div>
				</div>
			</div>
		</div>
	</body>
</html>