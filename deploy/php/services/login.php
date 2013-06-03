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
	
	//##########################################
	//##########################################
	//##########################################
	//################ REMOVE ##################
	//##########################################
	//##########################################
	//##########################################
	/*$additionnals = "";
	$additionnals .= "<uid>89</uid>\n";
	$additionnals .= "\t<name>Durss</name>\n";
	$additionnals .= "\t<pubkey>xxxx</pubkey>\n";
	Out::printOut(true, $additionnals);
	die;*/
	//##########################################
	//##########################################
	//##########################################
	//################ REMOVE ##################
	//##########################################
	//##########################################
	//##########################################

	if(isset($_POST["logout"])) {
		session_destroy();
	}
	$additionnals = "";
	$friends = array();
	if (isset($_POST["pubkey"], $_POST["uid"], $_POST["samples"])) {
		if(!isset($_SESSION['uid']) || ($_SESSION["uid"] != $_POST["uid"]) || !isset($_SESSION['pubkey']) || $_SESSION["pubkey"] != $_POST["pubkey"]) {
			$key = ($_SERVER['HTTP_HOST'] == "localhost")? "f98dad718d97ee01a886fbd7f2dffcaa" : "34e2f927f72b024cd9d1cf0099b097ab";
			$app = ($_SERVER['HTTP_HOST'] == "localhost")? "kuest-dev" : "kuest";
			$url = "http://muxxu.com/app/xml?app=".$app."&xml=user&id=".$_POST['uid']."&key=".md5($key . $_POST["pubkey"]);
			$xml = @simplexml_load_file($url);
			
			if ($xml === false) {
				Out::printOut(false, '', 'Muxxu API unavailable', 'API_ERROR');
				die;
			}
			
			if ($xml->getName() != "error") {
				$_SESSION["uid"]	= $_POST["uid"];
				$_SESSION["pubkey"]	= $_POST["pubkey"];
				$_SESSION["name"]	= (string) $xml->attributes()->name;
				$_SESSION["lang"]	= (string)$xml->attributes()->lang;
				$_SESSION["version"]= SESSION_VERSION;
			}else {
				Out::printOut(false, '', 'Invalid UID and/or PUBKEY', 'INVALID_IDS');
				die;
			}
			
			$dataKey = (string) $xml->attributes()->friends;
			$url = "http://muxxu.com/app/xml?app=".$app."&xml=friends&id=".$_POST['uid']."&key=".md5($key . $dataKey);
			$xml = @simplexml_load_file($url);
			$children = $xml->children();
			foreach ($children as $row) {
				$friends[] = array( 'name' => (string) $row['name'], 'id' => (string) $row['id'] );
			}
			$_SESSION["friends"] = $friends;
		}else if(isset($_SESSION["friends"])){
			$friends = $_SESSION["friends"];
		}
		
		$sql = "SELECT * FROM kuestUsers WHERE uid=:uid";
		$params = array(':uid' => $_SESSION["uid"]);
		$req = DBConnection::getLink()->prepare($sql);
		$req->execute($params);
		$tot = $req->rowCount();
		
		//User doesn't exist
		if ($tot == 0) {
			$sql = "INSERT INTO kuestUsers (uid, name, pubkey) VALUES (:uid, :name, :pubkey)";
			$params = array(':uid' => $_SESSION["uid"], ':name' => $_SESSION["name"], ':pubkey' => $_SESSION["pubkey"]);
			$req = DBConnection::getLink()->prepare($sql);
			$req->execute($params);
			$id = DBConnection::getLink()->lastInsertId();
			//$additionnals .= "\t<test>".print_r($req->errorInfo())."</test>\n";
		
		//User exists, update its nickname in case he changed it.
		}else {
			$sql = "UPDATE kuestUsers SET `pseudo`=:name WHERE `uid`=:uid";
			$params = array(':name' => $_SESSION["name"], ':uid' => $_SESSION["uid"]);
			$req = DBConnection::getLink()->prepare($sql);
			$req->execute($params);
		}
		
		$additionnals .= "<uid>".$_SESSION["uid"]."</uid>\n";
		$additionnals .= "\t<name>".$_SESSION["name"]."</name>\n";
		$additionnals .= "\t<pubkey>".$_SESSION["pubkey"]."</pubkey>\n";
		$additionnals .= "\t<lang>".$_SESSION["lang"]."</lang>\n";
		
		//Get my quests
		$sql = "SELECT * FROM kuests WHERE uid=:uid OR friends LIKE :uid2 ORDER BY id DESC";
		$params = array(':uid' => $_SESSION["uid"], ':uid2' => "%,".$_SESSION["uid"].",%");
		$req = DBConnection::getLink()->prepare($sql);
		if (!$req->execute($params)) {
			$error = $req->errorInfo();
			$error = $error[2];
			Out::printOut(false, '', $error, 'SQL_ERROR');
			die;
		}
		$res = $req->fetchAll();
		$additionnals .= "\t<kuests>\n";
		for ($i = 0; $i < count($res); $i++) {
			$additionnals .= "\t\t<k guid='".$res[$i]['guid']."' r='".substr($res[$i]["friends"], 1, strlen($res[$i]["friends"])-2 )."'>\n";
			$additionnals .= "\t\t\t<t><![CDATA[".utf8_encode($res[$i]['name'])."]]></t>\n";
			$additionnals .= "\t\t\t<d><![CDATA[".utf8_encode($res[$i]['description'])."]]></d>\n";
			$additionnals .= "\t\t</k>\n";
		}
		$additionnals .= "\t</kuests>\n";
		
		
		
		//Get the sample quests
		$ids	= explode(",", $_POST["samples"]);
		$plist	= ':id_'.implode(',:id_', array_keys($ids));
		$sql	= "SELECT * FROM kuests WHERE GUID IN ($plist) ORDER BY id ASC";
		$params = array_combine(explode(",", $plist), $ids);
		$req = DBConnection::getLink()->prepare($sql);
		if (!$req->execute($params)) {
			$error = $req->errorInfo();
			$error = $error[2];
			Out::printOut(false, '', $error, 'SQL_ERROR');
			die;
		}
		$res = $req->fetchAll();
		$additionnals .= "\t<samples>\n";
		for ($i = 0; $i < count($res); $i++) {
			$additionnals .= "\t\t<s guid='".$res[$i]['guid']."' r=''>\n";
			$additionnals .= "\t\t\t<t><![CDATA[".utf8_encode($res[$i]['name'])."]]></t>\n";
			$additionnals .= "\t\t\t<d><![CDATA[".utf8_encode($res[$i]['description'])."]]></d>\n";
			$additionnals .= "\t\t</s>\n";
		}
		$additionnals .= "\t</samples>\n";
		
		
		
		//Adds friends
		$additionnals .= "\t<friends>\n";
		foreach ($friends as $row) {
			$additionnals .= "\t\t<f id='".$row['id']."'><![CDATA[".$row['name']."]]></f>\n";
		}
		$additionnals .= "\t</friends>";
		
	}else if(!isset($_POST["logout"])){
		Out::printOut(false, '', 'POST data missing', 'INCOMPLETE_FORM');
		die;
	}
	
	Out::printOut(true, $additionnals);
?>