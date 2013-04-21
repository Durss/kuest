package com.twinoid.kube.quest.components.box {
	import com.twinoid.kube.quest.events.BoxEvent;
	import com.nurun.components.text.CssTextField;
	import com.nurun.structure.environnement.label.Label;
	import com.nurun.utils.pos.roundPos;
	import com.twinoid.kube.quest.controler.FrontControler;
	import com.twinoid.kube.quest.graphics.BoxEventGraphic;
	import com.twinoid.kube.quest.graphics.BoxInGraphic;
	import com.twinoid.kube.quest.graphics.BoxOutGraphic;
	import com.twinoid.kube.quest.vo.KuestEvent;

	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	[Event(name="createLink", type="com.twinoid.kube.quest.events.BoxEvent")]
	
	/**
	 * 
	 * @author Francois
	 * @date 3 févr. 2013;
	 */
	public class Box extends Sprite {
		
		private var _data:KuestEvent;
		private var _label:CssTextField;
		private var _image:Bitmap;
		private var _background:BoxEventGraphic;
		private var _dragOffset:Point;
		private var _outBox:BoxOutGraphic;
		private var _inBox:BoxInGraphic;
		
		
		
		
		/* *********** *
		 * CONSTRUCTOR *
		 * *********** */
		/**
		 * Creates an instance of <code>Box</code>.
		 */

		public function Box(data:KuestEvent = null) {
			_data = data;
			initialize();
		}

		
		
		/* ***************** *
		 * GETTERS / SETTERS *
		 * ***************** */



		/* ****** *
		 * PUBLIC *
		 * ****** */
		/**
		 * @inheritDoc
		 */
		override public function startDrag(lockCenter:Boolean = false, bounds:Rectangle = null):void {
			super.startDrag(lockCenter, bounds);
			_dragOffset.x =  x;
			_dragOffset.y =  y;
		}


		
		
		/* ******* *
		 * PRIVATE *
		 * ******* */
		/**
		 * Initialize the class.
		 */
		private function initialize():void {
			_outBox		= addChild(new BoxOutGraphic()) as BoxOutGraphic;
			_background	= addChild(new BoxEventGraphic()) as BoxEventGraphic;
			_inBox		= addChild(new BoxInGraphic()) as BoxInGraphic;
			_image		= addChild(new Bitmap()) as Bitmap;
			_label		= addChild(new CssTextField("box-label")) as CssTextField;
			
			_dragOffset = new Point();
			
			if(_data != null && _data.boxPosition != null) {
				x = _data.boxPosition.x;
				y = _data.boxPosition.y;
			}
			if(_data != null && !_data.isEmpty) {
				_label.text = _data.label;
			}else{
				_label.text = Label.getLabel("box-empty");
				_label.x = Math.round((95 - _label.width) * .5) + 5;
				_label.y = Math.round((45 - _label.height) * .5);
			}
			
			addEventListener(MouseEvent.CLICK, clickHandler);
			addEventListener(MouseEvent.ROLL_OUT, rollOutHandler);
			addEventListener(MouseEvent.ROLL_OVER, rollOverHandler);
			_inBox.addEventListener(MouseEvent.MOUSE_UP, mouseUpHandler);
			_outBox.addEventListener(MouseEvent.MOUSE_UP, mouseUpHandler);
			_inBox.addEventListener(MouseEvent.MOUSE_DOWN, mouseDownHandler);
			_outBox.addEventListener(MouseEvent.MOUSE_DOWN, mouseDownHandler);
			
			computePositions();
		}
		
		/**
		 * Called when mouse goes over the component
		 */
		private function rollOverHandler(event:MouseEvent):void {
			cacheAsBitmap = false;
		}
		
		/**
		 * Called when mouse goes out the component.
		 */
		private function rollOutHandler(event:MouseEvent):void {
			cacheAsBitmap = true;//TODO check if that's a enought optimization. If not, remove everything from holder and replace it by a bitmap snapshot
		}
		
		/**
		 * Called when the component is clicked to open the edition view
		 */
		private function clickHandler(event:MouseEvent):void {
			if(Math.abs(x-_dragOffset.x) < 5 && Math.abs(y-_dragOffset.y) < 5) {
				FrontControler.getInstance().edit(_data);
			}
		}
		
		/**
		 * Called when mouse is pressed over the in/out box
		 */
		private function mouseDownHandler(event:MouseEvent):void {
			event.stopPropagation();
			dispatchEvent(new BoxEvent(BoxEvent.CREATE_LINK));
		}
		
		/**
		 * Called when mouse is released over the in/out box
		 */
		private function mouseUpHandler(event:MouseEvent):void {
		}
		
		/**
		 * Resizes and replaces the elements.
		 */
		private function computePositions():void {
			_background.x = _inBox.width - 2;
			_outBox.x = _background.x + _background.width - 2;
			
			roundPos(_outBox);
			roundPos(_background);
		}
		
	}
}