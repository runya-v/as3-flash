package {
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.EventDispatcher;
	import flash.geom.Vector3D;
	
	/**
	 * @author Velichko R.N.; email:rostislav.vel@gmail.com; (c) 6.2011
	 */
	public class Transition extends Sprite {
		[Embed(source='../../map_data.swf', symbol='Needle')]
		private var Needle:Class;
		
		private static const ALPHA:Number = 10;
		private static const SUB_SHIFT:Number = 12;
		private static const LINE_DEPTH:Number = 10;

		private var parent_:Restaurant;
		public var id_:int;
		public var from_id_:int;
		public var to_id_:int;
		
		public function Transition(parent:Restaurant, id:int, from:int, to:int) {
			parent_  = parent;	
			id_      = id;
			from_id_ = from;
			to_id_   = to;
		}
		
		public function draw():void {
			this.graphics.clear();
			
			var from:Camera = parent_._cameras[from_id_];
			var to:Camera = parent_._cameras[to_id_];
			
			// линия
			var v:Vector3D = new Vector3D(to.x - from.x, to.y - from.y);
			var length:Number = v.length; 
			v.normalize();
			
			var sub:Vector3D = new Vector3D(v.x, v.y, v.z);
			sub.normalize();
			sub.scaleBy(SUB_SHIFT);
			
			var c:Vector3D = v.crossProduct(new Vector3D(0, 0, 1));
			c.normalize();
			c.scaleBy(LINE_DEPTH / 2);
			
			var rotate:Number = Math.acos(v.dotProduct(new Vector3D(0, 1))) * 180 / Math.PI;
			
			if (v.x >= 0) {
				rotate = 90 - rotate; 
			}
			else {
				rotate = 90 + rotate; 
			}
			this.graphics.beginFill(0xbfc8c7, ALPHA);
			this.graphics.lineStyle(1, 0x000000);
			this.graphics.moveTo(SUB_SHIFT, LINE_DEPTH / 2);
			this.graphics.lineTo(SUB_SHIFT * 1.5, 0);
			this.graphics.lineTo(SUB_SHIFT * 1.5, LINE_DEPTH / 4);
			this.graphics.lineTo(length - SUB_SHIFT * 1.5, LINE_DEPTH / 4);
			this.graphics.lineTo(length - SUB_SHIFT * 1.5, 0);
			this.graphics.lineTo(length - SUB_SHIFT, LINE_DEPTH / 2);
			this.graphics.lineTo(length - SUB_SHIFT * 1.5, LINE_DEPTH);
			this.graphics.lineTo(length - SUB_SHIFT * 1.5, LINE_DEPTH * 0.75);
			this.graphics.lineTo(SUB_SHIFT * 1.5, LINE_DEPTH * 0.75);
			this.graphics.lineTo(SUB_SHIFT * 1.5, LINE_DEPTH);
			this.graphics.lineTo(SUB_SHIFT, LINE_DEPTH / 2);
			this.graphics.endFill();
			
			this.x = from.x + c.x; 
			this.y = from.y + c.y;
			this.rotationZ = rotate;
		}
	}
}