package {
	import away3d.containers.View3D;
	import away3d.core.base.Mesh;
	import away3d.core.base.Object3D;
	import away3d.core.geom.Plane3D;
	import away3d.core.utils.Cast;
	import away3d.events.MouseEvent3D;
	import away3d.materials.BitmapMaterial;
	import away3d.materials.MovieMaterial;
	import away3d.primitives.Plane;
	import away3d.primitives.RoundedCube;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Loader;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.filters.BlurFilter;
	import flash.filters.GlowFilter;
	import flash.geom.Vector3D;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.ui.Mouse;
	import flash.ui.MouseCursor;
	
	/**
	 * @author Velichko R.N.; email:rostislav.vel@gmail.com; (c) 12.2010
	 */
	public class GoPoint extends EventDispatcher {
		[Embed(source='../../buttons.swf', symbol='bt_needle')]
		private var BtNeedle:Class;

		[Embed(source='../../buttons.swf', symbol='error_pview')]
		private var ErrorPview:Class;

		public static const RADIAN:Number = 57.295779513;
        
		public static const GO_COMPLETE:String    = "GO_COMPLETE";
		public static const GO_ERROR:String       = "GO_ERROR";
		public static const GO:String             = "GO";
        public static const SET_TRANSITION:String = "SET_TRANSITION";
        public static const DEL_TRANSITION:String = "DEL_TRANSITION";
		
		public static const CAMERA_RADIUS:Number = 70;
		public static const NEEDLE_RADIUS:Number = 40;
		public static const CAM_ZOOM_DIST_CORRECTION:Number = 2000;
		public static const HORIZONT:Number = -45;
		public static const BACK_SHIFT:Number = 2;
		public static const Y_DIRECTION:Vector3D = new Vector3D(0, 1, 0);
		public static const Z_DIRECTION:Vector3D = new Vector3D(0, 0, 1);
		
		public var _camera_radius:Number = CAMERA_RADIUS;
		public var _needle_radius:Number = NEEDLE_RADIUS;
        
		public var _bitmap:Bitmap = null;
		public var _needles:Array = [];
		public var _needle_backs:Array = [];
		public var _to_points:Array = [];
		public var _planes:Array = [];
		public var _need_vecs:Array = [];
        
        public var _my_id:int;
		public var _my_vec:Vector3D;

        private var _cam_vec:Vector3D = new Vector3D();	
		
		public function GoPoint(id:int, cam:Camera) {
			var err_img:Sprite = new ErrorPview;
			_my_id = id;
			_my_vec = new Vector3D(cam._x, 0, cam._y);
		}
		
		public function camZoom(r:Number):void {
			_camera_radius = (CAM_ZOOM_DIST_CORRECTION * r / (CAMERA_RADIUS / 2 + CAMERA_RADIUS * 2)) + CAMERA_RADIUS / 2;
			camRotate(_cam_vec);
		}

		public function camRotate(vec:Vector3D):void {
			_cam_vec = new Vector3D(vec.x, 0, -vec.z);	
			_cam_vec.normalize();
			_cam_vec.scaleBy(_camera_radius);
			
			for (var i:int; i < _need_vecs.length; ++i) {
				var plane:Plane = _planes[i];
				var plane_back:Plane = _needle_backs[i];
				var needle:Vector3D = new Vector3D(-_need_vecs[i].x, 0, _need_vecs[i].z);
				needle.normalize();
				needle.scaleBy(_needle_radius);
				var new_pos:Vector3D = new Vector3D(needle.x + _cam_vec.x, 0, needle.z + _cam_vec.z);
				
				plane.x = new_pos.x;
				plane.z = new_pos.z;

				needle.normalize();
				var angle:Number = Math.acos(needle.dotProduct(Z_DIRECTION)) * RADIAN;
				
				if (needle.x >= 0) {
					plane.rotationY = angle; 
				}
				else {
					plane.rotationY = -angle;
				}
				plane.visible = true;

				plane_back.x = plane.x; 
				plane_back.z = plane.z; 
				plane_back.rotationY = plane.rotationY;
				plane_back.visible = true;
			}
		}

		public function addTransitionId(to_id:int, vec:Vector3D):void {
			var needle:MovieClip = new BtNeedle();
			var needle_back:MovieClip = new BtNeedle();
			needle.gotoAndStop(1);
			needle_back.gotoAndStop(3);
			
			var mat:MovieMaterial = new MovieMaterial(needle, {lookX:0, lookY:0, smooth:true, precision:5});
			var mat_back:MovieMaterial = new MovieMaterial(
				needle_back, {lookX:0, lookY:0, smooth:true, precision:5});
			var plane:Plane = new Plane( { material:mat, width:24, height:14 } );
			var plane_back:Plane = new Plane( { material:mat_back, width:24, height:14 } );
			var pos_vec:Vector3D = new Vector3D(vec.x - _my_vec.x, 0, vec.z - _my_vec.z);

			plane.y = HORIZONT;
			plane_back.y = HORIZONT - BACK_SHIFT;
			plane_back.visible = false;
		
			plane.addOnMouseOver(onMouseOver);
			plane.addOnMouseOut(onMouseOut);
			plane.addOnMouseDown(onMouseClick);
			plane.visible = false;
			
			_planes.push(plane);
			_needles.push(needle);
			_to_points.push(to_id);
			_need_vecs.push(pos_vec);
			_needle_backs.push(plane_back);
		}

        public function go(to_id:uint):void {
            trace("to: " + to_id)
            this.dispatchEvent(new MessageEvent(GoPoint.GO, String(to_id)));
        }

		private function onMouseOver(e:MouseEvent3D):void {
			Mouse.cursor = MouseCursor.BUTTON;
			MovieClip(MovieMaterial(Plane(e.target).material).movie).gotoAndStop(2);
		}
		
		private function onMouseOut(e:MouseEvent3D):void {
			Mouse.cursor = MouseCursor.AUTO;
			MovieClip(MovieMaterial(Plane(e.target).material).movie).gotoAndStop(1);
		}

		private function onMouseClick(e:MouseEvent3D):void {
			this.dispatchEvent(new MessageEvent(GoPoint.GO, String(_to_points[_planes.indexOf(e.target)])));
		}
		
		public function initTransitions():void {
			for (var i:int; i < _planes.length; ++i) {
                this.dispatchEvent(new GoPointEvent(SET_TRANSITION, Object3D(_needle_backs[i]), Object3D(_planes[i])));
			}
		}

		public function deinitTransitions():void {
			for (var i:int; i < _planes.length; ++i) {
                this.dispatchEvent(new GoPointEvent(DEL_TRANSITION, Object3D(_needle_backs[i]), Object3D(_planes[i])));
			}
		}
	}
}