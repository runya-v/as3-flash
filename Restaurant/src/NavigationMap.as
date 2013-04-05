package {
	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.EventDispatcher;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.ui.Mouse;
	import flash.ui.MouseCursor;
	import flash.utils.Timer;
	
	import org.osmf.events.TimeEvent;
	
	/**
	 * @author Velichko R.N.; email:rostislav.vel@gmail.com; (c) 6.2011
	 */
	public class NavigationMap extends Sprite {
		[Embed(source='../../preloader.swf', symbol='tmp_image')]
		private var TmpImage:Class;

		[Embed(source='../../buttons.swf', symbol='map_pview')]
		private var PView:Class;
		
		public static const SCALE:int = 20;
		private static const WIDTH:int = 350;
		private static const HEIGHT:int = 300;
		private static const BORDER:int = 20;
		private static const HEIGHT_POS:int = BORDER;
		private static const OPEN_POS:int = 0;
		private static const CLOSE_POS:int = BORDER - WIDTH;

		private var parent_:Restaurant;
		private var rect_:Sprite = new Sprite;
		private var map_:Sprite = new Sprite;
		
		public var directin_:Sprite;
		
		private var is_open_:Boolean = false;
		private var is_move_:Boolean = false;
		private var timer_:Timer = new Timer(5, 1);

		private var bt_open_:MovieClip = new PView();

		public var nmap_cam_:NMapCamera = new NMapCamera();
		
		public function NavigationMap(parent:Restaurant) {
			parent_ = parent;
			this.x = CLOSE_POS;
			this.y = HEIGHT_POS;
			
			var back:MovieClip = new TmpImage();
			back.gotoAndStop(1);
			back.scaleX = WIDTH / 10;
			back.scaleY = HEIGHT / 10;
			
			rect_.addChild(back);
			
			bt_open_.gotoAndStop(1);
			bt_open_.x = WIDTH - bt_open_.width / 2 - 3;
			bt_open_.y = HEIGHT / 2;// + bt_open_.height / 2;
			
			rect_.addEventListener(MouseEvent.MOUSE_OVER, function (e:MouseEvent):void {
				Mouse.cursor = MouseCursor.BUTTON;
				
				if ( ! is_open_) {
					bt_open_.gotoAndStop(2);
				}
				else {
					bt_open_.gotoAndStop(4);
				}
			})

			rect_.addEventListener(MouseEvent.MOUSE_OUT, function (e:MouseEvent):void {
				Mouse.cursor = MouseCursor.AUTO;
				
				if ( ! is_open_) {
					bt_open_.gotoAndStop(1);
				}
				else {
					bt_open_.gotoAndStop(3);
				}
			})

			rect_.addEventListener(MouseEvent.MOUSE_DOWN, function (e:MouseEvent):void {
				{
					if ( ! is_move_) {
						is_move_ = true;
						timer_.start();
	 					timer_.addEventListener(TimerEvent.TIMER_COMPLETE, onMove);
					}
					else {
						Mouse.cursor = MouseCursor.BUTTON;
						
						if ( ! is_open_) {
							bt_open_.gotoAndStop(2);
						}
						else {
							bt_open_.gotoAndStop(4);
						}
					}
				}
			})
			rect_.addChild(bt_open_);
		 
			var mask:Sprite = new Sprite;
			mask.graphics.beginFill(0x000000);
			mask.graphics.drawRect(0, 0, WIDTH - BORDER, HEIGHT);
			mask.graphics.endFill();
			map_.mask = DisplayObject(mask);

			rect_.addChild(mask);
			nmap_cam_.x = (WIDTH - BORDER) / 2;
			nmap_cam_.y = (HEIGHT) / 2;
			map_.addChild(nmap_cam_);
			rect_.addChild(map_);
		
			this.addChild(rect_);
		}
		
		public function moveToPos(id:int):void {
			var set_cam:Camera = parent_._cameras[id];
			var ix:Number;
			var iy:Number;
			var iw:Number = (WIDTH - BORDER) / 2;
			var ih:Number = HEIGHT / 2;
			
			for each (var cam:Camera in parent_._cameras) {
				ix = (cam._x - set_cam._x) + iw;
				iy = (cam._y - set_cam._y) + ih;
				cam.x = ix;
				cam.y = iy;
			}

			for each (var transition:Transition in parent_._transitions) {
				transition.draw();
			}
		}

		public function setCameraPos(id:int, x:Number, y:Number):void {
			var cam:Camera = parent_._cameras[id];
			cam._x = x * SCALE;
			cam._y = y * SCALE;
			cam.draw();
		}
		
		public function addCamera(id:int):void {
			var cam:Camera = parent_._cameras[id];
			map_.addChildAt(cam, 0);
		}

		public function addTransition(id:int, from:int, to:int):void {
			parent_.addTransition(id, from, to);
			var trans:Transition = parent_._transitions[id];
			var from_cam:Camera = parent_._cameras[from];
			var to_cam:Camera = parent_._cameras[to];
			trans.from_id_ = from;
			trans.to_id_ = to;
			trans.draw();

			from_cam._transitions[id] = trans;
			to_cam._transitions[id] = trans;
			
			map_.addChild(trans);
		}

		private function onMove(e:TimerEvent):void {
			var d:Number;
			
			if ( ! is_open_) {
				if (this.x < (OPEN_POS - 1)) {
					d = (OPEN_POS - this.x) * 0.3; 
					this.x += d;
				}
				else {
					bt_open_.gotoAndStop(3);
					this.x = OPEN_POS;
					is_open_ = true;
					is_move_ = false;
				}
			}
			else {
				if ((CLOSE_POS + 1) < this.x) {
					d = -(CLOSE_POS - this.x) * 0.3; 
					this.x -= d;
				}
				else {
					bt_open_.gotoAndStop(1);
					this.x = CLOSE_POS;
					is_open_ = false;
					is_move_ = false;
				}
			}

			if (is_move_) {
				timer_.start();
			}
		}		
	}
}