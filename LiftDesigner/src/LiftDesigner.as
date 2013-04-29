package {
    import away3d.cameras.HoverCamera3D;
    import away3d.cameras.TargetCamera3D;
    import away3d.containers.View3D;
    import away3d.core.render.Renderer;
    import away3d.core.utils.Cast;
    import away3d.core.utils.Color;
    import away3d.materials.BitmapMaterial;
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
    import flash.text.TextField;
    import flash.ui.Mouse;
    import flash.ui.MouseCursor;
    
    [SWF(width="600", height="800", frameRate="60", backgroundColor="#000000")]
    //[SWF(frameRate="60", backgroundColor="#000000")]
    public class LiftDesigner extends Sprite {
        [Embed(source='../../buttons.swf', symbol='bt_inc')]
        private var bt_inc:Class;
        
        [Embed(source='../../buttons.swf', symbol='bt_dec')]
        private var bt_dec:Class;
        
        [Embed(source="../Scene.png")] 
        private var BackImage:Class;
        private var _back_image:Bitmap = new BackImage();

        [Embed(source="../Mask.png")] 
        private var MaskImage:Class;
        private var _mask_image:Bitmap = new MaskImage();

        [Embed(source="../Texture.png")] 
        private var TextureImage:Class;
        private var _tex_image:Bitmap = new TextureImage();
        
        private static const VERSION:String = "0.1";
        
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
        
        private var _color_changer:VerticalSpritesViewer;
        private var _color_sprites:Array = [];
        private var _colors:Array = [];
        private var _lift_changer:HorisontSpritesViewer;
        private var _lift_sprites:Array = [];
        
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
            
            _cam_x = _width / 2;
            _cam_y = _height / 2;
            
            // create a viewport
            _view = new View3D({camera:_cam, x:_cam_x, y:_cam_y, renderer:Renderer.CORRECT_Z_ORDER});
            this.addChild(_view);
            
            var shader:MaterialShader = new MaterialShader(new BackImage() as Bitmap);
            shader.insertMask(
                new MaskImage as Bitmap,
                Number(START_MASK_R) / Number(255),
                Number(START_MASK_G) / Number(255),
                Number(START_MASK_B) / Number(255),
                Number(START_MASK_A) / Number(255));

            _sphere = new Sphere({alpha:.1, radius:1000, segmentsH:32, segmentsW:32});
            _sphere.scaleX = -1;
            _sphere.material = new BitmapMaterial(Cast.bitmap(shader), {smooth:true, precision:20}); 

            _view.scene.addChild(_sphere);
            _view.render();

            _lift_changer = new HorisontSpritesViewer(BORDER, this.stage.stageWidth - BORDER * 8);
            _lift_changer.x = BORDER * 4;
            _lift_changer.y = this.stage.stageHeight - (HorisontSpritesViewer.HEIGHT + BORDER);

            var img:Bitmap;
            
            var l0:Sprite = new Sprite;
            img = new BackImage();
            l0.addChild(img);
            _lift_changer.insert(l0, img.width, img.height, "Сцена лифта");
            _lift_sprites.push(l0);
            
            var l1:Sprite = new Sprite;
            img = new MaskImage();
            l1.addChild(img);
            _lift_changer.insert(l1, img.width, img.height, "Маска закрашивания лифта");
            _lift_sprites.push(l1);
            
            var l2:Sprite = new Sprite;
            img = new TextureImage();
            l2.addChild(img);
            _lift_changer.insert(l2, img.width, img.height, "Текстура стен лифта");
            _lift_sprites.push(l2);
            
            var l3:Sprite = new Sprite;
            img = new BackImage();
            l3.addChild(img);
            _lift_changer.insert(l3, img.width, img.height, "Маска закрашивания лифта");
            _lift_sprites.push(l3);
            
            var l4:Sprite = new Sprite;
            img = new TextureImage();
            l4.addChild(img);
            _lift_changer.insert(l4, img.width, img.height, "Сцена лифта");
            _lift_sprites.push(l4);
            
            var l5:Sprite = new Sprite;
            img = new BackImage();
            l5.addChild(img);
            _lift_changer.insert(l5, img.width, img.height, "Маска закрашивания лифта");
            _lift_sprites.push(l5);
            
            this.addChild(_lift_changer);
            
            _color_changer = new VerticalSpritesViewer(BORDER);
            _color_changer.x = BORDER;
            _color_changer.y = COLOR_CHANGER_Y_POS;
            _color_changer.addEventListener(VerticalSpritesViewer.SELECTED, function(e:SpritesViewerEvent):void {
                var index:int = _color_sprites.indexOf(e._target); 
                
                if (index != -1) {
                    trace(index);
                    var shader:MaterialShader = new MaterialShader(new BackImage() as Bitmap);
                    index *= 4;
                    shader.insertMask(
                        new MaskImage() as Bitmap,
                        Number(_colors[index]) / Number(255),
                        Number(_colors[index + 1]) / Number(255),
                        Number(_colors[index + 2]) / Number(255),
                        Number(_colors[index + 3]) / Number(255));
                    
                    _sphere.material = new BitmapMaterial(Cast.bitmap(shader), {smooth:true, precision:20});
                    
                    _console.addMessage(
                        "mask color {" +
                        _colors[index] + "," +
                        _colors[index + 1] + "," +
                        _colors[index + 2] + "," +
                        _colors[index + 3] + "}");
                }
            });
            
            var color_alpha:uint = 0x4f;
            
            var t:Sprite = new Sprite;
            t.graphics.beginFill(0x03017f);
            t.graphics.drawRect(0, 0, 200, 123);
            t.graphics.endFill();
            _color_changer.insert(t, 200, 123, "Выбор цвета");
            _color_sprites.push(t);
            _colors.push(0x03); _colors.push(0x01); _colors.push(0x7f); _colors.push(color_alpha);

            var t_:Sprite = new Sprite;
            t_.graphics.beginFill(0x00000);
            t_.graphics.drawRect(0, 0, 200, 123);
            t_.graphics.endFill();
            _color_changer.insert(t_, 200, 123, "Выбор цвета _");
            _color_sprites.push(t_);
            _colors.push(0x00); _colors.push(0x00); _colors.push(0x00); _colors.push(color_alpha);

            var t0:Sprite = new Sprite;
            t0.graphics.beginFill(0xff0000);
            t0.graphics.drawRect(0, 0, 200, 123);
            t0.graphics.endFill();
            _color_changer.insert(t0, 200, 123, "Выбор цвета 0");
            _color_sprites.push(t0);
            _colors.push(0xff); _colors.push(0x00); _colors.push(0x00); _colors.push(color_alpha);
            
            var t1:Sprite = new Sprite;
            t1.graphics.beginFill(0x00ff00);
            t1.graphics.drawRect(0, 0, 200, 123);
            t1.graphics.endFill();
            _color_changer.insert(t1, 200, 123, "Выбор цвета 1");
            _color_sprites.push(t1);
            _colors.push(0x00); _colors.push(0xff); _colors.push(0x00); _colors.push(color_alpha);
            
            var t2:Sprite = new Sprite;
            t2.graphics.beginFill(0x03710f);
            t2.graphics.drawRect(0, 0, 200, 123);
            t2.graphics.endFill();
            _color_changer.insert(t2, 20, 12, "Выбор цвета 2");
            _color_sprites.push(t2);
            _colors.push(0x03); _colors.push(0x71); _colors.push(0x0f); _colors.push(color_alpha);
            
            var t3:Sprite = new Sprite;
            t3.graphics.beginFill(0xffff17);
            t3.graphics.drawRect(0, 0, 200, 123);
            t3.graphics.endFill();
            _color_changer.insert(t3, 200, 12, "Выбор цвета 3");
            _color_sprites.push(t3);
            _colors.push(0xff); _colors.push(0xff); _colors.push(0x17); _colors.push(color_alpha);
            
            var t4:Sprite = new Sprite;
            t4.graphics.beginFill(0x700700);
            t4.graphics.drawRect(0, 0, 200, 123);
            t4.graphics.endFill();
            _color_changer.insert(t4, 100, 102, "Выбор цвета 4");
            _color_sprites.push(t4);
            _colors.push(0x70); _colors.push(0x07); _colors.push(0x00); _colors.push(color_alpha);

            var t5:Sprite = new Sprite;
            t5.graphics.beginFill(0xffffff);
            t5.graphics.drawRect(0, 0, 200, 123);
            t5.graphics.endFill();
            _color_changer.insert(t5, 100, 102, "Выбор цвета 5");
            _color_sprites.push(t5);
            _colors.push(0xff); _colors.push(0xff); _colors.push(0xff); _colors.push(color_alpha);

            this.addChild(_color_changer);

            initConsole();
            
            _cam_control = new CameraController(this, _cam);
            _cam_control.init((stage.stageWidth / 2), (stage.stageHeight /2));

            addEventListener(Event.ENTER_FRAME, onEnterFrame);
        }
        
        private function initConsole():void {
            _console = new Console(20, 20, this.stage.stageWidth * 0.6, this.stage.stageHeight * 0.8);
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
                
                _lift_changer.y = this.stage.stageHeight - (HorisontSpritesViewer.HEIGHT + BORDER);
            }
        }
        private function onEnterFrame(e:Event):void {
            resize();
            _cam_control.update();
            _view.render();
        }
    }
}
