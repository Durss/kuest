package com.twinoid.kube.quest.editor.components.form.edit {
	import gs.TweenLite;

	import treefortress.sound.SoundAS;
	import treefortress.sound.SoundInstance;

	import com.nurun.components.button.visitors.applyDefaultFrameVisitorNoTween;
	import com.nurun.components.form.events.FormComponentEvent;
	import com.nurun.components.text.CssTextField;
	import com.nurun.core.lang.isEmpty;
	import com.nurun.structure.environnement.label.Label;
	import com.nurun.utils.pos.roundPos;
	import com.nurun.utils.string.StringUtils;
	import com.twinoid.kube.quest.editor.components.LoaderSpinning;
	import com.twinoid.kube.quest.editor.components.buttons.GraphicButtonKube;
	import com.twinoid.kube.quest.editor.components.form.CheckBoxKube;
	import com.twinoid.kube.quest.editor.components.form.input.InputKube;
	import com.twinoid.kube.quest.editor.vo.ActionSound;
	import com.twinoid.kube.quest.editor.vo.KuestEvent;
	import com.twinoid.kube.quest.graphics.EventChoiceYupIcon;
	import com.twinoid.kube.quest.graphics.PlaySoundIcon;
	import com.twinoid.kube.quest.graphics.StopSoundIcon;

	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.FocusEvent;
	import flash.events.MouseEvent;
	import flash.utils.clearTimeout;
	import flash.utils.getTimer;
	import flash.utils.setTimeout;
	
	/**
	 * 
	 * @author Francois
	 * @date 22 mai 2013;
	 */
	public class EditEventSound extends AbstractEditZone {
		private var _formUrlHolder:Sprite;
		private var _inputURL:InputKube;
		private var _testBt:GraphicButtonKube;
		private var _spin:LoaderSpinning;
		private var _stopIcon:StopSoundIcon;
		private var _playIcon:DisplayObject;
		private var _lastFocusTime:int;
		private var _result:CssTextField;
		private var _timeout:uint;
		private var _loop:CheckBoxKube;
		private var _currentSound:SoundInstance;
		
		
		
		
		/* *********** *
		 * CONSTRUCTOR *
		 * *********** */
		/**
		 * Creates an instance of <code>EditEventSound</code>.
		 */
		public function EditEventSound(width:int) {
			super(Label.getLabel("editWindow-sound-title"), width, true);
		}

		
		
		/* ***************** *
		 * GETTERS / SETTERS *
		 * ***************** */
		/**
		 * @inheritDoc
		 */
		override public function set tabIndex(value:int):void {
			super.tabIndex		= value;
			_inputURL.tabIndex	= value + 10;
		}



		/* ****** *
		 * PUBLIC *
		 * ****** */
		/**
		 * Saves the configurations to the value object
		 */
		public function save(data:KuestEvent):void {
			if(!enabled) {
				data.actionSound = new ActionSound();
			}else{
				data.actionSound = new ActionSound();
				if(_testBt.enabled) {
					data.actionSound.url = _inputURL.text;
					data.actionSound.loop = _loop.selected;
				}
			}
			SoundAS.stopAll();
		}
		
		/**
		 * Loads the configuration to the value object
		 */
		public function load(data:KuestEvent):void {
			if (data.actionSound != null) {
				if (data.actionSound.url != null && StringUtils.trim(data.actionSound.url).length > 0) {
					_inputURL.text = data.actionSound.url;
					_loop.selected = data.actionSound.loop;
					selectedIndex = 0;
					enabled = true;
					return;
				}
			}
			
			enabled = false;
			selectedIndex = 0;
			SoundAS.stopAll();
			_inputURL.text = "";
			_spin.close();
			_inputURL.enabled = true;
			_loop.selected = false;
			_testBt.icon = _playIcon;
			_testBt.enabled = false;
			removeEventListener(Event.ENTER_FRAME, enterFrameHandler);
		}


		
		
		/* ******* *
		 * PRIVATE *
		 * ******* */
		/**
		 * Initialize the class.
		 */
		override protected function initialize():void {
			super.initialize();
			
			buildUrlForm();
			
//			addEntry(new EventChoiceNoneIcon(), new Sprite(), Label.getLabel("editWindow-sound-noneTT"));
			addEntry(new EventChoiceYupIcon(), _formUrlHolder, Label.getLabel("editWindow-sound-urlTT"));
		}

		private function buildUrlForm():void {
			_formUrlHolder = new Sprite();
			var title:CssTextField = _formUrlHolder.addChild(new CssTextField("editWindow-label")) as CssTextField;
			_inputURL	= _formUrlHolder.addChild(new InputKube("http://")) as InputKube;
			_testBt		= _formUrlHolder.addChild(new GraphicButtonKube(new PlaySoundIcon())) as GraphicButtonKube;
			_result		= _formUrlHolder.addChild(new CssTextField("editWindow-label")) as CssTextField;
			_spin		= _formUrlHolder.addChild(new LoaderSpinning()) as LoaderSpinning;
			_loop		= _formUrlHolder.addChild(new CheckBoxKube(Label.getLabel("editWindow-sound-loop"))) as CheckBoxKube;
			_stopIcon	= new StopSoundIcon();
			_playIcon	= _testBt.icon;
			
			title.text	= Label.getLabel("editWindow-sound-urlTitle");
			_result.background = true;
			_result.backgroundColor = 0x47A9D1;
			applyDefaultFrameVisitorNoTween(_testBt, _stopIcon);
			
			title.width		= _width;
			_testBt.enabled	= false;
			_testBt.width	= _testBt.height = _inputURL.height;
			_testBt.x		= _width - _testBt.width;
			_inputURL.y		= _testBt.y = title.height;
			_inputURL.width	= _width - _testBt.width - 2;
			_result.x		= _inputURL.x + 1;
			_result.y		= _inputURL.y + 1;
			_result.width	= _inputURL.width - 2;
			_loop.y			= _inputURL.y + _inputURL.height + 2;
			_result.text	= Label.getLabel("editWindow-sound-testSuccess");
			_result.alpha	= 0;
			_result.visible	= false;
			
			SoundAS.loadFailed.addOnce(onSoundError);
			
			_testBt.addEventListener(MouseEvent.CLICK, clickTestHandler);
			_inputURL.addEventListener(Event.CHANGE, changeUrlHandler);
			_inputURL.addEventListener(FocusEvent.FOCUS_IN, focusInputHandler);
			_inputURL.addEventListener(MouseEvent.MOUSE_DOWN, mouseUpInputHandler);
			_inputURL.addEventListener(FormComponentEvent.SUBMIT, clickTestHandler);
			
			roundPos(_testBt, _inputURL, _result, _loop);
			
		}
		
		/**
		 * Called when URL changes.
		 */
		private function changeUrlHandler(event:Event):void {
			var url:String = String(_inputURL.value);
			_testBt.enabled = !isEmpty(url) && /^https?:\/\/.*/gi.test(url);
		}
		
		/**
		 * Called when test button is clicked.
		 * If already playing, it cuts the sound.
		 * If no sound is playing, start the loading/playing and wait for
		 * data to come on SoundMixer.
		 */
		private function clickTestHandler(event:Event):void {
			if(!_testBt.enabled) return;
			
			SoundAS.stopAll();
			if(_testBt.icon == _playIcon) {
				_testBt.enabled = false;
				_inputURL.enabled = false;
				_spin.open();
				_spin.x = _width * .5;
				_spin.y = _inputURL.y + _inputURL.height * .5;
				
				SoundAS.loadSound(_inputURL.text, "test", 0);
				_currentSound = SoundAS.play("test");
				_currentSound.soundCompleted.addOnce(onSoundComplete);
				addEventListener(Event.ENTER_FRAME, enterFrameHandler);
			}else{
				_testBt.icon = _playIcon;
			}
		}

		private function enterFrameHandler(event:Event):void {
			if (_currentSound.position > 100) {
				_testBt.enabled = _inputURL.enabled = true;
				_spin.close();				
				_inputURL.successFlash();
				_testBt.icon = _stopIcon;
				_result.text = Label.getLabel("editWindow-sound-testSuccess");
				TweenLite.to(_result, .25, {autoAlpha:1});
				clearTimeout(_timeout);
				_timeout = setTimeout(hideResult, 2000);
				removeEventListener(Event.ENTER_FRAME, enterFrameHandler);
			}
		}

		private function onSoundComplete(s:SoundInstance):void {
			s;//avoid unused warning
			_testBt.icon = _playIcon;
		}


		private function focusInputHandler(event:FocusEvent):void {
			if(_inputURL.text.length == 0) {
				_inputURL.text = "http://";
			}
			_lastFocusTime = getTimer();
		}

		private function mouseUpInputHandler(event:MouseEvent):void {
			if(getTimer() - _lastFocusTime < 100) {
				_inputURL.textfield.setSelection(0, _inputURL.text.length);
			}
		}

		private function onSoundError(s:SoundInstance):void {
			s;//avoid unused warning
			TweenLite.to(_result, .25, {autoAlpha:1});
			_result.text	= Label.getLabel("editWindow-sound-testError");
			_testBt.enabled	= _inputURL.enabled = true;
			_spin.close();
			_inputURL.errorFlash();
			clearTimeout(_timeout);
			_timeout = setTimeout(hideResult, 2000);
		}

		private function hideResult():void {
			_result.alpha = 0;
			TweenLite.to(_result, .25, {autoAlpha:0});
		}
		
	}
}