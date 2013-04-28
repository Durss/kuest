<?php
	
	class Logger {
	
		private static $_instance = null;
		private $_handler;
		private $_content;
		private $_filePath;
	
		private function __construct() {
			$this->_filePath = dirname(__FILE__)."/logs.txt";
			if (!file_exists($this->_filePath)) {
				$this->_handler = fopen($this->_filePath, "w");
			}else{
				$this->_handler = fopen($this->_filePath, "r+");
			}
			if (filesize($this->_filePath) == 0) {
				$this->_content = "";
			}else{
				$this->_content = fread($this->_handler, filesize($this->_filePath));
			}
		}
		
		public static function getInstance() {
			if(is_null(self::$_instance)) {
				self::$_instance = new Logger();  
			}

			return self::$_instance;
		}
		
		public function log($str) {
			file_put_contents($this->_filePath,  $this->_content."\r\n(".date('d-m-y H:i:s', time()).") ".$str);
		}
		
		public function closeFile() {
			fclose($this->_handler);
		}
	}
	
?>