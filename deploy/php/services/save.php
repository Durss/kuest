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
	if(!isset($_SESSION['kuest_uid'])) {
		Out::printOut(false, '', 'You must be logged in.', 'NOT_LOGGED');
		die;
	}
	
	if (isset($_GET["publish"])) {
		$dir = "../../kuests/published/";
	}else {
		$dir = "../../kuests/editing/";
	}
	$additionnals = "";
	if (isset($_GET["title"], $_GET["description"], $_GET["size"], $_GET["friends"], $GLOBALS['HTTP_RAW_POST_DATA'])) {
		if (strlen($GLOBALS['HTTP_RAW_POST_DATA']) != $_GET["size"]) {
			Out::printOut(false, '', 'Server didn\'t received all the data. Received ' .strlen($GLOBALS['HTTP_RAW_POST_DATA'])."bytes instead of ".$_GET["size"]." bytes.", 'MISSING_DATA_PART');
			die;
		}
		
		if (!file_exists($dir)) {
			Out::printOut(false, '', '"'.$dir.'" directory does not exist.', 'SAVE_DIRECTORY_MISSING');
			die;
		}
		
		//Update a kuest !
		if (isset($_GET["id"]) && strlen($_GET["id"]) > 0) {
			$guid = $_GET["id"];
			//Check for edition rights
			$sql = "SELECT uid, guid, dataFile, friends FROM kuests WHERE guid=:id";
			$params = array(':id' => $guid);
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
			if ($_SESSION['kuest_uid'] != $res['uid'] && strlen($res['friends']) > 0 && strpos(",".$_SESSION['kuest_uid'].",", $res['friends']) ) {
				//Not a map of ours, can't edit it.
				Out::printOut(false, '', 'Loading denied.', 'EDITION_NO_RIGHTS');
				die;
			}
			
			$owner		= $res['uid'];
			$friendsSrc	= array_filter( explode(",", $res['friends']) );
			$friendsA	= array_filter( explode(",", $_GET["friends"]) );
			$friendsA	= array_merge( $friendsSrc, $friendsA );
			if ($_SESSION['kuest_uid'] != $res['uid'])	$friendsA[] = $_SESSION['kuest_uid'];
			$friendsA	= array_unique( $friendsA );
			if (count($friendsA) == 0) $friends = "";
			else $friends = ",".implode(",", $friendsA).",";
			
			$sql = "UPDATE kuests SET name=:name, description=:description, friends=:friends WHERE guid=:id";
			$params = array(':id' => $guid, ':name' => $_GET["title"], ':description' => $_GET["description"], ':friends' => $friends);
			$req = DBConnection::getLink()->prepare($sql);
			if (!$req->execute($params)) {
				$error = $req->errorInfo();
				$error = $error[2];
				Out::printOut(false, '', $error, 'SQL_ERROR');
				die;
			}
			
			//Updates the kuest.
			$index = $res["dataFile"];
			if($fp = @fopen($dir.$index.".kst", 'wb')) {
				fwrite($fp, $GLOBALS[ 'HTTP_RAW_POST_DATA' ]);
				fclose($fp);
			}
			
			if (isset($_GET["publish"])) {
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
			// New quest !
			
			$owner = $_SESSION['kuest_uid'];
			
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
			$guid = uniqid();
			$sql = "INSERT into kuests (guid, uid, lang, name, description, dataFile, friends) VALUES (:guid, :uid, :lang, :name, :description, :dataFile, :friends)";
			$params = array('guid' => $guid, ':uid' => $_SESSION['kuest_uid'], ':lang' => $_SESSION['kuest_lang'], ':name' => $_GET["title"], ':description' => $_GET["description"], ':dataFile' => $index, ':friends' => ",".$_GET['friends'].",");
			$req = DBConnection::getLink()->prepare($sql);
			if (!$req->execute($params)) {
				$error = $req->errorInfo();
				$error = $error[2];
				Out::printOut(false, '', $error, 'SQL_ERROR');
				die;
			}
		}
	
		$additionnals .= "<guid uid='".$owner."'>".$guid."</guid>\n";
		Out::printOut(true, $additionnals);
	
	}else {
		Out::printOut(false, '', 'POST data missing', 'INCOMPLETE_FORM');
		die;
	}
?>