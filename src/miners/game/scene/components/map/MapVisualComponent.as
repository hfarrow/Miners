package miners.game.scene.components.map
{
	import miners.game.events.GameEvent;
	import miners.game.Game;
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
	import starling.display.Quad;
	import starling.events.Event;
	import starling.text.TextField;
	
	// Component Dependencies:
	//	MapComponent: getAttribute("mapNodes"):Vector.<MapNode>
	public class MapVisualComponent implements IEntityComponent, IDisplayComponent
	{
		private var _params:LevelParams;
		private var _entity:Entity;
		private var _map:Sprite;
		private var _nodes:Vector.<MapNode>
		private var _compound:Compound;
		
		public function MapVisualComponent()
		{
			
		}
		
		/* INTERFACE miners.game.scene.IEntityComponent */
		
		public function init():void 
		{
			_params = Game.level.params;
			_nodes = _entity.getAttribute("mapNodes") as Vector.<MapNode>;
			_map = new Sprite();
			
			_compound = new Compound();
			createMapVisuals();
			_compound.space = Game.level.physicsSpace;
			
			_entity.parent.addEventListener(GameEvent.NODE_EXCAVATED, onNodeExcavated);
			_entity.parent.addEventListener(GameEvent.ROW_CONSTRUCTED, onRowConstructed);
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
				var quad:Quad = new Quad(nodeSize, nodeSize, MapNode.getNodeColor(node.type));
				node.quad = quad;
			}
			else
			{
				node.quad.color = MapNode.getNodeColor(node.type);
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
				nodeContainer.addChild(node.debugText);
				_map.addChild(nodeContainer);
				node.container = nodeContainer;
			}
			
			node.container.x = node.xIndex * nodeSize;
			node.container.y = node.yIndex * nodeSize;			
			
			if (node.type == MapNodeType.DIRT || node.type == MapNodeType.ROCK)
			{
				if (node.body != null)
				{
					node.body.compound = null;
				}
				
				var body:Body = new Body(BodyType.STATIC, Vec2.weak(node.xIndex * nodeSize, node.yIndex * nodeSize));
				body.shapes.add(new Polygon(Polygon.rect( 0, 0, nodeSize, nodeSize)));
				body.compound = _compound;
				node.body = body;
			}
		}
		
		private function onNodeExcavated(event:GameEvent):void
		{
			var node:MapNode = MapNode(event.data);
			node.body.compound = null;
			node.body = null;
			node.setType(MapNodeType.EXCAVATED);
			node.quad.color = MapNode.getNodeColor(node.type);
		}
		
		private function onRowConstructed(event:GameEvent):void
		{
			var columns:int = Game.level.params.numColumns;
			var recycledNodes:Vector.<MapNode> = _nodes.splice(0, columns - 1);
			_nodes.concat(recycledNodes);
			
			for (var i:int = 0; i < recycledNodes.length; ++i)
			{
				var node:MapNode = _nodes[i];
				node.setType(MapNodeType.DIRT);
				var nodeIndex:int = i + _nodes.length - 1 - recycledNodes.length
				node.xIndex = nodeIndex % Game.level.params.numColumns;
				node.yIndex = nodeIndex / Game.level.params.numColumns;
				initNode(nodeIndex);
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