package com.twinoid.kube.quest.player.vo {
	/**
	 * @author Francois
	 */
	public class SaveVersion {
		
		/**
		 * Save version 1.
		 * 
		 * File is a ByteArray containing thee data this way :
		 * 		ba.writeUnsignedInt( version number );
		 * 		ba.writeObject( tree data );
		 * 		ba.writeObject( inventory data );
		 * 		ba.writeUTF( events history );
		 * 		ba.writeBoolean( quest complete );
		 * 		ba.writeBoolean( quest lost );
		 * 	
		 * tree data is formated this way :
		 * 	[
		 * 		treeID : [guid1, guid2, guid3, ...]
		 * 		treeID : [guid1, guid2, guid3, ...]
		 * 		treeID : [guid1, guid2, guid3, ...]
		 * 	]
		 * 
		 * inventory data is formated this way :
		 * 	[
		 * 		{total:x, guid:guid}
		 * 		{total:x, guid:guid}
		 * 		{total:x, guid:guid}
		 * 	]
		 * 
		 * events history is a comma separated string containing the events GUIDs :
		 * 		guid1,guid2,guid3,...,guidN
		 */
		public static const V1:uint = 1;
		
	}
}
