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
		
		public function ToggleButton()
		{
			super();
			this._states = 5
		}
		
		public function changeToggle(on:Boolean) :void {
			var s:Boolean = _bm.smoothing;
			if(testing) trace("Button::changeToggle() "+on );
			_bm.bitmapData = _bmds[on ? 2 : 0];
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
				_bmds[4] = arg;
			}
			center();
		}	
		
		/**
		*	Returns a clone of the given Button instance.
		*	
		*	@return ToggleButton instance.
		*/
		public override function clone() :Button
		{
			var newb:ToggleButton = new ToggleButton();
				newb.guide = guide == null ? null : guide.clone();
				newb.up = up == null ? null : up.clone();
				newb.over = over == null ? null : over.clone();
				newb.down = down == null ? null : down.clone();
				newb.disabled = (disabled == null) ? null : disabled.clone()
				newb.overDown = overDown == null ? null : overDown.clone();
				newb.upFunction = upFunction;
				newb.overFunction = overFunction;
				newb.downFunction = downFunction;
				newb.outFunction = outFunction;
				newb.textFormat = _textLabel.defaultTextFormat
				return newb;
		}
		/**
		 *	The <code>BitmapData</code> object to represent the button in the over position.
		 */
		public function get overDown() : BitmapData 
		{ 
			return _bmds[4]; 
		}
		
		/*---------------------------------------------------------------------------------------------------*/
		/*  OVERRIDE FUNCTIONS																			    */
		/*-------------------------------------------------------------------------------------------------*/
		
		protected override function mouseUpHandler(event:MouseEvent) : void {
			return
		} 
		
		protected override function nextOverBitmap() :BitmapData {
			return _bmds[_toggled ? 4 : 1];
		}
		
		protected override function nextDownBitmap() :BitmapData {
			//radio button style
			if(radioSet.length > 0){
				for each(var tb:ToggleButton in radioSet){
					tb.changeToggle(false)
				}
				this._toggled = true
			//check box style
			} else { 
				_toggled = !_toggled
			}
			return _bmds[_toggled ? 4 : 1];
		}
		
		protected override function nextOutBitmap() :BitmapData {
			return _bmds[_toggled ? 2 : 0];
		}
		
	}
}