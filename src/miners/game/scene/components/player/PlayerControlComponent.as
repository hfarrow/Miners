package miners.game.scene.components.player 
{
	import flash.ui.Keyboard;
	import miners.game.events.GameEvent;
	import miners.game.Game;
	import miners.game.input.DirectionalKeyBinding;
	import miners.game.input.KeyBinding;
	import miners.game.level.MapNode;
	import miners.game.level.MapNodeType;
	import miners.game.scene.Entity;
	import miners.game.scene.IEntityComponent;
	import nape.geom.Vec2;
	import nape.phys.Body;
	import starling.core.Starling;
	import starling.events.KeyboardEvent;
	
	// Component Dependencies:
	//	PhysicsComponent: body
	public class PlayerControlComponent implements IEntityComponent 
	{
		private var _entity:Entity;
		private var _moveBinding:DirectionalKeyBinding;
		private var _excavateBinding:KeyBinding;
		private var _body:Body;
		
		public function PlayerControlComponent() 
		{
			_moveBinding = new DirectionalKeyBinding(Keyboard.UP, Keyboard.DOWN, Keyboard.LEFT, Keyboard.RIGHT);
			_excavateBinding = new KeyBinding(Keyboard.SPACE);
		}
		
		/* INTERFACE miners.game.scene.IEntityComponent */
		
		public function init():void 
		{
			_body = _entity.getAttribute("physicsBody") as Body;
		}
		
		public function destroy():void 
		{
			
		}
		
		public function get type():Class 
		{
			return PlayerControlComponent;
		}
		
		public function get entity():Entity 
		{
			return _entity;
		}
		
		public function set entity(value:Entity):void 
		{
			_entity = value;
		}
		
		public function update(elapsedTime:Number):void
		{
			var node:MapNode;
			if (_moveBinding.down.isButtonPressed())
			{
				if (_excavateBinding.isButtonJustPressed())
				{
					node = Game.level.getNodeAtWorldPosition(_entity.x, _entity.y + 2 + (_entity.height / 2));
					if (node.type == MapNodeType.DIRT)
					{
						_entity.dispatchEvent(new GameEvent(GameEvent.NODE_EXCAVATED, true, node)); 
					}
				}
			}
			else if (_moveBinding.left.isButtonPressed())
			{
				if (_excavateBinding.isButtonJustPressed())
				{
					node = Game.level.getNodeAtWorldPosition(_entity.x - 2 - (_entity.width / 2), _entity.y);
					if (node.type == MapNodeType.DIRT)
					{
						_entity.dispatchEvent(new GameEvent(GameEvent.NODE_EXCAVATED, true, node)); 
					}
				}
				
				_body.velocity.x = -65;
			}			
			else if (_moveBinding.right.isButtonPressed())
			{
				if (_excavateBinding.isButtonJustPressed())
				{
					node = Game.level.getNodeAtWorldPosition(_entity.x + 2 + (_entity.width / 2), _entity.y);
					if (node.type == MapNodeType.DIRT)
					{
						_entity.dispatchEvent(new GameEvent(GameEvent.NODE_EXCAVATED, true, node)); 
					}
				}
				
				_body.velocity.x = 65;
			}
			
			if (_body.velocity.x > 0)
			{
				_body.velocity.x -= 5;
				if (_body.velocity.x < 0)
				{
					_body.velocity.x = 0;
				}
			}
			else if (_body.velocity.x < 0)
			{
				_body.velocity.x += 5;
				if (_body.velocity.x > 0)
				{
					_body.velocity.x = 0;
				}
			}
		}
	}
}