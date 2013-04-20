package miners.game.scene 
{
	public interface IEntityComponent 
	{
		function init():void;		
		function destroy():void;
		function get type():Class;
		function get entity():Entity;
		function set entity(value:Entity):void;
		function update(elapsedTime:Number):void;
	}
	
}