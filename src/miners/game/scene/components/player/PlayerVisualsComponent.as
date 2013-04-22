package miners.game.scene.components.player
{
	import miners.game.events.GameEvent;
	import miners.game.Game;
	import miners.game.level.MapNode;
	import miners.game.scene.Entity;
	import miners.game.scene.IDisplayComponent;
	import miners.game.scene.IEntityComponent;
	import nape.phys.Body;
	import starling.core.Starling;
	import starling.display.DisplayObject;
	import starling.display.MovieClip;
	import starling.display.Sprite;
	import starling.textures.Texture;
	import starling.textures.TextureAtlas;

	public class PlayerVisualsComponent implements IEntityComponent, IDisplayComponent
	{
		[Embed(source="../../../../../../content/player_sprite.png")]
		private var AnimTexture:Class;
		
		[Embed(source="../../../../../../content/player_sprite.xml", mimeType="application/octet-stream")]
		private var AnimData:Class;
		
		private var _entity:Entity;
		private var _container:Sprite;
		private var _currentAnimation:MovieClip;
		private var _standFrontAnimation:MovieClip;
		private var _standLeftAnimation:MovieClip;
		private var _standRightAnimation:MovieClip;
		private var _walkLeftAnimation:MovieClip;
		private var _walkRightAnimation:MovieClip;
		private var _excavateLeftAnimation:MovieClip;
		private var _excavateRightAnimation:MovieClip;
		private var _excavateDownAnimation:MovieClip;
		
		private var _excavateTarget:MapNode;
		
		public function PlayerVisualsComponent()
		{
			_container = new Sprite();
		}
		
		public function init():void
		{
			_entity.addChild(_container);
			
			var texture:Texture = Texture.fromBitmap(new AnimTexture());
			var xmlData:XML = XML(new AnimData());
			var textureAtlas:TextureAtlas = new TextureAtlas(texture, xmlData);
			
			//Fetch the sprite sequence form the texture using their name
			_standFrontAnimation = new MovieClip(textureAtlas.getTextures("stand_front"), 20);
			_standLeftAnimation = new MovieClip(textureAtlas.getTextures("stand_left"), 20);
			_standRightAnimation = new MovieClip(textureAtlas.getTextures("stand_right"), 20);
			_walkLeftAnimation = new MovieClip(textureAtlas.getTextures("walk_left"), 7);
			_walkRightAnimation = new MovieClip(textureAtlas.getTextures("walk_right"), 7);
			_excavateLeftAnimation = new MovieClip(textureAtlas.getTextures("excavate_left"), 7);
			_excavateRightAnimation = new MovieClip(textureAtlas.getTextures("excavate_right"), 7);
			_excavateDownAnimation = new MovieClip(textureAtlas.getTextures("excavate_down"), 7);
			
			_excavateLeftAnimation.loop = false;
			_excavateRightAnimation.loop = false;
			_excavateDownAnimation.loop = false;
			
			_container.addChild(_standFrontAnimation);
			_currentAnimation = _standFrontAnimation;
			Starling.juggler.add(_standFrontAnimation);
			
			_container.x = -(_container.width / 2);
			_container.y = -(_container.height) + (Game.level.params.nodeSize / 4);
			
			_entity.addEventListener(GameEvent.ACTION_STAND_FRONT, onStandFront);
			_entity.addEventListener(GameEvent.ACTION_STAND_LEFT, onStandLeft);
			_entity.addEventListener(GameEvent.ACTION_STAND_RIGHT, onStandRight);
			_entity.addEventListener(GameEvent.ACTION_WALK_LEFT, onWalkLeft);
			_entity.addEventListener(GameEvent.ACTION_WALK_RIGHT, onWalkRight);
			_entity.addEventListener(GameEvent.ACTION_EXCAVATE_LEFT, onExcavateLeft);
			_entity.addEventListener(GameEvent.ACTION_EXCAVATE_RIGHT, onExcavateRight);
			_entity.addEventListener(GameEvent.ACTION_EXCAVATE_DOWN, onExcavateDown);
		}
		
		public function destroy():void 
		{
			_entity.removeEventListener(GameEvent.ACTION_STAND_FRONT, onStandFront);
			_entity.removeEventListener(GameEvent.ACTION_STAND_LEFT, onStandLeft);
			_entity.removeEventListener(GameEvent.ACTION_STAND_RIGHT, onStandRight);
			_entity.removeEventListener(GameEvent.ACTION_WALK_LEFT, onWalkLeft);
			_entity.removeEventListener(GameEvent.ACTION_WALK_RIGHT, onWalkRight);
			_entity.removeEventListener(GameEvent.ACTION_EXCAVATE_LEFT, onExcavateLeft);
			_entity.removeEventListener(GameEvent.ACTION_EXCAVATE_RIGHT, onExcavateRight);
			_entity.removeEventListener(GameEvent.ACTION_EXCAVATE_DOWN, onExcavateDown);
			
			if (_currentAnimation != null)
			{
				Starling.juggler.remove(_currentAnimation);
			}
			_currentAnimation.removeFromParent();
			_standFrontAnimation.dispose();
			_standLeftAnimation.dispose();
			_standRightAnimation.dispose();
			_walkLeftAnimation.dispose();
			_walkRightAnimation.dispose();
			_excavateLeftAnimation.dispose();
			_excavateRightAnimation.dispose();
			_excavateDownAnimation.dispose();
			_container.removeFromParent();
			_container.dispose();
			_excavateTarget = null;
		}
		
		public function update(elaspedTime:Number):void
		{
			if (_currentAnimation == _excavateLeftAnimation || 
				_currentAnimation == _excavateRightAnimation || 
				_currentAnimation == _excavateDownAnimation)
			{
				if (_currentAnimation.isComplete)
				{
					if (_excavateTarget == null)
					{
						trace("NULL _excavateTarget");
					}
   					if (_excavateTarget != null)
					{
						_entity.dispatchEvent(new GameEvent(GameEvent.EXCAVATE_HIT, true, _excavateTarget));
						_excavateTarget = null;
					}
				}
			}
		}
		
		private function playAnimation(newAnimation:MovieClip):void
		{
			if (newAnimation == _currentAnimation)
			{
				// restart the animation
				_currentAnimation.currentFrame = 0;
			}
			else
			{
				Starling.juggler.remove(_currentAnimation);
				_currentAnimation.removeFromParent();
				_currentAnimation = newAnimation;
				_currentAnimation.currentFrame = 0;
				_container.addChild(_currentAnimation);
				Starling.juggler.add(_currentAnimation);
			}
		}
		
		private function onStandFront(e:GameEvent):void 
		{
			playAnimation(_standFrontAnimation);
		}
		
		private function onStandLeft(e:GameEvent):void 
		{
			playAnimation(_standLeftAnimation);
		}
		
		private function onStandRight(e:GameEvent):void 
		{
			playAnimation(_standRightAnimation);
		}
		
		private function onWalkLeft(e:GameEvent):void 
		{
			playAnimation(_walkLeftAnimation);
		}
		
		private function onWalkRight(e:GameEvent):void 
		{
			playAnimation(_walkRightAnimation);
		}
		
		private function onExcavateLeft(e:GameEvent):void 
		{
            _excavateTarget = MapNode(e.data);
			playAnimation(_excavateLeftAnimation);
		}
		
		private function onExcavateRight(e:GameEvent):void 
		{
			_excavateTarget = MapNode(e.data);
			playAnimation(_excavateRightAnimation);
		}
		
		private function onExcavateDown(e:GameEvent):void 
		{
			_excavateTarget = MapNode(e.data);
			playAnimation(_excavateDownAnimation);
		}
		
		public function get type():Class 
		{
			return PlayerVisualsComponent;
		}
		
		public function get entity():Entity 
		{
			return _entity;
		}
		
		public function set entity(value:Entity):void 
		{
			_entity = value;
		}
		
		public function get displayObject():DisplayObject 
		{
			return _container;
		}	
	}
}