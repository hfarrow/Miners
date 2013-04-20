package miners.game
{
	import flash.display.Sprite;
	import starling.core.Starling;
	
	public class Startup extends Sprite 
	{
		private var _starling:Starling;
		
		public function Startup():void 
		{
			_starling = new Starling(Game, stage);
			_starling.start();
		}		
	}	
}