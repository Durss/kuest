package com.twinoid.kube.quest.views {
	import com.twinoid.kube.quest.vo.KuestEvent;
	import com.nurun.utils.pos.roundPos;
	import com.muxxu.kub3dit.graphics.CancelIcon;
	import com.muxxu.kub3dit.graphics.SubmitIcon;
	import flash.events.MouseEvent;
	import com.twinoid.kube.quest.components.buttons.ButtonKube;
	import com.twinoid.kube.quest.components.form.edit.EditEventTime;
	import com.twinoid.kube.quest.controler.FrontControler;
	import com.twinoid.kube.quest.utils.Closable;
	import com.twinoid.kube.quest.utils.makeEscapeClosable;
	import gs.TweenLite;
	import gs.easing.Back;

	import com.nurun.structure.environnement.label.Label;
	import com.nurun.structure.mvc.model.events.IModelEvent;
	import com.nurun.structure.mvc.views.AbstractView;
	import com.nurun.utils.pos.PosUtils;
	import com.twinoid.kube.quest.components.form.edit.EditEventPlace;
	import com.twinoid.kube.quest.components.form.edit.EditEventType;
	import com.twinoid.kube.quest.components.window.PromptWindow;
	import com.twinoid.kube.quest.model.Model;

	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.events.Event;

	/**
	 * Displays the edition window.
	 * Contains editable categories.
	 * 
	 * @author Francois
	 * @date 3 févr. 2013;
	 */
	public class EditBoxView extends AbstractView implements Closable {
		
		private const _WIDTH:int = 300;
		 
		private var _window:PromptWindow;
		private var _holder:Sprite;
		private var _place:EditEventPlace;
		private var _type:EditEventType;
		private var _closed:Boolean;
		private var _times:EditEventTime;
		private var _submit:ButtonKube;
		private var _cancel:ButtonKube;
		private var _data:KuestEvent;
		
		
		
		
		/* *********** *
		 * CONSTRUCTOR *
		 * *********** */
		/**
		 * Creates an instance of <code>EditBoxView</code>.
		 */
		public function EditBoxView() {
			addEventListener(Event.ADDED_TO_STAGE, initialize);
		}

		
		
		/* ***************** *
		 * GETTERS / SETTERS *
		 * ***************** */
		/**
		 * Gets the width of the component.
		 */
		override public function get width():Number { return _WIDTH; }
		
		/**
		 * Gets the height of the component.
		 */
		override public function get height():Number { return _window.height; }



		/* ****** *
		 * PUBLIC *
		 * ****** */
		/**
		 * Called on model's update
		 */
		override public function update(event:IModelEvent):void {
			var model:Model = event.model as Model;
			
			TweenLite.killTweensOf(this);
			
			if(model.currentBoxToEdit != null) {
				_data = model.currentBoxToEdit;
				if(_closed) {
					_closed = false;
					scaleX = scaleY = 1;
					PosUtils.centerInStage(this);
					visible = true;
					stage.focus = this;
					TweenLite.from(this, .5, {x:stage.stageWidth * .5, y:stage.stageHeight * .5, scaleX:0, scaleY:0, ease:Back.easeOut});
				}
			}else if(!_closed){
				_closed = true;
				TweenLite.to(this, .5, {x:stage.stageWidth * .5, y:stage.stageHeight * .5, scaleX:0, scaleY:0, visible:false, ease:Back.easeIn});
			}
		}

		/**
		 * @inheritDoc
		 */
		public function close():void {
			if(_closed) return;
			FrontControler.getInstance().cancelBoxEdition();
		}


		
		
		/* ******* *
		 * PRIVATE *
		 * ******* */
		/**
		 * Initialize the class.
		 */
		private function initialize(event:Event):void {
			removeEventListener(Event.ADDED_TO_STAGE, initialize);
			
			_holder	= addChild(new Sprite()) as Sprite;
			_place	= _holder.addChild(new EditEventPlace(_WIDTH)) as EditEventPlace;
			_type	= _holder.addChild(new EditEventType(_WIDTH)) as EditEventType;
			_times	= _holder.addChild(new EditEventTime(_WIDTH)) as EditEventTime;
			_submit	= _holder.addChild(new ButtonKube(Label.getLabel("editWindow-submit"), new SubmitIcon())) as ButtonKube;
			_cancel	= _holder.addChild(new ButtonKube(Label.getLabel("editWindow-cancel"), new CancelIcon())) as ButtonKube;
			
			_window = addChild(new PromptWindow(Label.getLabel("editWindow-title"), _holder)) as PromptWindow;
			
			_closed = true;
			visible = false;
			scaleX = scaleY = 0;
			
			makeEscapeClosable(this);
			computePositions();
			
			addEventListener(Event.RESIZE, computePositions);
			_submit.addEventListener(MouseEvent.CLICK, clickButtonHandler);
			_cancel.addEventListener(MouseEvent.CLICK, clickButtonHandler);
			stage.addEventListener(MouseEvent.CLICK, clickStageHandler, true, 199999999);
		}
		
		/**
		 * Resizes and replaces the elements.
		 */
		private function computePositions(event:Event = null):void {
			if(event != null) event.stopPropagation();
			
			_window.width = _WIDTH;
			var i:int, len:int, item:DisplayObject, py:int;
			len = _holder.numChildren;
			for(i = 0; i < len; ++i) {
				item = _holder.getChildAt(i);
				if(item == _cancel) break;
				item.y = py;
				py += item.height + 20;
			}
			
			_cancel.y = _submit.y;
			_submit.x = _WIDTH * .5 - _submit.width - 10;
			_cancel.x = _WIDTH * .5 + 10;
			roundPos(_submit, _cancel);
			
			_window.forcedContentHeight = py;
			_window.updateSizes();
		}
		
		/**
		 * Called when submit or close button is clicked.
		 */
		private function clickButtonHandler(event:MouseEvent):void {
			if(event.currentTarget == _cancel) close();
			if(event.currentTarget == _submit) submit();
		}
		
		/**
		 * Called when stage is clicked to close the window
		 */
		private function clickStageHandler(event:MouseEvent):void {
			if(!contains(event.target as DisplayObject)) {
				close();
			}
		}
		
		/**
		 * Submit the form
		 */
		private function submit():void {
			_place.save( _data );
			_type.save( _data );
			_times.save( _data );
		}
		
	}
}