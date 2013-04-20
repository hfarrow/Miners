package miners.game.level 
{
	import nape.phys.Body;
	import starling.display.DisplayObject;
	import starling.display.Quad;
	import starling.text.TextField;
	public class MapNode 
	{
		private var _type:MapNodeType;
		public var xIndex:uint;
		public var yIndex:uint;
		public var body:Body;
		public var quad:Quad;
		public var debugText:TextField;
		public var container:DisplayObject;
		
		public function MapNode(type:MapNodeType=null) 
		{
			_type = type;
			if (_type == null)
			{
				_type = MapNodeType.DIRT;
			}
		}		
		
		public function get type():MapNodeType 
		{
			return _type;
		}
		
		public function setType(type:MapNodeType):void
		{
			_type = type;
		}
		
		public static function getNodeColor(nodeType:MapNodeType):uint
		{
			var color:uint;
			switch(nodeType)
			{
				case MapNodeType.DIRT: color = 0x603311; break;
				case MapNodeType.EXCAVATED: color = 0x292421; break;
				default: color = 0xaf4035; break;
			}
			return color;
		}
	}

}