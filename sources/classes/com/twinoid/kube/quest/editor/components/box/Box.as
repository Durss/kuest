package com.twinoid.kube.quest.editor.components.box {
	import gs.TweenLite;

	import com.muxxu.kub3dit.graphics.CancelIcon;
	import com.muxxu.kub3dit.graphics.DuplicateIcon;
	import com.nurun.components.bitmap.ImageResizer;
	import com.nurun.components.button.GraphicButton;
	import com.nurun.components.button.IconAlign;
	import com.nurun.components.button.visitors.applyDefaultFrameVisitorNoTween;
	import com.nurun.components.text.CssTextField;
	import com.nurun.components.vo.Margin;
	import com.nurun.structure.environnement.label.Label;
	import com.nurun.utils.pos.PosUtils;
	import com.nurun.utils.pos.roundPos;
	import com.nurun.utils.string.StringUtils;
	import com.nurun.utils.vector.VectorUtils;
	import com.twinoid.kube.quest.editor.controler.FrontControler;
	import com.twinoid.kube.quest.editor.events.BoxEvent;
	import com.twinoid.kube.quest.editor.events.ToolTipEvent;
	import com.twinoid.kube.quest.editor.utils.hexToMatrix;
	import com.twinoid.kube.quest.editor.utils.prompt;
	import com.twinoid.kube.quest.editor.views.BackgroundView;
	import com.twinoid.kube.quest.editor.vo.ActionType;
	import com.twinoid.kube.quest.editor.vo.KuestEvent;
	import com.twinoid.kube.quest.editor.vo.Point3D;
	import com.twinoid.kube.quest.editor.vo.ToolTipAlign;
	import com.twinoid.kube.quest.graphics.BoxEventGraphic;
	import com.twinoid.kube.quest.graphics.BoxInGraphic;
	import com.twinoid.kube.quest.graphics.BoxLinkIconGraphic;
	import com.twinoid.kube.quest.graphics.BoxOutGraphic;
	import com.twinoid.kube.quest.graphics.BoxTimerEventGraphic;
	import com.twinoid.kube.quest.graphics.ClearBoxGraphic;
	import com.twinoid.kube.quest.graphics.MoneyIndicationIconGraphic;
	import com.twinoid.kube.quest.graphics.TakePutIconGraphic;

	import flash.display.InteractiveObject;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.filters.ColorMatrixFilter;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.utils.Dictionary;


	
	[Event(name="createLink", type="com.twinoid.kube.quest.editor.events.BoxEvent")]
	[Event(name="delete", type="com.twinoid.kube.quest.editor.events.BoxEvent")]
	
	/**
	 * Displays a Box instance inside the board.
	 * 
	 * @author Francois
	 * @date 3 févr. 2013;
	 */
	public class Box extends Sprite {
		
		public static const NUM_CHOICES:int = 6;
		public static const COLS:int = 8;
		public static const ROWS:int = 3;
		
		private var _data:KuestEvent;
		private var _label:CssTextField;
		private var _image:ImageResizer;
		private var _background:BoxEventGraphic;
		private var _dragOffset:Point;
		private var _inBox:GraphicButton;
		private var _links:Vector.<BoxLink>;
		private var _timeIcon:BoxTimerEventGraphic;
		private var _deleteBt:GraphicButton;
		private var _outBoxes:Vector.<GraphicButton>;
		private var _outBoxToIndex:Dictionary;
		private var _debugMode:Boolean;
		private var _takePut:TakePutIconGraphic;
		private var _money : MoneyIndicationIconGraphic;
		private var _copyBt : GraphicButton;
		
		
		
		
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
		
		/**
		 * Gets the width of the component.
		 */
		override public function get width():Number { return _outBoxes[0].x + _outBoxes[0].width; }
		
		/**
		 * Gets the height of the component.
		 */
		override public function get height():Number { return _inBox.height; }
		
		/**
		 * Sets the debug mode state.
		 */
		public function get debugMode():Boolean { return _debugMode; }

		/**
		 * Gets the debug mode state.
		 */
		public function set debugMode(value:Boolean):void {
			_debugMode = value;
			mouseChildren = !_debugMode;
		}
		
		/**
		 * Gets the links related to this event
		 */
		public function get links():Vector.<BoxLink> { return _links; }



		/* ****** *
		 * PUBLIC *
		 * ****** */
		/**
		 * @inheritDoc
		 */
		override public function startDrag(lockCenter:Boolean = false, bounds:Rectangle = null):void {
			lockCenter, bounds;//avoid unused warnigns from FDT
			//Disabled the default startDrag behavior to prevent from lags between
			//the box and its link. Also mouse was sometimes "loosing" the box.
//			super.startDrag(lockCenter, bounds);
			_dragOffset.x =  stage.mouseX;
			_dragOffset.y =  stage.mouseY;
			var i:int, len:int = _links.length;
			for(i = 0; i < len; ++i) _links[i].startAutoUpdate();
		}
		/**
		 * @inheritDoc
		 */
		override public function stopDrag():void {
//			super.stopDrag();
			
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
		
		/**
		 * Refreshes the boxe's rendering.
		 * Called when data changes.
		 */
		public function render(event:Event = null):void {
			if(_data == null || _data.isEmpty()) {
				_label.text = Label.getLabel("box-empty");
				_takePut.visible = false;
				_money.visible = false;
//				if(_data != null) _label.text += _data.guid;
			}else{
				//Image
				if(_data.getImage() != null) {
					_image.setBitmapData(_data.getImage());
					_image.validate();
				}else{
					_image.clear();
				}
				//Labels
				if(StringUtils.trim(_data.getLabel()).length == 0) {
					_label.text = Label.getLabel("box-empty");
				}else{
					_label.text = _data.getLabel();
				}
				
				//Time display 
				if(!_data.actionDate.getAlwaysEnabled()) {
					addChild(_timeIcon);
				}else {
					if(contains(_timeIcon)) removeChild(_timeIcon);
				}
				
				//Colorize box
				if(_data.endsQuest) {
					_background.filters = _timeIcon.filters = _deleteBt.background.filters = _copyBt.background.filters = [new ColorMatrixFilter([0.37878480553627014,1.6029037237167358,-1.051688551902771,0,11.885000228881836,0.01224497240036726,0.5073512196540833,0.4104038178920746,0,11.885000228881836,1.1350740194320679,-0.12359676510095596,-0.08147723972797394,0,11.885000228881836,0,0,0,1,0])];
				}else
				if(_data.loosesQuest) {
					_background.filters = _timeIcon.filters = _deleteBt.background.filters = _copyBt.background.filters = [new ColorMatrixFilter([-0.8141878247261047,1.2870899438858032,0.45709773898124695,0,-11.364999771118164,0.46661293506622314,0.409849613904953,0.05353740602731705,0,-11.36500072479248,0.15669459104537964,1.7636311054229736,-0.9903256893157959,0,-11.364999771118164,0,0,0,1,0])];
				}else
				if(_data.startsTree) {
					_background.filters = _timeIcon.filters = _deleteBt.background.filters = _copyBt.background.filters = [new ColorMatrixFilter([-0.5876463055610657,2.2064313888549805,-0.61878502368927,0,51,0.30404403805732727,0.30756938457489014,0.3883865475654602,0,51,1.0775119066238403,1.017120599746704,-1.0946322679519653,0,51.000003814697266,0,0,0,1,0])];
				}else{
					_background.filters = _timeIcon.filters = _deleteBt.background.filters = _copyBt.background.filters = [];
				}
				
				//============ LINKS MANAGEMNT ============
				var i:int, len:int;
				var wasLinkHere:Array = [];
				len = _outBoxes.length;
				for(i = 1; i < len; ++i) {
					wasLinkHere[i] = contains(_outBoxes[i]);
					if(contains(_outBoxes[i])) removeChild(_outBoxes[i]);
				}
				
				//Define how much links output should be displayed
				if(_data.actionChoices != null) {
					var numChoices:int = Math.max(1, _data.actionChoices.choices.length);
					for(i = 1; i < numChoices; ++i) {
						MovieClip(_outBoxes[i].icon).gotoAndStop(_data.actionChoices.choicesCost.length > i && _data.actionChoices.choicesCost[i] != 0? 2 : 1);
						addChildAt(_outBoxes[i], getChildIndex(_outBoxes[i-1])+1);
					}
				}
				
				if(_data.actionChoices != null && _data.actionChoices.choicesCost.length > 0){
					MovieClip(_outBoxes[0].icon).gotoAndStop(_data.actionChoices.choicesCost.length > 0 && _data.actionChoices.choicesCost[0] != 0? 2 : 1);
				}else{
					MovieClip(_outBoxes[0].icon).gotoAndStop(1);
				}
				
				//If choices have been deleted, some links might have to be cleared as well
				var j:int, lenJ:int;
				lenJ = _links.length;
				for(i = 1; i < len; ++i) {
					if(wasLinkHere[i] && !contains(_outBoxes[i])) {
						for(j = 0; j < lenJ; ++j) {
							if(_links[j].choiceIndex == i) _links[j].deleteLink();
						}
					}
				}
				
				//Object indicator
				_takePut.visible = _data.actionType.type == ActionType.TYPE_OBJECT && (_data.actionType.takeMode || _data.actionType.putMode);
				_money.visible = _data.actionMoney != null && _data.actionMoney.kuborsEarned != 0;
				_takePut.gotoAndStop(_data.actionType.takeMode? 2 : 1);
			}
				
			//Render the box.
			computePositions();
			
			//Update the links rendering in case choices have been modified.
			//As the links update depending on the box's state, we need to render
			//the box before doing this. That's why "computePositions" is called before.
			len = _links.length;
			for(i = 0; i < len; ++i) _links[i].update();
		}
		
		/**
		 * Gets the Y offset position of an output button by its choice index.
		 */
		public function getChoiceIndexPosition(index:int):int {
			return _outBoxes[index].y + _outBoxes[index].height * .5;
		}



		
		
		/* ******* *
		 * PRIVATE *
		 * ******* */
		/**
		 * Initialize the class.
		 */
		private function initialize():void {
			_links		= new Vector.<BoxLink>();
			_outBoxes	= new Vector.<GraphicButton>();
			_outBoxToIndex = new Dictionary();
			var i:int, len:int;
			var colors:Array = [0xE95B5B, 0xff8800, 0xffff00, 0xb3ff00, 0x00ff66, 0x0093ff];
			len = NUM_CHOICES;
			for(i = 0; i < len; ++i) {
				_outBoxes[i] = new GraphicButton(new BoxOutGraphic(), new BoxLinkIconGraphic());
				_outBoxes[i].width = 30;
				MovieClip(_outBoxes[i].icon).gotoAndStop(1);
				_outBoxes[i].iconAlign = IconAlign.LEFT;
				_outBoxes[i].contentMargin = new Margin(10, 0, 0, 0);
				_outBoxes[i].background.filters = [new ColorMatrixFilter(hexToMatrix( colors[i] ))];
				_outBoxes[i].addEventListener(MouseEvent.MOUSE_DOWN, mouseDownHandler);
				_outBoxes[i].addEventListener(MouseEvent.ROLL_OVER, overOutBoxHandler);
				applyDefaultFrameVisitorNoTween(_outBoxes[i], _outBoxes[i].background);
				_outBoxToIndex[ _outBoxes[i] ] = i;
				if(i == 0) addChild(_outBoxes[i]);
			}
			_background	= addChild(new BoxEventGraphic()) as BoxEventGraphic;
			_inBox		= addChild(new GraphicButton(new BoxInGraphic(), new BoxLinkIconGraphic())) as GraphicButton;
			_image		= addChild(new ImageResizer()) as ImageResizer;
			_label		= addChild(new CssTextField("box-label")) as CssTextField;
			_takePut	= addChild(new TakePutIconGraphic()) as TakePutIconGraphic;
			_money		= addChild(new MoneyIndicationIconGraphic()) as MoneyIndicationIconGraphic;
			_deleteBt	= new GraphicButton(new ClearBoxGraphic(), new CancelIcon());
			_copyBt		= new GraphicButton(new ClearBoxGraphic(), new DuplicateIcon());
			_timeIcon	= new BoxTimerEventGraphic();
			
			MovieClip(_inBox.icon).gotoAndStop(1);
			
			_dragOffset = new Point();
			_label.mouseEnabled = false;
			
			applyDefaultFrameVisitorNoTween(_deleteBt, _deleteBt.background, _deleteBt.icon);
			applyDefaultFrameVisitorNoTween(_copyBt, _copyBt.background, _copyBt.icon);
			
			_deleteBt.width = 27;
			_deleteBt.height = 22;
			_copyBt.width = 27;
			_copyBt.height = 22;
			_inBox.width = 30;
			_inBox.iconAlign = IconAlign.LEFT;
			_inBox.contentMargin = new Margin(10, 0, 0, 0);
			
			_deleteBt.iconAlign = IconAlign.LEFT;
			_copyBt.iconAlign = IconAlign.LEFT;
			
			_inBox.contentMargin = new Margin(10, 0, 0, 0);
			_deleteBt.contentMargin = new Margin(7, 0, 0, 0);
			_copyBt.contentMargin = new Margin(7, 0, 0, 0);
			
			if(_data != null && _data.boxPosition != null) {
				x = _data.boxPosition.x;
				y = _data.boxPosition.y;
			}
			
			if(_data != null) {
				_data.addEventListener(Event.CHANGE, render);
				_data.addEventListener(Event.SELECT, debugHandler);
			}
			
			addEventListener(MouseEvent.CLICK, clickHandler);
			addEventListener(MouseEvent.ROLL_OUT, rollOutHandler);
			addEventListener(MouseEvent.ROLL_OVER, rollOverHandler);
			_copyBt.addEventListener(MouseEvent.MOUSE_DOWN, mouseDownHandler);
			_deleteBt.addEventListener(MouseEvent.MOUSE_DOWN, mouseDownHandler);
//			_inBox.addEventListener(MouseEvent.MOUSE_DOWN, mouseDownHandler);
			_background.addEventListener(MouseEvent.ROLL_OVER, overBackGraphicHandler);
			_timeIcon.addEventListener(MouseEvent.ROLL_OVER, overTimeIconGraphicHandler);
			
			render();
		}
		
		/**
		 * Tell the debugger the current display node is this one.
		 */
		private function debugHandler(event:Event):void {
			dispatchEvent(new BoxEvent(BoxEvent.ACTIVATE_DEBUG, 0, true));
		}
		
		/**
		 * Resizes and replaces the elements.
		 */
		private function computePositions():void {
			_background.width = BackgroundView.CELL_SIZE * COLS - _inBox.width - _outBoxes[0].width + 4;
			_background.height = _inBox.height = BackgroundView.CELL_SIZE * ROWS;
			_background.x = _inBox.width - 2;
			var t:int = 0;
			var h:int = _inBox.height;
			for(var i:int = 0; i < _outBoxes.length; ++i) {
				_outBoxes[i].x = _background.x + _background.width - 2;
				if(contains(_outBoxes[i])) {
					t++;
					if(i > 0) h+=4;
				}
			}
			
			h = Math.round(h/t);
			for(i = 0; i < _outBoxes.length; ++i) {
				_outBoxes[i].height = h;
				_outBoxes[i].validate();
				//Dirty hack to offset the icon's position as the contentMargin
				//seems to be fucked up...
				_outBoxes[i].icon.y -= 3;
			}
			PosUtils.vPlaceNext(-4, VectorUtils.toArray(_outBoxes));
			
			var margin:int = 3;
			var isImage:Boolean = _data != null && _data.getImage() != null;
			_image.height = _image.width = _background.height - 5 - margin * 2;
			_image.x = _background.x + 5 + margin;
			_image.y = margin;
			_label.x = _image.x + _image.width + margin;
			_label.y = margin;
			_label.width = _background.width - _label.x + _background.x - margin;
			_label.height = _background.height - margin * 2;
			if(_data == null || _data.isEmpty() || !isImage) {
				_label.width = _background.width;
				_label.y = Math.round((_background.height - _label.height) * .5);
				_label.x = _background.x + 5 + margin;
				_label.width = _background.width - 5 - margin * 2;
			}
			
			_takePut.x	= _image.x + _image.width - _takePut.width;
			_money.x	= _takePut.visible? _takePut.x - _money.width + 1 : _takePut.x;
			_takePut.y	= _money.y = _image.y + _image.height - _takePut.height;
			
			_timeIcon.x = _background.x + (_background.width - _timeIcon.width) * .5;
			_timeIcon.y = -_timeIcon.height;
			
			_deleteBt.x = _background.x + _background.width - _deleteBt.width;
			_deleteBt.y = -_deleteBt.height;
			
			_copyBt.x = _deleteBt.x - _copyBt.width - 5;
			_copyBt.y = -_copyBt.height;
			
			roundPos(_background, _timeIcon, _deleteBt, _copyBt);
		}
		
		
		
		
		//__________________________________________________________ MOUSE EVENTS
		
		/**
		 * Called when time icon is rolled over.
		 */
		private function overTimeIconGraphicHandler(event:MouseEvent):void {
			_timeIcon.dispatchEvent(new ToolTipEvent(ToolTipEvent.OPEN, Label.getLabel("box-timeIcon"), ToolTipAlign.TOP));
		}
		
		/**
		 * Called when background is rolled over to display the box'scoordinates
		 */
		private function overBackGraphicHandler(event:MouseEvent):void {
			var p:* = _data.actionPlace == null? new Point() : _data.actionPlace.getAsPoint();
			var label:String;
			if(p is Point) label = "["+Point(p).x+"]["+Point(p).y+"]";
			if(p is Point3D) label = "["+Point3D(p).x+"]["+Point3D(p).y+"]["+Point3D(p).z+"]";
			dispatchEvent(new ToolTipEvent(ToolTipEvent.OPEN, label, ToolTipAlign.BOTTOM, 10));
		}
		
		/**
		 * Called when mouse goes over the component
		 */
		private function rollOverHandler(event:MouseEvent):void {
			cacheAsBitmap = false;
			opaqueBackground = null;
			if(!_debugMode) {
				addChildAt(_deleteBt, 0);
				addChildAt(_copyBt, 1);
				TweenLite.killTweensOf(_deleteBt);
				TweenLite.killTweensOf(_copyBt);
				TweenLite.to(_deleteBt, .15, {y:Math.round(-_deleteBt.height)});
				TweenLite.to(_copyBt, .15, {y:Math.round(-_copyBt.height)});
				if(event.shiftKey && event.altKey) {
					_label.text = 'GUID : '+_data.guid.toString()+'<br />TREE : '+_data.getTreeID();
				}
			}else{
				overBackGraphicHandler(event);
			}
		}
		
		/**
		 * Called when an out box is rolled over.
		 * Display the related choice.
		 */
		private function overOutBoxHandler(event:MouseEvent):void {
			if(_data.actionChoices != null && _data.actionChoices.choices.length > 0) {
				var label:String;
				label = _data.actionChoices.choices[ _outBoxToIndex[event.currentTarget] ];
				if(_data.actionChoices.choicesCost != null && _data.actionChoices.choicesCost.length > _outBoxToIndex[event.currentTarget]) {
					var cost:uint = _data.actionChoices.choicesCost[ _outBoxToIndex[event.currentTarget] ];
					if(cost != 0) label += ' ('+cost+'K)';
				}
				InteractiveObject(event.currentTarget).dispatchEvent(new ToolTipEvent(ToolTipEvent.OPEN, label, ToolTipAlign.RIGHT));
			}
		}
		
		/**
		 * Called when mouse goes out the component.
		 */
		private function rollOutHandler(event:MouseEvent):void {
			cacheAsBitmap = true;//TODO check if that's a sufficient optimization. If not, remove everything from holder and replace it by a bitmap snapshot
			if(!_debugMode) {
				TweenLite.killTweensOf(_deleteBt);
				TweenLite.to(_deleteBt, .15, {y:0, removeChild:true});
				TweenLite.killTweensOf(_copyBt);
				TweenLite.to(_copyBt, .15, {y:0, removeChild:true, onComplete:resetOpaqueBackground});
			}
		}
		
		/**
		 * Sets the opaque background when user does not
		 * interact with the coponent to optimise its rendering.
		 * As there are no "visible" holes in the design, it's
		 * graphically totally ok to do that.
		 */
		private function resetOpaqueBackground():void {
			opaqueBackground = 0xBBDDEC;
		}
		
		/**
		 * Called when the component is clicked to open the edition view
		 */
		private function clickHandler(event:MouseEvent):void {
			if(_debugMode) return;
			
			if(event.target == _deleteBt || event.target == _copyBt || _outBoxToIndex[event.target] != undefined) {
				event.stopPropagation();
				if(event.target == _deleteBt) {
					if(_data.isEmpty()) {
						onDelete();
					}else{
						prompt("box-delete-promptTitle", "box-delete-promptContent", onDelete, "deleteEvent");
					}
				}else
				if(event.target == _copyBt) {
					dispatchEvent(new BoxEvent(BoxEvent.DUPLICATE));
				}
				return;
			}
			//If the box haven't been dragged
			if(Math.abs(stage.mouseX-_dragOffset.x) < 5 && Math.abs(stage.mouseY-_dragOffset.y) < 5) {
				FrontControler.getInstance().edit(_data);
			}
		}
		
		/**
		 * Called by prompt window when submitting the deletion.
		 */
		private function onDelete():void {
			dispatchEvent(new BoxEvent(BoxEvent.DELETE));
		}
		
		/**
		 * Called when mouse is pressed over the out box
		 * Prevents dragging if pressing delete/duplicate icon, and starts a link
		 * creation if starting from an out box.
		 */
		private function mouseDownHandler(event:MouseEvent):void {
			if(_debugMode) return;
			
			event.stopPropagation();
			if (event.currentTarget != _deleteBt && event.currentTarget != _copyBt) {
				var index:int = _outBoxToIndex[event.currentTarget];
				dispatchEvent(new BoxEvent(BoxEvent.CREATE_LINK, index));
			}
		}
		
	}
}