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
	if(!isset($_SESSION['kuest_uid'])) {
		Out::printOut(false, '', 'You must be logged in.', 'NOT_LOGGED');
		die;
	}
	
	$path = '../../kuests/progressions/';
	$additionnals = "";
	if (isset($_POST["id"])) {
		
		if (!file_exists($path)) {
			Out::printOut(false, '', '"'.$path.'" directory does not exist.', 'PROGRESSION_DIRECTORY_MISSING');
			die;
		}
		
		//Get the save
		$sql = "SELECT * FROM `kuestSaves` WHERE kid=(SELECT id FROM kuests WHERE guid=:guid) AND uid=:uid";
		$params = array(':guid' => $_POST["id"], ':uid' => $_SESSION['kuest_uid']);
		$req = DBConnection::getLink()->prepare($sql);
		if (!$req->execute($params)) {
			$error = $req->errorInfo();
			$error = $error[2];
			Out::printOut(false, '', $error, 'SQL_ERROR');
			die;
		}
		$tot = $req->rowCount();
		if ($tot == 0) {
			Out::printOut(false, '', 'Save not found. ', 'SAVE_KUEST_NOT_FOUND', false);
			die;
		}else {
			$res = $req->fetch();
			$url = $path.$res['dataFile'].".sav";
			DBConnection::close();
			//If don't send the content-length header, flash cannot get the bytesLoaded and bytesTotal during loading
			header('Content-type: application/octet-stream');
			header("Content-length: ".filesize($url));
			echo file_get_contents($url);
		}
	}else{
		Out::printOut(false, '', 'POST data missing', 'INCOMPLETE_FORM');
	}
?>