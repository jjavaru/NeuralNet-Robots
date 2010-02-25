package
{
	import Robots.BaseRobot;
	import Robots.NNRobot;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Graphics;
	import flash.display.Sprite;
	import flash.filters.DropShadowFilter;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	
	import gui.Button;
	import gui.DraggableSprite;
	import gui.Graph;
	import gui.ToggleButton;

	public class BoardUI extends Sprite
	{
		[Embed(source="../Images/CheckUp.jpg")]
		public var imgCheckUp:Class;
		[Embed(source="../Images/CheckDown.jpg")]
		public var imgCheckDown:Class;
		[Embed(source="../Images/CheckOver.jpg")]
		public var imgCheckOver:Class;
		[Embed(source="../Images/CheckOverDown.jpg")]
		public var imgCheckOverDown:Class;
		
		protected var board:RobotBoard
		
		public var graph:Graph;
		public var displayRobot:BaseRobot;
		public var txtFitness:TextField = new TextField();
		public var txtTraining:TextField = new TextField();
		public var detailsMC:Sprite = new DraggableSprite();
		public var topMenuMC:Sprite = new Sprite();
		public var netDisplayMC:Sprite = new Sprite();
		public var menuMC:Sprite = new Sprite();
		
		//Buttons
		protected var btnUnsupervised:Button = new Button();
		protected var btnSupervised:Button;
		protected var btnTesting:Button = new ToggleButton();
		
		//Button Images
		protected var bmdu_up   :BitmapData = new BitmapData(183, 40, true, 0xFFBDE052);
	    protected var bmdu_over :BitmapData = new BitmapData(183, 40, true, 0xFF52C4E0);
	    protected var bmdu_down :BitmapData = new BitmapData(183, 40, true, 0xFFffd700); //0xFFE052C4);
	    protected var bmdu_dis  :BitmapData = new BitmapData(183, 40, true, 0x99999999);
		
		protected var bmd_t_up   :BitmapData = new BitmapData(50, 16, true, 0xFFBDE052);
	    protected var bmd_t_over :BitmapData = new BitmapData(50, 16, true, 0xFF52C4E0);
	    protected var bmd_t_down :BitmapData = new BitmapData(50, 16, true, 0xFFE052C4);
	    protected var bmd_t_dis  :BitmapData = new BitmapData(50, 16, true, 0x99999999);
		
		
		public function BoardUI(board:RobotBoard)
		{
			super();
			this.board = board;
		}
		
		public function drawUI() :void {
			drawTopMenu()
			drawInspectPane()
			drawGraph()
		}
		
		public function drawMainMenu() :void {
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
	        btnPoison.downFunction = function():void { board.poison = true; trace("downFun",board.poison); }
	        btnPoison.upFunction   = function():void { board.poison = false; trace("upFun",board.poison); }
			
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
	        btn50.downFunction = function():void { board.popCount = 50}
	        btn100.downFunction = function():void { board.popCount = 100}
	        btn100.toggle = true
			
			with(btnUnsupervised){
	        	x = 165
	        	y = 400
	        	up = bmdu_up;
	        	over = bmdu_over;
	        	down = bmdu_down
	        	disabled = bmdu_dis
	        	text = "No training"
	  		}
	        btnUnsupervised.downFunction = function():void { board.supervised = false;}
	        
	        btnSupervised = btnUnsupervised.clone();
	        with(btnSupervised){
	        	x = 350
	        	y = 400
	        	enabled = false
	        	text = "Backpropagation training"
	        }
	        btnSupervised.downFunction = function():void { board.supervised = true; txtTraining.visible = true;}
	        
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
	        btnBegin.downFunction = function():void {board.begin();
													menuMC.visible = false;
													txtTraining.visible = false;}
	        
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
			btnPause.downFunction = function() :void { board.paused = !board.paused };
			
			var btnQuit:Button = btnGraph.clone()
			with(btnQuit){
				x = 156
				y = 0
				enabled = true
				text = "Quit"
			}
			btnQuit.downFunction = function() :void { board.save(); board.mainMC.visible = false; menuMC.visible = true };
			
			
			this.addChild(topMenuMC)
			topMenuMC.addChild(btnGraph)
			topMenuMC.addChild(btnInfo)
			topMenuMC.addChild(btnPause)
			topMenuMC.addChild(btnQuit)
		}
		
		protected function drawGraph() :void {
			graph = new Graph(true,"Round","Average Fitness")
			with (graph){
				x = 420;
				y = 200;
			}
			this.addChild(graph)
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
				x = 10;
				y = 10;
				width = 130;
				multiline = true;
				mouseEnabled = false;
				defaultTextFormat = new TextFormat("Arial",16,0xffffff);
				wordWrap = true;
			}
			
			displayRobot = new BaseRobot(0,this.board,75,120,false,1.0);
			//displayRobot = new Robot(0,this.board,75,120,null,false,false,1.0,true)
			detailsMC.addChild(displayRobot);
			
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
		
		protected function drawNNDisplay( arr :Array) :void {
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
		
		public function updateDisplayRobot(selectedRobot :NNRobot) :void {
			txtFitness.text = 	"Robot " + selectedRobot.id + 
								"\nGeneration " + selectedRobot.generation + 
								"\nScore: " + selectedRobot.score
			displayRobot.greenOn = selectedRobot.greenOn
			displayRobot.redOn = selectedRobot.redOn
			displayRobot.rotation = selectedRobot.rotation
			drawNNDisplay(selectedRobot.cachedInput)
		}
		
		//handle clicking on a robot
		public function robotSelect(ro :BaseRobot) :void{
			
			txtFitness.text = ro.score.toString()
			detailsMC.visible = true
		}
		
	}
}