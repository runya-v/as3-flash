package {
    import away3d.cameras.HoverCamera3D;
    import away3d.cameras.TargetCamera3D;
    import away3d.containers.View3D;
    import away3d.core.render.Renderer;
    import away3d.core.utils.Cast;
    import away3d.materials.BitmapMaterial;
    import away3d.primitives.Sphere;
    
    import flash.display.Bitmap;
    import flash.display.BlendMode;
    import flash.display.MovieClip;
    import flash.display.Sprite;
    import flash.events.Event;
    import flash.events.MouseEvent;
    
    [SWF(width="720", height="400", frameRate="60", backgroundColor="#000000")]
    //[SWF(frameRate="60", backgroundColor="#000000")]
    public class PanoramaMask extends Sprite {
        public static const START_MASK_R:uint = 155;
        public static const START_MASK_G:uint = 100;
        public static const START_MASK_B:uint = 60;
        public static const START_MASK_A:uint = 125;
        
        public static const START_TEXTURE_R:uint = 255;
        public static const START_TEXTURE_G:uint = 255;
        public static const START_TEXTURE_B:uint = 255;
        public static const START_TEXTURE_A:uint = 125;
                
        private var m_bt_step_:ControllerButton;

        private var m_bt_mask_r_:ControllerButton;
        private var m_bt_mask_g_:ControllerButton;
        private var m_bt_mask_b_:ControllerButton;
        private var m_bt_mask_a_:ControllerButton;

        private var m_bt_tex_r_:ControllerButton;
        private var m_bt_tex_g_:ControllerButton;
        private var m_bt_tex_b_:ControllerButton;
        private var m_bt_tex_a_:ControllerButton;
        
       
        private var m_view:View3D;
        private var m_cam:HoverCamera3D;
        private var m_cam_x:uint;
        private var m_cam_y:uint;
        
        private var m_sphere:Sphere;
        private var m_curr_alpha:Number;
        
        [Embed(source='../../buttons.swf', symbol='bt_inc')]
        private var bt_inc:Class;
        
        [Embed(source='../../buttons.swf', symbol='bt_dec')]
        private var bt_dec:Class;
        
        private var m_shader:BitmapMaterial;
        
        private var m_cur_num_img:int = 0;
        private var m_duration:uint;
        
        private var _old_mouse_x:Number = 0;
        private var _old_mouse_y:Number = 0;
        
        private var _is_mouse_down:Boolean = false;
        
        public function PanoramaMask() {
            // create a basic camera
            m_cam = new HoverCamera3D();
            m_cam.zoom = 8;
            m_cam.focus = 50;
            m_cam.panAngle = 0;
            m_cam.tiltAngle = 0;
            m_cam.minTiltAngle = -90;
            m_cam.distance = 0.5;
            m_cam.hover(true);
            
            m_cam_x = 360;
            m_cam_y = 200;
            
            // create a viewport
            m_view = new View3D({camera:m_cam, x:360, y:200, renderer:Renderer.CORRECT_Z_ORDER});
            addChild(m_view);

            m_shader = new BitmapMaterial(
                Cast.bitmap((new MaterialShader(
                    Number(START_MASK_R) / Number(255),
                    Number(START_MASK_G) / Number(255),
                    Number(START_MASK_B) / Number(255),
                    Number(START_MASK_A) / Number(255),
                    
                    Number(START_TEXTURE_R) / Number(255),
                    Number(START_TEXTURE_G) / Number(255),
                    Number(START_TEXTURE_B) / Number(255),
                    Number(START_TEXTURE_A) / Number(255))).sprite_), 
                {smooth:true, precision:20});
            
            m_sphere = new Sphere({alpha:.1, radius:800, segmentsH:30, segmentsW:30});
            m_sphere.material = m_shader
            m_sphere.scaleX = -1;
            
            m_view.scene.addChild(m_sphere);
            m_view.render();
            
            initCameraButtons();
            
            addEventListener(Event.ENTER_FRAME, onEnterFrame);
            
            //this.addEventListener(MouseEvent.MOUSE_DOWN, function(e:MouseEvent):void {
            //    _is_mouse_down
            //});
            
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
                    m_cam.moveRight(-shift_x);
                    m_cam.panAngle += shift_x;
                }
                
                if (shift_x > 0) {
                    m_cam.moveLeft(shift_x);
                    m_cam.panAngle += shift_x;
                }
                
                if (shift_y < 0) {
                    m_cam.moveDown(-shift_y);
                    m_cam.tiltAngle += shift_y
                }
                
                if (shift_y > 0) {
                    m_cam.moveUp(shift_y);
                    m_cam.tiltAngle += shift_y;
                }
                
                _old_mouse_x = e.stageX;
                _old_mouse_y = e.stageY;
            });
        }
        
        public function get_sphere_radius():int {
            return m_sphere.radius;
        }
        
        public function set_sphere_radius(s:int):void {
            m_sphere.radius = s;
        }
        
        private function initCameraButtons():void {
            var scale:Number = 0.2;
            var move:Number = 1;
            var one_pos:int = 30;
            var two_pos:int = 22;
            var cam_y:uint = m_cam_y + 155;

            var two_pos_shift:Number = 1;
            
            m_bt_step_ = new ControllerButton(this, new bt_inc(), new bt_dec(), scale - .03, two_pos, two_pos*(two_pos_shift++), 25, "step", 10, 50);

            m_bt_mask_r_ = new ControllerButton(this, new bt_inc(), new bt_dec(), scale - .03, two_pos, two_pos*(two_pos_shift++), 25, "mask R", START_MASK_R, 255);
            m_bt_mask_g_ = new ControllerButton(this, new bt_inc(), new bt_dec(), scale - .03, two_pos, two_pos*(two_pos_shift++), 25, "mask G", START_MASK_G, 255);
            m_bt_mask_b_ = new ControllerButton(this, new bt_inc(), new bt_dec(), scale - .03, two_pos, two_pos*(two_pos_shift++), 25, "mask B", START_MASK_B, 255);
            m_bt_mask_a_ = new ControllerButton(this, new bt_inc(), new bt_dec(), scale - .03, two_pos, two_pos*(two_pos_shift++), 25, "mask A", START_MASK_A, 255);
            
            m_bt_tex_r_ = new ControllerButton(this, new bt_inc(), new bt_dec(), scale - .03, two_pos, two_pos*(two_pos_shift++), 25, "texture R", START_TEXTURE_R, 255);
            m_bt_tex_g_ = new ControllerButton(this, new bt_inc(), new bt_dec(), scale - .03, two_pos, two_pos*(two_pos_shift++), 25, "texture G", START_TEXTURE_G, 255);
            m_bt_tex_b_ = new ControllerButton(this, new bt_inc(), new bt_dec(), scale - .03, two_pos, two_pos*(two_pos_shift++), 25, "texture B", START_TEXTURE_B, 255);
            m_bt_tex_a_ = new ControllerButton(this, new bt_inc(), new bt_dec(), scale - .03, two_pos, two_pos*(two_pos_shift++), 25, "texture A", START_TEXTURE_A, 255);
            
            m_bt_mask_r_.step_ = m_bt_step_.value_; 
            m_bt_mask_g_.step_ = m_bt_step_.value_;
            m_bt_mask_b_.step_ = m_bt_step_.value_;
            m_bt_mask_a_.step_ = m_bt_step_.value_;
            
            m_bt_tex_r_.step_ = m_bt_step_.value_;
            m_bt_tex_g_.step_ = m_bt_step_.value_;
            m_bt_tex_b_.step_ = m_bt_step_.value_;
            m_bt_tex_a_.step_ = m_bt_step_.value_;
            
            m_bt_step_.addEventListener(ControllerButton.CHANGE, function(e:Event):void {
                m_bt_mask_r_.step_ = m_bt_step_.value_; 
                m_bt_mask_g_.step_ = m_bt_step_.value_;
                m_bt_mask_b_.step_ = m_bt_step_.value_;
                m_bt_mask_a_.step_ = m_bt_step_.value_;
                
                m_bt_tex_r_.step_ = m_bt_step_.value_;
                m_bt_tex_g_.step_ = m_bt_step_.value_;
                m_bt_tex_b_.step_ = m_bt_step_.value_;
                m_bt_tex_a_.step_ = m_bt_step_.value_;
            });
                
            m_bt_mask_r_.addEventListener(ControllerButton.CHANGE, changeShader);
            m_bt_mask_g_.addEventListener(ControllerButton.CHANGE, changeShader);
            m_bt_mask_b_.addEventListener(ControllerButton.CHANGE, changeShader);
            m_bt_mask_a_.addEventListener(ControllerButton.CHANGE, changeShader);
            m_bt_tex_r_.addEventListener(ControllerButton.CHANGE, changeShader);
            m_bt_tex_g_.addEventListener(ControllerButton.CHANGE, changeShader);
            m_bt_tex_b_.addEventListener(ControllerButton.CHANGE, changeShader);
            m_bt_tex_a_.addEventListener(ControllerButton.CHANGE, changeShader);
        }

        private function changeShader(e:Event):void {
            m_shader = new BitmapMaterial(
                Cast.bitmap((new MaterialShader(
                    Number(m_bt_mask_r_.value_) / Number(255),
                    Number(m_bt_mask_g_.value_) / Number(255),
                    Number(m_bt_mask_b_.value_) / Number(255),
                    Number(m_bt_mask_a_.value_) / Number(255),
                    
                    Number(m_bt_tex_r_.value_) / Number(255),
                    Number(m_bt_tex_g_.value_) / Number(255),
                    Number(m_bt_tex_b_.value_) / Number(255),
                    Number(m_bt_tex_a_.value_) / Number(255))).sprite_), 
                {smooth:true, precision:20});
            
            m_sphere.material = m_shader;
        }

        private function onEnterFrame(e:Event):void {
            m_cam.hover();
            m_view.render();
        }
    }
}
