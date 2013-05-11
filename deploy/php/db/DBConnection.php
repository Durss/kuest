<?php
	class DBConnection {
		private static $connection;
		
		public static function connect() {
			if ($_SERVER['HTTP_HOST'] == "localhost") {
				self::$connection = new PDO('mysql:host=localhost;dbname=kuest', 'root', '');
			}else {
				self::$connection = new PDO('mysql:host=mysql5-21.bdb;dbname=fevermapmysql', 'fevermapmysql', 'reyhPGwW');
			}
			
			session_start();
			if (!isset($_SESSION["uid"])) {
				$_SESSION["uid"] = "";
				$_SESSION["name"] = "";
				$_SESSION["pubkey"] = "";
			}
		}
		
		public static function close() {
			self::$connection = null;
		}
		
		public static function getLink() {
			return self::$connection;
		}
	}
?>