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
	if (isset($_GET["id"], $_GET["size"], $GLOBALS['HTTP_RAW_POST_DATA'])) {
	
		if (strlen($GLOBALS['HTTP_RAW_POST_DATA']) != $_GET["size"]) {
			Out::printOut(false, '', 'Server didn\'t received all the data. Received ' .strlen($GLOBALS['HTTP_RAW_POST_DATA'])."bytes instead of ".$_GET["size"]." bytes.", 'MISSING_DATA_PART');
			die;
		}
		
		$dataFile = $_GET["id"]."_".$_SESSION['uid'];
		//Check if file is already registered
		$sql = "SELECT * FROM `kuestSaves` WHERE kid=(SELECT id FROM kuests WHERE guid=:guid) AND uid=:uid";
		$params = array(':guid' => $_GET["id"], ':uid' => $_SESSION["uid"]);
		$req = DBConnection::getLink()->prepare($sql);
		if (!$req->execute($params)) {
			$error = $req->errorInfo();
			$error = $error[2];
			Out::printOut(false, '', $error, 'SQL_ERROR');
			die;
		}
		$tot = $req->rowCount();
		if ($tot == 0) {
			//No save yet, add DB entry
			$sql = "INSERT INTO `kuestSaves` (uid, kid, dataFile) VALUES (:uid, (SELECT id FROM kuests WHERE guid=:guid), :file)";
			$params = array(':uid' => $_SESSION["uid"], ':guid' => $_GET["id"], ':file' => $dataFile);
			$req = DBConnection::getLink()->prepare($sql);
			if (!$req->execute($params)) {
				$error = $req->errorInfo();
				$error = $error[2];
				Out::printOut(false, '', $error, 'SQL_ERROR');
				die;
			}
		}
		
		//Save file
		if($fp = @fopen("../../saves/".$dataFile.".sav", 'wb')) {
			fwrite($fp, $GLOBALS[ 'HTTP_RAW_POST_DATA' ]);
			fclose($fp);
			Out::printOut(true, "");
		}else {
			Out::printOut(false, '', 'Unable to open file '.$dataFile, 'CANNOT_WRITE_SAVE');
		}
		
	}else{
		Out::printOut(false, '', 'POST data missing', 'INCOMPLETE_FORM');
	}
?>