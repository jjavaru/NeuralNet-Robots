/* AS3
	Copyright 2008 efnx.com.
*/
package gui
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import flash.text.TextFormat;
	
	/**
	 *	Button is a simple button with three images and four actions: over, down, up and out.
	 *
	 *	@langversion ActionScript 3.0
	 *	@playerversion Flash 9.0
	 *
	 *	@author Schell Scivally
	 *	@since  2008-07-24
	 * 
	 * JMJ changes:
	 * - disabled state
	 * - togglable
	 * - upover state
	 */
	public class Button extends Sprite 
	{
		
		/*---------------------------------------------------------------------------------------------------*/
		/*  CLASS CONSTANTS						                                      		CLASS CONSTANTS */
		/*-------------------------------------------------------------------------------------------------*/
		
		/*---------------------------------------------------------------------------------------------------*/
		/*  PRIVATE VARIABLES			                                                 PRIVATE VARIABLES  */
		/*-------------------------------------------------------------------------------------------------*/
		protected var _bmds : Array = new Array();
		protected var _bm:Bitmap = new Bitmap();
		private var _dwnBf:Boolean = false;
		private var _prs:Boolean = false;
		private var _center:String = "TL";
		//*JMJ additions
		private var _text:String = "";
		protected var _textLabel:TextField = new TextField()
		protected var _textFormatSet:Boolean = false
		protected var _disabled :Boolean = false
		protected var _states :Number = 4
		/*---------------------------------------------------------------------------------------------------*/
		/*  PUBLIC VARIABLES			                                                  PUBLIC VARIABLES  */
		/*-------------------------------------------------------------------------------------------------*/
		/**
	 	*	Reference to the function to be performed on roll over.
	 	*/
		public var overFunction:Function;
		/**
	 	*	Reference to the function to be performed on mouse down.
	 	*/
		public var downFunction:Function;
		/**
	 	*	Reference to the function to be performed on mouse up.
	 	*/
		public var upFunction:Function;
		/**
	 	*	Reference to the function to be performed on roll out.
	 	*/
		public var outFunction:Function;
		/**
	 	*	A <code>BitmapData</code> object specifying the bounds of the button.
	 	*	Two BitmapData given for each up/over/down state could be different
	 	*	sizes, so the guide will be the deciding bound.
	 	*/
		public var guide:BitmapData;
		/**
	 	*	Toggles verbose output.
	 	*/
		public static var testing:Boolean = false;
		/*---------------------------------------------------------------------------------------------------*/
		/*  CONSTRUCTOR							                                         	   CONSTRUCTOR  */
		/*-------------------------------------------------------------------------------------------------*/
		
		/**
		 *	@Constructor
		 */
		public function Button():void
		{
			super();
			if(testing) trace("Button::constructor() ");
			addChild(_bm);
			buttonMode = true;
			this.addChild(_textLabel);
			this.text = ""
		}
		
		/*---------------------------------------------------------------------------------------------------*/
		/*  GETTER/SETTERS							                                      	GETTER/SETTERS  */
		/*-------------------------------------------------------------------------------------------------*/
		/**
	 	 *	Returns the button text
	 	 */
		public function get text():String
		{
			return _text;
		}
		/**
	 	 *	Set the button text
	 	 */
		public function set text(newText :String) :void
		{
			if(!_textFormatSet){
				_textLabel.defaultTextFormat = new TextFormat("Arial")
			}
            _textLabel.textColor = 0x000000
            _textLabel.mouseEnabled = false;
            _textLabel.text = newText;
            _textLabel.autoSize = "left";
            _textLabel.x = this.width/2 - _textLabel.width/2;
            _textLabel.y = this.height/2 - _textLabel.height/2;
		}
		
		public function set textFormat(newStyle :TextFormat) :void
		{
			_textFormatSet = true
			_textLabel.defaultTextFormat = newStyle
		}
		
		/**
	 	 *	Returns whether or not the Button is initialized and
	 	 *	contains references to bitmapData.
	 	 */
		public function get initialized():Boolean
		{
			if(_bmds == null || _bmds.length < _states) return false
			return true;
		}
		/**
	 	*	The <code>BitmapData</code> object to represent the button in the normal or "up" position.
	 	*/
		public function set up( arg:BitmapData ) : void 
		{  
			if(testing) trace("Button::up() " );
			if(_bmds.length == 0)
			{
				if(testing) trace("	up() pushing _bm.bitmapData into all slots." );
				initImagesAndListeners(arg);
			}else
			{
				_bmds[0] = arg;
			}
			center();
		}
		/**
	 	*	The <code>BitmapData</code> object to represent the button in the normal or "up" position.
	 	*/
		public function get up() : BitmapData 
		{ 
			return _bmds[0]; 
		}
		/**
	 	*	The <code>BitmapData</code> object to represent the button in the over position.
	 	*/
		public function set over( arg:BitmapData ) : void 
		{ 
			if(testing) trace("Button::over() " );
			if(_bmds.length == 0)
			{
				if(testing) trace("	over() pushing _bm.bitmapData into all slots.");
				initImagesAndListeners(arg);
			}else
			{
				_bmds[1] = arg;
			}
			center();
		}	
		/**
		 *	The <code>BitmapData</code> object to represent the button in the over position.
		 */
		public function get over() : BitmapData 
		{ 
			return _bmds[1]; 
		}
		/**
	 	*	The <code>BitmapData</code> object to represent the button in the down position.
	 	*/
		public function set down( arg:BitmapData ) : void 
		{ 
			if(testing) trace("Button::down() " );
			if(_bmds.length == 0)
			{
				if(testing) trace("	down() pushing _bm.bitmapData into all slots.");
				initImagesAndListeners(arg);
			}else
			{
				_bmds[2] = arg;
			} 
			center();
		}
		/**
	 	*	The <code>BitmapData</code> object to represent the button in the down position.
	 	*/
		public function get down() : BitmapData 
		{ 
			return _bmds[2]; 
		}
		/**
	 	*	The <code>BitmapData</code> object to represent the button when disabled.
	 	*/
		public function set disabled( arg:BitmapData ) : void 
		{ 
			if(testing) trace("Button::down() " );
			if(_bmds.length == 0)
			{
				if(testing) trace("	disabled() pushing _bm.bitmapData into all slots.");
				initImagesAndListeners(arg);
			}else
			{
				_bmds[3] = arg;
			} 
			center();
		}
		/**
	 	*	The <code>BitmapData</code> object to represent the button when disabled.
	 	*/
		public function get disabled() : BitmapData 
		{ 
			return _bmds[3]; 
		}
		
		/**
		*	@inheritDoc
		*/
		public override function get width():Number
		{
			if(guide != null) return guide.width;
			if(_bmds.length == 0) return 0;
			var w:Number = up.width > over.width ? up.width : over.width;
				w = w > down.width ? w : down.width;
				
			return w;
		}
		/**
		*	@inheritDoc
		*/
		public override function set width(val:Number):void
		{
			var w:Number = width;
			var scale:Number = val/width;
			scaleX = scale;
		}
		/**
	 	*	@inheritDoc
		*/
		public override function get height():Number
		{
			if(guide != null) return guide.height;
			if(_bmds.length == 0) return 0;
			var h:Number = up.height > over.height ? up.height : over.height;
				h = h > down.height ? h : down.height;
				
			return h;
		}
		/**
	 	*	@inheritDoc
		*/
		public override function set height(val:Number):void
		{
			var h:Number = height;
			var scale:Number = val/height;
			scaleY = height;
		}
		/*---------------------------------------------------------------------------------------------------*/
		/*  PUBLIC METHODS							                               	       	PUBLIC METHODS  */
		/*-------------------------------------------------------------------------------------------------*/
		/**
	 	*	Destroys all internal references.
	 	*/
		public function destroy():void
		{
			if(_bmds.length > 0)
			{
				for each(var bmd:BitmapData in _bmds) {
					if(bmd != null) bmd.dispose()
				}
			}
			if(guide != null) guide.dispose();
			_bmds.splice(0, _states);
		}
		/**
		*	Returns a clone of the given Button instance.
		*	
		*	@return Button instance.
		*/
		public function clone():Button
		{
			var newb:Button = new Button();
				newb.guide = guide == null ? null : guide.clone();
				newb.up = up == null ? null : up.clone();
				newb.over = over == null ? null : over.clone();
				newb.down = down == null ? null : down.clone();
				newb.disabled = (disabled == null) ? null : disabled.clone()
				//newb.overDown = overDown == null ? null : overDown.clone();
				newb.upFunction = upFunction;
				newb.overFunction = overFunction;
				newb.downFunction = downFunction;
				newb.outFunction = outFunction;
				newb.textFormat = _textLabel.defaultTextFormat
				return newb;
		}
		/**
	 	*	Inherits the skin [or bitmapdata and guide] as well as optionally the 
	 	*	action functions of the <code>parent</code> Button. This is much like
	 	*	the <code>clone</code> function, but instead of creating a new Button
	 	*	instance and returning it, it populates the calling Button instance
	 	*	with the bitmapdata and guide of the Button passed in the parameters.
	 	*	
	 	*	@param parent	The parent Button to inherit from.
	 	*	@parem inheritFunctions	Boolean value dictating whether or not to inherit the
	 	*	action functions of the <code>parent</code> Button.
	 	*/
		public function inheritSkin(parent:Button, inheritFunctions:Boolean = false):void
		{
			this.guide	= parent.guide;
			this.up   	= parent.up;   
			this.over 	= parent.over; 
			this.down 	= parent.down; 
			if(!inheritFunctions) return
			this.upFunction		= parent.upFunction;
			this.overFunction 	= parent.overFunction;
			this.downFunction 	= parent.downFunction;
			this.outFunction  	= parent.outFunction;
		}
		
		public function set enabled(d :Boolean) :void {
			this._disabled = !d
			if(_disabled){
				_bm.bitmapData = _bmds[3];
				trace("disabling button")
			} else {
				_bm.bitmapData = _bmds[0]
			}
		}
		/*---------------------------------------------------------------------------------------------------*/
		/*  EVENT HANDLERS							                                       EVENT HANDLERS   */
		/*-------------------------------------------------------------------------------------------------*/
		protected function mouseOverHandler(event:MouseEvent) : void 
		{
			if(!_disabled){
				var s:Boolean = _bm.smoothing;
				if(testing) trace("Button::mouseOverHandler() " );
				if(event.buttonDown && !_prs) _dwnBf = true;
				_bm.bitmapData = nextOverBitmap();
				_bm.smoothing = s;
				center();
			}
			if(overFunction != null) overFunction(event);
		}
		
		private function mouseDownHandler(event:MouseEvent) : void 
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
			if(downFunction != null) downFunction(event);
		}
		protected function mouseUpHandler(event:MouseEvent) : void 
		{
			if(_disabled) return
			var s:Boolean = _bm.smoothing;
			if(testing) trace("Button::mouseUpHandler() " );
			stage.removeEventListener("mouseUp", mouseUpHandler);
			_bm.bitmapData = (event.target == this) ? _bmds[1] : _bmds[0];
			_bm.smoothing = s;
			_prs = false;
			center();
			if(upFunction != null) upFunction(event);
		}
		
		
		
		private function mouseOutHandler(event:MouseEvent) : void 
		{
			if(!_disabled){
				var s:Boolean = _bm.smoothing;
				if(testing) trace("Button::mouseOutHandler() " );
				if((!event.buttonDown || _dwnBf) )
				{
					_bm.bitmapData = nextOutBitmap();
					_dwnBf = false;
				}
				_bm.smoothing = s;
				center();
			}
			if(outFunction != null) outFunction(event);
		}
		/*---------------------------------------------------------------------------------------------------*/
		/*  PRIVATE/PROTECTED METHODS				                           	 PRIVATE/PROTECTED METHODS  */
		/*-------------------------------------------------------------------------------------------------*/
		protected function initImagesAndListeners(arg:BitmapData) :void {
			_bm.bitmapData = arg;
			addEventListener("mouseOver", mouseOverHandler, false, 0, true);
			addEventListener("mouseDown", mouseDownHandler, false, 0, true);
			addEventListener("mouseOut", mouseOutHandler, false, 0, true);
			
			for (var i:int = 0; i<_states; i++)
			{
				_bmds.push(arg);
			}
		}
		/**
		*
		*/
		protected function center():void
		{
			_bm.x = width/2 - _bm.width/2;
			_bm.y = height/2 - _bm.height/2;
		}
		
		//select new bitmap for 
		protected function nextOutBitmap() :BitmapData {
			return _bmds[0]
		}
		protected function nextOverBitmap() :BitmapData {
			return _bmds[1]
		}
		protected function nextDownBitmap() :BitmapData {
			return _bmds[2]
		}
	}
	
}
