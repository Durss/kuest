<?php
	
	class Logger {
	
		private static $_instance = null;
		private $_handler;
		private $_filePath;
	
		private function __construct() {
			$this->_filePath = dirname(__FILE__)."/logs.txt";
			if (!file_exists($this->_filePath)) {
				$this->_handler = fopen($this->_filePath, "w");
			}else{
				$this->_handler = fopen($this->_filePath, "r+");
			}
		}
		
		public static function getInstance() {
			if(is_null(self::$_instance)) {
				self::$_instance = new Logger();  
			}

			return self::$_instance;
		}
		
		public function log($str) {
			file_put_contents($this->_filePath,  "\r\n(".date('d-m-y H:i:s', time()).") ".$str, FILE_APPEND);
		}
		
		public function closeFile() {
			fclose($this->_handler);
		}
	}
	
?>