package {
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.EventDispatcher;
	
	/**
	 * @author Velichko R.N.; email:rostislav.vel@gmail.com; (c) 12.2010
	 */
	public class Camera extends Sprite {
		private static const RADIUS:Number = 7;
		
		public var _id:int;
		public var _x:Number;
		public var _y:Number;
		public var _transitions:Array = [];
		
		public function Camera(id:int, x:Number, y:Number) {
            _id = id;
            _x = x;
            _y = y;
		}
		
		public function draw():void {
			this.graphics.clear();
			this.graphics.beginFill(0x999999);
			this.graphics.lineStyle(1, 0xff5555);
			this.graphics.drawCircle(0, 0, RADIUS);
			this.graphics.endFill();
			this.x = _x;
			this.y = _y;
		}
		
		public function hide(b:Boolean):void {
			this.graphics.clear();
		}
	}
}