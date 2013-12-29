<?php
	require_once("../db/DBConnection.php");
	require_once("../out/Out.php");
	require_once("../log/Logger.php");
	require_once("../utils/Xor.php");
	
	session_start();
	
	$time = time();
	
	define('XOR_KEY', "DataManagerEvent"); //Encryption key
	$time = base64_encode(Xorer::bitxor(XOR_KEY, (string) time()));
	
	$isLogged = isset($_SESSION['kuest_logged']) && $_SESSION['kuest_logged'] === true;
	$additionnals = "<logged>".($isLogged? 'true' : 'false')."</logged>";
	if ($isLogged) {
		$additionnals .= "<uid>".$_SESSION['kuest_uid']."</uid>\n";
		$additionnals .= "\t<name>".$_SESSION['kuest_name']."</name>\n";
		$additionnals .= "\t<pubkey>".$_SESSION['kuest_oAuthkey']."</pubkey>\n";
		$additionnals .= "\t<lang>".$_SESSION['kuest_lang']."</lang>\n";
		$additionnals .= "\t<time><![CDATA[".$time."]]></time>\n";//encrypted time is sent to prevent from time hacking by simply changing the desktop's time.
	}
	//session_destroy();
	Out::printOut(true, $additionnals);
?>