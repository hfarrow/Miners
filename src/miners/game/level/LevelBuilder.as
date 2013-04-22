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
			var nodes:Vector.<MapNode> = new Vector.<MapNode>(level.params.numColumns * level.params.numRows, false);
			for (var i:uint = 0; i < nodes.length; i++) 
			{
				var node:MapNode = new MapNode();
				node.xIndex = i % level.params.numColumns;
				node.yIndex = i / level.params.numColumns;
				
				var type:MapNodeType;
				if (Math.random() < level.params.rockChance || node.xIndex == 0 || node.xIndex == level.params.numColumns - 1)
				{
					type = MapNodeType.ROCK;
				}
				else
				{
					type = MapNodeType.DIRT;
				}
				
				node.setType(type);
				nodes[i] = node;
			}
			
			//starting node
			var spawnNode:MapNode = nodes[uint(level.params.numColumns / 2 + (level.params.numColumns * 2))];
			spawnNode.setType(MapNodeType.EXCAVATED);
			
			level.nodes = nodes;
			level.playerSpawnNode = spawnNode;
		}
	}
}