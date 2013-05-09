package com.twinoid.kube.quest.editor.components.menu.obj {
	import com.nurun.structure.environnement.label.Label;
	import com.twinoid.kube.quest.editor.components.menu.AbstractListItem;
	import com.twinoid.kube.quest.editor.vo.ObjectItemData;
	
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
			super("menu-objects-delete-title", "menu-objects-delete-content", "deleteObject");
			_nameInput.defaultLabel = Label.getLabel("menu-objects-add-name");
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