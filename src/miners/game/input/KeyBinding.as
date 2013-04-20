package miners.game.input 
{
	import miners.game.Game;
	public class KeyBinding 
	{
		private var _keyCode:int;
		
		public function KeyBinding(keyCode:int)
		{
			_keyCode = keyCode;
		}
		
		public function set buttonId(keyCode:int):void
		{
			_keyCode = keyCode;
		}
		
		public function get buttonId():int
		{
			return _keyCode;
		}
		
		public function isButtonPressed():Boolean
		{
			return Game.inputManager.isKeyDown(_keyCode);
		}
		
		public function isButtonJustPressed():Boolean
		{
			return Game.inputManager.isKeyJustPressed(_keyCode);
		}
		
		public function isButtonJustReleased():Boolean
		{
			return Game.inputManager.isKeyJustReleased(_keyCode);
		}
	}
}