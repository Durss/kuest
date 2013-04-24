package com.twinoid.kube.quest.components.box {
	import com.nurun.utils.string.StringUtils;
	import com.nurun.components.bitmap.ImageResizer;
	import com.nurun.components.text.CssTextField;
	import com.nurun.structure.environnement.label.Label;
	import com.nurun.utils.pos.roundPos;
	import com.twinoid.kube.quest.controler.FrontControler;
	import com.twinoid.kube.quest.events.BoxEvent;
	import com.twinoid.kube.quest.graphics.BoxEventGraphic;
	import com.twinoid.kube.quest.graphics.BoxInGraphic;
	import com.twinoid.kube.quest.graphics.BoxOutGraphic;
	import com.twinoid.kube.quest.vo.KuestEvent;

	import flash.display.Sprite;
	import flash.events.Event;
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
		private var _image:ImageResizer;
		private var _background:BoxEventGraphic;
		private var _dragOffset:Point;
		private var _outBox:BoxOutGraphic;
		private var _inBox:BoxInGraphic;
		private var _links:Vector.<BoxLink>;
		
		
		
		
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
		/**
		 * Gets the component's data
		 */
		public function get data():KuestEvent { return _data; }



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
			var i:int, len:int = _links.length;
			for(i = 0; i < len; ++i) _links[i].startAutoUpdate();
		}
		/**
		 * @inheritDoc
		 */
		override public function stopDrag():void {
			super.stopDrag();
			
			var i:int, len:int = _links.length;
			for(i = 0; i < len; ++i) _links[i].stopAutoUpdate();
		}
		
		/**
		 * Adds a link's reference to the box.
		 * This provides a way to know which links should be updated when
		 * dragging the box
		 */
		public function addlink(link:BoxLink):void {
			_links.push(link);
		}
		
		/**
		 * Removes a link's reference
		 */
		public function removelink(link:BoxLink):void {
			_links.push(link);
			var i:int, len:int;
			len = _links.length;
			for(i = 0; i < len; ++i) {
				if(_links[i] == link) {
					_links.splice(i, 1);
					i --;
					len --;
				}
			}
		}



		
		
		/* ******* *
		 * PRIVATE *
		 * ******* */
		/**
		 * Initialize the class.
		 */
		private function initialize():void {
			_links		= new Vector.<BoxLink>();
			
			_outBox		= addChild(new BoxOutGraphic()) as BoxOutGraphic;
			_background	= addChild(new BoxEventGraphic()) as BoxEventGraphic;
			_inBox		= addChild(new BoxInGraphic()) as BoxInGraphic;
			_image		= addChild(new ImageResizer()) as ImageResizer;
			_label		= addChild(new CssTextField("box-label")) as CssTextField;
			
			_dragOffset = new Point();
			_label.mouseEnabled = false;
			
			if(_data != null && _data.boxPosition != null) {
				x = _data.boxPosition.x;
				y = _data.boxPosition.y;
			}
			
			if(_data != null) {
				_data.addEventListener(Event.CHANGE, dataUpdateHandler);
			}
			
			addEventListener(MouseEvent.CLICK, clickHandler);
			addEventListener(MouseEvent.ROLL_OUT, rollOutHandler);
			addEventListener(MouseEvent.ROLL_OVER, rollOverHandler);
			_inBox.addEventListener(MouseEvent.MOUSE_UP, mouseUpHandler);
			_outBox.addEventListener(MouseEvent.MOUSE_UP, mouseUpHandler);
			_inBox.addEventListener(MouseEvent.MOUSE_DOWN, mouseDownHandler);
			_outBox.addEventListener(MouseEvent.MOUSE_DOWN, mouseDownHandler);
			
			dataUpdateHandler();
		}
		
		/**
		 * Called when data changes
		 */
		private function dataUpdateHandler(event:Event = null):void {
			if(_data == null || _data.isEmpty) {
				_label.text = Label.getLabel("box-empty");
			}else{
				if(_data.image != null) {
					_image.setBitmapData(_data.image);
				}else{
					_image.clear();
				}
				if(StringUtils.trim(_data.label).length == 0) {
					_label.text = Label.getLabel("box-empty");
				}else{
					_label.text = _data.label;
				}
			}
			
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
			cacheAsBitmap = true;//TODO check if that's a sufficient optimization. If not, remove everything from holder and replace it by a bitmap snapshot
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
			_background.width = 180;
			_background.height = 75;
			_background.x = _inBox.width - 2;
			_outBox.x = _background.x + _background.width - 2;

			var margin:int = 3;
			var isImage:Boolean = _data != null && _data.image != null;
			_image.height = _image.width = _background.height - 5 - margin * 2;
			_image.x = _background.x + 5 + margin;
			_image.y = margin;
			_label.x = _image.x + _image.width + margin;
			_label.y = margin;
			_label.width = _background.width - _label.x + _background.x - margin;
			_label.height = _background.height - margin * 2;
			if(_data == null || _data.isEmpty || !isImage) {
				_label.width = _background.width;
				_label.y = Math.round((_background.height - _label.height) * .5);
				_label.x = _background.x + 5 + margin;
				_label.width = _background.width - 5 - margin * 2;
			}
			
			roundPos(_outBox);
			roundPos(_background);
		}
		
	}
}