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
		header("location: http://fevermap.org/dials/admin");
		die;
	}
	
	//Connect to database
	try {
		DBConnection::connect();
	}catch (Exception $loadingError) {
		echo 'Unable to contact database... :(';
		die;
	}
	
	if (!isset($_SESSION['kuest_uid']) || ($_SESSION['kuest_uid'] != 48 && $_SESSION['kuest_uid'] != 1875)) {
		header("location: /dials");
	}
	
	$flash = '';
	if (isset($_GET['delete'])) {
		//Insert into DB
		$sql = "DELETE from kuestDialogues WHERE id=:id";
		$params = array(':id' => $_GET['delete']);
		$req = DBConnection::getLink()->prepare($sql);
		if (!$req->execute($params)) {
			$error = $req->errorInfo();
			$error = $error[2];
			$flash = '<div class="flash">Woops... ça a chié :(<br /><pre>'.$error.'</pre></div>';
		}else {
			$_SESSION['kuest_dial_delete'] = true;
			header("location: /dials/admin");
			die;
		}
	}
	
	if(isset($_SESSION['kuest_dial_delete']) && $_SESSION['kuest_dial_delete'] === true) {
		$flash = '<div class="flash">Dialogue supprimé avec succès !</div>';
		$_SESSION['kuest_dial_delete'] = false;
	}
	
	
	
	$sql = "SELECT * FROM kuestDialogues ORDER BY id DESC";
	$params = array();
	$req = DBConnection::getLink()->prepare($sql);
	if (!$req->execute($params)) {
		$error = $req->errorInfo();
		$error = $error[2];
		$flash = '<div class="flash">Woops... ça a chié :(<br /><pre>'.$error.'</pre></div>';
	}else{
		$entries = $req->fetchAll();
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
		
		<script type="text/javascript" src="/kuest/js/plugins/CSSPlugin.min.js"></script>
		<script type="text/javascript" src="/kuest/js/easing/EasePack.min.js"></script>
		<script type="text/javascript" src="/kuest/js/TweenLite.min.js"></script>
		<link rel="stylesheet" type="text/css" href="css/stylesheet.css"/>
		<link rel="stylesheet" type="text/css" href="css/opentip.css"/>
		
		<script type="text/javascript" src="js/opentip.js"></script>
		<script type="text/javascript" src="js/utils.js"></script>
		<script type="text/javascript">
			function deleteEntry(id) {
				if (confirm("Supprimer ce message ?")) {
					window.location.href = '?delete='+id;
				}
			}
		</script>
	</head>
	<body>
		<a href="/dials"><div class="banner"></div></a>
		<?php echo $flash; ?>
		<div class="table">
			<?php 
			for($i=0; $i < count($entries); $i++) {
				if($i%2 == 0) echo '<div style="display:table-row">';
			?>
			<div class="window cell">
				<div class="title">
					<a href="http://twinoid.com/user/<?php echo $entries[$i]['uid']; ?>" target="_blank"><img src="img/user.png"/></a> &nbsp;<?php echo utf8_encode($entries[$i]['pseudo']); ?>&nbsp;&nbsp;
					[<?php echo $entries[$i]['zoneX']; ?>][<?php echo $entries[$i]['zoneY']; ?>]
					<span class="delete"><a href="#" onclick="deleteEntry(<?php echo $entries[$i]['id']; ?>)"><img src="img/delete.gif"/></a></span>
				</div>
				<div class="content">
					<div class="inner">
						<form method="POST" action="?">
							<img src="<?php echo $entries[$i]['avatar']; ?>" class="avatar avatarLeft" />
							<?php echo nl2br(utf8_encode($entries[$i]['text'])); ?><br /><br />
						</form>
					</div>
				</div>
				<div class="bottom">
					<div class="date">
					<?php 
						$date = new DateTime($entries[$i]['date']);
						echo $date->format('d-m-y H:i:s');
					?>
					</div>
				</div>
			</div>
			<?php
				if($i%2 == 1) echo '</div>';
			}
			?>
		</div>
	</body>
</html>