package {
	import away3d.cameras.HoverCamera3D;
	import away3d.cameras.TargetCamera3D;
	import away3d.containers.View3D;
	import away3d.core.render.Renderer;
	import away3d.core.utils.Cast;
	import away3d.materials.BitmapMaterial;
	import away3d.primitives.Sphere;
	
	import flash.display.Bitmap;
	import flash.display.BlendMode;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.ui.Mouse;
	import flash.ui.MouseCursor;
	
	[SWF(width="600", height="800", frameRate="60", backgroundColor="#000000")]
	//[SWF(frameRate="60", backgroundColor="#000000")]
	public class PanoramaSettings extends Sprite {
        [Embed(source='../../buttons.swf', symbol='bt_inc')]
        private var bt_inc:Class;
        
        [Embed(source='../../buttons.swf', symbol='bt_dec')]
        private var bt_dec:Class;
        
        [Embed(source="../lift.png")] 
        private var SrcImage:Class;
        private var m_image:Bitmap = new SrcImage();

        private var m_bt_cam_zoom:CameraControllerButton;
		private var m_bt_cam_focus:CameraControllerButton;
		private var m_bt_cam_fov:CameraControllerButton;
		
		private var m_view:View3D;
		private var m_cam:HoverCamera3D;
		private var m_cam_x:uint;
		private var m_cam_y:uint;
		
		private var m_sphere:Sphere;
		private var m_curr_alpha:Number;
		
		private var m_material:BitmapMaterial;
		
		private var m_cur_num_img:int = 0;
		private var m_duration:uint;
        
        private var _old_mouse_x:Number = 0;
        private var _old_mouse_y:Number = 0;
        private var _mouse_dovn:Boolean = false;

        
		public function PanoramaSettings() {
			// create a basic camera
			m_cam = new HoverCamera3D();
			m_cam.zoom = 8;
			m_cam.focus = 50;
			m_cam.panAngle = 0;
			m_cam.tiltAngle = 0;
			m_cam.minTiltAngle = -90;
			m_cam.distance = 0.5;
			m_cam.hover(true);
			
			m_cam_x = 360;
			m_cam_y = 200;
			
			// create a viewport
			m_view = new View3D({camera:m_cam, x:360, y:200, renderer:Renderer.CORRECT_Z_ORDER});
			addChild(m_view);

			m_material = new BitmapMaterial(Cast.bitmap(m_image), {smooth:true, precision:20});
		
			m_sphere = new Sphere({alpha:.1, radius:800, segmentsH:40, segmentsW:40});
			m_sphere.material = m_material
			m_sphere.scaleX = -1;
			
			m_view.scene.addChild(m_sphere);
			m_view.render();
			
			initCameraButtons();

            addEventListener(Event.ENTER_FRAME, onEnterFrame);
            
            this.addEventListener(MouseEvent.MOUSE_DOWN, function(e:MouseEvent):void {
                Mouse.cursor = MouseCursor.HAND;
                _mouse_dovn = true;
            });
            
            this.addEventListener(MouseEvent.MOUSE_UP, function(e:MouseEvent):void {
                Mouse.cursor = MouseCursor.AUTO;
                _mouse_dovn = false;
                _old_mouse_x = 0;
                _old_mouse_y = 0;
            });
            
            this.addEventListener(MouseEvent.MOUSE_OVER, function(e:MouseEvent):void {
                Mouse.cursor = MouseCursor.AUTO;
                _mouse_dovn = false;
                _old_mouse_x = 0;
                _old_mouse_y = 0;
            });
            
            this.addEventListener(MouseEvent.MOUSE_MOVE, function(e:MouseEvent):void {
                if (_mouse_dovn) {
                    if (_old_mouse_x == 0) {
                        _old_mouse_x = e.stageX;
                    }
                    
                    if (_old_mouse_y == 0) {
                        _old_mouse_y = e.stageY;
                    }
                    
                    var shift_x:Number = e.stageX - _old_mouse_x;
                    var shift_y:Number = e.stageY - _old_mouse_y;
                    
                    if (shift_x < 0) {
                        m_cam.moveRight(-shift_x);
                        m_cam.panAngle += shift_x;
                    }
                    
                    if (shift_x > 0) {
                        m_cam.moveLeft(shift_x);
                        m_cam.panAngle += shift_x;
                    }
                    
                    if (shift_y < 0) {
                        m_cam.moveDown(-shift_y);
                        m_cam.tiltAngle += shift_y
                    }
                    
                    if (shift_y > 0) {
                        m_cam.moveUp(shift_y);
                        m_cam.tiltAngle += shift_y;
                    }
                    
                    _old_mouse_x = e.stageX;
                    _old_mouse_y = e.stageY;
                }
            });
		}

		public function get_sphere_radius():int {
			return m_sphere.radius;
		}

		public function set_sphere_radius(s:int):void {
			m_sphere.radius = s;
		}

		private function initCameraButtons():void {
			var scale:Number = 0.2;
			var move:Number = 1;
			var one_pos:int = 30;
			var two_pos:int = 22;
			var cam_y:uint = m_cam_y + 155;
			
			m_bt_cam_zoom = new CameraControllerButton(this, new bt_inc(), new bt_dec(), m_cam, 1, scale - .03, two_pos, two_pos, 25, "zoom");
			m_bt_cam_focus = new CameraControllerButton(this, new bt_inc(), new bt_dec(), m_cam, 2, scale - .03, two_pos, two_pos*2, 25, "focus");
			m_bt_cam_fov = new CameraControllerButton(this, new bt_inc(), new bt_dec(), m_cam, 3, scale - .03, two_pos, two_pos*3, 25, "fov");
			m_bt_cam_fov = new CameraControllerButton(this, new bt_inc(), new bt_dec(), m_cam, 4, scale - .03, two_pos, two_pos*4, 25, "distance");
			m_bt_cam_fov = new CameraControllerButton(this, new bt_inc(), new bt_dec(), m_cam, 5, scale - .03, two_pos, two_pos*5, 25, "sphere radius");
		}

		private function onEnterFrame(e:Event):void {
    		m_cam.hover();
			m_view.render();
		}
	}
}
