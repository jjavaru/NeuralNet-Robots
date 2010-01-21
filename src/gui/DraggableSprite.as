package gui
{
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;

	public class DraggableSprite extends Sprite
	{
		protected var minix :int;
		protected var miniy :int;
		
		public function DraggableSprite()
		{
			super();
			this.addEventListener(MouseEvent.MOUSE_DOWN,doFollow)
			this.addEventListener(MouseEvent.MOUSE_UP,dontFollow)
		}
		
		public function destroy():void {
			this.removeEventListener(MouseEvent.MOUSE_DOWN,doFollow)
			this.removeEventListener(MouseEvent.MOUSE_UP,dontFollow)
		}
		
		public function drop() :void {
			this.removeEventListener(Event.ENTER_FRAME,followMouse)
		}
		
		//------------------------------------
		// 				Events 
		//------------------------------------
		protected function doFollow(e:Event) :void {
			this.addEventListener(Event.ENTER_FRAME,followMouse)
			minix = this.mouseX
			miniy = this.mouseY
			trace(minix,miniy)
		}
		
		protected function dontFollow(e:Event) :void {
			this.removeEventListener(Event.ENTER_FRAME,followMouse)
		}
		
		protected function followMouse(e:Event) :void{
			this.x = this.parent.mouseX-minix-this.parent.x
			this.y = this.parent.mouseY-miniy-this.parent.y
		}
	}
}