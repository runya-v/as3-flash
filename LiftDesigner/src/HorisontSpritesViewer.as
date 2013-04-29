package {
    import flash.display.DisplayObject;
    import flash.display.MovieClip;
    import flash.display.Sprite;
    import flash.events.EventDispatcher;
    import flash.events.MouseEvent;
    import flash.events.TimerEvent;
    import flash.text.TextField;
    import flash.text.TextFieldAutoSize;
    import flash.ui.Mouse;
    import flash.ui.MouseCursor;
    import flash.utils.Timer;
    
    import org.osmf.events.TimeEvent;
    
    /**
     * @author Velichko R.N.; email:rostislav.vel@gmail.com; (c) 6.2011
     */
    public class HorisontSpritesViewer extends Sprite {
        [Embed(source='../../preloader.swf', symbol='tmp_image')]
        private var TmpImage:Class;
        
        [Embed(source='../../buttons.swf', symbol='map_pview')]
        private var PView:Class;
        
        public static const SELECTED:String = "SELECTED";
        
        //public static const this.width:int  = 500;
        public static const HEIGHT:int = 100;
        
        private static const BT_IMG_SHIFT:Number      = 3;
        private static const BT_IMG_WIDTH:Number      = HEIGHT * 0.75;
        private static const BT_IMG_SHIFT_STEP:Number = 5;
        
        private var _view:Sprite = new Sprite;
        
        private var _shift_timer:Timer = new Timer(30, 1);
        private var _cur_x_pos:Number = BT_IMG_SHIFT;
        private var _sprites:Array = [];
        private var _titles:Array = [];
        private var _direction_shift:Number = 0;
        private var _width:Number = 0;
        
        public function HorisontSpritesViewer(border:Number, width:Number) {
            _width = width;
            _cur_x_pos = border + BT_IMG_SHIFT;
            
            var back:MovieClip = new TmpImage();
            back.gotoAndStop(1);
            back.scaleX = width / 10;
            back.scaleY = HEIGHT / 10;
            
            this.addChild(back);
            
            _shift_timer.addEventListener(TimerEvent.TIMER_COMPLETE, updateImgsPos);
            
            var bt_right_rect:Sprite = new Sprite;
            bt_right_rect.x = this.width - border;
            bt_right_rect.graphics.beginFill(0x707070);
            bt_right_rect.graphics.drawRect(0, 0, border, HEIGHT);
            bt_right_rect.graphics.endFill();
            bt_right_rect.alpha = 0.5;
            this.addChild(bt_right_rect);
            
            var bt_right:MovieClip = new PView();
            bt_right.gotoAndStop(1);
            bt_right.x = border / 2;
            bt_right.y = HEIGHT / 2;
            bt_right_rect.addChild(bt_right);
            
            bt_right_rect.addEventListener(MouseEvent.MOUSE_OVER, function(e:MouseEvent):void {
                bt_right.gotoAndStop(2);
                bt_right_rect.alpha = 0.8;
            });
            
            bt_right_rect.addEventListener(MouseEvent.MOUSE_OUT, function(e:MouseEvent):void {
                bt_right.gotoAndStop(1);
                bt_right_rect.alpha = 0.5;
                _direction_shift = 0;
            });
            
            bt_right_rect.addEventListener(MouseEvent.MOUSE_DOWN, function(e:MouseEvent):void {
                bt_right_rect.alpha = 0.2;
                _direction_shift = -BT_IMG_SHIFT_STEP;
                updateImgsPos(null);
            });
            
            bt_right_rect.addEventListener(MouseEvent.MOUSE_UP, function(e:MouseEvent):void {
                bt_right.gotoAndStop(1);
                bt_right_rect.alpha = 0.5;
                _direction_shift = 0;
            });
            
            var bt_left_rect:Sprite = new Sprite;
            bt_left_rect.graphics.beginFill(0x707070);
            bt_left_rect.graphics.drawRect(0, 0, border, HEIGHT);
            bt_left_rect.graphics.endFill();
            bt_left_rect.alpha = 0.5;
            this.addChild(bt_left_rect);
            
            var bt_left:MovieClip = new PView();
            bt_left.gotoAndStop(1);
            bt_left.rotationZ = 180;
            bt_left.x = border / 2;
            bt_left.y = HEIGHT / 2;
            bt_left_rect.addChild(bt_left);
            
            bt_left_rect.addEventListener(MouseEvent.MOUSE_OVER, function(e:MouseEvent):void {
                bt_left.gotoAndStop(2);
                bt_left_rect.alpha = 0.8;
            });
            
            bt_left_rect.addEventListener(MouseEvent.MOUSE_OUT, function(e:MouseEvent):void {
                bt_left.gotoAndStop(1);
                bt_left_rect.alpha = 0.5;
                _direction_shift = 0;
            });
            
            bt_left_rect.addEventListener(MouseEvent.MOUSE_DOWN, function(e:MouseEvent):void {
                bt_left_rect.alpha = 0.2;
                _direction_shift = BT_IMG_SHIFT_STEP;
                updateImgsPos(null);
            });
            
            bt_left_rect.addEventListener(MouseEvent.MOUSE_UP, function(e:MouseEvent):void {
                bt_left.gotoAndStop(1);
                bt_left_rect.alpha = 0.5;
                _direction_shift = 0;
            });
            
            var mask:Sprite = new Sprite;
            mask.x = border;
            mask.graphics.beginFill(0x000000);
            mask.graphics.drawRect(0, 0, width - border * 2, HEIGHT);
            mask.graphics.endFill();
            _view.mask = DisplayObject(mask);
            
            this.addChild(mask);
            this.addChild(_view);
        }
        
        private function updateImgsPos(e:TimerEvent):void {
            if (_direction_shift && _sprites.length && _cur_x_pos > (HEIGHT - _view.mask.x)) {
                var i:int;
               
                if (Sprite(_sprites[0]).x > (_view.mask.x + BT_IMG_SHIFT)) {
                    _cur_x_pos = _view.mask.x + BT_IMG_SHIFT;
                    
                    for (i = 0; i < _sprites.length; i++) {
                        Sprite(_sprites[i]).x = _cur_x_pos;
                        _cur_x_pos += BT_IMG_WIDTH + BT_IMG_SHIFT;
                    }
                }
                else if ((_cur_x_pos - BT_IMG_SHIFT) < (_width - _view.mask.x)) {
                    var delta:Number = (_cur_x_pos - BT_IMG_SHIFT) - (_width - _view.mask.x);
                    
                    for (i = 0; i < _sprites.length; i++) {
                        Sprite(_sprites[i]).x -= delta;
                    }
                    _cur_x_pos -= delta;
                }
                else {
                    for (i = 0; i < _sprites.length; i++) {
                        Sprite(_sprites[i]).x += _direction_shift;
                    }
                    _cur_x_pos = Sprite(_sprites[0]).x + ((BT_IMG_WIDTH + BT_IMG_SHIFT) * _sprites.length);
                }
                _shift_timer.start();
            }
        }
        
        public function insert(sprite:Sprite, width:Number = BT_IMG_WIDTH, height:Number = (HEIGHT - BT_IMG_SHIFT * 2), title:String = "тип лифта"):void {
            sprite.x = _cur_x_pos;
            sprite.y = BT_IMG_SHIFT;
            sprite.scaleX = BT_IMG_WIDTH / sprite.width; 
            sprite.scaleY = (HEIGHT - BT_IMG_SHIFT * 2) / sprite.height;
            sprite.alpha = .8;
            
            _view.addChild(sprite);
            _sprites.push(sprite);
            _titles.push(title);
            
            sprite.addEventListener(MouseEvent.MOUSE_OVER, function(e:MouseEvent):void {
                var rect:Sprite = new Sprite;
                var target:Sprite = Sprite(e.target); 
                rect.graphics.lineStyle(2, 0xf7fff7);
                rect.graphics.drawRect(0, 0, BT_IMG_WIDTH / target.scaleX, (HEIGHT - BT_IMG_SHIFT * 2) / e.target.scaleY);
                target.addChild(rect);
                target.alpha = 1;

                var index:int = _sprites.indexOf(target); 

                if (index != -1) {
                    var ttl:TextField = new TextField;
                    ttl.x = 2;
                    ttl.y = -1;
                    ttl.textColor = 0xefefff;
                    ttl.text = _titles[index];
                    ttl.width = ttl.textWidth + 6;
                    
                    var tex_sprite:Sprite = new Sprite;
                    tex_sprite.x = target.x;
                    tex_sprite.y = target.y - 30; 
                    tex_sprite.graphics.beginFill(0x7f7f9f, 0.8);
                    tex_sprite.graphics.lineStyle(1, ttl.textColor);
                    tex_sprite.graphics.drawRoundRect(0, 0, ttl.textWidth + 6, ttl.textHeight + 2, 4, 4);
                    tex_sprite.graphics.endFill();
                    tex_sprite.addChild(ttl);
                    
                    addChildAt(tex_sprite, 0);
                }
            });
            
            sprite.addEventListener(MouseEvent.MOUSE_OUT, function(e:MouseEvent):void {
                var childs:int = Sprite(e.target).numChildren;
                Sprite(e.target).removeChildAt(childs - 1);
                Sprite(e.target).alpha = .8;
                var index:int = _sprites.indexOf(Sprite(e.target)); 
                removeChildAt(0);
            });
            
            sprite.addEventListener(MouseEvent.MOUSE_DOWN, function(e:MouseEvent):void {
                var childs:int = Sprite(e.target).numChildren;
                Sprite(e.target).removeChildAt(childs - 1);
                
                var rect:Sprite = new Sprite;
                var target:Sprite = Sprite(e.target); 
                rect.graphics.lineStyle(3, 0xf7f7f7);
                rect.graphics.drawRect(0, 0, BT_IMG_WIDTH / target.scaleX, (HEIGHT - BT_IMG_SHIFT * 2) / e.target.scaleY);
                Sprite(e.target).addChild(rect);
                
                dispatchEvent(new SpritesViewerEvent(Sprite(e.target), SELECTED));
            });
            
            _cur_x_pos += BT_IMG_WIDTH + BT_IMG_SHIFT;
        }
    }
}