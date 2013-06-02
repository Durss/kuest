package com.twinoid.kube.quest.player.views {
	import gs.TweenLite;
	import gs.easing.Sine;

	import com.nurun.components.scroll.events.ScrollerEvent;
	import com.nurun.components.scroll.scroller.scrollbar.Scrollbar;
	import com.nurun.components.scroll.scroller.scrollbar.ScrollbarSkin;
	import com.nurun.components.text.CssTextField;
	import com.nurun.core.commands.events.CommandEvent;
	import com.nurun.structure.environnement.label.Label;
	import com.nurun.utils.pos.roundPos;
	import com.twinoid.kube.quest.editor.components.LoaderSpinning;
	import com.twinoid.kube.quest.editor.components.Splitter;
	import com.twinoid.kube.quest.editor.components.buttons.ButtonKube;
	import com.twinoid.kube.quest.editor.vo.SplitterType;
	import com.twinoid.kube.quest.graphics.EvaluationScrollBackGraphic;
	import com.twinoid.kube.quest.graphics.EvaluationScrollButtonGraphic;
	import com.twinoid.kube.quest.graphics.EvaluationSmileyGraphic;
	import com.twinoid.kube.quest.player.cmd.EvaluateCmd;
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
	public class EvaluateQuestView extends Sprite {
		
		private var _label:CssTextField;
		private var _smiley:EvaluationSmileyGraphic;
		private var _width:int;
		private var _scroll:Scrollbar;
		private var _submit:ButtonKube;
		private var _splitter:Splitter;
		private var _back:Shape;
		private var _opened:Boolean;
		private var _spinning:LoaderSpinning;
		private var _cmd:EvaluateCmd;
		
		
		
		
		/* *********** *
		 * CONSTRUCTOR *
		 * *********** */
		/**
		 * Creates an instance of <code>EvaluateQuestView</code>.
		 */
		public function EvaluateQuestView(width:int) {
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
//			visible = false;
			_cmd		= new EvaluateCmd();
			_back		= addChild(new Shape()) as Shape;
			_smiley		= addChild(new EvaluationSmileyGraphic()) as EvaluationSmileyGraphic;
			_label		= addChild(new CssTextField("kuest-evaluationTitle")) as CssTextField;
			_scroll		= addChild(new Scrollbar(new ScrollbarSkin(null, null, new EvaluationScrollButtonGraphic(), null, new EvaluationScrollBackGraphic()), false)) as Scrollbar;
			_submit		= addChild(new ButtonKube(Label.getLabel("player-evaluateSubmit"))) as ButtonKube;
			_splitter	= addChild(new Splitter(SplitterType.HORIZONTAL)) as Splitter;
			_spinning	= addChild(new LoaderSpinning()) as LoaderSpinning;
			
			_label.text		= Label.getLabel("player-evaluate");
			_scroll.percent	= .5;
			_back.filters	= [new GlowFilter(0, .4, 0, 10, 2, 2, true)];
			
			scrollRect = new Rectangle(0, 0, _width, 0);
			
			scrollingHandler();
			_submit.addEventListener(MouseEvent.CLICK, submitHandler);
			_cmd.addEventListener(CommandEvent.ERROR, loadErrorHandler);
			_cmd.addEventListener(CommandEvent.COMPLETE, loadCompleteHandler);
			_scroll.addEventListener(ScrollerEvent.SCROLLING, scrollingHandler);
			DataManager.getInstance().addEventListener(DataManagerEvent.QUEST_COMPLETE, questCompleteHandler);
			DataManager.getInstance().addEventListener(DataManagerEvent.CLEAR_PROGRESSION_COMPLETE, clearProgressionHandler);
			computePositions();
		}
		
		/**
		 * Resizes and replaces the elements.
		 */
		private function computePositions():void {
			_label.width		= _width;
			_scroll.rotation	= -90;
			_scroll.width		= 20;
			_scroll.height		= _width * .25;
			_smiley.scaleX		= _smiley.scaleY = 2;
			_smiley.x			= (_width - _smiley.width - _scroll.height) * .5;
			_smiley.y			= _label.height;
			_scroll.x			= _smiley.x + 50;
			_scroll.y			= _smiley.y + (_smiley.height - _scroll.width) *.5 + _scroll.width + 2 * _smiley.scaleY;
			_submit.x			= (_width - _submit.width) * .5;
			_submit.y			= _smiley.y + _smiley.height + 10;
			_splitter.y			= _submit.y + _submit.height + 5;
			_splitter.width		= _width;
			
			roundPos(_smiley, _scroll, _submit, _splitter);
			
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
		private function questCompleteHandler(event:DataManagerEvent):void {
			_opened = true;
			TweenLite.to(_splitter, .35, {y:_back.y + _back.height, ease:Sine.easeInOut});
			TweenLite.to(this, .35, {scrollRect:{height:_back.y + _back.height + _splitter.height}, ease:Sine.easeInOut});
			dispatchEvent(new Event(Event.RESIZE, true));
		}
		
		/**
		 * Caled when scrollbar is used
		 */
		private function scrollingHandler(event:ScrollerEvent = null):void {
			_smiley.gotoAndStop( Math.round(_smiley.totalFrames * _scroll.percent) );
		}
		
		/**
		 * Called when form is submitted
		 */
		private function submitHandler(event:MouseEvent):void {
			_submit.enabled = false;
			_scroll.enabled = false;
			_spinning.open();
			_spinning.x = _submit.x + _submit.width * .5;
			_spinning.y = _submit.y + _submit.height * .5;
			
			_cmd.populate(DataManager.getInstance().currentQuestGUID, DataManager.getInstance().pubkey, _smiley.currentFrame);
			_cmd.execute();
		}
		
		/**
		 * Called when evaluation completes
		 */
		private function loadCompleteHandler(event:CommandEvent):void {
			_label.text = Label.getLabel("player-evaluateComplete");
			removeChild(_submit);
			removeChild(_scroll);
			
			_label.y = Math.round(_back.height * .3 - _label.height * .5);
			_smiley.y = Math.round(_label.y + _label.height + 10);
			_smiley.x = Math.round((_width - _smiley.width) * .5);
			
			_spinning.close();
			
			DataManager.getInstance().questEvaluated();
			TweenLite.from(_label, .25, {alpha:0});
			TweenLite.from(_smiley, .25, {alpha:0, delay:.25});
			close(2);
		}

		/**
		 * Called if evaluation fails
		 */
		private function loadErrorHandler(event:CommandEvent):void {
			_spinning.close();
			_submit.enabled = _scroll.enabled = true;
		}
		
	}
}