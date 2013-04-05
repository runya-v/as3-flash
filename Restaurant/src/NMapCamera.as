package {
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	
	/**
	 * @author Velichko R.N.; email:rostislav.vel@gmail.com; (c) 6.2011
	 */
	public class NMapCamera extends Sprite {
		[Embed(source='../../map_data.swf', symbol='CameraSector')]
		private var CameraSector:Class;
		
		[Embed(source='../../map_data.swf', symbol='MapCamera')]
		private var MapCamera:Class;

		private var mask_:Sprite = new Sprite;
		private var sector_:Sprite = new Sprite;
		private var sector_back_:Sprite = new Sprite;
		private var camera_sector_:Sprite = new CameraSector();
		private var map_camera_:Sprite = new MapCamera();;
		
		public function NMapCamera() {
			dravSectorMask();
			sector_back_.addChild(mask_);
			sector_back_.addChild(camera_sector_);
			this.addChild(sector_back_);
			this.addChild(map_camera_);
		}
		
		public function dravSectorMask(h:Number = 0.5):void {
			if (h < 0) {
				h = camera_sector_.width * 0.1;
			} else if (1 < h) {
				h = camera_sector_.width - camera_sector_.width * 0.1;
			} else {
				h *= (camera_sector_.width - camera_sector_.width * 0.2);
			}
			
			var x0:Number = 0;
			var y0:Number = 0;
			
			// левая точка
			var x1:Number = h - camera_sector_.width;
			var y1:Number = -h;

			var x2:Number = 0;
			var y2:Number = -camera_sector_.width;

			// правая точка
			var x3:Number = camera_sector_.width - h;
			var y3:Number = -h;
			
			mask_.graphics.clear();
			mask_.graphics.beginFill(0x000000);
			mask_.graphics.moveTo(x0, x0);
			mask_.graphics.lineTo(x1, y1);
			mask_.graphics.lineTo(x2, y2);
			mask_.graphics.lineTo(x3, y3);
			mask_.graphics.lineTo(x0, x0);
			mask_.graphics.endFill();
			sector_back_.mask = DisplayObject(mask_);
		}
	}
}