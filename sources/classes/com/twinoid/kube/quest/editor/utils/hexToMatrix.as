package com.twinoid.kube.quest.editor.utils {
	
	/**
	 * Converts a color into a matrix for ColorMatrixFilter.
	 * 
	 * @author Francois
	 */
	public function hexToMatrix(color:uint, alpha:Number=1 ):Array {
	    var matrix:Array = [];
	    matrix = matrix.concat([((color & 0x00FF0000) >>> 16)/255, 0, 0, 0, 0]); // red
	    matrix = matrix.concat([0, ((color & 0x0000FF00) >>> 8)/255, 0, 0, 0]); //green
	    matrix = matrix.concat([0, 0, (color & 0x000000FF)/255, 0, 0]); // blue
	    matrix = matrix.concat([0, 0, 0, alpha, 0]); // alpha
	    return matrix;
	}
	
}
