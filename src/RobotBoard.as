package {
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Graphics;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.filters.DropShadowFilter;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	
	import gui.Button;
	import gui.DraggableSprite;
	import gui.Graph;
	import gui.ToggleButton;
	
	[Embed(source="C:/Windows/Fonts/Arial.TTF", fontFamily="Arial")]
	[SWF(width="700", height="600", frameRate="30", backgroundColor="#123456")]
	public class RobotBoard extends Sprite
	{
		[Embed(source="../Images/CheckUp.jpg")]
		public var imgCheckUp:Class;
		[Embed(source="../Images/CheckDown.jpg")]
		public var imgCheckDown:Class;
		[Embed(source="../Images/CheckOver.jpg")]
		public var imgCheckOver:Class;
		[Embed(source="../Images/CheckOverDown.jpg")]
		public var imgCheckOverDown:Class;
		
		protected var player:Robot
		protected var robots:Array = new Array()
		protected var plants:Array = new Array()
		protected var greenRobots:Array = new Array() // cache of robots with green light on
		protected var redRobots:Array = new Array() // cache of robots with red light on
		
		protected var right:Boolean
		protected var left:Boolean
		protected var txtFitness:TextField = new TextField()
		protected var txtTraining:TextField = new TextField()
		protected var frame:Number = 0
		public var round:Number = 0
		protected var currentScale:Number = 1.0
		protected var selectedRobot:Robot = null
		protected var displayRobot:Robot
		
		//Stats
		public var cached:Number = 0
		public var uncached:Number = 0
		
		//Options
		protected var supervised:Boolean = false
		protected var inCircle:Boolean = false
		protected var frameTimer:Number = 1200
		protected var popCount:Number = 100
		public var poison:Boolean = false
		protected var paused:Boolean = false
		public var hardWiredLights:Boolean = true
		
		//Button Images
		protected var bmdu_up   :BitmapData = new BitmapData(183, 40, true, 0xFFBDE052);
	    protected var bmdu_over :BitmapData = new BitmapData(183, 40, true, 0xFF52C4E0);
	    protected var bmdu_down :BitmapData = new BitmapData(183, 40, true, 0xFFffd700); //0xFFE052C4);
	    protected var bmdu_dis  :BitmapData = new BitmapData(183, 40, true, 0x99999999);
		
		protected var bmd_t_up   :BitmapData = new BitmapData(50, 16, true, 0xFFBDE052);
	    protected var bmd_t_over :BitmapData = new BitmapData(50, 16, true, 0xFF52C4E0);
	    protected var bmd_t_down :BitmapData = new BitmapData(50, 16, true, 0xFFE052C4);
	    protected var bmd_t_dis  :BitmapData = new BitmapData(50, 16, true, 0x99999999);
		
		//Buttons
		protected var btnUnsupervised:Button = new Button();
		protected var btnSupervised:Button;
		protected var btnTesting:Button = new ToggleButton();
		
		//Sprite layers
		protected var menuMC:Sprite = new Sprite();
		protected var mainMC:Sprite = new Sprite();
		protected var graph:Graph
		protected var detailsMC:Sprite = new DraggableSprite();
		protected var topMenuMC:Sprite = new Sprite();
		protected var netDisplayMC:Sprite = new Sprite();
		
		public function RobotBoard(){
			drawButtons()
			//begin()
		}
		
		//Draw the main menu 
		public function drawButtons():void {
			//Training... 
	        with(txtTraining){
				x = 350
				y = 350
				width = 0
				multiline = true
				mouseEnabled = false
				autoSize = TextFormatAlign.CENTER
				defaultTextFormat = new TextFormat("Arial",20,0xffffff)
				text = "Training..."
				
				background = true
				backgroundColor = 0xaaaaaa
				visible = false
			}
			
			var txtTitle:TextField = new TextField();
			with (txtTitle){
				x = 350
				y = 100
				width = 0
				defaultTextFormat = new TextFormat(null,36,0xff0000)
				autoSize = TextFormatAlign.CENTER
				multiline = false
				mouseEnabled = false
				visible = true
				text = "Neural Network Simulation"
			}
			
			var btnPoison:ToggleButton = new ToggleButton();
			with(btnPoison){
	        	x = 350
	        	y = 200
	        	up = (new imgCheckUp() as Bitmap).bitmapData
	        	over = (new imgCheckOver() as Bitmap).bitmapData
	        	down = (new imgCheckDown() as Bitmap).bitmapData
	        	overDown = (new imgCheckOverDown() as Bitmap).bitmapData
	        	//disabled = bmdu_dis
	  		}
	  		//Button.testing = true
	  		var txtPoison:TextField = new TextField(); 
			with(txtPoison){
	        	x = 165
	        	y = 200
	        	defaultTextFormat = new TextFormat(null,14)
				autoSize = TextFormatAlign.CENTER
				multiline = false
				mouseEnabled = false
				visible = true
	        	text = "Poison Plants"
	  		}
	        btnPoison.downFunction = function():void { poison = true; trace("downFun",poison); }
	        btnPoison.upFunction   = function():void { poison = false; trace("upFun",poison); }
			
			var btn50:ToggleButton = new ToggleButton();
			var btn100:ToggleButton
			with(btn50){
	        	x = 165
	        	y = 300
	        	down = bmdu_down
	        	over = bmdu_over;
	        	up = bmdu_up;
	        	disabled = bmdu_dis
	        	//text = "50"
	  		}
	  		btn100 = btn50.clone() as ToggleButton;
			with(btn100){
	        	x = 350
	        	y = 300
	        	text = "100"
	  		}
	  		btn50.radioSet  = [btn100]
	  		btn100.radioSet = [btn50]
	        btn50.downFunction = function():void { popCount = 50}
	        btn100.downFunction = function():void { popCount = 100}
	        btn100.changeToggle(true)
			
			with(btnUnsupervised){
	        	x = 165
	        	y = 400
	        	up = bmdu_up;
	        	over = bmdu_over;
	        	down = bmdu_down
	        	disabled = bmdu_dis
	        	text = "No training"
	  		}
	        btnUnsupervised.downFunction = function():void { supervised = false;}
	        
	        btnSupervised = btnUnsupervised.clone();
	        with(btnSupervised){
	        	x = 350
	        	y = 400
	        	enabled = false
	        	text = "Backpropagation training"
	        }
	        btnSupervised.downFunction = function():void { supervised = true; txtTraining.visible = true;}
	        
	        var btnBegin:Button = new Button()
	        with(btnBegin){
	        	x = 259 
	        	y = 500
	        	up = bmdu_up;
	        	over = bmdu_over;
	        	down = bmdu_down;
	        	disabled = bmdu_dis;
	        	text = "Begin"
	  		}
	        btnBegin.downFunction = function():void {begin();}
	        
			this.addChild(txtTraining)
			menuMC.addChild(txtTitle)
			menuMC.addChild(btn50)
			menuMC.addChild(btn100)
			menuMC.addChild(btnPoison)
			menuMC.addChild(txtPoison)
	        menuMC.addChild(btnSupervised)
	        menuMC.addChild(btnUnsupervised)
	        menuMC.addChild(btnBegin)
	        this.addChild(menuMC)
	        this.addChild(mainMC)
	        
		}
		
		protected function drawTopMenu() :void {
			var btnGraph:Button = new Button()
			with(btnGraph){
				x = 0
	        	y = 0
	        	up = bmd_t_up;
	        	over = bmd_t_over;
	        	down = bmd_t_down;
	        	disabled = bmd_t_dis;
	        	textFormat = new TextFormat(null,10)
	        	text = "Graph"
			}
			btnGraph.downFunction = function() :void { graph.visible = !graph.visible; };
			
			var btnInfo:Button = btnGraph.clone()
			with(btnInfo){
				x = 52
				y = 0
				text = "Info"
			}
			btnInfo.downFunction = function() :void { detailsMC.visible = !detailsMC.visible; };
			
			var btnPause:Button = btnGraph.clone()
			with(btnPause){
				x = 104
				y = 0
				text = "Pause"
			}
			btnPause.downFunction = function() :void { paused = !paused };
			
			var btnQuit:Button = btnGraph.clone()
			with(btnQuit){
				x = 156
				y = 0
				enabled = false
				text = "Quit"
			}
			btnQuit.downFunction = function() :void { mainMC.visible = false; menuMC.visible = true };
			
			this.addChild(topMenuMC)
			topMenuMC.addChild(btnGraph)
			topMenuMC.addChild(btnInfo)
			topMenuMC.addChild(btnPause)
			topMenuMC.addChild(btnQuit)
		}
		
		protected function drawInspectPane() :void {
			var g:Graphics = detailsMC.graphics;
			g.lineStyle(1,0x444444)
			g.beginFill(0xffffff,.5)
			g.drawRect(0,0,150,150)
			g.beginFill(0x444444,1)
			g.drawRect(5,5,140,140)
			detailsMC.filters = [new DropShadowFilter()]
			
			//label for reporting the overall fitness of the round
			detailsMC.addChild(txtFitness)
			with(txtFitness){
				x = 10
				y = 10
				width = 130
				multiline = true
				mouseEnabled = false
				defaultTextFormat = new TextFormat("Arial",16,0xffffff)
				wordWrap = true
			}
			
			displayRobot = new Robot(0,this,75,120,null,false,false,1.0,true)
			detailsMC.addChild(displayRobot)
			
			this.addChild(detailsMC)
			with(detailsMC){
				x = 500
				y = 350
				visible = false
			}
			
			with(netDisplayMC){
				x = 0
				y = 100
			}
			detailsMC.addChild(netDisplayMC)
		}
		
		public function begin():void{
			var i:Number
			
			this.menuMC.visible = false
			drawInspectPane()
			drawTopMenu()
			
			
			player = new Robot(0,this,350,250,null,true,false,3.0,true)
			this.addChild(player)
			this.stage.addEventListener(KeyboardEvent.KEY_DOWN,keyDown)
			this.stage.addEventListener(KeyboardEvent.KEY_UP,keyUp)
			
			for(i=0;i<15;i++){
				var pl:Plant = new Plant(this.poison && i%2==1)
				this.mainMC.addChild(pl)
				plants.push(pl)
			}
			
			for(i=0;i<popCount;i++){
				var n:Robot = new Robot(0,this,100+Math.random()*500,100+Math.random()*300,null,false,supervised)
				this.mainMC.addChild(n)
				robots.push(n)
			}
			txtTraining.visible = false
			//arrange robots in a circle
			if(this.inCircle){
				var dAngle:Number = 2*Math.PI/robots.length
				for(i=0;i<robots.length;i++){
					var angle:Number = i*dAngle
					robots[i].position(250-250*Math.cos(angle),250-250*Math.sin(angle),angle)
				}
			}
			
			graph = new Graph(true,"Round","Average Fitness")
			with (graph){
				x = 420;
				y = 200;
			}
			this.addChild(graph)
			
			this.addEventListener(Event.ENTER_FRAME,onFrame)
		}
		
		protected function cull() :void{
			var i:int
			
			for(i=0;i<robots.length;){
				if((robots[i] as Robot).isDestroyed){
					robots.splice(i,1);
				} else {
					i++
				}
			}
		}
		
		protected function onFrame(e:Event) :void{
			var i:Number
			var ro:Robot
			
			if(paused) return
			
			//start the new round
			if(frame > frameTimer){
				cull()
				if(robots.length > popCount) throw new Error("Population error: "+robots.length)
				var sum:Number = 0
				for(var c:Number=0;c<robots.length;c++){
					sum += robots[c].score
				}
				sum /= robots.length
				this.round++
				graph.addPoint(sum)
				//sort robots and get rid of poor ones 
				robots.sortOn("score",Array.DESCENDING | Array.NUMERIC)
				for(var j:Number=popCount/2;j<robots.length;j++){
					this.mainMC.removeChild(robots[j])
				}
				robots.splice(popCount/2,popCount/2)
				//create child robots
				txtTraining.visible = true
				for(var k:Number=0; k<popCount/2;k++){
					robots[k].reset()
					var newRobot:Robot = robots[k].mate(robots[Math.floor(popCount/4*Math.random())],currentScale)
					this.mainMC.addChild(newRobot)
					robots.push(newRobot)
				}
				txtTraining.visible = false
				//arrange robots in a circle
				if(this.inCircle){
					var dAngle:Number = 2*Math.PI/robots.length
					for(i=0;i<robots.length;i++){
						var angle:Number = i*dAngle
						robots[i].position(250-250*Math.cos(angle),250-250*Math.sin(angle),angle)
					}
				}
				frame = 0
			}
			if(false && frame > 200){
				var sum2:Number = 0
				for each(ro in robots){
					sum2 += ro.score
				}
				sum2 /= robots.length
				this.round++
				graph.addPoint(sum2)
				frame = 0
			}
			frame++
			
			//move player
			//player.move(Math.random()<.5,Math.random()<.5) 
			player.move(right,left)
			for each (ro in robots){
				if(!ro.isDestroyed && toroidalDistance(player,ro) < 30){
					//create new robot child to replace 
					var buddingRobot:Robot = topRobot().mate(robots[Math.floor(popCount/4*Math.random())],currentScale)
					this.mainMC.addChild(buddingRobot)
					robots.push(buddingRobot)
					//selectedRobot = buddingRobot
					//remove eaten robot
					ro.destroy()
				}
			}
			
			//Create cache of which robots have lights on
			greenRobots = new Array();
			redRobots = new Array();
			for each (ro in robots){
				if(ro.greenOn && !ro.isDestroyed){
					greenRobots.push(ro)
				}
				if(ro.redOn && !ro.isDestroyed){
					redRobots.push(ro)
				}
			}
			
			//Move all robots
			for each(ro in robots){
				if(!ro.isDestroyed) ro.input(inRange(ro))
			}
			
			if(selectedRobot){
				txtFitness.text = "Robot " + selectedRobot.id + "\nGeneration " + selectedRobot.generation+ "\nScore: " + selectedRobot.score// + "\n" + selectedRobot.cachedInput.toString()
				displayRobot.greenOn = selectedRobot.greenOn
				displayRobot.redOn = selectedRobot.redOn
				displayRobot.rotation = selectedRobot.rotation
				drawNetDisplay(selectedRobot.cachedInput)
			}
			
			//Cached vs Uncached readout
			//txtFitness.text = cached.toString() + ":" + uncached.toString()
		}
		
		protected function topRobot() :Robot {
			var topScore:Number = Number.MIN_VALUE
			var returnRobot:Robot
			
			for each (var ro:Robot in robots){
				if(ro.score > topScore && !ro.isDestroyed){
					topScore = ro.score
					returnRobot = ro
				}
			}
			
			returnRobot.score/=2
			return returnRobot
		}
		
		protected function drawNetDisplay( arr :Array) :void {
			var dx:Number = this.detailsMC.width / arr.length
			
			var g:Graphics = netDisplayMC.graphics
			g.clear()
			g.lineStyle(1,0x000000)
			for(var i:Number = 0;i<arr.length;i++){
				g.beginFill(arr[i] > 0 ? 0x009900 : 0x990000)
				g.drawCircle(i*dx + 10,0,5)
			}
			g.endFill()
		}
		
		protected function inRange(ro:Robot,output:Boolean = false):Array{
			var greenRobotNbrs:Array = [-1,-1,-1]
			var redRobotNbrs:Array = poison ? [-1,-1,-1] : []
			var plantNbrs:Array = [-1,-1,-1]
			var poisonNbrs:Array = poison ? [-1,-1,-1] : []
			var predatorNbrs:Array = poison ? [] : [-1,-1,-1,-1]
			ro.greenOn = false
			ro.redOn = false
			
			for each(var robotNbr:Sprite in greenRobots){
				greenRobotNbrs = distance(ro,robotNbr,greenRobotNbrs,robotPoints,340)
			}
			if(poison){
				for each(robotNbr in redRobots){
					redRobotNbrs = distance(ro,robotNbr,redRobotNbrs,robotPoints,340)
				}
			}
			if(!poison){
				predatorNbrs = distance4way(ro,player,predatorNbrs,predatorPoints,150)
			}
			
			for each(var plant:Plant in plants){
				if(plant.poison){
					poisonNbrs = distance(ro,plant,poisonNbrs,poisonPoints)
				} else {
					plantNbrs = distance(ro,plant,plantNbrs,plantPoints)
				}
			}
			
			var tempArr:Array = plantNbrs.concat(poisonNbrs,greenRobotNbrs,redRobotNbrs,predatorNbrs)
			if(tempArr.length > 10){
				trace("problem?")
			}
			return plantNbrs.concat(poisonNbrs,greenRobotNbrs,redRobotNbrs,predatorNbrs)
		}
		
		protected function toroidalDistance(s1:Sprite, s2:Sprite) :Number{
			// Calculate distance to object
			var diffX :int = (s1.x>s2.x ? s1.x-s2.x : s2.x-s1.x);
			var diffY :int = (s1.y>s2.y ? s1.y-s2.y : s2.y-s1.y);
			//toroidal distance
			if(diffX > 350) diffX = 700 - diffX
			if(diffY > 300) diffY = 600 - diffY 
			return Math.round(Math.sqrt((diffX * diffX) + (diffY * diffY)));
		}
		
		protected function distance(ro:Robot, sp:Sprite, ret:Array, points:Function,maxDist :Number = 35):Array{
			
			var diffX :int = ro.x - sp.x;
			var diffY :int = ro.y - sp.y;
			var dist :int = toroidalDistance(ro,sp)
			
			if (dist <= maxDist)
			{
				var twoPi:Number = 2*Math.PI
				var angle:Number = ((Math.atan2(-diffY,-diffX)-ro.angle) +twoPi+ twoPi) % twoPi
				var bucket:int = ((angle+ Math.PI/8) / (Math.PI/4)) %8
				switch(bucket){
					case 0:
						bucket = 0
						break
					case 1:
					case 2:
					case 3:
					case 4:
						bucket = 1
						break;
					case 5:
					case 6:
					case 7:
						bucket = 2
						break;
					default:
						trace("assert error")
				}
				ret[bucket] = 1
				points(bucket,ro,angle,dist)
			}
			
			return ret
		}
		
		protected function distance4way(ro:Robot, sp:Sprite, ret:Array, points:Function,maxDist :Number = 35):Array{
			
			var diffX :int = ro.x - sp.x;
			var diffY :int = ro.y - sp.y;
			var dist :int = toroidalDistance(ro,sp)
			
			if (dist <= maxDist)
			{
				var twoPi:Number = 2*Math.PI
				var angle:Number = ((Math.atan2(-diffY,-diffX)-ro.angle) +twoPi+ twoPi) % twoPi
				var bucket:int = (angle / (Math.PI/4)) %8
				switch(bucket){
					case 0:
					case 7:
						bucket = 0
						break
					case 1:
					case 2:
						bucket = 1
						break;
					case 3:
					case 4:
						bucket = 2
						break;
					case 5:
					case 6:
						bucket = 3
						break;
					default:
						throw new Error("Bucket error")
						trace("assert error")
				}
				ret[bucket] = 1
				points(bucket,ro,angle,dist)
			}
			
			return ret
		}
		
		protected function robotPoints(bucket:int,ro:Robot,angle:Number,dist:Number):void{
			if( bucket == 1 ) ro.score+= 80
		}
		
		protected function predatorPoints(bucket:int,ro:Robot,angle:Number, dist:Number) :void{
			
			if(hardWiredLights) ro.redOn = true
		}
		
		//reward points to the robots based on behavior near plants
		protected function plantPoints(bucket:int,ro:Robot,angle:Number,dist:Number):void{
			var reward:Number = 0
			switch(bucket){
				case 0:
					//ro.drawDir(angle,dist)
					reward +=20000
					break
				case 1:
				case 2:
					reward +=300
					break
			}
			
			if(!ro.lmotor && !ro.rmotor){
				reward *= 50
			}
			
			if(hardWiredLights) ro.greenOn = true
			ro.score += reward
		}
		
		protected function poisonPoints(bucket:int,ro:Robot,angle:Number,dist:Number):void{
			var reward:Number = 0
			switch(bucket){
				case 0:
					reward -=2000
					break
				case 1:
				case 2:
					reward -=30
					break
			}
			
			if(!ro.lmotor && !ro.rmotor){
				reward *= 50
			}
			
			if(hardWiredLights) ro.redOn = true
			ro.score += reward
		}
		
		/*---------------------------------------------------------------------------------------------------*/
		/*  User Input   							                                      	                */
		/*-------------------------------------------------------------------------------------------------*/
		protected function keyDown(e:KeyboardEvent):void{
			//trace(e.keyCode.toString(),String.fromCharCode(e.charCode))
			switch (e.keyCode) {
				
				case 37 : //left
					left = true
					break
				case 38 : //up
				case 87 : //w
					right = true
					left = true
					break;
				case 39 : //right
					right = true
					break
				case 40 : //down
				case 83 : //s
					break;
			}
		}
		
		protected function keyUp(e:KeyboardEvent):void {
			//trace(e.keyCode.toString(),String.fromCharCode(e.charCode))
			switch (e.keyCode) {
				
				case 37 : //left
					left = false
					break
				case 38 : //up
				case 87 : //w
					right = false
					left = false
					break;
				case 39 : //right
					right = false
					break
				case 40 : //down
				case 83 : //s
					break;
			}
		}
		
		//handle clicking on a robot
		public function robotSelect(ro :Robot) :void{
			if(selectedRobot){
				selectedRobot.rangeOn = false
			}
			txtFitness.text = ro.score.toString()
			selectedRobot = ro
			detailsMC.visible = true
			selectedRobot.rangeOn = true
		}
	}
}
