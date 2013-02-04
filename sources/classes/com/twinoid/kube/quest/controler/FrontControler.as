package com.twinoid.kube.quest.controler {
	import com.twinoid.kube.quest.vo.KuestEvent;
	import com.twinoid.kube.quest.model.Model;
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


		
		
		/* ******* *
		 * PRIVATE *
		 * ******* */
		
	}
}

internal class SingletonEnforcer{}