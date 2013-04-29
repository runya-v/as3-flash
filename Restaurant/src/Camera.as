package {
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.MouseEvent;
	import flash.ui.Mouse;
	import flash.ui.MouseCursor;
	
	/**
	 * @author Velichko R.N.; email:rostislav.vel@gmail.com; (c) 12.2010
	 */
	public class Camera extends Sprite {
        public static const GO_TO_MY:String = "GO_TO_MY";

		private static const RADIUS:Number = 8;
		
		public var _id:int;
		public var _x:Number;
		public var _y:Number;
		public var _transitions:Array = [];
		
		public function Camera(id:int, x:Number, y:Number) {
            _id = id;
            _x = x;
            _y = y;
            
            this.addEventListener(MouseEvent.MOUSE_OVER, function(e:MouseEvent):void {
                Mouse.cursor = MouseCursor.BUTTON;
                graphics.clear();
                draw(0x8989ff);
            });

            this.addEventListener(MouseEvent.MOUSE_OUT, function(e:MouseEvent):void {
                Mouse.cursor = MouseCursor.AUTO;
                graphics.clear();
                draw();
            });
            
            this.addEventListener(MouseEvent.CLICK, function(e:MouseEvent):void {
                graphics.clear();
                draw();
                var id:uint = _id;
                dispatchEvent(new MessageEvent(GO_TO_MY, String(id)));
            });
		}
		
		public function draw(color:uint = 0x898999):void {
			this.graphics.clear();
			this.graphics.beginFill(color);
			this.graphics.lineStyle(1, 0x5555ff);
			this.graphics.drawCircle(0, 0, RADIUS);
			this.graphics.endFill();
			//this.x = _x;
			//this.y = _y;
		}
		
		public function hide(b:Boolean):void {
			this.graphics.clear();
		}
	}
}