<?php
	require_once("../db/DBConnection.php");
	require_once("../out/Out.php");
	require_once("../log/Logger.php");
	require_once("../utils/Base62.php");
	
	/**
	 * Error codes :
	 * 
	 * SQL_CONNECTION_FAIL
	 * NOT_LOGGED
	 * SQL_ERROR
	 * INCOMPLETE_FORM
	 * EDITION_KUEST_NOT_FOUND
	 * EDITION_NO_RIGHTS
	 */
	
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
	
	if (isset($_GET["publish"])) {
		$dir = "../../kuests/published/";
	}else {
		$dir = "../../kuests/saves/";
	}
	$additionnals = "";
	if (isset($_GET["title"], $_GET["description"], $_GET["size"], $_GET["friends"], $GLOBALS['HTTP_RAW_POST_DATA'])) {
		if (strlen($GLOBALS['HTTP_RAW_POST_DATA']) != $_GET["size"]) {
			Out::printOut(false, '', 'Server didn\'t received all the data. Received ' .strlen($GLOBALS['HTTP_RAW_POST_DATA'])."bytes instead of ".$_GET["size"]." bytes.", 'MISSING_DATA_PART');
			die;
		}
		
		//Update a kuest !
		if (isset($_GET["id"]) && strlen($_GET["id"]) > 0) {
			//Check for edition rights
			$sql = "SELECT uid, guid, dataFile, friends FROM kuests WHERE id=:id";
			$params = array(':id' => $_GET["id"]);
			$req = DBConnection::getLink()->prepare($sql);
			if (!$req->execute($params)) {
				$error = $req->errorInfo();
				$error = $error[2];
				Out::printOut(false, '', $error, 'SQL_ERROR');
				die;
			}
			$tot = $req->rowCount();
			if ($tot == 0) {
				Out::printOut(false, '', 'Kuest to edit not found.', 'EDITION_KUEST_NOT_FOUND');
				die;
			}
			
			$res = $req->fetch();
			if ($_SESSION["uid"] != $res['uid'] && strpos(",".$_SESSION["uid"].",", $res['friends']) ) {
				//Not a map of ours, can't edit it.
				Out::printOut(false, '', 'Loading denied.', 'EDITION_NO_RIGHTS');
				die;
			}
			
			$friends = $_GET["friends"];
			if ($_SESSION["uid"] != $res['uid']) $friends .= ",89";
			
			$sql = "UPDATE kuests SET name=:name, description=:description, friends=:friends WHERE id=:id";
			$params = array(':id' => $_GET["id"], ':name' => $_GET["title"], ':description' => $_GET["description"], ':friends' => ",".$friends.",");
			$req = DBConnection::getLink()->prepare($sql);
			if (!$req->execute($params)) {
				$error = $req->errorInfo();
				$error = $error[2];
				Out::printOut(false, '', $error, 'SQL_ERROR');
				die;
			}
			
			//Updates the kuest.
			$index = $res["dataFile"];
			if(@$fp = fopen($dir.$index.".kst", 'wb')) {
				fwrite($fp, $GLOBALS[ 'HTTP_RAW_POST_DATA' ]);
				fclose($fp);
			}
			$id = $_GET["id"];
			if (isset($_GET["publish"])) {
				$guid = $res['guid'];
				
				//Flag as published
				$sql = "UPDATE kuests SET published=:published WHERE guid=:guid";
				$params = array('guid' => $guid, ':published' => true);
				$req = DBConnection::getLink()->prepare($sql);
				if (!$req->execute($params)) {
					$error = $req->errorInfo();
					$error = $error[2];
					Out::printOut(false, '', $error, 'SQL_ERROR');
					die;
				}
			}
			
		}else {
		
			//Create index file
			$filepath = $dir."index.txt";
			if (!file_exists($filepath)) {
				$handler = fopen($filepath, "w");
				fwrite($handler, "0");
				fclose($handler);
			}
			
			//Get next kuest index available
			$handler = fopen($filepath, "r+");
			$index = intval(fread($handler, filesize($filepath))) + 1;
			file_put_contents($filepath, $index);
			fclose($handler);
			$index = Base62::convert($index, 10, 62);
				
			//Save file
			if(@$fp = fopen($dir.$index.".kst", 'wb')) {
				fwrite($fp, $GLOBALS[ 'HTTP_RAW_POST_DATA' ]);
				fclose($fp);
			}
			
			//Insert into DB
			$sql = "INSERT into kuests (guid, uid, lang, name, description, dataFile, friends) VALUES (:guid, :uid, :lang, :name, :description, :dataFile, :friends)";
			$params = array('guid' => uniqid(), ':uid' => $_SESSION['uid'], ':lang' => $_SESSION['lang'], ':name' => $_GET["title"], ':description' => $_GET["description"], ':dataFile' => $index, ':friends' => ",".$_GET["friends"].",");
			$req = DBConnection::getLink()->prepare($sql);
			if (!$req->execute($params)) {
				$error = $req->errorInfo();
				$error = $error[2];
				Out::printOut(false, '', $error, 'SQL_ERROR');
				die;
			}
			$id = DBConnection::getLink()->lastInsertId();
		}
	
		$additionnals .= "<id>".$id."</id>\n";
		if(isset($guid)) $additionnals .= "\t<guid>".$res['guid']."</guid>\n";
		Out::printOut(true, $additionnals);
	
	}else {
		Out::printOut(false, '', 'POST data missing', 'INCOMPLETE_FORM');
		die;
	}
?>