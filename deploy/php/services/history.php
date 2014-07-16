<?php
	require_once("../db/DBConnection.php");
	require_once("../out/Out.php");
	require_once("../log/Logger.php");
	require_once("../utils/OAuth.php");
	require_once("../l10n/labels.php");
	
	//Connect to database
	try {
		DBConnection::connect();
	}catch (Exception $error) {
		Out::printOut(false, '', "".$error->getMessage(), 'SQL_CONNECTION_FAIL');
		die;
	}
	
	OAuth::connect();
	
	//Get last kuests
	if(!isset($_POST['top']) || $_POST['top'] == 'false') {
		$sql = "SELECT kuestUsers.uid, kuests.id, kuests.name as title, kuests.description, kuests.guid, kuestUsers.name as pseudo, kuestEvaluations.id as evalId
		FROM kuestSaves
		INNER JOIN kuests ON kuestSaves.kid = kuests.id
		INNER JOIN kuestUsers ON kuests.uid = kuestUsers.uid
		LEFT JOIN kuestEvaluations ON (kuestEvaluations.kid = kuestSaves.kid AND kuestEvaluations.uid = kuestSaves.uid)
		WHERE kuestSaves.uid = :uid
		ORDER BY kuestSaves.id DESC";
		$params = array(':uid' => $_SESSION['kuest_uid']);
		$req = DBConnection::getLink()->prepare($sql);
		if (!$req->execute($params)) {
			$error = $req->errorInfo();
			$error = $error[2];
			Out::printOut(false, '', $error, 'SQL_ERROR');
			die;
		}
		$res = $req->fetchAll();
		
		//No result. Get a suggestion
		if (count($res) == 0) {
			//That request is probably heavy.. Put it in cache to prevent from doing it multiple times
			if(!isset($_SESSION['kuest_suggestionCache']) || !isset($_SESSION['kuest_suggestionCacheExpirationTime']) || time() > $_SESSION['kuest_suggestionCacheExpirationTime']) {
				$sql = "SELECT kuestEvaluations.uid, SUM(kuestEvaluations.note) as total, kuestEvaluations.kid, kuests.name as title, kuests.description, kuests.guid, kuestUsers.name as pseudo
				FROM kuestEvaluations
				INNER JOIN kuests ON kuestEvaluations.kid = kuests.id
				INNER JOIN kuestUsers ON kuests.uid = kuestUsers.uid
				GROUP BY kuestEvaluations.kid
				ORDER BY total DESC LIMIT 0,5";
				$params = array(':uid' => $_SESSION['kuest_uid']);
				$req = DBConnection::getLink()->prepare($sql);
				if (!$req->execute($params)) {
					$error = $req->errorInfo();
					$error = $error[2];
					Out::printOut(false, '', $error, 'SQL_ERROR');
					die;
				}
				$res = $req->fetchAll();
				$key = array_rand($res);
				$entry = $res[$key];
				$_SESSION['kuest_suggestionCache'] = $entry;
				$_SESSION['kuest_suggestionCacheExpirationTime'] = time() + 60 * 30;//Suggestion lasts 30 mins
			}else {
				$entry = $_SESSION['kuest_suggestionCache'];
			}
			
			$additionnals = "<kuests/>\n";
			$additionnals .= "\t<suggestion guid='".$entry['guid']."'>\n";
			$additionnals .= "\t\t<u id='".$entry['uid']."'><![CDATA[".htmlspecialchars(utf8_encode($entry['pseudo']), ENT_COMPAT, "UTF-8")."]]></u>\n";
			$additionnals .= "\t\t<title><![CDATA[".htmlspecialchars(utf8_encode($entry['title']), ENT_COMPAT, "UTF-8")."]]></title>\n";
			$additionnals .= "\t\t<description><![CDATA[".htmlspecialchars(utf8_encode($entry['description']), ENT_COMPAT, "UTF-8")."]]></description>\n";
			$additionnals .= "\t</suggestion>\n";
		
		}else {
		
			$additionnals = "<kuests>\n";
			for ($i = 0; $i < count($res); $i++) {
				$complete		= empty($res[$i]['evalId'])? 'false' : 'true';
				$completeLabel	= empty($res[$i]['evalId'])? $history_inProgress : $history_complete;
				$additionnals	.= "\t\t<k guid='".$res[$i]['guid']."' complete='".$complete."'>\n";
				$additionnals	.= "\t\t\t<u id='".$res[$i]['uid']."'><![CDATA[".htmlspecialchars(utf8_encode($res[$i]['pseudo']), ENT_COMPAT, "UTF-8")."]]></u>\n";
				$additionnals	.= "\t\t\t<title><![CDATA[".htmlspecialchars(utf8_encode($res[$i]['title']), ENT_COMPAT, "UTF-8")."]]></title>\n";
				$additionnals	.= "\t\t\t<description><![CDATA[".htmlspecialchars(utf8_encode($res[$i]['description']), ENT_COMPAT, "UTF-8").$completeLabel."]]></description>\n";
				$additionnals	.= "\t\t</k>\n";
			}
			$additionnals .= "\t</kuests>\n";
		}
		
		Out::printOut(true, $additionnals);
	}else{
		Out::printOut(false, '', 'Missing parameters', 'MISSING_PARAMETERS');
	}
	
?>