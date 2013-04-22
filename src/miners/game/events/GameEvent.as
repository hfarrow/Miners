package miners.game.events
{
	import starling.events.Event;

	public class GameEvent extends Event
	{
		public static const NODE_EXCAVATED:String = "nodeExcavated";
		public static const CONSTRUCT_ROW:String = "constructRow";
		public static const ACTION_WALK_LEFT:String = "actionWalkLeft";
		public static const ACTION_WALK_RIGHT:String = "actionWalkRight";
		public static const ACTION_STAND_FRONT:String = "actionStandFront";
		public static const ACTION_STAND_LEFT:String = "actionStandLeft";
		public static const ACTION_STAND_RIGHT:String = "actionStandRight";
		public static const ACTION_JUMP:String = "actionJump";
		public static const ACTION_EXCAVATE_LEFT:String = "actionExcavateLeft";
		public static const ACTION_EXCAVATE_RIGHT:String = "actionExcavateRight";
		public static const ACTION_EXCAVATE_DOWN:String = "actionExcavateDown";
		public static const EXCAVATE_HIT:String = "excavateHit";
		
		public function GameEvent(type:String, bubbles:Boolean=false, data:Object=null)
		{
			super(type, bubbles, data);
		}
	}
}