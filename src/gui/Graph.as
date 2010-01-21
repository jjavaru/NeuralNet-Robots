package gui
{
	import flash.display.Graphics;
	import flash.display.Sprite;
	import flash.filters.DropShadowFilter;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	
	
	public class Graph extends DraggableSprite
	{
		public var graphHeight:Number = 200
		public var graphWidth:Number = 200
		
		public var timeSeries:Boolean = true
		protected var nextPoint:int = 0
		protected var yRange:Number
		protected var xRange:Number
		protected var points:Array = new Array();
		protected var yVals:Array = new Array();
		
		//visual objects
		protected var pointsMC:Sprite = new Sprite();
		protected var txtTooltip:TextField = new TextField();
		
		public function Graph(series:Boolean = true, xlabel:String = "", ylabel:String = "") :void{
			this.timeSeries = series
			this.drawPlot(xlabel,ylabel)
			this.addChild(pointsMC)
			super();
		}
		
		protected function drawPlot(xstr:String, ystr:String) :void{
			var g:Graphics = this.graphics
			g.beginFill(0x000000,.4)
			g.drawRect(-20,-2,graphWidth+24,graphHeight+24)
			g.endFill()
			g.moveTo(0,0)
			g.lineStyle(2,0xFFFFFF)
			g.lineTo(0,graphHeight)
			g.lineTo(graphWidth,graphHeight)
			
			//graph lables
			if(xstr != ""){
				var txtXLabel:TextField = new TextField()
	          	with(txtXLabel){
					x = this.graphWidth/2
					y = this.graphHeight+2
					width = 0
					height = 0
					defaultTextFormat = new TextFormat("Arial",null,0xFFFFFF);
					multiline = false
					mouseEnabled = false
					autoSize = TextFormatAlign.CENTER
					background = true
					backgroundColor = 0xaaaaaa
					border = false
					visible = true
					text = xstr
	          	}
				addChild(txtXLabel)
			}
			if(ystr != ""){
				var txtYLabel:TextField = new TextField()
	          	with(txtYLabel){
					x = -20
					y = this.graphHeight/2
					width = 0
					height = 0
					embedFonts = true
					defaultTextFormat = new TextFormat("Arial",null,0xFFFFFF);
					multiline = false
					mouseEnabled = false
					autoSize = TextFormatAlign.CENTER
					background = true
					backgroundColor = 0xaaaaaa
					border = false
					visible = true
					rotation = 270
					text = ystr
	          	}
				addChild(txtYLabel)
			}
			
			//mouse-over tooltips
          	with(txtTooltip){
				x = 0
				y = 0
				width = 0
				height = 100
				defaultTextFormat = new TextFormat("Arial",null,0xFFFFFF);
				multiline = true
				mouseEnabled = false
				autoSize = TextFormatAlign.RIGHT
				background = true
				backgroundColor = 0xaaaaaa
				border = true
				borderColor = 0x000000
				visible = false
          	}
			addChild(txtTooltip)
			this.filters = [new DropShadowFilter()]
		}
		
		//
		public function addPoint(yval:Number,xval:Number = -1) :void {
			
			if(xval == -1){
				if(nextPoint == 0){
					yRange = yval * 2
					xRange = 15
				}
				if(yval > yRange || nextPoint > xRange){
					if(yval > yRange) yRange = yval*1.2
					if(nextPoint > xRange) xRange += 15
					this.replot()
				}
				yVals.push(yval)
				var gp:GraphPoint = new GraphPoint(this,nextPoint+1,yval)
				var ypos:Number = graphHeight*(1 - (yval/yRange));
				var xpos:Number = nextPoint * (graphWidth/xRange)
				with(gp){
					x = xpos
					y = ypos
				}
				points.push(gp)
				this.addChild(gp)
				trace(xpos,ypos)
				nextPoint++
			} else {
				trace("Not implemented")
			}
		}
		
		protected function replot() :void {
			for(var i:Number = 0;i<points.length;i++){
				var ypos:Number = graphHeight*(1 - (yVals[i]/yRange));
				var xpos:Number = i * (graphWidth/xRange)
				var gr:GraphPoint = (points[i] as GraphPoint)
				with(gr){
					x = xpos
					y = ypos
				}
			}	
			
		}
		
		public function showTooltip(gr :GraphPoint):void{
			with(txtTooltip){
				x = gr.x
				y = gr.y+25
				text = gr.info
				visible = true
			}
		}
		
		public function hideTooltip():void{
			txtTooltip.visible = false
		}
		

	}
}