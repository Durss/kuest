<?php
	/**
	 * Open this script to the browser to download a CSV file containing all
	 * the labels ready to be imported in a google spreadsheet.
	 */
	$files = get_included_files();
	$isIncluded = $files[0] != __FILE__;
	
	$lang = '';
	if(isset($_SESSION['kuest_lang'])) 
		$lang = $_SESSION['kuest_lang'];
	else
		$lang = substr($_SERVER['HTTP_ACCEPT_LANGUAGE'], 0, 2);
	
	if(!$isIncluded && isset($_GET['lang'])) $lang = $_GET['lang'];
		
	//Check if the application is localized in this lang or not. If not, force english.
	$availableLanguages = array('fr', 'en');
	if (!in_array($lang, $availableLanguages)) $lang = "en";
	
	//MENU
	
	$editor_prompt = array();
	$editor_prompt["fr"] = "En quittant cette page vous perdrez des données non sauvegardées !\\rÊtes-vous certain de vouloir continuer ?";
	$editor_prompt["en"] = "You have currently unsaved data.\\rDo you really wish to leave this page ?";
	$editor_prompt = $editor_prompt[ $lang ];
	
	
	
	
	
	//MENU
	
	$menu_createButton = array();
	$menu_createButton["fr"] = "Créer une quête";
	$menu_createButton["en"] = "Create a quest";
	$menu_createButton = $menu_createButton[ $lang ];
	
	$menu_createButtonTT = array();
	$menu_createButtonTT["fr"] = "Découvrez l'éditeur de quête qui vous permettra à vous aussi de créer une quête pour le jeu Kube !";
	$menu_createButtonTT["en"] = "Discover the quest editor and create your own quest for the game Kube !";
	$menu_createButtonTT = $menu_createButtonTT[ $lang ];
	
	$menu_kuests = array();
	$menu_kuests["fr"] = "Liste des quêtes";
	$menu_kuests["en"] = "Quests list";
	$menu_kuests = $menu_kuests[ $lang ];
	
	$menu_connect = array();
	$menu_connect["fr"] = "Me connecter";
	$menu_connect["en"] = "Connect";
	$menu_connect = $menu_connect[ $lang ];
	
	$menu_history = array();
	$menu_history["fr"] = "Quêtes jouées";
	$menu_history["en"] = "Played quests";
	$menu_history = $menu_history[ $lang ];
	
	$menu_histoButtonTT = array();
	$menu_histoButtonTT["fr"] = "Consultez toutes les quêtes auxquelles vous avez déjà joué jusque là.";
	$menu_histoButtonTT["en"] = "browse the quest you played";
	$menu_histoButtonTT = $menu_histoButtonTT[ $lang ];
	
	$menu_kuestsTT = array();
	$menu_kuestsTT["fr"] = "Retour à la liste des quêtes.";
	$menu_kuestsTT["en"] = "Back to the quests list.";
	$menu_kuestsTT = $menu_kuestsTT[ $lang ];
	
	
	
	
	
	//BROWSE PAGE//
	
	$browse_search = array();
	$browse_search["fr"] = "Rechercher une quête";
	$browse_search["en"] = "Search for a quest";
	$browse_search = $browse_search[ $lang ];
	
	$browse_search = array();
	$browse_search["fr"] = "Rechercher une quête";
	$browse_search["en"] = "Search for a quest";
	$browse_search = $browse_search[ $lang ];
	
	$browse_searchPlaceholder = array();
	$browse_searchPlaceholder["fr"] = "Entrez un mot clé ou un pseudo...";
	$browse_searchPlaceholder["en"] = "Enter a keyword or a nickname...";
	$browse_searchPlaceholder = $browse_searchPlaceholder[ $lang ];
	
	$browse_searchSubmit = array();
	$browse_searchSubmit["fr"] = "Rechercher";
	$browse_searchSubmit["en"] = "Search";
	$browse_searchSubmit = $browse_searchSubmit[ $lang ];
	
	$browse_results = array();
	$browse_results["fr"] = "Résultats de la recherche";
	$browse_results["en"] = "Search results";
	$browse_results = $browse_results[ $lang ];
	
	$browse_titleLeft = array();
	$browse_titleLeft["fr"] = "Meilleures quêtes";
	$browse_titleLeft["en"] = "Best quests";
	$browse_titleLeft = $browse_titleLeft[ $lang ];
	
	$browse_titleRight = array();
	$browse_titleRight["fr"] = "Dernières quêtes créées";
	$browse_titleRight["en"] = "Last created quests";
	$browse_titleRight = $browse_titleRight[ $lang ];
	
	$browse_players = array();
	$browse_players["fr"] = "<span class='totalPlays'>Cette quête a été jouée par {TOTAL} personnes.</span>";
	$browse_players["en"] = "<span class='totalPlays'>This quest has been played by {TOTAL} players.</span>";
	$browse_players = $browse_players[ $lang ];
	
	$loading = array();
	$loading["fr"] = "Chargement...";
	$loading["en"] = "Loading...";
	$loading = $loading[ $lang ];
	
	$noResults = array();
	$noResults["fr"] = "Aucun résultat.";
	$noResults["en"] = "No result.";
	$noResults = $noResults[ $lang ];
	
	$loadingError = array();
	$loadingError["fr"] = "Oops... une erreur est survenue durant le chargement des quêtes.";
	$loadingError["en"] = "Woops... an error has occurred while loading quests list.";
	$loadingError = $loadingError[ $lang ];
	
	
	
	//HISTORY PAGE//
	
	$history_titleRight = array();
	$history_titleRight["fr"] = "Quêtes auxquelles vous avez joué";
	$history_titleRight["en"] = "Played quests";
	$history_titleRight = $history_titleRight[ $lang ];
	
	$history_noResults = array();
	$history_noResults["fr"] = "Vous n'avez joué à aucune quête<br/>pour le moment !<br /><br />Pourquoi ne pas essayer cette quête ?";
	$history_noResults["en"] = "You haven't played any quest for now !<br/><br/>Why don't you try this one ?";
	$history_noResults = $history_noResults[ $lang ];
	
	$history_complete = array();
	$history_complete["fr"] = "<strong>Vous avez terminé cette quête !</strong>";
	$history_complete["en"] = "<strong>You have complete this quest !</strong>";
	$history_complete = $history_complete[ $lang ];
	
	$history_inProgress = array();
	$history_inProgress["fr"] = "<b>Vous n'avez pas encore terminé cette quête.</b>";
	$history_inProgress["en"] = "<b>You haven't complete this quest yet.</b>";
	$history_inProgress = $history_inProgress[ $lang ];
	
	
	
	//DOWN PAGE//
	
	$down_content = array();
	$down_content["fr"] = "Twinoid est actuellement indisponible rendant cette application hors service.<br /><br />Essayez à nouveau un peu plus tard.<br /><br /><i>Désolé pour la gêne occasionnée.</i>";
	$down_content["en"] = "Twinoid is unavailable for the moment, which makes this application unusable.<br /><br />Please try again later.<br /><br /><i>Sorry for the inconvenience.</i>";
	$down_content = $down_content[ $lang ];
	if ($_SERVER['HTTP_HOST'] != "fevermap.org") {
		$down_content .= '<br /><br /><br /><span class="error"><i>Make sure PHP module "<b>php_openssl</b>" is enabled as well as apache extension "<b>ssl_module</b>"!</i></span>';
	}
	
	$down_title = array();
	$down_title["fr"] = "Erreur serveur";
	$down_title["en"] = "Server error";
	$down_title = $down_title[ $lang ];
	
	$down_tryAgain = array();
	$down_tryAgain["fr"] = "Essayer à nouveau";
	$down_tryAgain["en"] = "Try again";
	$down_tryAgain = $down_tryAgain[ $lang ];
	
	
	
	//AUTH PAGE//
	
	$auth_title = array();
	$auth_title["fr"] = "Application Kuest";
	$auth_title["en"] = "Kuest application";
	$auth_title = $auth_title[ $lang ];
	
	$auth_content = array();
	$auth_content["fr"] = "Pour utiliser <b>Kuest</b> vous devez l'autoriser à accéder à certaines de vos informations personnelles : <br/> <ul><li>votre pseudo</li><li>votre avatar</li><li>votre liste d'amis</li></ul><br/><br/><b>Kuest</b> vous permettra de jouer à des quêtes créées par la communauté ou de créer vos propres quêtes jouable directement dans le monde de kube.<br/><br/>Vous pourrez créer des <b>dialogues</b> sur des zones, faire ramasser ou utiliser des <b>objets</b>, faire gagner de l'<b>argent</b> virtuel pour acheter des indices ou objets, et bien plus encore.<br />N'hésitez plus et essayez-vous à kuest en vous y connectant !";
	$auth_content["en"] = "To be able to use <b>Kuest</b> you need to authorize it to access some of your private details :<br /><ul><li>your nickname</li><li>your avatar</li><li>your friends list</li></ul><br/><br/><b>Kuest</b> will allow you to play quest created by the community or to create your own quests playable right in the kube's world.<br /><br />You'll be able to create <b>dialogues</b> on any zone of the game, give <b>objects</b> to the player or ask him to use some, give <b>money</b> to the player so he can buy hints or objects, and even more...<br />Try <b>Kuest</b> now by connecting to it !";
	$auth_content = $auth_content[ $lang ];
	
	
	
	//REDIRECT PAGE//
	$redirect_title = array();
	$redirect_title["fr"] = "Si vous n'êtes pas redirigé, <a href=\"{URL}\" target=\"_blank\">cliquez ici</a>.";
	$redirect_title["en"] = "If you are not automatically redirected, <a href=\"{URL}\" target=\"_blank\">click here</a>.";
	$redirect_title = $redirect_title[ $lang ];
	$redirect_title = str_replace('{URL}', 'http://kube.muxxu.com/?'.$_SERVER['QUERY_STRING'], $redirect_title);
	
	
	
	//SYNCER PAGE//
	
	$syncer_description = array();
	$syncer_description["fr"] = "<strong class='collapser collapserOpen'>Description de la quête :</strong>";
	$syncer_description["en"] = "<strong class='collapser collapserOpen'>Quest description :</strong>";
	$syncer_description = $syncer_description[ $lang ];
	
	$syncer_load = array();
	$syncer_load["fr"] = "Lancer cette quête";
	$syncer_load["en"] = "Launch this quest";
	$syncer_load = $syncer_load[ $lang ];
	
	$syncer_installScript = array();
	$syncer_installScript["fr"] = "Installer le script Kuest";
	$syncer_installScript["en"] = "Install script Kuest";
	$syncer_installScript = $syncer_installScript[ $lang ];
	
	$syncer_installGM = array();
	$syncer_installGM["fr"] = "Installer GreaseMonkey";
	$syncer_installGM["en"] = "Install GreaseMonkey";
	$syncer_installGM = $syncer_installGM[ $lang ];
	
	$syncer_installTM = array();
	$syncer_installTM["fr"] = "Installer TamperMonkey";
	$syncer_installTM["en"] = "Install TamperMonkey ";
	$syncer_installTM = $syncer_installTM[ $lang ];
	
	$syncer_installInstructions = array();
	$syncer_installInstructions["fr"] = "<img src='/kuest/img/warning.png' alt='warning' />Pour jouer à cette quête, installer l'extension <span id='extension-GM'><a href='https://addons.mozilla.org/firefox/addon/greasemonkey/' target='_blank'>GreaseMonkey</a></span><span id='extension-TM'><a href='https://chrome.google.com/webstore/detail/tampermonkey/dhdgffkkebhmkfjojejmpbldmpobfkfo' target='_blank'>TamperMonkey</a></span> ainsi que le script <b>Kuest</b> :";
	$syncer_installInstructions["en"] = "<img src='/kuest/img/warning.png' alt='warning' />To play this quest, install <span id='extension-GM'><a href='https://addons.mozilla.org/firefox/addon/greasemonkey/' target='_blank'>GreaseMonkey</a></span><span id='extension-TM'><a href='https://chrome.google.com/webstore/detail/tampermonkey/dhdgffkkebhmkfjojejmpbldmpobfkfo' target='_blank'>TamperMonkey</a></span> as well as the script <b>Kuest</b> :";
	$syncer_installInstructions = $syncer_installInstructions[ $lang ];
	
	$syncer_infoTitle = array();
	$syncer_infoTitle["fr"] = "Aide :";
	$syncer_infoTitle["en"] = "Help :";
	$syncer_infoTitle = $syncer_infoTitle[ $lang ];
	
	$syncer_infoContent = array();
	$syncer_infoContent["fr"] = "Voici les étapes à suivre pour pouvoir charger une quête dans le jeu.<br /><ul><li>Si vous utilisez <b>Firefox</b>, installez <a href='https://addons.mozilla.org/firefox/addon/greasemonkey/' target='_blank'>GreaseMonkey</a> et cliquez sur <a href='/kuest/js/kuest.user.js' target='_blank'>ce lien</a>.</li><li>Si vous utilisez <b>Google Chrome</b>, installez <a href='https://chrome.google.com/webstore/detail/tampermonkey/dhdgffkkebhmkfjojejmpbldmpobfkfo' target='_blank'>TamperMonkey</a> puis cliquez sur <a href='/kuest/js/kuest.user.js' target='_blank'>ce lien</a>.<br />Ou bien rendez-vous à l'adresse <b>chrome://extensions</b> et glissez déposez le fichier <a href='/kuest/js/kuest.user.js' target='_blank'>Kuest.user.js</a> dans la page.</li><li>Le script n'a pas été testé sous <b>Opéra</b></li><li>Sous <b>Internet Explorer</b> il n'est pas possible d'installer ce script.</li></ul>Une fois le script installé, il vous suffit de cliquer sur le bouton \"<b>".$syncer_load."</b>\" ci-dessous pour commencer la quête.";
	$syncer_infoContent["en"] = "Here are the steps to be able to play a quest.<br /><ul><li>If you use <b>Firefox</b>, <a href='https://addons.mozilla.org/firefox/addon/greasemonkey/' target='_blank'>install GreaseMonkey</a> then click on <a href='/kuest/js/kuest.user.js' target='_blank'>that link</a>.</li><li>If you use <b>Google Chrome</b>, install <a href='https://chrome.google.com/webstore/detail/tampermonkey/dhdgffkkebhmkfjojejmpbldmpobfkfo' target='_blank'>TamperMonkey</a> then click on <a href='/kuest/js/kuest.user.js' target='_blank'>that link</a>.<br />Or go to the page <b>chrome://extensions</b> then drag&drop the file <a href='/kuest/js/kuest.user.js' target='_blank'>Kuest.user.js</a> inside the page.</li><li>The script hasen't been tested on <b>Opera</b></li><li><b>Internet Explorer</b> doesn't support the script.</li></ul>Once installed, you only need to click on \"<b>".$syncer_load."</b>\" under to start the quest.";
	$syncer_infoContent = $syncer_infoContent[ $lang ];
	
	$syncer_notFoundTitle = array();
	$syncer_notFoundTitle["fr"] = "Quête introuvable";
	$syncer_notFoundTitle["en"] = "Quest not found";
	$syncer_notFoundTitle = $syncer_notFoundTitle[ $lang ];
	
	$syncer_notFoundContent = array();
	$syncer_notFoundContent["fr"] = "<img src='/kuest/img/error.png' alt='error'/> La quête que vous avez demandé n'existe pas.<br /><br />Assurez-vous que le lien qui vous a amené ici soit valide.";
	$syncer_notFoundContent["en"] = "<img src='/kuest/img/error.png' alt='error'/> Quest not found";
	$syncer_notFoundContent = $syncer_notFoundContent[ $lang ];
	
	$syncer_players = array();
	$syncer_players["fr"] = "Joueurs ayant terminé la quête";
	$syncer_players["en"] = "Players that finished this quest";
	$syncer_players= $syncer_players[ $lang ];
	
	$syncer_playersContent = array();
	$syncer_playersContent["fr"] = "Personne n'a terminé cette quête pour le moment.<br />Une quête est considérée comme terminée lorsque le joueur l'a évalué.";
	$syncer_playersContent["en"] = "Nobody has finished this quest yet.<br />A quest is considered as complete when the player evaluated it.";
	$syncer_playersContent= $syncer_playersContent[ $lang ];
	
	
	
	//ERROR PAGE//
	if (isset($_GET['e']) || !$isIncluded) {
		if (!$isIncluded || $_GET['e'] == 'cancel') {
			$error_title = array();
			$error_title["fr"] = "Connexion échouée";
			$error_title["en"] = "Connection failed";
			$error_title = $error_title[ $lang ];
			
			$error_content = array();
			$error_content["fr"] = "Vous devez autoriser l'application à accéder à vos informations pour pouvoir l'utiliser.<br /><br />Vos informations sont utilisées pour :<ul><li>Vous authentifier</li><li>Sauvegarder votre progression</li><li>Vous permettre de créer des quêtes</li><li>Pondérer vos évaluations selon vos statistiques Kube</li></ul><br />Cliquez sur le bouton de connexion ci-dessus pour vous connecter à nouveau.";
			$error_content["en"] = "In order to use this application, you need to grant it authorization to access your personnal informations.<br /><br />Your informations will be used to :<ul><li>Authenticate</li><li>Weight your evaluations depending on your Kube's statistics</li></ul><br />Click on the button above to connect again.";
			$error_content = $error_content[ $lang ];
			
			$error_auth_title = $error_title;
			$error_auth_content = $error_content;
		
		} 
		
		if (!$isIncluded || $_GET['e'] == 'dbconnect') {
		
			$error_title = array();
			$error_title["fr"] = "Erreur de connexion à la base de données";
			$error_title["en"] = "Database connection error";
			$error_title = $error_title[ $lang ];
			
			$error_content = array();
			$error_content["fr"] = "<br/><br/>La connexion à la base de données<br/>a échoué.<br />Veuillez essayez à nouveau ultérieurement !";
			$error_content["en"] = "<br/><br/><br/>Unable to connect database.<br />Please try again later !";
			$error_content = $error_content[ $lang ];
			
			$error_db_title = $error_title;
			$error_db_content = $error_content;
		
		}
		
		if(!$isIncluded || ($_GET['e'] != 'dbconnect' && $_GET['e'] != 'cancel')){
			if (!isset($_GET['e'])) {
				$_GET['e'] = '{CODE}';
				$_GET['api'] = '{API}';
			}
			$error_title = array();
			$error_title["fr"] = "Erreur API";
			$error_title["en"] = "API error";
			$error_title = $error_title[ $lang ];
			
			$error_content = array();
			$error_content["fr"] = "Une erreur est survenue lors de votre connexion à l'application.<br /><br />L'API twinoid a répondu :<br /><div class='error'><i><b>{CODE}</b> for graph API request <b>{API}</b></i></div>";
			$error_content["en"] = "An error has occured while connecting to the application.<br /><br />Twinoid's API has answered :<br /><div class='error'><i><b>{CODE}</b> for graph API request <b>{API}</b></i></div>";
			$error_content = $error_content[ $lang ];
			
			if(isset($_GET['e']))
				$error_content = str_replace('{CODE}', $_GET['e'], $error_content);
			if(isset($_GET['api']))
				$error_content = str_replace('{API}', $_GET['api'], $error_content);
			
			$error_api_title = $error_title;
			$error_api_content = $error_content;
		}
	}
	
	//Allow CSV export of the labels
	if(!$isIncluded) {
		header('Content-Type: text/html; charset=utf-8');
		header("Expires: 0");
		header("Cache-Control: must-revalidate, post-check=0, pre-check=0");
		header("Cache-Control: private",false);
		header("Content-Type: application/octet-stream");
		header("Content-Disposition: attachment; filename=\"serverLabels.csv\";" );
		header("Content-Transfer-Encoding: binary");

		$vars = get_defined_vars();
		$ignoredVars = array('GLOBALS', 'vars', 'ignoredVars', 'key', 'value', 'files', 'isIncluded', 'lang', 'availableLanguages');
		foreach($vars as $key => $value) {
			if(substr($key, 0 , 1) == '_') continue;//ignore vars starting by "_"
			if(in_array($key, $ignoredVars)) continue;
			
			echo '"'.str_replace('"', '""', $key).'","","'.str_replace('"', '""', $value).'"'."\n";
		}
	}
?>