<?php
	require_once("../db/DBConnection.php");
	require_once("../out/Out.php");
	require_once("../log/Logger.php");
	require_once("../utils/OAuth.php");
	
	//Connect to database
	try {
		DBConnection::connect();
	}catch (Exception $error) {
		Out::printOut(false, '', "".$error->getMessage(), 'SQL_CONNECTION_FAIL');
		die;
	}
	
	OAuth::connect();
	
	//Search for quests
	if(isset($_POST['search'])) {
		$sql = "SELECT kuests.id, kuests.guid, kuests.uid as 'uid', kuests.description as 'description', kuests.name as 'title', kuestUsers.name as 'pseudo' FROM kuests, kuestUsers WHERE published=1 AND kuests.uid=kuestUsers.uid AND lang=:lang AND (kuests.name LIKE :search OR kuestUsers.name LIKE :search) ORDER BY kuests.id DESC";
		$params = array(':lang' => $_SESSION["lang"], ':search' => '%'.$_POST["search"].'%');
		$req = DBConnection::getLink()->prepare($sql);
		if (!$req->execute($params)) {
			$error = $req->errorInfo();
			$error = $error[2];
			Out::printOut(false, '', $error, 'SQL_ERROR');
			die;
		}
		$res = $req->fetchAll();
		$additionnals = "<kuests>\n";
		for ($i = 0; $i < count($res); $i++) {
			$sql	= "SELECT SUM(note) as 'note' FROM kuestEvaluations WHERE kid=:kid";
			$params	= array(':kid' => $res[$i]['id']);
			$req2	= DBConnection::getLink()->prepare($sql);
			$note	= "0";
			if ($req2->rowCount() > 0 && $req2->execute($params)) {
				$res2 = $req2->fetch();
				$note = $res2['note'];
			}
			$additionnals .= "\t\t<k guid='".$res[$i]['guid']."' note='".$note."'>\n";
			$additionnals .= "\t\t\t<u id='".$res[$i]['uid']."'><![CDATA[".$res[$i]['pseudo']."]]></u>\n";
			$additionnals .= "\t\t\t<title><![CDATA[".utf8_encode($res[$i]['title'])."]]></title>\n";
			$additionnals .= "\t\t\t<description><![CDATA[".utf8_encode($res[$i]['description'])."]]></description>\n";
			$additionnals .= "\t\t</k>\n";
		}
		$additionnals .= "\t</kuests>\n";
		
		Out::printOut(true, $additionnals);
	}
?>