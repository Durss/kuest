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
	
	//Not logged
	if(!isset($_SESSION["uid"])) {
		Out::printOut(false, '', 'You must be logged in.', 'NOT_LOGGED');
		die;
	}
	
	$additionnals = "";
	if (isset($_POST["id"])) {
		$dataFile = $_POST["id"]."_".$_SESSION['uid'];
		
		//Delete DB entry
		$sql = "DELETE FROM `kuestSaves` WHERE kid=(SELECT id FROM kuests WHERE guid=:guid) AND uid=:uid";
		$params = array(':guid' => $_POST["id"], ':uid' => $_SESSION["uid"]);
		$req = DBConnection::getLink()->prepare($sql);
		if (!$req->execute($params)) {
			$error = $req->errorInfo();
			$error = $error[2];
			Out::printOut(false, '', $error, 'SQL_ERROR');
			die;
		}
		
		//Delete file
		@unlink("../../saves/".$dataFile.".sav");
		Out::printOut(true, "");
		
	}else{
		Out::printOut(false, '', 'POST data missing', 'INCOMPLETE_FORM');
	}
?>