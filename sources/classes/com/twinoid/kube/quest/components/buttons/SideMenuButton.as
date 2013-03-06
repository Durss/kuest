package com.twinoid.kube.quest.components.buttons {
	import com.nurun.components.button.IconAlign;
	import com.nurun.components.button.visitors.applyDefaultFrameVisitorNoTween;
	import com.nurun.components.form.ToggleButton;
	import com.nurun.components.invalidator.Validable;
	import com.twinoid.kube.quest.graphics.MenuButtonSelectedGraphic;

	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	
	/**
	 * 
	 * @author Francois
	 * @date 10 févr. 2013;
	 */
	public class SideMenuButton extends ToggleButton {
		
		
		
		
		/* *********** *
		 * CONSTRUCTOR *
		 * *********** */
		/**
		 * Creates an instance of <code>SideMenuButton</code>.
		 */
		public function SideMenuButton(icon:DisplayObject) {
			super("", "", "", new MenuButtonGraphic(), new MenuButtonSelectedGraphic(), icon, icon);
			if(icon is Validable) Validable(icon).validate();
			width = 25;
			height = 80;
			iconAlign = IconAlign.CENTER;
			applyDefaultFrameVisitorNoTween(this, background, selectedBackground);
			if(icon != null && icon is MovieClip && MovieClip(icon).totalFrames > 1) applyDefaultFrameVisitorNoTween(this, icon);
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