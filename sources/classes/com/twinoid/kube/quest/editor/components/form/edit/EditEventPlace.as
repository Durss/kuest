package com.twinoid.kube.quest.editor.components.form.edit {
	import flash.events.Event;
	import com.twinoid.kube.quest.editor.vo.Point3D;
	import com.nurun.components.text.CssTextField;
	import com.nurun.structure.environnement.label.Label;
	import com.nurun.utils.pos.PosUtils;
	import com.twinoid.kube.quest.editor.components.buttons.ButtonKube;
	import com.twinoid.kube.quest.editor.components.form.input.InputKube;
	import com.twinoid.kube.quest.editor.events.ToolTipEvent;
	import com.twinoid.kube.quest.editor.vo.ActionPlace;
	import com.twinoid.kube.quest.editor.vo.KuestEvent;
	import com.twinoid.kube.quest.editor.vo.ToolTipAlign;
	import com.twinoid.kube.quest.graphics.EventPlaceKubeIcon;
	import com.twinoid.kube.quest.graphics.EventPlaceZoneIcon;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	
	[Event(name="resize", type="flash.events.Event")]

	
	/**
	 * Displays the place edition form.
	 * The user can choose a zone or a kube coordinates.
	 * 
	 * @author Francois
	 * @date 3 févr. 2013;
	 */
	public class EditEventPlace extends AbstractEditZone {
		
		private var _zone:Sprite;
		private var _kube:Sprite;
		private var _kubeX:InputKube;
		private var _kubeY:InputKube;
		private var _kubeZ:InputKube;
		private var _zoneX:InputKube;
		private var _zoneY:InputKube;
		private var _captureBt:ButtonKube;
		private var _lastGamePosition:Point;
		private var _captureZone:Sprite;
		private var _lastForumPosition:Point3D;
		private var _helpKubeCoords:CssTextField;
		private var _kubeInputsLabel:CssTextField;
		
		
		
		
		/* *********** *
		 * CONSTRUCTOR *
		 * *********** */
		/**
		 * Creates an instance of <code>EditEventPlace</code>.
		 */
		public function EditEventPlace(width:int) {
			super(Label.getLabel("editWindow-place-title"), width);
		}

		
		
		/* ***************** *
		 * GETTERS / SETTERS *
		 * ***************** */
		/**
		 * Sets if the application is connected to the game via LC or not.
		 */
		public function set connectedToGame(value:Boolean):void {
			_captureBt.enabled = value;
			_captureZone.visible = !value;
		}
		
		/**
		 * Sets the last in game's position
		 */
		public function set inGamePosition(value:Point):void { _lastGamePosition = value; }

		/**
		 * Sets if the application is connected to the kuest player via LC or not.
		 */
		public function set connectedToPlayer(value:Boolean):void {
			_kubeX.visible = _kubeY.visible = _kubeZ.visible = value;
			_kubeInputsLabel.visible = value;
			_helpKubeCoords.text = Label.getLabel(value? "editWindow-place-kubeHelp" : "editWindow-place-kubeConnectHelp");
			_kubeInputsLabel.y = _kubeX.y = _kubeY.y = _kubeZ.y = value? Math.round(_helpKubeCoords.height) + 5 : 0;
			if(!_closed && selectedIndex == 1) {
				_contentsMask.height = _kube.height;
			}
			dispatchEvent(new Event(Event.RESIZE, true));
		}
		
		/**
		 * Sets the last touched forum's position
		 */
		public function set forumPosition(value:Point3D):void {
			_lastForumPosition = value;
			if(value != null) {
				_kubeX.text = value.x.toString();
				_kubeY.text = value.y.toString();
				_kubeZ.text = value.z.toString();
			}
		}
		
		/**
		 * @inheritDoc
		 */
		override public function set tabIndex(value:int):void {
			super.tabIndex		= value;
			_zoneX.tabIndex		= value + 10;
			_zoneY.tabIndex		= value + 11;
			_captureBt.tabIndex	= value + 12;
			_kubeX.tabIndex		= value + 13;
			_kubeY.tabIndex		= value + 14;
			_kubeZ.tabIndex		= value + 15;
		}



		/* ****** *
		 * PUBLIC *
		 * ****** */
		/**
		 * Saves the configuration to the value object
		 */
		public function save(data:KuestEvent):void {
			var isZone:Boolean = selectedIndex == 0;
			
			if(isZone) {
				data.actionPlace = new ActionPlace();
				data.actionPlace.x = _zoneX.numValue;
				data.actionPlace.y = _zoneY.numValue;
			}else{
				data.actionPlace = new ActionPlace();
				data.actionPlace.x = _kubeX.numValue;
				data.actionPlace.y = _kubeY.numValue;
				data.actionPlace.z = _kubeZ.numValue;
			}
			data.actionPlace.kubeMode = !isZone;
		}
		
		/**
		 * Loads the configuration to the value object
		 */
		public function load(data:KuestEvent):void {
			if (data.actionPlace == null) {
				selectedIndex = 0;
				_zoneX.text = "";
				_zoneY.text = "";
				_kubeX.text = "";
				_kubeY.text = "";
				_kubeZ.text = "";
				return;
			}
			
			if(!data.actionPlace.kubeMode) {
				selectedIndex = 0;
				_zoneX.text = data.actionPlace.x.toString();
				_zoneY.text = data.actionPlace.y.toString();
				_kubeX.text = "";
				_kubeY.text = "";
				_kubeZ.text = "";
			}else{
				selectedIndex = 1;
				_kubeX.text = data.actionPlace.x.toString();
				_kubeY.text = data.actionPlace.y.toString();
				_kubeZ.text = data.actionPlace.z.toString();
				_zoneX.text = "";
				_zoneY.text = "";
			}
		}


		
		
		/* ******* *
		 * PRIVATE *
		 * ******* */
		/**
		 * Initialize the class.
		 */
		override protected function initialize():void {
			super.initialize();
			
			buildZone();
			buildKube();
			
			addEntry(new EventPlaceZoneIcon(), _zone, Label.getLabel("editWindow-place-zoneTT"));
			addEntry(new EventPlaceKubeIcon(), _kube, Label.getLabel("editWindow-place-kubeTT"));
		}
		
		/**
		 * Builds the zone form
		 */
		private function buildZone():void {
			_zone = new Sprite();
			var label:CssTextField = _zone.addChild(new CssTextField("editWindow-label")) as CssTextField;
			_zoneX = _zone.addChild(new InputKube("0", true, -99999999, 99999999)) as InputKube;
			_zoneY = _zone.addChild(new InputKube("0", true, -99999999, 99999999)) as InputKube;
			_captureBt = _zone.addChild(new ButtonKube(Label.getLabel("editWindow-place-capture"))) as ButtonKube;
			_captureZone = _zone.addChild(new Sprite()) as Sprite;
			
			label.text = Label.getLabel("editWindow-place-zone");
			
			_zoneX.width = _zoneY.width = Math.floor((_width - label.width - _captureBt.width - 30) * .5);
			PosUtils.hPlaceNext(10, label, _zoneX, _zoneY, _captureBt);
			_captureZone.x = _captureBt.x;
			_captureZone.y = _captureBt.y;
			_captureBt.height = _zoneX.height;
			
			_captureZone.graphics.beginFill(0xff0000, 0);
			_captureZone.graphics.drawRect(0, 0, _captureBt.width, _captureBt.height);
			_captureZone.graphics.endFill();
			
			_captureZone.addEventListener(MouseEvent.ROLL_OVER, overCaptureHandler);
			_captureBt.addEventListener(MouseEvent.CLICK, clickCaptureHandler);
		}
		
		/**
		 * Called when capture button is clicked.
		 */
		private function clickCaptureHandler(event:MouseEvent):void {
			_zoneX.text = _lastGamePosition.x.toString();
			_zoneY.text = _lastGamePosition.y.toString();
		}
		
		/**
		 * Called when capture button is rolled over
		 */
		private function overCaptureHandler(event:MouseEvent):void {
			_captureZone.dispatchEvent(new ToolTipEvent(ToolTipEvent.OPEN, Label.getLabel("editWindow-place-captureTT"), ToolTipAlign.TOP_RIGHT));
		}

		/**
		 * Builds the kube form
		 */
		private function buildKube():void {
			_kube = new Sprite();
			_helpKubeCoords = _kube.addChild(new CssTextField("editWindow-label")) as CssTextField;
			_kubeInputsLabel = _kube.addChild(new CssTextField("editWindow-label")) as CssTextField;
			_kubeX = addChild(new InputKube("0", true, -99999999*32, 99999999*32)) as InputKube;
			_kubeY = addChild(new InputKube("0", true, -99999999*32, 99999999*32)) as InputKube;
			_kubeZ = addChild(new InputKube("0", true, -99999999*32, 99999999*32)) as InputKube;
			_kube.addChild(_kubeInputsLabel);
			_kube.addChild(_kubeX);
			_kube.addChild(_kubeY);
			_kube.addChild(_kubeZ);
			
			_helpKubeCoords.text = Label.getLabel("editWindow-place-kubeHelp");
			_kubeInputsLabel.text = Label.getLabel("editWindow-place-kube");
			
			_helpKubeCoords.width = _width;
			_kubeInputsLabel.y = _kubeX.y = _kubeY.y = _kubeZ.y = Math.round(_helpKubeCoords.height) + 5;
			_kubeX.width = _kubeY.width = _kubeZ.width = Math.floor((_width - _kubeInputsLabel.width - 30) / 3);
			PosUtils.hPlaceNext(10, _kubeInputsLabel, _kubeX, _kubeY, _kubeZ);
		}
		
	}
}