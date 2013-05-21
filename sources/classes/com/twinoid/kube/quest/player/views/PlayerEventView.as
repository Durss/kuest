package com.twinoid.kube.quest.player.views {
	import com.nurun.utils.vector.VectorUtils;
	import gs.TweenLite;
	import com.nurun.structure.environnement.label.Label;
	import flash.utils.Dictionary;
	import com.twinoid.kube.quest.editor.vo.ToolTipAlign;
	import com.twinoid.kube.quest.editor.events.ToolTipEvent;
	import com.nurun.components.bitmap.ImageResizer;
	import com.nurun.components.bitmap.ImageResizerAlign;
	import com.nurun.components.button.TextAlign;
	import com.nurun.components.text.CssTextField;
	import com.nurun.utils.pos.PosUtils;
	import com.twinoid.kube.quest.editor.components.buttons.ButtonKube;
	import com.twinoid.kube.quest.editor.vo.KuestEvent;
	import com.twinoid.kube.quest.player.events.DataManagerEvent;
	import com.twinoid.kube.quest.player.model.DataManager;

	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	
	[Event(name="resize", type="flash.events.Event")]
	
	/**
	 * Displays the current event
	 * 
	 * @author Francois
	 * @date 19 mai 2013;
	 */
	public class PlayerEventView extends Sprite {
		
		private var _width:int;
		private var _image:ImageResizer;
		private var _tf:CssTextField;
		private var _data:KuestEvent;
		private var _buttonToIndex:Dictionary;
		private var _next:ButtonKube;
		private var _choicesSpool:Vector.<ButtonKube>;
		
		
		
		/* *********** *
		 * CONSTRUCTOR *
		 * *********** */
		/**
		 * Creates an instance of <code>PlayerEventView</code>.
		 */
		public function PlayerEventView(width:int) {
			_width = width;
			initialize();
		}

		
		
		/* ***************** *
		 * GETTERS / SETTERS *
		 * ***************** */
		/**
		 * Gets the height of the component.
		 */
		override public function get height():Number { return visible? super.height : 0; }



		/* ****** *
		 * PUBLIC *
		 * ****** */


		
		
		/* ******* *
		 * PRIVATE *
		 * ******* */
		/**
		 * Initialize the class.
		 */
		private function initialize():void {
			visible = false;
			
			_choicesSpool = new Vector.<ButtonKube>();
			_buttonToIndex = new Dictionary();
			
			_image	= addChild(new ImageResizer(ImageResizerAlign.CENTER, true, true, 100, 100)) as ImageResizer;
			_tf		= addChild(new CssTextField("kuest-description")) as CssTextField;
			_next	= addChild(new ButtonKube(Label.getLabel("player-next"))) as ButtonKube;
			
			_tf.selectable = true;
			
			_image.defaultTweenEnabled = false;
			
			DataManager.getInstance().addEventListener(DataManagerEvent.NEW_EVENT, newEventHandler);
			computePositions();
			_image.addEventListener(MouseEvent.ROLL_OVER, rollOverImageHandler);
			addEventListener(MouseEvent.CLICK, clickHandler);
		}
		
		/**
		 * Resizes and replaces the elements.
		 */
		private function computePositions():void {
		}
		
		/**
		 * Called when a new event should be displayed
		 */
		private function newEventHandler(event:DataManagerEvent):void {
			_data = DataManager.getInstance().currentEvent;
			
			var wasVisible:Boolean = visible;
			visible = _data != null;
			if(!visible) {
				if(wasVisible) dispatchEvent(new Event(Event.RESIZE, true));
				visible = true;
				TweenLite.to(this, .01, {autoAlpha:0, delay:.35});
				return;
			}
			alpha = 1;
			
			var i:int, len:int, maxWidth:int;
			len = _choicesSpool.length;
			for(i = 0; i < len; ++i) removeChild(_choicesSpool[i]);
			
			len = _data.actionChoices.choices.length;
			for(i = 0; i < len; ++i) {
				if(_choicesSpool.length <= i) {
					_choicesSpool[i] = new ButtonKube("");
					_choicesSpool[i].textAlign = TextAlign.LEFT;
					_buttonToIndex[_choicesSpool[i]] = i;
				}
				_choicesSpool[i].width = -1;//Reset autosize capabilities
				addChild(_choicesSpool[i]);
				_choicesSpool[i].label = "● " + _data.actionChoices.choices[i];
				maxWidth = Math.max(maxWidth, _choicesSpool[i].width);
			}
			
			if(contains(_next)) removeChild(_next);
			
			if(_data.actionChoices.choices.length == 0 && _data.getChildren().length > 0) {//TODO Check for time
				addChild(_next);
			}
			
			graphics.clear();
			if(_data.actionType.getItem().image != null) {
				_image.visible = true;
				_image.setBitmapData( _data.actionType.getItem().image.getConcreteBitmapData() );
				graphics.beginFill(0x2D89B0);
				graphics.drawRect(_image.x - 2, _image.y - 2, 104, 104);
				graphics.endFill();
			}else{
				_image.visible = false;
				_image.clear();
			}
			_tf.text = _data.actionType.text;
			_tf.x = _image.visible? _image.width + 10 : 10;
			_tf.width = _image.visible? _width - _image.width - 10 : _width - 20;
			
			PosUtils.vPlaceNext(5, _tf, VectorUtils.toArray(_choicesSpool));
			PosUtils.vPlaceNext(5, _tf, _next);
			len = _choicesSpool.length;
			for(i = 0; i < len; ++i) {
				_choicesSpool[i].x = _tf.x;
				_choicesSpool[i].width = maxWidth + 10;
//				PosUtils.hCenterIn(_choicesSpool[i], _tf);
			}
			_next.x = _tf.x;
			
			dispatchEvent(new Event(Event.RESIZE, true));
		}
	
		/**
		 * Called when image is rolled over.
		 */
		private function rollOverImageHandler(event:MouseEvent):void {
			dispatchEvent(new ToolTipEvent(ToolTipEvent.OPEN, _data.actionType.getItem().name, ToolTipAlign.BOTTOM));
		}
		
		/**
		 * Called when something is clicked
		 */
		private function clickHandler(event:MouseEvent):void {
			if(_buttonToIndex[event.target] != undefined) {
				var index:int = _buttonToIndex[event.target];
				DataManager.getInstance().answer(index);
			}
			if(event.target == _next) {
				DataManager.getInstance().next();
			}
		}
		
	}
}