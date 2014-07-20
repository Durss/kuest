package com.twinoid.kube.quest.editor.components.menu.file {
	import gs.TweenLite;

	import com.nurun.components.text.CssTextField;
	import com.nurun.structure.environnement.configuration.Config;
	import com.nurun.structure.environnement.label.Label;
	import com.nurun.utils.draw.createRect;
	import com.twinoid.kube.quest.editor.utils.Closable;
	import com.twinoid.kube.quest.editor.utils.makeEscapeClosable;

	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.Event;
	
	/**
	 * 
	 * @author Francois
	 * @date 10 mai 2013;
	 */
	public class FilePublishForm extends Sprite implements Closable {
		
		private var _width:int;
		private var _closed:Boolean;
		private var _mask:Shape;
		private var _label:CssTextField;
		
		
		
		
		/* *********** *
		 * CONSTRUCTOR *
		 * *********** */
		/**
		 * Creates an instance of <code>FilePublishForm</code>.
		 */
		public function FilePublishForm(width:int) {
			_width = width;
			initialize();
		}

		
		
		/* ***************** *
		 * GETTERS / SETTERS *
		 * ***************** */
		/**
		 * @inheritDoc
		 */
		public function get isClosed():Boolean { return _closed; }
		
		/**
		 * Gets the height of the component.
		 */
		override public function get height():Number { return _mask.height; }



		/* ****** *
		 * PUBLIC *
		 * ****** */
		
		/**
		 * Toggles the open state.
		 */
		public function toggle():void {
			if(_closed) open();
			else close();
		}
		
		/**
		 * Opens the form
		 */
		public function open():void {
			if(!_closed) return;
			_closed = false;
			var e:Event = new Event(Event.RESIZE);
			TweenLite.to(_mask, .25, {scaleY:1, onUpdate:dispatchEvent, onUpdateParams:[e]});
		}
		
		/**
		 * @inheritDoc
		 */
		public function close():void {
			if(_closed) return;
			_closed = true;
			var e:Event = new Event(Event.RESIZE);
			TweenLite.to(_mask, .25, {scaleY:0, onUpdate:dispatchEvent, onUpdateParams:[e]});
		}
		
		/**
		 * Populates the component
		 */
		public function populate(id:String):void {
			_label.text = Label.getLabel("menu-file-publish-label").replace(/\{ROOT\}/gi, Config.getVariable("root")).replace(/\{ID\}/gi, id);
			computePositions();
		}


		
		
		/* ******* *
		 * PRIVATE *
		 * ******* */
		/**
		 * Initialize the class.
		 */
		private function initialize():void {
			_mask			= addChild(createRect()) as Shape;
			_label			= addChild(new CssTextField("menu-label")) as CssTextField;
			mask			= _mask;
			
			makeEscapeClosable(this);
			
			computePositions();
			
			_closed = true;
			_mask.scaleY = 0;
		}
		
		/**
		 * Resizes and replaces the elements.
		 */
		private function computePositions():void {
			graphics.clear();
			
			var margin:int = 5;
			_label.width = _width - margin * 2;
			_label.x = margin;
			
			var h:int = _label.height;
			
			_mask.graphics.clear();
			_mask.graphics.beginFill(0xff0000, .5);
			_mask.graphics.drawRect(0, 0, _width, h);
			_mask.graphics.endFill();
			
			graphics.lineStyle(0, 0x265367, 1);
			graphics.beginFill(0x2e92b8, 1);
			graphics.drawRect(0, 0, _width - 1, h - 1);
			graphics.endFill();
		}
		
	}
}