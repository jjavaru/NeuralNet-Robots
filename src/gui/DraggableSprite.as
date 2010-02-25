package gui
{
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;

	public class DraggableSprite extends Sprite
	{	
		protected var _propagate:Boolean
		public function DraggableSprite(dragByChild:Boolean = false)
		{
			super();
			this.addEventListener(MouseEvent.MOUSE_DOWN,doFollow)
			this.addEventListener(MouseEvent.MOUSE_UP,dontFollow)
			this._propagate = dragByChild
		}
		
		public function destroy():void {
			this.removeEventListener(MouseEvent.MOUSE_DOWN,doFollow)
			this.removeEventListener(MouseEvent.MOUSE_UP,dontFollow)
		}
		
		public function drop() :void {
			stopDrag()
		}
		
		//------------------------------------
		// 				Events 
		//------------------------------------
		protected function doFollow(e:Event) :void {
			if(_propagate || e.target == this){
				this.startDrag()
				e.stopPropagation()
			}
		}
		
		protected function dontFollow(e:Event) :void {
			this.stopDrag()
		}
		
	}
}