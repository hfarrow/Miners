package miners.game.scene.components.map
{
	import flash.display.Bitmap;
	import flash.geom.Point;
	import miners.game.events.GameEvent;
	import miners.game.Game;
	import miners.game.level.Level;
	import miners.game.level.LevelParams;
	import miners.game.level.MapNode;
	import miners.game.level.MapNodeType;
	import miners.game.scene.Entity;
	import miners.game.scene.IEntityComponent;
	import miners.game.scene.IDisplayComponent;
	import nape.geom.Vec2;
	import nape.phys.Body;
	import nape.phys.BodyType;
	import nape.phys.Compound;
	import nape.shape.Polygon;
	import starling.display.DisplayObject;
	import starling.display.Sprite;
	import starling.display.Image;
	import starling.events.Event;
	import starling.text.TextField;
	import starling.textures.Texture;
	
	// Component Dependencies:
	//	MapComponent: getAttribute("mapNodes"):Vector.<MapNode>
	public class MapVisualsComponent implements IEntityComponent, IDisplayComponent
	{
		[Embed(source="../../../../../../content/ground.jpg")]
		protected var GroundImage:Class;
 
		private var _params:LevelParams;
		private var _entity:Entity;
		private var _map:Sprite;
		private var _nodes:Vector.<MapNode>
		private var _compound:Compound;
		private var _groundTexture:Texture;
		
		public function MapVisualsComponent()
		{
			
		}
		
		/* INTERFACE miners.game.scene.IEntityComponent */
		
		public function init():void 
		{
			_params = Game.level.params;
			_nodes = _entity.getAttribute("mapNodes") as Vector.<MapNode>;
			_map = new Sprite();
			
			var groundImage:Bitmap = new GroundImage();
			_groundTexture = Texture.fromBitmap(groundImage);
			
			_compound = new Compound();
			createMapVisuals();
			_compound.space = Game.level.physicsSpace;
			
			_entity.parent.addEventListener(GameEvent.NODE_EXCAVATED, onNodeExcavated);
			_entity.parent.addEventListener(GameEvent.CONSTRUCT_ROW, onRowConstructed);
		}
			
		public function destroy():void 
		{
			
		}
		
		private function createMapVisuals():void
		{
			for (var i:int = 0; i < _nodes.length; ++i)
			{
				initNode(i);
			}
		}
		
		private function initNode(index:int):void
		{
			var node:MapNode = _nodes[index];
			
			var nodeSize:Number = _params.nodeSize;
			if (node.quad == null)
			{
				var quad:Image = new Image(_groundTexture);
				quad.width = nodeSize;
				quad.height = nodeSize;
				quad.texture.repeat = true;
				node.quad = quad;
			}
			
			if (node.debugText == null)
			{
				var debugText:TextField = new TextField(nodeSize, nodeSize, index.toString(), "Verdana", 7);
				node.debugText = debugText;
			}
			else
			{
				node.debugText.text = index.toString();
			}
			
			if (node.container == null)
			{
				var nodeContainer:Sprite = new Sprite();
				nodeContainer.addChild(quad);
				//nodeContainer.addChild(node.debugText);
				_map.addChild(nodeContainer);
				node.container = nodeContainer;
			}
			
			node.container.x = node.xIndex * nodeSize;
			node.container.y = node.yIndex * nodeSize;
					
			var texStepX:Number = _params.numColumns / (_params.numColumns * nodeSize);
			var texStepY:Number = _params.numRows / (_params.numRows * nodeSize);
			node.quad.setTexCoords(0, new Point(node.xIndex * texStepX, node.yIndex * texStepY));
			node.quad.setTexCoords(1, new Point(node.xIndex * texStepX + texStepX, node.yIndex * texStepY));
			node.quad.setTexCoords(2, new Point(node.xIndex * texStepX, node.yIndex * texStepY + texStepY));
			node.quad.setTexCoords(3, new Point(node.xIndex * texStepX + texStepX, node.yIndex * texStepY + texStepY));
			node.quad.color = MapNode.getNodeColor(node.type);	
			
			if (node.type == MapNodeType.DIRT || node.type == MapNodeType.ROCK)
			{
				if (node.body != null)
				{
					node.body.compound = null;
					node.body.cbTypes.clear();
				}
				
				var body:Body = new Body(BodyType.STATIC, Vec2.weak(node.xIndex * nodeSize, node.yIndex * nodeSize));
				body.shapes.add(new Polygon(Polygon.rect( 0, 0, nodeSize, nodeSize)));
				body.compound = _compound;
				body.cbTypes.add(Level.CB_GROUND);
				node.body = body;
			}
		}
		
		private function onNodeExcavated(event:GameEvent):void
		{
			var node:MapNode = MapNode(event.data);
			node.body.compound = null;
			node.body.cbTypes.clear();
			node.body = null;
			node.setType(MapNodeType.EXCAVATED);
			node.quad.color = MapNode.getNodeColor(node.type);
		}
		
		private function onRowConstructed(event:GameEvent):void
		{
			var columns:int = Game.level.params.numColumns;
			var newRowIndexY:int = _nodes[_nodes.length -1].yIndex + 1;
			
			var recycledNodes:Vector.<MapNode> = _nodes.splice(0, columns);
			for each (var recycledNode:MapNode in recycledNodes)
			{
				_nodes.push(recycledNode);
			}
			
			for (var i:int = 0; i < recycledNodes.length; ++i)
			{
				var node:MapNode = recycledNodes[i];
				var nodeIndex:int = i + _nodes.length - recycledNodes.length;
				node.xIndex = i;
				node.yIndex = newRowIndexY;
				var type:MapNodeType;
				if (Math.random() < _params.rockChance || node.xIndex == 0 || node.xIndex == _params.numColumns - 1)
				{
					type = MapNodeType.ROCK;
				}
				else
				{
					type = MapNodeType.DIRT;
				}
				node.setType(type);
				initNode(nodeIndex);
			}
			
			// Wrong place for a game over check but it is just here so that the game can end without any exceptions.
			// this function could dispatch an event that level listens for where it does this check instead.
			var index:int = Game.level.getNodeIndexAtWorldPosition(Game.level.player.x, Game.level.player.y);
			if (index < 0 && !Game.level.isGameOver)
			{
				trace("GAME OVER");
				Game.level.gameOver();
			}
		}
		
		public function get type():Class 
		{
			return IDisplayComponent;
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
			
		}
		
		/* INTERFACE miners.game.scene.components.IDisplayComponent */
		
		public function get displayObject():DisplayObject
		{
			return _map;
		}
	}
}