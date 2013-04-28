package com.twinoid.kube.quest.controler {
	import com.twinoid.kube.quest.model.Model;
	import com.twinoid.kube.quest.vo.CharItemData;
	import com.twinoid.kube.quest.vo.KuestEvent;
	import com.twinoid.kube.quest.vo.ObjectItemData;

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
		 * Refreshes the objects list
		 */
		public function refreshObjectsList(list:Vector.<ObjectItemData>):void {
			_model.refreshObjectsList(list);
		}
		
		/**
		 * Refreshes the objects list
		 */
		public function refreshCharsList(list:Vector.<CharItemData>):void {
			_model.refreshCharsList(list);
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


		
		
		/* ******* *
		 * PRIVATE *
		 * ******* */
		
	}
}

internal class SingletonEnforcer{}