package miners.game.scene.components 
{
	import miners.game.scene.Entity;
	import miners.game.scene.IDisplayComponent;
	import miners.game.scene.IEntityComponent;
	import starling.display.DisplayObject;
	import starling.text.TextField;
	
	public class TextFieldComponent implements IEntityComponent, IDisplayComponent 
	{
		private var _entity:Entity;
		public var textField:TextField;
		
		public function TextFieldComponent(width:Number, height:Number, text:String = "", font:String = "Verdana",
											fontSize:Number = 10, color:uint=0x0, bold:Boolean=false) 
		{
			textField = new TextField(width, height, text, font, fontSize, color, bold);
		}
		
		/* INTERFACE miners.game.scene.IDisplayComponent */
			
		public function get displayObject():DisplayObject 
		{
			return textField;
		}
		
		/* INTERFACE miners.game.scene.IEntityComponent */
		
		public function init():void 
		{
			
		}
		
		public function destroy():void 
		{
			
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
		
	}

}