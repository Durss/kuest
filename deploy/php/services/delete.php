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
	
	$dir1 = "../../kuests/saves/";
	$dir2 = "../../kuests/published/";
	
	if (isset($_POST["id"])) {
		//Check for loading rights
		$sql = "SELECT id, uid, dataFile FROM kuests WHERE guid=:guid";
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
			Out::printOut(false, '', 'Quest not found.', 'DELETE_KUEST_NOT_FOUND');
			die;
		}
		
		//Check if we have rights to delete this kuest.
		$res = $req->fetch();
		if ($_SESSION["uid"] != $res['uid']) {
			Out::printOut(false, '', 'Quest deletion denied.', 'DELETE_NO_RIGHTS');
			die;
		}
		
		//Deletes the DB entry
		$sql = "DELETE FROM kuests WHERE guid=:guid";
		$req = DBConnection::getLink()->prepare($sql);
		if (!$req->execute($params)) {
			$error = $req->errorInfo();
			$error = $error[2];
			Out::printOut(false, '', $error, 'SQL_ERROR');
			die;
		}
		
		$params = array(':id' => $res["id"]);
		//Deletes the users saves
		$sql = "DELETE FROM kuestSaves WHERE kid=:id";
		$req = DBConnection::getLink()->prepare($sql);
		if (!$req->execute($params)) {
			$error = $req->errorInfo();
			$error = $error[2];
			Out::printOut(false, '', $error, 'SQL_ERROR');
			die;
		}
		
		//Deletes the evaluations
		$sql = "DELETE FROM kuestEvaluations WHERE kid=:id";
		$req = DBConnection::getLink()->prepare($sql);
		if (!$req->execute($params)) {
			$error = $req->errorInfo();
			$error = $error[2];
			Out::printOut(false, '', $error, 'SQL_ERROR');
			die;
		}
		
		//Delete quests files.
		@unlink($dir1.$res["dataFile"].".kst");
		@unlink($dir2.$res["dataFile"].".kst");
		
		Out::printOut(true, '');
		
	}else{
		Out::printOut(false, '', 'POST data missing', 'INCOMPLETE_FORM');
	}
	
?>