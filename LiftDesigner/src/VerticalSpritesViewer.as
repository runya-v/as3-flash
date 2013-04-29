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
    public class VerticalSpritesViewer extends Sprite {
        [Embed(source='../../preloader.swf', symbol='tmp_image')]
        private var TmpImage:Class;
        
        [Embed(source='../../buttons.swf', symbol='map_pview')]
        private var PView:Class;

        public static const SELECTED:String = "SELECTED";
        
        public static const WIDTH:int  = 100;
        public static const HEIGHT:int = 250;
        
        private static const BT_IMG_SHIFT:Number      = 3;
        private static const BT_IMG_HEIGHT:Number     = 30;
        private static const BT_IMG_SHIFT_STEP:Number = 3;
        
        private var _view:Sprite = new Sprite;

        private var _shift_timer:Timer = new Timer(30, 1);
        private var _cur_y_pos:Number = BT_IMG_SHIFT;
        private var _sprites:Array = [];
        private var _titles:Array = [];
        private var _direction_shift:Number = 0;
        
        public function VerticalSpritesViewer(border:Number) {
            _cur_y_pos = border + BT_IMG_SHIFT;
            
            var back:MovieClip = new TmpImage();
            back.gotoAndStop(1);
            back.scaleX = WIDTH / 10;
            back.scaleY = HEIGHT / 10;
            
            this.addChild(back);

            _shift_timer.addEventListener(TimerEvent.TIMER_COMPLETE, updateImgsPos);
            
            var bt_up_rect:Sprite = new Sprite;
            bt_up_rect.graphics.beginFill(0x707070);
            bt_up_rect.graphics.drawRect(0, 0, WIDTH, border);
            bt_up_rect.graphics.endFill();
            bt_up_rect.alpha = 0.5;
            this.addChild(bt_up_rect);

            var bt_up:MovieClip = new PView();
            bt_up.gotoAndStop(1);
            bt_up.rotationZ = -90;
            bt_up.x = WIDTH / 2 ;
            bt_up.y = border / 2;
            bt_up_rect.addChild(bt_up);

            bt_up_rect.addEventListener(MouseEvent.MOUSE_OVER, function(e:MouseEvent):void {
                bt_up.gotoAndStop(2);
                bt_up_rect.alpha = 0.8;
            });

            bt_up_rect.addEventListener(MouseEvent.MOUSE_OUT, function(e:MouseEvent):void {
                bt_up.gotoAndStop(1);
                bt_up_rect.alpha = 0.5;
                _direction_shift = 0;
            });

            bt_up_rect.addEventListener(MouseEvent.MOUSE_DOWN, function(e:MouseEvent):void {
                bt_up_rect.alpha = 0.2;
                _direction_shift = BT_IMG_SHIFT_STEP;
                updateImgsPos(null);
            });

            bt_up_rect.addEventListener(MouseEvent.MOUSE_UP, function(e:MouseEvent):void {
                bt_up.gotoAndStop(1);
                bt_up_rect.alpha = 0.5;
                _direction_shift = 0;
            });

            var bt_down_rect:Sprite = new Sprite;
            bt_down_rect.y = HEIGHT - border;
            bt_down_rect.graphics.beginFill(0x707070);
            bt_down_rect.graphics.drawRect(0, 0, WIDTH, border);
            bt_down_rect.graphics.endFill();
            bt_down_rect.alpha = 0.5;
            this.addChild(bt_down_rect);

            var bt_down:MovieClip = new PView();
            bt_down.gotoAndStop(1);
            bt_down.rotationZ = 90;
            bt_down.x = WIDTH / 2 ;
            bt_down.y = border / 2;
            bt_down_rect.addChild(bt_down);

            bt_down_rect.addEventListener(MouseEvent.MOUSE_OVER, function(e:MouseEvent):void {
                bt_down.gotoAndStop(2);
                bt_down_rect.alpha = 0.8;
            });
            
            bt_down_rect.addEventListener(MouseEvent.MOUSE_OUT, function(e:MouseEvent):void {
                bt_down.gotoAndStop(1);
                bt_down_rect.alpha = 0.5;
                _direction_shift = 0;
            });
            
            bt_down_rect.addEventListener(MouseEvent.MOUSE_DOWN, function(e:MouseEvent):void {
                bt_down_rect.alpha = 0.2;
                _direction_shift = -BT_IMG_SHIFT_STEP;
                updateImgsPos(null);
            });
            
            bt_down_rect.addEventListener(MouseEvent.MOUSE_UP, function(e:MouseEvent):void {
                bt_down.gotoAndStop(1);
                bt_down_rect.alpha = 0.5;
                _direction_shift = 0;
            });
            
            var mask:Sprite = new Sprite;
            mask.y = border;
            mask.graphics.beginFill(0x000000);
            mask.graphics.drawRect(0, 0, WIDTH, HEIGHT - border * 2);
            mask.graphics.endFill();
            _view.mask = DisplayObject(mask);
            
            this.addChild(mask);
            this.addChild(_view);
        }
    
        private function updateImgsPos(e:TimerEvent):void {
            if (_direction_shift && _sprites.length && _cur_y_pos > (HEIGHT - _view.mask.y)) {
                var i:int;

                if (Sprite(_sprites[0]).y > (_view.mask.y + BT_IMG_SHIFT)) {
                    _cur_y_pos = _view.mask.y + BT_IMG_SHIFT;
                   
                    for (i = 0; i < _sprites.length; i++) {
                        Sprite(_sprites[i]).y = _cur_y_pos;
                        _cur_y_pos += BT_IMG_HEIGHT + BT_IMG_SHIFT;
                    }
                }
                else if ((_cur_y_pos - BT_IMG_SHIFT - 1) < (HEIGHT - _view.mask.y)) {
                    trace((_cur_y_pos - BT_IMG_SHIFT - 1) + " : " + (HEIGHT - _view.mask.y))
                    var delta:Number = (_cur_y_pos - BT_IMG_SHIFT - 1) - (HEIGHT - _view.mask.y);

                    for (i = 0; i < _sprites.length; i++) {
                        Sprite(_sprites[i]).y -= delta;
                    }
                    _cur_y_pos -= delta;
                }
                else {
                    for (i = 0; i < _sprites.length; i++) {
                        Sprite(_sprites[i]).y += _direction_shift;
                    }
                    _cur_y_pos += _direction_shift; // = Sprite(_sprites[0]).y + ((BT_IMG_HEIGHT + BT_IMG_SHIFT) * _sprites.length);
                }
                _shift_timer.start();
            }
        }
        
        public function insert(sprite:Sprite, width:Number = (WIDTH - BT_IMG_SHIFT * 2), height:Number = BT_IMG_HEIGHT, title:String = "кнопка выбора"):void {
            sprite.x = BT_IMG_SHIFT;
            sprite.y = _cur_y_pos;
            sprite.scaleX = (WIDTH - BT_IMG_SHIFT * 2) / sprite.width;
            sprite.scaleY = BT_IMG_HEIGHT / sprite.height;
            sprite.alpha = .8;
                
            _view.addChild(sprite);
            _sprites.push(sprite);
            _titles.push(title);
            
            sprite.addEventListener(MouseEvent.MOUSE_OVER, function(e:MouseEvent):void {
                var rect:Sprite = new Sprite;
                var target:Sprite = Sprite(e.target); 
                rect.graphics.lineStyle(2, 0xf7fff7);
                rect.graphics.drawRect(0, 0, (WIDTH - BT_IMG_SHIFT * 2) / target.scaleX, BT_IMG_HEIGHT / e.target.scaleY);
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
                    tex_sprite.x = target.x + target.width + BT_IMG_SHIFT;
                    tex_sprite.y = target.y; 
                    tex_sprite.graphics.beginFill(0x7f7f9f, 0.8);
                    tex_sprite.graphics.lineStyle(1, ttl.textColor);
                    tex_sprite.graphics.drawRoundRect(0, 0, ttl.textWidth + 6, ttl.textHeight + 2, 4, 4);
                    tex_sprite.graphics.endFill();
                    tex_sprite.addChild(ttl);
                    addChildAt(tex_sprite, 0);
                }
            });
            
            sprite.addEventListener(MouseEvent.MOUSE_OUT, function(e:MouseEvent):void {
                Sprite(e.target).removeChildAt(0);
                Sprite(e.target).alpha = .8;
                removeChildAt(0);
            });

            sprite.addEventListener(MouseEvent.MOUSE_DOWN, function(e:MouseEvent):void {
                Sprite(e.target).removeChildAt(0);
                
                var rect:Sprite = new Sprite;
                rect.graphics.lineStyle(3, 0xf7f7f7);
                rect.graphics.drawRect(0, 0, (WIDTH - BT_IMG_SHIFT * 2) / Sprite(e.target).scaleX, BT_IMG_HEIGHT / Sprite(e.target).scaleY);
                Sprite(e.target).addChild(rect);
                
                dispatchEvent(new SpritesViewerEvent(Sprite(e.target), SELECTED));
            });

            _cur_y_pos += BT_IMG_HEIGHT + BT_IMG_SHIFT;
        }
    }
}