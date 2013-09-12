<?php
	require_once("../db/DBConnection.php");
	require_once("../out/Out.php");
	require_once("../log/Logger.php");
	require_once("../utils/Xor.php");
	
	session_start();
	
	$time = time();
	
	define('XOR_KEY', "DataManagerEvent"); //Encryption key
	$time = base64_encode(Xorer::bitxor(XOR_KEY, (string) time()));
	
	$isLogged = isset($_SESSION['logged']) && $_SESSION['logged'] === true;
	$additionnals = "<logged>".($isLogged? 'true' : 'false')."</logged>";
	if ($isLogged) {
		$additionnals .= "<uid>".$_SESSION["uid"]."</uid>\n";
		$additionnals .= "\t<name>".$_SESSION["name"]."</name>\n";
		$additionnals .= "\t<pubkey>".$_SESSION["pubkey"]."</pubkey>\n";
		$additionnals .= "\t<lang>".$_SESSION["lang"]."</lang>\n";
		$additionnals .= "\t<time><![CDATA[".$time."]]></time>\n";//Time is sent to prevent from time hacking by changing the desktop's time.
	}
	//session_destroy();
	Out::printOut(true, $additionnals);
?>