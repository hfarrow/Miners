package miners.game.scene 
{
	import miners.game.scene.IDisplayComponent;
	import starling.display.Sprite;
	import flash.display.DisplayObject;
	import flash.utils.Dictionary;
	public class Entity extends Sprite
	{
		public var manager:SceneManager;
		private var _components:Dictionary;
		private var _attributes:Dictionary;
		
		public function Entity(manager:SceneManager)
		{
			this.manager = manager;
			_components = new Dictionary();
			_attributes = new Dictionary();
		}
		
		public function init():void
		{
			for each(var components:Vector.<IEntityComponent> in _components)
			{
				for each(var component:IEntityComponent in components)
				{
					component.init();
				}
			}
			
			addDisplayComponents();
		}
		
		public function destroy():void 
		{
			removeDisplayComponents();
			removeAllComponents();
		}
		
		private function addDisplayComponents():void
		{
			var entityComponents:Vector.<IEntityComponent> = getComponentsOfType(IDisplayComponent);
			if (entityComponents == null)
			{
				return;
			}
			
			var displayComponents:Vector.<IDisplayComponent> = Vector.<IDisplayComponent>(entityComponents);
			if (displayComponents != null)
			{
				for each(var displayComponent:IDisplayComponent in displayComponents)
				{
					addChild(displayComponent.displayObject);
				}
			}
		}
		
		private function removeDisplayComponents():void
		{
			var entityComponents:Vector.<IEntityComponent> = getComponentsOfType(IDisplayComponent);
			if (entityComponents == null)
			{
				return;
			}
			
			var displayComponents:Vector.<IDisplayComponent> = Vector.<IDisplayComponent>(entityComponents);
			if (displayComponents != null)
			{
				for each(var displayComponent:IDisplayComponent in displayComponents)
				{
					displayComponent.displayObject.removeFromParent();
				}
			}
		}
		
		// TODO: need to be able to "createNumberAttribute", "createStringAttribute", etc. so that there is less casting	
		public function createAttribute(name:String, value:Object, owner:IEntityComponent, isReadOnly:Boolean=false):EntityAttribute
		{
			if (_attributes[name] != null)
			{
				throw new Error(owner + "is trying to add an attribute named '" + name + "' that already exists.");
			}
			else
			{
				var attribute:EntityAttribute = new EntityAttribute(name, value, owner, isReadOnly);
				_attributes[name] = attribute;
				return attribute;
			}
			return null;
		}
		
		public function setAttribute(name:String, value:Object):void
		{
			var attribute:EntityAttribute = _attributes[name];
			if (attribute == null)
			{
				throw new Error("Trying to set the value of an attribute named '" + name + "' that does not exist.");
			}
			else
			{
				if (attribute.isReadOnly)
				{
					throw new Error("Trying to set a read-only attribute named '" + name + "'. The owner of this attribute should be able to \
set the value through the EntityAttribute reference returned to the component when createAttribute was called.");
				}
				else
				{
					attribute.value = value;
				}
			}
		}
		
		public function getAttribute(name:String):Object
		{
			var attribute:EntityAttribute = _attributes[name];
			if (attribute == null)
			{
				throw new Error("Trying to get the value of an attribute named '" + name + "' that does not exists.");
			}
			else
			{
				return attribute.value;
			}
		}
		
		public function tryGetAttribute(name:String, defaultValue:Object = null):Object
		{
			var attribute:EntityAttribute = _attributes[name];
			if (attribute == null)
			{
				return defaultValue;
			}
			else
			{
				return attribute.value;
			}
		}
		
		public function hasAttribute(name:String):Boolean
		{
			return _attributes[name] != null;
		}
		
		public function isAttributeReadOnly(name:String):Boolean
		{
			var attribute:EntityAttribute = _attributes[name];
			if (attribute == null)
			{
				throw new Error("Trying to check the read-only flag of an attribute named '" + name + "' that does not exists.");
			}
			else
			{
				return attribute.isReadOnly;
			}
		}
		
		public function getComponent(type:Class):IEntityComponent
		{
			if (_components[type] != null && _components[type].length != 1)
			{
				throw new Error("There is more than one component for the specified type. Please use getComponentsOfType instead.");
			}
			
			return IEntityComponent(_components[type][0]);
		}
		
		public function getComponentsOfType(type:Class):Vector.<IEntityComponent>
		{
			return _components[type];
		}
		
		public function addComponent(component:IEntityComponent, doInit:Boolean=true):void
		{
			if (_components[component.type] == null)
			{
				_components[component.type] = new Vector.<IEntityComponent>();
			}
			
			component.entity = this;
			_components[component.type].push(component);
			
			if (doInit)
			{
				component.init();
			}
		}
		
		public function removeComponent(type:Class, componentToRemove:IEntityComponent):void
		{
			var componentsForType:Vector.<IEntityComponent> = _components[type];
			if (componentsForType != null && componentsForType.length > 0)
			{
				var componentIndex:int = componentsForType.indexOf(componentToRemove);
				if (componentIndex != -1)
				{
					componentToRemove.entity = null;
					componentToRemove.destroy();
					componentsForType.splice(componentIndex, 1);
					return;
				}
			}

			throw new Error("A component of the provided type or instance does not exist in this entity.");			
		}
		
		public function removeAllComponents():void
		{
			for each(var components:Vector.<IEntityComponent> in _components)
			{
				for each(var component:IEntityComponent in components)
				{
					component.destroy();
				}
				components = null;
			}
			_components = null;
		}
		
		public function update(elapsedTime:Number):void
		{
			for each(var components:Vector.<IEntityComponent> in _components)
			{
				for each(var component:IEntityComponent in components)
				{
					component.update(elapsedTime);
				}
			}
		}
	}
}