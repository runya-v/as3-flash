package {
	import away3d.cameras.HoverCamera3D;
	
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.text.TextField;

	public class CameraController {
		private var m_cam:HoverCamera3D;
		private var m_scene:Sprite;
		
		private var m_bt_inc_zoom:MovieClip;
		private var m_bt_dec_zoom:MovieClip;
		private var m_zoom_text:TextField;

		private var m_bt_inc_focus:MovieClip;
		private var m_bt_inc_focus:MovieClip;
		private var m_focus_text:TextField;
		
		private var m_bt_inc_distance:MovieClip;
		private var m_bt_inc_distance:MovieClip;
		private var m_distance_text:TextField;
		
		public function CameraController(scene:Sprite, bt_inc:Class, bt_dec:Class, cam:HoverCamera3D) {
			m_cam = cam;
			m_scene = scene;
			
			var x1:int = 10;
			var x2:int = 30;
			var x3:int = 60;
			var y1:int = 10;
			var y2:int = 30;
			var y3:int = 60;
			
			m_bt_inc_zoom = new bt_inc();
			m_bt_inc_zoom.x = x1;
			m_bt_inc_zoom.y = y1;
			scene.addChild(m_bt_inc_zoom);
			
			m_bt_dec_zoom = new bt_dec();
			m_bt_dec_zoom.x = 30;
			m_bt_dec_zoom.y = y1;
			scene.addChild(m_bt_dec_zoom);
			
			m_zoom_text = new TextField();
			m_zoom_text.x = 60;
			m_zoom_text.y = y1;
			scene.addChild(m_zoom_text);
				
			m_bt_inc_focus = new bt_inc();
			m_bt_inc_focus.x = x1;
			m_bt_inc_focus.y = y2;
			scene.addChild(m_bt_inc_focus);
			
			m_bt_inc_focus = new bt_dec();
			m_bt_inc_focus.x = x2;
			m_bt_inc_focus.y = y2;
			scene.addChild(m_bt_inc_focus);
				
			m_focus_text = new TextField();
			m_focus_text.x = x3;
			m_focus_text.y = y2;
			scene.addChild(m_focus_text);
				
			m_bt_inc_distance = new bt_inc();
			m_bt_inc_distance.x = x1;
			m_bt_inc_distance.y = y3;
			scene.addChild(m_bt_inc_distance);
				
			m_bt_inc_distance = new bt_dec();
			m_bt_inc_distance.x = x2;
			m_bt_inc_distance.y = y3;
			scene.addChild(m_bt_inc_distance);
				
			m_distance_text = new TextField();
			m_distance_text.x = x3;
			m_distance_text.y = y3;
			scene.addChild(m_distance_text);

			m_bt_inc.addEventListener(MouseEvent.MOUSE_OVER, mouseOver);
			m_bt_inc.addEventListener(MouseEvent.MOUSE_OUT, mouseOut);
			
			m_bt_dec.addEventListener(MouseEvent.MOUSE_OVER, mouseOver);
			m_bt_dec.addEventListener(MouseEvent.MOUSE_OUT, mouseOut);
		}
		
		private function init_control(bt:MovieClip, x:int, y:int) {
			m_distance_text = new TextField();
			m_distance_text.x = x3;
			m_distance_text.y = y3;
			scene.addChild(m_distance_text);
 		}

		private function init_test(text:TextField, x:int, y:int) {
			text = new TextField();
			text.x = x3;
			text.y = y3;
			scene.addChild(text);
		}
	}
}