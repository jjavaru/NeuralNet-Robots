package Robots
{
	import flash.events.MouseEvent;
	
	public class NNRobot extends BaseRobot
	{	
		//Neural Net related
		protected var net:NeuralNet;
		protected var TrainingInput:Array
		protected var TrainingOutput:Array
		protected var useBackprop:Boolean = false
		public var cachedInput:Array = new Array()
		protected var cachedOutput:Array;
		
		public function NNRobot(board:RobotBoard, gen:Number, mateNet:NeuralNet = null, training :Boolean = false)
		{
			super(gen,board,0,0,false,1.0)
			
			if(mateNet == null) {
				net = new NeuralNet(9 + (board.poison ? 6 : 0) + (board.predatorActive ? 4 : 0),
									8,
									4 + (board.hardWiredLights ? 0 :(board.poison ? 2 : 1)) );
			} else {
				net = mateNet
			}
			
			if(useBackprop && mateNet == null){
				trainNeuralNet()
			}
			
			this.addEventListener(MouseEvent.CLICK,selected)
			initialPosition()
			
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
		
		protected function selected(e :MouseEvent) :void {
			this.board.robotSelect(this)
		}
		
		public function mate(ro:NNRobot, scale:Number = 1.0):NNRobot{
			
			return new NNRobot(board,this.board.round,net.mate(ro.net),false)
		}
		
		/*---------------------------------------------------------------------------------------------------*/
		/*  GETTER/SETTERS							                                      	GETTER/SETTERS  */
		/*-------------------------------------------------------------------------------------------------*/
		public function set debug(b:Boolean):void{
			this.net.debug = b
		}
		
		/*---------------------------------------------------------------------------------------------------*/
		/*  PUBLIC FUNCTIONS							                               	  PUBLIC FUNCTIONS  */
		/*-------------------------------------------------------------------------------------------------*/
		/**
	 	*	Handle input to this robot
	 	*/
		public override function input(neighbors:Array):void{
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

	}
}