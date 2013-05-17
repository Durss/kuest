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

		private var _id:String;
		
		
		
		
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
		public function get id():String { return _id; }



		/* ****** *
		 * PUBLIC *
		 * ****** */
		/**
		 * Populates the component
		 */
		public function populate(id:String):void {
			_id = id;
			_urlVariables["id"] = id;
		}


		
		
		/* ******* *
		 * PRIVATE *
		 * ******* */
		/**
		 * Called when upload completes
		 */
		override protected function loadCompleteHandler(event:Event = null):void {
			try {
				var xml:XML = new XML(_loader.data);
			}catch(error:Error) {
				throw new KuestException(error.message, "XML_FORMATING");
				return;
			}
			
			if(!parseBoolean(xml.child("result")[0].@success)) {
				throw new KuestException(Label.getLabel("exception-" + xml.child("error")[0].@id), "DELETE_ERROR");
			}else{
				dispatchEvent(new CommandEvent(CommandEvent.COMPLETE));
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
