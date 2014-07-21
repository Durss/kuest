package com.twinoid.kube.quest.editor.components.form.edit {
	import gs.TweenLite;

	import treefortress.sound.SoundAS;
	import treefortress.sound.SoundInstance;

	import com.nurun.components.button.visitors.applyDefaultFrameVisitorNoTween;
	import com.nurun.components.form.events.FormComponentEvent;
	import com.nurun.components.form.events.ListEvent;
	import com.nurun.components.text.CssTextField;
	import com.nurun.core.lang.isEmpty;
	import com.nurun.structure.environnement.label.Label;
	import com.nurun.utils.pos.roundPos;
	import com.nurun.utils.string.StringUtils;
	import com.twinoid.kube.quest.editor.components.LoaderSpinning;
	import com.twinoid.kube.quest.editor.components.buttons.GraphicButtonKube;
	import com.twinoid.kube.quest.editor.components.form.CheckBoxKube;
	import com.twinoid.kube.quest.editor.components.form.input.ComboboxItem;
	import com.twinoid.kube.quest.editor.components.form.input.ComboboxKube;
	import com.twinoid.kube.quest.editor.components.form.input.InputKube;
	import com.twinoid.kube.quest.editor.utils.SfxrSynth;
	import com.twinoid.kube.quest.editor.utils.setToolTip;
	import com.twinoid.kube.quest.editor.vo.ActionSound;
	import com.twinoid.kube.quest.editor.vo.KuestEvent;
	import com.twinoid.kube.quest.graphics.EventChoiceYupIcon;
	import com.twinoid.kube.quest.graphics.HelpSmallIcon;
	import com.twinoid.kube.quest.graphics.PlaySoundIcon;
	import com.twinoid.kube.quest.graphics.StopSoundIcon;

	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.FocusEvent;
	import flash.events.MouseEvent;
	import flash.net.URLRequest;
	import flash.net.navigateToURL;
	import flash.utils.clearTimeout;
	import flash.utils.getTimer;
	import flash.utils.setTimeout;
	
	/**
	 * 
	 * @author Francois
	 * @date 22 mai 2013;
	 */
	public class EditEventSound extends AbstractEditZone {
		private var _formUrlSFXRHolder:Sprite;
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
		private var _titleURL:CssTextField;
		private var _titleSFXR:CssTextField;
		private var _cbSFXR:ComboboxKube;
		private var _inputSFXR:InputKube;
		private var _testSFXRBt:GraphicButtonKube;
		private var _helpSFXR:GraphicButtonKube;
		private var _synth:SfxrSynth;
		
		
		
		
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
			value				+= 10;
			_inputURL.tabIndex	= value++;
			_testBt.tabIndex	= value++;
			_loop.tabIndex		= value++;
			_inputSFXR.tabIndex	= value++;
			_testSFXRBt.tabIndex= value++;
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
				if(_testSFXRBt.enabled && StringUtils.trim(_inputSFXR.value as String).length > 0) {
					data.actionSound.sfxr = _inputSFXR.text;
				}
			}
			SoundAS.stopAll();
		}
		
		/**
		 * Loads the configuration to the value object
		 */
		public function load(data:KuestEvent):void {
			var enabled:Boolean = false;
			if (data.actionSound != null) {
				if(data.actionSound.sfxr != null && StringUtils.trim(data.actionSound.sfxr).length > 0) {
					_inputSFXR.text = data.actionSound.sfxr;
					enabled = true;
				}else{
					_inputSFXR.text = '';
				}
				
				if (data.actionSound.url != null && StringUtils.trim(data.actionSound.url).length > 0) {
					_inputURL.text = data.actionSound.url;
					_loop.selected = data.actionSound.loop;
					enabled = true;
				}else{
					clearSoundPlayerState();
				}
			}else{
				clearSoundPlayerState();
			}
			
			super.onload(enabled, 0);
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
			
			addEntry(new EventChoiceYupIcon(), _formUrlSFXRHolder, Label.getLabel("editWindow-sound-urlTT"));
		}

		private function buildUrlForm():void {
			_synth		= new SfxrSynth();
			_formUrlSFXRHolder = new Sprite();
			_titleURL	= _formUrlSFXRHolder.addChild(new CssTextField("editWindow-label")) as CssTextField;
			_inputURL	= _formUrlSFXRHolder.addChild(new InputKube("http://")) as InputKube;
			_testBt		= _formUrlSFXRHolder.addChild(new GraphicButtonKube(new PlaySoundIcon())) as GraphicButtonKube;
			_result		= _formUrlSFXRHolder.addChild(new CssTextField("editWindow-label")) as CssTextField;
			_spin		= _formUrlSFXRHolder.addChild(new LoaderSpinning()) as LoaderSpinning;
			_loop		= _formUrlSFXRHolder.addChild(new CheckBoxKube(Label.getLabel("editWindow-sound-sfxrPresetsTitle"))) as CheckBoxKube;
			_titleSFXR	= _formUrlSFXRHolder.addChild(new CssTextField("editWindow-label")) as CssTextField;
			_cbSFXR		= _formUrlSFXRHolder.addChild(new ComboboxKube(Label.getLabel('editWindow-sound-sfxrPresetsTitle'), false, false, false)) as ComboboxKube;
			_inputSFXR	= _formUrlSFXRHolder.addChild(new InputKube("SFXR...")) as InputKube;
			_testSFXRBt	= _formUrlSFXRHolder.addChild(new GraphicButtonKube(new PlaySoundIcon())) as GraphicButtonKube;
			_helpSFXR	= _formUrlSFXRHolder.addChild(new GraphicButtonKube(new HelpSmallIcon(), false)) as GraphicButtonKube;
			
			_stopIcon	= new StopSoundIcon();
			_playIcon	= _testBt.icon;
			
			_titleURL.text			= Label.getLabel("editWindow-sound-urlTitle");
			_titleSFXR.text			= Label.getLabel("editWindow-sound-sfxrTitle");
			_result.background		= true;
			_result.backgroundColor	= 0x47A9D1;
			applyDefaultFrameVisitorNoTween(_testBt, _stopIcon);
			
			setToolTip(_helpSFXR, Label.getLabel('editWindow-sound-sfxrHelpTT'));
			
			//Populate SFXpresets
			var i:int = 1;
			while(Label.getLabel('editWindow-sound-sfxrPreset-'+i).indexOf('missing lbl') == -1) {
				var chunks:Array = Label.getLabel('editWindow-sound-sfxrPreset-'+i).split('|');
				_cbSFXR.addSkinnedItem(chunks[0], chunks[1]);
				i++;
			}
			_cbSFXR.validate();
			
			_titleURL.width	= _width;
			_testBt.enabled	= false;
			_testBt.width	= _testBt.height = _inputURL.height;
			_testBt.x		= _width - _testBt.width;
			_inputURL.y		= _testBt.y = _titleURL.height;
			_inputURL.width	= _width - _testBt.width - 2;
			_result.x		= _inputURL.x + 1;
			_result.y		= _inputURL.y + 1;
			_result.width	= _inputURL.width - 2;
			_loop.y			= _inputURL.y + _inputURL.height + 2;
			_result.text	= Label.getLabel("editWindow-sound-testSuccess");
			_result.alpha	= 0;
			_result.visible	= false;
			_cbSFXR.listWidth = _width - _testBt.width;
			
			_titleSFXR.x	= _helpSFXR.width;
			_titleSFXR.y	= _loop.y + _loop.height + 20;
			_inputSFXR.y	= _testSFXRBt.y = _cbSFXR.y = _titleSFXR.y + _titleSFXR.height;
			_titleSFXR.width= _width - _helpSFXR.width;
			_inputSFXR.x	= _cbSFXR.x + _cbSFXR.width + 5;
			_helpSFXR.y		= _titleSFXR.y + _titleSFXR.height - _helpSFXR.height;
			_testSFXRBt.width= _testSFXRBt.height = _cbSFXR.height = _inputSFXR.height;
			_testSFXRBt.x	= _width - _testBt.width;
			_inputSFXR.width= _width - _testSFXRBt.width - 2 - _cbSFXR.width - 2;
			
			SoundAS.loadFailed.addOnce(onSoundError);
			
			_testBt.addEventListener(MouseEvent.CLICK, clickHandler);
			_testSFXRBt.addEventListener(MouseEvent.CLICK, clickHandler);
			_helpSFXR.addEventListener(MouseEvent.CLICK, clickHandler);
			_inputURL.addEventListener(Event.CHANGE, changeUrlHandler);
			_inputSFXR.addEventListener(Event.CHANGE, changeSFXRHandler);
			_inputSFXR.addEventListener(FocusEvent.FOCUS_IN, focusInputHandler);
			_inputSFXR.addEventListener(FocusEvent.FOCUS_OUT, focusInputHandler);
			_inputURL.addEventListener(FocusEvent.FOCUS_IN, focusInputHandler);
			_inputURL.addEventListener(MouseEvent.MOUSE_DOWN, mouseUpInputHandler);
			_inputURL.addEventListener(FormComponentEvent.SUBMIT, clickHandler);
			_inputSFXR.addEventListener(FormComponentEvent.SUBMIT, clickHandler);
			_cbSFXR.addEventListener(ListEvent.SELECT_ITEM, selectComboBoxItemHandler);
			_cbSFXR.addEventListener(MouseEvent.MOUSE_OVER, overComboBoxItemHandler);
			
			roundPos(_testBt, _inputURL, _result, _loop, _cbSFXR, _inputSFXR, _titleSFXR, _testSFXRBt, _helpSFXR);
			
			_formUrlSFXRHolder.graphics.beginFill(0x8BC9E2, 1);
			_formUrlSFXRHolder.graphics.drawRect(0, _titleSFXR.y - 10, _width, 1);
			_formUrlSFXRHolder.graphics.endFill();
		}

		private function overComboBoxItemHandler(event : MouseEvent) : void {
			if(event.target is ComboboxItem) {
				//Dirty hack to detect which item is rolled over and get its data
				//Something should be native in the component for this...
				var index:int = _cbSFXR.list.scrollableList.container.getChildIndex(event.target as ComboboxItem);
				var chunks:Array = Label.getLabel('editWindow-sound-sfxrPreset-' + (index+1)).split('|');
				
				_synth.stop();
				_synth.params.setSettingsString( chunks[1] );
				_synth.play();
			}
		}
		
		/**
		 * Called when user selects a sound from the combobox
		 */
		private function selectComboBoxItemHandler(event:ListEvent):void {
			_inputSFXR.text = event.data;
		}
		
		/**
		 * Called when URL changes.
		 */
		private function changeUrlHandler(event:Event):void {
			var url:String = String(_inputURL.value);
			_testBt.enabled = !isEmpty(url) && /^https?:\/\/.*/gi.test(url);
		}
		
		/**
		 * Called when SFXR data changes
		 */
		private function changeSFXRHandler(event:Event):void {
			_testSFXRBt.enabled = _inputSFXR.text.split(',').length == 24;
		}
		
		/**
		 * Called when a button is clicked.
		 * 
		 * In case of distant sound button :
		 * If already playing, it cuts the sound.
		 * If no sound is playing, start the loading/playing and wait for
		 * data to come on SoundMixer.
		 * 
		 * In case of SFXR test button, it plays the sound
		 */
		private function clickHandler(event:Event):void {
			if(event.currentTarget == _testBt || event.currentTarget == _inputURL) {
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
			}else
			
			if(event.currentTarget == _testSFXRBt || event.currentTarget == _inputSFXR) {
				_synth.stop();
				_synth.params.setSettingsString( _inputSFXR.text );
				_synth.play();
			}else
			
			if(event.currentTarget == _helpSFXR) {
				navigateToURL(new URLRequest('http://www.superflashbros.net/as3sfxr/'), '_blank');
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
			if(event.currentTarget == _inputURL) {
				if(_inputURL.text.length == 0) {
					_inputURL.text = "http://";
				}
				_lastFocusTime = getTimer();
			}else{
				changeSFXRHandler(event);
			}
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

		private function clearSoundPlayerState():void {
			SoundAS.stopAll();
			_inputURL.text = "";
			_spin.close();
			_inputURL.enabled = true;
			_loop.selected = false;
			_testBt.icon = _playIcon;
			_testBt.enabled = false;
			removeEventListener(Event.ENTER_FRAME, enterFrameHandler);
		}

		private function hideResult():void {
			_result.alpha = 0;
			TweenLite.to(_result, .25, {autoAlpha:0});
		}
		
	}
}