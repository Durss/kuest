package com.twinoid.kube.quest.editor.components.form.input {
	import com.nurun.utils.string.StringUtils;
	import gs.TweenLite;

	import com.muxxu.kub3dit.graphics.InputSkin;
	import com.nurun.components.form.Input;
	import com.nurun.components.vo.Margin;
	import com.nurun.utils.math.MathUtils;
	import com.nurun.utils.text.CssManager;

	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.ColorTransform;
	import flash.geom.Point;
	import flash.ui.Mouse;
	import flash.ui.MouseCursor;

	
	/**
	 * 
	 * @author Francois
	 */
	public class InputKube extends Input {
		
		private var _isNumeric:Boolean;
		private var _minNumValue:Number;
		private var _maxNumValue:Number;
		private var _dragOffset:Point;
		
		
		

		/* *********** *
		 * CONSTRUCTOR *
		 * *********** */
		/**
		 * Creates an instance of <code>KBInput</code>.
		 */
		public function InputKube(defaultLabel:String = "", isNumeric:Boolean = false, minNumValue:Number = 0, maxNumValue:Number = 100) {
			_maxNumValue = maxNumValue;
			_minNumValue = minNumValue;
			_isNumeric = isNumeric;
			var locMargins:Margin = new Margin(4, 2, 4, 0);
			super("input", new InputSkin(), defaultLabel, "inputDefault", locMargins);
			
			if(isNumeric) {
				textfield.restrict = "[0-9]";
				textfield.maxChars = maxNumValue.toString().length;
				width = textfield.maxChars * (parseInt(CssManager.getInstance().styleSheet.getStyle("."+style)["fontSize"])+1) + locMargins.width;
				addEventListener(Event.CHANGE, changeValueHandler);
				addEventListener(MouseEvent.MOUSE_WHEEL, mouseWheelHandler);
			}else{
				width = 10 * (parseInt(CssManager.getInstance().styleSheet.getStyle("."+style)["fontSize"])+1) + locMargins.width;
			}
			if(isNumeric) {
				addEventListener(Event.ADDED_TO_STAGE, addedToStageHandler);
			}
		}
		
		/**
		 * Make a red flash
		 */
		public function errorFlash():void {
			transform.colorTransform = new ColorTransform();
			TweenLite.from(this, .5, {tint:0xff0000});
		}


		
		
		/* ***************** *
		 * GETTERS / SETTERS *
		 * ***************** */
		/**
		 * Sets the enable state of the component.
		 */
		public function set enabled(value:Boolean):void {
			mouseEnabled = value;
			mouseChildren = value;
			textfield.tabEnabled = value;
			alpha = value? 1 : .5;
		}
		
		/**
		 * Gets the input's value as a number.
		 */
		public function get numValue():Number {
			return parseFloat(text);
		}
		
		override public function set text(value:String):void {
			if(StringUtils.trim(value).length == 0) {
				super.text = defaultLabel;
			}else{
				super.text = value;
			}
		}



		/* ****** *
		 * PUBLIC *
		 * ****** */


		
		
		/* ******* *
		 * PRIVATE *
		 * ******* */
		/**
		 * Called when the input's value changes
		 */
		private function changeValueHandler(event:Event):void {
			var v:Number = Math.round(parseFloat(text));
			v = MathUtils.restrict(v, _minNumValue, _maxNumValue);
			if(v.toString() != text) {
				event.stopPropagation();
				text = v.toString();
			}
		}
		
		/**
		 * Called when the user uses the mouse's wheel over the input
		 */
		private function mouseWheelHandler(event:MouseEvent):void {
			var v:int = parseInt(text) + event.delta/Math.abs(event.delta);
			v = MathUtils.restrict(v, _minNumValue, _maxNumValue);
			text = v.toString();
			dispatchEvent(new Event(Event.CHANGE));
		}
		
		/**
		 * Called when the stage is available.
		 */
		private function addedToStageHandler(event:Event):void {
			removeEventListener(Event.ADDED_TO_STAGE, addedToStageHandler);
			addEventListener(MouseEvent.MOUSE_DOWN, mouseDownHandler);
			addEventListener(MouseEvent.ROLL_OVER, rollHandler);
			addEventListener(MouseEvent.ROLL_OUT, rollHandler);
			stage.addEventListener(MouseEvent.MOUSE_UP, mouseUpHandler);
			
			_dragOffset = new Point();
		}

		private function rollHandler(event:MouseEvent):void {
			if (event.type == MouseEvent.ROLL_OVER) {
				Mouse.cursor = MouseCursor.HAND;
			}else{
				Mouse.cursor = MouseCursor.AUTO;
			}
		}

		private function mouseDownHandler(event:MouseEvent):void {
			_dragOffset.x = mouseX;
			_dragOffset.y = mouseY;
			addEventListener(Event.ENTER_FRAME, enterFrameHandler);
		}

		private function mouseUpHandler(event:MouseEvent):void {
			if(hasEventListener(Event.ENTER_FRAME)) {
				removeEventListener(Event.ENTER_FRAME, enterFrameHandler);
			}
		}

		private function enterFrameHandler(event:Event):void {
			var dist:Number = (mouseX - _dragOffset.x) + (mouseY - _dragOffset.y);//Math.sqrt(Math.pow(mouseX - _dragOffset.x, 2) + Math.pow(mouseY - _dragOffset.y, 2));
			var v:int = parseInt(textfield.text) + Math.round(dist);
			v = MathUtils.restrict(v, _minNumValue, _maxNumValue);
			text = v.toString();
			_dragOffset.x = mouseX;
			_dragOffset.y = mouseY;
			dispatchEvent(new Event(Event.CHANGE));
		}
		
	}
}