package com.twinoid.kube.quest.editor.components.buttons {
	import flash.display.DisplayObject;
	import com.twinoid.kube.quest.graphics.ButtonSkinPress;
	import com.muxxu.kub3dit.graphics.ButtonSkin;
	import com.nurun.components.button.IconAlign;
	import com.nurun.components.button.TextAlign;
	import com.nurun.components.button.visitors.CssVisitor;
	import com.nurun.components.button.visitors.applyDefaultFrameVisitorNoTween;
	import com.nurun.components.form.ToggleButton;
	import com.nurun.components.invalidator.Validable;
	import com.nurun.components.vo.Margin;

	import flash.display.MovieClip;
	import flash.utils.Dictionary;
	
	/**
	 * Pre-skinned toggle button
	 * 
	 * @author Francois
	 * @date 3 févr. 2013;
	 */
	public class ToggleButtonKube extends ToggleButton {
		private var _visitedIcons:Dictionary;
		
		
		
		
		/* *********** *
		 * CONSTRUCTOR *
		 * *********** */
		/**
		 * Creates an instance of <code>ToggleButtonKube</code>.
		 */
		public function ToggleButtonKube(label:String, delfaultIcon:DisplayObject = null, selectedIcon:DisplayObject = null) {
			super(label, "button", "button", new ButtonSkin(), new ButtonSkinPress(), delfaultIcon, selectedIcon);
			if(defaultIcon is Validable) Validable(defaultIcon).validate();
			contentMargin = new Margin(defaultIcon==null? 2 : 5, 1, 2, 1);
			textBoundsMode = false;
			iconAlign = IconAlign.LEFT;
			textAlign = defaultIcon == null? TextAlign.CENTER : TextAlign.LEFT;
			iconSpacing = label.length == 0? 0 : 5;
			applyDefaultFrameVisitorNoTween(this, defaultBackground, selectedBackground);
			_visitedIcons = new Dictionary();
			if(defaultIcon != null && defaultIcon is MovieClip && MovieClip(defaultIcon).currentLabels.length > 0) {
				applyDefaultFrameVisitorNoTween(this, defaultIcon);
				_visitedIcons[defaultIcon] = true;
			}
			if(selectedIcon != null && selectedIcon != defaultIcon && selectedIcon is MovieClip && MovieClip(selectedIcon).currentLabels.length > 0) {
				applyDefaultFrameVisitorNoTween(this, selectedIcon);
				_visitedIcons[selectedIcon] = true;
			}
			accept(new CssVisitor());
		}

		
		
		/* ***************** *
		 * GETTERS / SETTERS *
		 * ***************** */



		/* ****** *
		 * PUBLIC *
		 * ****** */


		
		
		/* ******* *
		 * PRIVATE *
		 * ******* */
		
	}
}