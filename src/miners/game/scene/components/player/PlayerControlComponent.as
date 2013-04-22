package miners.game.scene.components.player 
{
	import flash.ui.Keyboard;
	import miners.game.events.GameEvent;
	import miners.game.Game;
	import miners.game.input.DirectionalKeyBinding;
	import miners.game.input.KeyBinding;
	import miners.game.level.Level;
	import miners.game.level.MapNode;
	import miners.game.level.MapNodeType;
	import miners.game.scene.Entity;
	import miners.game.scene.IEntityComponent;
	import nape.callbacks.CbEvent;
	import nape.callbacks.InteractionCallback;
	import nape.callbacks.InteractionListener;
	import nape.callbacks.InteractionType;
	import nape.callbacks.Listener;
	import nape.geom.Vec2;
	import nape.phys.Body;
	import nape.phys.Interactor;
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
		private var _goundListener:Listener;
		private var _currentAction:String;
		private var _isJumping:Boolean;
		
		public function PlayerControlComponent() 
		{
			_moveBinding = new DirectionalKeyBinding(Keyboard.UP, Keyboard.DOWN, Keyboard.LEFT, Keyboard.RIGHT);
			_excavateBinding = new KeyBinding(Keyboard.SPACE);
		}
		
		/* INTERFACE miners.game.scene.IEntityComponent */
		
		public function init():void 
		{
			_isJumping = false;
			
			_body = _entity.getAttribute("physicsBody") as Body;
			_goundListener = new InteractionListener(CbEvent.BEGIN, InteractionType.COLLISION, Level.CB_PLAYER, Level.CB_GROUND, onPlayerCollisionBegin);
			Game.level.physicsSpace.listeners.add(_goundListener);
			
			_entity.parent.addEventListener(GameEvent.NODE_EXCAVATED, onNodeExcavated);
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
			//trace("update");
			
			if (_currentAction == null)
			{
				_entity.dispatchEvent(new GameEvent(GameEvent.ACTION_STAND_FRONT));
			}
			
			var node:MapNode;
			if (_moveBinding.up.isButtonJustPressed() && _body.velocity.y < 1 && _body.velocity.y > -1)
			{
				_body.applyImpulse(Vec2.weak(0, -45));
				_isJumping = true;
				startAction(GameEvent.ACTION_JUMP, false, true);
			}
			else if (_moveBinding.down.isButtonPressed())
			{
				if (_excavateBinding.isButtonJustPressed())
				{
					node = Game.level.getNodeAtWorldPosition(_entity.x, _entity.y + 2 + (_entity.height / 2));
					if (node.type == MapNodeType.DIRT && node.yIndex < Game.level.getHighestNodeYIndex())
					{
						startAction(GameEvent.ACTION_EXCAVATE_DOWN, node);
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
						startAction(GameEvent.ACTION_EXCAVATE_LEFT, node, true);
					}
				}
				
				if (_currentAction != GameEvent.ACTION_EXCAVATE_LEFT)
				{
					startAction(GameEvent.ACTION_WALK_LEFT);
					_body.velocity.x = -65;
				}
			}
			else if (_moveBinding.right.isButtonPressed())
			{
				if (_excavateBinding.isButtonJustPressed())
				{
					node = Game.level.getNodeAtWorldPosition(_entity.x + 2 + (_entity.width / 2), _entity.y);
					if (node.type == MapNodeType.DIRT)
					{
						startAction(GameEvent.ACTION_EXCAVATE_RIGHT, node, true);
					}
				}
				
				if (_currentAction != GameEvent.ACTION_EXCAVATE_RIGHT)
				{
					startAction(GameEvent.ACTION_WALK_RIGHT);
					_body.velocity.x = 65;
				}
			}
			
			/*
			if (_excavateBinding.isButtonJustReleased())
			{
 				if (_currentAction == GameEvent.ACTION_EXCAVATE_LEFT)
				{
					startAction(GameEvent.ACTION_STAND_LEFT);
				}
				else if (_currentAction == GameEvent.ACTION_EXCAVATE_RIGHT)
				{
					startAction(GameEvent.ACTION_STAND_RIGHT);
				}
				else if (_currentAction == GameEvent.ACTION_EXCAVATE_DOWN)
				{
					startAction(GameEvent.ACTION_STAND_FRONT);
				}
			}
			*/
			
			if (_body.velocity.x > 0)
			{
				_body.velocity.x -= 5;
				if (_body.velocity.x < 0)
				{
					_body.velocity.x = 0;
					if (isMoving())
					{
						startAction(GameEvent.ACTION_STAND_FRONT);
					}
				}
			}
			else if (_body.velocity.x < 0)
			{
				_body.velocity.x += 5;
				if (_body.velocity.x > 0)
				{
					_body.velocity.x = 0;
					if (isMoving())
					{
						startAction(GameEvent.ACTION_STAND_FRONT);
					}
				}
			}
			else if (_body.velocity.x < 1 && _body.velocity.x > -1 && _body.velocity.y < 1 && _body.velocity.y > -1)
			{
				if (isMoving()) 
				{
					startAction(GameEvent.ACTION_STAND_FRONT);
				}
			}
		}
		
		private function onPlayerCollisionBegin(cb:InteractionCallback):void
		{
			var playerBody:Body = cb.int1.castBody;
			var groundBody:Body = cb.int2.castBody;
			
 			var node:MapNode = Game.level.getNodeAtWorldPosition(_entity.x, _entity.y + 2 + (_entity.height / 2));
			if (_isJumping && node != null && cb.arbiters.at(0).totalImpulse().y > 5 && node.body == groundBody)
			{
				// We just landed on ground.
				trace("LANDED");
				_isJumping = false;
				if (!isExcavating())
				{
					startAction(GameEvent.ACTION_STAND_FRONT, null, true);
				}
			}
         }
		
		private function onNodeExcavated(e:GameEvent):void 
		{
            var node:MapNode = MapNode(e.data);
			if (_currentAction == GameEvent.ACTION_EXCAVATE_LEFT)
			{
				startAction(GameEvent.ACTION_WALK_LEFT);
			}
			else if (_currentAction == GameEvent.ACTION_EXCAVATE_RIGHT)
			{
				startAction(GameEvent.ACTION_WALK_RIGHT);
			}
			else if (_currentAction == GameEvent.ACTION_EXCAVATE_DOWN)
			{
				// TODO: Add a falling animation for after a player excavated the node below themselves?
				startAction(GameEvent.ACTION_STAND_FRONT);
			}
		}
		
		private function isMoving():Boolean
		{
			return (_currentAction != GameEvent.ACTION_STAND_LEFT && _currentAction != GameEvent.ACTION_EXCAVATE_LEFT &&
					_currentAction != GameEvent.ACTION_STAND_RIGHT && _currentAction != GameEvent.ACTION_EXCAVATE_RIGHT &&
					_currentAction != GameEvent.ACTION_STAND_FRONT && _currentAction != GameEvent.ACTION_EXCAVATE_DOWN);
		}
		
		private function isExcavating():Boolean
		{
			return (_currentAction == GameEvent.ACTION_EXCAVATE_LEFT ||
					_currentAction == GameEvent.ACTION_EXCAVATE_RIGHT ||
					_currentAction == GameEvent.ACTION_EXCAVATE_DOWN);
		}
		
		private function isStanding():Boolean
		{
			return (_currentAction == GameEvent.ACTION_STAND_LEFT ||
					_currentAction == GameEvent.ACTION_STAND_RIGHT ||
					_currentAction == GameEvent.ACTION_STAND_FRONT);
		}
		
		private function isJumping():Boolean
		{
			return _currentAction == GameEvent.ACTION_JUMP;
		}
		
		private function isWalking(action:String = null):Boolean
		{
			if (action == null)
			{
				action = _currentAction;
			}
			return (action == GameEvent.ACTION_WALK_LEFT ||
					action == GameEvent.ACTION_WALK_RIGHT)
		}
		
		public function startAction(action:String, actionData:Object=null, overrideJumping:Boolean=false):void
		{
			if (_currentAction == action)
			{
				return;
			}
			
			if (_isJumping && !overrideJumping)
			{
				// No air walking
				if (action == GameEvent.ACTION_WALK_LEFT)
				{
					action = GameEvent.ACTION_STAND_LEFT;
				}
				else if (action == GameEvent.ACTION_WALK_RIGHT)
				{
					action = GameEvent.ACTION_STAND_RIGHT;
				}
				
				_entity.dispatchEvent(new GameEvent(action, true, actionData));
				return;
			}
			
			_currentAction = action;
			trace("_currentAction = " + _currentAction);
			_entity.dispatchEvent(new GameEvent(_currentAction, true, actionData));
		}
	}
}