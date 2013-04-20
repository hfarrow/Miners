package miners.game.level 
{
	public class LevelBuilder 
	{
		public var level:Level;
		
		public function LevelBuilder(level:Level) 
		{
			this.level = level;
		}
		
		public function generateRandomLevel():void
		{
			var nodes:Vector.<MapNode> = new Vector.<MapNode>(level.params.numColumns * level.params.numRows, true);
			for (var i:uint = 0; i < nodes.length; i++) 
			{
				var node:MapNode = new MapNode(MapNodeType.DIRT);
				nodes[i] = node;
				
				node.xIndex = i % level.params.numColumns;
				node.yIndex = i / level.params.numColumns;
			}
			
			//starting node
			var spawnNode:MapNode = nodes[uint(level.params.numColumns / 2)];
			spawnNode.setType(MapNodeType.EXCAVATED);
			
			level.nodes = nodes;
			level.playerSpawnNode = spawnNode;
		}
	}
}