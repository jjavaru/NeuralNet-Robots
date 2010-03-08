package
{
	import Decision_Systems.*;
	
	import flash.display.Graphics;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.filters.BlurFilter;
	import flash.filters.GlowFilter;
	
	public class Robot extends Sprite
	{
		protected static var nextID:Number = 0
		protected var board:RobotBoard
		public var id:Number
		public var generation:Number
		public var isDestroyed:Boolean = false
		
		//dimensions
		protected var _width:Number = 12
		protected var _height:Number = 12
		protected var _moveStep:Number = 4.7
		protected var _x:Number
		protected var _y:Number
		protected var _angle:Number = Math.random() * 2 * Math.PI
		protected var _debug:Boolean = false
		public var score:Number = 0
		public var rmotor:Boolean = false
		public var lmotor:Boolean = false
		
		//Sprite layers
		protected var greenMC:Sprite = new Sprite()
		protected var redMC:Sprite = new Sprite()
		protected var rangeMC:Sprite = new Sprite()
		
		//Neural Net related
		protected var net:NeuralNet;
		protected var TrainingInput:Array
		protected var TrainingOutput:Array
		protected var useBackprop:Boolean = false
		public var cachedInput:Array = new Array()
		protected var cachedOutput:Array;
		
		public function Robot(gen:Number,game:RobotBoard,xpos:Number,ypos:Number,mateNet:NeuralNet = null, range:Boolean = false, training :Boolean = false, scale :Number = 1.0, displayOnly :Boolean = false)
		{
			id = nextID++
			generation = gen
			board = game
			x = xpos
			y = ypos
			_x = x
			_y = y
			useBackprop = training
			this._height *= scale
			this._width *= scale
			this._moveStep *= scale
			//if(_moveStep > 4.7) _moveStep = 2.7
			
			if(mateNet == null && !displayOnly) {
				if(this.board.poison){
					if(this.board.hardWiredLights){
						net = new NeuralNet(15,12,4)
					} else {
						net = new NeuralNet(15,12,6)
					}
				} else {
					if(this.board.hardWiredLights){
						net = new NeuralNet(13,8,4)
					} else {
						net = new NeuralNet(13,8,5)
					}
				}
			} else {
				net = mateNet
			}

			if(useBackprop && mateNet == null){
				trainNeuralNet()
			}
			
			drawRobot()
			if(!displayOnly){
				this.addEventListener(MouseEvent.CLICK,selected)
				initialPosition()
			}
			greenOn = false
			redOn = false
		}
		
		protected function trainNeuralNet() :void {
			TrainingInput =  [[-1,-1,-1,-1,-1,-1,-1,-1,1],
							  [1,-1,-1,1,-1,-1,-1,-1,1],
							  [-1,-1,-1,1,-1,-1,-1,-1,1],
							  [-1,-1,-1,-1,1,-1,-1,-1,1],
							  [-1,-1,-1,-1,-1,1,-1,-1,1],
							  [-1,-1,-1,-1,-1,-1,1,1,1],
							  [1,-1,-1,-1,-1,-1,-1,-1,1],
							  [-1,1,-1,-1,-1,-1,-1,-1,1],
							  [-1,-1,1,-1,-1,-1,-1,-1,1]]
							 			
			TrainingOutput = [[0,0,0,1,0],
							  [1,0,0,0,0],
							  [1,0,0,0,1],
							  [0,1,0,0,1],
							  [0,0,1,0,1],
							  [0,0,0,1,0],
							  [0,0,0,1,0],
							  [0,1,0,0,0],
							  [0,0,1,0,0]]
							  
			for(var i:Number = 0;i<100;i++){
				var error:Number = 0
				for(var j:Number = 0;j<TrainingInput.length;j++){
					error += net.backProp(TrainingOutput[j],TrainingInput[j])
				}
				if(_debug) trace(i,error)
			}
		}
		
		public function destroy() :void {
			this.visible = false
			this.isDestroyed = true
		}
		
		protected function selected(e :MouseEvent) :void {
			//this.board.robotSelect(this)
		}
		
		public function mate(ro:Robot, scale:Number = 1.0):Robot{
			
			return new Robot(this.board.round,board,100+Math.random()*500,100+Math.random()*300,net.mate(ro.net),false,false,scale)
		}
		
		public function position(nx:Number,ny:Number,na:Number):void {
			this.score = 0
			this.x = nx
			this.y = ny
			this._x = x
			this._y = y
			this._angle = na
			this.rotation = 180*(this._angle/Math.PI)
		}
		
		public function initialPosition():void{
			this.position(	Math.random()*50 + [0,650][Math.floor(2*Math.random())],
							Math.random()*50 + [0,550][Math.floor(2*Math.random())],
							Math.random() * 2 * Math.PI )
		}
		
		/*---------------------------------------------------------------------------------------------------*/
		/*  GETTER/SETTERS							                                      	GETTER/SETTERS  */
		/*-------------------------------------------------------------------------------------------------*/
		public function get greenOn():Boolean{
			return this.greenMC.visible
		}
		
		public function set greenOn(b:Boolean):void{
			this.greenMC.visible = b
		}
		
		public function get redOn():Boolean{
			return this.redMC.visible
		}
		
		public function set redOn(b:Boolean):void{
			this.redMC.visible = b
		}
		
		public function set debug(b:Boolean):void{
			this.net.debug = b
		}
		
		public function get angle():Number{
			if(_debug) trace("angle",_angle,(this._angle % (2*Math.PI)))
			return (this._angle % (2*Math.PI))
		}
		
		public function set rangeOn(b:Boolean):void{
			this.rangeMC.visible = b
		}
		
		public function get rangeOn():Boolean{
			return this.rangeMC.visible
		}
		
		/*---------------------------------------------------------------------------------------------------*/
		/*  PUBLIC FUNCTIONS							                               	  PUBLIC FUNCTIONS  */
		/*-------------------------------------------------------------------------------------------------*/
		/**
	 	*	Handle input to this robot
	 	*/
		public function input(neighbors:Array):void{
			var sw:int;
			var decision:Array;
			
			neighbors.push(lmotor?1:-1)
			neighbors.push(rmotor?1:-1)
			neighbors.push(1)
			var equal:Boolean = true
			for(var i:Number = 0;i<neighbors.length-1;i++){
				if(neighbors[i] != cachedInput[i]){
					equal = false;
					break;
				}
			}
			
			if(equal){
				decision = cachedOutput;
				sw = maxIndex(decision,0,4);
				this.board.cached++;
			} else {
				cachedInput = neighbors
				decision = net.decide(neighbors)
				sw = maxIndex(decision,0,4)
				cachedOutput = decision;
				this.board.uncached++;
			}
			if(_debug) trace("decision",decision,sw,!!(sw&1),!!(sw&2))
			move(!!(sw&1),!!(sw&2))
			if(!board.hardWiredLights){
				this.greenOn = (decision[4] > .5)
				if(board.poison) this.redOn = (decision[5] > .5)
			}
		}
		
		/**
		 * Draw line where this robot is looking
	 	 */
		public function drawDir(dir:Number,dist:Number,clear:Boolean = false):void{
			var g:Graphics = this.rangeMC.graphics
			g.clear()
			if(clear) return
			g.moveTo(0,0)
			g.lineStyle(2,0x990000,.9)
			g.lineTo(dist*Math.cos(dir),dist*Math.sin(dir))
			g.endFill()
		}
		
		public function move(right:Boolean, left:Boolean):void{
			rmotor = right
			lmotor = left
			if(right && left){
				this._x += _moveStep*Math.cos(this._angle)
				this._y += _moveStep*Math.sin(this._angle)
				this.score += 10
			}else if(right){
				this._angle += Math.PI/12
			}else if(left){
				this._angle -= Math.PI/12
			}
			//wrap the screen around
			if(_x < 0) _x = 700
			if(_x>700) _x = 0
			if(_y < 0) _y = 600
			if(_y>600) _y = 0
			this.x = this._x
			this.y = this._y
			this.rotation = 180*(this._angle/Math.PI)
		}
		
		
		/*---------------------------------------------------------------------------------------------------*/
		/*  Protected FUNCTIONS							                               Protected FUNCTIONS  */
		/*-------------------------------------------------------------------------------------------------*/
		/**
		 *  Draw robot on the field.
	 	 *  Called by: constructor
	 	 *
	 	 */
		protected function drawRobot(range:Boolean = false):void{
			var g:Graphics = this.graphics
			
			// Draw body
			g.beginFill(0x999999)
			g.lineStyle(1,0x000000)
			g.drawRect(-_width/2,-_height/2,this._width,this._height)
			g.beginFill(0x999900,.5)
			g.drawRect(-_width/2,-_height/4,this._width/2,this._height/2)
			g.endFill()
			
			//Draw lights
			var gf:GlowFilter = new GlowFilter(0x009900,.8,3,3,3,2)
			var rf:GlowFilter = new GlowFilter(0x990000,.8,3,3,3,2)
			var bf:BlurFilter = new BlurFilter(3,3,1)
			this.greenMC.filters = [gf,bf]
			g = greenMC.graphics
			g.beginFill(0x009900,.8)
			g.drawCircle(0,0,2)
			g.endFill()
			greenMC.x = _width/4
			greenMC.y = _height/4
			this.redMC.filters = [rf,bf]
			g = redMC.graphics
			g.beginFill(0x990000,.8)
			g.drawCircle(0,0,2)
			g.endFill()
			redMC.x = _width/4
			redMC.y = -_height/4
			
			//Draw range overlay
			g = this.rangeMC.graphics
			g.beginFill(0x990000,.4)
			g.lineStyle(1,0x111111)
			g.drawCircle(0,0,35)
			g.endFill()
			rangeMC.x = 0
			rangeMC.y = 0
			rangeMC.visible = range
			
			this.rotation = 180*(this._angle/Math.PI)
			
			this.addChild(rangeMC)
			this.addChild(greenMC)
			this.addChild(redMC)
		}
		
		/**
		 *  Return the index of maximum value in a range of an array.
		 * 	TODO: move to a different class
	 	 */
		protected function maxIndex(arr :Array, start :int = 0, end :int = -1):int{
			var m:Number = Number.MIN_VALUE
			var index:int = -1
			if(end == -1) end = arr.length
			for(var i:Number = start;i<end;i++){
				if(arr[i] > m){
					m=arr[i]
					index = i
				}
			}
			return index
		}

	}
}