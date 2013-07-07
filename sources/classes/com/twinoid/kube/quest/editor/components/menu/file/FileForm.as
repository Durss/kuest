package com.twinoid.kube.quest.editor.components.menu.file {
	import com.twinoid.kube.quest.graphics.HelpIcon;
	import com.nurun.structure.environnement.label.Label;
	import com.nurun.structure.environnement.path.Path;
	import com.nurun.structure.mvc.views.ViewLocator;
	import com.nurun.utils.pos.PosUtils;
	import com.nurun.utils.pos.roundPos;
	import com.twinoid.kube.quest.editor.components.LoaderSpinning;
	import com.twinoid.kube.quest.editor.components.buttons.ButtonKube;
	import com.twinoid.kube.quest.editor.components.buttons.GraphicButtonKube;
	import com.twinoid.kube.quest.editor.controler.FrontControler;
	import com.twinoid.kube.quest.editor.events.ToolTipEvent;
	import com.twinoid.kube.quest.editor.events.ViewEvent;
	import com.twinoid.kube.quest.editor.model.Model;
	import com.twinoid.kube.quest.editor.vo.ToolTipAlign;
	import com.twinoid.kube.quest.graphics.DeployIcon;
	import com.twinoid.kube.quest.graphics.LoadIcon;
	import com.twinoid.kube.quest.graphics.NewFileIcon;
	import com.twinoid.kube.quest.graphics.ParamsIcon;
	import com.twinoid.kube.quest.graphics.SaveIcon;
	import com.twinoid.kube.quest.graphics.SaveNewIcon;

	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.net.URLRequest;
	import flash.net.navigateToURL;
	import flash.ui.Keyboard;
	import flash.utils.Dictionary;

	
	[Event(name="resize", type="flash.events.Event")]
	
	/**
	 * Displays the file menu.
	 * Contains the load/save/create/params buttons.
	 * 
	 * @author Francois
	 * @date 28 avr. 2013;
	 */
	public class FileForm extends Sprite {
		
		private var _width:int;
		private var _componentToTTID:Dictionary;
		private var _clearBt:ButtonKube;
		private var _loadBt:ButtonKube;
		private var _saveBt:ButtonKube;
		private var _publishBt:ButtonKube;
		private var _testBt:ButtonKube;
		private var _saveForm:FileSaveForm;
		private var _saveNewBt:GraphicButtonKube;
		private var _spin:LoaderSpinning;
		private var _loadForm:FileLoadForm;
		private var _model:Model;
		private var _publishForm:FilePublishForm;
		private var _prevKuestGUID:String;
		private var _helpBt:ButtonKube;
		private var _helpForm:FileHelpForm;
		
		
		
		/* *********** *
		 * CONSTRUCTOR *
		 * *********** */
		/**
		 * Creates an instance of <code>FileForm</code>.
		 */

		public function FileForm(width:int) {
			_width = width;
			initialize();
		}

		
		
		/* ***************** *
		 * GETTERS / SETTERS *
		 * ***************** */
		/**
		 * @inheritDoc
		 */
		override public function set tabIndex(value:int):void {
			_clearBt.tabIndex	= value;
			_loadBt.tabIndex	= value + 1;
			_saveBt.tabIndex	= value + 2;
			_publishBt.tabIndex	= value + 3;
			_testBt.tabIndex	= value + 4;
			_helpBt.tabIndex	= value + 5;
		}



		/* ****** *
		 * PUBLIC *
		 * ****** */
		/**
		 * Called on model's update
		 */
		public function update(model:Model):void {
			_model = model;
			_saveNewBt.visible = model.currentKuest != null;
			_publishBt.enabled = _testBt.enabled = _saveNewBt.visible;
			_loadForm.populate(model.kuests);
			_saveForm.populate(model.currentKuest, model.friends);
			_helpForm.populate(model.samples);
			if(model.currentKuestGUID != _prevKuestGUID) _publishForm.close();
			_prevKuestGUID = model.currentKuestGUID;
			computePositions();
		}


		
		
		/* ******* *
		 * PRIVATE *
		 * ******* */
		/**
		 * Initialize the class.
		 */
		private function initialize():void {
			_clearBt	= addChild(new ButtonKube(Label.getLabel("menu-file-new"), new NewFileIcon(), true)) as ButtonKube;
			_loadBt		= addChild(new ButtonKube(Label.getLabel("menu-file-load"), new LoadIcon(), true)) as ButtonKube;
			_saveBt		= addChild(new ButtonKube(Label.getLabel("menu-file-save"), new SaveIcon(), true)) as ButtonKube;
			_publishBt	= addChild(new ButtonKube(Label.getLabel("menu-file-publish"), new DeployIcon(), true)) as ButtonKube;
			_testBt		= addChild(new ButtonKube(Label.getLabel("menu-file-test"), new ParamsIcon(), true)) as ButtonKube;
			_helpBt		= addChild(new ButtonKube(Label.getLabel("menu-file-help"), new HelpIcon(), true)) as ButtonKube;
			_saveNewBt	= addChild(new GraphicButtonKube(new SaveNewIcon())) as GraphicButtonKube;
			_loadForm	= addChild(new FileLoadForm(_width)) as FileLoadForm;
			_saveForm	= addChild(new FileSaveForm(_width)) as FileSaveForm;
			_publishForm= addChild(new FilePublishForm(_width)) as FilePublishForm;
			_helpForm	= addChild(new FileHelpForm(_width)) as FileHelpForm;
			_spin		= addChild(new LoaderSpinning()) as LoaderSpinning;
			
			_saveNewBt.visible = false;
			
			_componentToTTID = new Dictionary();
			_componentToTTID[_clearBt] = "menu-file-clearTT";
			_componentToTTID[_saveNewBt] = "menu-file-saveNewTT";
			_componentToTTID[_publishBt] = "menu-file-publishTT";
//			_componentToTTID[_loadBt] = "file-loadTT";
			
			_saveBt.addEventListener(MouseEvent.ROLL_OVER, rollOverHandler);
			_saveNewBt.addEventListener(MouseEvent.ROLL_OVER, rollOverHandler);
			_saveForm.addEventListener(MouseEvent.ROLL_OVER, rollOverHandler);
			addEventListener(MouseEvent.CLICK, clickHandler);
			_saveForm.addEventListener(Event.RESIZE, computePositions);
			_loadForm.addEventListener(Event.RESIZE, computePositions);
			_helpForm.addEventListener(Event.RESIZE, computePositions);
			_publishForm.addEventListener(Event.RESIZE, computePositions);
			addEventListener(Event.ADDED_TO_STAGE, addedToStageHandler);
			ViewLocator.getInstance().addEventListener(ViewEvent.LOGIN_SUCCESS, loginHandler);
			
			computePositions();
		}
		
		/**
		 * Called when the stage is available.
		 */
		private function addedToStageHandler(event:Event):void {
			removeEventListener(Event.ADDED_TO_STAGE, addedToStageHandler);
			stage.addEventListener(KeyboardEvent.KEY_UP, keyUpHandler);
		}
		
		/**
		 * Resizes and replaces the elements.
		 */
		private function computePositions(event:Event = null):void {
			_clearBt.width = _loadBt.width = _saveBt.width = _publishBt.width = _testBt.width = _helpBt.width = _width;
			PosUtils.vPlaceNext(10, _clearBt, _loadBt);
			PosUtils.vPlaceNext(0, _loadBt, _loadForm);
			PosUtils.vPlaceNext(10, _loadForm, _saveBt);
			PosUtils.vPlaceNext(0, _saveBt, _saveForm);
			PosUtils.vPlaceNext(10, _saveForm, _publishBt);
			PosUtils.vPlaceNext(0, _publishBt, _publishForm);
			PosUtils.vPlaceNext(10, _publishForm, _testBt, _helpBt);
			PosUtils.vPlaceNext(0, _helpBt, _helpForm);
			
			//If we already saved the kuest or if we loaded one, display the
			//"save new" button to allow to save it as a new map.
			if(_saveNewBt.visible ) {
				_saveNewBt.height = _saveBt.height;
				_saveNewBt.x = _saveBt.width - _saveNewBt.width;
				_saveNewBt.y = _saveBt.y;
				_saveBt.width -= _saveNewBt.width -2;
			}
			
			if(_saveForm.height == 0 && _saveForm.isClosed && contains(_saveForm)) removeChild(_saveForm);
			if(_loadForm.height == 0 && _loadForm.isClosed && contains(_loadForm)) removeChild(_loadForm);
			if(_publishForm.height == 0 && _publishForm.isClosed && contains(_publishForm)) removeChild(_publishForm);
			if(_helpForm.height == 0 && _helpForm.isClosed && contains(_helpForm)) removeChild(_helpForm);
			
			roundPos(_clearBt, _saveForm, _loadBt, _saveBt, _saveNewBt, _publishBt, _publishForm, _testBt, _helpBt, _helpForm);
			
			dispatchEvent(new Event(Event.RESIZE));
		}
		
		/**
		 * Called when a component is rolled over.
		 */
		private function rollOverHandler(event:MouseEvent):void {
			var labelID:String = _componentToTTID[event.currentTarget];
			if(labelID != null) {
				EventDispatcher(event.currentTarget).dispatchEvent(new ToolTipEvent(ToolTipEvent.OPEN, Label.getLabel(labelID), ToolTipAlign.TOP));
			}
		}
		
		/**
		 * Called when a component is clicked
		 */
		private function clickHandler(event:MouseEvent):void {
			if(event.target == _saveBt) {
				if(_saveForm.isClosed) addChildAt(_saveForm, getChildIndex(_saveBt)+1);
				_saveForm.toggle(_saveNewBt.visible);
			}else
			 
			if(event.target == _saveNewBt) {
				if(_saveForm.isClosed) addChildAt(_saveForm, getChildIndex(_saveBt)+1);
				_saveForm.toggle();
				
			}else 
			
			if(event.target == _loadBt) {
				addChildAt(_loadForm, getChildIndex(_loadBt)+1);
				_loadForm.toggle();
			}else
			
			if(event.target == _clearBt) {
				FrontControler.getInstance().clear();
			}else
			
			if(event.target == _publishBt) {
				_publishBt.enabled = false;
				_spin.x = _publishBt.x + _publishBt.width * .5;
				_spin.y = _publishBt.y + _publishBt.height * .5;
				_spin.open(Label.getLabel("loader-publishing"));
				FrontControler.getInstance().save(_saveForm.title, _saveForm.description, _saveForm.friends, onPublish, true);
			}else
			
			if(event.target == _testBt) {
				navigateToURL(new URLRequest(Path.compute("{v_root}/redirect.php?kuest="+_model.currentKuestGUID+"&test")));
			}else
			
			if(event.target == _helpBt) {
				addChildAt(_helpForm, getChildIndex(_helpBt)+1);
				_helpForm.toggle();
			}
		}
		
		/**
		 * Called when saving completes/fails
		 */
		private function onSave(succes:Boolean = false, errorID:String = "", progress:Number = NaN):void {
			progress;//can't work for upload :(
			errorID;//
			_saveBt.enabled = true;
			_saveNewBt.enabled = true;
			if(succes) {
				_spin.close(Label.getLabel("loader-savingOK"));
			}else {
				_spin.close(Label.getLabel("loader-savingKO"));
			}
		}
		
		/**
		 * Called when saving completes/fails
		 */
		private function onPublish(success:Boolean = false, errorID:String = "", publishID:String = ""):void {
			_publishBt.enabled = true;
			if(success) {
				if (publishID.length > 0) {
					addChildAt(_publishForm, 0);
					_publishForm.populate(publishID);
					_publishForm.open();
				}
				_spin.close(Label.getLabel("loader-publishingOK"));
			}else if(errorID.length > 0){//if no error ID, it's a canceled prompt window.
				_spin.close(Label.getLabel("loader-publishingKO"));
			}else{
				_spin.close();
			}
		}
		
		/**
		 * Called when a key is released.
		 * Listenes for CTRL+S to save the current kuest.
		 */
		private function keyUpHandler(event:KeyboardEvent):void {
			if(event.keyCode == Keyboard.S && event.ctrlKey && _saveNewBt.visible && _saveBt.enabled) {
				_spin.x = _saveBt.x + _saveBt.width * .5;
				_spin.y = _saveBt.y + _saveBt.height * .5;
				_spin.open(Label.getLabel("loader-saving"));
				_saveBt.enabled = false;
				_saveNewBt.enabled = false;
				FrontControler.getInstance().save(_saveForm.title, _saveForm.description, _saveForm.friends, onSave, false, true);
			}
		}
		
		/**
		 * Called when loading completes.
		 * Update the kuests links.
		 */
		private function loginHandler(event:ViewEvent):void {
			_loadForm.populate(_model.kuests);
			_helpForm.populate(_model.samples);
		}
		
	}
}