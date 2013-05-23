package com.twinoid.kube.quest.editor.utils {
	import com.twinoid.kube.quest.editor.vo.ActionSound;
	import com.twinoid.kube.quest.editor.vo.ActionChoices;
	import com.twinoid.kube.quest.editor.vo.ActionDate;
	import com.twinoid.kube.quest.editor.vo.ActionPlace;
	import com.twinoid.kube.quest.editor.vo.ActionType;
	import com.twinoid.kube.quest.editor.vo.CharItemData;
	import com.twinoid.kube.quest.editor.vo.Dependency;
	import com.twinoid.kube.quest.editor.vo.IItemData;
	import com.twinoid.kube.quest.editor.vo.KuestEvent;
	import com.twinoid.kube.quest.editor.vo.ObjectItemData;
	import com.twinoid.kube.quest.editor.vo.SerializableBitmapData;

	import flash.display.GraphicsPath;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.net.registerClassAlias;
	import flash.utils.describeType;
	/**
	 * @author Francois
	 */
	public function initSerializableClasses():void {
			//Check if the value objects are all serializable and registers aliases
			//so that ByteArray.readObject() can instanciate the value objects.
			var serializableClasses:Array = [Point, Date, GraphicsPath, Rectangle, String, Dependency, KuestEvent, ActionDate, ActionPlace, ActionType, ActionChoices, ActionSound, IItemData, ObjectItemData, CharItemData, SerializableBitmapData];
			var i:int, len:int;
			var j:int, lenJ:int;
			len = serializableClasses.length;
			for (i = 0; i < len; ++i) {
				
				var xml:XML = describeType(serializableClasses[i]);
				var nodes:XMLList = XML(xml.child("factory")[0]).child("accessor");
				var cName:String = String(xml.@name).replace(/.*::(.*)/gi, "$1");
				registerClassAlias(cName, serializableClasses[i]);
				
				if(serializableClasses[i] != Point
				&& serializableClasses[i] != Date
				&& serializableClasses[i] != String) {
					lenJ = nodes.length();
					for(j = 0; j < lenJ; ++j) {
						if(nodes[j].@access != "readwrite") {
							trace("Class "+cName+"'s '"+nodes[j].@name+"' property is '"+nodes[j].@access+"'. Must be 'readwrite'.");
						}
					}
				}
			}
			
			/*
			var c:Vector.<KuestEvent> = new Vector.<KuestEvent>();
			var e1:KuestEvent = new KuestEvent();
			e1.boxPosition = new Point(69,96);
			e1.actionDate = new ActionDate();
			e1.actionDate.days = [0,1,4];
			e1.actionDate.startTime = 12;
			e1.actionDate.endTime = 82;
			
			e1.actionPlace = new ActionPlace();
			e1.actionPlace.x = 42;
			e1.actionPlace.y = 43;
			e1.actionPlace.z = 44;
			
			e1.actionType = new ActionType();
			e1.actionType.type = ActionType.TYPE_CHARACTER;
			e1.actionType.setItem(_kuestData.characters[0]);
			e1.actionType.text = "Zizi !!";
			
			//====================
			
			var e2:KuestEvent = new KuestEvent();
			e2.actionDate = new ActionDate();
			e2.actionDate.dates = new <Date>[new Date()];
			e2.actionDate.startTime = 12;
			e2.actionDate.endTime = 82;
			
			e2.actionPlace = new ActionPlace();
			e2.actionPlace.x = 89;
			e2.actionPlace.y = 12;
			e2.actionPlace.z = 8;
			
			e2.actionType = new ActionType();
			e2.actionType.type = ActionType.TYPE_OBJECT;
			e2.actionType.setItem(_kuestData.objects[0]);
			e2.actionType.text = "Cacaaa !!";
			e2.addDependency(e1);
			
			c.push(e1);
			c.push(e2);
			
			//Simulate serialization / deserialization just to be sure everything's ok.
			var bytes:ByteArray = new ByteArray();
			bytes.writeObject(_kuestData.characters);
			bytes.writeObject(_kuestData.objects);
			bytes.writeObject(c);
			bytes.deflate();
			
			bytes.inflate();
			_kuestData.deserialize(bytes);
			//*/
	}
}
