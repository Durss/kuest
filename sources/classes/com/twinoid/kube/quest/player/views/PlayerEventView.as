package com.twinoid.kube.quest.player.views {
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
		private var _choice1:ButtonKube;
		private var _choice2:ButtonKube;
		private var _choice3:ButtonKube;
		private var _data:KuestEvent;
		private var _buttonToIndex:Dictionary;
		private var _next:ButtonKube;
		
		
		
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
			
			_image	= addChild(new ImageResizer(ImageResizerAlign.CENTER, true, true, 100, 100)) as ImageResizer;
			_tf		= addChild(new CssTextField("kuest-description")) as CssTextField;
			_choice1= addChild(new ButtonKube("")) as ButtonKube;
			_choice2= addChild(new ButtonKube("")) as ButtonKube;
			_choice3= addChild(new ButtonKube("")) as ButtonKube;
			_next	= addChild(new ButtonKube(Label.getLabel("player-next"))) as ButtonKube;
			
			_tf.selectable = true;
			_choice1.textAlign = TextAlign.LEFT;
			_choice2.textAlign = TextAlign.LEFT;
			_choice3.textAlign = TextAlign.LEFT;
			_buttonToIndex = new Dictionary();
			_buttonToIndex[_choice1] = 0;
			_buttonToIndex[_choice2] = 1;
			_buttonToIndex[_choice3] = 2;
			
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
			
			_choice1.width = _choice2.width = _choice3.width = -1;//Reset autosize capabilities
			if(contains(_choice1)) removeChild(_choice1);
			if(contains(_choice2)) removeChild(_choice2);
			if(contains(_choice3)) removeChild(_choice3);
			if(contains(_next)) removeChild(_next);
			if(_data.actionChoices.choices.length > 1) {
				addChild(_choice1);
				addChild(_choice2);
				_choice1.label = "● " + _data.actionChoices.choices[0];
				_choice2.label = "● " + _data.actionChoices.choices[1];
			}
			if(_data.actionChoices.choices.length > 2) {
				addChild(_choice3);
				_choice3.label = "● " + _data.actionChoices.choices[2];
			}
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
			
			PosUtils.vPlaceNext(5, _tf, _choice1, _choice2, _choice3);
			PosUtils.vPlaceNext(5, _tf, _next);
			_choice1.width = _choice2.width = _choice3.width = Math.max(_choice1.width, _choice2.width, _choice3.width) + 10;
//			PosUtils.hCenterIn(_choice1, _tf);
//			PosUtils.hCenterIn(_choice2, _tf);
//			PosUtils.hCenterIn(_choice3, _tf);
			_choice1.x = _choice2.x = _choice3.x = _next.x = _tf.x;
			
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