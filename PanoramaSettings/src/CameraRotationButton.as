package {
	import away3d.cameras.HoverCamera3D;
	
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;

	public class CameraRotationButton {
		private var m_scene:Sprite;
		private var m_cam:HoverCamera3D;
		private var m_scale:Number; 
		private var m_rot_x:Number;
		private var m_rot_y:Number;
		private var m_is_move:Boolean;
		
		private var m_bt:MovieClip;
		
		public function CameraRotationButton(
			scene:Sprite, bt:MovieClip, cam:HoverCamera3D, 
			scale:Number, pos_x:Number, pos_y:Number, rot_x:Number, rot_y:Number) {
			
			m_is_move = false;
				
			m_scene = scene;
			m_cam = cam;
			m_scale = scale; 
			
			m_bt = bt;
		
			m_bt.gotoAndStop(1);
			m_bt.scaleX = scale;
			m_bt.scaleY = scale;
			m_bt.x = pos_x;
			m_bt.y = pos_y;
			m_rot_x = rot_x;
			m_rot_y = rot_y;

			if (m_rot_x && m_rot_y) {
				m_rot_x /= 2;
				m_rot_y /= 2;
			}

			m_bt.addEventListener(MouseEvent.MOUSE_OVER, mouseOver);
			m_bt.addEventListener(MouseEvent.MOUSE_OUT, mouseOut);
			
			m_scene.addChild(bt);
		}
		
		private function mouseOver(e:Event):void {
			m_bt.gotoAndStop(2);
			m_is_move = true;
		}

		private function mouseOut(e:Event):void {
			m_bt.gotoAndStop(1);
			m_is_move = false;
		}

		public function getMovieClip():MovieClip {
			return m_bt;
		}
		
		public function updateMove():void {
			if (m_is_move) {
				if (m_rot_x < 0) {
					m_cam.moveRight(-m_rot_x);
					m_cam.panAngle += m_rot_x;
				}
				
				if (m_rot_x > 0) {
					m_cam.moveLeft(m_rot_x);
					m_cam.panAngle += m_rot_x;
				}
				
				if (m_rot_y < 0) {
					m_cam.moveDown(-m_rot_y);
					m_cam.tiltAngle += m_rot_y
				}
				
				if (m_rot_y > 0) {
					m_cam.moveUp(m_rot_y);
					m_cam.tiltAngle += m_rot_y;
				}
			}
		}
	}
}