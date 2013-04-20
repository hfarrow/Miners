package miners.game.scene.components.map
{
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
		
		/* INTERFACE miners.game.scene.IEntityComponent */
		
		public function init():void 
		{
			_entity.createAttribute("mapNodes", nodes, this, true);
		}
		
		public function destroy():void 
		{
			
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