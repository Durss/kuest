package com.twinoid.kube.quest.editor.components.menu.todo {
	import flash.events.MouseEvent;
	import com.nurun.components.button.TextAlign;
	import com.nurun.components.tile.ITileEngineItem2D;
	import com.nurun.components.tile.TileEngine2D;
	import com.twinoid.kube.quest.editor.components.buttons.ButtonKube;
	import com.twinoid.kube.quest.editor.vo.TodoData;

	import flash.display.Sprite;
	
	/**
	 * 
	 * @author Durss
	 * @date 20 juil. 2014;
	 */
	public class TodoItem extends Sprite implements ITileEngineItem2D {
		
		public static const HEIGHT:int = 20;
		private var _bt:ButtonKube;
		private var _data:TodoData;
		
		
		
		/* *********** *
		 * CONSTRUCTOR *
		 * *********** */
		/**
		 * Creates an instance of <code>TodoItem</code>.
		 */
		public function TodoItem() {
			initialize();
		}

		
		
		/* ***************** *
		 * GETTERS / SETTERS *
		 * ***************** */

		public function get data():TodoData {
			return _data;
		}



		/* ****** *
		 * PUBLIC *
		 * ****** */

		public function dispose():void {
		}

		public function populate(data:*, engineRef:TileEngine2D):void {
			_data = data as TodoData;
			
			if(_data == null) {
				visible = false;
				return;
			}
			visible = true;
			var label:String = _data.text.replace(/\r|\n/g," ").substr(0, 30);
			if(label.length < _data.text.length) label += '...';
			_bt.text = label;
			_bt.width = engineRef.width;
			_bt.height = TodoItem.HEIGHT;
		}


		
		
		/* ******* *
		 * PRIVATE *
		 * ******* */
		/**
		 * Initialize the class.
		 */
		private function initialize():void {
			_bt = addChild(new ButtonKube('test')) as ButtonKube;
			_bt.textAlign = TextAlign.LEFT;
			
			this.graphics.beginFill(0xff0000, 1);
			this.graphics.drawRect(0, 0, 5, 5);
			this.graphics.endFill();
			
			computePositions();
			
			_bt.addEventListener(MouseEvent.CLICK, clickButtonHandler);
		}
		
		/**
		 * Resizes and replaces the elements.
		 */
		private function computePositions():void {
			
		}
		
		/**
		 * Called when the button is clicked.
		 * Stops the event and fire it again from this component.
		 * This way, the FileTodosForm class will get the TodoItem
		 * as target instead of the button inside it.
		 */
		private function clickButtonHandler(event:MouseEvent):void {
			event.stopPropagation();
			dispatchEvent(event);
		}
		
	}
}