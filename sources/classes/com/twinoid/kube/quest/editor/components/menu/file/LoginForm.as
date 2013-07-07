package com.twinoid.kube.quest.editor.components.menu.file {
	import com.nurun.components.form.events.FormComponentEvent;
	import com.nurun.components.text.CssTextField;
	import com.nurun.structure.environnement.label.Label;
	import com.nurun.utils.pos.PosUtils;
	import com.nurun.utils.string.StringUtils;
	import com.twinoid.kube.quest.editor.components.buttons.ButtonKube;
	import com.twinoid.kube.quest.editor.components.form.input.InputKube;
	import com.twinoid.kube.quest.editor.controler.FrontControler;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import gs.TweenLite;

	
	/**
	 * 
	 * @author Francois
	 * @date 28 avr. 2013;
	 */
	public class LoginForm extends Sprite {
		private var _uid:InputKube;
		private var _pubkey:InputKube;
		private var _width:int;
		private var _submit:ButtonKube;
		private var _label:CssTextField;
		private var _error:CssTextField;
		
		
		
		
		/* *********** *
		 * CONSTRUCTOR *
		 * *********** */
		/**
		 * Creates an instance of <code>LoginForm</code>.
		 */

		public function LoginForm(width:int) {
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
			_uid.tabIndex		= value;
			_pubkey.tabIndex	= value + 1;
			_submit.tabIndex	= value + 2;
		}



		/* ****** *
		 * PUBLIC *
		 * ****** */
		/**
		 * Sets the error's ID.
		 */
		public function setErrorID(id:String):void {
			id;//avoid unused warnings from FDT
			_error.text = Label.getLabel("login-invalidIDS");
			TweenLite.killTweensOf(_error);
			
			_error.alpha = 0;
			TweenLite.to(_error, .25, {alpha:1});
			TweenLite.to(_error, .25, {alpha:0, delay:5});
			computePositions();
		}
		
		/**
		 * Populates the inputs
		 */
		public function populate(uid:String, pubkey:String):void {
			if(uid != null) _uid.text = uid;
			if(pubkey != null) _pubkey.text = pubkey;
		}


		
		
		/* ******* *
		 * PRIVATE *
		 * ******* */
		/**
		 * Initialize the class.
		 */
		private function initialize():void {
			_label = addChild(new CssTextField("menu-label")) as CssTextField;
			_uid = addChild(new InputKube(Label.getLabel("login-uid"))) as InputKube;
			_pubkey = addChild(new InputKube(Label.getLabel("login-pubkey"))) as InputKube;
			_submit = addChild(new ButtonKube(Label.getLabel("login-submit"))) as ButtonKube;
			_error = addChild(new CssTextField("errorBig")) as CssTextField;
			
			_label.text = Label.getLabel("login-title");
			
			_submit.addEventListener(MouseEvent.CLICK, submitHandler);
			_uid.addEventListener(FormComponentEvent.SUBMIT, submitHandler);
			_pubkey.addEventListener(FormComponentEvent.SUBMIT, submitHandler);
			
			computePositions();
		}
		
		/**
		 * Submits the form
		 */
		private function submitHandler(event:Event):void {
			if(StringUtils.trim(_uid.value as String).length == 0) {
				_uid.errorFlash();
				stage.focus = _uid;
				return;
			}
			if(StringUtils.trim(_pubkey.value as String).length == 0) {
				_pubkey.errorFlash();
				stage.focus = _pubkey;
				return;
			}
			_error.text = "";
			FrontControler.getInstance().login(StringUtils.trim(_uid.text), StringUtils.trim(_pubkey.text));
		}
		
		/**
		 * Resizes and replaces the elements.
		 */
		private function computePositions():void {
			_uid.width = _width;
			_pubkey.width = _width;
			_submit.width = _width * .5;
			_label.width = _width;
			
			PosUtils.vPlaceNext(5, _label, _uid, _pubkey, _submit, _error);
			PosUtils.hAlign(PosUtils.H_ALIGN_CENTER, 0, _uid, _pubkey, _submit, _error);
		}
		
	}
}