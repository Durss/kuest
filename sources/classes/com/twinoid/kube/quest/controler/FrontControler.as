package com.twinoid.kube.quest.controler {
	import flash.geom.Rectangle;
	import com.twinoid.kube.quest.model.Model;
	import com.twinoid.kube.quest.vo.CharItemData;
	import com.twinoid.kube.quest.vo.KuestEvent;
	import com.twinoid.kube.quest.vo.ObjectItemData;

	import flash.display.GraphicsPath;
	import flash.errors.IllegalOperationError;


	
	
	/**
	 * Singleton FrontControler
	 * 
	 * @author francois.dursus
	 * @date 3 mai 2012;
	 */
	public class FrontControler {
		private static var _instance:FrontControler;
		private var _model:Model;
		
		
		
		/* *********** *
		 * CONSTRUCTOR *
		 * *********** */
		/**
		 * Creates an instance of <code>FrontControler</code>.
		 */
		public function FrontControler(enforcer:SingletonEnforcer) {
			if(enforcer == null) {
				throw new IllegalOperationError("A singleton can't be instanciated. Use static accessor 'getInstance()'!");
			}
		}

		
		
		/* ***************** *
		 * GETTERS / SETTERS *
		 * ***************** */
		/**
		 * Singleton instance getter.
		 */
		public static function getInstance():FrontControler {
			if(_instance == null)_instance = new  FrontControler(new SingletonEnforcer());
			return _instance;	
		}



		/* ****** *
		 * PUBLIC *
		 * ****** */
		/**
		 * Initialize the class.
		 */
		public function initialize(model:Model):void {
			_model = model;
		}
		
		/**
		 * Adds a new entry point
		 */
		public function addEntryPoint(px:int, py:int):void {
			_model.addEntryPoint(px, py);
		}
		
		/**
		 * Starts a box edition
		 */
		public function edit(data:KuestEvent):void {
			_model.edit(data);
		}
		
		/**
		 * Cancels the current box edition
		 */
		public function cancelBoxEdition():void {
			_model.cancelBoxEdition();
		}
		
		/**
		 * Deletes a character
		 */
		public function deleteCharacter(item:CharItemData):void {
			_model.deleteCharacter(item);
		}
		
		/**
		 * Deletes an object
		 */
		public function deleteObject(item:ObjectItemData):void {
			_model.deleteObject(item);
		}
		
		/**
		 * Adds a character
		 */
		public function addCharacter():void {
			_model.addCharacter();
		}
		
		/**
		 * Adds an object
		 */
		public function addObject():void {
			_model.addObject();
		}
		
		/**
		 * Deletes a node from the kuest
		 */
		public function deleteNode(data:KuestEvent):void {
			_model.deleteNode(data);
		}
		
		/**
		 * Logs the user in.
		 */
		public function login(uid:String, pubkey:String):void {
			_model.login(uid, pubkey);
		}
		
		/**
		 * Saves the current quest
		 */
		public function save():void {
			_model.save();
		}
		
		/**
		 * Loads a quest
		 */
		public function load():void {
			_model.load();
		}
		
		/**
		 * Saves the comments to the model
		 */
		public function saveComments(drawingPaths:Vector.<GraphicsPath>, viewports:Vector.<Rectangle>):void {
			_model.saveComments(drawingPaths, viewports);
		}


		
		
		/* ******* *
		 * PRIVATE *
		 * ******* */
		
	}
}

internal class SingletonEnforcer{}