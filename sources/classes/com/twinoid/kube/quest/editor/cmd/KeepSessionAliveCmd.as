package com.twinoid.kube.quest.editor.cmd {
	import com.nurun.core.commands.Command;
	import com.nurun.structure.environnement.configuration.Config;
	import com.nurun.utils.commands.LoadFileCmd;
	
	/**
	 * The  KeepSessionAliveCmd is a concrete implementation of the ICommand interface.
	 * Its responsability is to keep the PHP session alive.
	 *
	 * @author Francois
	 * @date 10 mai 2013;
	 */
	public class KeepSessionAliveCmd extends LoadFileCmd implements Command {
		
		
		
		
		/* *********** *
		 * CONSTRUCTOR *
		 * *********** */
		public function KeepSessionAliveCmd() {
			super(Config.getPath("ksaWS"));
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
