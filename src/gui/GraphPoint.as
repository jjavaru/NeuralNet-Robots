package gui
{
	import flash.display.Graphics;
	import flash.display.Sprite;
	import flash.events.MouseEvent;

	public class GraphPoint extends Sprite
	{
		public var info:String;
		public var yVal:Number;
		public var xVal:Number;
		public var series:int;
		protected var graph:Graph;
		
		protected static var colors:Array = [0xFF0000,0x00FF00,0x0000FF,0xFFFF00,0xFF00FF];
		
		public function GraphPoint(gr:Graph,xv:Number,yv:Number,group:int = 0)
		{
			graph = gr
			xVal = xv
			yVal = yv
			series = group
			info = "Round " + xVal.toString() + ": " + toPPString(yVal,0)
			
			super();
			
			drawGraphPoint(colors[group])
			this.addEventListener(MouseEvent.MOUSE_OVER,showTooltip)
			this.addEventListener(MouseEvent.MOUSE_OUT,hideTooltip)
		}
		
		protected function drawGraphPoint(color:int) :void {
			var g:Graphics = this.graphics
			g.lineStyle(2,color)
			g.beginFill(0x556600)
			g.drawCircle(0,0,2)
			
		}
		
		protected function toPPString(yourNum :Number, precision :int = int.MAX_VALUE):String{
			var numtoString:String = new String();
			var strTemp:String = yourNum.toString();
			var strDecimal:String = new String();
		    var numLength:Number;
		    numtoString = "";
			
			var decPoint:Number = strTemp.lastIndexOf(".")
			if(decPoint != -1){
				strDecimal = strTemp.substr(decPoint,precision)
				strTemp = strTemp.substr(0,decPoint)
			}
			numLength = strTemp.length;
		    for (var i:Number=0; i<numLength; i++) { 
		        if ((numLength-i)%3 == 0 && i != 0) {
		                numtoString += ",";
		        }
		        numtoString += strTemp.charAt(i);
		    }
		    return numtoString+strDecimal;

		}
		
		protected function showTooltip(e:MouseEvent):void{
			graph.showTooltip(this);
		}
		
		protected function hideTooltip(e:MouseEvent):void{
			graph.hideTooltip();
		}
		
	}
}