package com.twinoid.kube.quest.editor.components.box {
	import flash.geom.Matrix;
	import com.twinoid.kube.quest.editor.views.BackgroundView;
	import flash.events.Event;
	import fl.motion.easing.Back;
	import gs.TweenLite;
	import com.nurun.components.button.GraphicButton;
	import com.nurun.components.vo.Margin;
	import com.nurun.core.lang.Disposable;
	import com.nurun.structure.environnement.label.Label;
	import com.twinoid.kube.quest.editor.components.MagnifyableTextfield;
	import com.twinoid.kube.quest.editor.components.buttons.GraphicButtonKube;
	import com.twinoid.kube.quest.editor.controler.FrontControler;
	import com.twinoid.kube.quest.editor.events.BoxEvent;
	import com.twinoid.kube.quest.editor.events.ToolTipEvent;
	import com.twinoid.kube.quest.editor.vo.TodoData;
	import com.twinoid.kube.quest.graphics.DeleteIcon;
	import com.twinoid.kube.quest.graphics.TodoIcon;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	
	/**
	 * Displays a todo icon on the board.
	 * Shows its content on a tooltip when rolled over.
	 * 
	 * @author Durss
	 * @date 19 juil. 2014;
	 */
	public class BoxTodo extends Sprite implements Disposable {
		
		private static var _BMD:BitmapData;
		private static var _TF:MagnifyableTextfield;
		private static var _DEL:GraphicButton;
		private static var _OFS:Point;
		private var _data : TodoData;
		
		
		
		/* *********** *
		 * CONSTRUCTOR *
		 * *********** */
		/**
		 * Creates an instance of <code>BoxTodo</code>.
		 */
		public function BoxTodo(data:TodoData = null) {
			_data = data;
			initialize();
		}

		
		
		/* ***************** *
		 * GETTERS / SETTERS *
		 * ***************** */

		public function get data() : TodoData {
			return _data;
		}



		/* ****** *
		 * PUBLIC *
		 * ****** */
		/**
		 * Makes an opening transition
		 */
		public function open():void {
			rollOverHandler();
			TweenLite.from(this, .3, {transformAroundCenter:{scaleX:0}, ease:Back.easeOut, easeParams:[3], delay:.15});
			TweenLite.from(this, .3, {transformAroundCenter:{scaleY:0}, ease:Back.easeOut, easeParams:[3]});
		}
		
		/**
		 * Makes a closing transition and clears the item
		 */
		public function close():void {
			TweenLite.to(this, .3, {transformAroundCenter:{scaleX:0}, ease:Back.easeIn, easeParams:[3]});
			TweenLite.to(this, .3, {transformAroundCenter:{scaleY:0}, ease:Back.easeIn, easeParams:[3], delay:.1, onComplete:dispose});
		}
		
		/**
		 * Highlights the todo when searching for it from menu
		 */
		public function highlight():void {
			x = _data.pos.x;
			y = _data.pos.y;
			scaleX = scaleY = 1;
			TweenLite.from(this, .5, {transformAroundCenter:{scaleX:3, scaleY:3}, ease:Back.easeOut});
		}
		
		/**
		 * Makes the component garbage collectable.
		 */
		public function dispose():void {
			while(numChildren > 0) {
				removeChildAt(0);
			}
			graphics.clear();
			
			removeEventListener(MouseEvent.CLICK, clickHandler);
			removeEventListener(MouseEvent.ROLL_OVER, rollOverHandler);
			removeEventListener(MouseEvent.ROLL_OUT, rollOutHandler);
			_data.removeEventListener(BoxEvent.SEARCH_TODO, searchTodoHandler);
			
			parent.removeChild(this);//Yup, dirty :D
			
			FrontControler.getInstance().deleteTodo(_data);
			_data = null;
		}
		
		/**
		 * Sets the todo's position
		 */
		public function moveTo(px:int, py:int):void {
			x = _data.pos.x = Math.floor(px / BackgroundView.CELL_SIZE) * BackgroundView.CELL_SIZE;
			y = _data.pos.y = Math.floor(py / BackgroundView.CELL_SIZE) * BackgroundView.CELL_SIZE;
		}



		
		
		/* ******* *
		 * PRIVATE *
		 * ******* */
		/**
		 * Initialize the class.
		 */
		private function initialize():void {
			if(_BMD == null) {
				var src:TodoIcon = new TodoIcon();
				_BMD = new BitmapData(src.width, src.height, true, 0);
				_BMD.draw(src);
				_BMD.lock();
				_TF = new MagnifyableTextfield(Label.getLabel('global-todoTitle'));
				_TF.visible = false;
				_DEL = new GraphicButtonKube(new DeleteIcon());
				_DEL.contentMargin = new Margin(2, 5, 2, 5);
				_OFS = new Point();
			}
			
			//Data isn't null when loading a todo instance from a quest save.
			if(_data == null) {
				_data = new TodoData();
				_data.pos.x = x;
				_data.pos.y = y;
				FrontControler.getInstance().addTodo(_data);
			}else{
				x = _data.pos.x;
				y = _data.pos.y;
			}

			var m:Matrix = new Matrix();
			m.translate(0, -5);
			graphics.beginBitmapFill(_BMD,m);
			graphics.drawRect(0, -5, _BMD.width, _BMD.height);
			graphics.endFill();
			
			addEventListener(MouseEvent.CLICK, clickHandler);
			addEventListener(MouseEvent.ROLL_OVER, rollOverHandler);
			addEventListener(MouseEvent.ROLL_OUT, rollOutHandler);
			addEventListener(MouseEvent.MOUSE_DOWN, mouseDownHandler);
			_data.addEventListener(BoxEvent.SEARCH_TODO, searchTodoHandler);
		}
		
		/**
		 * Called when the component is clicked
		 */
		private function clickHandler(event:MouseEvent):void {
			if(event.target == _DEL) {
				close();
			}else if(Math.sqrt(Math.pow(_OFS.y-y, 2) + Math.pow(_OFS.x-x, 2)) < 5) {//If item hasn't been dragged
				_TF.text = _data.text;
				_TF.width = width;
				_TF.height = height;
				_TF.endEditionCallback = onEndEdit;
				//This trick opens up the MagnifyableTextfield instance
				addChild(_TF);
				stage.focus = _TF;
			}
		}
		
		/**
		 * Called when the component is rolled over
		 */
		private function rollOverHandler(event:MouseEvent = null):void {
			if(contains(_DEL)) return;
			
			_DEL.y = height - 5;
			_DEL.width = width;
			addChild(_DEL);
			
			if(_data.text == null || _data.text.length == 0) return;
			dispatchEvent(new ToolTipEvent(ToolTipEvent.OPEN, _data.text));
		}
		
		/**
		 * Called when component is rolled out
		 */
		private function rollOutHandler(event:MouseEvent):void {
			if(contains(_DEL)) removeChild(_DEL);
		}
		
		/**
		 * Called when text editions complete from the magnified textarea
		 */
		private function onEndEdit(text:String):void {
			removeChild(_TF);
			_data.text = text;
		}
		
		/**
		 * Called when mouse is pressed to drag it
		 */
		private function mouseDownHandler(event:MouseEvent):void {
			if(event.target != BoxTodo._DEL) {
				_OFS.x = x;
				_OFS.y = y;
				parent.addChild(this);
				stage.addEventListener(MouseEvent.MOUSE_UP, mouseUpHandler);
				addEventListener(Event.ENTER_FRAME, enterFrameHandler);
			}
		}
		
		/**
		 * Called on enter_frame event to drag the item.
		 */
		private function enterFrameHandler(event:Event):void {
			x = Math.floor(parent.mouseX / BackgroundView.CELL_SIZE) * BackgroundView.CELL_SIZE;
			y = Math.floor(parent.mouseY / BackgroundView.CELL_SIZE) * BackgroundView.CELL_SIZE;
		}
		
		/**
		 * Called when mouse is released. Stop its drag
		 */
		private function mouseUpHandler(event:MouseEvent):void {
			event.stopPropagation();
			event.stopImmediatePropagation();
			stage.removeEventListener(MouseEvent.MOUSE_UP, mouseUpHandler);
			_data.pos.x = x;
			_data.pos.y = y;
			removeEventListener(Event.ENTER_FRAME, enterFrameHandler);
		}
		
		/**
		 * Called when the related data has been selected on the todo
		 * search menu.
		 */
		private function searchTodoHandler(event:BoxEvent):void {
			dispatchEvent(event);
		}
		
	}
}