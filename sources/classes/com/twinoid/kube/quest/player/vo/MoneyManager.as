package com.twinoid.kube.quest.player.vo {
	import com.twinoid.kube.quest.editor.vo.ActionMoney;
	import com.twinoid.kube.quest.editor.vo.KuestEvent;
	
	/**
	 * 
	 * @author Francois
	 * @date 21 déc. 2013;
	 */
	public class MoneyManager {
		
		private var _money:int = 0;
		
		
		
		/* *********** *
		 * CONSTRUCTOR *
		 * *********** */
		/**
		 * Creates an instance of <code>MoneyManager</code>.
		 */
		public function MoneyManager() {
			
		}

		
		
		/* ***************** *
		 * GETTERS / SETTERS *
		 * ***************** */

		public function get money():int {
			return _money;
		}



		/* ****** *
		 * PUBLIC *
		 * ****** */
		
		/**
		 * Checks if an event is accessible or not.
		 */
		public function isEventAccessible(event:KuestEvent):Boolean {
			if(event.actionMoney == null || !event.actionMoney.unlockConditionEnabled) return true;
			
			switch(event.actionMoney.unlockCondition){
				case ActionMoney.EQUALS:
					return _money == event.actionMoney.unlockValue;
					break;
				case ActionMoney.GREATER_EQUALS:
					return _money >= event.actionMoney.unlockValue;
					break;
				case ActionMoney.LOWER:
					return _money < event.actionMoney.unlockValue;
					break;
				case ActionMoney.LOWER_EQUALS:
					return _money <= event.actionMoney.unlockValue;
					break;
				default:
				case ActionMoney.GREATER:
					return _money > event.actionMoney.unlockValue;
					break;
			}
			return true;
		}
		
		/**
		 * Called when an event completes
		 * 
		 * @return if the money value has changed
		 */
		public function selectEvent(event:KuestEvent):Boolean {
			if(event.actionMoney != null) {
				if(event.actionMoney.kuborsEarned != 0) {
					_money += event.actionMoney.kuborsEarned;
					return true;
				}
			}
			return false;
		}
		
		/**
		 * Called when the user makes a choice
		 * 
		 * @param cost		cost of the choice
		 */
		public function answerChoice(cost:int):void {
			_money -= cost;
		}
		
		/**
		 * Exports the data as anonymous object ready to be stored to a ByteArray.
		 * These data will then be imported back with importData().
		 * Basically, the exported data will look like this :
		 * 	{
		 * 		money:xxx
		 *  }
		 */
		public function exportData(version:uint):Object {
			version;
			return {money:_money};
		}
		
		/**
		 * Imports data that have been previously exported by exportData() .
		 */
		public function importData(data:Object, version:uint):void {
			switch(version){
				case SaveVersion.V1:
					_money = data['money'];
					break;
				default:
			}
		}

		
		/**
		 * Resets the money
		 */
		public function reset():void {
			_money = 0;
		}


		
		
		/* ******* *
		 * PRIVATE *
		 * ******* */
		
	}
}