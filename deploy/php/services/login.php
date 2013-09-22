<?php
	require_once("../db/DBConnection.php");
	require_once("../utils/OAuth.php");
	require_once("../out/Out.php");
	require_once("../log/Logger.php");
	
	//Connect to database
	try {
		DBConnection::connect();
	}catch (Exception $error) {
		Out::printOut(false, '', $error->getMessage(), 'SQL_CONNECTION_FAIL');
		die;
	}
	
	//Used for standalone tests.
	//Session system is probably linked to Internet Explorer but i'm too lazy to use
	//it and log me in, so i simulate the login with a static JSON.
	//Works only localy to prevent from a huge security issue !
	//I don't want people to connect as me by just adding the simulateSession param !
	if (isset($_POST['simulateSession'])
	&& (!isset($_SESSION['logged']) || $_SESSION['logged'] === false)
	&& $_SERVER['SERVER_ADDR'] == '127.0.0.1') {
		$json = '{"name":"Durss","locale":"fr","id":48,"contacts":[{"user":{"name":"01101101","id":194333}},{"user":{"name":"AerynSun","id":12913}},{"user":{"name":"anaX","id":20153}},{"user":{"name":"Architecteur","id":9544}},{"user":{"name":"Aristocrate","id":27609}},{"user":{"name":"Arma","id":21}},{"user":{"name":"ArthurFanboy","id":147038}},{"user":{"name":"ayalti","id":36044}},{"user":{"name":"Braxer","id":16788}},{"user":{"name":"Brisespoir","id":7519}},{"user":{"name":"Bugzilla","id":148}},{"user":{"name":"Cabra_Sanguir","id":22295}},{"user":{"name":"Caouane","id":41997}},{"user":{"name":"Cerulien","id":1329}},{"user":{"name":"Charlotte","id":427608}},{"user":{"name":"Choupy","id":13420}},{"user":{"name":"Colapsydo","id":338}},{"user":{"name":"Drikky","id":21825}},{"user":{"name":"ElGuigo","id":6355}},{"user":{"name":"Eole","id":12}},{"user":{"name":"Etti","id":13191}},{"user":{"name":"excru","id":13833}},{"user":{"name":"Fenryl","id":37104}},{"user":{"name":"Flouk","id":56854}},{"user":{"name":"gghh","id":193749}},{"user":{"name":"Gluttony","id":26261}},{"user":{"name":"GreenMachine","id":8131}},{"user":{"name":"Halfman","id":607}},{"user":{"name":"hiko","id":15}},{"user":{"name":"Keikyaku","id":5985}},{"user":{"name":"LeReveur","id":45643}},{"user":{"name":"Le Gardien","id":3188352}},{"user":{"name":"Lilith","id":1875}},{"user":{"name":"Louleke","id":164332}},{"user":{"name":"lwxtz2004","id":17226}},{"user":{"name":"Lykan","id":70505}},{"user":{"name":"Maloups","id":1218}},{"user":{"name":"Mitnik","id":2585}},{"user":{"name":"MlleNolwenn","id":32215}},{"user":{"name":"Mogweed","id":18928}},{"user":{"name":"moulins","id":2009}},{"user":{"name":"Musaran","id":4030}},{"user":{"name":"newSunshine","id":111586}},{"user":{"name":"niacoliv","id":20455}},{"user":{"name":"Nourbie","id":31}},{"user":{"name":"Nymac","id":11464}},{"user":{"name":"oshyso","id":8689}},{"user":{"name":"Pafi","id":35909}},{"user":{"name":"Peanutz","id":516}},{"user":{"name":"Ponytaaa","id":3392}},{"user":{"name":"Psycause007","id":6272}},{"user":{"name":"Qosmos","id":1616}},{"user":{"name":"Random3","id":27}},{"user":{"name":"Sakuya","id":3296}},{"user":{"name":"Selliato","id":20333}},{"user":{"name":"Shusei","id":2615}},{"user":{"name":"skool","id":8}},{"user":{"name":"Smoggstudio","id":103775}},{"user":{"name":"Somberlord","id":102}},{"user":{"name":"Spirale","id":218}},{"user":{"name":"Spzr","id":40538}},{"user":{"name":"Swiks","id":52}},{"user":{"name":"Tama","id":22343}},{"user":{"name":"TheFreeStyle","id":6082}},{"user":{"name":"Tom_","id":23166}},{"user":{"name":"Tubasa","id":22773}},{"user":{"name":"ULTIMATOY","id":2284684}},{"user":{"name":"Uncherry","id":215062}},{"user":{"name":"warp","id":1}},{"user":{"name":"yoshi","id":5}},{"user":{"name":"blackmagic","id":17}},{"user":{"name":"bumdum","id":6}},{"user":{"name":"deepnight","id":2}},{"user":{"name":"Mr_Hk_","id":9}},{"user":{"name":"rhumsteack","id":75526}}]}';
		OAuth::logFromJSON(json_decode($json));
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
			$additionnals .= "\t\t<k guid='".$res[$i]['guid']."' uid='".$res[$i]['uid']."' r='".substr($res[$i]["friends"], 1, strlen($res[$i]["friends"])-2 )."'>\n";
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
			$additionnals .= "\t\t<s guid='".$res[$i]['guid']."' uid='' r=''>\n";
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