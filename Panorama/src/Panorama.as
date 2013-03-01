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
	import flash.geom.Vector3D;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.system.Security;
	import flash.system.SecurityPanel;
	import flash.text.TextField;
	import flash.ui.Keyboard;
	import flash.ui.Mouse;
	import flash.ui.MouseCursor;
	
	
	/**
	 * @author Velichko R.N.; email:rostislav.vel@gmail.com; (c) 2.2013
	 */
	[SWF(width="920", height="500", frameRate="30", backgroundColor="#000000")]
	public class Panorama extends Sprite {
		[Embed(source='../preloader.swf', symbol='loader')]
		private var preloader:Class;
		
		public static const VERSION:String = "0.1";
		public static const URL:String = "";
		public static const SESSION_ID:String = "16";
		public static const WIDTH:int = 920;
		public static const HEIGHT:int = 500;
		
		private static const INFO_X:int = 10;
		private static const INFO_Y:int = 10;
		private static const INFO_W:int = 200;
		private static const INFO_SCALE:int = 3;
		private static const INFO_COLOR:uint = 0xeeeeff;
		
		public var m_dw:int = 0;
		public var m_dh:int = 0;
		public var m_width:int = 0; //WIDTH;
		public var m_height:int = 0; //HEIGHT;
		public var url_:String = URL;
		public var sid_:String = SESSION_ID;
		public var view_:View3D;
		
		private var cam_control_:CameraController;
		private var preloader_:MovieClip;
		private var pic_viewer_:PictureViewer;
		private var pv_images_:Array = [];
		
		public var panorama_:Panorama;
		private var bt_cons_:Sprite = new Sprite;
		
		public var console_:Console;
		
		public var cameras_:Array = [];
		public var panorama_imgs_:Array = [];
		
		public var pano_images_:Array = [];
		
		public function ExpoNet():void {
			if (stage) {				
				stage.scaleMode = StageScaleMode.NO_SCALE;
				stage.align = StageAlign.TOP_LEFT;
				
				var y:int = INFO_Y;
				
				for (var name:String in this.loaderInfo.parameters) {
					if (name =="crmFlashPortUrl") {
						url_= this.loaderInfo.parameters[name];
						url_ += "/rest";
					}
					
					if (name =="floorId") {
						sid_ = this.loaderInfo.parameters[name];
					}
				}
				init();
			}
			else {
				this.addEventListener(Event.ADDED_TO_STAGE, init);
			}
		}
		
		private function init(e:Event = null):void {
			//Security.loadPolicyFile("http://vi-ex.ru/crossdomain.xml");
			this.removeEventListener(Event.ADDED_TO_STAGE, init);
			
			initConsole();
			console_.addMessage("url:`" + url_ + "`; sid:`" + sid_ + "`");
			
			// инициализация загрузки
			var sloader:SceneLoader = new SceneLoader(this);
			var cam_x:int = WIDTH / 2;
			var cam_y:int = HEIGHT / 2;
			
			cam_control_ = new CameraController(this);
			cam_control_.addEventListener(CameraController.CAMERA_UPDATET, onCameraMove);
			view_ = new View3D( { camera:cam_control_.m_cam, x:cam_x, y:cam_y, renderer:Renderer.CORRECT_Z_ORDER } );
			
			this.addChild(view_);
			
			// Добавление консоли
			this.addChild(console_);
			this.addChild(bt_cons_);
			
			// Инициализация элемента процесса загрузки
			preloader_ = new preloader();
			preloader_.x = cam_x;
			preloader_.y = cam_y;
			this.addChild(preloader_);
			
			panorama_ = new Panorama(this);
			
			this.addEventListener(Event.ENTER_FRAME, frame);
			
			cam_control_.init((m_width / 2), (m_height /2));
			pic_viewer_ = new PictureViewer(this);
			pic_viewer_.init();
			pic_viewer_.resize();
			nmap_ = new NavigationMap(this);
			this.addChild(nmap_);
		}
		
		private function initConsole():void {
			console_ = new Console(20, 20, 600, 300);
			console_.visible = false;
			
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
				console_.visible = ! console_.visible; 
			})
		}
		
		
		public function onCameraMove(e:CameraEvent):void {
			panorama_.cameraMove(view_.camera.rotationY + 180);
		}
		
		
		
		private function frame(e:Event):void {
			
			resize();
			
			cam_control_.update();
			
			view_.render();
			
		}
		
		
		
		private function resize():void {
			
			if (preloader_) {
				
				preloader_.x = this.stage.stageWidth / 2;
				
				preloader_.y = this.stage.stageHeight / 2;
				
			}
			
			
			
			if ((m_width != this.stage.stageWidth) || (m_height != this.stage.stageHeight)) {
				
				m_width = this.stage.stageWidth;
				
				m_height = this.stage.stageHeight;
				
				cam_control_.resize(m_width, m_height);
				
				view_.camera.x = m_width / 2;
				
				view_.camera.y = m_height / 2;
				
				view_.x = m_width / 2;
				
				view_.y = m_height / 2;
				
				pic_viewer_.resize();
				
			}
			
		}
		
		
		
		public function complete():void {
			
			this.removeChild(preloader_);
			
			preloader_ = null;
			
		}
		
		
		
		private function onCamerasLoaded(e:Event):void {
			
			
			
		}
		
		
		
		private function onTransitionsLoaded(e:Event):void {
			
			
			
		}
		
		
		
		private function onWallsLoaded(e:Event):void {
			
			
			
		}
		
		
		
		private function onPlacesLoaded(e:Event):void {
			
			
			
		}
		
		
		
		private function onLaddersLoaded(e:Event):void {
			
			
			
		}
		
		
		
		private function onPannelsLoaded(e:Event):void {
			
			
			
		}
		
		
		
		private function onCameraXmlComplete(e:Event):void {
			
			
			
		}
		
		
		
		private function onTransitionXmlComplete(e:Event):void {
			
			
			
		}
		
		
		
		private function onWallsXmlComplete(e:Event):void {
			
			
			
		}
		
		
		
		private function onPlacesXmlComplete(e:Event):void {
			
			
			
		}
		
		
		
		private function onLaddersXmlComplete(e:Event):void {
			
			
			
		}
		
		
		
		private function onPannelsXmlComplete(e:Event):void {
			
			
			
		}
		
		
		
		private function onCameraNumber(e:Event):void {
			
			
			
		}
		
		
		
		private function onSetActiveCamera(e:Event):void {
			
			panorama_.setGoPoint(active_camera_id_);
			
		}
		
		
		
		private function onImageLoaded(e:PanoramaImageEvent):void {
			
			panorama_.setNewImage(e.id_);
			
		}
		
		
		
		private function onNewValidTransition(e:ValidTransitionEvent):void {
			
			addTransition(e.id_, e.from_, e.to_);
			
		}
		
		
		
		public function addTransition(id:int, from:int, to:int):void {
			
			var trans:Transition = transitions_[id];
			
			
			
			if ( ! trans) {
				
				transitions_[id] = new Transition(this, id, from, to);
				
			}
			
		}
		
		
		
		private function onTransitionNumber(e:Event):void {
			
			
			
		}
		
		
		
		private function onLoadedComplete(e:Event):void {
			
			for each (var trans:Transition in transitions_) {
				
				panorama_.newTransition(trans.id_, trans.from_id_, trans.to_id_);
			}
			complete();
		}
		
		
		private function onNetError(e:Event):void {
			complete();
		}
	}
}