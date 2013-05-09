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
	if (isset($_GET["title"], $_GET["description"], $GLOBALS['HTTP_RAW_POST_DATA'])) {
		//Update a kuest !
		if (isset($_GET["id"])) {
			//Check for edition rights
			$sql = "SELECT uid, dataFile FROM kuests WHERE id=:id";
			$params = array(':id' => $_GET["id"]);
			$req = DBConnection::getLink()->prepare($sql);
			if (!$req->execute($params)) {
				Out::printOut(false, '', $req->errorInfo(), 'SQL_ERROR');
				die;
			}
			$tot = $req->rowCount();
			if ($tot == 0) {
				Out::printOut(false, '', 'Kuest to edit not found.', 'EDITION_KUEST_NOT_FOUND');
				die;
			}
			
			$res = $req->fetch();
			if ($_SESSION["uid"] != $res['uid']) {
				//Not a map of ours, can't edit it.
				Out::printOut(false, '', 'Loading denied.', 'EDITION_NO_RIGHTS');
				die;
			}
			
			//Updates the kuest.
			$index = $res["dataFile"];
			if(@$fp = fopen($dir.$index.".kst", 'wb')) {
				fwrite($fp, $GLOBALS[ 'HTTP_RAW_POST_DATA' ]);
				fclose($fp);
			}
			$id = $_GET["id"];
			
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
			$sql = "INSERT into kuests (uid, name, description, dataFile) VALUES (:uid, :name, :description, :dataFile)";
			$params = array(':uid' => $_SESSION['uid'], ':name' => $_GET["title"], ':description' => $_GET["description"], ':dataFile' => $index);
			$req = DBConnection::getLink()->prepare($sql);
			if (!$req->execute($params)) {
				Out::printOut(false, '', $req->errorInfo(), 'SQL_ERROR');
				die;
			}
			$id = DBConnection::getLink()->lastInsertId();
		}
	
		$additionnals .= "<id>".$id."</id>\n";
		Out::printOut(true, $additionnals);
	
	}else {
		Out::printOut(false, '', 'POST data missing', 'INCOMPLETE_FORM');
		die;
	}
?>