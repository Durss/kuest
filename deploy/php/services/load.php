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
	
	$dir = "../../kuests/saves/";
	if (isset($_GET["id"])) $_POST["id"] = $_GET["id"];
	
	if (isset($_POST["id"])) {
		//Check for loading rights
		$sql = "SELECT uid, dataFile FROM kuests WHERE id=:id";
		$params = array(':id' => $_POST["id"]);
		$req = DBConnection::getLink()->prepare($sql);
		if (!$req->execute($params)) {
			Out::printOut(false, '', $req->errorInfo(), 'SQL_ERROR');
			die;
		}
		$tot = $req->rowCount();
		if ($tot == 0) {
			Out::printOut(false, '', 'Kuest not found.', 'LOADING_KUEST_NOT_FOUND');
			die;
		}
		
		//Check if we have rights to load this kuest.
		$res = $req->fetch();
		if ($_SESSION["uid"] != $res['uid']) {
			Out::printOut(false, '', 'Loading denied.', 'LOADING_NO_RIGHTS');
			die;
		}
		
		//Output file's content
		$url = $dir.$res["dataFile"].".kst";
		DBConnection::close();
		//If don't send the content-length header, flash cannot get the bytesLoaded and bytesTotal during loading
		header('Content-type: application/octet-stream');
		header("Content-length: ".filesize($url));
		echo file_get_contents($url);
		
	}else{
		Out::printOut(false, '', 'POST data missing', 'INCOMPLETE_FORM');
	}
	
?>