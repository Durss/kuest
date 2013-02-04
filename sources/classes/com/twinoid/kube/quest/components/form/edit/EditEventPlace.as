package com.twinoid.kube.quest.components.form.edit {
	import com.nurun.components.text.CssTextField;
	import com.nurun.structure.environnement.label.Label;
	import com.nurun.utils.pos.PosUtils;
	import com.twinoid.kube.quest.components.form.input.InputKube;
	import com.twinoid.kube.quest.graphics.EventPlaceKubeIcon;
	import com.twinoid.kube.quest.graphics.EventPlaceZoneIcon;

	import flash.display.Sprite;
	
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
		private var _width:int;
		
		
		
		
		/* *********** *
		 * CONSTRUCTOR *
		 * *********** */
		/**
		 * Creates an instance of <code>EditEventPlace</code>.
		 */
		public function EditEventPlace(width:int) {
			_width = width;
			super(Label.getLabel("editWindow-place-title"), width);
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
			var label:CssTextField = _zone.addChild(new CssTextField("promptWindowContent")) as CssTextField;
			var inputX:InputKube = addChild(new InputKube("0", true, -99999999, 99999999)) as InputKube;
			var inputY:InputKube = addChild(new InputKube("0", true, -99999999, 99999999)) as InputKube;
			_zone.addChild(label);
			_zone.addChild(inputX);
			_zone.addChild(inputY);
			
			label.text = Label.getLabel("editWindow-place-zone");
			
			inputX.width = inputY.width = Math.floor((_width - label.width - 20) * .5);
			PosUtils.hPlaceNext(10, label, inputX, inputY);
		}

		/**
		 * Builds the kube form
		 */
		private function buildKube():void {
			_kube = new Sprite();
			var help:CssTextField = _kube.addChild(new CssTextField("promptWindowContent")) as CssTextField;
			var label:CssTextField = _kube.addChild(new CssTextField("promptWindowContent")) as CssTextField;
			var inputX:InputKube = addChild(new InputKube("0", true, -99999999*32, 99999999*32)) as InputKube;
			var inputY:InputKube = addChild(new InputKube("0", true, -99999999*32, 99999999*32)) as InputKube;
			var inputZ:InputKube = addChild(new InputKube("0", true, -99999999*32, 99999999*32)) as InputKube;
			_kube.addChild(label);
			_kube.addChild(inputX);
			_kube.addChild(inputY);
			_kube.addChild(inputZ);
			
			help.text = Label.getLabel("editWindow-place-kubeHelp");
			label.text = Label.getLabel("editWindow-place-kube");
			
			help.width = _width;
			label.y = inputX.y = inputY.y = inputZ.y = Math.round(help.height) + 5;
			inputX.width = inputY.width = inputZ.width = Math.floor((_width - label.width - 30) / 3);
			PosUtils.hPlaceNext(10, label, inputX, inputY, inputZ);
		}
		
	}
}