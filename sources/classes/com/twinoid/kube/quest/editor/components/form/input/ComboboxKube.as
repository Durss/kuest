package com.twinoid.kube.quest.editor.components.form.input {
	import com.muxxu.kub3dit.graphics.ComboboxBackgroundGraphic;
	import com.muxxu.kub3dit.graphics.ComboboxIconGraphic;
	import com.nurun.components.button.IconAlign;
	import com.nurun.components.button.TextAlign;
	import com.nurun.components.form.ComboBox;
	import com.twinoid.kube.quest.editor.components.buttons.ButtonKube;
	import com.twinoid.kube.quest.editor.components.form.ScrollbarKube;
	import flash.filters.DropShadowFilter;





	/**
	 * Fired when an item is selected
	 *
	 * @eventType com.nurun.components.form.events.ListEvent.SELECT_ITEM
	 */
	[Event(name="onSelectItem", type="com.nurun.components.form.events.ListEvent")]
	
	/**
	 * 
	 * @author Francois DURSUS for Nurun
	 * @date 7 juin 2011;
	 */
	public class ComboboxKube extends ComboBox {
		
		
		
		/* *********** *
		 * CONSTRUCTOR *
		 * *********** */
		/**
		 * Creates an instance of <code>KubeCombobox</code>.
		 */
		public function ComboboxKube(label:String, openToTop:Boolean = false) {
			super(new ButtonKube(label, new ComboboxIconGraphic()), new ScrollbarKube(), null, new ComboboxBackgroundGraphic(), openToTop);
			_list.filters = [new DropShadowFilter(2,90,0,.2,0,2,1,3)];
			ButtonKube(_button).textAlign = TextAlign.LEFT;
			ButtonKube(_button).iconAlign = IconAlign.RIGHT;
			ButtonKube(_button).iconSpacing = 10;
			autoSize = false;
			autosizeItems = true;
		}

		
		
		/* ***************** *
		 * GETTERS / SETTERS *
		 * ***************** */



		/* ****** *
		 * PUBLIC *
		 * ****** */
		/**
		 * Adds a pre-skinned item
		 */
		public function addSkinnedItem(label:String, data:*):void {
			addItem(new ComboboxItem(label), data);
		}
		
		/**
		 * Opens the list.
		 */
		override public function open():void {
			listHeight = Math.min(_list.scrollableList.heightMax, 125);
			super.open();
			_button.filters = [new DropShadowFilter(2,openToTop? 270 : 90,0,.2,0,2,1,3)];
		}
		
		/**
		 * Closes the list.
		 */
		override public function close():void {
			super.close();
			_button.filters = [];
		}


		
		
		/* ******* *
		 * PRIVATE *
		 * ******* */
		
	}
}