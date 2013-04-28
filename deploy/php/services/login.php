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

	/*
	Return codes signification :

	0 - success
	1 - SQL error
	2 - POST var missing
	3 - Invalid logins
	4 - Unable to register user
	102 - token has expired
	200 - needs an update

	*/
	if(isset($_POST["logout"])) {
		session_destroy();
	}
	$additionnals = "";
	if (isset($_POST["pubkey"], $_POST["uid"])) {
		if($_SESSION["uid"] != $_POST["uid"] || $_SESSION["pubkey"] != $_POST["pubkey"]) {
			$url = "http://muxxu.com/app/xml?app=kuest&xml=user&id=".$_POST['uid']."&key=".md5("34e2f927f72b024cd9d1cf0099b097ab" . $_POST["pubkey"]);
			$xml = @file_get_contents($url);
			preg_match('/name="(.*?)"/', $xml, $matches); //*? = quantificateur non gourmand
			
			if (strpos($xml, "<error>") === false && count($matches) > 1) {
				$_SESSION["uid"]	= $_POST["uid"];
				$_SESSION["name"]	= $matches[1];
				$_SESSION["pubkey"]	= $_POST["pubkey"];
			}else {
				Out::printOut(false, '', 'Invalid UID and/or PUBKEY', 'INVALID_IDS');
				die;
			}
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
			
	}else if(!isset($_POST["logout"])){
		Out::printOut(false, '', 'POST data missing', 'INCOMPLETE_FORM');
		die;
	}
	
	$additionnals .= "<uid>".$_SESSION["uid"]."</uid>\n";
	$additionnals .= "\t<name>".$_SESSION["name"]."</name>\n";
	$additionnals .= "\t<pubkey>".$_SESSION["pubkey"]."</pubkey>\n";
	
	Out::printOut(true, $additionnals);
?>