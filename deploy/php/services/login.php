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
	
	if (isset($_POST['simulateSession'])) {
		$_SESSION['logged'] = true;
				
		$_SESSION['logged']	= true;
		$_SESSION['lang']	= $userInfos->locale;
		$_SESSION['uid']	= $userInfos->id;
		$_SESSION['name']	= $userInfos->name;
		$_SESSION["pubkey"]	= 'nw0eChqaEhidt7gXxeA8PY1YEJAzLQq5';
		$_SESSION["friends"]= $userInfos->contacts;
	}
		
	if(!isset($_SESSION["logged"]) || $_SESSION["logged"] === false) {
		Out::printOut(false, '', 'Not connected', 'NOT_CONNECTED');
		die;
	}
	
	$additionnals = "";
	//if (isset($_POST["pubkey"], $_POST["uid"], $_POST["samples"])) {
		$sql = "SELECT * FROM kuestUsers WHERE uid=:uid";
		$params = array(':uid' => $_SESSION["uid"]);
		$req = DBConnection::getLink()->prepare($sql);
		$req->execute($params);
		$tot = $req->rowCount();
		
		//User doesn't exist
		if ($tot == 0) {
			//TODO display error !
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
			if ($res[$i]['uid'] == "0") {
				$additionnals .= "\t\t\t<isSample />\n";
			}
			$additionnals .= "\t\t</k>\n";
		}
		$additionnals .= "\t</kuests>\n";
		
		
		
		//Get the sample quests
		if(isset($_POST["samples"])) {
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
		}else {
			$res = array();
		}
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
		//*
		foreach ($_SESSION['friends'] as $row) {
			$additionnals .= "\t\t<f id='".$row->user->id."'><![CDATA[".$row->user->name."]]></f>\n";
		}
		//*/
		$additionnals .= "\t</friends>";
		
	//}
	
	Out::printOut(true, $additionnals);
?>