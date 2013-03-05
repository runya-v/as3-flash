package {
    import away3d.cameras.HoverCamera3D;
    import away3d.cameras.TargetCamera3D;
    import away3d.containers.View3D;
    import away3d.core.render.Renderer;
    import away3d.core.utils.Cast;
    import away3d.materials.BitmapMaterial;
    import away3d.primitives.Cube;
    import away3d.primitives.Skybox;
    import away3d.primitives.Skybox6;
    
    import flash.display.Bitmap;
    import flash.display.BlendMode;
    import flash.display.MovieClip;
    import flash.display.Sprite;
    import flash.events.Event;
    import flash.events.MouseEvent;
    
    [SWF(width="720", height="400", frameRate="60", backgroundColor="#000000")]
    //[SWF(frameRate="60", backgroundColor="#000000")]
    public class CubeMap extends Sprite {
        [Embed(source="../back.png")] 
        private var BackImage:Class;
        private var _back_image:Bitmap = new BackImage();
        
        [Embed(source="../bottom.png")] 
        private var BottomImage:Class;
        private var _bottom_image:Bitmap = new BottomImage();
        
        [Embed(source="../front.png")] 
        private var FrontImage:Class;
        private var _front_image:Bitmap = new FrontImage();
        
        [Embed(source="../left.png")] 
        private var LeftImage:Class;
        private var _left_image:Bitmap = new LeftImage();
        
        [Embed(source="../right.png")] 
        private var RightImage:Class;
        private var _right_image:Bitmap = new RightImage();
        
        [Embed(source="../top.png")] 
        private var TopImage:Class;
        private var _top_image:Bitmap = new TopImage();

        [Embed(source="../Material.png")] 
        private var MaterialImage:Class;
        private var _material_bitmap:Bitmap = new MaterialImage();
        
        private var _view:View3D;
        
        private var _cam:HoverCamera3D;
        private var _cam_x:uint;
        private var _cam_y:uint;
        
        private var _cube:Skybox6;

        private var _old_mouse_x:Number = 0;
        private var _old_mouse_y:Number = 0;
        
        public function CubeMap() {
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
            addChild(_view);
            
            _cube = new Skybox6(new BitmapMaterial(Cast.bitmap(_material_bitmap)));  
            
            _view.scene.addChild(_cube);
            _view.render();
            
            addEventListener(Event.ENTER_FRAME, onEnterFrame);
            
            this.addEventListener(MouseEvent.MOUSE_MOVE, function(e:MouseEvent):void {
                if (_old_mouse_x == 0) {
                    _old_mouse_x = e.stageX;
                }
                
                if (_old_mouse_y == 0) {
                    _old_mouse_y = e.stageY;
                }
                
                var shift_x:Number = e.stageX - _old_mouse_x;
                var shift_y:Number = e.stageY - _old_mouse_y;
                
                if (shift_x < 0) {
                    _cam.moveRight(-shift_x);
                    _cam.panAngle += shift_x;
                }
                
                if (shift_x > 0) {
                    _cam.moveLeft(shift_x);
                    _cam.panAngle += shift_x;
                }
                
                if (shift_y < 0) {
                    _cam.moveDown(-shift_y);
                    _cam.tiltAngle += shift_y
                }
                
                if (shift_y > 0) {
                    _cam.moveUp(shift_y);
                    _cam.tiltAngle += shift_y;
                }
                
                _old_mouse_x = e.stageX;
                _old_mouse_y = e.stageY;
            });
        }
        
        private function onEnterFrame(e:Event):void {
            _cam.hover();
            _view.render();
        }
    }
}
