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
	if(!isset($_POST["uid"])) {
		Out::printOut(false, '', 'You must be logged in.', 'NOT_LOGGED');
		die;
	}
	
	$dir = "../../kuest/";
	if (isset($_POST["id"])) {
		//Insert into DB
		$sql = "SELECT uid FROM kuests WHERE id=:id";
		$params = array(':id' => $_POST["id"]);
		$req = DBConnection::getLink()->prepare($sql);
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
		echo file_get_contents($dir.$_POST["id"].".kst");
		
	}else{
		Out::printOut(false, '', 'Missing parameters.', 'MISSING_PARAMETERS');
	}
	
?>