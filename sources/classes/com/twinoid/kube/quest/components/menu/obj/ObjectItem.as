package com.twinoid.kube.quest.components.menu.obj {
	import com.twinoid.kube.quest.components.menu.AbstractListItem;
	import com.twinoid.kube.quest.vo.ObjectItemData;
	
	/**
	 * Displays an object's form
	 * 
	 * @author Francois
	 * @date 20 avr. 2013;
	 */
	public class ObjectItem extends AbstractListItem {
		
		
		
		
		/* *********** *
		 * CONSTRUCTOR *
		 * *********** */
		/**
		 * Creates an instance of <code>ObjectItem</code>.
		 */
		public function ObjectItem(data:ObjectItemData = null) {
			_data = data == null? new ObjectItemData() : data;
			super();
		}

		
		
		/* ***************** *
		 * GETTERS / SETTERS *
		 * ***************** */
		
		/**
		 * Gets the item's data
		 */
		public function get data():ObjectItemData { return _data as ObjectItemData; }



		/* ****** *
		 * PUBLIC *
		 * ****** */


		
		
		/* ******* *
		 * PRIVATE *
		 * ******* */
		
	}
}