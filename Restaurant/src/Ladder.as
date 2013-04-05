package {
	import flash.display.Sprite;
	import flash.events.EventDispatcher;
	
	/**
	 * @author Velichko R.N.; email:rostislav.vel@gmail.com; (c) 6.2011
	 */
	public class Ladder extends Sprite {
		private static const ALPHA:Number = 10;

		private var parent_:Restaurant;
		public var id_:int;
		public var x_:Number;
		public var y_:Number;
		public var w_:Number;
		public var h_:Number;
		public var angle_:Number;
		public var to_floor_:int;
		
		public function Ladder(parent:Restaurant) {
			parent_ = parent;	
		}
		
		public function draw():void {
			this.graphics.clear();
			this.graphics.beginFill(0x999999, ALPHA);
			this.graphics.lineStyle(1, 0x39658c);
			this.graphics.drawRect(-w_ / 2, -h_ / 2, w_, h_);
			this.graphics.endFill();
			this.graphics.moveTo(-w_ / 2, -h_ / 2);
			this.graphics.lineTo(0, h_ / 2);
			this.graphics.lineTo(w_ / 2, -h_ / 2);
			
			this.x = x_;
			this.y = y_; 
			this.rotationZ = angle_;
		}
	}
}