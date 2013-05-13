<?php
	if (!isset($_GET["uid"], $_GET["pubkey"])) {
		header("location:http://muxxu.com/a/kuest?act=ids");
	}

	session_start();
	if(isset($_SESSION["lang"])) 
		$lang = $_SESSION["lang"];
	else
		$lang = substr($_SERVER['HTTP_ACCEPT_LANGUAGE'], 0, 2);
	
	$title = array();
	$title["fr"] = "Identifiants de connexion :";
	$title["en"] = "My logins :";
	
	$content = array();
	$content["fr"] = "Ces valeurs sont à renseigner dans les champs du même nom au sein de l'application si vous l'utilisez en dehors de Muxxu à l'adresse suivante <a href='http://fevermap.org/kuest' target='_blank'>http://fevermap.org/kuest</a> :";
	$content["en"] = "These values must be copied inside the application if you use it outside of Muxxu at the following address <a href='http://fevermap.org/kuest' target='_blank'>http://fevermap.org/kuest</a> :";
	
	$copy = array();
	$copy["fr"] = "Copier";
	$copy["en"] = "Copy";
	
	$click = array();
	$click["fr"] = "Ou cliquez ici";
	$click["en"] = "Or click here";
	
	if(!$content[ $lang ])
	$lang = "en";
?>
<!DOCTYPE html>
<html lang="fr">
	<head>
		<title>Kuest IDS</title>
		<link rel="shortcut icon" href="favicon.ico" />
		<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
		<meta name="language" content="fr" />
		<meta name="description" content="" />
		<meta name="keywords" content="" />
		
		<link rel="stylesheet" type="text/css" href="css/stylesheet.css"/>
		<script type="text/javascript" src="js/ZeroClipboard.js"></script>
	</head>
	<body>
		<div class="window">
			<div class="title"><?php echo $title[$lang]; ?></div>
			<div class="content"><?php echo $content[$lang]; ?>
				<div class="table">
					<div class="row">
						<div class="colLeft"><h1>UID</h1></div>
						<div class="colMiddle"><h2 id="uid"><?php echo htmlentities($_GET["uid"]); ?></h2></div>
						<div class="colRight" id="copy1"><h2 class="copyLink"><a href="#"><?php echo $copy[$lang]; ?></a></h2></div>
					</div>
					<div class="row">
						<div class="colLeft"><h1>PUBKEY</h1></div>
						<div class="colMiddle"><h2 id="pubkey"><?php echo htmlentities($_GET["pubkey"]); ?></h2></div>
						<div class="colRight" id="copy2"><h2 class="copyLink"><a href="#"><?php echo $copy[$lang]; ?></a></h2></div>
					</div>
				</div>
				<br /><center><a href="http://fevermap.org/kuest/?uid=<?php echo htmlentities($_GET["uid"]); ?>&pubkey=<?php echo htmlentities($_GET["pubkey"]); ?>" target="_blank">&gt; <?php echo $click[$lang]; ?> &lt;</a></center>
			</div>
			<div class="bottom"></div>
		</div>
		
		<script language="JavaScript">
			var clip = null;
			ZeroClipboard.setMoviePath('swf/ZeroClipboard10.swf');

			function $(id) { return document.getElementById(id); }

			function init() {
				clip = new ZeroClipboard.Client();
				clip.setHandCursor(true);
				clip.setText( $('uid').innerHTML );
				clip.glue('copy1');
				
				clip = new ZeroClipboard.Client();
				clip.setHandCursor(true);
				clip.setText( $('pubkey').innerHTML );
				clip.glue('copy2');
			}
			window.onload = init;
		</script>
	</body>
</html>