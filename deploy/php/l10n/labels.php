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
	$menu_createButtonTT["fr"] = "Découvrez l\'éditeur de quête qui vous permettra à vous aussi de créer une quête pour le jeu Kube !";
	$menu_createButtonTT["en"] = "Discover the quest editor and create your own quest for the game Kube !";
	$menu_createButtonTT = $menu_createButtonTT[ $lang ];
	
	$menu_kuests = array();
	$menu_kuests["fr"] = "Liste des quêtes";
	$menu_kuests["en"] = "Quests list";
	$menu_kuests = $menu_kuests[ $lang ];
	
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
	
	$syncer_infoTitle = array();
	$syncer_infoTitle["fr"] = "Aide :";
	$syncer_infoTitle["en"] = "Help :";
	$syncer_infoTitle = $syncer_infoTitle[ $lang ];
	
	$syncer_infoContent = array();
	$syncer_infoContent["fr"] = "Voici les étapes à suivre pour pouvoir charger une quête dans le jeu.<br /><ul><li>Si vous utilisez Firefox, <a href='https://addons.mozilla.org/firefox/addon/greasemonkey/' target='_blank'>installez GreaseMonkey</a> et cliquez sur <a href='/kuest/js/kuest.user.js' target='_blank'>ce lien</a>.</li><li>Si vous utilisez Google Chrome, faites de même mais en installant d'abord <a href='https://chrome.google.com/webstore/detail/tampermonkey/dhdgffkkebhmkfjojejmpbldmpobfkfo' target='_blank'>TamperMonkey</a>.<br />Ou bien rendez-vous à l'adresse <b>chrome://extensions</b> et glissez déposez le fichier <a href='/kuest/js/kuest.user.js' target='_blank'>Kuest.user.js</a> dans la page.</li><li>Le script n'a pas été testé sous Opéra</li><li>Sous Internet Explorer il n'est pas possible d'installer ce script.</li></ul>Une fois le script installé, il vous suffit de cliquer sur le bouton \"<b>".$syncer_load."</b>\" ci-dessous pour commencer la quête.";
	$syncer_infoContent["en"] = "TODO";
	$syncer_infoContent = $syncer_infoContent[ $lang ];
	
	$syncer_notFoundTitle = array();
	$syncer_notFoundTitle["fr"] = "Quête introuvable";
	$syncer_notFoundTitle["en"] = "Quest not found";
	$syncer_notFoundTitle = $syncer_notFoundTitle[ $lang ];
	
	$syncer_notFoundContent = array();
	$syncer_notFoundContent["fr"] = "<img src='/kuest/img/error.png' alt='error'/> La quête que vous avez demandé n'existe pas.<br /><br />Assurez-vous que le lien qui vous a amené ici soit valide.";
	$syncer_notFoundContent["en"] = "<img src='/kuest/img/error.png' alt='error'/> Quest not found";
	$syncer_notFoundContent = $syncer_notFoundContent[ $lang ];
	
	
	
	//SYNCER PAGE//
	if(isset($_GET['e'])) {
		$error_title = array();
		$error_title["fr"] = "Erreur API";
		$error_title["en"] = "API error";
		$error_title = $error_title[ $lang ];
		
		$error_content = array();
		$error_content["fr"] = "Une erreur est survenue lors de votre connexion à l'application.<br /><br />L'API twinoid a répondu :<br /><div class='error'><i><b>".$_GET['e']."</b> for graph API request <b>".$_GET['api']."</b></i></div>";
		$error_content["en"] = "An error has occured while connecting to the application.<br /><br />Twinoid's APID has answered :<br /><div class='error'><i><b>".$_GET['e']."</b> for graph API request <b>".$_GET['api']."</b></i></div>";
		$error_content = $error_content[ $lang ];
	}
?>