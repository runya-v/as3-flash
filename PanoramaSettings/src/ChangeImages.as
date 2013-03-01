package {
	import away3d.cameras.TargetCamera3D;
	import away3d.containers.View3D;
	import away3d.core.base.Object3D;
	import away3d.core.utils.Cast;
	import away3d.events.MouseEvent3D;
	import away3d.materials.BitmapMaterial;
	import away3d.primitives.Cone;
	import away3d.primitives.Cube;
	import away3d.primitives.Sphere;
	
	import flash.display.Bitmap;
	import flash.display.BlendMode;
	import flash.display.Loader;
	import flash.display.LoaderInfo;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.events.ProgressEvent;
	import flash.net.URLRequest;
	import flash.ui.Keyboard;
	import flash.ui.Mouse;
	
	import flashx.textLayout.formats.Float;
		
	[SWF(width="720", height="400", frameRate="60", backgroundColor="#ffffff")]
	public class ChangeImages extends Sprite {
		private var m_loader:ClassLoader;
		
		private var m_bt_up:CameraRotationButton;
		private var m_bt_down:CameraRotationButton;
		private var m_bt_left:CameraRotationButton;
		private var m_bt_right:CameraRotationButton;
		private var m_bt_up_left:CameraRotationButton;
		private var m_bt_up_right:CameraRotationButton;
		private var m_bt_down_left:CameraRotationButton;
		private var m_bt_down_right:CameraRotationButton;
		
		private var m_cam:TargetCamera3D;
		private var m_view:View3D;
		
		private var m_sphere:Sphere;
		
		[Embed(source="../../Panorama_01.jpg")] 
		private var Image_01:Class;
		private var m_image_01:Bitmap = new Image_01();
		
		[Embed(source="../../Panorama_02.jpg")] 
		private var Image_02:Class;
		private var m_image_02:Bitmap = new Image_02();
		
		[Embed(source="../../Panorama_03.jpg")] 
		private var Image_03:Class;
		private var m_image_03:Bitmap = new Image_03();
		
		private var m_material_01:BitmapMaterial = new BitmapMaterial(Cast.bitmap(m_image_01));
		private var m_material_02:BitmapMaterial = new BitmapMaterial(Cast.bitmap(m_image_02));
		private var m_material_03:BitmapMaterial = new BitmapMaterial(Cast.bitmap(m_image_03));
		
		private var m_cur_num_img:int = 0;
		private var m_duration:uint;

		private var m_cam_x:uint;
		private var m_cam_y:uint;
		
		private var m_changer:MaterialChanger;
		
		public function ChangeImages() {
			m_loader = new ClassLoader();
			m_loader.load("buttons.swf");
			//m_loader.addEventListener(ClassLoader.LOAD_ERROR,loadErrorHandler);
			m_loader.addEventListener(ClassLoader.CLASS_LOADED, classLoadedHandler);

			// create a basic camera
			m_cam = new TargetCamera3D();
			m_cam.z = -500; // make sure it's positioned away from the default 0,0,0 coordinate
			m_cam.y = -10;
			
			m_cam_x = 360;
			m_cam_y = 200;
			
			// create a viewport
			m_view = new View3D({camera:m_cam, x:360, y:200});
			addChild(m_view);
			
			m_sphere = new Sphere({radius:700, segmentsH:22, segmentsW:22, material:m_image_01});
			m_sphere.scaleX = -1;
			//m_sphere.blendMode = BlendMode.ADD;
			//m_sphere.alpha = 0.5;
			
			m_view.scene.addChild(m_sphere);
			m_view.render();
			
			this.stage.addEventListener(KeyboardEvent.KEY_DOWN, keyDown);
			this.stage.addEventListener(KeyboardEvent.KEY_UP, keyUp);
			this.addEventListener(Event.ENTER_FRAME, onEnterFrame);
			
			nextImage(null);
			
			m_changer = new MaterialChanger(this, 3, 50, m_sphere);
		}

		private function classLoadedHandler(e:Event):void {
			var scale:Number = 2.3;
			var move:int = 10;
			var one_pos:int = 30;
			var two_pos:int = 22;
			var bt:String = "bt_cam_move";
			
			m_cam_y += 155;
			
			m_bt_up = new CameraRotationButton(
				this, m_loader, bt, m_cam, scale, m_cam_x, m_cam_y - one_pos, 0, -move);
			m_bt_down = new CameraRotationButton(
				this, m_loader, bt, m_cam, scale, m_cam_x, m_cam_y + one_pos, 0, move);
			m_bt_left = new CameraRotationButton(
				this, m_loader, bt, m_cam, scale, m_cam_x - one_pos, m_cam_y, -move, 0);
			m_bt_right = new CameraRotationButton(
				this, m_loader, bt, m_cam, scale, m_cam_x + one_pos, m_cam_y, move, 0);
			m_bt_up_left = new CameraRotationButton(
				this, m_loader, bt, m_cam, scale, m_cam_x - two_pos, m_cam_y - two_pos, -move, -move);
			m_bt_up_right = new CameraRotationButton(
				this, m_loader, bt, m_cam, scale, m_cam_x + two_pos, m_cam_y - two_pos, move, -move);
			m_bt_down_left = new CameraRotationButton(
				this, m_loader, bt, m_cam, scale, m_cam_x - two_pos, m_cam_y + two_pos, -move, move);
			m_bt_down_right = new CameraRotationButton(
				this, m_loader, bt, m_cam, scale, m_cam_x + two_pos, m_cam_y + two_pos, move, move);

			addChild(m_bt_up.getMovieClip());
			addChild(m_bt_down.getMovieClip());
			addChild(m_bt_left.getMovieClip());
			addChild(m_bt_right.getMovieClip());
			addChild(m_bt_up_left.getMovieClip());
			addChild(m_bt_up_right.getMovieClip());
			addChild(m_bt_down_left.getMovieClip());
			addChild(m_bt_down_right.getMovieClip());
		}

		private function onEnterFrame(e:Event):void {
			m_bt_up.updateMove();
			m_bt_down.updateMove();
			m_bt_left.updateMove();
			m_bt_right.updateMove();
			m_bt_up_left.updateMove();
			m_bt_up_right.updateMove();
			m_bt_down_left.updateMove();
			m_bt_down_right.updateMove();
			
			m_view.render();
		}
		
		private function keyDown(e:KeyboardEvent):void {
			switch(e.keyCode) {
				case Keyboard.TAB: nextImage(null);//m_changer.start(); break;
			}
		}
		
		private function keyUp(e:KeyboardEvent):void {

		}

		private function nextImage(e:MouseEvent):void {
			if (m_cur_num_img < 3) {
				m_cur_num_img++;
			}
			else {
				m_cur_num_img = 0;
			}

			switch (m_cur_num_img) {
				case 0: m_sphere.material = m_material_01; break;
				case 1: m_sphere.material = m_material_02; break;
				case 2: m_sphere.material = m_material_03; break;
			}
		}
	}
}
