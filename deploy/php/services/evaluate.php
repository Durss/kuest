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
	
	if (isset($_POST["id"], $_POST["note"], $_POST["key"])) {
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
			
			$key = ($_SERVER['HTTP_HOST'] == "localhost")? "f98dad718d97ee01a886fbd7f2dffcaa" : "34e2f927f72b024cd9d1cf0099b097ab";
			$app = ($_SERVER['HTTP_HOST'] == "localhost")? "kuest-dev" : "kuest";
			$url = "http://muxxu.com/app/xml?app=".$app."&xml=user&id=".$_SESSION['uid']."&key=".md5($key . $_POST["key"]);
			if($xml = simplexml_load_file($url))
			{
				$node = $xml->xpath("/user/games/g[@game='kube']");
				if(count($node) > 0) {
					$points = $node[0]->xpath("i[@key='Score']");
					$zones = $node[0]->xpath("i[@key='Carte']");
					$points = intval(preg_replace("[\D]", "", $points[0]->asXML()));
					$zones = intval(preg_replace("[\D]", "", $zones[0]->asXML()));
				}else {
					$points = 0;
					$zones = 0;
				}
			}
			
			//Ponderate note
			$noteBase = min(20, max(1, $_POST['note']));//Limit note input
			$note = $noteBase;
			$note += round($points * .03);
			$note += round($zones * .0001);
			
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