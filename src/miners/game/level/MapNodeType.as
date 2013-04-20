package miners.game.level 
{
	public final class MapNodeType
	{
		public static var EXCAVATED:MapNodeType = new MapNodeType(0);
		public static var AIR:MapNodeType = new MapNodeType(1);
		public static var DIRT:MapNodeType = new MapNodeType(2);
		public static var ROCK:MapNodeType = new MapNodeType(3);		
		
		private var _id:uint;
		
		public function MapNodeType(id:uint) 
		{
			_id = id;
		}		
		
		public function get id():uint 
		{
			return _id;
		}
	}
}