<?php
	require_once("../db/DBConnection.php");
	require_once("../out/Out.php");
	require_once("../log/Logger.php");
	
	session_start();
	
	$isLogged = isset($_SESSION['uid']);
	$additionnals = "<logged>".($isLogged? 'true' : 'false')."</logged>";
	if ($isLogged) {
		$additionnals .= "<uid>".$_SESSION["uid"]."</uid>\n";
		$additionnals .= "\t<name>".$_SESSION["name"]."</name>\n";
		$additionnals .= "\t<pubkey>".$_SESSION["pubkey"]."</pubkey>\n";
		$additionnals .= "\t<lang>".$_SESSION["lang"]."</lang>\n";
	}
	//session_destroy();
	Out::printOut(true, $additionnals);
?>