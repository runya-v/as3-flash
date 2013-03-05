package {
	import away3d.cameras.HoverCamera3D;
	
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.MouseEvent;
	import flash.external.ExternalInterface;
	import flash.text.TextField;
	
	public class ControllerButton extends EventDispatcher {
        public static const CHANGE:String = "CHANGE";
        
		private var m_scene:Sprite;
		
		private var m_bt_inc:MovieClip;
		private var m_bt_dec:MovieClip;
		private var m_text:TextField;
		private var m_is_inc:Boolean;
		private var m_is_dec:Boolean;

        public var step_:uint;
        private var val_limit_:uint;
        public var value_:uint;
        private var str_:String;
        
		public function ControllerButton(
			scene:Sprite, bt_inc:MovieClip, bt_dec:MovieClip,  
			scale:Number, x:int, y:int, shift:int, str:String, value:uint, val_limit:uint) {
            
            m_is_inc = false;
			m_is_dec = false;
			m_scene = scene;
			
            step_ = 1;
            val_limit_ = val_limit;
            value_ = value; 
			str_ = str;
			
			m_bt_inc = bt_inc;
			m_bt_inc.scaleX = scale;
			m_bt_inc.scaleY = scale;
			m_bt_inc.x = x;
			m_bt_inc.y = y;
			m_bt_inc.gotoAndStop(1);
			
			x += shift;
			
			m_bt_dec = bt_dec;
			m_bt_dec.scaleX = scale;
			m_bt_dec.scaleY = scale;
			m_bt_dec.x = x;
			m_bt_dec.y = y;
			m_bt_dec.gotoAndStop(1);

			x += shift;
			
			m_text = new TextField();
			m_text.x = x - 5;
			m_text.y = y - 15;
			m_text.scaleX = 1.5;
			m_text.scaleY = 1.5;
			m_text.textColor = 0xeeeeff;

			m_text.text = str_ + " " + value_;
			
			m_bt_inc.addEventListener(MouseEvent.MOUSE_OVER, mouse_over_inc);
			m_bt_inc.addEventListener(MouseEvent.MOUSE_OUT, mouse_out_inc);
			m_bt_inc.addEventListener(MouseEvent.MOUSE_DOWN, mouse_down_inc);
			m_bt_inc.addEventListener(MouseEvent.MOUSE_UP, mouse_up_inc);
			
			m_bt_dec.addEventListener(MouseEvent.MOUSE_OVER, mouse_over_dec);
			m_bt_dec.addEventListener(MouseEvent.MOUSE_OUT, mouse_out_dec);
			m_bt_dec.addEventListener(MouseEvent.MOUSE_DOWN, mouse_down_dec);
			m_bt_dec.addEventListener(MouseEvent.MOUSE_UP, mouse_up_dec);

			scene.addChild(m_bt_inc);
			scene.addChild(m_bt_dec);
			scene.addChild(m_text);
		}
		
		public function update():void {
			if (m_is_inc) {
                if (val_limit_ > value_ + step_) {
                    value_ += step_;
                }
                else {
                    value_ = val_limit_; 
                }
			}
			else if (m_is_dec) {
                if ((value_ > step_) && (0 < value_ - step_)) {
                    value_ -= step_;
                }
                else {
                    value_ = 0;
                }
			}
            m_text.text = str_ + " " + value_;
            
            this.dispatchEvent(new Event(ControllerButton.CHANGE));
		}
		
		private function mouse_over_inc(e:Event):void {
			
		}
		
		private function mouse_out_inc(e:Event):void {
		}

		private function mouse_down_inc(e:Event):void {
			m_bt_inc.gotoAndStop(2);
			m_is_inc = true;
            update();
		}

		private function mouse_up_inc(e:Event):void {
			m_bt_inc.gotoAndStop(1);
			m_is_inc = false;
            update();
		}

		private function mouse_over_dec(e:Event):void {
		}
		
		private function mouse_out_dec(e:Event):void {
		}

		private function mouse_down_dec(e:Event):void {
			m_bt_dec.gotoAndStop(2);
			m_is_dec = true;
            update();
		}

		private function mouse_up_dec(e:Event):void {
			m_bt_dec.gotoAndStop(1);
			m_is_dec = false;
            update();
		}
	}
}