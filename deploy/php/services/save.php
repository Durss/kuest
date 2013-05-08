<?php
	require_once("../db/DBConnection.php");
	require_once("../out/Out.php");
	require_once("../log/Logger.php");
	require_once("../utils/Base62.php");
	
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
	
	$dir = "../../kuest/";
	$additionnals = "";
	if (isset($_POST["title"], $_POST["description"], $GLOBALS['HTTP_RAW_POST_DATA'])) {
	
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
		$sql = "INSERT into kuests (name, description, dataFile) VALUES (:name, :description, :dataFile)";
		$params = array(':name' => $_POST["title"], ':description' => $_POST["description"], ':dataFile' => $index);
		$req = DBConnection::getLink()->prepare($sql);
		if (!$req->execute($params)) {
			Out::printOut(false, '', $req->errorInfo(), 'SQL_ERROR');
			die;
		}
	}
	
	$additionnals .= "<id>".$index."</id>\n";
	
	Out::printOut(true, $additionnals);
?>