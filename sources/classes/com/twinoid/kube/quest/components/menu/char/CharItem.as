package com.twinoid.kube.quest.components.menu.char {
	import com.twinoid.kube.quest.components.menu.AbstractListItem;
	import com.twinoid.kube.quest.vo.CharItemData;
	
	/**
	 * Displays a character's form
	 * 
	 * @author Francois
	 * @date 20 avr. 2013;
	 */
	public class CharItem extends AbstractListItem {
		
		
		
		
		/* *********** *
		 * CONSTRUCTOR *
		 * *********** */
		/**
		 * Creates an instance of <code>CharItem</code>.
		 */
		public function CharItem(data:CharItemData = null) {
			_data = data == null? new CharItemData() : data;
			super();
		}

		
		
		/* ***************** *
		 * GETTERS / SETTERS *
		 * ***************** */
		
		/**
		 * Gets the item's data
		 */
		public function get data():CharItemData { return _data as CharItemData; }



		/* ****** *
		 * PUBLIC *
		 * ****** */


		
		
		/* ******* *
		 * PRIVATE *
		 * ******* */
		
	}
}