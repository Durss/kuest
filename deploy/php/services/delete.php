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
		$sql = "SELECT id, uid, dataFile, friends FROM kuests WHERE guid=:guid";
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
		
		$isOwner = false;
		$additionnals = '';
		
		//Check if we have rights to delete this kuest.
		$res = $req->fetch();
		if ($_SESSION["uid"] != $res['uid']) {
			//If we have the rights on the map but are not its creator,
			//remove us from the rights
			$friends = explode(",", $res['friends']);
			//Remove empty items.
			for ($i = 0; $i < count($friends); $i++) {
				if (strlen($friends[$i]) == 0) {
					array_splice($friends, $i, 1);
					$i --;
				}
			}
			
			if (in_array($_SESSION["uid"], $friends)) {
				for ($i = 0; $i < count($friends); $i++) {
					if ($friends[$i] == $_SESSION['uid']) {
						array_splice($friends, $i, 1);
						$i --;
					}
				}
				$sqlDel = "UPDATE kuests SET friends=:friends WHERE guid=:guid";
				$paramsDel = array(':guid' => $_POST["id"], ':friends' => ",".implode(",", $friends).",");
				$reqDel = DBConnection::getLink()->prepare($sqlDel);
				if (!$reqDel->execute($paramsDel)) {
					$error = $reqDel->errorInfo();
					$error = $error[2];
					Out::printOut(false, '', $error, 'SQL_ERROR');
					die;
				}
				$isOwner = false;
				$additionnals = '<selfDelete></selfDelete>';
			}else{
				Out::printOut(false, '', 'Quest deletion denied.', 'DELETE_NO_RIGHTS');
				die;
			}
		}else {
			$isOwner = true;
		}
		
		if($isOwner) {
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
			//Deletes the save files
			$sql = "SELECT * FROM kuestSaves WHERE kid=:id";
			$req = DBConnection::getLink()->prepare($sql);
			if (!$req->execute($params)) {
				$error = $req->errorInfo();
				$error = $error[2];
				Out::printOut(false, '', $error, 'SQL_ERROR');
				die;
			}
			$entries = $req->fetchAll();
			for ($i = 0; $i < count($entries); $i++) {
				@unlink("../../saves/".$entries[$i]['dataFile'].".sav");
			}
			
			//Deletes the saves logs
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
		}
		
		Out::printOut(true, $additionnals);
		
	}else{
		Out::printOut(false, '', 'POST data missing', 'INCOMPLETE_FORM');
	}
	
?>