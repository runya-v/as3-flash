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
    import flash.display.MovieClip;
    import flash.display.Sprite;
    import flash.display.StageAlign;
    import flash.display.StageScaleMode;
    import flash.display3D.textures.Texture;
    import flash.events.Event;
    import flash.events.MouseEvent;
    import flash.geom.Rectangle;
    import flash.geom.Vector3D;
    import flash.text.TextField;
    import flash.ui.Mouse;
    import flash.ui.MouseCursor;
    
    [SWF(width="540", height="720", frameRate="60", backgroundColor="#000000")]
    //[SWF(frameRate="60", backgroundColor="#000000")]
    public class Lift extends Sprite {
        [Embed(source='../../lift_animation.swf', symbol='lift_animation')]
        private var SrcMovie:Class;
        private var _movie_mat:MovieClip = new SrcMovie;
        
        private static const ANIMATE_FORVARD:String = "ANIMATE_FORVARD";
        private static const ANIMATE_BACK:String = "ANIMATE_BACK";
                
        private static const VERSION:String = "2.1";
        
        public static const RADIAN:Number = 57.295779513;
        
        private static const BORDER:int              = 20;
        private static const COLOR_CHANGER_Y_POS:int = BORDER;
        
        public static const START_MASK_R:uint = 155;
        public static const START_MASK_G:uint = 100;
        public static const START_MASK_B:uint = 60;
        public static const START_MASK_A:uint = 125;
        
        public static const START_TEXTURE_R:uint = 255;
        public static const START_TEXTURE_G:uint = 255;
        public static const START_TEXTURE_B:uint = 255;
        public static const START_TEXTURE_A:uint = 125;
        
        private var _material:BitmapMaterial;
        
        private var _bt_cons:Sprite;
        private var _console:Console;
        
        private var _view:View3D;
        private var _cam:HoverCamera3D;
        private var _cam_x:uint;
        private var _cam_y:uint;
        private var _sphere:Sphere;
        
        private var _cam_control:CameraController;
        private var _shader:MaterialShader;
        
        private var _width:Number;
        private var _height:Number;
        
        private var _is_open:Boolean = false;
        
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
            
            _movie_mat.gotoAndStop(_movie_mat.totalFrames); 
            _material = new MovieMaterial(_movie_mat);
            _material.smooth = true;
            
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
            
            // create a viewport
            _view = new View3D({camera:_cam, x:_cam_x, y:_cam_y, renderer:Renderer.CORRECT_Z_ORDER});
            this.addChild(_view);
            
            _sphere = new Sphere({alpha:.1, radius:1000, segmentsH:32, segmentsW:32});
            _sphere.scaleX = -1;
            _sphere.rotationY = 90;
            _sphere.material = _material; 

            _view.scene.addChild(_sphere);
            _view.render();

            _cam_control = new CameraController(this, _cam);
            _cam_control.init((stage.stageWidth / 2), (stage.stageHeight /2));
            
            initConsole();

            addEventListener(Event.ENTER_FRAME, onEnterFrame);
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
                _cam_control.resize(_width, _height);
                _view.camera.x = _width / 2;
                _view.camera.y = _height / 2;
                _view.x = _width / 2;
                _view.y = _height / 2;
            }
        }
        
        private function onEnterFrame(e:Event):void {
            resize();
            _cam_control.update();
            _view.render();

            var v_cam:Vector3D = new Vector3D(_cam_control._cam.x, _cam_control._cam.y, _cam_control._cam.z);
            v_cam.normalize();
            var alpha:Number = Math.acos(v_cam.dotProduct(new Vector3D(0,0,1))) * RADIAN;
            
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
