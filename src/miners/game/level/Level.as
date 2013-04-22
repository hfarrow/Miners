package miners.game.level 
{
	import flash.utils.getTimer;
	import miners.game.events.GameEvent;
	import miners.game.Game;
	import miners.game.graphics.filters.SpotlightFilter;
	import miners.game.scene.components.CameraComponent;
	import miners.game.scene.components.map.MapComponent;
	import miners.game.scene.components.map.MapVisualsComponent;
	import miners.game.scene.components.PhysicsComponent;
	import miners.game.scene.components.player.PlayerControlComponent;
	import miners.game.scene.components.player.PlayerVisualsComponent;
	import miners.game.scene.components.SpatialComponent;
	import miners.game.scene.Entity;
	import miners.game.scene.SceneManager;
	import nape.callbacks.CbType;
	import nape.geom.Vec2;
	import nape.phys.Body;
	import nape.phys.BodyType;
	import nape.phys.Material;
	import nape.shape.Circle;
	import nape.space.Space;
	import nape.util.Debug;
	import nape.util.ShapeDebug;
	import starling.core.Starling;
	import starling.display.Sprite;
	import starling.display.Stage;
	
	public class Level
	{
		public static const CB_PLAYER:CbType = new CbType();
		public static const CB_GROUND:CbType = new CbType();
		
		public var container:Sprite;		
		public var params:LevelParams;
		
		private var _builder:LevelBuilder;
		private var _sceneManager:SceneManager;
		private var _player:Entity;
		private var _map:Entity;
		private var _camera:Entity;
		
		private var _nodes:Vector.<MapNode>;
		private var _playerSpawnNode:MapNode;
		
		private var _physicsSpace:Space;
		private var _physicsDebug:Debug;
		private var _debugPhysics:Boolean = true;
		private var _prevTimeMS:int;
        private var _simulationTime:Number;
		private var _nextRowDeletionY:Number;
		
		private var _isGameOver:Boolean = false;
		
		public function Level(params:LevelParams) 
		{
			this.params = params;
		}
		
		public function get sceneManager():SceneManager
		{
			return _sceneManager;
		}
		
		public function get physicsSpace():Space
		{
			return _physicsSpace;
		}
			
		public function init():void
		{
			initContainer();
			initLevelBuilder();
			initSceneManager();
			initPhysics();
			initMap();
			initPlayer();
			initCamera();
		}
		
		private function initContainer():void
		{
			if (Game.current.contains(container))
			{
				Game.current.removeChild(container, true);
			}
			
			container = new Sprite();
			container.filter = new SpotlightFilter(0, 0, 1.2, 1.2, .50);
			Game.current.addChild(container);
		}
		
		private function initLevelBuilder():void
		{
			_builder = new LevelBuilder(this);
			_builder.generateRandomLevel();
		}
		
		private function initSceneManager():void 
		{
			_sceneManager = new SceneManager(container);	
		}
		
		private function initPhysics():void
		{
			_physicsSpace = new Space(Vec2.weak(0, 300));
			var stage:Stage = Game.current.stage;
			_physicsDebug = new ShapeDebug(stage.stageWidth, stage.stageHeight, stage.color);
			Starling.current.nativeOverlay.addChild(_physicsDebug.display);
			
			// Set up fixed time step logic.
            _prevTimeMS = getTimer();
            _simulationTime = 0.0;
		}
		
		private function initMap():void
		{
			var map:MapComponent = new MapComponent(_nodes);
			var mapVisuals:MapVisualsComponent = new MapVisualsComponent();
			_map = _sceneManager.createEntity([map, mapVisuals]);
		}
		
		private function initPlayer():void
		{
			var playerSize:Number = params.nodeSize / 2;
			var startX:Number = _playerSpawnNode.xIndex * params.nodeSize + ((params.nodeSize - playerSize) / 2);
			var startY:Number = params.nodeSize * _playerSpawnNode.yIndex + params.nodeSize - playerSize;
			
			var body:Body = new Body(BodyType.DYNAMIC, new Vec2(startX + playerSize / 2, startY + playerSize / 2 - 5));
			body.shapes.add(new Circle(playerSize / 2, null, new Material(0.2, 0.05, 0.05, 1, 1)));
			body.space = _physicsSpace;
			body.cbTypes.add(CB_PLAYER);
			
			var spatial:SpatialComponent = new SpatialComponent();
			spatial.lockedRotation = true;
			var physics:PhysicsComponent = new PhysicsComponent(body);
			var controller:PlayerControlComponent = new PlayerControlComponent();
			var display:PlayerVisualsComponent = new PlayerVisualsComponent();
			_player = _sceneManager.createEntity([spatial, physics, controller, display]);
			_player.setAttribute("x", startX);
			_player.setAttribute("y", startY);
		}
		
		private function initCamera():void
		{			
			var spatial:SpatialComponent = new SpatialComponent();
			var cameraComponent:CameraComponent = new CameraComponent(container, 0, 50);
			_camera = _sceneManager.createEntity([spatial, cameraComponent]);
			_camera.setAttribute("y", -20);
			_nextRowDeletionY = -params.nodeSize;
		}
		
		public function set nodes(value:Vector.<MapNode>):void
		{
			_nodes = Vector.<MapNode>(value);
		}
		
		public function set playerSpawnNode(value:MapNode):void
		{
			_playerSpawnNode = value;
		}
		
		public function get player():Entity
		{
			return _player;
		}
		
		public function getNodeIndexAtWorldPosition(x:Number, y:Number):int
		{
			var xIndex:int = int(Math.floor(x / params.nodeSize));
			var yIndex:int = int(Math.floor(y / params.nodeSize));
			
			// Base index off of the lowest index currently active.
			yIndex -= _nodes[0].yIndex;
			
			return (yIndex * params.numColumns) + xIndex;
		}
		
		public function getNodeAtWorldPosition(x:Number, y:Number):MapNode
		{
			var xIndex:int = int(Math.floor(x / params.nodeSize));
			var yIndex:int = int(Math.floor(y / params.nodeSize));
			
			// Base index off of the lowest index currently active.
			yIndex -= _nodes[0].yIndex;
			
			var index:int = (yIndex * params.numColumns) + xIndex;
			if (index >= 0 && index < _nodes.length)
			{
				return _nodes[(yIndex * params.numColumns) + xIndex];
			}
			
			return null;
		}
		
		public function getNodeAtIndex(xIndex:int, yIndex:int):MapNode
		{
			return _nodes[(yIndex * params.numColumns) + xIndex];
		}
		
		public function getHighestNodeYIndex():int
		{
			return _nodes[_nodes.length - 1].yIndex;
		}
		
		//public function getNodeAtStagePosition(x:Number, y:Number):MapNode
		
		public function update(elapsedTime:Number):void
		{
			// We cap this value so that if execution is paused we do
            // not end up trying to simulate 10 minutes at once.
            if (elapsedTime > 0.08) 
			{
                elapsedTime = 0.08;
            }
			
			updatePhysics(elapsedTime);
			updateScene(elapsedTime);
			updateCamera(elapsedTime);
			updateDebugPhysics(elapsedTime);
		}
		
		private function updatePhysics(elapsedTime:Number):void
		{
			var curTimeMS:uint = getTimer();
            if (curTimeMS == _prevTimeMS) 
			{
                // No time has passed!
                return;
            }

            _prevTimeMS = curTimeMS;
            _simulationTime += elapsedTime;

            // Keep on stepping forward by fixed time step until amount of time
            // needed has been simulated.
            while (_physicsSpace.elapsedTime < _simulationTime) 
			{
                _physicsSpace.step(1 / Starling.current.nativeStage.frameRate);
            }
		}
		
		private function updateDebugPhysics(elapsedTime:Number):void
		{
			if (_debugPhysics)
			{
				_physicsDebug.clear();
				_physicsDebug.draw(_physicsSpace);
				_physicsDebug.flush();
			}
			
			_physicsDebug.display.x = container.x;
			_physicsDebug.display.y = container.y;
			_physicsDebug.display.rotation = container.rotation;
		}
		
		private function updateScene(elapsedTime:Number):void
		{
			_sceneManager.update(elapsedTime);
			var spotlight:SpotlightFilter = container.filter as SpotlightFilter;
			spotlight.centerX = _player.getAttribute("x") as Number;
			spotlight.centerY = (_player.getAttribute("y") as Number) + container.y;
		}
		
		private function updateCamera(elapsedTime:Number):void
		{
			_camera.setAttribute("y", _camera.y + elapsedTime * 10);
			var visibleHeight:Number = params.numRows * params.nodeSize;
			if (container.y <= _nextRowDeletionY + 50)
			{
				_nextRowDeletionY -= params.nodeSize;
				container.dispatchEvent(new GameEvent(GameEvent.CONSTRUCT_ROW));
			}
		}
		
		public function get isGameOver():Boolean
		{
			return _isGameOver;
		}
		
		public function gameOver():void
		{
			_isGameOver = true;
			sceneManager.destroyEntity(player);
		}
	}
}