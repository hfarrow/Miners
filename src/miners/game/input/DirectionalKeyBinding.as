package miners.game.input 
{
	public class DirectionalKeyBinding 
	{
		private var _up:KeyBinding;
		private var _down:KeyBinding;
		private var _left:KeyBinding;
		private var _right:KeyBinding;
		
		public function DirectionalKeyBinding(upKeyCode:int, downKeyCode:int, leftKeyCode:int, rightKeyCode:int)
		{
			_up = new KeyBinding(upKeyCode);
			_down = new KeyBinding(downKeyCode);
			_left = new KeyBinding(leftKeyCode);
			_right = new KeyBinding(rightKeyCode);
		}
		
		public function get up():KeyBinding
		{
			return _up;
		}
		
		public function get down():KeyBinding
		{
			return _down;
		}
		
		public function get left():KeyBinding
		{
			return _left;
		}
		
		public function get right():KeyBinding
		{
			return _right;
		}
	}
}