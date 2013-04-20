package miners.game 
{
	import flash.ui.Keyboard;
	import miners.game.input.DirectionalKeyBinding;
	import miners.game.input.InputManager;
	import miners.game.level.Level;
	import miners.game.level.LevelBuilder;
	import miners.game.level.LevelParams;
	import starling.display.Sprite;
	import starling.events.EnterFrameEvent;
	import starling.text.TextField;
	import starling.events.Event;
	
	public class Game extends Sprite
	{
		public static var current:Game;
		public static var inputManager:InputManager;
		public static var level:Level;
		
		public var binding:DirectionalKeyBinding;
		
		public function Game()
		{
			Game.current = this;
			
			addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
		}
		
		private function onAddedToStage(e:Event):void 
		{
			removeEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
			addEventListener(Event.ENTER_FRAME, onEnterFrame);
			
			inputManager = new InputManager();
			
			level = new Level(new LevelParams());
			level.init();
			
			binding = new DirectionalKeyBinding(Keyboard.UP, Keyboard.DOWN, Keyboard.LEFT, Keyboard.RIGHT);
		}
		
		public function onEnterFrame(e:EnterFrameEvent):void
		{
			level.update(e.passedTime);
			
			// input manager must be updated after gameplay so that current and last keyboard states 
			// are swapped at the end of the frame in preperation of the next frame.
			inputManager.update(e.passedTime);
		}
	}
}