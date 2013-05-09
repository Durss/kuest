package com.twinoid.kube.quest.editor.vo {	import com.twinoid.kube.quest.editor.components.tooltip.content.ToolTipContent;	import flash.display.InteractiveObject;	/**	 * Value object containing informations about a tooltip opening.	 * 	 * @author  Francois	 */	public class ToolTipMessage  {		private var _content:ToolTipContent;		private var _target:InteractiveObject;								/* *********** *		 * CONSTRUCTOR *		 * *********** */		/**		 * Creates an instance of <code>ToolTipMessage</code>.		 * 		 * @param content	content to display on the tooltip.		 * @param target	target over wich display the tooltip.		 */		public function ToolTipMessage(content:ToolTipContent, target:InteractiveObject) {			_target = target;			_content = content;		}						/* ***************** *		 * GETTERS / SETTERS *		 * ***************** */		/**		 * Gets the target over which display the tooltip.		 * If specified the tooltip will be auto placed and auto closed on		 * roll out from the target.		 */		public function get target():InteractiveObject { return _target; }				/**		 * Sets the target over which display the tooltip.		 * If specified the tooltip will be auto placed and auto closed on		 * roll out from the target.		 */		public function set target(value:InteractiveObject):void { _target = value; }				/**		 * Sets the content to display on the tooltip.		 */		public function set content(value:ToolTipContent):void { _content = value; }				/**		 * Gets the content to display on the tooltip.		 */		public function get content():ToolTipContent { return _content; }		/* ****** *		 * PUBLIC *		 * ****** */						/* ******* *		 * PRIVATE *		 * ******* */			}}