<?php
	class DBConnection {
		private static $connection;
		
		public static function connect() {
			if ($_SERVER['HTTP_HOST'] == "localhost") {
				self::$connection = new PDO('mysql:host=localhost;dbname=kuest', 'root', '');
			}else {
				self::$connection = new PDO('mysql:host=mysql5-21.bdb;dbname=fevermapmysql', 'fevermapmysql', 'reyhPGwW');
			}
			
			define("SESSION_VERSION", 1);
			session_start();
			if (!isset($_SESSION["version"]) || $_SESSION["version"] != SESSION_VERSION) {
				session_unset();
				$_SESSION["version"] = SESSION_VERSION;
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