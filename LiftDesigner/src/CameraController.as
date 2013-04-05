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
	
	import flashx.textLayout.tlf_internal;
	
	import org.osmf.events.TimeEvent;
	
	/**
	 * @author Velichko R.N.; email:rostislav.vel@gmail.com; (c) 12.2010
	 */
	public class CameraController extends EventDispatcher {
		[Embed(source='../../buttons.swf', symbol='bt_cam_move')]
		private var bt_ca_move:Class;

		[Embed(source='../../buttons.swf', symbol='cam_rotate')]
		private var CamRotate:Class;

		[Embed(source='../../buttons.swf', symbol='cam_aspect_plus')]
		private var CamAspectPlus:Class;
		
		[Embed(source='../../buttons.swf', symbol='cam_aspect_slider')]
		private var CamAspectSlider:Class;

		[Embed(source='../../buttons.swf', symbol='cam_aspect_minus')]
		private var CamAspectMinus:Class;

        public static const RADIAN:Number = 57.295779513;

		public static const CAMERA_UPDATET:String = "CAMERA_UPDATET";
		public static const BUTTON_SHIFT_X:Number = 100;
		public static const BUTTON_SHIFT_Y:Number = 70;

        public static const AUTO_ROTATION_X:Number = 0.15;
        public static const AUTO_ROTATION_Y:Number = 0.08;
		public static const ROTATION_X:Number = 40;
		public static const ROTATION_Y:Number = 15;

		public static const ASPECT_SLIDE_HEIGHT:Number = 100;
		public static const ASPECT_SHIFT_Y:Number = 70;
		public static const MAX_ZOOM:Number = 16;
		public static const MIN_ZOOM:Number = 3;

		public var _cam:HoverCamera3D;

        public var _dw:int = 0;
        public var _dh:int = 0;
        
		private var _back:MovieClip;
		private var _bt_back:MovieClip;
		private var _up:MovieClip;
		private var _right:MovieClip;
		private var _left:MovieClip;
		private var _down:MovieClip;
		private var _hand:MovieClip;
		private var _rotate:MovieClip;
		
		private var _aspect_back:MovieClip;
		private var _aspect_slide:MovieClip;
		private var _aspect_plus:MovieClip;
		private var _aspect_minus:MovieClip;		
		private var _aspect_slide_back:MovieClip;
		private var _aspect_plus_back:MovieClip;
		private var _aspect_minus_back:MovieClip;		

		private var _old_nor_aspect:Number;		
		
		private var _is_init:Boolean = false;
		private var _sprite:Sprite;
		private var _old_cam_Y:Number;
		private var _old_cam_Z:Number;
		
		private var _is_rotate:Boolean = false;
		private var _is_back_slide:Boolean = false;
		private var _is_slide:Boolean = false;
		private var _is_slide_plus:Boolean = false;
		private var _is_slide_minus:Boolean = false;
        
        private var _auto_move_timer:Timer;
        private var _stop_move_timer:Timer;
        private var _is_stop_move_timer:Boolean = false;
		
		public function CameraController(sprite:Sprite, camera:HoverCamera3D, dw:int = 0, dh:int = 0):void {
            _dw = dw;
            _dh = dh;
			_sprite = sprite;
			
            _cam = camera;
            _cam.hover(true);
			_cam.zoom         = 8;
			_cam.focus        = 50;
			_cam.panAngle     = 0;
			_cam.tiltAngle    = 3;
			_cam.minTiltAngle = -90;
			_cam.distance     = 0.5;
            
			_old_cam_Y = _cam.rotationY;
			_cam.zoom = (MAX_ZOOM - MIN_ZOOM) / 2;
            
            _stop_move_timer = new Timer(3000, 1);
            _stop_move_timer.addEventListener(TimerEvent.TIMER_COMPLETE, function(e:TimerEvent):void {
                _is_stop_move_timer = false;
            });
            
            _auto_move_timer = new Timer(5, 1);
            _auto_move_timer.addEventListener(TimerEvent.TIMER_COMPLETE, function(e:TimerEvent):void {
                _cam.hover(false);

                if ( ! _is_stop_move_timer) {
                    if (_cam.tiltAngle < 0) {
                        _cam.tiltAngle += AUTO_ROTATION_Y;
                    }
                    
                    if (_cam.tiltAngle > 0) {
                        _cam.tiltAngle -= AUTO_ROTATION_Y;
                    }
                    
                    if ( ! _is_rotate) {
                        _cam.panAngle -= AUTO_ROTATION_X;
                    }
                }
                _auto_move_timer.start();
            });
            _auto_move_timer.start();
		}
		
		public function init(x:int, y:int):void {
			_is_init = true;
			_back = new CamRotate();
			_bt_back = new CamRotate();
			_up = new CamRotate();
			_right = new CamRotate();
			_left = new CamRotate();
			_down = new CamRotate();
			_hand = new CamRotate();
			_rotate = new CamRotate();
			
			_back.x    = _dw + x * 2 - BUTTON_SHIFT_X;
			_back.y    = _dh + BUTTON_SHIFT_Y;
            _bt_back.x = _dw + x * 2 - BUTTON_SHIFT_X;
			_bt_back.y = _dh + BUTTON_SHIFT_Y;
            _up.x      = _dw + x * 2 - BUTTON_SHIFT_X;
			_up.y      = _dh + BUTTON_SHIFT_Y;
            _right.x   = _dw + x * 2 - BUTTON_SHIFT_X;
			_right.y   = _dh + BUTTON_SHIFT_Y;
            _down.x    = _dw + x * 2 - BUTTON_SHIFT_X;
			_down.y    = _dh + BUTTON_SHIFT_Y;
            _left.x    = _dw + x * 2 - BUTTON_SHIFT_X;
			_left.y    = _dh + BUTTON_SHIFT_Y;
            _hand.x    = _dw + x * 2 - BUTTON_SHIFT_X;
			_hand.y    = _dh + BUTTON_SHIFT_Y;
            _rotate.x  = _dw + _back.x;
			_rotate.y  = _dh + _back.y - _back.height / 2;
			
			_back.gotoAndStop(1);
			_bt_back.gotoAndStop(20);
			_up.gotoAndStop(4);
			_right.gotoAndStop(7);
			_down.gotoAndStop(10);
			_left.gotoAndStop(13);
			_hand.gotoAndStop(16);
			_rotate.gotoAndStop(17);
			
			_up.addEventListener(MouseEvent.MOUSE_OVER,    onUpOver);
			_up.addEventListener(MouseEvent.MOUSE_OUT,     onUpOut);
			_up.addEventListener(MouseEvent.MOUSE_UP,      onUpUp);
			_up.addEventListener(MouseEvent.MOUSE_DOWN,    onUpDown);
			_right.addEventListener(MouseEvent.MOUSE_OVER, onRightOver);
			_right.addEventListener(MouseEvent.MOUSE_OUT,  onRightOut);
			_right.addEventListener(MouseEvent.MOUSE_UP,   onRightUp);
			_right.addEventListener(MouseEvent.MOUSE_DOWN, onRightDown);
			_down.addEventListener(MouseEvent.MOUSE_OVER,  onDownOver);
			_down.addEventListener(MouseEvent.MOUSE_OUT,   onDownOut);
			_down.addEventListener(MouseEvent.MOUSE_UP,    onDownUp);
			_down.addEventListener(MouseEvent.MOUSE_DOWN,  onDownDown);
			_left.addEventListener(MouseEvent.MOUSE_OVER,  onLeftOver);
			_left.addEventListener(MouseEvent.MOUSE_OUT,   onLeftOut);
			_left.addEventListener(MouseEvent.MOUSE_UP,    onLeftUp);
			_left.addEventListener(MouseEvent.MOUSE_DOWN,  onLeftDown);
			
			_rotate.addEventListener(MouseEvent.MOUSE_OVER, onRotateOver);
			_rotate.addEventListener(MouseEvent.MOUSE_OUT,  onRotateOut);
			_rotate.addEventListener(MouseEvent.MOUSE_DOWN, onRotateDown);
			_back.addEventListener(MouseEvent.MOUSE_OVER,   onRotateOver);
			_back.addEventListener(MouseEvent.MOUSE_OUT,    onRotateOut);
			_back.addEventListener(MouseEvent.MOUSE_DOWN,   onRotateDown);
			
			_sprite.addEventListener(MouseEvent.MOUSE_UP,   onRotateUp);
			_sprite.addEventListener(MouseEvent.MOUSE_MOVE, onStageMouseMove);
			
			_sprite.addChild(_back);
			_sprite.addChild(_bt_back);
			_sprite.addChild(_up);
			_sprite.addChild(_right);
			_sprite.addChild(_down);
			_sprite.addChild(_left);
			_sprite.addChild(_hand);
			_sprite.addChild(_rotate);
			
			_aspect_back       = new CamAspectSlider();
			_aspect_slide      = new CamAspectSlider();
			_aspect_plus       = new CamAspectPlus();
			_aspect_minus      = new CamAspectMinus();		
			_aspect_slide_back = new CamAspectSlider();
			_aspect_plus_back  = new CamAspectPlus();
			_aspect_minus_back = new CamAspectMinus();		

			_aspect_back.gotoAndStop(4);
			_aspect_slide.gotoAndStop(1);
			_aspect_plus.gotoAndStop(1);
			_aspect_minus.gotoAndStop(1);	
			_aspect_slide_back.gotoAndStop(1);
			_aspect_plus_back.gotoAndStop(1);
			_aspect_minus_back.gotoAndStop(1);	
			
			_aspect_back.x = x * 2 - BUTTON_SHIFT_X;
			_aspect_back.y = BUTTON_SHIFT_Y + ASPECT_SHIFT_Y + ASPECT_SLIDE_HEIGHT / 2;
			_aspect_back.scaleY = ASPECT_SLIDE_HEIGHT / 10;

			_aspect_slide.x = x * 2 - BUTTON_SHIFT_X;
			_aspect_slide.y = BUTTON_SHIFT_Y + ASPECT_SHIFT_Y + (ASPECT_SLIDE_HEIGHT - _aspect_slide.height) / 2 + _aspect_slide.height / 2;

			_aspect_plus.x = x * 2 - BUTTON_SHIFT_X;
			_aspect_plus.y = BUTTON_SHIFT_Y + ASPECT_SHIFT_Y; 

			_aspect_minus.x = x * 2 - BUTTON_SHIFT_X;
			_aspect_minus.y = BUTTON_SHIFT_Y + ASPECT_SHIFT_Y + ASPECT_SLIDE_HEIGHT; 

			_aspect_slide_back.x = _aspect_slide.x;
			_aspect_slide_back.y = _aspect_slide.y;
			
			_aspect_plus_back.x = _aspect_plus.x;
			_aspect_plus_back.y = _aspect_plus.y; 
			
			_aspect_minus_back.x = _aspect_minus.x;
			_aspect_minus_back.y = _aspect_minus.y; 
			
			_aspect_back.addEventListener(MouseEvent.MOUSE_OVER, onAspectBackOver);
			_aspect_back.addEventListener(MouseEvent.MOUSE_OUT,  onAspectBackOut);
			_aspect_back.addEventListener(MouseEvent.MOUSE_MOVE, onAspectBackMove);
			_aspect_back.addEventListener(MouseEvent.MOUSE_UP,   onAspectBackUp);
			_aspect_back.addEventListener(MouseEvent.MOUSE_DOWN, onAspectBackDown);

			_aspect_slide.addEventListener(MouseEvent.MOUSE_OVER, onAspectSlideOver);
			_aspect_slide.addEventListener(MouseEvent.MOUSE_OUT,  onAspectSlideOut);
			_aspect_slide.addEventListener(MouseEvent.MOUSE_MOVE, onAspectSlideMove);
			_aspect_slide.addEventListener(MouseEvent.MOUSE_UP,   onAspectSlideUp);
			_aspect_slide.addEventListener(MouseEvent.MOUSE_DOWN, onAspectSlideDown);

			_aspect_plus.addEventListener(MouseEvent.MOUSE_OVER, onAspectPlusOver);
			_aspect_plus.addEventListener(MouseEvent.MOUSE_OUT,  onAspectPlusOut);
			_aspect_plus.addEventListener(MouseEvent.MOUSE_UP,   onAspectPlusUp);
			_aspect_plus.addEventListener(MouseEvent.MOUSE_DOWN, onAspectPlusDown);

			_aspect_minus.addEventListener(MouseEvent.MOUSE_OVER, onAspectMinusOver);		
			_aspect_minus.addEventListener(MouseEvent.MOUSE_OUT,  onAspectMinusOut);		
			_aspect_minus.addEventListener(MouseEvent.MOUSE_UP,   onAspectMinusUp);		
			_aspect_minus.addEventListener(MouseEvent.MOUSE_DOWN, onAspectMinusDown);		

			_sprite.addChild(_aspect_back);
			_sprite.addChild(_aspect_slide_back);
			_sprite.addChild(_aspect_plus_back);
			_sprite.addChild(_aspect_minus_back);
			_sprite.addChild(_aspect_slide);
			_sprite.addChild(_aspect_plus);
			_sprite.addChild(_aspect_minus);
		}

		private function onAspectBackOver(e:MouseEvent):void {
			Mouse.cursor = MouseCursor.BUTTON;	
			_aspect_back.gotoAndStop(5);
		}
		
		private function onAspectBackOut(e:MouseEvent):void {
			Mouse.cursor = MouseCursor.AUTO;	
			_is_back_slide = false;
			_aspect_back.gotoAndStop(4);
		}
		
		private function onAspectBackMove(e:MouseEvent):void {
			if (_is_slide) {
				var h:Number = BUTTON_SHIFT_Y + ASPECT_SLIDE_HEIGHT + ASPECT_SHIFT_Y;
				
				if ((h - _aspect_slide.height) < e.stageY) {
					_aspect_slide.y = (h - _aspect_slide.height);
				}
				else if (e.stageY < (h + _aspect_slide.height - ASPECT_SLIDE_HEIGHT)) {
					_aspect_slide.y = (h + _aspect_slide.height - ASPECT_SLIDE_HEIGHT);
				}
				else {
					_aspect_slide.y = e.stageY; 
				}
				_aspect_slide_back.y = _aspect_slide.y;
			}
            update();
		}
		
		private function onAspectBackUp(e:MouseEvent):void {
			_is_back_slide = false;
		}
		
		private function onAspectBackDown(e:MouseEvent):void {
			_is_back_slide = true;

			var h:Number = BUTTON_SHIFT_Y + ASPECT_SLIDE_HEIGHT + ASPECT_SHIFT_Y;
			
			if ((h - _aspect_slide.height) < e.stageY) {
				_aspect_slide.y = (h - _aspect_slide.height);
			}
			else if (e.stageY < (h + _aspect_slide.height - ASPECT_SLIDE_HEIGHT)) {
				_aspect_slide.y = (h + _aspect_slide.height - ASPECT_SLIDE_HEIGHT);
			}
			else {
				_aspect_slide.y = e.stageY; 
			}
			_aspect_slide_back.y = _aspect_slide.y;
		}

		private function onAspectSlideOver(e:MouseEvent):void {
			Mouse.cursor = MouseCursor.HAND;
			_aspect_slide.gotoAndStop(2);
		}

		private function onAspectSlideOut(e:MouseEvent):void {
			Mouse.cursor = MouseCursor.AUTO;	
			_aspect_slide.gotoAndStop(1);
			_is_slide = false;
		}

		private function onAspectSlideMove(e:MouseEvent):void {
			if (_is_slide) {
				var h:Number = BUTTON_SHIFT_Y + ASPECT_SLIDE_HEIGHT + ASPECT_SHIFT_Y;
				
				if ((h - _aspect_slide.height) < e.stageY) {
					_aspect_slide.y = (h - _aspect_slide.height);
				}
				else if (e.stageY < (h + _aspect_slide.height - ASPECT_SLIDE_HEIGHT)) {
					_aspect_slide.y = (h + _aspect_slide.height - ASPECT_SLIDE_HEIGHT);
				}
				else {
					_aspect_slide.y = e.stageY; 
				}
				_aspect_slide_back.y = _aspect_slide.y;
			}			
            update();
		}
		
		private function onAspectSlideUp(e:MouseEvent):void {
			_is_slide = false;
			_aspect_slide.gotoAndStop(1);
		}

		private function onAspectSlideDown(e:MouseEvent):void {
			_is_slide = true;
			_aspect_slide.gotoAndStop(3);
		}
		
		private function onAspectPlusOver(e:MouseEvent):void {
			Mouse.cursor = MouseCursor.BUTTON;	
			_aspect_plus.gotoAndStop(2);	
		}

		private function onAspectPlusOut(e:MouseEvent):void {
			Mouse.cursor = MouseCursor.AUTO;	
			_aspect_plus.gotoAndStop(1);	
		}

		private function onAspectPlusUp(e:MouseEvent):void {
			_aspect_plus.gotoAndStop(1);
			_is_slide_plus = false;
		}

		private function onAspectPlusDown(e:MouseEvent):void {
			_aspect_plus.gotoAndStop(3);	
			_is_slide_plus = true;
		}
		
		private function onAspectMinusOver(e:MouseEvent):void {
			Mouse.cursor = MouseCursor.BUTTON;	
			_aspect_minus.gotoAndStop(2);	
		}	

		private function onAspectMinusOut(e:MouseEvent):void {
			Mouse.cursor = MouseCursor.AUTO;	
			_aspect_minus.gotoAndStop(1);	
		}		

		private function onAspectMinusUp(e:MouseEvent):void {
			_aspect_minus.gotoAndStop(1);	
			_is_slide_minus = false;
		}		
		
		private function onAspectMinusDown(e:MouseEvent):void {
			_aspect_minus.gotoAndStop(3);	
			_is_slide_minus = true;
		}		

		private function onUpOver(e:MouseEvent):void {
			Mouse.cursor = MouseCursor.BUTTON;
			_up.gotoAndStop(5);
		}
		
		private function onRightOver(e:MouseEvent):void {
			Mouse.cursor = MouseCursor.BUTTON;
			_right.gotoAndStop(8);
		}
 		
		private function onDownOver(e:MouseEvent):void {
			Mouse.cursor = MouseCursor.BUTTON;
			_down.gotoAndStop(11);
		}
		
		private function onLeftOver(e:MouseEvent):void {
			Mouse.cursor = MouseCursor.BUTTON;
			_left.gotoAndStop(14);
		}

		private function onUpOut(e:MouseEvent):void {
			Mouse.cursor = MouseCursor.AUTO;
			_up.gotoAndStop(4);
		}
		
		private function onRightOut(e:MouseEvent):void {
			Mouse.cursor = MouseCursor.AUTO;
			_right.gotoAndStop(7);
		}
		
		private function onDownOut(e:MouseEvent):void {
			Mouse.cursor = MouseCursor.AUTO;
			_down.gotoAndStop(10);
		}
		
		private function onLeftOut(e:MouseEvent):void {
			Mouse.cursor = MouseCursor.AUTO;
			_left.gotoAndStop(13);
		}

		private function onUpDown(e:MouseEvent):void {
			_up.gotoAndStop(6);
		}
		
		private function onRightDown(e:MouseEvent):void {
			_right.gotoAndStop(9);
		}
		
		private function onDownDown(e:MouseEvent):void {
			_down.gotoAndStop(12);
		}
		
		private function onLeftDown(e:MouseEvent):void {
			_left.gotoAndStop(15);
		}
		
		private function onUpUp(e:MouseEvent):void {
            _stop_move_timer.start();
            _is_stop_move_timer = true;
            _cam.hover(true);
			_cam.moveDown(-ROTATION_Y);
			_cam.tiltAngle -= ROTATION_Y;
			_up.gotoAndStop(4);
		}
		
		private function onRightUp(e:MouseEvent):void {
            _stop_move_timer.start();
            _is_stop_move_timer = true;
            _cam.hover(true);
			_cam.moveRight(ROTATION_X);
			_cam.panAngle += ROTATION_X;
			_right.gotoAndStop(7);
		}
		
		private function onDownUp(e:MouseEvent):void {
            _stop_move_timer.start();
            _is_stop_move_timer = true;
            _cam.hover(true);
			_cam.moveDown(ROTATION_Y);
			_cam.tiltAngle += ROTATION_Y;
			_down.gotoAndStop(10);
		}
		
		private function onLeftUp(e:MouseEvent):void {
            _stop_move_timer.start();
            _is_stop_move_timer = true;
            _cam.hover(true);
			_cam.moveRight(-ROTATION_X);
			_cam.panAngle -= ROTATION_X;
			_left.gotoAndStop(13);
		}

		public function rotate():void {
			if ((_old_cam_Y != _cam.rotationY) && _back && _rotate){
				_old_cam_Y == _cam.rotationY;

				var v:Vector3D = new Vector3D(-Math.sin(_cam.rotationY / RADIAN), Math.cos(_cam.rotationY / RADIAN));
				v.normalize();
				v.scaleBy(_back.width / 2);
				
				_rotate.x = v.x + _back.x;
				_rotate.y = v.y + _back.y;
				_rotate.rotationZ = _cam.rotationY;
			}
		}

		private function onRotateOver(e:MouseEvent):void {
			if ( ! _is_rotate) {
				_rotate.gotoAndStop(18);
				_back.gotoAndStop(2);	
				Mouse.cursor = MouseCursor.HAND;
			}
		}
		
		private function onRotateOut(e:MouseEvent):void {
			if ( ! _is_rotate) {
				_rotate.gotoAndStop(17);
				_back.gotoAndStop(1);
				Mouse.cursor = MouseCursor.AUTO;
			}
		}
		
		private function onRotateUp(e:MouseEvent):void {
			_rotate.gotoAndStop(17);
			_back.gotoAndStop(1);
			_is_rotate = false;
			Mouse.cursor = MouseCursor.AUTO;
		}
		
		private function onRotateDown(e:MouseEvent):void {
			_back.gotoAndStop(3);
			_rotate.gotoAndStop(19);
			_is_rotate = true;
		}
		
		private function onStageMouseMove(e:MouseEvent):void {
			if (_is_rotate) {
				var v:Vector3D = new Vector3D(e.stageX - _back.x, e.stageY - _back.y); 
				v.normalize();
				var rot:Number = Math.acos(v.dotProduct(new Vector3D(0, 1))) * RADIAN;

				if (v.x < 0) {
					_rotate.rotationZ = rot;
					_cam.panAngle = rot + 180;
				} else {
					_rotate.rotationZ = -rot;
					_cam.panAngle = -rot + 180;
				}
				_cam.hover(true);
				v.scaleBy(_back.width / 2);
				_rotate.x = v.x + _back.x;
				_rotate.y = v.y + _back.y;
			}
		}
		
		public function resize(w:Number, h:Number):void {
			if (_is_init) {
				_sprite.removeChild(_back);
				_sprite.removeChild(_bt_back);
				_sprite.removeChild(_up);
				_sprite.removeChild(_right);
				_sprite.removeChild(_down);
				_sprite.removeChild(_left);
				_sprite.removeChild(_hand);
				_sprite.removeChild(_rotate);			
				
				_sprite.removeChild(_aspect_back);
				_sprite.removeChild(_aspect_slide);
				_sprite.removeChild(_aspect_plus);
				_sprite.removeChild(_aspect_minus);
				_sprite.removeChild(_aspect_slide_back);
				_sprite.removeChild(_aspect_plus_back);
				_sprite.removeChild(_aspect_minus_back);

				init(w / 2, h / 2);
			}
		}
		
		public function update():void {
			if (_aspect_slide) {
				var h:Number = BUTTON_SHIFT_Y + ASPECT_SLIDE_HEIGHT + ASPECT_SHIFT_Y;

				if (_is_slide_minus && (_aspect_slide.y + 1) < (h - _aspect_slide.height)) {
					++_aspect_slide.y; 
				}
				
				if (_is_slide_plus && (h - ASPECT_SLIDE_HEIGHT + _aspect_slide.height) < (_dh + _aspect_slide.y - 1)) {
					--_aspect_slide.y; 
				}
				_aspect_slide_back.y = _aspect_slide.y;
				var shift_h:Number = _aspect_slide.y - BUTTON_SHIFT_Y - ASPECT_SHIFT_Y; 
				_cam.zoom = MAX_ZOOM - ((MAX_ZOOM - MIN_ZOOM) *  shift_h) / (ASPECT_SLIDE_HEIGHT - _aspect_slide.width);
			}
			rotate();
			_cam.hover();

			if (_old_cam_Y != _cam.rotationY) {
				_old_cam_Y == _cam.rotationY;
				this.dispatchEvent(new CameraEvent(CAMERA_UPDATET, _cam));
			}
		}
	}
}