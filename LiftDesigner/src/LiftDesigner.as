package {
    import away3d.cameras.HoverCamera3D;
    import away3d.cameras.TargetCamera3D;
    import away3d.containers.View3D;
    import away3d.core.render.Renderer;
    import away3d.core.utils.Cast;
    import away3d.materials.BitmapMaterial;
    import away3d.primitives.Skybox6;
    
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
    import flash.text.TextField;
    import flash.ui.Mouse;
    import flash.ui.MouseCursor;
    
    [SWF(width="1024", height="400", frameRate="60", backgroundColor="#000000")]
    //[SWF(frameRate="60", backgroundColor="#000000")]
    public class LiftDesigner extends Sprite {
        [Embed(source='../../buttons.swf', symbol='bt_inc')]
        private var bt_inc:Class;
        
        [Embed(source='../../buttons.swf', symbol='bt_dec')]
        private var bt_dec:Class;
        
        [Embed(source="../Render.png")] 
        private var BackImage:Class;
        private var _back_image:Bitmap = new BackImage();

        [Embed(source="../Mask.png")] 
        private var MaskImage:Class;
        private var _mask_image:Bitmap = new MaskImage();

        [Embed(source="../Texture1.png")] 
        private var Texture1Image:Class;
        private var _tex_1_image:Bitmap = new Texture1Image();

        [Embed(source="../Texture2.png")] 
        private var Texture2Image:Class;
        private var _tex_2_image:Bitmap = new Texture2Image();
        
        private static const VERSION:String = "0.1";
        private var _bt_cons:Sprite;
        private var _console:Console;
        
        public static const START_MASK_R:uint = 155;
        public static const START_MASK_G:uint = 100;
        public static const START_MASK_B:uint = 60;
        public static const START_MASK_A:uint = 125;
        
        public static const START_TEXTURE_R:uint = 255;
        public static const START_TEXTURE_G:uint = 255;
        public static const START_TEXTURE_B:uint = 255;
        public static const START_TEXTURE_A:uint = 125;
        
        private var _bt_step_:ControllerButton;
        
        private var _bt_mask_r_:ControllerButton;
        private var _bt_mask_g_:ControllerButton;
        private var _bt_mask_b_:ControllerButton;
        private var _bt_mask_a_:ControllerButton;
        
        private var _bt_tex_r_:ControllerButton;
        private var _bt_tex_g_:ControllerButton;
        private var _bt_tex_b_:ControllerButton;
        private var _bt_tex_a_:ControllerButton;
        
        private var _view:View3D;
        private var _cam:HoverCamera3D;
        private var _cam_x:uint;
        private var _cam_y:uint;
        private var _box:Skybox6;
        
        private var _cam_control:CameraController;
        private var _shader:MaterialShader;
        
        private var _width:Number;
        private var _height:Number;
        
        public function LiftDesigner() {
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
            
            _cam_x = 360;
            _cam_y = 200;
            
            // create a viewport
            _view = new View3D({camera:_cam, x:360, y:200, renderer:Renderer.CORRECT_Z_ORDER});
            this.addChild(_view);
            
            var shader:MaterialShader = new MaterialShader(new BackImage() as Bitmap);
            shader.insertMask(
                new MaskImage as Bitmap,
                Number(START_MASK_R) / Number(255),
                Number(START_MASK_G) / Number(255),
                Number(START_MASK_B) / Number(255),
                Number(START_MASK_A) / Number(255));
            shader.insertMask(
                new Texture2Image() as Bitmap, 
                Number(START_TEXTURE_R) / Number(255),
                Number(START_TEXTURE_G) / Number(255),
                Number(START_TEXTURE_B) / Number(255),
                Number(START_TEXTURE_A) / Number(255));

            _box = new Skybox6(new BitmapMaterial(Cast.bitmap(shader), {smooth:true, precision:20}));
            _view.scene.addChild(_box);
            _view.render();
            
            _cam_control = new CameraController(this, _cam);
            
            initCameraButtons();
            initConsole();
            
            addEventListener(Event.ENTER_FRAME, onEnterFrame);
            _cam_control.init((stage.stageWidth / 2), (stage.stageHeight /2));
        }
        
        private function initConsole():void {
            _console = new Console(20, 20, 600, 300);
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
        
        private function initCameraButtons():void {
            var scale:Number = 0.18;
            var move:Number = 1;
            var one_pos:int = 30;
            var two_pos:int = 22;
            var cam_y:uint = _cam_y + 155;
            
            var two_pos_shift:Number = 2;
            
            _bt_step_ = new ControllerButton(this, new bt_inc(), new bt_dec(), scale, two_pos, two_pos*(two_pos_shift++), 25, "step", 10, 50);
            
            _bt_mask_r_ = new ControllerButton(this, new bt_inc(), new bt_dec(), scale, two_pos, two_pos*(two_pos_shift++), 25, "mask R", START_MASK_R, 255);
            _bt_mask_g_ = new ControllerButton(this, new bt_inc(), new bt_dec(), scale, two_pos, two_pos*(two_pos_shift++), 25, "mask G", START_MASK_G, 255);
            _bt_mask_b_ = new ControllerButton(this, new bt_inc(), new bt_dec(), scale, two_pos, two_pos*(two_pos_shift++), 25, "mask B", START_MASK_B, 255);
            _bt_mask_a_ = new ControllerButton(this, new bt_inc(), new bt_dec(), scale, two_pos, two_pos*(two_pos_shift++), 25, "mask A", START_MASK_A, 255);
            
            _bt_tex_r_ = new ControllerButton(this, new bt_inc(), new bt_dec(), scale, two_pos, two_pos*(two_pos_shift++), 25, "texture R", START_TEXTURE_R, 255);
            _bt_tex_g_ = new ControllerButton(this, new bt_inc(), new bt_dec(), scale, two_pos, two_pos*(two_pos_shift++), 25, "texture G", START_TEXTURE_G, 255);
            _bt_tex_b_ = new ControllerButton(this, new bt_inc(), new bt_dec(), scale, two_pos, two_pos*(two_pos_shift++), 25, "texture B", START_TEXTURE_B, 255);
            _bt_tex_a_ = new ControllerButton(this, new bt_inc(), new bt_dec(), scale, two_pos, two_pos*(two_pos_shift++), 25, "texture A", START_TEXTURE_A, 255);
            
            _bt_mask_r_.step_ = _bt_step_.value_; 
            _bt_mask_g_.step_ = _bt_step_.value_;
            _bt_mask_b_.step_ = _bt_step_.value_;
            _bt_mask_a_.step_ = _bt_step_.value_;
            
            _bt_tex_r_.step_ = _bt_step_.value_;
            _bt_tex_g_.step_ = _bt_step_.value_;
            _bt_tex_b_.step_ = _bt_step_.value_;
            _bt_tex_a_.step_ = _bt_step_.value_;
            
            _bt_step_.addEventListener(ControllerButton.CHANGE, function(e:Event):void {
                _bt_mask_r_.step_ = _bt_step_.value_; 
                _bt_mask_g_.step_ = _bt_step_.value_;
                _bt_mask_b_.step_ = _bt_step_.value_;
                _bt_mask_a_.step_ = _bt_step_.value_;
                
                _bt_tex_r_.step_ = _bt_step_.value_;
                _bt_tex_g_.step_ = _bt_step_.value_;
                _bt_tex_b_.step_ = _bt_step_.value_;
                _bt_tex_a_.step_ = _bt_step_.value_;
                
                _console.addMessage("step set to: " + _bt_step_.value_);
            });
            
            _bt_mask_r_.addEventListener(ControllerButton.CHANGE, changeShader);
            _bt_mask_g_.addEventListener(ControllerButton.CHANGE, changeShader);
            _bt_mask_b_.addEventListener(ControllerButton.CHANGE, changeShader);
            _bt_mask_a_.addEventListener(ControllerButton.CHANGE, changeShader);
            _bt_tex_r_.addEventListener(ControllerButton.CHANGE, changeShader);
            _bt_tex_g_.addEventListener(ControllerButton.CHANGE, changeShader);
            _bt_tex_b_.addEventListener(ControllerButton.CHANGE, changeShader);
            _bt_tex_a_.addEventListener(ControllerButton.CHANGE, changeShader);
        }
        
        private function changeShader(e:Event):void {
            var shader:MaterialShader = new MaterialShader(new BackImage() as Bitmap);
            shader.insertMask(
                new MaskImage() as Bitmap,
                Number(_bt_mask_r_.value_) / Number(255),
                Number(_bt_mask_g_.value_) / Number(255),
                Number(_bt_mask_b_.value_) / Number(255),
                Number(_bt_mask_a_.value_) / Number(255));
            shader.insertMask(
                new Texture2Image() as Bitmap, 
                Number(_bt_tex_r_.value_) / Number(255),
                Number(_bt_tex_g_.value_) / Number(255),
                Number(_bt_tex_b_.value_) / Number(255),
                Number(_bt_tex_a_.value_) / Number(255));
            
            _box.material = new BitmapMaterial(Cast.bitmap(shader), {smooth:true, precision:20});
            
            _console.addMessage(
                "mask color {" +
                _bt_mask_r_.value_ + "," +
                _bt_mask_g_.value_ + "," +
                _bt_mask_b_.value_ + "," +
                _bt_mask_a_.value_ + "}" +
                "tex color {" +
                _bt_tex_r_.value_ + "," +
                _bt_tex_g_.value_ + "," +
                _bt_tex_b_.value_ + "," +
                _bt_tex_a_.value_ + "}");
        }
        
        private function resize():void {
            if ((_width != this.stage.stageWidth) || (_height != this.stage.stageHeight)) {
                _width = this.stage.stageWidth;
                _height = this.stage.stageHeight;
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
        }
    }
}
