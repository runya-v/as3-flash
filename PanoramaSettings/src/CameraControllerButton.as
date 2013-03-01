package {
	import away3d.cameras.HoverCamera3D;
	
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	
	public class CameraControllerButton {
		private var m_cam:HoverCamera3D;
		private var m_scene:PanoramaSettings;
		
		private var m_bt_inc:MovieClip;
		private var m_bt_dec:MovieClip;
		private var m_text:TextField;
		private var m_value:int;
		private var m_str:String;
		private var m_is_inc:Boolean;
		private var m_is_dec:Boolean;
		
		public function CameraControllerButton(
			scene:PanoramaSettings, bt_inc:MovieClip, bt_dec:MovieClip, cam:HoverCamera3D, value:int, 
			scale:Number, x:int, y:int, shift:int, str:String) {
			m_is_inc = false;
			m_is_dec = false;
			m_cam = cam;
			m_scene = scene;
			m_value = value; 
			m_str = str;
			
			m_bt_inc = bt_inc;
			m_bt_inc.scaleX = scale;
			m_bt_inc.scaleY = scale;
			m_bt_inc.x = x;
			m_bt_inc.y = y;
			m_bt_inc.gotoAndStop(1);
			
			x += shift;
			
			m_bt_dec = bt_dec;
			m_bt_dec.scaleX = scale;
			m_bt_dec.scaleY = scale;
			m_bt_dec.x = x;
			m_bt_dec.y = y;
			m_bt_dec.gotoAndStop(1);

			x += shift;
			
			m_text = new TextField();
			m_text.x = x - 5;
			m_text.y = y - 15;
			m_text.scaleX = 1.5;
			m_text.scaleY = 1.5;
			m_text.textColor = 0xeeeeff;

			switch(m_value) {
				case 1: m_text.text = "zoom: " + m_cam.zoom; break;
				case 2: m_text.text = "focus: " + m_cam.focus; break;
				case 3: m_text.text = "fov: " + m_cam.fov; break;
				case 4: m_text.text = "distance: " + m_cam.distance; break;
				case 5: m_text.text = "sphere radius: " + m_scene.get_sphere_radius(); break;
			}
			
			m_bt_inc.addEventListener(MouseEvent.MOUSE_OVER, mouse_over_inc);
			m_bt_inc.addEventListener(MouseEvent.MOUSE_OUT, mouse_out_inc);
			m_bt_inc.addEventListener(MouseEvent.MOUSE_DOWN, mouse_down_inc);
			m_bt_inc.addEventListener(MouseEvent.MOUSE_UP, mouse_up_inc);
			
			m_bt_dec.addEventListener(MouseEvent.MOUSE_OVER, mouse_over_dec);
			m_bt_dec.addEventListener(MouseEvent.MOUSE_OUT, mouse_out_dec);
			m_bt_dec.addEventListener(MouseEvent.MOUSE_DOWN, mouse_down_dec);
			m_bt_dec.addEventListener(MouseEvent.MOUSE_UP, mouse_up_dec);

			scene.addChild(m_bt_inc);
			scene.addChild(m_bt_dec);
			scene.addChild(m_text);
		}
		
		public function update():void {
			if (m_is_inc) {
				switch(m_value) {
					case 1: 
						m_cam.zoom++;
						m_text.text = "zoom: " + m_cam.zoom;
						break;
					case 2: 
						m_cam.focus++;
						m_text.text = "focus: " + m_cam.focus;
						break;
					case 3: 
						m_cam.fov++;
						m_text.text = "fov: " + m_cam.fov;
						break;
					case 4: 
						m_cam.distance++;
						m_text.text = "distance: " + m_cam.distance; 
						break;
					case 5: 
						m_scene.set_sphere_radius(m_scene.get_sphere_radius() + 10);
						m_text.text = "sphere radius: " + m_scene.get_sphere_radius(); 
						break;
				}
			}
			else if (m_is_dec) {
				switch(m_value) {
					case 1: 
						m_cam.zoom--;
						m_text.text = "zoom: " + m_cam.zoom;
						break;
					case 2: 
						m_cam.focus--;
						m_text.text = "focus: " + m_cam.focus;
						break;
					case 3: 
						m_cam.fov--;
						m_text.text = "fov: " + m_cam.fov;
						break;
					case 4: 
						m_cam.distance--;
						m_text.text = "distance: " + m_cam.distance; 
						break;
					case 5: 
						m_scene.set_sphere_radius(m_scene.get_sphere_radius() - 10);
						m_text.text = "sphere radius: " + m_scene.get_sphere_radius(); 
						break;
				}
			}
		}
		
		private function mouse_over_inc(e:Event):void {
			
		}
		
		private function mouse_out_inc(e:Event):void {
		}

		private function mouse_down_inc(e:Event):void {
			m_bt_inc.gotoAndStop(2);
			m_is_inc = true;update();
		}

		private function mouse_up_inc(e:Event):void {
			m_bt_inc.gotoAndStop(1);
			m_is_inc = false;update();
		}

		private function mouse_over_dec(e:Event):void {
		}
		
		private function mouse_out_dec(e:Event):void {
		}

		private function mouse_down_dec(e:Event):void {
			m_bt_dec.gotoAndStop(2);
			m_is_dec = true;update();
		}

		private function mouse_up_dec(e:Event):void {
			m_bt_dec.gotoAndStop(1);
			m_is_dec = false;update();
		}
	}
}