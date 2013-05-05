package com.twinoid.kube.quest.components.buttons {
	import com.muxxu.kub3dit.graphics.ButtonSkin;
	import com.nurun.components.button.BaseButton;
	import com.nurun.components.button.IconAlign;
	import com.nurun.components.button.TextAlign;
	import com.nurun.components.button.visitors.CssVisitor;
	import com.nurun.components.button.visitors.applyDefaultFrameVisitorNoTween;
	import com.nurun.components.invalidator.Validable;
	import com.nurun.components.vo.Margin;
	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	import flash.utils.Dictionary;


	
	/**
	 * Creates a pre-skinned button.
	 * 
	 * @author Francois
	 */
	public class ButtonKube extends BaseButton {
		private var _visitedIcons:Dictionary;
		
		
		
		
		/* *********** *
		 * CONSTRUCTOR *
		 * *********** */
		/**
		 * Creates an instance of <code>KBButton</code>.
		 */
		public function ButtonKube(label:String, icon:DisplayObject = null) {
			super(label, "button", new ButtonSkin(), icon);
			if(icon is Validable) Validable(icon).validate();
			contentMargin = new Margin(icon==null? 2 : 5, 3, 5, 3);
			textBoundsMode = false;
			iconAlign = IconAlign.LEFT;
			textAlign = icon == null? TextAlign.CENTER : TextAlign.LEFT;
			iconSpacing = label.length == 0? 0 : 5;
			applyDefaultFrameVisitorNoTween(this, background);
			_visitedIcons = new Dictionary();
			if(icon != null && icon is MovieClip && MovieClip(icon).currentLabels.length > 0) {
				applyDefaultFrameVisitorNoTween(this, icon);
				_visitedIcons[icon] = true;
			}
			accept(new CssVisitor());
		}

		
		
		/* ***************** *
		 * GETTERS / SETTERS *
		 * ***************** */
		override public function set icon(value:DisplayObject):void {
			super.icon = value;
			if(icon != null && icon is MovieClip && _visitedIcons[icon] == undefined && MovieClip(icon).currentLabels.length > 0) {
				applyDefaultFrameVisitorNoTween(this, icon);
				_visitedIcons[icon] = true;
				textAlign = TextAlign.LEFT;
			}else{
				textAlign = value != null? TextAlign.LEFT : TextAlign.CENTER;
			}
		}



		/* ****** *
		 * PUBLIC *
		 * ****** */
		/**
		 * Simply hides the button.
		 * Used for easy timeout callbacks.
		 */
		public function hide():void {
			visible = false;
		}


		
		
		/* ******* *
		 * PRIVATE *
		 * ******* */
		override protected function computePositions():void {
			super.computePositions();
			_backgroundMc.width = Math.round(_backgroundMc.width);
			_backgroundMc.height = Math.round(_backgroundMc.height);
		}
		
	}
}