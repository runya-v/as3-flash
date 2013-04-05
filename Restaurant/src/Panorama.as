package {
	import away3d.cameras.Camera3D;
	import away3d.containers.View3D;
	import away3d.core.utils.Cast;
	import away3d.materials.BitmapMaterial;
	import away3d.primitives.Sphere;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.TimerEvent;
	import flash.geom.Vector3D;
	import flash.text.TextField;
	import flash.utils.Timer;
	
	/**
	 * @author Velichko R.N.; email:rostislav.vel@gmail.com; (c) 12.2010
	 */
	public class Panorama extends EventDispatcher {
        [Embed(source="../Panorama.png")] 
        private var DefaultImage:Class;
        private var _default_image:Bitmap = new DefaultImage();
        
		public static const COMPLETE:String = "COMPLETE";
		public static const ERROR:String = "PANORAMA_ERROR";
		public static const DT:Number = 10;
		
		private var _parent:Restaurant;
		private var _sphere:Sphere;
		private var _material:BitmapMaterial;
		private var next_sphere_:Sphere;
		private var next_material_:BitmapMaterial;
		private var change_alpha_:Number;
		private var change_timer_:Timer;
		
		public var _curr_gop:GoPoint;
		
		public function Panorama(parent:Restaurant) {
			_parent = parent;
            _sphere = new Sphere({alpha:.1, radius:1000, segmentsH:50, segmentsW:50});
            _sphere.material = new BitmapMaterial(new BitmapData(80, 30, false, 0x7F7FFF), { smooth:true, precision:20 } );
            _sphere.scaleX = -1;
            _sphere.rotate(new Vector3D(0, 1, 0), -90);
            _parent._view.scene.addChild(_sphere);
 		}
		
		public function setGoPoint(id:int):void {
			if (_curr_gop) {
				_curr_gop.deinitTransitions();
			}
			
			var gop:GoPoint = _parent._go_points[id];
            
			_sphere.material = new BitmapMaterial(Cast.bitmap(Bitmap(gop._bitmap).bitmapData), { smooth:true, precision:20 } );
			
			gop.initTransitions();
			_parent._view.render();
            
            gop.camRotate(new Vector3D(
                -Math.sin(_parent._view.camera.rotationY / GoPoint.RADIAN), 
                0, 
                Math.cos(_parent._view.camera.rotationY / GoPoint.RADIAN)));
			
            _curr_gop = gop;
		}

		public function setNewBitmap(id:int, bitmap:Bitmap):void {
			var gop:GoPoint = _parent._go_points[id];
			
			if (gop) {
                if (gop._my_id == id) {
					gop._bitmap = bitmap;
                    setGoPoint(id);
                }
			}
			else {
				_parent._console.addMessage("! ERROR: panorama: can`t find GoPoint by id:" + id);		
			}
		}
		
		/*public function next(e:MessageEvent):void {
			_curr_gop = _parent._go_points[int(e._msg)];
			_sphere.material = _curr_gop._material;

			e.target.deinitTransitions();
			_curr_gop.initTransitions();
			_parent._view.render();
			_curr_gop.camRotate(new Vector3D(
				-Math.sin(_parent._view.camera.rotationY / GoPoint.RADIAN), 
                0, 
				Math.cos(_parent._view.camera.rotationY / GoPoint.RADIAN)));
		}*/

		public function newTransition(trans_id:int, from_gop:GoPoint, to_gop:GoPoint):void {
            from_gop.addTransitionId(to_gop._my_id, to_gop._my_vec);			
			to_gop.addTransitionId(from_gop._my_id, from_gop._my_vec);
		}
		
		public function cameraMove(a:Number):void {
			if (_curr_gop) {
				_curr_gop.camRotate(new Vector3D(-Math.sin(a / GoPoint.RADIAN), 0, Math.cos(a / GoPoint.RADIAN)));
			}
		}

		public function cameraZoom(z:Number):void {
			if (_curr_gop) {
				_curr_gop.camZoom(z);
			}
		}
	}
}