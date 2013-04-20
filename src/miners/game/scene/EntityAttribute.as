package miners.game.scene
{
	public class EntityAttribute
	{
		private var _name:String;
		private var _value:Object;
		private var _owner:IEntityComponent;
		private var _isReadOnly:Boolean;
		
		public function EntityAttribute(name:String, value:Object, owner:IEntityComponent, isReadOnly:Boolean=false)
		{
			_name = name;
			_value = value;
			_owner = owner;
			_isReadOnly = isReadOnly;
		}
		
		public function get name():String
		{
			return _name;
		}
		
		public function get value():Object
		{
			return _value;
		}
		
		public function get owner():IEntityComponent 
		{
			return _owner;
		}
		
		public function get isReadOnly():Boolean 
		{
			return _isReadOnly;
		}
		
		public function set value(v:Object):void
		{
			_value = v;
		}
	}
}