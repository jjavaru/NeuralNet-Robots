package {
	import Robots.BaseRobot;
	import Robots.NNRobot;
	
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.net.SharedObject;
	
	[Embed(source="C:/Windows/Fonts/Arial.TTF", fontFamily="Arial")]
	[SWF(width="700", height="600", frameRate="30", backgroundColor="#123456")]
	public class RobotBoard extends Sprite
	{
		
		protected var player:BaseRobot
		protected var robots:Array = new Array()
		protected var plants:Array = new Array()
		protected var greenRobots:Array = new Array() // cache of robots with green light on
		protected var redRobots:Array = new Array() // cache of robots with red light on
		
		protected var right:Boolean
		protected var left:Boolean
		protected var frame:Number = 0
		public var round:Number = 0
		protected var currentScale:Number = 1.0
		protected var selectedRobot:NNRobot = null
		
		//Stats
		public var cached:Number = 0
		public var uncached:Number = 0
		
		//Options
		public var supervised:Boolean = false
		public var inCircle:Boolean = false
		public var frameTimer:Number = 800
		public var popCount:Number = 100
		public var poison:Boolean = false
		public var paused:Boolean = false
		public var hardWiredLights:Boolean = true
		public var predatorActive:Boolean = false
		
		//Sprite layers
		public var mainMC:Sprite = new Sprite();
		protected var UILayer:BoardUI
		
		public function RobotBoard(){
			drawButtons()
		}
		
		//Draw the main menu 
		public function drawButtons():void {
			UILayer = new BoardUI(this);
			UILayer.drawMainMenu()
	        this.addChild(mainMC)
			this.addChild(UILayer)
		}
		
		public function begin():void{
			var i:Number
			
			UILayer.drawUI()
			load()
			
			if(predatorActive){
				player = new BaseRobot(0,this,350,250,false,3.0)
				this.addChild(player)
				this.stage.addEventListener(KeyboardEvent.KEY_DOWN,keyDown)
				this.stage.addEventListener(KeyboardEvent.KEY_UP,keyUp)
			}
			
			for(i=0;i<15;i++){
				var pl:Plant = new Plant(this.poison && i%2==1)
				this.mainMC.addChild(pl)
				plants.push(pl)
			}
			
			for(i=0;i<popCount;i++){
				var n:NNRobot = new NNRobot(this,0,null,supervised);
				this.mainMC.addChild(n);
				robots.push(n);
			}
			//arrange robots in a circle
			if(this.inCircle){
				var dAngle:Number = 2*Math.PI/robots.length
				for(i=0;i<robots.length;i++){
					var angle:Number = i*dAngle
					robots[i].position(250-250*Math.cos(angle),250-250*Math.sin(angle),angle)
				}
			}
			
			this.addEventListener(Event.ENTER_FRAME,onFrame)
		}
		
		protected function removeDestroyedRobots() :void{
			var i:int
			
			for(i=0;i<robots.length;){
				if((robots[i] as BaseRobot).isDestroyed){
					robots.splice(i,1);
				} else {
					i++
				}
			}
		}
		
		protected function startNewRound() :void {
			var i:Number
			var robot:BaseRobot
			
			removeDestroyedRobots()
			if(robots.length > popCount) throw new Error("Population error: "+robots.length)
			
			//collect statistics and update graph
			var sum:Number = 0
			var max:Number = Number.MIN_VALUE
			for each(var ro:BaseRobot in robots){
				sum += ro.score
				if(ro.score > max) max = ro.score;
			}
			sum /= robots.length
			UILayer.graph.addPoint(round,sum,0)
			UILayer.graph.addPoint(round,max,1)
			this.round++
			
			//sort robots and get rid of poor ones 
			robots.sortOn("score",Array.DESCENDING | Array.NUMERIC)
			for(var j:Number=popCount/2;j<robots.length;j++){
				this.mainMC.removeChild(robots[j])
			}
			robots.splice(popCount/2,popCount/2)
			
			//create child robots
			UILayer.txtTraining.visible = true
			for(var k:Number=0; k<popCount/2;k++){
				robots[k].initialPosition()
				var newRobot:NNRobot = robots[k].mate(robots[Math.floor(popCount/4*Math.random())],currentScale)
				this.mainMC.addChild(newRobot)
				robots.push(newRobot)
			}
			UILayer.txtTraining.visible = false
			
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
		
		protected function onFrame(e:Event) :void{
			var i:Number
			var ro:BaseRobot
			
			if(paused) return
			
			if(frame > frameTimer){
				startNewRound()
			}
			frame++
			
			//move player
			if(predatorActive){
				//player.move(Math.random()<.5,Math.random()<.5) 
				player.move(right,left)
				for each (ro in robots){
					if(!ro.isDestroyed && toroidalDistance(player,ro) < 30){
						//create new robot child to replace 
						var buddingRobot:NNRobot = topRobot().mate(robots[Math.floor(popCount/4*Math.random())],currentScale)
						this.mainMC.addChild(buddingRobot)
						robots.push(buddingRobot)
						//remove eaten robot
						ro.destroy()
					}
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
				UILayer.updateDisplayRobot(selectedRobot)
			}
			
		}
		
		protected function topRobot() :NNRobot {
			var topScore:Number = Number.MIN_VALUE
			var returnRobot:NNRobot
			
			for each (var ro:NNRobot in robots){
				if(ro.score > topScore && !ro.isDestroyed){
					topScore = ro.score
					returnRobot = ro
				}
			}
			
			if(returnRobot == null){
				throw Error("FFFFFFFUUUUUUUUUUUUU")	
			} 
			returnRobot.score/=2
			return returnRobot
		}
		
		protected function inRange(ro:BaseRobot,output:Boolean = false):Array{
			var greenRobotNbrs:Array = [-1,-1,-1]
			var redRobotNbrs:Array = poison ? [-1,-1,-1] : []
			var plantNbrs:Array = [-1,-1,-1]
			var poisonNbrs:Array = poison ? [-1,-1,-1] : []
			var predatorNbrs:Array = predatorActive ? [-1,-1,-1,-1] : []
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
			if(predatorActive){
				predatorNbrs = distance4way(ro,player,predatorNbrs,predatorPoints,150)
			}
			
			for each(var plant:Plant in plants){
				if(plant.poison){
					poisonNbrs = distance(ro,plant,poisonNbrs,poisonPoints)
				} else {
					plantNbrs = distance(ro,plant,plantNbrs,plantPoints)
				}
			}
			
			var allNbrs:Array = plantNbrs.concat(poisonNbrs,greenRobotNbrs,redRobotNbrs,predatorNbrs)
			
			return allNbrs
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
		
		protected function distance(ro:BaseRobot, sp:Sprite, ret:Array, points:Function,maxDist :Number = 35):Array{
			
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
		
		protected function distance4way(ro:BaseRobot, sp:Sprite, ret:Array, points:Function,maxDist :Number = 35):Array{
			
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
		
		protected function robotPoints(bucket:int,ro:BaseRobot,angle:Number,dist:Number):void{
			if( bucket == 1 ) ro.score+= 80
		}
		
		protected function predatorPoints(bucket:int,ro:BaseRobot,angle:Number, dist:Number) :void{
			
			if(hardWiredLights) ro.redOn = true
		}
		
		//reward points to the robots based on behavior near plants
		protected function plantPoints(bucket:int,ro:BaseRobot,angle:Number,dist:Number):void{
			var reward:Number = 0
			switch(bucket){
				case 0:
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
		
		protected function poisonPoints(bucket:int,ro:BaseRobot,angle:Number,dist:Number):void{
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
		/*  File I/O    							                                      	                */
		/*-------------------------------------------------------------------------------------------------*/
		public function save():void {
			var so:SharedObject = SharedObject.getLocal("robotsGraph")
			UILayer.graph.save(so)
			so.flush()
			so.close()
		}
		
		protected function load():void {
			var so:SharedObject = SharedObject.getLocal("robotsGraph")
			//so.clear()
			UILayer.graph.load(so)
			so.close()
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
		public function robotSelect(ro :NNRobot) :void{
			if(selectedRobot){
				selectedRobot.rangeOn = false
			}
			UILayer.robotSelect(ro);
			selectedRobot = ro
			selectedRobot.rangeOn = true
		}
		
	}
}
