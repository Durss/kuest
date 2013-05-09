package com.twinoid.kube.quest.editor.utils {
	
	/**
	 * Specify a component that can be closed with the escape key.
	 * To enable this behavior, pass the instance implementing this interface
	 * to the package function makeEscapeClosable().
	 * 
	 * @author Francois
	 */
	public interface Closable {
		
		/**
		 * Closes the component.
		 */
		function close():void;
		
		/**
		 * Gets if the component is closed
		 */
		function get isClosed():Boolean;
		
	}
}
