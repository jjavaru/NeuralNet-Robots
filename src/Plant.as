package
{
	import flash.display.Graphics;
	import flash.display.Sprite;
	
	public class Plant extends Sprite
	{
		protected var mod:Number;
		public var poison:Boolean;
		
		/*---------------------------------------------------------------------------------------------------*/
		/*  CONSTRUCTOR							                                         	   CONSTRUCTOR  */
		/*-------------------------------------------------------------------------------------------------*/
		public function Plant(poisonPlant:Boolean = false)
		{
			this.poison = poisonPlant
			this.mod = (poison ? -1 : 1)
			var g:Graphics = this.graphics
			g.beginFill(poison ? 0x990000 : 0x009900)
			g.drawCircle(0,0,7)
			g.endFill()
			reset(poison)
		}
		
		/*---------------------------------------------------------------------------------------------------*/
		/*  PUBLIC FUNCTIONS							                               	  PUBLIC FUNCTIONS  */
		/*-------------------------------------------------------------------------------------------------*/
		/**
	 	*	Set the location of the plant
	 	*/
		public function reset(poison:Boolean):void{
			if(poison){
				this.x = 250 + Math.random()*200
				this.y = 400 + Math.random()*100
			} else {
				this.x = 200 + Math.random()*200
				this.y = 200 + Math.random()*100
			}
			
			
		}

	}
}