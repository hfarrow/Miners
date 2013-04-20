package miners.game.scene.components
{
	import miners.game.Game;
	import miners.game.scene.Entity;
	import miners.game.scene.EntityAttribute;
	import miners.game.scene.IEntityComponent;
	import nape.phys.Body;
	
	// Component Dependencies:
	//	SpatialComponent: x, y, rotation
	public class PhysicsComponent implements IEntityComponent
	{
		private var _entity:Entity;
		private var _body:Body
		
		public function PhysicsComponent(body:Body)
		{
			_body = body;
		}
		
		/* INTERFACE miners.game.scene.IEntityComponent */
		
		public function init():void 
		{
			_entity.createAttribute("physicsBody", _body, this);
		}
		
		public function destroy():void 
		{
			
		}
		
		public function get type():Class 
		{
			return PhysicsComponent;
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
			_entity.setAttribute("x", _body.position.x);
			_entity.setAttribute("y", _body.position.y);
			_entity.setAttribute("rotation", _body.rotation);
		}
	}
}