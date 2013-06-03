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
	
	$releaseMode = isset($_POST["release"]);
	if($releaseMode) {
		$dir = "../../kuests/published/";
	}else {
		$dir = "../../kuests/saves/";
	}
	if (isset($_POST["id"])) {
		//Check for loading rights
		$sql = "SELECT uid, dataFile, friends, published FROM kuests WHERE guid=:guid";
		$params = array(':guid' => $_POST["id"]);
		$req = DBConnection::getLink()->prepare($sql);
		if (!$req->execute($params)) {
			$error = $req->errorInfo();
			$error = $error[2];
			Out::printOut(false, '', $error, 'SQL_ERROR');
			die;
		}
		$tot = $req->rowCount();
		if ($tot == 0) {
			Out::printOut(false, '', 'Quest not found.', 'LOADING_KUEST_NOT_FOUND');
			die;
		}
		
		//Check if we have rights to load this kuest.
		$res = $req->fetch();
		if (!$releaseMode && $res['uid'] != "0" && $_SESSION["uid"] != $res['uid'] && strpos($res['friends'], ",".$_SESSION["uid"].",") === false) {
			Out::printOut(false, '', 'Quest loading denied.', 'LOADING_NO_RIGHTS');
			die;
		}
		
		if ($releaseMode && !$res['published']) {
			Out::printOut(false, '', 'Quest not published.', 'QUEST_NOT_PUBLISHED');
			die;
		}
		
		//Output file's content
		$url = $dir.$res["dataFile"].".kst";
		if (!file_exists($url)) {
			if ($releaseMode) {
				Out::printOut(false, '', 'Quest not published.', 'QUEST_FILE_NOT_PUBLISHED');
			}else{
				Out::printOut(false, '', 'Quest file not found.', 'QUEST_FILE_NOT_FOUND');
			}
			die;
		}
		DBConnection::close();
		//If don't send the content-length header, flash cannot get the bytesLoaded and bytesTotal during loading
		header('Content-type: application/octet-stream');
		header("Content-length: ".filesize($url));
		echo file_get_contents($url);
		
	}else{
		Out::printOut(false, '', 'POST data missing', 'INCOMPLETE_FORM');
	}
	
?>