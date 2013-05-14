<?php
	require_once("../db/DBConnection.php");
	require_once("../out/Out.php");
	require_once("../log/Logger.php");
	
	//Connect to database
	try {
		DBConnection::connect();
	}catch (Exception $error) {
		Out::printOut(false, '', $error->getMessage(), 'SQL_CONNECTION_FAIL');
		die;
	}
	
	//Missing data
	if(!isset($_POST["kid"])) {
		Out::printOut(false, '', 'POST data missing', 'INCOMPLETE_FORM');
		die;
	}
	
	
	$sql = "SELECT * FROM kuests WHERE guid=:guid";
	$params = array(':guid' => $_POST["kid"]);
	$req = DBConnection::getLink()->prepare($sql);
	if (!$req->execute($params)) {
		Out::printOut(false, '', $req->errorInfo(), 'SQL_ERROR');
		die;
	}
	$res = $req->fetch();
	$additionnals = "<title><![CDATA[".$res["name"]."]]></title>\n";
	$additionnals .= "\t<description><![CDATA[".$res["description"]."]]></description>\n";
	Out::printOut(true, $additionnals);
?>