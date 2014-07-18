<?php
	define('CLIENT_ID', $_SERVER['SERVER_NAME'] != 'fevermap.org'? '65' : '66');
	define('CLIENT_SECRET', $_SERVER['SERVER_NAME'] != 'fevermap.org'? 'Ekx40TWP8jagC3kBj3QBslZCjPlKMaAF' : 'HrGwVYWZLjScHvT3LjjRX9GPM7WqnBHt');
	define('REDIRECT_URI', $_SERVER['SERVER_NAME'] != 'fevermap.org'? 'http://local.kuest' : 'http://fevermap.org/kuest');

	class OAuth {

		/**
		 * Connects the user with the twinoid API
		 */
		public static function connect() {
			if (!isset($_SESSION['kuest_logged']) || $_SESSION['kuest_logged'] === 	false) {
				//If user isn't logged in, redirect to twinoid's auth
				if ((!isset($_SESSION['kuest_logged']) || $_SESSION['kuest_logged'] === false) && !isset($_GET['state'])) {
					header('location: https://twinoid.com/oauth/auth?response_type=code&client_id='.urlencode(constant('CLIENT_ID')).'&redirect_uri='.urlencode(constant('REDIRECT_URI')).'&scope=contacts&state='.urlencode($_SERVER["REQUEST_URI"]).'&access_type=online');
					die;
				}
				
				//User canceled the authorization rights
				if (isset($_GET['error']) && $_GET['error'] == 'access_denied') {
					header("location: /kuest/error?e=cancel&api=grant_access");
					die;
				}
				
				//Connects the user
				if (isset($_GET['state'])) {
					$ctx = array('http' =>
									array(
										'method' => 'POST',
										'header' => 'Content-type: application/x-www-form-urlencoded',
										'content' => "client_id=".constant('CLIENT_ID')."&client_secret=".constant('CLIENT_SECRET')."&redirect_uri=".urlencode(constant('REDIRECT_URI'))."&code=".$_GET['code']."&grant_type=authorization_code"
									)
							);
					$context = stream_context_create($ctx);
					$response = file_get_contents('https://twinoid.com/oauth/token', false, $context);
					$json = json_decode($response);
					//API error
					if (property_exists($json, 'error')) {
						header("location: /kuest/error?e=".$json->error."&api=token");
						die;
					}
					//Twinoid's down
					if ($response === false) {
						header("location: /kuest/down");
						die;
					}
					$_SESSION['kuest_access_token'] = $json->access_token;
					$_SESSION['kuest_access_token_death'] = time() + $json->expires_in;
					
					$userInfos = OAuth::call('me?fields=id,name,locale,contacts.fields(user.fields(id,name))');
					
					self::logFromJSON($userInfos);
				}
			}
			
			if (isset($_GET['state'])) {
				header('location:'.$_GET['state']);
				die;
			}
		}
		
		public static function logFromJSON($json) {
			$sql = "SELECT * FROM kuestUsers WHERE uid=:uid";
			$params = array(':uid' => $json->id);
			$req = DBConnection::getLink()->prepare($sql);
			$req->execute($params);
			$tot = $req->rowCount();
			if($tot === 0) {
				$oAuthCode = sha1($_GET["code"]);
				$sql = "INSERT INTO kuestUsers (uid, name, oAuthCode) VALUES (:uid, :name, :code)";
				$params = array(':uid' => $json->id, ':name' => $json->name, ':code' => $oAuthCode);
				$req = DBConnection::getLink()->prepare($sql);
				$req->execute($params);
			}else {
				$res = $req->fetch();
				$oAuthCode = $res['oAuthCode'];
				$sql = "UPDATE kuestUsers SET name=:name WHERE uid=:uid";
				$params = array(':uid' => $json->id, ':name' => $json->name);
				$req = DBConnection::getLink()->prepare($sql);
				$req->execute($params);
			}
			
			$_SESSION['kuest_logged']	= true;
			$_SESSION['kuest_lang']	= $json->locale;
			$_SESSION['kuest_uid']= $json->id;
			$_SESSION['kuest_name']	= $json->name;
			$_SESSION['kuest_friends']= $json->contacts;
			$_SESSION['kuest_oAuthkey']	= $oAuthCode;
			setcookie('kuestAppAuthorized_'.CLIENT_ID, 'true', time()+60*60*24*365*5);//5 years of living, fuck yeah \o/
		}
		
		
		/**
		 * Gets the user's information to finalise login
		 */
		public static function call($graphAPI) {
			//Add server cache to limit API calls?
			if (time() > $_SESSION['kuest_access_token_death']) {
				$_SESSION['kuest_logged'] = false;
				OAuth::connect();
			}
			$ctx = array('http' =>
							array(
								'method' => 'POST',
								'header' => 'Content-type: application/x-www-form-urlencoded',
								'content' => "access_token=".$_SESSION['kuest_access_token']
							)
					);
			$context = stream_context_create($ctx);
			$response = file_get_contents('http://twinoid.com/graph/'.$graphAPI, false, $context);
			$json = json_decode($response);
			
			//API error
			if (property_exists($json, 'error')) {
				header("location: /kuest/error?e=".$json->error.'&api='.$graphAPI);
				die;
			}
			//Twinoid's down
			if ($response === false) {
				header("location: /kuest/down");
				die;
			}
			
			return $json;
		}
	}
?>