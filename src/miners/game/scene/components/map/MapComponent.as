package miners.game.scene.components.map
{
	import miners.game.events.GameEvent;
	import miners.game.Game;
	import miners.game.level.MapNode;
	import miners.game.level.MapNodeType;
	import miners.game.scene.Entity;
	import miners.game.scene.IEntityComponent;
	
	public class MapComponent implements IEntityComponent
	{
		private var _entity:Entity;
		private var _nodes:Vector.<MapNode>;
		
		public function MapComponent(nodes:Vector.<MapNode>)
		{
			_nodes = nodes;
		}
		
		public function get nodes():Vector.<MapNode>
		{
			return _nodes;
		}
		
		public function init():void 
		{
			_entity.createAttribute("mapNodes", nodes, this, true);
			_entity.parent.addEventListener(GameEvent.EXCAVATE_HIT, onExcavateHit);
		}
		
		public function destroy():void 
		{
			_entity.parent.removeEventListener(GameEvent.ACTION_EXCAVATE_LEFT, onExcavateHit);
		}
		
		private function onExcavateHit(e:GameEvent):void
		{
            var node:MapNode = MapNode(e.data);			
			
            if (node.type == MapNodeType.DIRT)
			{
				_entity.dispatchEvent(new GameEvent(GameEvent.NODE_EXCAVATED, true, node));
			}
		}
		
		public function get type():Class 
		{
			return MapComponent;
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
	}
}