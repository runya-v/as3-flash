package {
    import away3d.cameras.HoverCamera3D;
    import away3d.cameras.TargetCamera3D;
    import away3d.containers.View3D;
    import away3d.core.render.Renderer;
    import away3d.core.utils.Cast;
    import away3d.core.utils.Color;
    import away3d.materials.BitmapMaterial;
    import away3d.materials.MovieMaterial;
    import away3d.primitives.Skybox6;
    import away3d.primitives.Sphere;
    
    import flash.display.Bitmap;
    import flash.display.BlendMode;
    import flash.display.Loader;
    import flash.display.LoaderInfo;
    import flash.display.MovieClip;
    import flash.display.Sprite;
    import flash.display.StageAlign;
    import flash.display.StageScaleMode;
    import flash.display3D.textures.Texture;
    import flash.events.Event;
    import flash.events.IOErrorEvent;
    import flash.events.MouseEvent;
    import flash.events.ProgressEvent;
    import flash.events.SecurityErrorEvent;
    import flash.geom.Rectangle;
    import flash.geom.Vector3D;
    import flash.net.URLRequest;
    import flash.system.ApplicationDomain;
    import flash.system.LoaderContext;
    import flash.system.Security;
    import flash.system.SecurityDomain;
    import flash.text.TextField;
    import flash.ui.Mouse;
    import flash.ui.MouseCursor;
    
    [SWF(width="540", height="720", frameRate="60", backgroundColor="#000000")]
    //[SWF(frameRate="60", backgroundColor="#000000")]
    public class Lift extends Sprite {
        [Embed(source='../../preloader.swf', symbol='loader')]
        private var Preloader:Class;
        
        [Embed(source='../../lift_animation.swf', symbol='lift_animation')]
        private var SrcMovie:Class;
        private var _movie_mat:MovieClip = new SrcMovie;
        
        private static const ANIMATE_FORVARD:String = "ANIMATE_FORVARD";
        private static const ANIMATE_BACK:String = "ANIMATE_BACK";
                
        private static const VERSION:String = "4.0";
        
        private static const BORDER:int              = 20;
        private static const COLOR_CHANGER_Y_POS:int = BORDER;

        public static const RADIAN:Number = 57.295779513;
        public static const URL:String = "http://kb-server.pollux.roger.net.ru/projects";
        public static const URL_IMAGES:String = "http://static.vi-ex.ru/crm";
        public static const CROSS_DATA:String = "kb-server.pollux.roger.net.ru/crossdomain.xml";
        
        public static const START_MASK_R:uint = 155;
        public static const START_MASK_G:uint = 100;
        public static const START_MASK_B:uint = 60;
        public static const START_MASK_A:uint = 125;
        
        public static const START_TEXTURE_R:uint = 255;
        public static const START_TEXTURE_G:uint = 255;
        public static const START_TEXTURE_B:uint = 255;
        public static const START_TEXTURE_A:uint = 125;
        
        public static const ROTATION_X:Number = 40;
        public static const ROTATION_Y:Number = 15;
        
        private var _material:BitmapMaterial;
        
        private var _bt_cons:Sprite;
        private var _console:Console;
        
        private var _view:View3D;
        private var _cam:HoverCamera3D;
        private var _cam_x:uint;
        private var _cam_y:uint;
        private var _sphere:Sphere;
        
        private var _shader:MaterialShader;
        
        private var _width:Number;
        private var _height:Number;
        
        private var _is_open:Boolean = false;

        private var _old_mouse_x:Number = 0;
        private var _old_mouse_y:Number = 0;
        private var _mouse_dovn:Boolean = false;

        private var _preloader:MovieClip;
        private var _vc:ViewController;
            
        public function Lift() {
            if (stage) {
                stage.scaleMode = StageScaleMode.NO_SCALE;
                stage.align = StageAlign.TOP_LEFT;
                
                _width = stage.stageWidth;
                _height = stage.stageHeight;
                
                init();
            }
            else {
                this.addEventListener(Event.ADDED_TO_STAGE, init);
            }
        }
        
        private function init():void {
            this.removeEventListener(Event.ADDED_TO_STAGE, init);
            
            // create a basic camera
            _cam = new HoverCamera3D();
            _cam.zoom         = 8;
            _cam.focus        = 50;
            _cam.panAngle     = 0;
            _cam.tiltAngle    = 0;
            _cam.minTiltAngle = -90;
            _cam.distance     = 0.5;
            _cam.hover(true);
            
            _cam_x = _width / 2;
            _cam_y = _height / 2;
            trace(_cam_x + ":" + _cam_y);
            // create a viewport
            _view = new View3D({camera:_cam, x:_cam_x, y:_cam_y, renderer:Renderer.CORRECT_Z_ORDER});
            this.addChild(_view);

            _view.render();
            
            _vc = new ViewController;
            _vc.x = stage.stageWidth * 0.05;
            _vc.y = stage.stageHeight * 0.05;
            _vc.addEventListener(ViewController.BUT_LEFT_DOWN, function(e:Event):void {
                _cam.panAngle -= ROTATION_X;
            });

            _vc.addEventListener(ViewController.BUT_RIGHT_DOWN, function(e:Event):void {
                _cam.panAngle += ROTATION_X;
            });

            _vc.addEventListener(ViewController.BUT_UP_DOWN, function(e:Event):void {
                _cam.tiltAngle -= ROTATION_Y;
            });

            _vc.addEventListener(ViewController.BUT_DOWN_DOWN, function(e:Event):void {
                _cam.tiltAngle += ROTATION_Y;
            });

            this.addChild(_vc);

            initConsole();
            
            _preloader = new Preloader();
            _preloader.scaleX = 2;
            _preloader.scaleY = 2;
            _preloader.x = _cam_x;
            _preloader.y = _cam_y;
            addChild(_preloader);
            
            Security.loadPolicyFile(CROSS_DATA);
            
            var loaderContext:LoaderContext = new LoaderContext();
            loaderContext.securityDomain = SecurityDomain.currentDomain;
            loaderContext.checkPolicyFile = true;
            var ldr:Loader = new Loader(); 
            var ldrReq:URLRequest = new URLRequest(URL + "/lift_animation.swf");
            ldr.load(ldrReq, loaderContext); 
            this.addChild(ldr);
            
            ldr.addEventListener(SecurityErrorEvent.SECURITY_ERROR, function(e:SecurityErrorEvent):void {
                removeChild(_preloader);
                _console.addMessage("ERR: Sequrity error by resurce loading. " + e);
            });
            
            ldr.addEventListener(IOErrorEvent.IO_ERROR, function(e:IOErrorEvent):void {
                removeChild(_preloader);
                _console.addMessage("ERR: IO error by resurce loading. " + e);
            });

            ldr.contentLoaderInfo.addEventListener(Event.COMPLETE, function(e:Event):void {
                _console.addMessage("Extern data is Loaded.");
                removeChild(_preloader);
                var loaderInfo:LoaderInfo = LoaderInfo(e.target);
                var loadedAppDomain:ApplicationDomain = loaderInfo.applicationDomain;
                var SymbolClass:Class = Class(loadedAppDomain.getDefinition("lift_animation"));
                _console.addMessage(SymbolClass.toString());
                
                if (SymbolClass) {
                    _console.addMessage("Init scene.");
                    _movie_mat = MovieClip(new SymbolClass()); 
                    _movie_mat.gotoAndStop(_movie_mat.totalFrames); 
                    
                    _material = new MovieMaterial(_movie_mat);
                    _material.smooth = true;
                    
                    _sphere = new Sphere({alpha:.1, radius:1000, segmentsH:40, segmentsW:40});
                    _sphere.scaleX = -1;
                    _sphere.rotationY = 180;
                    _sphere.material = _material;

                    _view.scene.addChild(_sphere);
                }
            });
            
            addEventListener(Event.ENTER_FRAME, onEnterFrame);
            
            this.addEventListener(MouseEvent.MOUSE_DOWN, function(e:MouseEvent):void {
                Mouse.cursor = MouseCursor.HAND;
                _mouse_dovn = true;
            });
            
            this.addEventListener(MouseEvent.MOUSE_UP, function(e:MouseEvent):void {
                Mouse.cursor = MouseCursor.AUTO;
                _mouse_dovn = false;
                _old_mouse_x = 0;
                _old_mouse_y = 0;
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
                        _cam.panAngle += shift_x;
                    }
                    
                    if (shift_x > 0) {
                        _cam.panAngle += shift_x;
                    }
                    
                    if (shift_y < 0) {
                        _cam.tiltAngle += shift_y
                    }
                    
                    if (shift_y > 0) {
                        _cam.tiltAngle += shift_y;
                    }
                    
                    _old_mouse_x = e.stageX;
                    _old_mouse_y = e.stageY;
                }
            });
        }
        
        private function openDoor():void {
            if (_movie_mat.currentFrame != 1) { 
                _movie_mat.prevFrame(); 
            } 
        }

        private function closeDoor():void {
            if (_movie_mat.currentFrame != _movie_mat.totalFrames) { 
                _movie_mat.nextFrame(); 
            } 
        }

        private function initConsole():void {
            _console = new Console(20, 20, this.stage.stageWidth * 0.6, this.stage.stageHeight * 0.9);
            this.addChild(_console);
            _console.visible = false;
            
            _bt_cons = new Sprite;
            this.addChild(_bt_cons);

            _bt_cons.graphics.beginFill(0x0000ff, 0.05);
            _bt_cons.graphics.drawRect(0, 0, 20, 20);
            _bt_cons.graphics.endFill();

            var version:TextField = new TextField;
            version.text = VERSION;
            version.x = 2;
            version.y = 2;
            version.width = _bt_cons.width - version.x;
            version.height = _bt_cons.height - version.y;
            version.textColor = 0xeeeeff;
            version.mouseEnabled = false;
            
            _bt_cons.addChild(version);
            
            _bt_cons.addEventListener(MouseEvent.MOUSE_OVER, function(e:MouseEvent):void {
                Mouse.cursor = MouseCursor.BUTTON;
            })
            
            _bt_cons.addEventListener(MouseEvent.MOUSE_OUT, function(e:MouseEvent):void {
                Mouse.cursor = MouseCursor.AUTO;
            })
            
            _bt_cons.addEventListener(MouseEvent.MOUSE_DOWN, function(e:MouseEvent):void {
                _console.visible = ! _console.visible; 
            })
        }
        
        private function resize():void {
            if ((_width != this.stage.stageWidth) || (_height != this.stage.stageHeight)) {
                _width = stage.stageWidth;
                _height = stage.stageHeight;
                _vc.x = stage.stageWidth * 0.02;
                _vc.x = stage.stageHeight * 0.02;
                _view.camera.x = _width / 2;
                _view.camera.y = _height / 2;
                _view.x = _width / 2;
                _view.y = _height / 2;
            }
        }
        
        private function onEnterFrame(e:Event):void {
            resize();
            _view.render();
            _cam.hover();

            var v_cam:Vector3D = new Vector3D(_cam.x, _cam.y, _cam.z);
            v_cam.normalize();
            var alpha:Number = Math.acos(v_cam.dotProduct(new Vector3D(1,0,0))) * RADIAN;
            
            if (24 > alpha) {
                if (_movie_mat.currentFrame == _movie_mat.totalFrames) {
                    _console.addMessage("Open Door.");
                }
                openDoor();
            }
            else {
                if (_movie_mat.currentFrame == 1) {
                    _console.addMessage("Close Door.");
                }
                closeDoor();
            }
        }
    }
}
