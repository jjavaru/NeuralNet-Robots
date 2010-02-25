package gui
{
	import flash.display.BitmapData;
	import flash.events.MouseEvent;
	
	public class ToggleButton extends Button
	{
		/*---------------------------------------------------------------------------------------------------*/
		/*  PUBLIC VARIABLES			                                                 PUBLIC VARIABLES   */
		/*-------------------------------------------------------------------------------------------------*/
		/**
	 	*	Array of Buttons to toggle with this one.  
	 	*/
		public var radioSet :Array = []
		
		/*---------------------------------------------------------------------------------------------------*/
		/*  PRIVATE VARIABLES			                                                 PRIVATE VARIABLES  */
		/*-------------------------------------------------------------------------------------------------*/
		private var _toggled :Boolean = false 
		protected static var OVERDOWN:Number = 4
		
		/*---------------------------------------------------------------------------------------------------*/
		/*  CONSTRUCTOR					                                                 				    */
		/*-------------------------------------------------------------------------------------------------*/
		public function ToggleButton()
		{
			super();
			this._states = 5
		}
		
		public function set toggle(on:Boolean) :void {
			if(_disabled) return
			var s:Boolean = _bm.smoothing;
			if(testing) trace("Button::changeToggle() "+on );
			_bm.bitmapData = _bmds[on ? DOWN : UP];
			_toggled = on
			_bm.smoothing = s;
		}
		
		/**
	 	*	The <code>BitmapData</code> object to represent the button in the over position when toggled on.
	 	*/
		public function set overDown( arg:BitmapData ) : void 
		{ 
			if(testing) trace("Button::over() " );
			if(_bmds.length == 0)
			{
				if(testing) trace("	overDown() pushing _bm.bitmapData into all slots.");
				initImagesAndListeners(arg);
			}else
			{
				_bmds[OVERDOWN] = arg;
			}
			center();
		}
		
		/**
	 	*	The <code>BitmapData</code> object to represent the button in the "mouse-over and selected" state. 
	 	*/
		public function get overDown() : BitmapData 
		{ 
			return _bmds[OVERDOWN]; 
		}
		
		/**
		*	Returns a clone of the given Button instance.
		*	
		*	@return ToggleButton instance.
		*/
		public override function clone(_x:int = 0, _y:int = 0, _text:String="") :Button
		{
			var newb:ToggleButton = makeClone(new ToggleButton(),_x,_y,_text) as ToggleButton
			newb.overDown = overDown == null ? null : overDown.clone();
			newb.radioSet = radioSet
			return newb
		}
		
		public function cloneToggle(_x:int = 0, _y:int = 0, _text:String="") :ToggleButton {
			return clone(_x,_y,_text) as ToggleButton
		}
		
		/*---------------------------------------------------------------------------------------------------*/
		/*  OVERRIDE FUNCTIONS																			    */
		/*-------------------------------------------------------------------------------------------------*/
		
		protected override function mouseUpHandler(event:MouseEvent) : void {
			return
		} 
		
		protected override function nextOverBitmap() :BitmapData {
			if(testing) trace("nextOverBitmap: ",_toggled ? 4: 1)
			return _bmds[_toggled ? OVERDOWN : OVER];
		}
		
		protected override function nextDownBitmap() :BitmapData {
			//radio button style
			if(radioSet.length > 0){
				for each(var tb:ToggleButton in radioSet){
					tb.toggle = false
				}
				this._toggled = true
			//check box style
			} else { 
				_toggled = !_toggled
			}
			return _bmds[_toggled ? OVERDOWN : OVER];
		}
		
		protected override function nextOutBitmap() :BitmapData {
			return _bmds[_toggled ? DOWN : UP];
		}
		
		protected override function mouseDownHandler(event:MouseEvent) : void 
		{
			if(_disabled) return
			var s:Boolean = _bm.smoothing;
			if(testing) trace("Button::mouseDownHandler() " );
			stage.addEventListener("mouseUp", mouseUpHandler, false, 0, true);
			_bm.bitmapData = nextDownBitmap()
			_bm.smoothing = s;
			_prs = true;
			_dwnBf = false;
			center();
			if(_toggled){
				if(downFunction != null) downFunction(event);
			} else { 
				if(upFunction != null) upFunction(event);		
			}
		}
		
	}
}