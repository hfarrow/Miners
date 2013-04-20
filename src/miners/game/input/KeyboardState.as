package miners.game.input 
{
	import flash.utils.Dictionary;
	public dynamic class KeyboardState 
	{
		private var _keys:Dictionary;
		
		public function KeyboardState() 
		{
			_keys = new Dictionary();
			clear();
		}
		
		public function clear():void
		{
			for (var key:* in _keys)
			{
				_keys[key] = false;
			}
		}
		
		public function setKeyDown(keyCode:int):void
		{
			_keys[keyCode] = true;
		}
		
		public function setKeyUp(keyCode:int):void
		{
			_keys[keyCode] = false;
		}
		
		public function isKeyDown(keyCode:int):Boolean
		{
			return _keys[keyCode] == true ? true : false;
		}
		
		public function copyFrom(state:KeyboardState):void
		{
			clear();
			for (var key:* in state._keys)
			{
				_keys[key] = state._keys[key];
			}
		}
	}

}