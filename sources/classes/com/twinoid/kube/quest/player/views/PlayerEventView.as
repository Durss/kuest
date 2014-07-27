package com.twinoid.kube.quest.player.views {
	import com.twinoid.kube.quest.player.utils.enrichText;
	import com.nurun.components.bitmap.ImageResizer;
	import com.nurun.components.bitmap.ImageResizerAlign;
	import com.nurun.components.button.IconAlign;
	import com.nurun.components.button.TextAlign;
	import com.nurun.components.text.CssTextField;
	import com.nurun.structure.environnement.label.Label;
	import com.nurun.utils.pos.PosUtils;
	import com.nurun.utils.vector.VectorUtils;
	import com.twinoid.kube.quest.editor.components.buttons.ButtonKube;
	import com.twinoid.kube.quest.editor.events.ToolTipEvent;
	import com.twinoid.kube.quest.editor.vo.KuestEvent;
	import com.twinoid.kube.quest.editor.vo.ToolTipAlign;
	import com.twinoid.kube.quest.graphics.MoneyIcon;
	import com.twinoid.kube.quest.player.events.DataManagerEvent;
	import com.twinoid.kube.quest.player.model.DataManager;

	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.utils.Dictionary;
	
	
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
		private var _simulatedMode:Boolean;
		
		
		
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
			_next	= addChild(new ButtonKube('')) as ButtonKube;
			
			_tf.selectable = true;
			
			_image.defaultTweenEnabled = false;
			
			DataManager.getInstance().addEventListener(DataManagerEvent.NEW_EVENT, newEventHandler);
			DataManager.getInstance().addEventListener(DataManagerEvent.SIMULATE_EVENT, newEventHandler);
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
		private function newEventHandler(event:DataManagerEvent = null):void {
			if(_data != null && _data.actionType.getItem() != null) {
				_data.actionType.getItem().image.removeEventListener(Event.CHANGE, changeImageHandler);
			}
			
			if(event != null && event.type == DataManagerEvent.SIMULATE_EVENT) {
				_simulatedMode = true;
				_next.text = Label.getLabel("player-stopSim");
				_data = DataManager.getInstance().simulatedEvent;
			}else{
				_simulatedMode = false;
				_next.text = Label.getLabel("player-next");
				_data = DataManager.getInstance().currentEvent;
			}
			var wasVisible:Boolean = visible;
			visible = _data != null;
			if(!visible) {
				alpha = 0;
				if(wasVisible) dispatchEvent(new Event(Event.RESIZE, true));
				return;
			}
			alpha = 1;
			
			//Remove choices buttons
			var i:int, len:int, maxWidth:int;
			len = _choicesSpool.length;
			for(i = 0; i < len; ++i) if(contains(_choicesSpool[i])) removeChild(_choicesSpool[i]);
			
			//Add necessary choices buttons.
			len = _data.actionChoices.choices.length;
			for(i = 0; i < len; ++i) {
				if(_choicesSpool.length <= i) {
					_choicesSpool[i] = new ButtonKube("");
					_choicesSpool[i].textAlign = TextAlign.LEFT;
					_buttonToIndex[_choicesSpool[i]] = i;
				}
				_choicesSpool[i].width = -1;//Reset autosize capabilities
				addChild(_choicesSpool[i]);
				
				if(_data.actionChoices.choicesCost != null
				&& _data.actionChoices.choicesCost.length > i
				&& _data.actionChoices.choicesCost[i] > 0) {
					if(_choicesSpool[i].icon == null) {
						_choicesSpool[i].icon = new MoneyIcon();
						_choicesSpool[i].iconAlign = IconAlign.LEFT;
						_choicesSpool[i].textAlign = TextAlign.LEFT;
						_choicesSpool[i].icon.scaleX = _choicesSpool[i].icon.scaleY = 2;
					}
					_choicesSpool[i].label = '(x'+_data.actionChoices.choicesCost[i]+')    ● ' + _data.actionChoices.choices[i].replace(/</gi, "&lt;").replace(/>/gi, "&gt;");
					_choicesSpool[i].enabled = DataManager.getInstance().money >= _data.actionChoices.choicesCost[i];
				}else{
					_choicesSpool[i].icon = null;
					_choicesSpool[i].enabled = true;
					_choicesSpool[i].textAlign = TextAlign.LEFT;
					_choicesSpool[i].label = "● " + _data.actionChoices.choices[i].replace(/</gi, "&lt;").replace(/>/gi, "&gt;");
				}
				maxWidth = Math.max(maxWidth, _choicesSpool[i].width);
			}
			
			//Add/remove next button
			if(_simulatedMode || (_data.actionChoices.choices.length == 0 && _data.getChildren().length > 0)) {//TODO Check for time
				addChild(_next);
			}else if(contains(_next)) {
				removeChild(_next);
			}
			
			//Display image
			graphics.clear();
			if (_data.actionType.getItem() != null && _data.actionType.getItem().image != null) {
				_data.actionType.getItem().image.addEventListener(Event.CHANGE, changeImageHandler);
				_image.visible = true;
				_image.setBitmapData( _data.actionType.getItem().image.getConcreteBitmapData() );
				graphics.beginFill(0x2D89B0);
				graphics.drawRect(_image.x - 2, _image.y - 2, 104, 104);
				graphics.endFill();
			}else{
				_image.visible = false;
				_image.clear();
			}
			
			if (_simulatedMode) {
				var type:String = _data.actionPlace.kubeMode? Label.getLabel('editWindow-place-kube') : Label.getLabel('editWindow-place-zone');
				_tf.text = '<i>'+type+_data.actionPlace.getAsLabel()+'</i><br />'+enrichText(_data.actionType.text);
			}else{
				_tf.text = enrichText(_data.actionType.text);
			}
			
			//Place elements
			_tf.x = _image.visible? _image.width + 10 : 10;
			_tf.width = _image.visible? _width - _image.width - 10 : _width - 20;
			
			if(_data.actionChoices.choices.length > 0) {
				PosUtils.vPlaceNext(5, _tf, VectorUtils.toArray(_choicesSpool), _next);
			}else{
				PosUtils.vPlaceNext(5, _tf, _next);
			}
			len = _choicesSpool.length;
			for(i = 0; i < len; ++i) {
				_choicesSpool[i].x = _tf.x;
				_choicesSpool[i].width = maxWidth + 10;
				_choicesSpool[i].enabled = _choicesSpool[i].enabled && !_simulatedMode;
//				PosUtils.hCenterIn(_choicesSpool[i], _tf);
			}
			_next.x = _tf.x;
			_next.validate();
			
			dispatchEvent(new Event(Event.RESIZE, true));
		}
		
		/**
		 * Called when image changes.
		 * This is usefull as images decoding might take some time and it can be displayed
		 * before actually be fully initialized. If initialized after its display, we
		 * refresh its rendering with the new image.
		 */
		private function changeImageHandler(event:Event):void {
			_image.setBitmapData( _data.actionType.getItem().image.getConcreteBitmapData() );
		}
	
		/**
		 * Called when image is rolled over.
		 */
		private function rollOverImageHandler(event:MouseEvent):void {
			if(_data == null || _data.actionType == null) return;
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
				if(_simulatedMode) {
					trace("PlayerEventView.clickHandler(event)");
					newEventHandler();
				}else{
					DataManager.getInstance().next();
				}
			}
		}
		
	}
}