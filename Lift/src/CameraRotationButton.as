package {
	import away3d.cameras.HoverCamera3D;
	import flash.system.System;
	import flash.utils.Timer;
	import flash.events.TimerEvent;
	
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;

	/**
	 * @author Velichko R.N.; email:rostislav.vel@gmail.com; (c) 12.2010
	 */
	public class CameraRotationButton {
		private static const m_dtime:Number = 10;
			
		private var m_scale:Number; 
		private var m_rot_x:Number;
		private var m_rot_y:Number;
		private var m_is_move:Boolean;
		private var m_timer:Timer;
		
		private var m_bt:MovieClip;
		private var m_cam:HoverCamera3D;
		
		
		public function CameraRotationButton(
			sprite:Sprite, bt:MovieClip, cam:HoverCamera3D, 
			scale:Number, pos_x:Number, pos_y:Number, rot_x:Number, rot_y:Number) {
			m_is_move = false;
				
			m_cam = cam;
			m_bt = bt;
			m_scale = scale; 
		
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
			sprite.addChild(bt);
			
			m_timer = new Timer(m_dtime, 1);
			m_timer.addEventListener(TimerEvent.TIMER, on_update_move);
			m_timer.addEventListener(TimerEvent.TIMER_COMPLETE, on_restart_timer);
		}
		
		private function mouseOver(e:Event):void {
			m_is_move = true;
			m_bt.gotoAndStop(2);
			m_timer.start();
		}

		private function mouseOut(e:Event):void {
			m_is_move = false;
			m_bt.gotoAndStop(1);
			m_timer.stop();
		}

		public function getMovieClip():MovieClip {
			return m_bt;
		}
		
		public function on_restart_timer(e:TimerEvent):void {
			if (m_is_move) {
				m_timer.start();
			}
		}
			
		public function on_update_move(e:TimerEvent):void {
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