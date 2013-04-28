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
			
			if(!$success) {
				Logger::getInstance()->log($errorID." :: ".$error."\r\n\t\tGET : ".print_r($_GET, true)."\r\n\t\tPOST : ".print_r($_POST, true));
			}
			
			echo $str;
		}
		
	}
?>