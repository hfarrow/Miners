package miners.game.input 
{
	import starling.core.Starling;
	import starling.events.KeyboardEvent;
	public class InputManager 
	{
		private var currentKeyboardState:KeyboardState;
		private var lastKeyboardState:KeyboardState;
		
		public function InputManager() 
		{
			currentKeyboardState = new KeyboardState();
			lastKeyboardState = new KeyboardState();
			enable();
		}
		
		public function enable():void
		{
			addListeners();
		}
		
		public function disable():void
		{
			removeListeners();
			currentKeyboardState.clear();
			lastKeyboardState.clear();
		}
		
		private function addListeners():void		
		{
			Starling.current.stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
			Starling.current.stage.addEventListener(KeyboardEvent.KEY_UP, onKeyUp);
		}
		
		private function removeListeners():void
		{
			Starling.current.stage.removeEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
			Starling.current.stage.removeEventListener(KeyboardEvent.KEY_UP, onKeyUp);
		}
		
		private function onKeyDown(e:KeyboardEvent):void
		{
			//trace("key down: " + e.keyCode, e.charCode, e.keyLocation);
			currentKeyboardState.setKeyDown(e.keyCode);
		}
		
		private function onKeyUp(e:KeyboardEvent):void
		{
			//trace("key up: " + e.keyCode, e.charCode, e.keyLocation);
			currentKeyboardState.setKeyUp(e.keyCode);
		}
		
		public function isKeyDown(keyCode:int):Boolean
		{
			return currentKeyboardState.isKeyDown(keyCode);
		}
		
		public function isKeyJustPressed(keyCode:int):Boolean
		{
			return currentKeyboardState.isKeyDown(keyCode) && !lastKeyboardState.isKeyDown(keyCode);
		}
		
		public function isKeyJustReleased(keyCode:int):Boolean
		{
			return !currentKeyboardState.isKeyDown(keyCode) && lastKeyboardState.isKeyDown(keyCode);
		}
		
		public function update(elapsedTime:Number):void
		{
			var temp:* = lastKeyboardState;
			lastKeyboardState = currentKeyboardState;
			currentKeyboardState = temp;
			currentKeyboardState.copyFrom(lastKeyboardState);
		}		
	}

}