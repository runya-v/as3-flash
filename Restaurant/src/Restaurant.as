package {
	import away3d.containers.View3D;
	import away3d.core.render.Renderer;
	import away3d.events.CameraEvent;
	
	import flash.display.Bitmap;
	import flash.display.Loader;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.events.SecurityErrorEvent;
	import flash.events.TimerEvent;
	import flash.geom.Vector3D;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.system.Security;
	import flash.system.SecurityPanel;
	import flash.text.TextField;
	import flash.text.engine.TabAlignment;
	import flash.ui.Keyboard;
	import flash.ui.Mouse;
	import flash.ui.MouseCursor;
	import flash.utils.Timer;
	
	/**
	 * @author Velichko R.N.; email:rostislav.vel@gmail.com; (c) 12.2010
	 */
	//[SWF(width="920", height="500", frameRate="30", backgroundColor="#000000")]
	public class Restaurant extends Sprite {
		[Embed(source='../../preloader.swf', symbol='loader')]
		private var preloader:Class;

		public static const VERSION:String = "1.3";
		
        public static const CROSS_DATA:String = "http://vi-ex.ru/crossdomain.xml";
        public static const CROSS_IMG:String  = "http://static.vi-ex.ru/crossdomain.xml";
		public static const URL:String        = "http://vi-ex.ru/restaurant/rs-api/restaurant/1";
        public static const URL_IMAGES:String = "http://static.vi-ex.ru/crm";

        //public static const CROSS_DATA:String = "192.168.0.100:8888/crossdomain.xml";
        //public static const CROSS_IMG:String  = "192.168.0.100:8888/localhost/crossdomain.xml";
        //public static const URL:String        = "192.168.0.100:8888/localhost/projects/restaurant.xml";
        //public static const URL_IMAGES:String = "192.168.0.100:8888/localhost/images";
		
        //public static const SESSION_ID:String = "1";
		public static const WIDTH:int = 920;
		public static const HEIGHT:int = 500;

		private static const INFO_X:int = 10;
		private static const INFO_Y:int = 10;
		private static const INFO_W:int = 200;
		private static const INFO_SCALE:int = 3;
		private static const INFO_COLOR:uint = 0xeeeeff;
		
		public var m_width:int = 0; //WIDTH;
		public var m_height:int = 0; //HEIGHT;
		public var _url:String = URL;
		//public var _sid:String = SESSION_ID;
		public var _view:View3D;
		
		private var _cam_control:CameraController;
		private var _preloader:MovieClip;
		private var pic_viewer_:PictureViewer;
		private var pv_images_:Array = [];

		public var _panorama:Panorama;
		public var _nmap:NavigationMap;
		
		private var bt_cons_:Sprite = new Sprite;
		public var _console:Console;

		public var _cameras:Array = [];
        public var _go_points:Array = [];
        public var _materials:Array = [];
        public var _pano_image_args:Array = [];
		public var _transitions:Array = [];
		
		public var _active_camera_id:int = 0;
		
		public var _num_cameras:int = 0;
		public var num_transitions_:int = 0;
		
        private var _old_mouse_x:Number = 0;
        private var _old_mouse_y:Number = 0;
        private var _mouse_dovn:Boolean = false;
		
        private var _auto_move_timer:Timer;
            
		public function Restaurant():void {
			if (stage) {				
				stage.scaleMode = StageScaleMode.NO_SCALE;
				stage.align = StageAlign.TOP_LEFT;
				
				var y:int = INFO_Y;
				
				for (var name:String in this.loaderInfo.parameters) {
					if (name =="crmFlashPortUrl") {
						_url= this.loaderInfo.parameters[name];
					}
					
					//if (name =="floorId") {
					//	_sid = this.loaderInfo.parameters[name];
					//}
				}
				init();
			}
			else {
				this.addEventListener(Event.ADDED_TO_STAGE, init);
			}
		}
		
		private function init(e:Event = null):void {
            Security.loadPolicyFile(CROSS_DATA);
            Security.loadPolicyFile(CROSS_IMG);

			this.removeEventListener(Event.ADDED_TO_STAGE, init);
		
			initConsole();
			//_console.addMessage("url:`" + _url + "`; sid:`" + _sid + "`");
            _console.addMessage("url:`" + _url);

			// инициализация загрузки
			var sloader:SceneLoader = new SceneLoader;
            sloader.addEventListener(SceneLoader.ERROR_SECURITY_LOADING_SCENE, function(e:MessageEvent):void {
                _console.addMessage("ERROR SECURITY: scene loading: `" + e._msg + "`");
                complete();
            });

            sloader.addEventListener(SceneLoader.ERROR_LOADING_SCENE, function(e:MessageEvent):void {
                _console.addMessage("ERROR: scene loading: `" + e._msg + "`");
                complete();
            });

            sloader.addEventListener(SceneLoader.LOADED_SCENE_NAME, function(e:MessageEvent):void {
                _console.addMessage("Scene is loaded. Name `" + e._msg + "`");
            });

            sloader.addEventListener(SceneLoader.LOADED_VIEWPOINT, function(e:MessageEvent):void {
                _console.addMessage("Loaded viewpoint: `" + e._msg + "`");
                
                var args:Array = e._msg.split(";");
                var id:int = int(args[0]);
                
                var cam:Camera = new Camera(id, args[3] * 10, args[4] * 10);
                cam.addEventListener(Camera.GO_TO_MY, function(e:MessageEvent):void {
                    _console.addMessage("Go to my: " + int(e._msg));
                    _panorama._curr_gop.go(int(e._msg));
                });
                
                _cameras[id] = cam; 
                _pano_image_args[id] = e._msg;
                addGoPoint(id, cam);
                _nmap.addCamera(id);
            });   
            
            sloader.addEventListener(SceneLoader.LOADED_COMPLETE, function(e:MessageEvent):void {
                var args:Array = _pano_image_args[int(e._msg)].split(";");
                
                loadImage(int(e._msg), args[1]);
                _nmap.moveToPos(int(e._msg));
            });

            sloader.addEventListener(SceneLoader.LOADED_TRANSITION, function(e:MessageEvent):void {
                _console.addMessage("Loaded transition: `" + e._msg + "`");
                
                var args:Array = e._msg.split(";");
                
                addTransition(int(args[0]), int(args[1]), int(args[2]));
                _nmap.addTransition(int(args[0]), int(args[1]), int(args[2]));
            });

            sloader.load(_url);// + "/" + _sid);            
		
			var cam_x:int = WIDTH / 2;
			var cam_y:int = HEIGHT / 2;
			
			_cam_control = new CameraController(this);
			_cam_control.addEventListener(CameraController.CAMERA_UPDATET, function(e:CameraEvent):void {
                _panorama.cameraMove(_view.camera.rotationY + 180);
            });
			
            _view = new View3D({ camera:_cam_control._cam, x:cam_x, y:cam_y, renderer:Renderer.CORRECT_Z_ORDER });
			this.addChild(_view);
			
			// Добавление консоли
			this.addChild(_console);
			this.addChild(bt_cons_);
			
			// Инициализация элемента процесса загрузки
			_preloader = new preloader();
			_preloader.x = cam_x;
			_preloader.y = cam_y;
			this.addChild(_preloader);

			_panorama = new Panorama(this);
			
			this.addEventListener(Event.ENTER_FRAME, function(e:Event):void{
                resize();
                _cam_control.update();
                _view.render();
            });

			_cam_control.init((m_width / 2), (m_height /2));
			
            pic_viewer_ = new PictureViewer(this);
			pic_viewer_.init();
			pic_viewer_.resize();
			
            _nmap = new NavigationMap(this);
			this.addChild(_nmap);
            
            this.addEventListener(MouseEvent.MOUSE_DOWN, function(e:MouseEvent):void {
                Mouse.cursor = MouseCursor.HAND;
                _mouse_dovn = true;
            });

            this.addEventListener(MouseEvent.MOUSE_UP, function(e:MouseEvent):void {
                Mouse.cursor = MouseCursor.AUTO;
                _mouse_dovn = false;
                _old_mouse_x = 0;
                _old_mouse_y = 0;
                _auto_move_timer.start();
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
                        _cam_control._cam.moveRight(-shift_x);
                        _cam_control._cam.panAngle += shift_x;
                    }
                    
                    if (shift_x > 0) {
                        _cam_control._cam.moveLeft(shift_x);
                        _cam_control._cam.panAngle += shift_x;
                    }
                    
                    if (shift_y < 0) {
                        _cam_control._cam.moveDown(-shift_y);
                        _cam_control._cam.tiltAngle += shift_y
                    }
                    
                    if (shift_y > 0) {
                        _cam_control._cam.moveUp(shift_y);
                        _cam_control._cam.tiltAngle += shift_y;
                    }
                    
                    _old_mouse_x = e.stageX;
                    _old_mouse_y = e.stageY;
                }
            });

            _auto_move_timer = new Timer(3000, 1);
            _auto_move_timer.addEventListener(TimerEvent.TIMER_COMPLETE, function(e:TimerEvent):void {
                if (_cam_control._cam.tiltAngle != 0) {
                    _cam_control._cam.tiltAngle = 0;
                }
            });
		}

        private function onMoveByNavigationCamera():void {
            
        }
		
		private function initConsole():void {
			_console = new Console(20, 20, 600, 300);
			_console.visible = false;

			var version:TextField = new TextField;
			version.text = VERSION;
			version.x = 2;
			version.y = 2;
			version.textColor = 0xeeeeff;
			
			bt_cons_.addChild(version);
			
			bt_cons_.graphics.beginFill(0x0000ff, 0.05);
			bt_cons_.graphics.drawRect(0, 0, 20, 20);
			bt_cons_.graphics.endFill();
			
			bt_cons_.addEventListener(MouseEvent.MOUSE_OVER, function(e:MouseEvent):void {
				Mouse.cursor = MouseCursor.BUTTON; 
			})
			
			bt_cons_.addEventListener(MouseEvent.MOUSE_OUT, function(e:MouseEvent):void {
				Mouse.cursor = MouseCursor.AUTO; 
			})

			bt_cons_.addEventListener(MouseEvent.MOUSE_DOWN, function(e:MouseEvent):void {
				_console.visible = ! _console.visible; 
			})
		}
		
		private function resize():void {
			if (_preloader) {
				_preloader.x = this.stage.stageWidth / 2;
				_preloader.y = this.stage.stageHeight / 2;
			}

			if ((m_width != this.stage.stageWidth) || (m_height != this.stage.stageHeight)) {
				m_width = this.stage.stageWidth;
				m_height = this.stage.stageHeight;
				_cam_control.resize(m_width, m_height);
				_view.camera.x = m_width / 2;
				_view.camera.y = m_height / 2;
				_view.x = m_width / 2;
				_view.y = m_height / 2;
				pic_viewer_.resize();
			}
		}
		
        private function loadImage(id:int, url:String):void {
            var image_loader:PanoramaImageLoader = new PanoramaImageLoader;
            
            image_loader.addEventListener(PanoramaImageLoader.ERROR_SECURITY_LOADING_IMAGE, function(e:PanoramaImageEvent):void{
                _console.addMessage("ERROR SECURITY: image loading: " + e._id + ": " + e._url_image);
                complete();
            });
            
            image_loader.addEventListener(PanoramaImageLoader.ERROR_LOADING_IMAGE, function(e:PanoramaImageEvent):void{
                _console.addMessage("ERROR: image loading: " + e._id + ": " + e._url_image);
                complete();
            });
            
            image_loader.addEventListener(PanoramaImageLoader.LOADED_IMAGE, function(e:PanoramaImageEvent):void{
                complete();
                
                _console.addMessage("Loaded image: " + e._id + ": " + e._url_image);
                _go_points[e._id]._bitmap = e._bitmap;
                _panorama.setGoPoint(e._id);
            });
            
            image_loader.load(id, URL_IMAGES + url);
        }
        
		public function complete():void {
			this.removeChild(_preloader);
			_preloader = null;
		}

        public function addGoPoint(id:int, cam:Camera):GoPoint {
            var gop:GoPoint = new GoPoint(id, cam);
            _go_points[id] = gop;
            
            gop.addEventListener(GoPoint.SET_TRANSITION, function(e:GoPointEvent):void {
                _view.scene.addChild(e._cursor_back);
                _view.scene.addChild(e._cursor);
            });
            
            gop.addEventListener(GoPoint.DEL_TRANSITION, function(e:GoPointEvent):void {
                _view.scene.removeChild(e._cursor_back);
                _view.scene.removeChild(e._cursor);
            });
            
            gop.addEventListener(GoPoint.GO, function(e:MessageEvent):void {
                var args:Array = _pano_image_args[int(e._msg)].split(";");
                
                if (! _go_points[int(e._msg)]._bitmap) {
                    _preloader = new preloader();
                    _preloader.x = stage.stageWidth / 2;
                    _preloader.y = stage.stageHeight / 2;
                    addChild(_preloader);
                
                    loadImage(int(e._msg), args[1]);
                }
                else {
                    _console.addMessage("Go to: " + int(e._msg) + "; from " + e.target._my_id);
                    _panorama.setGoPoint(int(e._msg));
                }
                
                // сместить карту в положение текущей камеры
                _nmap.moveToPos(int(e._msg));
            });
            
            return gop;
        }

		public function addTransition(id:int, from:int, to:int):void {
			var trans:Transition = _transitions[id];
			
			if ( ! trans) {
				_transitions[id] = new Transition(this, id, from, to);
                _panorama.newTransition(id, _go_points[from], _go_points[to]);
			}
		}
	}
}