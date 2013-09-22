<?php
	class DBConnection {
		private static $connection;
		private static $SESSION_VERSION = 4;
		
		public static function connect() {
			if ($_SERVER['HTTP_HOST'] != "fevermap.org") {
				self::$connection = new PDO('mysql:host=localhost;dbname=kuest', 'root', '');
			}else {
				self::$connection = new PDO('mysql:host=mysql5-21.bdb;dbname=fevermapmysql', 'fevermapmysql', 'reyhPGwW');
			}
			
			if (get_magic_quotes_gpc()) {
				function stripslashes_gpc(&$value)
				{
					$value = stripslashes($value);
				}
				array_walk_recursive($_GET, 'stripslashes_gpc');
				array_walk_recursive($_POST, 'stripslashes_gpc');
				array_walk_recursive($_COOKIE, 'stripslashes_gpc');
				array_walk_recursive($_REQUEST, 'stripslashes_gpc');
			}
			
			self::initSession();
		}
		
		public static function initSession() {
			session_start();
			if (!isset($_SESSION["version"]) || $_SESSION["version"] != self::$SESSION_VERSION) {
				session_unset();
				$_SESSION["version"] = self::$SESSION_VERSION;
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