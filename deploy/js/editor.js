function Editor() {
	var onload = function () {
        if(lang.length == 0) {//Get browser's language if we couldn't get the user's language from Twinoid's API because ... dunno, just in case :D
            lang = (navigator.language) ? navigator.language : navigator.userLanguage;
            lang = lang.split("-")[0];
        }
        //TODO Compute this languages list via PHP depending on the folder's content.
        if(lang != "fr" && lang != "en") lang = "en";

        var flashvars = {};
        flashvars["version"] = "86";
        flashvars["configXml"] = "./xml/config.xml?v="+flashvars["version"];
        flashvars["lang"] = lang;
        var attributes = {};
        attributes["id"] = "externalDynamicContent";
        attributes["name"] = "externalDynamicContent";

        var params = {};
        params['allowFullScreen'] = 'true';
        params['allowFullScreenInteractive'] = 'true';
        params['menu'] = 'false';

        swfobject.embedSWF("/kuest/swf/application.swf?v="+flashvars["version"], "content", "100%", "100%", "11", "/kuest/swf/expressinstall.swf", flashvars, params, attributes);

        swffit.fit("externalDynamicContent", 800, 600, 3000, 3000, true, true);
	}
    
    this.setEditMode = function(editing) {
        if(editing) {
            window.onbeforeunload = function () { return prompt; }
        }else{
            window.onbeforeunload = null;
        }
    }

	addEvent(window, 'load', onload);
};