<?php
	if (!isset($_GET["uid"], $_GET["pubkey"])) {
		header("location:http://muxxu.com/a/kuest?act=ids");
	}

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
			<strong>Identifiants de connexion :</strong>
			<p>Ces valeurs sont à renseigner dans les champs du même nom au sein de l'application si vous l'utilisez en dehors de muxxu :</p>
			<div class="table">
				<div class="row">
					<div class="colLeft"><h1>UID</h1></div>
					<div class="colMiddle"><h2 id="uid"><?php echo $_GET["uid"]; ?></h2></div>
					<div class="colRight" id="copy1"><h2 class="copyLink"><a href="#">Copier</a></h2></div>
				</div>
				<div class="row">
					<div class="colLeft"><h1>PUBKEY</h1></div>
					<div class="colMiddle"><h2 id="pubkey"><?php echo htmlentities($_GET["pubkey"]); ?></h2></div>
					<div class="colRight" id="copy2"><h2 class="copyLink"><a href="#">Copier</a></h2></div>
				</div>
			</div>
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