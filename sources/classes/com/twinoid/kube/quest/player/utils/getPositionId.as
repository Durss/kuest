package com.twinoid.kube.quest.player.utils {
	import com.twinoid.kube.quest.editor.vo.ActionPlace;
	import com.twinoid.kube.quest.editor.vo.Point3D;

	import flash.geom.Point;
	/**
	 * Gets an ID representing the action's position or an external Point/Point3D
	 * @author Francois
	 */
	public function getPositionId(src:* = null):String {
			if(src is Point) {
				return Point(src).x+"_"+Point(src).y;
			}else if(src is Point3D) {
				return Point3D(src).x+"_"+Point3D(src).y+"_"+Point3D(src).z;
			}else if(src is ActionPlace){
				return !ActionPlace(src).kubeMode? ActionPlace(src).x+"_"+ActionPlace(src).y : ActionPlace(src).x+"_"+ActionPlace(src).y+"_"+ActionPlace(src).z;
			}
			return null;
		}
	
}
