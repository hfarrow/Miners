package miners.game.scene 
{	
	import starling.display.DisplayObjectContainer;
	import starling.display.DisplayObject;
	
	public class SceneManager 
	{
		private var _root:DisplayObjectContainer;
		private var _entities:Vector.<Entity>;
		
		public function SceneManager(root:DisplayObjectContainer) 
		{
			_root = root;
			_entities = new Vector.<Entity>();
		}
		
		public function createEntity(components:Array):Entity
		{
			var entity:Entity = new Entity(this);
			_entities.push(entity);
			
			for each(var component:IEntityComponent in components)
			{
				entity.addComponent(component, false);
			}
			
			_root.addChild(entity);
			entity.init();			
			return entity;
		}
		
		public function destroyEntity(entity:Entity):void
		{
			_root.removeChild(entity);
			entity.destroy();
			entity.manager = null;
		}
		
		public function update(elapsedTime:Number):void
		{
			for each(var entity:Entity in _entities)
			{
				entity.update(elapsedTime);
			}
		}
	}

}