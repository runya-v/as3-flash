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
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	
	[SWF(width="720", height="400", frameRate="60", backgroundColor="#000000")]
	//[SWF(frameRate="60", backgroundColor="#000000")]
	public class PanoramaSettings extends Sprite {
		private var m_bt_cam_up:CameraRotationButton;
		private var m_bt_cam_down:CameraRotationButton;
		private var m_bt_cam_left:CameraRotationButton;
		private var m_bt_cam_right:CameraRotationButton;
		private var m_bt_cam_up_left:CameraRotationButton;
		private var m_bt_cam_up_right:CameraRotationButton;
		private var m_bt_cam_down_left:CameraRotationButton;
		private var m_bt_cam_down_right:CameraRotationButton;

		private var m_bt_cam_zoom:CameraControllerButton;
		private var m_bt_cam_focus:CameraControllerButton;
		private var m_bt_cam_fov:CameraControllerButton;
		
		private var m_view:View3D;
		private var m_cam:HoverCamera3D;
		private var m_cam_x:uint;
		private var m_cam_y:uint;
		
		private var m_sphere:Sphere;
		private var m_curr_alpha:Number;

		[Embed(source='../../buttons.swf', symbol='bt_cam_move')]
		private var bt_cam_move:Class;
		
		[Embed(source='../../buttons.swf', symbol='bt_inc')]
		private var bt_inc:Class;

		[Embed(source='../../buttons.swf', symbol='bt_dec')]
		private var bt_dec:Class;

		[Embed(source='../../buttons.swf', symbol='bt_needle')]
		private var bt_needle:Class;

		[Embed(source="../Panorama.png")] 
		private var SrcImage:Class;
		private var m_image:Bitmap = new SrcImage();
		
		private var m_material:BitmapMaterial;
		
		private var m_cur_num_img:int = 0;
		private var m_duration:uint;
		private var m_alpha_rate:Number;
		private var m_timer:Timer;
		private var m_delta_time:Number;
		private var m_rate:Number;

		public function PanoramaSettings() {
			// create a basic camera
			m_cam = new HoverCamera3D();
			//m_cam.z = -500; // make sure it's positioned away from the default 0,0,0 coordinate
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
		
			m_sphere = new Sphere({alpha:.1, radius:800, segmentsH:30, segmentsW:30});
			m_sphere.material = m_material
			m_sphere.scaleX = -1;
			
			m_view.scene.addChild(m_sphere);
			m_view.render();
			
			initCameraButtons();

            addEventListener(Event.ENTER_FRAME, onEnterFrame);

			m_rate = 10;
			m_delta_time = 0.5;
			m_alpha_rate = 1.0 / m_rate;
			m_curr_alpha = -m_alpha_rate;
		}

		public function get_sphere_radius():int {
			return m_sphere.radius;
		}

		public function set_sphere_radius(s:int):void {
			m_sphere.radius = s;
		}

		public function onTick(event:TimerEvent):void {
			m_material.alpha += m_curr_alpha;
		} 
		
		public function onTimerComplete(event:TimerEvent):void {
			if (m_material.alpha < .1) {
				m_curr_alpha = -m_alpha_rate;
			}
			else if (m_material.alpha > .9) {
				m_curr_alpha = m_alpha_rate;
			}
			onTick(null);
		} 

		private function nextImage(e:MouseEvent):void {
			if (m_cur_num_img < 3) {
				m_cur_num_img++;
			}
			else {
				m_cur_num_img = 0;
			}
			
			switch (m_cur_num_img) {
				case 0: m_sphere.material = m_material; break;
			}
		}

		public function nextMaterial():void {
			if (m_cur_num_img < 3) {
				m_cur_num_img++;
			}
			else {
				m_cur_num_img = 0;
			}
			
			switch (m_cur_num_img) {
				case 0: m_sphere.material = m_material; break;
			}
		}

		private function initCameraButtons():void {
			var scale:Number = 0.2;
			var move:Number = 1;
			var one_pos:int = 30;
			var two_pos:int = 22;
			var cam_y:uint = m_cam_y + 155;
			
			m_bt_cam_up = new CameraRotationButton(
				this, new bt_cam_move(), m_cam, scale, m_cam_x, cam_y - one_pos, 0, -move);
			m_bt_cam_down = new CameraRotationButton(
				this, new bt_cam_move(), m_cam, scale, m_cam_x, cam_y + one_pos, 0, move);
			m_bt_cam_left = new CameraRotationButton(
				this, new bt_cam_move(), m_cam, scale, m_cam_x - one_pos, cam_y, -move, 0);
			m_bt_cam_right = new CameraRotationButton(
				this, new bt_cam_move(), m_cam, scale, m_cam_x + one_pos, cam_y, move, 0);
			m_bt_cam_up_left = new CameraRotationButton(
				this, new bt_cam_move(), m_cam, scale, m_cam_x - two_pos, cam_y - two_pos, -move, -move);
			m_bt_cam_up_right = new CameraRotationButton(
				this, new bt_cam_move(), m_cam, scale, m_cam_x + two_pos, cam_y - two_pos, move, -move);
			m_bt_cam_down_left = new CameraRotationButton(
				this, new bt_cam_move(), m_cam, scale, m_cam_x - two_pos, cam_y + two_pos, -move, move);
			m_bt_cam_down_right = new CameraRotationButton(
				this, new bt_cam_move(), m_cam, scale, m_cam_x + two_pos, cam_y + two_pos, move, move);
			
			m_bt_cam_zoom = new CameraControllerButton(
				this, new bt_inc(), new bt_dec(), m_cam, 1, scale - .03, two_pos, two_pos, 25, "zoom");
			m_bt_cam_focus = new CameraControllerButton(
				this, new bt_inc(), new bt_dec(), m_cam, 2, scale - .03, two_pos, two_pos*2, 25, "focus");
			m_bt_cam_fov = new CameraControllerButton(
				this, new bt_inc(), new bt_dec(), m_cam, 3, scale - .03, two_pos, two_pos*3, 25, "fov");
			m_bt_cam_fov = new CameraControllerButton(
				this, new bt_inc(), new bt_dec(), m_cam, 4, scale - .03, two_pos, two_pos*4, 25, "distance");
			m_bt_cam_fov = new CameraControllerButton(
				this, new bt_inc(), new bt_dec(), m_cam, 5, scale - .03, two_pos, two_pos*5, 25, "sphere radius");
		}

		private function onEnterFrame(e:Event):void {
			m_bt_cam_up.updateMove();
			m_bt_cam_down.updateMove();
			m_bt_cam_left.updateMove();
			m_bt_cam_right.updateMove();
			m_bt_cam_up_left.updateMove();
			m_bt_cam_up_right.updateMove();
			m_bt_cam_down_left.updateMove();
			m_bt_cam_down_right.updateMove();
			
			m_cam.hover();
			m_view.render();
			onTimerComplete(null);
		}
	}
}
