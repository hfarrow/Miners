package miners.game.events
{
	import starling.events.Event;

	public class GameEvent extends Event
	{
		public static const NODE_EXCAVATED:String = "nodeExcavated";
		public static const ROW_CONSTRUCTED:String = "rowConstructed";
		
		public function GameEvent(type:String, bubbles:Boolean=false, data:Object=null)
		{
			super(type, bubbles, data);
		}
	}
}