package {
	import flash.display.Sprite;
	import flash.events.EventDispatcher;
	import flash.geom.Vector3D;
	
	/**
	 * @author Velichko R.N.; email:rostislav.vel@gmail.com; (c) 6.2011
	 */
	public class Wall extends Sprite {
		private static const RADIUS:Number = 5;
		private static const ALPHA:Number = 10;
		private static const LINE_DEPTH:Number = 5;
		
		private var parent_:Restaurant;
		public var id_:int;
		public var x1_:int;
		public var y1_:int;
		public var x2_:int;
		public var y2_:int;
		public var angle_:Number;
		public var length_:Number;
		
		public function Wall(parent:Restaurant) {
			parent_ = parent;
		}
		
		public function draw():void {
			this.graphics.clear();
			
			// линия
			var v:Vector3D = new Vector3D(x2_ - x1_, y2_ - y1_);
			length_ = v.length; 

			var c:Vector3D = v.crossProduct(new Vector3D(0, 0, 1));
			c.normalize();
			c.scaleBy(LINE_DEPTH / 2);
			
			v.normalize();
			
			var rotate:Number = Math.acos(v.dotProduct(new Vector3D(0, 1))) * 180 / Math.PI;
			
			if (v.x >= 0) {
				angle_ = 90 - rotate; 
			}
			else {
				angle_ = 90 + rotate; 
			}
			trace(v + ": " + c + ": " + angle_);
			this.graphics.beginFill(0x999999, ALPHA);
			this.graphics.lineStyle(1, 0x39658c);
			this.graphics.drawRect(0, 0, length_, LINE_DEPTH);
			this.graphics.endFill();

			// первая точка
			this.graphics.beginFill(0x999999, ALPHA);
			this.graphics.lineStyle(1, 0x39658c);
			this.graphics.drawCircle(-RADIUS / 2, RADIUS / 2, RADIUS);
			this.graphics.endFill();
			
			// вторая точка
			this.graphics.beginFill(0x999999, ALPHA);
			this.graphics.lineStyle(1, 0x39658c);
			this.graphics.drawCircle(length_ - RADIUS / 2, LINE_DEPTH - RADIUS / 2, RADIUS);
			this.graphics.endFill();

			this.x = x1_ + c.x; 
			this.y = y1_ + c.y;
			this.rotationZ = angle_;
		}
	}
}