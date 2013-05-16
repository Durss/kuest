package com.twinoid.kube.quest.editor.components.box {
	import gs.TweenLite;

	import com.muxxu.kub3dit.graphics.CancelIcon;
	import com.nurun.components.bitmap.ImageResizer;
	import com.nurun.components.button.GraphicButton;
	import com.nurun.components.button.IconAlign;
	import com.nurun.components.button.visitors.applyDefaultFrameVisitorNoTween;
	import com.nurun.components.text.CssTextField;
	import com.nurun.components.vo.Margin;
	import com.nurun.structure.environnement.label.Label;
	import com.nurun.utils.math.MathUtils;
	import com.nurun.utils.pos.PosUtils;
	import com.nurun.utils.pos.roundPos;
	import com.nurun.utils.string.StringUtils;
	import com.twinoid.kube.quest.editor.controler.FrontControler;
	import com.twinoid.kube.quest.editor.events.BoxEvent;
	import com.twinoid.kube.quest.editor.events.ToolTipEvent;
	import com.twinoid.kube.quest.editor.utils.hexToMatrix;
	import com.twinoid.kube.quest.editor.utils.prompt;
	import com.twinoid.kube.quest.editor.views.BackgroundView;
	import com.twinoid.kube.quest.editor.vo.KuestEvent;
	import com.twinoid.kube.quest.editor.vo.ToolTipAlign;
	import com.twinoid.kube.quest.graphics.BoxEventGraphic;
	import com.twinoid.kube.quest.graphics.BoxInGraphic;
	import com.twinoid.kube.quest.graphics.BoxLinkIconGraphic;
	import com.twinoid.kube.quest.graphics.BoxOutGraphic;
	import com.twinoid.kube.quest.graphics.BoxTimerEventGraphic;
	import com.twinoid.kube.quest.graphics.ClearBoxGraphic;

	import flash.display.DisplayObject;
	import flash.display.InteractiveObject;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.filters.ColorMatrixFilter;
	import flash.geom.Point;
	import flash.geom.Rectangle;


	
	[Event(name="createLink", type="com.twinoid.kube.quest.editor.events.BoxEvent")]
	[Event(name="delete", type="com.twinoid.kube.quest.editor.events.BoxEvent")]
	
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
		private var _outBox1:GraphicButton;
		private var _inBox:GraphicButton;
		private var _links:Vector.<BoxLink>;
		private var _timeIcon:BoxTimerEventGraphic;
		private var _deleteBt:GraphicButton;
		private var _outBox2:GraphicButton;
		private var _outBox3:GraphicButton;
		
		
		
		
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
		override public function get width():Number { return _outBox1.x + _outBox1.width; }
		
		/**
		 * Gets the height of the component.
		 */
		override public function get height():Number { return _inBox.height; }



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
			}else{
				if(_data.getImage() != null) {
					_image.setBitmapData(_data.getImage());
					_image.validate();
				}else{
					_image.clear();
				}
				if(StringUtils.trim(_data.getLabel()).length == 0) {
					_label.text = Label.getLabel("box-empty");
				}else{
					_label.text = _data.getLabel();
				}
				if(!_data.actionDate.getAlwaysEnabled()) {
					addChild(_timeIcon);
				}else {
					if(contains(_timeIcon)) removeChild(_timeIcon);
				}
				
				_background.filters = _data.endsQuest? [new ColorMatrixFilter([-1.2100542783737183,1.388539433479309,1.2215150594711304,0,-25.40000343322754,0.7383951544761658,0.7626101970672607,-0.1010054349899292,0,-25.400001525878906,-0.2772481143474579,2.9502274990081787,-1.2729790210723877,0,-25.400007247924805,0,0,0,1,0])] : [];
				
				//============ LINKS MANAGEMNT ============
				var wasLink2:Boolean = contains(_outBox2);
				var wasLink3:Boolean = contains(_outBox3);
				
				//Define how much links output should be displayed
				if(contains(_outBox2)) removeChild(_outBox2);
				if(contains(_outBox3)) removeChild(_outBox3);
				if(_data.actionChoices != null) {
					var numChoices:int = Math.max(1, _data.actionChoices.choices.length);
					if(numChoices > 1) addChildAt(_outBox2, 1);
					if(numChoices > 2) addChildAt(_outBox3, 2);
				}
				
				//If choices have been deleted, some links might have to be cleared
				//Clear the links for the second output.
				var i:int, len:int, choicesUpdate:Boolean;
				if(wasLink2 != contains(_outBox2)) choicesUpdate = true;
				if(wasLink3 != contains(_outBox3)) choicesUpdate = true;
				
				len = _links.length;
				if(wasLink2 && !contains(_outBox2)) {
					for(i = 0; i < len; ++i) {
						if(_links[i].choiceIndex == 1) _links[i].deleteLink();
					}
				}
				
				//If choices have been deleted, some links might have to be cleared
				//Clear the links for the third output.
				if(wasLink3 && !contains(_outBox3)) {
					for(i = 0; i < len; ++i) {
						if(_links[i].choiceIndex == 2) _links[i].deleteLink();
					}
				}
			}
			
			//Render the box.
			computePositions();
			
			//If there have ben an update in the choices, update the links rendering.
			//As the links update depending on the box's state, we need to render
			//the box before doing this. That's why "computePositions" is called before.
			if(choicesUpdate) {
				for(i = 0; i < len; ++i) _links[i].update();
			}
		}
		
		/**
		 * Gets the Y offset position of an output button by its choice index.
		 */
		public function getChoiceIndexPosition(index:int):int {
			var target:DisplayObject = this["_outBox" + MathUtils.restrict(index + 1, 1, 3)];
			return target.y + target.height * .5;
		}



		
		
		/* ******* *
		 * PRIVATE *
		 * ******* */
		/**
		 * Initialize the class.
		 */
		private function initialize():void {
			_links		= new Vector.<BoxLink>();
			
			_outBox1	= addChild(new GraphicButton(new BoxOutGraphic(), new BoxLinkIconGraphic())) as GraphicButton;
			_outBox2	= new GraphicButton(new BoxOutGraphic(), new BoxLinkIconGraphic());
			_outBox3	= new GraphicButton(new BoxOutGraphic(), new BoxLinkIconGraphic());
			_background	= addChild(new BoxEventGraphic()) as BoxEventGraphic;
			_inBox		= addChild(new GraphicButton(new BoxInGraphic(), new BoxLinkIconGraphic())) as GraphicButton;
			_image		= addChild(new ImageResizer()) as ImageResizer;
			_label		= addChild(new CssTextField("box-label")) as CssTextField;
			_deleteBt	= new GraphicButton(new ClearBoxGraphic(), new CancelIcon());
			_timeIcon	= new BoxTimerEventGraphic();
			
			_dragOffset = new Point();
			_label.mouseEnabled = false;
			
			applyDefaultFrameVisitorNoTween(_outBox1, _outBox1.background);
			applyDefaultFrameVisitorNoTween(_outBox2, _outBox2.background);
			applyDefaultFrameVisitorNoTween(_outBox3, _outBox3.background);
			applyDefaultFrameVisitorNoTween(_deleteBt, _deleteBt.background, _deleteBt.icon);
			
			_deleteBt.width = 27;
			_deleteBt.height = 22;
			_inBox.width = _outBox1.width = _outBox2.width = _outBox3.width = 30;
			
			_deleteBt.iconAlign = IconAlign.LEFT;
			_outBox1.iconAlign = _outBox2.iconAlign = _outBox3.iconAlign = _inBox.iconAlign = IconAlign.LEFT;
			_inBox.contentMargin = new Margin(10, 0, 0, 0);
			_outBox1.contentMargin = new Margin(10, 0, 0, 0);
			_outBox2.contentMargin = new Margin(10, 0, 0, 0);
			_outBox3.contentMargin = new Margin(10, 0, 0, 0);
			_deleteBt.contentMargin = new Margin(7, 0, 0, 0);
			_outBox1.background.filters = [new ColorMatrixFilter(hexToMatrix( 0xE95B5B ))];
			_outBox2.background.filters = [new ColorMatrixFilter(hexToMatrix( 0xff8800 ))];
			_outBox3.background.filters = [new ColorMatrixFilter(hexToMatrix( 0xffff00 ))];
			
			if(_data != null && _data.boxPosition != null) {
				x = _data.boxPosition.x;
				y = _data.boxPosition.y;
			}
			
			if(_data != null) {
				_data.addEventListener(Event.CHANGE, render);
			}
			
			addEventListener(MouseEvent.CLICK, clickHandler);
			addEventListener(MouseEvent.ROLL_OUT, rollOutHandler);
			addEventListener(MouseEvent.ROLL_OVER, rollOverHandler);
			_deleteBt.addEventListener(MouseEvent.MOUSE_DOWN, mouseDownHandler);
//			_inBox.addEventListener(MouseEvent.MOUSE_DOWN, mouseDownHandler);
			_outBox1.addEventListener(MouseEvent.MOUSE_DOWN, mouseDownHandler);
			_outBox2.addEventListener(MouseEvent.MOUSE_DOWN, mouseDownHandler);
			_outBox3.addEventListener(MouseEvent.MOUSE_DOWN, mouseDownHandler);
			_outBox1.addEventListener(MouseEvent.ROLL_OVER, overOutHBoxandler);
			_outBox2.addEventListener(MouseEvent.ROLL_OVER, overOutHBoxandler);
			_outBox3.addEventListener(MouseEvent.ROLL_OVER, overOutHBoxandler);
			_timeIcon.addEventListener(MouseEvent.ROLL_OVER, overTimeIconGraphic);
			
			render();
		}
		
		/**
		 * Resizes and replaces the elements.
		 */
		private function computePositions():void {
			_background.width = BackgroundView.CELL_SIZE * 8 - _inBox.width - _outBox1.width + 4;
			_background.height = _inBox.height = BackgroundView.CELL_SIZE * 3;
			_background.x = _inBox.width - 2;
			_outBox1.x = _outBox2.x = _outBox3.x = _background.x + _background.width - 2;
			
			var t:int = 1;
			if(contains(_outBox2)) t++;
			if(contains(_outBox3)) t++;
			var h:int = _inBox.height;
			if(contains(_outBox2)) h+=4;
			if(contains(_outBox3)) h+=4;
			h = Math.round(h/t);
			_outBox1.height = _outBox2.height = _outBox3.height = h;
			PosUtils.vPlaceNext(-4, _outBox1, _outBox2, _outBox3);
			
			//Dirty hack to offset the icon's position as the contentMargin
			//seems to be fucked up...
			_outBox1.validate();
			_outBox2.validate();
			_outBox3.validate();
			_outBox1.icon.y -= 3;
			_outBox2.icon.y -= 3;
			_outBox3.icon.y -= 3;
			
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
			
			_timeIcon.x = _background.x + (_background.width - _timeIcon.width) * .5;
			_timeIcon.y = -_timeIcon.height;
			
			_deleteBt.x = _background.x + _background.width - _deleteBt.width;
			_deleteBt.y = -_deleteBt.height;
			
			roundPos(_outBox1, _background, _timeIcon, _deleteBt);
		}
		
		
		
		
		//__________________________________________________________ MOUSE EVENTS
		
		/**
		 * Called when time icon is rolled over.
		 */
		private function overTimeIconGraphic(event:MouseEvent):void {
			_timeIcon.dispatchEvent(new ToolTipEvent(ToolTipEvent.OPEN, Label.getLabel("box-timeIcon"), ToolTipAlign.TOP));
		}
		
		/**
		 * Called when mouse goes over the component
		 */
		private function rollOverHandler(event:MouseEvent):void {
			if(event.target != this) return; //Fuckin bug ! Without that, we get a rollover fired when we click "out" or "delete" button, even if we're already over. Probably due to GraphicButton component...
			cacheAsBitmap = false;
			addChildAt(_deleteBt, 0);
			TweenLite.killTweensOf(_deleteBt);
			TweenLite.to(_deleteBt, .15, {y:Math.round(-_deleteBt.height)});
		}
		
		/**
		 * Called when an out box is rolled over.
		 * Display the related choice.
		 */
		private function overOutHBoxandler(event:MouseEvent):void {
			if(_data.actionChoices != null && _data.actionChoices.choices.length > 0) {
				var label:String;
				if(event.currentTarget == _outBox1) label = _data.actionChoices.choices[0];
				if(event.currentTarget == _outBox2) label = _data.actionChoices.choices[1];
				if(event.currentTarget == _outBox3) label = _data.actionChoices.choices[2];
				InteractiveObject(event.currentTarget).dispatchEvent(new ToolTipEvent(ToolTipEvent.OPEN, label, ToolTipAlign.RIGHT));
			}
		}
		
		/**
		 * Called when mouse goes out the component.
		 */
		private function rollOutHandler(event:MouseEvent):void {
			if(event.target != this) return; //Fuckin bug ! Without that, we get a rollover fired when we click "out" or "delete" button, even if we're already over. Probably due to GraphicButton component...
			cacheAsBitmap = true;//TODO check if that's a sufficient optimization. If not, remove everything from holder and replace it by a bitmap snapshot
			TweenLite.killTweensOf(_deleteBt);
			TweenLite.to(_deleteBt, .15, {y:0, removeChild:true});
		}
		
		/**
		 * Called when the component is clicked to open the edition view
		 */
		private function clickHandler(event:MouseEvent):void {
			if(event.target == _deleteBt || event.target == _outBox1 || event.target == _outBox2 || event.target == _outBox3) {
				event.stopPropagation();
				if(event.target == _deleteBt) {
					if(_data.isEmpty()) {
						onDelete();
					}else{
						prompt("box-delete-promptTitle", "box-delete-promptContent", onDelete, "deleteEvent");
					}
				}
				return;
			}
			if(Math.abs(stage.mouseX-_dragOffset.x) < 2 && Math.abs(stage.mouseY-_dragOffset.y) < 2) {
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
		 * Called when mouse is pressed over the in/out box
		 */
		private function mouseDownHandler(event:MouseEvent):void {
			event.stopPropagation();
			if (event.currentTarget != _deleteBt) {
				var index:int = event.currentTarget == _outBox1 ? 0 : event.currentTarget == _outBox2 ? 1 : 2;
				dispatchEvent(new BoxEvent(BoxEvent.CREATE_LINK, index));
			}
		}
		
	}
}