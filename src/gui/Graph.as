package gui
{
	import flash.display.Bitmap;
	import flash.display.Graphics;
	import flash.display.Sprite;
	import flash.filters.DropShadowFilter;
	import flash.net.SharedObject;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	
	
	public class Graph extends DraggableSprite
	{
		[Embed(source="../Images/CheckUp.jpg")]
		public var imgCheckUp:Class;
		[Embed(source="../Images/CheckDown.jpg")]
		public var imgCheckDown:Class;
		[Embed(source="../Images/CheckOver.jpg")]
		public var imgCheckOver:Class;
		[Embed(source="../Images/CheckOverDown.jpg")]
		public var imgCheckOverDown:Class;
		
		public var graphHeight:Number = 200
		public var graphWidth:Number = 200
		
		public var timeSeries:Boolean = true
		protected var nextPoint:int = 0
		protected var yRange:Number = 0
		protected var xRange:Number = 0
		protected var points:Array = new Array();
		protected var seriesVisible:Array = new Array();
		
		//visual objects
		protected var pointsMC:Sprite = new Sprite();
		protected var txtTooltip:TextField = new TextField();
		
		public function Graph(series:Boolean = true, xlabel:String = "", ylabel:String = "") :void{
			this.timeSeries = series
			this.drawPlot(xlabel,ylabel)
			this.addChild(pointsMC)
			super(true);
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
				
				var key:Sprite = new DraggableSprite()
				addChild(key)
				var btnOne:ToggleButton = new ToggleButton()
				key.addChild(btnOne)
				with(btnOne){
		        	x = 0
		        	y = 0
		        	up = (new imgCheckUp() as Bitmap).bitmapData
		        	over = (new imgCheckOver() as Bitmap).bitmapData
		        	down = (new imgCheckDown() as Bitmap).bitmapData
		        	overDown = (new imgCheckOverDown() as Bitmap).bitmapData
		        	//disabled = bmdu_dis
		  		}
		        btnOne.downFunction = function():void { setSeriesVisible(1, true); trace("downFun",seriesVisible[0]); }
		        btnOne.upFunction   = function():void { setSeriesVisible(1, false); trace("upFun",seriesVisible[0]); }
				
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
		public function addPoint(xval:Number, yval:Number, series:int = 0) :void {
			
			var gp2:GraphPoint = new GraphPoint(this,xval,yval,series)
			points.push(gp2)
			this.addChild(gp2)
			if(seriesVisible[series] == null) seriesVisible[series] = true
			replot()
			return
			
			
			
			if(yRange == 0){
				yRange = yval * 2
				xRange = 15
			}
			if(yval > yRange || xval > xRange){
				if(yval > yRange) yRange = yval*1.2
				if(xval > xRange) xRange += 15
				this.replot()
			}
			var gp2:GraphPoint = new GraphPoint(this,xval,yval,series)
			var ypos2:Number = graphHeight*(1 - (yval/yRange));
			var xpos2:Number = xval * (graphWidth/xRange)
			with(gp2){
				x = xpos2
				y = ypos2
			}
			trace(xval,yval,xpos2,ypos2)
			points.push(gp2)
			this.addChild(gp2)
		}
		
		protected function replot() :void {
			var maxX:Number = Number.MIN_VALUE
			var maxY:Number = Number.MIN_VALUE
			var gp:GraphPoint
			
			for each(gp in points){
				if(seriesVisible[gp.series]){
					if(gp.xVal > maxX) maxX = gp.xVal
					if(gp.yVal > maxY) maxY = gp.yVal
				}
			}
			
			xRange = maxX * 1.05
			yRange = maxY * 1.05
			
			for each(gp in points){
				if(seriesVisible[gp.series]){
					var xpos:Number = gp.xVal * (graphWidth/xRange)
					var ypos:Number = graphHeight*(1 - (gp.yVal/yRange));
					with(gp){
						x = xpos
						y = ypos
					}
				}
				gp.visible = seriesVisible[gp.series];
			}	
		}
		
		public function setSeriesVisible(series:int, visible:Boolean = false) :void {
			seriesVisible[series] = visible
			replot()
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
		
		public function save(so:SharedObject) :void {
			var rows:Number = so.data.rows
			var graphData:Array
			
			if(isNaN(rows)){
				rows = 1;
				graphData = new Array()
			} else {
				rows++;
				graphData = so.data.graphData
			}
			graphData.push(points.filter(isMax));
			
			so.data.graphData = graphData;
			so.data.rows = rows;
		}
		private function isMax(element:*, index:int, arr:Array):Boolean {
            return (element.series == 0);
        }

		
		public function load(so:SharedObject) :void {
			var rows:Number = so.data.rows
			var graphData:Array
			
			if(isNaN(rows)) return
			
			graphData = so.data.graphData
			
			for(var i:int = 0;i<rows;i++){
				for each(var gp:* in graphData[i]){
					addPoint(gp.xVal,gp.yVal,i+2)
				}
			}
		}
		

	}
}