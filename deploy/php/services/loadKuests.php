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
		$sql = "SELECT kuests.id, kuests.guid, kuests.uid as 'uid', kuests.description as 'description', kuests.name as 'title', kuestUsers.name as 'pseudo', (SELECT COUNT(kuestSaves.id) FROM kuestSaves WHERE kid=kuests.id) as 'totalPlays'
		FROM kuests
		INNER JOIN kuestUsers ON kuestUsers.uid = kuests.uid
		WHERE published = 1 AND lang = :lang
		ORDER BY kuests.id DESC
		LIMIT 0, 30";
		
		$params = array(':lang' => $_SESSION['kuest_lang']);
		$req = DBConnection::getLink()->prepare($sql);
		if (!$req->execute($params)) {
			$error = $req->errorInfo();
			$error = $error[2];
			Out::printOut(false, '', $error, 'SQL_ERROR');
			die;
		}
		$res = $req->fetchAll();
		$additionnals = "<kuests top='false'>\n";
		for ($i = 0; $i < count($res); $i++) {
			$sql	= "SELECT SUM(note) as 'note' FROM kuestEvaluations WHERE kid=:kid";
			$params	= array(':kid' => $res[$i]['id']);
			$req2	= DBConnection::getLink()->prepare($sql);
			$note	= "0";
			if ($req2->rowCount() > 0 && $req2->execute($params)) {
				$res2 = $req2->fetch();
				$note = $res2['note'];
			}
			$additionnals .= "\t\t<k guid='".$res[$i]['guid']."' note='".$note."' plays='".$res[$i]['totalPlays']."'>\n";
			$additionnals .= "\t\t\t<u id='".$res[$i]['uid']."'><![CDATA[".utf8_encode(htmlspecialchars($res[$i]['pseudo']))."]]></u>\n";
			$additionnals .= "\t\t\t<title><![CDATA[".utf8_encode(htmlspecialchars($res[$i]['title']))."]]></title>\n";
			$additionnals .= "\t\t\t<description><![CDATA[".utf8_encode(htmlspecialchars($res[$i]['description'])).$browse_players."]]></description>\n";
			$additionnals .= "\t\t</k>\n";
		}
		$additionnals .= "\t</kuests>\n";
		
		Out::printOut(true, $additionnals);
	
	//Get best notted quests 
	}else {
		$sql = "SELECT kid, SUM(note) as 'total'
		FROM kuestEvaluations
		INNER JOIN kuests ON kuests.id = kuestEvaluations.kid
		WHERE kuests.lang = :lang
		GROUP BY kid ORDER BY SUM(note)
		DESC LIMIT 0,30";
		$params = array(':lang' => $_SESSION['kuest_lang']);
		$req = DBConnection::getLink()->prepare($sql);
		if (!$req->execute($params)) {
			$error = $req->errorInfo();
			$error = $error[2];
			Out::printOut(false, '', $error, 'SQL_ERROR');
			die;
		}
		
		$res = $req->fetchAll();
		$additionnals = "<kuests top='true'>\n";
		for ($i = 0; $i < count($res); $i++) {
			$sql2		= "SELECT kuests.id, kuests.lang, kuests.description as 'description', kuests.guid, kuests.uid as 'uid', kuests.name as 'title', kuestUsers.name as 'pseudo', (SELECT COUNT(kuestSaves.id) FROM kuestSaves WHERE kid=:kid) as 'totalPlays'
			FROM kuests
			INNER JOIN kuestUsers ON kuestUsers.uid = kuests.uid
			WHERE kuests.published = 1 AND kuests.id = :kid
			ORDER BY kuests.id DESC";
			
			$params2	= array(':kid' => $res[$i]['kid']);
			$req2		= DBConnection::getLink()->prepare($sql2);
			$req2->execute($params2);
			if ($req2->rowCount() > 0) {
				$res2 = $req2->fetch();
				if ($res2['lang'] == $_SESSION['kuest_lang']) {
					$additionnals .= "\t\t<k guid='".$res2['guid']."' note='".$res[$i]['total']."' plays='".$res2['totalPlays']."'>\n";
					$additionnals .= "\t\t\t<u id='".$res2['uid']."'><![CDATA[".htmlspecialchars($res2['pseudo'])."]]></u>\n";
					$additionnals .= "\t\t\t<title><![CDATA[".utf8_encode(htmlspecialchars($res2['title']))."]]></title>\n";
					$additionnals .= "\t\t\t<description><![CDATA[".utf8_encode(htmlspecialchars($res2['description'])).$browse_players."]]></description>\n";
					$additionnals .= "\t\t</k>\n";
				}
			}
		}
		$additionnals .= "\t</kuests>\n";
		
		Out::printOut(true, $additionnals);
	}
?>