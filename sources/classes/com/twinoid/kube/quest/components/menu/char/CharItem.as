package com.twinoid.kube.quest.components.menu.char {
	import com.nurun.structure.environnement.label.Label;
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
			_nameInput.defaultLabel = Label.getLabel("menu-chars-add-name");
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