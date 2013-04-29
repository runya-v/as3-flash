package {
	import away3d.cameras.Camera3D;
	import away3d.cameras.HoverCamera3D;
	import away3d.cameras.TargetCamera3D;
	import away3d.events.CameraEvent;
	import away3d.events.MouseEvent3D;
	
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.geom.Vector3D;
	import flash.ui.Mouse;
	import flash.ui.MouseCursor;
	import flash.utils.Timer;
	
	/**
	 * @author Velichko R.N.; email:rostislav.vel@gmail.com; (c) 12.2010
	 */
	public class CameraController extends EventDispatcher {
		[Embed(source='../../buttons.swf', symbol='bt_cam_move')]
		private var bt_cam_move:Class;

		[Embed(source='../../buttons.swf', symbol='cam_rotate')]
		private var CamRotate:Class;

		[Embed(source='../../buttons.swf', symbol='cam_aspect_plus')]
		private var CamAspectPlus:Class;
		
		[Embed(source='../../buttons.swf', symbol='cam_aspect_slider')]
		private var CamAspectSlider:Class;

		[Embed(source='../../buttons.swf', symbol='cam_aspect_minus')]
		private var CamAspectMinus:Class;

		public static const CAMERA_UPDATET:String = "CAMERA_UPDATET";
		public static const BUTTON_SHIFT_X:Number = 100;
		public static const BUTTON_SHIFT_Y:Number = 70;

        public static const AUTO_ROTATION_X:Number = 0.08;
        public static const AUTO_ROTATION_Y:Number = 0.1;
		public static const ROTATION_X:Number = 40;
		public static const ROTATION_Y:Number = 15;

		public static const ASPECT_SLIDE_HEIGHT:Number = 100;
		public static const ASPECT_SHIFT_Y:Number = 70;
		public static const MAX_ZOOM:Number = 18;
		public static const MIN_ZOOM:Number = 4;

		public var _cam:HoverCamera3D;

		private var m_back:MovieClip;
		private var m_bt_back:MovieClip;
		private var m_up:MovieClip;
		private var m_right:MovieClip;
		private var m_left:MovieClip;
		private var m_down:MovieClip;
		private var m_hand:MovieClip;
		private var m_rotate:MovieClip;
		
		private var m_aspect_back:MovieClip;
		private var m_aspect_slide:MovieClip;
		private var m_aspect_plus:MovieClip;
		private var m_aspect_minus:MovieClip;		
		private var m_aspect_slide_back:MovieClip;
		private var m_aspect_plus_back:MovieClip;
		private var m_aspect_minus_back:MovieClip;		

		private var old_norm_aspect_:Number;		
		
		private var m_is_init:Boolean = false;
		private var m_sprite:Restaurant;
		private var m_old_cam_Y:Number;
		private var m_old_cam_Z:Number;
		
		private var _is_rotate:Boolean = false;
		private var m_is_back_slide:Boolean = false;
		private var m_is_slide:Boolean = false;
		private var m_is_slide_plus:Boolean = false;
		private var m_is_slide_minus:Boolean = false;
        
        private var _auto_move_timer:Timer;
        private var _stop_move_timer:Timer;
        private var _is_stop_move_timer:Boolean = false;
		
		public function CameraController(sprite:Restaurant):void {
			m_sprite = sprite;
			_cam = new HoverCamera3D();
			_cam.zoom = 8;
			_cam.focus = 50;
			_cam.panAngle = 0;
			_cam.tiltAngle = 0;
			_cam.minTiltAngle = -90;
			_cam.distance = 0.5;
			_cam.hover(true);
			m_old_cam_Y = _cam.rotationY;
			_cam.zoom = (MAX_ZOOM - MIN_ZOOM) / 2;
            
            _auto_move_timer = new Timer(5, 1);
            _auto_move_timer.addEventListener(TimerEvent.TIMER_COMPLETE, function(e:TimerEvent):void {
                _cam.hover(false);
                
                if ( ! _is_stop_move_timer) {
                    if ( ! _is_rotate) {
                        //_cam.panAngle -= AUTO_ROTATION_X;
                    }
                }
                _auto_move_timer.start();
            });
            _auto_move_timer.start();
		}
		
		public function init(x:int, y:int):void {
			m_is_init = true;
			m_back = new CamRotate();
			m_bt_back = new CamRotate();
			m_up = new CamRotate();
			m_right = new CamRotate();
			m_left = new CamRotate();
			m_down = new CamRotate();
			m_hand = new CamRotate();
			m_rotate = new CamRotate();
			
			m_back.x    = x * 2 - BUTTON_SHIFT_X;
			m_back.y    = BUTTON_SHIFT_Y;
			m_bt_back.x = x * 2 - BUTTON_SHIFT_X;
			m_bt_back.y = BUTTON_SHIFT_Y;
			m_up.x      = x * 2 - BUTTON_SHIFT_X;
			m_up.y      = BUTTON_SHIFT_Y;
			m_right.x   = x * 2 - BUTTON_SHIFT_X;
			m_right.y   = BUTTON_SHIFT_Y;
			m_down.x    = x * 2 - BUTTON_SHIFT_X;
			m_down.y    = BUTTON_SHIFT_Y;
			m_left.x    = x * 2 - BUTTON_SHIFT_X;
			m_left.y    = BUTTON_SHIFT_Y;
			m_hand.x    = x * 2 - BUTTON_SHIFT_X;
			m_hand.y    = BUTTON_SHIFT_Y;
			m_rotate.x  = m_back.x;
			m_rotate.y  = m_back.y - m_back.height / 2;
			
			m_back.gotoAndStop(1);
			m_bt_back.gotoAndStop(20);
			m_up.gotoAndStop(4);
			m_right.gotoAndStop(7);
			m_down.gotoAndStop(10);
			m_left.gotoAndStop(13);
			m_hand.gotoAndStop(16);
			m_rotate.gotoAndStop(17);
			
			m_up.addEventListener(MouseEvent.MOUSE_OVER, on_up_over);
			m_up.addEventListener(MouseEvent.MOUSE_OUT, on_up_out);
			m_up.addEventListener(MouseEvent.MOUSE_UP, on_up_up);
			m_up.addEventListener(MouseEvent.MOUSE_DOWN, on_up_down);
			m_right.addEventListener(MouseEvent.MOUSE_OVER, on_right_over);
			m_right.addEventListener(MouseEvent.MOUSE_OUT, on_right_out);
			m_right.addEventListener(MouseEvent.MOUSE_UP, on_right_up);
			m_right.addEventListener(MouseEvent.MOUSE_DOWN, on_right_down);
			m_down.addEventListener(MouseEvent.MOUSE_OVER, on_down_over);
			m_down.addEventListener(MouseEvent.MOUSE_OUT, on_down_out);
			m_down.addEventListener(MouseEvent.MOUSE_UP, on_down_up);
			m_down.addEventListener(MouseEvent.MOUSE_DOWN, on_down_down);
			m_left.addEventListener(MouseEvent.MOUSE_OVER, on_left_over);
			m_left.addEventListener(MouseEvent.MOUSE_OUT, on_left_out);
			m_left.addEventListener(MouseEvent.MOUSE_UP, on_left_up);
			m_left.addEventListener(MouseEvent.MOUSE_DOWN, on_left_down);
			
			m_rotate.addEventListener(MouseEvent.MOUSE_OVER, on_rotate_over);
			m_rotate.addEventListener(MouseEvent.MOUSE_OUT, on_rotate_out);
			m_rotate.addEventListener(MouseEvent.MOUSE_DOWN, on_rotate_down);
			m_back.addEventListener(MouseEvent.MOUSE_OVER, on_rotate_over);
			m_back.addEventListener(MouseEvent.MOUSE_OUT, on_rotate_out);
			m_back.addEventListener(MouseEvent.MOUSE_DOWN, on_rotate_down);
			
			m_sprite.addEventListener(MouseEvent.MOUSE_UP, on_rotate_up);
			m_sprite.addEventListener(MouseEvent.MOUSE_MOVE, on_stage_mouse_move);
			
			m_sprite.addChild(m_back);
			m_sprite.addChild(m_bt_back);
			m_sprite.addChild(m_up);
			m_sprite.addChild(m_right);
			m_sprite.addChild(m_down);
			m_sprite.addChild(m_left);
			m_sprite.addChild(m_hand);
			m_sprite.addChild(m_rotate);
			
			m_aspect_back = new CamAspectSlider();
			m_aspect_slide = new CamAspectSlider();
			m_aspect_plus = new CamAspectPlus();
			m_aspect_minus = new CamAspectMinus();		
			m_aspect_slide_back = new CamAspectSlider();
			m_aspect_plus_back = new CamAspectPlus();
			m_aspect_minus_back = new CamAspectMinus();		

			m_aspect_back.gotoAndStop(4);
			m_aspect_slide.gotoAndStop(1);
			m_aspect_plus.gotoAndStop(1);
			m_aspect_minus.gotoAndStop(1);	
			m_aspect_slide_back.gotoAndStop(1);
			m_aspect_plus_back.gotoAndStop(1);
			m_aspect_minus_back.gotoAndStop(1);	
			
			m_aspect_back.x = x * 2 - BUTTON_SHIFT_X;
			m_aspect_back.y = BUTTON_SHIFT_Y + ASPECT_SHIFT_Y + ASPECT_SLIDE_HEIGHT / 2;
			m_aspect_back.scaleY = ASPECT_SLIDE_HEIGHT / 10;

			m_aspect_slide.x = x * 2 - BUTTON_SHIFT_X;
			m_aspect_slide.y = 
				BUTTON_SHIFT_Y + ASPECT_SHIFT_Y + 
				(ASPECT_SLIDE_HEIGHT - m_aspect_slide.height) / 2 +
				m_aspect_slide.height / 2;

			m_aspect_plus.x = x * 2 - BUTTON_SHIFT_X;
			m_aspect_plus.y = BUTTON_SHIFT_Y + ASPECT_SHIFT_Y; 

			m_aspect_minus.x = x * 2 - BUTTON_SHIFT_X;
			m_aspect_minus.y = BUTTON_SHIFT_Y + ASPECT_SHIFT_Y + ASPECT_SLIDE_HEIGHT; 

			m_aspect_slide_back.x = m_aspect_slide.x;
			m_aspect_slide_back.y = m_aspect_slide.y;
			
			m_aspect_plus_back.x = m_aspect_plus.x;
			m_aspect_plus_back.y = m_aspect_plus.y; 
			
			m_aspect_minus_back.x = m_aspect_minus.x;
			m_aspect_minus_back.y = m_aspect_minus.y; 
			
			m_aspect_back.addEventListener(MouseEvent.MOUSE_OVER, on_aspect_back_over);
			m_aspect_back.addEventListener(MouseEvent.MOUSE_OUT, on_aspect_back_out);
			m_aspect_back.addEventListener(MouseEvent.MOUSE_MOVE, on_aspect_back_move);
			m_aspect_back.addEventListener(MouseEvent.MOUSE_UP, on_aspect_back_up);
			m_aspect_back.addEventListener(MouseEvent.MOUSE_DOWN, on_aspect_back_down);

			m_aspect_slide.addEventListener(MouseEvent.MOUSE_OVER, on_aspect_slide_over);
			m_aspect_slide.addEventListener(MouseEvent.MOUSE_OUT, on_aspect_slide_out);
			m_aspect_slide.addEventListener(MouseEvent.MOUSE_MOVE, on_aspect_slide_move);
			m_aspect_slide.addEventListener(MouseEvent.MOUSE_UP, on_aspect_slide_up);
			m_aspect_slide.addEventListener(MouseEvent.MOUSE_DOWN, on_aspect_slide_down);

			m_aspect_plus.addEventListener(MouseEvent.MOUSE_OVER, on_aspect_plus_over);
			m_aspect_plus.addEventListener(MouseEvent.MOUSE_OUT, on_aspect_plus_out);
			m_aspect_plus.addEventListener(MouseEvent.MOUSE_UP, on_aspect_plus_up);
			m_aspect_plus.addEventListener(MouseEvent.MOUSE_DOWN, on_aspect_plus_down);

			m_aspect_minus.addEventListener(MouseEvent.MOUSE_OVER, on_aspect_minus_over);		
			m_aspect_minus.addEventListener(MouseEvent.MOUSE_OUT, on_aspect_minus_out);		
			m_aspect_minus.addEventListener(MouseEvent.MOUSE_UP, on_aspect_minus_up);		
			m_aspect_minus.addEventListener(MouseEvent.MOUSE_DOWN, on_aspect_minus_down);		

			m_sprite.addChild(m_aspect_back);
			m_sprite.addChild(m_aspect_slide_back);
			m_sprite.addChild(m_aspect_plus_back);
			m_sprite.addChild(m_aspect_minus_back);
			m_sprite.addChild(m_aspect_slide);
			m_sprite.addChild(m_aspect_plus);
			m_sprite.addChild(m_aspect_minus);
		}

		private function on_aspect_back_over(e:MouseEvent):void {
			Mouse.cursor = MouseCursor.BUTTON;	
			m_aspect_back.gotoAndStop(5);
		}
		
		private function on_aspect_back_out(e:MouseEvent):void {
			Mouse.cursor = MouseCursor.AUTO;	
			m_is_back_slide = false;
			m_aspect_back.gotoAndStop(4);
		}
		
		private function on_aspect_back_move(e:MouseEvent):void {
			if (m_is_slide) {
				var h:Number = BUTTON_SHIFT_Y + ASPECT_SLIDE_HEIGHT + ASPECT_SHIFT_Y;
				
				if ((h - m_aspect_slide.height) < e.stageY) {
					m_aspect_slide.y = (h - m_aspect_slide.height);
				}
				else if (e.stageY < (h + m_aspect_slide.height - ASPECT_SLIDE_HEIGHT)) {
					m_aspect_slide.y = (h + m_aspect_slide.height - ASPECT_SLIDE_HEIGHT);
				}
				else {
					m_aspect_slide.y = e.stageY; 
				}
				m_aspect_slide_back.y = m_aspect_slide.y;
			}
		}
		
		private function on_aspect_back_up(e:MouseEvent):void {
			m_is_back_slide = false;
		}
		
		private function on_aspect_back_down(e:MouseEvent):void {
			m_is_back_slide = true;

			var h:Number = BUTTON_SHIFT_Y + ASPECT_SLIDE_HEIGHT + ASPECT_SHIFT_Y;
			
			if ((h - m_aspect_slide.height) < e.stageY) {
				m_aspect_slide.y = (h - m_aspect_slide.height);
			}
			else if (e.stageY < (h + m_aspect_slide.height - ASPECT_SLIDE_HEIGHT)) {
				m_aspect_slide.y = (h + m_aspect_slide.height - ASPECT_SLIDE_HEIGHT);
			}
			else {
				m_aspect_slide.y = e.stageY; 
			}
			m_aspect_slide_back.y = m_aspect_slide.y;
		}

		private function on_aspect_slide_over(e:MouseEvent):void {
			Mouse.cursor = MouseCursor.HAND;
			m_aspect_slide.gotoAndStop(2);
		}

		private function on_aspect_slide_out(e:MouseEvent):void {
			Mouse.cursor = MouseCursor.AUTO;	
			m_aspect_slide.gotoAndStop(1);
			m_is_slide = false;
		}

		private function on_aspect_slide_move(e:MouseEvent):void {
			if (m_is_slide) {
				var h:Number = BUTTON_SHIFT_Y + ASPECT_SLIDE_HEIGHT + ASPECT_SHIFT_Y;
				
				if ((h - m_aspect_slide.height) < e.stageY) {
					m_aspect_slide.y = (h - m_aspect_slide.height);
				}
				else if (e.stageY < (h + m_aspect_slide.height - ASPECT_SLIDE_HEIGHT)) {
					m_aspect_slide.y = (h + m_aspect_slide.height - ASPECT_SLIDE_HEIGHT);
				}
				else {
					m_aspect_slide.y = e.stageY; 
				}
				m_aspect_slide_back.y = m_aspect_slide.y;
			}			
		}
		
		private function on_aspect_slide_up(e:MouseEvent):void {
			m_is_slide = false;
			m_aspect_slide.gotoAndStop(1);
		}

		private function on_aspect_slide_down(e:MouseEvent):void {
			m_is_slide = true;
			m_aspect_slide.gotoAndStop(3);
		}
		
		private function on_aspect_plus_over(e:MouseEvent):void {
			Mouse.cursor = MouseCursor.BUTTON;	
			m_aspect_plus.gotoAndStop(2);	
		}

		private function on_aspect_plus_out(e:MouseEvent):void {
			Mouse.cursor = MouseCursor.AUTO;	
			m_aspect_plus.gotoAndStop(1);	
		}

		private function on_aspect_plus_up(e:MouseEvent):void {
			m_aspect_plus.gotoAndStop(1);
			m_is_slide_plus = false;
		}

		private function on_aspect_plus_down(e:MouseEvent):void {
			m_aspect_plus.gotoAndStop(3);	
			m_is_slide_plus = true;
		}
		
		private function on_aspect_minus_over(e:MouseEvent):void {
			Mouse.cursor = MouseCursor.BUTTON;	
			m_aspect_minus.gotoAndStop(2);	
		}	

		private function on_aspect_minus_out(e:MouseEvent):void {
			Mouse.cursor = MouseCursor.AUTO;	
			m_aspect_minus.gotoAndStop(1);	
		}		

		private function on_aspect_minus_up(e:MouseEvent):void {
			m_aspect_minus.gotoAndStop(1);	
			m_is_slide_minus = false;
		}		
		
		private function on_aspect_minus_down(e:MouseEvent):void {
			m_aspect_minus.gotoAndStop(3);	
			m_is_slide_minus = true;
		}		

		private function on_up_over(e:MouseEvent):void {
			Mouse.cursor = MouseCursor.BUTTON;
			m_up.gotoAndStop(5);
		}
		
		private function on_right_over(e:MouseEvent):void {
			Mouse.cursor = MouseCursor.BUTTON;
			m_right.gotoAndStop(8);
		}
 		
		private function on_down_over(e:MouseEvent):void {
			Mouse.cursor = MouseCursor.BUTTON;
			m_down.gotoAndStop(11);
		}
		
		private function on_left_over(e:MouseEvent):void {
			Mouse.cursor = MouseCursor.BUTTON;
			m_left.gotoAndStop(14);
		}

		private function on_up_out(e:MouseEvent):void {
			Mouse.cursor = MouseCursor.AUTO;
			m_up.gotoAndStop(4);
		}
		
		private function on_right_out(e:MouseEvent):void {
			Mouse.cursor = MouseCursor.AUTO;
			m_right.gotoAndStop(7);
		}
		
		private function on_down_out(e:MouseEvent):void {
			Mouse.cursor = MouseCursor.AUTO;
			m_down.gotoAndStop(10);
		}
		
		private function on_left_out(e:MouseEvent):void {
			Mouse.cursor = MouseCursor.AUTO;
			m_left.gotoAndStop(13);
		}

		private function on_up_down(e:MouseEvent):void {
			m_up.gotoAndStop(6);
		}
		
		private function on_right_down(e:MouseEvent):void {
			m_right.gotoAndStop(9);
		}
		
		private function on_down_down(e:MouseEvent):void {
			m_down.gotoAndStop(12);
		}
		
		private function on_left_down(e:MouseEvent):void {
			m_left.gotoAndStop(15);
		}
		
		private function on_up_up(e:MouseEvent):void {
			_cam.moveDown(-ROTATION_Y);
			_cam.tiltAngle -= ROTATION_Y;
			m_up.gotoAndStop(4);
		}
		
		private function on_right_up(e:MouseEvent):void {
			if (m_sprite._panorama._curr_gop && m_sprite._panorama._curr_gop._need_vecs.length) {
				var max:Number = 360;
				var camv:Vector3D = new Vector3D(
					-Math.sin(_cam.rotationY / GoPoint.RADIAN),
					0,
					Math.cos(_cam.rotationY / GoPoint.RADIAN));
				camv.normalize();

				for each (var v:Vector3D in m_sprite._panorama._curr_gop._need_vecs) {
					var gov:Vector3D = new Vector3D(v.x, v.y, v.z);
					gov.normalize();
					var cross:Vector3D = gov.crossProduct(camv);
					cross.normalize();
					gov.normalize();
					var angle:Number = Math.acos(gov.dotProduct(camv)) * GoPoint.RADIAN * cross.y;

					if (angle < 0) {
						angle = 360 + angle;
					}

					if (5 < angle) {
						if (angle < max) {
							max = angle;
						}
					}
				}
				_cam.moveRight(max);
				_cam.panAngle += max;
			}
			else {
				_cam.moveRight(ROTATION_X);
				_cam.panAngle += ROTATION_X;
			}
			m_right.gotoAndStop(7);
		}
		
		private function on_down_up(e:MouseEvent):void {
			_cam.moveDown(ROTATION_Y);
			_cam.tiltAngle += ROTATION_Y;
			m_down.gotoAndStop(10);
		}
		
		private function on_left_up(e:MouseEvent):void {
			if (m_sprite._panorama._curr_gop && m_sprite._panorama._curr_gop._need_vecs.length) {
				var max:Number = 360;
				var camv:Vector3D = new Vector3D(
					-Math.sin(_cam.rotationY / GoPoint.RADIAN),
					0,
					Math.cos(_cam.rotationY / GoPoint.RADIAN));
				camv.normalize();
				
				for each (var v:Vector3D in m_sprite._panorama._curr_gop._need_vecs) {
					var gov:Vector3D = new Vector3D(v.x, v.y, v.z);
					gov.normalize();
					var cross:Vector3D = gov.crossProduct(camv);
					cross.normalize();
					gov.normalize();
					var angle:Number = Math.acos(gov.dotProduct(camv)) * GoPoint.RADIAN * -cross.y;
					
					if (angle < 0) {
						angle = 360 + angle;
					}					
					
					if (5 < angle) {
						if (angle < max) {
							max = angle;
						}
					}
				}
				_cam.moveRight(-max);
				_cam.panAngle -= max;
			}
			else {
				_cam.moveRight(-ROTATION_X);
				_cam.panAngle -= ROTATION_X;
			}
			m_left.gotoAndStop(13);
		}

		public function rotate():void {
			if ((m_old_cam_Y != _cam.rotationY) && m_back && m_rotate){
				m_old_cam_Y == _cam.rotationY;

				var v:Vector3D = new Vector3D(
					-Math.sin(_cam.rotationY / GoPoint.RADIAN), 
					Math.cos(_cam.rotationY / GoPoint.RADIAN));
				v.normalize();
				v.scaleBy(m_back.width / 2);
				
				m_rotate.x = v.x + m_back.x;
				m_rotate.y = v.y + m_back.y;
				m_rotate.rotationZ = _cam.rotationY;
				
				m_sprite._nmap.nmap_cam_.rotationZ = _cam.rotationY - 180; 
			}
		}

		private function on_rotate_over(e:MouseEvent):void {
			if ( ! _is_rotate) {
				m_rotate.gotoAndStop(18);
				m_back.gotoAndStop(2);	
				Mouse.cursor = MouseCursor.HAND;
			}
		}
		
		private function on_rotate_out(e:MouseEvent):void {
			if ( ! _is_rotate) {
				m_rotate.gotoAndStop(17);
				m_back.gotoAndStop(1);
				Mouse.cursor = MouseCursor.AUTO;
			}
		}
		
		private function on_rotate_up(e:MouseEvent):void {
			m_rotate.gotoAndStop(17);
			m_back.gotoAndStop(1);
			_is_rotate = false;
			Mouse.cursor = MouseCursor.AUTO;
		}
		
		private function on_rotate_down(e:MouseEvent):void {
			m_back.gotoAndStop(3);
			m_rotate.gotoAndStop(19);
			_is_rotate = true;
		}
		
		private function on_stage_mouse_move(e:MouseEvent):void {
			if (_is_rotate) {
				var v:Vector3D = new Vector3D(e.stageX - m_back.x, e.stageY - m_back.y); 
				v.normalize();
				var rot:Number = Math.acos(v.dotProduct(new Vector3D(0, 1))) * GoPoint.RADIAN;

				if (v.x < 0) {
					m_rotate.rotationZ = rot;
					_cam.panAngle = rot + 180;
				} else {
					m_rotate.rotationZ = -rot;
					_cam.panAngle = -rot + 180;
				}
				_cam.hover(true);
				v.scaleBy(m_back.width / 2);
				m_rotate.x = v.x + m_back.x;
				m_rotate.y = v.y + m_back.y;
			}
		}
		
		public function resize(w:Number, h:Number):void {
			if (m_is_init) {
				m_sprite.removeChild(m_back);
				m_sprite.removeChild(m_bt_back);
				m_sprite.removeChild(m_up);
				m_sprite.removeChild(m_right);
				m_sprite.removeChild(m_down);
				m_sprite.removeChild(m_left);
				m_sprite.removeChild(m_hand);
				m_sprite.removeChild(m_rotate);			
				
				m_sprite.removeChild(m_aspect_back);
				m_sprite.removeChild(m_aspect_slide);
				m_sprite.removeChild(m_aspect_plus);
				m_sprite.removeChild(m_aspect_minus);
				m_sprite.removeChild(m_aspect_slide_back);
				m_sprite.removeChild(m_aspect_plus_back);
				m_sprite.removeChild(m_aspect_minus_back);

				init(w / 2, h / 2);
			}
		}
		
		public function update():void {
			if (m_aspect_slide) {
				var h:Number = BUTTON_SHIFT_Y + ASPECT_SLIDE_HEIGHT + ASPECT_SHIFT_Y;

				if (m_is_slide_minus && (m_aspect_slide.y + 1) < (h - m_aspect_slide.height)) {
					++m_aspect_slide.y; 
				}
				
				if (m_is_slide_plus && (h - ASPECT_SLIDE_HEIGHT + m_aspect_slide.height) < (m_aspect_slide.y - 1)) {
					--m_aspect_slide.y; 
				}
				m_aspect_slide_back.y = m_aspect_slide.y;
				var shift_h:Number = m_aspect_slide.y - BUTTON_SHIFT_Y - ASPECT_SHIFT_Y; 
				_cam.zoom = MAX_ZOOM - ((MAX_ZOOM - MIN_ZOOM) *  shift_h) / (ASPECT_SLIDE_HEIGHT - m_aspect_slide.width);
				m_sprite._panorama.cameraZoom(_cam.zoom - MIN_ZOOM);
								
				var aspect:Number = 
					(m_aspect_slide.y - BUTTON_SHIFT_Y - ASPECT_SHIFT_Y - 
					m_aspect_plus.height / 2 - 2.5) / BUTTON_SHIFT_Y;
				
				if (old_norm_aspect_ != aspect) {
					old_norm_aspect_ != aspect;
					m_sprite._nmap.nmap_cam_.dravSectorMask(1 - aspect);
				}
			}
			rotate();
			_cam.hover();

			if (m_old_cam_Y != _cam.rotationY) {
				m_old_cam_Y == _cam.rotationY;
				this.dispatchEvent(new CameraEvent(CAMERA_UPDATET, _cam));
			}
		}
	}
}