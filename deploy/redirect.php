<?php
	//header("location:http://kube.muxxu.com/?kuest=".$_GET['id']);
?>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html>
	<head>
		<title>Kuests</title>
		<link rel="shortcut icon" href="favicon.ico" />
		<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
		<meta name="language" content="en" />
		<meta name="description" content="Tool to create quests for the game Kube." />
		<meta name="keywords" content="kube, quest, durss" />
		
		<link rel="stylesheet" type="text/css" href="css/stylesheet.css"/>
	</head>
	<body style="text-align:center;">
		<div id="redirectDiv" style="display:none;">Si vous n'êtes pas redirigé, <a href="http://kube.muxxu.com/?<?php echo $_SERVER['QUERY_STRING']; ?>" target="_blank">cliquez ici</a>.<br /></div>
		<img src="img/loader.gif" alt="patientez..." />
		<script type="text/javascript">
			//this page provides a way to get a document.referrer containing the quest ID.
			//That way, even if the user is redirected to the zone/choose page, and so the "kuest"
			//parameter is cleared from the URL, we still can grab the ID from the referrer and
			//override all the buttons link to add the "kuest" parameter. So that when the user
			//choose a spawn zone, the kuest ID will be on the URL.
			var target= window.parent || window;
			target.location = "http://kube.muxxu.com/?<?php echo $_SERVER['QUERY_STRING']; ?>";
			function showMessage() {
				document.getElementById("redirectDiv").style.display = "block";
			}
			setTimeout(showMessage, 2000);
		</script>
	</body>
</html>