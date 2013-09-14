<?php
	if(isset($_SESSION["lang"])) 
		$lang = $_SESSION["lang"];
	else
		$lang = substr($_SERVER['HTTP_ACCEPT_LANGUAGE'], 0, 2);
	
	//Check if the application is localized in this lang or not. If not, force english.
	$availableLanguages = array('fr', 'en');
	if (!in_array($lang, $availableLanguages)) $lang = "en";
	
	//BROWSE PAGE//
	
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
	
	$loading = array();
	$loading["fr"] = "Chargement...";
	$loading["en"] = "Loading...";
	$loading = $loading[ $lang ];
	
	$noResults = array();
	$noResults["fr"] = "Aucun résultat.";
	$noResults["en"] = "No result.";
	$noResults = $noResults[ $lang ];
	
	$loadingError = array();
	$loadingError["fr"] = "Oops... une erreur est survenue durant le chargement des quêtes.<br /><button class='button' onClick='loadQuests()'><img src='/kuest/img/submit.png'/>Ré-essayer</button>";
	$loadingError["en"] = "Woops... an error has occurred while loading quests list.<br /><button class='button' onClick='loadQuests()'><img src='/kuest/img/submit.png'/>Try again</button>";
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
	
	$down_title = array();
	$down_title["fr"] = "Erreur serveur";
	$down_title["en"] = "Server error";
	$down_title = $down_title[ $lang ];
	
	
	
	//REDIRECT PAGE//
	$redirect_title = array();
	$redirect_title["fr"] = "Si vous n'êtes pas redirigé, <a href=\"http://kube.muxxu.com/?".$_SERVER['QUERY_STRING']."\" target=\"_blank\">cliquez ici</a>.";
	$redirect_title["en"] = "If you are not automatically redirected, <a href=\"http://kube.muxxu.com/?".$_SERVER['QUERY_STRING']."\" target=\"_blank\">click here</a>.";
	$redirect_title = $redirect_title[ $lang ];
	
	
	
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
	
	
	
	//ERROR PAGE//
	if (isset($_GET['e'])) {
		if ($_GET['e'] == 'cancel') {
			$error_title = array();
			$error_title["fr"] = "Connexion échouée";
			$error_title["en"] = "Connection failed";
			$error_title = $error_title[ $lang ];
			
			$error_content = array();
			$error_content["fr"] = "Vous devez autoriser l'application à accéder à vos informations pour pouvoir l'utiliser.<br /><br />Vos informations sont utilisées pour :<ul><li>Vous authentifier</li><li>Pondérer vos évaluations selon vos statistiques Kube</li></ul><br />Cliquez sur le bouton de connexion ci-dessus pour vous connecter à nouveau.";
			$error_content["en"] = "In order to use this application, you need to grant it authorization to access your personnal informations.<br /><br />Your informations will be used to :<ul><li>Authenticate</li><li>Weight your evaluations depending on your Kube's statistics</li></ul><br />Click on the button above to connect again.";
			$error_content = $error_content[ $lang ];
		
		}else 
		if ($_GET['e'] == 'dbconnect') {
		
			$error_title = array();
			$error_title["fr"] = "Erreur de connexion à la base de données";
			$error_title["en"] = "Database connection error";
			$error_title = $error_title[ $lang ];
			
			$error_content = array();
			$error_content["fr"] = "<br/><br/>La connexion à la base de données<br/>a échoué.<br />Veuillez essayez à nouveau ultérieurement !";
			$error_content["en"] = "<br/><br/><br/>Unable to connect database.<br />Please try again later !";
			$error_content = $error_content[ $lang ];
		
		}else{
		
			$error_title = array();
			$error_title["fr"] = "Erreur API";
			$error_title["en"] = "API error";
			$error_title = $error_title[ $lang ];
			
			$error_content = array();
			$error_content["fr"] = "Une erreur est survenue lors de votre connexion à l'application.<br /><br />L'API twinoid a répondu :<br /><div class='error'><i><b>".htmlentities($_GET['e'])."</b> for graph API request <b>".htmlentities($_GET['api'])."</b></i></div>";
			$error_content["en"] = "An error has occured while connecting to the application.<br /><br />Twinoid's APID has answered :<br /><div class='error'><i><b>".htmlentities($_GET['e'])."</b> for graph API request <b>".$_GET['api']."</b></i></div>";
			$error_content = $error_content[ $lang ];
		}
	}
?>