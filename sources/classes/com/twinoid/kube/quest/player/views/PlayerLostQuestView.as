package com.twinoid.kube.quest.player.views {
	import gs.TweenLite;
	import gs.easing.Sine;

	import com.nurun.components.text.CssTextField;
	import com.nurun.structure.environnement.label.Label;
	import com.nurun.utils.pos.roundPos;
	import com.twinoid.kube.quest.editor.components.Splitter;
	import com.twinoid.kube.quest.editor.components.buttons.ButtonKube;
	import com.twinoid.kube.quest.editor.vo.SplitterType;
	import com.twinoid.kube.quest.graphics.LostQuestIconGraphic;
	import com.twinoid.kube.quest.player.events.DataManagerEvent;
	import com.twinoid.kube.quest.player.model.DataManager;

	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.filters.GlowFilter;
	import flash.geom.Rectangle;
	
	/**
	 * Displays the evaluation form.
	 * 
	 * @author Francois
	 * @date 1 juin 2013;
	 */
	public class PlayerLostQuestView extends Sprite {
		
		private var _label:CssTextField;
		private var _smiley:LostQuestIconGraphic;
		private var _width:int;
		private var _submit:ButtonKube;
		private var _splitter:Splitter;
		private var _back:Shape;
		private var _opened:Boolean;
		
		
		
		
		/* *********** *
		 * CONSTRUCTOR *
		 * *********** */
		/**
		 * Creates an instance of <code>PlayerLostQuestView</code>.
		 */
		public function PlayerLostQuestView(width:int) {
			_width = width;
			initialize();
		}

		
		
		/* ***************** *
		 * GETTERS / SETTERS *
		 * ***************** */
		/**
		 * Gets the height of the component.
		 */
		override public function get height():Number { return _opened? _back.y + _back.height + _splitter.height : 0; }



		/* ****** *
		 * PUBLIC *
		 * ****** */

		private function close(delay:Number = 0):void {
			mouseChildren = tabChildren = false;
			_opened = false;
			TweenLite.to(_splitter, .35, {y:0, delay:delay, ease:Sine.easeInOut});
			TweenLite.to(this, .35, {scrollRect:{height:0}, delay:delay, ease:Sine.easeInOut, onStart:dispatchEvent, onStartParams:[new Event(Event.RESIZE, true)]});
		}


		
		
		/* ******* *
		 * PRIVATE *
		 * ******* */
		/**
		 * Initialize the class.
		 */
		private function initialize():void {
			mouseChildren = tabChildren = false;
			
			_back		= addChild(new Shape()) as Shape;
			_smiley		= addChild(new LostQuestIconGraphic()) as LostQuestIconGraphic;
			_label		= addChild(new CssTextField("kuest-lostTitle")) as CssTextField;
			_submit		= addChild(new ButtonKube(Label.getLabel("player-questLostRestart"))) as ButtonKube;
			_splitter	= addChild(new Splitter(SplitterType.HORIZONTAL)) as Splitter;
			
			_label.text		= Label.getLabel("player-questLost");
			_back.filters	= [new GlowFilter(0, .4, 0, 10, 2, 2, true)];
			
			scrollRect = new Rectangle(0, 0, _width, 0);
			
			_submit.addEventListener(MouseEvent.CLICK, submitHandler);
			DataManager.getInstance().addEventListener(DataManagerEvent.QUEST_FAILED, questFailHandler);
			DataManager.getInstance().addEventListener(DataManagerEvent.CLEAR_PROGRESSION_COMPLETE, clearProgressionHandler);
			computePositions();
		}
		
		/**
		 * Resizes and replaces the elements.
		 */
		private function computePositions():void {
			_label.width		= _width;
			_smiley.scaleX		= _smiley.scaleY = 2;
			_smiley.x			= (_width - _smiley.width) * .5;
			_smiley.y			= _label.height;
			_submit.x			= (_width - _submit.width) * .5;
			_submit.y			= _smiley.y + _smiley.height + 10;
			_splitter.y			= _submit.y + _submit.height + 5;
			_splitter.width		= _width;
			
			roundPos(_smiley, _submit, _splitter);
			
			_back.graphics.beginFill(0x2E7D9E, 1);
			_back.graphics.drawRect(0, 0, _width, _splitter.y);
			_back.graphics.endFill();
		}
		
		/**
		 * Called when progression is cleared.
		 */
		private function clearProgressionHandler(event:DataManagerEvent):void {
			close();
		}
		
		/**
		 * Called when quest is complete
		 */
		private function questFailHandler(event:DataManagerEvent):void {
			mouseChildren = tabChildren = true;
			_submit.enabled = true;
			_opened = true;
			TweenLite.to(_splitter, .35, {y:_back.y + _back.height, ease:Sine.easeInOut});
			TweenLite.to(this, .35, {scrollRect:{height:_back.y + _back.height + _splitter.height}, ease:Sine.easeInOut});
			dispatchEvent(new Event(Event.RESIZE, true));
		}
		
		/**
		 * Called when form is submitted
		 */
		private function submitHandler(event:MouseEvent):void {
			_submit.enabled = false;
			DataManager.getInstance().clearProgression();
		}
	}
}