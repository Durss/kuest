package com.twinoid.kube.quest.editor.views {
	import com.twinoid.kube.quest.editor.components.tooltip.ToolTip;
	import com.twinoid.kube.quest.editor.components.tooltip.content.TTBitmapContent;
	import com.twinoid.kube.quest.editor.components.tooltip.content.TTTextContent;
	import com.twinoid.kube.quest.editor.events.ToolTipEvent;
	import com.twinoid.kube.quest.editor.vo.ToolTipAlign;
	import com.twinoid.kube.quest.editor.vo.ToolTipMessage;
	import flash.display.BitmapData;
	import flash.display.InteractiveObject;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;



	/**
	 * 
	 * @author Francois
	 * @date 31 oct. 2011;
	 */
	public class ToolTipView extends Sprite {
		private var _toolTip:ToolTip;
		private var _opened:Boolean;
		private var _alignType:String;
		private var _margin:int;
		private var _content:TTTextContent;
		private var _message:ToolTipMessage;
		private var _contentBmp:TTBitmapContent;
		
		
		
		
		/* *********** *
		 * CONSTRUCTOR *
		 * *********** */
		/**
		 * Creates an instance of <code>ToolTipView</code>.
		 */
		public function ToolTipView() {
			initialize();
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
		/**
		 * Initialize the class.
		 */
		private function initialize():void {
			_toolTip = addChild(new ToolTip()) as ToolTip;
			_toolTip.addEventListener(Event.CLOSE, closeHandler);
			
			_content = new TTTextContent(false);
			_contentBmp = new TTBitmapContent();
			_message = new ToolTipMessage(_content, null);
			
			mouseEnabled = mouseChildren = false;
			
			addEventListener(Event.ADDED_TO_STAGE, addedToStageHandler);
		}
		
		/**
		 * Called when the stage is available.
		 */
		private function addedToStageHandler(event:Event):void {
			removeEventListener(Event.ADDED_TO_STAGE, addedToStageHandler);
			stage.addEventListener(ToolTipEvent.OPEN, openHandler);
			stage.addEventListener(ToolTipEvent.CLOSE, closeHandler);
			stage.addEventListener(MouseEvent.MOUSE_MOVE, mouseMoveHandler);
		}
		
		/**
		 * Called when the mouse moves.
		 */
		private function mouseMoveHandler(event:MouseEvent):void {
			if(!_opened) return;
			
			switch(_alignType){
				case ToolTipAlign.TOP_LEFT:
					_toolTip.x = mouseX - _toolTip.width - _margin;
					_toolTip.y = mouseY - _toolTip.height - _margin;
					break;
					
				case ToolTipAlign.TOP:
					_toolTip.x = mouseX - _toolTip.width * .5;
					_toolTip.y = mouseY - _toolTip.height - _margin;
					break;
					
				case ToolTipAlign.TOP_RIGHT:
					_toolTip.x = mouseX + 12 + _margin;
					_toolTip.y = mouseY - _toolTip.height - _margin;
					break;
					
				
				case ToolTipAlign.LEFT:
					_toolTip.x = mouseX - _toolTip.width - _margin;
					_toolTip.y = mouseY - _toolTip.height * .5;
					break;
					
				case ToolTipAlign.MIDDLE:
					_toolTip.x = mouseX - _toolTip.width * .5;
					_toolTip.y = mouseY - _toolTip.height * .5;
					break;
					
				case ToolTipAlign.RIGHT:
					_toolTip.x = mouseX + 12 + _margin;
					_toolTip.y = mouseY - _toolTip.height * .5;
					break;
				
				case ToolTipAlign.BOTTOM_LEFT:
					_toolTip.x = mouseX - _toolTip.width - _margin;
					_toolTip.y = mouseY + 12 + _margin;
					break;
					
				case ToolTipAlign.BOTTOM:
					_toolTip.x = mouseX - _toolTip.width * .5;
					_toolTip.y = mouseY + 12 + _margin;
					break;
					
				default:
				case ToolTipAlign.BOTTOM_RIGHT:
					_toolTip.x = mouseX + 12 + _margin;
					_toolTip.y = mouseY + 12 + _margin;
					break;
			}
			_toolTip.x = Math.round(_toolTip.x);
			_toolTip.y = Math.round(_toolTip.y);
		}
		
		/**
		 * Called when the tooltip is closed
		 */
		private function closeHandler(event:Event):void {
			if(event is ToolTipEvent) {
				_toolTip.close();
			}else{
				_opened = false;
			}
		}
		
		/**
		 * Called when the tooltip needs to be opened
		 */
		private function openHandler(event:ToolTipEvent):void {
			_opened = true;
			_margin = event.margin;
			_message.target = event.target as InteractiveObject;
			if(event.data is BitmapData){
				_contentBmp.populate(event.data as BitmapData);
				_message.content = _contentBmp;
			}else if(event.data is String){
				_content.populate(event.data as String, event.style);
				_message.content = _content;
			}
			_toolTip.open(_message);
			_alignType = event.align;
			mouseMoveHandler(null);
		}
		
	}
}