package com.twinoid.kube.quest.editor.components.form {	import com.muxxu.kub3dit.graphics.CheckBoxSelectedSkin;	import com.muxxu.kub3dit.graphics.CheckBoxSkin;	import com.nurun.components.button.visitors.CssVisitor;	import com.nurun.components.button.visitors.FrameVisitor;	import com.nurun.components.button.visitors.FrameVisitorOptions;	import com.nurun.components.form.Checkbox;	import flash.display.MovieClip;	/**	 * Creates a preskined CheckBox instance.	 * 	 * @author  Francois	 */	public class CheckBoxKube extends Checkbox {										/* *********** *		 * CONSTRUCTOR *		 * *********** */		/**		 * Creates an instance of <code>KubeCheckBox</code>.		 */		public function CheckBoxKube(label:String, defaultStyle:String = 'checkBox', selectedStyle:String = 'checkBox_selected') {			super(label, defaultStyle, selectedStyle, new CheckBoxSkin(), new CheckBoxSelectedSkin());			var fv:FrameVisitor = new FrameVisitor();			var opts:FrameVisitorOptions = new FrameVisitorOptions("out", "over", "down", "disable");			fv.addTarget(defaultIcon as MovieClip, opts);			fv.addTarget(selectedIcon as MovieClip, opts);			accept(fv);			accept(new CssVisitor());			yLabelOffset = -2;		}						/* ***************** *		 * GETTERS / SETTERS *		 * ***************** */		/* ****** *		 * PUBLIC *		 * ****** */						/* ******* *		 * PRIVATE *		 * ******* */			}}