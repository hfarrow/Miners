package miners.game.level 
{
	import flash.geom.Rectangle;
	import flash.utils.getTimer;
	import miners.game.scene.components.CameraComponent;
	import miners.game.scene.components.map.MapComponent;
	import miners.game.scene.components.map.MapVisualComponent;
	import miners.game.scene.components.PhysicsComponent;
	import miners.game.scene.components.SpatialComponent;
	import miners.game.scene.components.TextFieldComponent;
	import miners.game.scene.IDisplayComponent;
	import miners.game.scene.components.player.PlayerControlComponent;
	import miners.game.scene.components.QuadComponent;
	import miners.game.scene.Entity;
	import miners.game.scene.SceneManager;
	import nape.geom.Vec2;
	import nape.phys.Body;
	import nape.phys.BodyType;
	import nape.phys.Material;
	import nape.shape.Circle;
	import nape.space.Space;
	import nape.util.BitmapDebug;
	import nape.util.Debug;
	import starling.core.Starling;
	import starling.display.Sprite;
	import miners.game.Game;
	import starling.display.Stage;
	
	public class Level
	{		
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
		private var prevTimeMS:int;
        private var simulationTime:Number;
		
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
			_physicsDebug = new BitmapDebug(stage.stageWidth, stage.stageHeight, stage.color, true);
			Starling.current.nativeOverlay.addChild(_physicsDebug.display);
			
			// Set up fixed time step logic.
            prevTimeMS = getTimer();
            simulationTime = 0.0;
		}
		
		private function initMap():void
		{
			var map:MapComponent = new MapComponent(_nodes);
			var mapVisuals:MapVisualComponent = new MapVisualComponent();
			_map = _sceneManager.createEntity([map, mapVisuals]);
		}
		
		private function initPlayer():void
		{
			var playerSize:Number = params.nodeSize / 2;
			var startX:Number = _playerSpawnNode.xIndex * params.nodeSize + ((params.nodeSize - playerSize) / 2);
			var startY:Number = params.nodeSize - playerSize;
			
			var body:Body = new Body(BodyType.DYNAMIC, new Vec2(startX + playerSize / 2, startY + playerSize / 2 - 5));
			body.shapes.add(new Circle(playerSize / 2, null, new Material(0.2, 1, 1, 1, 1)));
			body.space = _physicsSpace;
			
			var spatial:SpatialComponent = new SpatialComponent();
			spatial.lockedRotation = true;
			var physics:PhysicsComponent = new PhysicsComponent(body);
			var controller:PlayerControlComponent = new PlayerControlComponent();
			var display:IDisplayComponent = new QuadComponent(playerSize, playerSize, 0xffffff);
			var debugDisplay:IDisplayComponent = new TextFieldComponent(playerSize, playerSize, "p", "Verdana", 7);
			var diplayOffset:Number = -playerSize / 2;
			display.displayObject.x = diplayOffset;
			display.displayObject.y = diplayOffset;
			debugDisplay.displayObject.x = diplayOffset;
			debugDisplay.displayObject.y = diplayOffset;
			_player = _sceneManager.createEntity([spatial, physics, controller, display, debugDisplay]);
			_player.setAttribute("x", startX);
			_player.setAttribute("y", startY);
		}
		
		private function initCamera():void
		{			
			var spatial:SpatialComponent = new SpatialComponent();
			var cameraComponent:CameraComponent = new CameraComponent(container, 0, 0);
			_camera = _sceneManager.createEntity([spatial, cameraComponent]);
			_camera.setAttribute("y", -100);
		}
		
		public function set nodes(value:Vector.<MapNode>):void
		{
			_nodes = Vector.<MapNode>(value);
		}
		
		public function set playerSpawnNode(value:MapNode):void
		{
			_playerSpawnNode = value;
		}
		
		public function getNodeAtWorldPosition(x:Number, y:Number):MapNode
		{
			var xIndex:int = int(Math.floor(x / params.nodeSize));
			var yIndex:int = int(Math.floor(y / params.nodeSize));
			
			return _nodes[(yIndex * params.numColumns) + xIndex];
		}
		
		public function getNodeAtIndex(xIndex:int, yIndex:int):MapNode
		{
			return _nodes[(yIndex * params.numColumns) + xIndex];
		}
		
		//public function getNodeAtStagePosition(x:Number, y:Number):MapNode
		
		public function update(elapsedTime:Number):void
		{
			var curTimeMS:uint = getTimer();
            if (curTimeMS == prevTimeMS) {
                // No time has passed!
                return;
            }

            // Amount of time we need to try and simulate (in seconds).
            var deltaTime:Number = (curTimeMS - prevTimeMS) / 1000;
            // We cap this value so that if execution is paused we do
            // not end up trying to simulate 10 minutes at once.
            if (deltaTime > 0.05) {
                deltaTime = 0.05;
            }
            prevTimeMS = curTimeMS;
            simulationTime += deltaTime;

            // Keep on stepping forward by fixed time step until amount of time
            // needed has been simulated.
            while (_physicsSpace.elapsedTime < simulationTime) {
                _physicsSpace.step(1 / Starling.current.nativeStage.frameRate);
            }
			
			_sceneManager.update(elapsedTime);
			_camera.setAttribute("y", _camera.y + deltaTime * 5);
			
			/*
			_physicsDebug.clear();
			_physicsDebug.draw(_physicsSpace);
			_physicsDebug.flush();
			*/
			
			_physicsDebug.display.x = container.x;
			_physicsDebug.display.y = container.y;
			_physicsDebug.display.rotation = container.rotation;
		}
	}
}