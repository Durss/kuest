package com.twinoid.kube.quest.editor.views {
	import gs.TweenLite;
	import gs.easing.Back;

	import com.muxxu.kub3dit.graphics.CancelIcon;
	import com.muxxu.kub3dit.graphics.SubmitIcon;
	import com.nurun.components.form.FormComponentGroup;
	import com.nurun.structure.environnement.label.Label;
	import com.nurun.structure.mvc.model.events.IModelEvent;
	import com.nurun.structure.mvc.views.AbstractView;
	import com.nurun.structure.mvc.views.ViewLocator;
	import com.nurun.utils.pos.PosUtils;
	import com.nurun.utils.pos.roundPos;
	import com.twinoid.kube.quest.editor.components.buttons.ButtonKube;
	import com.twinoid.kube.quest.editor.components.form.CheckBoxKube;
	import com.twinoid.kube.quest.editor.components.form.edit.EditEventChoices;
	import com.twinoid.kube.quest.editor.components.form.edit.EditEventPlace;
	import com.twinoid.kube.quest.editor.components.form.edit.EditEventSound;
	import com.twinoid.kube.quest.editor.components.form.edit.EditEventTime;
	import com.twinoid.kube.quest.editor.components.form.edit.EditEventType;
	import com.twinoid.kube.quest.editor.components.window.TitledWindow;
	import com.twinoid.kube.quest.editor.controler.FrontControler;
	import com.twinoid.kube.quest.editor.model.Model;
	import com.twinoid.kube.quest.editor.utils.Closable;
	import com.twinoid.kube.quest.editor.utils.makeEscapeClosable;
	import com.twinoid.kube.quest.editor.utils.setToolTip;
	import com.twinoid.kube.quest.editor.vo.KuestEvent;

	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.utils.setTimeout;



	/**
	 * Displays the edition window.
	 * Contains editable categories.
	 * 
	 * @author Francois
	 * @date 3 févr. 2013;
	 */
	public class EditBoxView extends AbstractView implements Closable {
		
		private const _WIDTH:int = 400;
		 
		private var _window:TitledWindow;
		private var _holder:Sprite;
		private var _place:EditEventPlace;
		private var _type:EditEventType;
		private var _closed:Boolean;
		private var _times:EditEventTime;
		private var _submit:ButtonKube;
		private var _cancel:ButtonKube;
		private var _data:KuestEvent;
		private var _choices:EditEventChoices;
		private var _disable:Sprite;
		private var _endsQuest:CheckBoxKube;
		private var _loosesQuest:CheckBoxKube;
		private var _sound:EditEventSound;
		private var _startTree:CheckBoxKube;
		private var _group:FormComponentGroup;
		private var _tabIndex:int;
		
		
		
		
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
		
		/**
		 * @inheritDoc
		 */
		public function get isClosed():Boolean { return _closed; }
		
		/**
		 * @inheritDoc
		 */
		override public function set tabIndex(value:int):void {
			_tabIndex = value;
		}



		/* ****** *
		 * PUBLIC *
		 * ****** */
		/**
		 * Called on model's update
		 */
		override public function update(event:IModelEvent):void {
			var model:Model = event.model as Model;
			
			if (model.currentBoxToEdit != null) {
				if(_closed) {
					_data = model.currentBoxToEdit;
					_window.visible = true;
					//Do not put this AFTER the populate or textfields will be
					//totally fucked up. The getLineMetrics used by some components
					//will return shitty values.
					_window.scaleX = _window.scaleY = 1;
					
					_place.load( _data );
					_type.load( _data );
					_times.load( _data );
					_choices.load( _data );
					_sound.load( _data );
					_endsQuest.selected = _data.endsQuest;
					_loosesQuest.selected = _data.loosesQuest;
					_startTree.selected = _data.startsTree;
					
					computePositions();
					stage.focus = _window;
					TweenLite.killTweensOf(_window);
					TweenLite.killTweensOf(_disable);
					
					setTimeout(flagOpened, 0);//Flag as opened a frame later. See method for more infos
					TweenLite.from(_window, .5, {x:_window.x + width * .5, y:_window.y + height * .5, scaleX:.1, scaleY:.1, ease:Back.easeInOut});
					TweenLite.to(_disable, .25, {autoAlpha:1});
				}
				_place.connectedToGame		= model.connectedToGame;
				_place.inGamePosition		= model.inGamePosition;
				_place.connectedToPlayer	= model.connectedToPlayer;
				_place.forumPosition		= model.forumPosition;
				
			}else if(!_closed){
				_closed = true;
				TweenLite.killTweensOf(_window);
				TweenLite.to(_window, .5, {x:_window.x + width * .5, y:_window.y + height * .5, scaleX:0, scaleY:0, visible:false, ease:Back.easeIn});
				TweenLite.to(_disable, .25, {autoAlpha:0});
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
			
			_holder		= addChild(new Sprite()) as Sprite;
			_place		= _holder.addChild(new EditEventPlace(_WIDTH)) as EditEventPlace;
			_type		= _holder.addChild(new EditEventType(_WIDTH)) as EditEventType;
			_choices	= _holder.addChild(new EditEventChoices(_WIDTH)) as EditEventChoices;
			_times		= _holder.addChild(new EditEventTime(_WIDTH)) as EditEventTime;
			_sound		= _holder.addChild(new EditEventSound(_WIDTH)) as EditEventSound;
			_startTree	= _holder.addChild(new CheckBoxKube(Label.getLabel("editWindow-startTree"))) as CheckBoxKube;
			_endsQuest	= _holder.addChild(new CheckBoxKube(Label.getLabel("editWindow-endEvent"))) as CheckBoxKube;
			_loosesQuest= _holder.addChild(new CheckBoxKube(Label.getLabel("editWindow-looseEvent"))) as CheckBoxKube;
			_submit		= _holder.addChild(new ButtonKube(Label.getLabel("editWindow-submit"), new SubmitIcon())) as ButtonKube;
			_cancel		= _holder.addChild(new ButtonKube(Label.getLabel("editWindow-cancel"), new CancelIcon())) as ButtonKube;
			
			_disable	= addChild(new Sprite()) as Sprite;
			_window		= addChild(new TitledWindow(Label.getLabel("editWindow-title"), _holder)) as TitledWindow;
			
			_closed				= true;
			_disable.alpha		= 0;
			_disable.visible	= false;
			_window.visible		= false;
			
			_place.tabIndex			= _tabIndex;
			_type.tabIndex			= _tabIndex + 50;
			_choices.tabIndex		= _tabIndex + 100;
			_times.tabIndex			= _tabIndex + 150;
			_sound.tabIndex			= _tabIndex + 200;
			_startTree.tabIndex		= _tabIndex + 250;
			_endsQuest.tabIndex		= _tabIndex + 300;
			_loosesQuest.tabIndex	= _tabIndex + 301;
			_submit.tabIndex		= _tabIndex + 350;
			_cancel.tabIndex		= _tabIndex + 351;
			
			//Prevents from selecting both start and end boxes
			_group = new FormComponentGroup();
			_group.allowNoSelection = true;
			_group.add(_startTree);
			_group.add(_endsQuest);
			_group.add(_loosesQuest);
			
			setToolTip(_startTree, Label.getLabel("editWindow-startTreeTT"));
			setToolTip(_endsQuest, Label.getLabel("editWindow-endEventTT"));
			setToolTip(_loosesQuest, Label.getLabel("editWindow-looseEventTT"));
			
			_place.open();
			_type.open();
			
			makeEscapeClosable(this);
			computePositions();
			
			stage.addEventListener(Event.RESIZE, computePositions);
			_holder.addEventListener(Event.RESIZE, computePositions);
			_submit.addEventListener(MouseEvent.CLICK, clickButtonHandler);
			_cancel.addEventListener(MouseEvent.CLICK, clickButtonHandler);
			_disable.addEventListener(MouseEvent.CLICK, clickDisableHandler);
		}
		
		/**
		 * Resizes and replaces the elements.
		 */
		private function computePositions(event:Event = null):void {
			if(event != null && _disable.alpha < 1) return;
			
			//Prevent from firing a RESIZE event to the stage that would be
			//captured on every views listening for it.
			if(event != null && event.currentTarget == _holder) event.stopPropagation();
			
			_window.width = _WIDTH;
			var i:int, len:int, item:DisplayObject, py:int;
			len = _holder.numChildren;
			for(i = 0; i < len; ++i) {
				item = _holder.getChildAt(i);
				if(item == _cancel) break;
				item.y = py;
				py += item.height + 10;
			}
			
			_cancel.y = _submit.y;
			_submit.x = _WIDTH * .5 - _submit.width - 10;
			_cancel.x = _WIDTH * .5 + 10;
			roundPos(_submit, _cancel);
			
			_window.forcedContentHeight = py - 10;
			_window.updateSizes();
			PosUtils.centerInStage(_window);
			var menu:SideMenuView = ViewLocator.getInstance().locateViewByType(SideMenuView) as SideMenuView;
			if(menu != null) {
				_window.x = menu.x + menu.width + Math.round((stage.stageWidth - (menu.x + menu.width) - width) * .5);
			}
			_disable.graphics.clear();
			_disable.graphics.beginFill(0, .3);
			_disable.graphics.drawRect(0, 0, stage.stageWidth, stage.stageHeight);
			_disable.graphics.endFill();
		}
		
		/**
		 * Flags the content as opened when opening transition completes.
		 * This prevents the view to close right after opening.
		 * When clicking a box it tells the model to open this view which opens
		 * synchronously. But right after, the stage click is detected by this
		 * view, which makes it close if this trick isn't done.
		 */
		private function flagOpened():void { _closed = false; }

		
		/**
		 * Called when submit or close button is clicked.
		 */
		private function clickButtonHandler(event:MouseEvent):void {
			if(event.currentTarget == _cancel) close();
			if(event.currentTarget == _submit) submit();
		}
		
		/**
		 * Called when disable layer is clicked to close the window
		 */
		private function clickDisableHandler(event:MouseEvent):void {
			if(!_closed) close();
		}
		
		/**
		 * Submit the form
		 */
		private function submit():void {
			_place.save( _data );
			_type.save( _data );
			_times.save( _data );
			_choices.save( _data );
			_sound.save( _data );
			_data.startsTree	= _startTree.selected;
			_data.endsQuest		= _endsQuest.selected;
			_data.loosesQuest	= _loosesQuest.selected;
			_data.submit();
			close();
		}
		
	}
}