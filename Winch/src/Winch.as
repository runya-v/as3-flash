package {
    import flash.display.Loader;
    import flash.display.LoaderInfo;
    import flash.display.MovieClip;
    import flash.display.Sprite;
    import flash.display.StageAlign;
    import flash.display.StageScaleMode;
    import flash.events.Event;
    import flash.events.IOErrorEvent;
    import flash.events.MouseEvent;
    import flash.events.SecurityErrorEvent;
    import flash.events.TimerEvent;
    import flash.net.URLRequest;
    import flash.system.ApplicationDomain;
    import flash.system.LoaderContext;
    import flash.system.Security;
    import flash.system.SecurityDomain;
    import flash.text.TextField;
    import flash.ui.Mouse;
    import flash.ui.MouseCursor;
    import flash.utils.Timer;
    
    import org.osmf.events.TimeEvent;
    
    [SWF(width="800", height="600", frameRate="60", backgroundColor="#000000")]
    public class Winch extends Sprite {
        [Embed(source='../../preloader.swf', symbol='loader')]
        private var Preloader:Class;
        /*
        [Embed(source='../../Cam_01.swf', symbol='Cam_01')]
        private var Hoist_1:Class;
        
        [Embed(source='../../Cam_02.swf', symbol='Cam_02')]
        private var Hoist_2:Class;
        
        [Embed(source='../../Cam_03.swf', symbol='Cam_03')]
        private var Hoist_3:Class;
        //*/      
        private static const MY_DOWN:String = "MY_DOWN";
        private static const MY_UP:String   = "MY_UP";
        private static const MY_OVER:String = "MY_OVER";
        private static const MY_MOVE:String = "MY_MOVE";
        
        public static const URL:String = "http://www.kmzlift.ru/flash/winch";
        //public static const URL:String = "http://kmzlift.centrida.lclients.ru/flash/winch";
        private static const VERSION:String = "2.5";
        
        private var _url:String = URL;
        private var _preloader:MovieClip;
        private var _console:Console;
        private var _bt_cons:Sprite;
        
        private var _hoist_1:MovieClip;
        private var _hoist_2:MovieClip;
        private var _hoist_3:MovieClip;
        private var _is_mouse_dovn:Boolean = false;
        private var _old_mouse_x:Number = 0;
        private var _old_mouse_y:Number = 0;
        private var _shift_x:Number = 0;
        private var _shift_y:Number = 0;
        private var _width:Number = 0;
        private var _height:Number = 0;
        private var _old_anim_id:uint = 1;
        private var _anim_id:uint = 1;
        private var _this:Sprite;
        private var _rotate_count:int = 0;
        
        public function Winch() {
            if (stage) {
                stage.scaleMode = StageScaleMode.NO_SCALE;
                stage.align = StageAlign.TOP_LEFT;
                
                for (var name:String in this.loaderInfo.parameters) {
                    if (name =="Domain") {
                        _url= this.loaderInfo.parameters[name];
                    }
                }
                
                _width  = this.stage.stageWidth;
                _height = this.stage.stageHeight;

                init();
            }
            else {
                this.addEventListener(Event.ADDED_TO_STAGE, init);
            }
        }
        
        private function init():void {
            this.removeEventListener(Event.ADDED_TO_STAGE, init);
            
            Mouse.cursor = MouseCursor.BUTTON;
            
            _preloader = new Preloader();
            _preloader.scaleX = 2;
            _preloader.scaleY = 2;
            _preloader.x = this.stage.stageWidth / 2;
            _preloader.y = this.stage.stageHeight / 2;
            this.addChild(_preloader);
                      
            Security.loadPolicyFile(_url + "/crossdomain.xml");
            
            var ldr_02:Loader = new Loader(); 
            var ldrReq_02:URLRequest = new URLRequest(_url + "/Cam_02.swf");
            this.addChild(ldr_02);
            
            ldr_02.addEventListener(SecurityErrorEvent.SECURITY_ERROR, function(e:SecurityErrorEvent):void {
                removeChild(_preloader);
                _console.addMessage("ERR: Sequrity error by resurce loading. " + e);
            });
            
            ldr_02.addEventListener(IOErrorEvent.IO_ERROR, function(e:IOErrorEvent):void {
                removeChild(_preloader);
                _console.addMessage("ERR: IO error by resurce loading. " + e);
            });
            
            ldr_02.contentLoaderInfo.addEventListener(Event.COMPLETE, function(e:Event):void {
                _console.addMessage("Extern data is Loaded.");
                
                var loaderInfo:LoaderInfo = LoaderInfo(e.target);
                var loadedAppDomain:ApplicationDomain = loaderInfo.applicationDomain;
                var SymbolClass2:Class = Class(loadedAppDomain.getDefinition("Cam_02"));
                _console.addMessage(SymbolClass2.toString());
                
                if (SymbolClass2) {
                    _hoist_2 = MovieClip(new SymbolClass2());
                    
                    if (_width) {
                        _hoist_2.scaleX = _width / _hoist_2.width;
                    }
                    
                    if (_height) {
                        _hoist_2.scaleY = _height / _hoist_2.height;
                    }
                    _hoist_2.stop();
                    addChild(_hoist_2);
                }
               
                _console.addMessage("Init scene 02.");
            });

            ldr_02.load(ldrReq_02);

            var ldr_01:Loader = new Loader(); 
            var ldrReq_01:URLRequest = new URLRequest(_url + "/Cam_01.swf");
            this.addChild(ldr_01);
            
            ldr_01.addEventListener(SecurityErrorEvent.SECURITY_ERROR, function(e:SecurityErrorEvent):void {
                removeChild(_preloader);
                _console.addMessage("ERR: Sequrity error by resurce loading. " + e);
            });
            
            ldr_01.addEventListener(IOErrorEvent.IO_ERROR, function(e:IOErrorEvent):void {
                removeChild(_preloader);
                _console.addMessage("ERR: IO error by resurce loading. " + e);
            });
            
            ldr_01.contentLoaderInfo.addEventListener(Event.COMPLETE, function(e:Event):void {
                _console.addMessage("Extern data is Loaded.");

                var loaderInfo:LoaderInfo = LoaderInfo(e.target);
                var loadedAppDomain:ApplicationDomain = loaderInfo.applicationDomain;
                var SymbolClass1:Class = Class(loadedAppDomain.getDefinition("Cam_01"));
                _console.addMessage(SymbolClass1.toString());
                
                if (SymbolClass1) {
                    _hoist_1 = MovieClip(new SymbolClass1());

                    if (_width) {
                        _hoist_1.scaleX =  _width / _hoist_1.width;
                    }
                    
                    if (_height) {
                        _hoist_1.scaleY = _height / _hoist_1.height;
                    }
                    _hoist_1.stop();
                    addChild(_hoist_1);
                }
               
                _console.addMessage("Init scene 01.");
            });
            
            ldr_01.load(ldrReq_01);

            var ldr_03:Loader = new Loader(); 
            var ldrReq_03:URLRequest = new URLRequest(_url + "/Cam_03.swf");
            this.addChild(ldr_03);
            
            ldr_03.addEventListener(SecurityErrorEvent.SECURITY_ERROR, function(e:SecurityErrorEvent):void {
                removeChild(_preloader);
                _console.addMessage("ERR: Sequrity error by resurce loading. " + e);
            });
            
            ldr_03.addEventListener(IOErrorEvent.IO_ERROR, function(e:IOErrorEvent):void {
                removeChild(_preloader);
                _console.addMessage("ERR: IO error by resurce loading. " + e);
            });
            
            ldr_03.contentLoaderInfo.addEventListener(Event.COMPLETE, function(e:Event):void {
                _console.addMessage("Extern data is Loaded.");

                var loaderInfo:LoaderInfo = LoaderInfo(e.target);
                var loadedAppDomain:ApplicationDomain = loaderInfo.applicationDomain;
                var SymbolClass:Class = Class(loadedAppDomain.getDefinition("Cam_03"));
                _console.addMessage(SymbolClass.toString());
                
                if (SymbolClass) {
                    _hoist_3 = MovieClip(new SymbolClass());

                    if (_width) {
                        _hoist_3.scaleX = _width / _hoist_3.width;
                    }
                    
                    if (_height) {
                        _hoist_3.scaleY = _height / _hoist_3.height;
                    }
                    _hoist_3.stop();
                    addChild(_hoist_3);
                }
                
                _console.addMessage("Init scene 03.");
                removeChild(_preloader);
            });
            
            ldr_03.load(ldrReq_03);

            //*/
            /*
            _hoist_1 = new Hoist_1();
            _hoist_1.stop();
            _hoist_1.visible = false;
            addChild(_hoist_1);
            
            _hoist_2 = new Hoist_2();
            _hoist_2.stop();
            addChild(_hoist_2);
            
            _hoist_3 = new Hoist_3();
            _hoist_3.stop();
            _hoist_3.visible = false;
            addChild(_hoist_3);
            //*/
            this.addEventListener(MouseEvent.MOUSE_DOWN, function(e:MouseEvent):void {
                Mouse.cursor = MouseCursor.HAND;
                _is_mouse_dovn = true;
            });
            
            this.addEventListener(MouseEvent.MOUSE_UP, function(e:MouseEvent):void {
                Mouse.cursor = MouseCursor.BUTTON;
                _is_mouse_dovn = false;
                _old_mouse_x = 0;
                _old_mouse_y = 0;
            });
            
            this.addEventListener(MouseEvent.MOUSE_OVER, function(e:MouseEvent):void {
                Mouse.cursor = MouseCursor.BUTTON;
                if (_old_anim_id == _anim_id) {
                    _is_mouse_dovn = false;
                }
                _old_mouse_x = 0;
                _old_mouse_y = 0;
            });
            
            addEventListener(MouseEvent.MOUSE_MOVE, function(e:MouseEvent):void {
                if (_is_mouse_dovn) {
                    if (_old_mouse_x == 0) {
                        _old_mouse_x = e.stageX;
                    }
                    
                    if (_old_mouse_y == 0) {
                        _old_mouse_y = e.stageY;
                    }
                    
                    _shift_x += (e.stageX - _old_mouse_x) * 4;
                    _shift_y += (e.stageY - _old_mouse_y);
                    
                    _old_mouse_x = e.stageX;
                    _old_mouse_y = e.stageY;
                }
            });
            
            addEventListener(Event.ENTER_FRAME, function(e:Event):void {
                if ( ! _is_mouse_dovn && 0 >= _rotate_count && _hoist_1 && _hoist_2 && _hoist_3)
                {
                    _rotate_count = 2;
                    if (_hoist_2.currentFrame < _hoist_2.totalFrames) {
                        _hoist_1.nextFrame();
                        _hoist_2.nextFrame();
                        _hoist_3.nextFrame();
                    }
                    else {
                        _hoist_1.gotoAndStop(1);
                        _hoist_2.gotoAndStop(1);
                        _hoist_3.gotoAndStop(1);
                    }
                }
                else {
                    --_rotate_count;
                }
                
                if (0 > _shift_x) {
                    ++_shift_x;
                }
                
                if (0 < _shift_x) {
                    --_shift_x;
                }
                
                if (0 > _shift_y) {
                    ++_shift_y;
                }
                
                if (0 < _shift_y) {
                    --_shift_y;
                }
                
                if (_hoist_2 && _hoist_2 && _hoist_3) {
                    if (-1 > _shift_x) {
                        _shift_x = 0;
                        
                        if (_hoist_2.currentFrame < _hoist_2.totalFrames) {
                            _hoist_1.nextFrame();
                            _hoist_2.nextFrame();
                            _hoist_3.nextFrame();
                        }
                        else {
                            _hoist_1.gotoAndStop(1);
                            _hoist_2.gotoAndStop(1);
                            _hoist_3.gotoAndStop(1);
                        }
                        _console.addMessage("Next frame is: " + _hoist_2.currentFrame);
                    }
                    
                    if (1 < _shift_x) {
                        _shift_x = 0;
                        
                        if (1 < _hoist_2.currentFrame) {
                            _hoist_1.prevFrame();
                            _hoist_2.prevFrame();
                            _hoist_3.prevFrame();
                        }
                        else {
                            _hoist_1.gotoAndStop(_hoist_1.totalFrames);
                            _hoist_2.gotoAndStop(_hoist_2.totalFrames);
                            _hoist_3.gotoAndStop(_hoist_3.totalFrames);
                        }
                        _console.addMessage("Prev frame is: " + _hoist_2.currentFrame);
                    }
                    
                    _old_anim_id = _anim_id;
                    
                    if (-40 > _shift_y) {
                        _shift_y = 0;
                        
                        if (0 < _anim_id) {
                            --_anim_id;
                        }
                    }
                    
                    if (40 < _shift_y) {
                        _shift_y = 0;
                        
                        if (3 > _anim_id) {
                            ++_anim_id;
                        }
                    }
                    
                    switch (_anim_id) {
                        case 0: 
                            _hoist_1.visible = true;
                            _hoist_2.visible = false;
                            _hoist_3.visible = false;
                            break;
                        case 1: 
                            _hoist_1.visible = false;
                            _hoist_2.visible = true;
                            _hoist_3.visible = false;
                            break;
                        case 2: 
                            _hoist_1.visible = false;
                            _hoist_2.visible = false;
                            _hoist_3.visible = true;
                            break;
                    }
                }
            });
            
            initConsole();
        }
        
        private function initConsole():void {
            _console = new Console(20, 20, this.stage.stageWidth * 0.6, this.stage.stageHeight * 0.9);
            _console.visible = false;
            this.addChild(_console);
            
            _bt_cons = new Sprite;
            _bt_cons.graphics.beginFill(0x0000ff, 0.05);
            _bt_cons.graphics.drawRect(0, 0, 20, 20);
            _bt_cons.graphics.endFill();
            this.addChild(_bt_cons);
            
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
    }
}