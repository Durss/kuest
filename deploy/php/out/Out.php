<?php
	class Out {
		
		public static function printOut($success, $additionnals = '', $error = '', $errorID = '') {
			header("Content-Type: application/xml; charset=utf-8");
			$str = "<?xml version='1.0' encoding='UTF-8'?>\n";
			$str .= "<root>\n";
			$str .= "	<result success='" . ($success? "true" : "false") . "' />\n";
			if($error && strlen($error) > 0)				$str .= "	<error id='".$errorID."'><![CDATA[".$error."]]></error>\n";
			if($additionnals && strlen($additionnals) > 0)	$str .= "	".$additionnals."\n";
			$str .= "</root>";
			
			//No logs for me on prod server 'coz i don't give shit about that :D (yeah, i'll probably regret that...)
			if(!$success && (!isset($_SESSION['uid']) || $_SESSION['uid'] != '89' || $_SERVER['HTTP_HOST'] != "localhost")) {
				Logger::getInstance()->log($errorID." :: ".$error."\r\n\t\tGET : ".print_r($_GET, true)."\r\n\t\tPOST : ".print_r($_POST, true)."\r\n\t\tSESSION : ".print_r($_SESSION, true));
			}
			
			//Close DB connection
			try {
				DBConnection::close();
			}catch (Exception $error) { }
			
			echo $str;
		}
		
	}
?>