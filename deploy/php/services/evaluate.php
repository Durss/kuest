<?php
	require_once("../db/DBConnection.php");
	require_once("../out/Out.php");
	require_once("../log/Logger.php");
	require_once("../utils/OAuth.php");
	
	//Connect to database
	try {
		DBConnection::connect();
	}catch (Exception $error) {
		Out::printOut(false, '', $error->getMessage(), 'SQL_CONNECTION_FAIL');
		die;
	}
	
	OAuth::connect();
	
	//Not logged
	if(!isset($_SESSION["logged"]) || $_SESSION["logged"] === false) {
		Out::printOut(false, '', 'You must be logged in.', 'NOT_LOGGED');
		die;
	}
	
	//If query parameters are correct
	if (isset($_POST["id"], $_POST["note"], $_POST["key"])) {
		//Check if the quest key is valid
		if ($_SESSION["pubkey"] != $_POST['key']) {
			Out::printOut(false, '', 'Invalid key.', 'KUEST_EVALUATION_INVALID_KEY', false);
			die;
		}
	
		//Check if we have already evaluated this quest or not
		$sql = "SELECT * FROM kuestEvaluations WHERE kid=(SELECT id FROM kuests WHERE guid=:guid) AND uid=:uid";
		$params = array(':guid' => $_POST["id"], ':uid' => $_SESSION["uid"]);
		$req = DBConnection::getLink()->prepare($sql);
		if (!$req->execute($params)) {
			$error = $req->errorInfo();
			$error = $error[2];
			Out::printOut(false, '', $error, 'SQL_ERROR');
			die;
		}
		
		$tot = $req->rowCount();
		if ($tot !== 0) {
			
			//Quest already evaluated
			Out::printOut(false, '', 'Kuest already evaluated.', 'KUEST_ALREADY_EVALUATED', false);
			die;
			
		}else {
			//Grab the statistics
			$json = OAuth::call('siteUser/'.$_SESSION['uid'].'/18?fields=user,site,realId,link,stats.fields(id,score)');
			$stats = $json->stats;
			$points = 0;
			$zones = 0;
			for ($i = 0; $i < count($stats); $i++) {
				if($stats[$i]->id == 'action') $points = (int) $stats[$i]->score;
				if($stats[$i]->id == 'zones') $zones = (int) $stats[$i]->score;
			}
			
			//Ponderate note
			$noteBase = min(20, max(1, $_POST['note']));//Limit note input
			$note = $noteBase;
			$note += max(0, round($points * .0001));
			$note += max(0, round($zones * .00005));
			
			//Get the quest's ID
			$sql = "SELECT * FROM kuests WHERE guid=:guid";
			$params = array(':guid' => $_POST["id"]);
			$req = DBConnection::getLink()->prepare($sql);
			if (!$req->execute($params)) {
				$error = $req->errorInfo();
				$error = $error[2];
				Out::printOut(false, '', $error, 'SQL_ERROR');
				die;
			}
			$res = $req->fetch();
			
			//Register evaluation
			$sql = "INSERT INTO kuestEvaluations (uid, kid, note, noteBase) VALUES (:uid, :kid, :note, :noteBase)";
			$params = array(':uid' => $_SESSION['uid'], ':kid' => $res["id"], ':note' => $note, ':noteBase' => $noteBase);
			$req = DBConnection::getLink()->prepare($sql);
			if (!$req->execute($params)) {
				$error = $req->errorInfo();
				$error = $error[2];
				Out::printOut(false, '', $error, 'SQL_ERROR');
				die;
			}
			
			Out::printOut(true, "");
		}
		
	}else{
		Out::printOut(false, '', 'POST data missing', 'INCOMPLETE_FORM');
	}
?>