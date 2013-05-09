package com.twinoid.kube.quest.components {
	import gs.TweenLite;

	import com.muxxu.kube3dit.graphics.SpinGraphic;
	import com.nurun.components.text.CssTextField;

	import flash.display.Sprite;
	import flash.events.Event;
	import flash.filters.DropShadowFilter;

	/**
	 * 
	 * @author Francois
	 */
	public class LoaderSpinning extends Sprite {
		
		private var _label:CssTextField;
		private var _spin:SpinGraphic;
		private var _width:Number;
		private var _height:Number;
		
		
		
		
		/* *********** *
		 * CONSTRUCTOR *
		 * *********** */
		/**
		 * Creates an instance of <code>LoaderSpinning</code>.
		 */
		public function LoaderSpinning() {
			filters = [new DropShadowFilter(0,0,0,.4,5,5,2,2)];
			alpha = 0;
			visible = false;
			_spin = new SpinGraphic();
			_label = new CssTextField("loader-label");
			_spin.scaleX = _spin.scaleY = 1.5;
			_width = _spin.width;
			_height = _spin.height;
		}

		
		
		/* ***************** *
		 * GETTERS / SETTERS *
		 * ***************** */
		/**
		 * Gets the width of the component.
		 */
		override public function get width():Number { return _width; }
		
		/**
		 * Gets the height of the component.
		 */
		override public function get height():Number { return _height; }



		/* ****** *
		 * PUBLIC *
		 * ****** */

		public function dispose():void {
			removeEventListener(Event.ENTER_FRAME, enterFrameHandler);
		}

		public function open(label:String = null):void {
			addChild(_spin);
			if(label != null) {
				_label.text = label;
				addChild(_label);
				_label.x = Math.round(-_label.width * .5);
				_label.y = Math.round(_height * .5);
				_label.alpha = 1;
				_label.visible = true;
				TweenLite.from(_label, .25, {y:"+10", autoAlpha:0, delay:.25});
			}
			TweenLite.to(this, .25, {autoAlpha:1});
			addEventListener(Event.ENTER_FRAME, enterFrameHandler);
		}

		public function close(label:String = null):void {
			if(label != null) {
				_label.text = label;
				_label.x = -_label.width * .5;
			}
			if(contains(_label)) {
				TweenLite.to(_label, .25, {y:"+10", removeChild:true, autoAlpha:0, delay:.75});
			}
			TweenLite.to(this, .25, {autoAlpha:0, onComplete:killListener, delay:1});
		}



		
		
		/* ******* *
		 * PRIVATE *
		 * ******* */

		private function enterFrameHandler(event:Event):void {
			_spin.rotation -= 15;
		}

		private function killListener():void {
			if(contains(_spin)) removeChild(_spin);
			removeEventListener(Event.ENTER_FRAME, enterFrameHandler);
		}
		
	}
}