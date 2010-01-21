package gui
{
	import flash.display.Graphics;
	import flash.display.Sprite;
	import flash.events.MouseEvent;

	public class GraphPoint extends Sprite
	{
		public var info:String;
		public var yVar:Number;
		public var xVar:Number;
		protected var graph:Graph;
		
		public function GraphPoint(gr:Graph,xv:Number,yv:Number)
		{
			graph = gr
			xVar = xv
			yVar = yv
			info = "Round " + xVar.toString() + ": " + toPPString(yVar)
			
			super();
			var g:Graphics = this.graphics
			g.lineStyle(2,0xFFFFFF)
			g.beginFill(0x556600)
			g.drawCircle(0,0,2)
			
			this.addEventListener(MouseEvent.MOUSE_OVER,showTooltip)
			this.addEventListener(MouseEvent.MOUSE_OUT,hideTooltip)
		}
		
		protected function toPPString(yourNum :Number):String{
			var numtoString:String = new String();
			var strTemp:String = yourNum.toString();
			var strDecimal:String = new String();
		    var numLength:Number;
		    numtoString = "";
			
			var decPoint:Number = strTemp.lastIndexOf(".")
			if(decPoint != -1){
				strDecimal = strTemp.substr(decPoint)
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