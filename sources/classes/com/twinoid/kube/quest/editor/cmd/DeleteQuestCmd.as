package com.twinoid.kube.quest.editor.cmd {
	import com.nurun.core.commands.events.CommandEvent;
	import com.nurun.core.commands.Command;
	import com.nurun.core.lang.boolean.parseBoolean;
	import com.nurun.structure.environnement.configuration.Config;
	import com.nurun.structure.environnement.label.Label;
	import com.nurun.utils.commands.LoadFileCmd;
	import com.twinoid.kube.quest.editor.error.KuestException;

	import flash.events.Event;
	import flash.events.IOErrorEvent;
	
	/**
	 * The DeleteQuestCmd is a concrete implementation of the ICommand interface.
	 * Its responsability is to delete a quest
	 *
	 * @author Francois
	 * @date 17 mai 2013;
	 */
	public class DeleteQuestCmd extends LoadFileCmd implements Command {

		private var _guid:String;
		
		
		
		
		/* *********** *
		 * CONSTRUCTOR *
		 * *********** */
		public function  DeleteQuestCmd() {
			super( Config.getPath("deleteWS") );
		}

		
		
		/* ***************** *
		 * GETTERS / SETTERS *
		 * ***************** */
		/**
		 * Gets the quest ID
		 */
		public function get guid():String { return _guid; }



		/* ****** *
		 * PUBLIC *
		 * ****** */
		/**
		 * Populates the component
		 */
		public function populate(guid:String):void {
			_guid = guid;
			_urlVariables["id"] = guid;
		}


		
		
		/* ******* *
		 * PRIVATE *
		 * ******* */
		/**
		 * Called when upload completes
		 */
		override protected function loadCompleteHandler(event:Event = null):void {
			trace('_loader.data: ' + (_loader.data));
			try {
				var xml:XML = new XML(_loader.data);
			}catch(error:Error) {
				throw new KuestException(error.message, "XML_FORMATING");
				return;
			}
			
			if(!parseBoolean(xml.child("result")[0].@success)) {
				throw new KuestException(Label.getLabel("exception-" + xml.child("error")[0].@id), "DELETE_ERROR");
			}else{
				var selfDelete:Boolean = xml.child("selfDelete") != undefined;
				dispatchEvent(new CommandEvent(CommandEvent.COMPLETE, selfDelete));
			}
		}
		
		/**
		 * Called if upload failled
		 */
		override protected function loadErrorHandler(event:IOErrorEvent):void {
			throw new KuestException(Label.getLabel("exception-IOERROR"), "DELETE_ERROR");
		}
	}
}
