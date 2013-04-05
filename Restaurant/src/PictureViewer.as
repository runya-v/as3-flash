package {
	import flash.display.Bitmap;
	import flash.display.Loader;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.utils.Timer;
	
	import org.osmf.events.TimeEvent;
	
	/**
	 * @author Velichko R.N.; email:rostislav.vel@gmail.com; (c) 3.2011
	 */
	public class PictureViewer extends EventDispatcher {
		[Embed(source='../../preloader.swf', symbol='tmp_image')]
		private var TmpImage:Class;

		[Embed(source='../../buttons.swf', symbol='left_pview')]
		private var LeftShift:Class;

		[Embed(source='../../buttons.swf', symbol='right_pview')]
		private var RightShift:Class;

		[Embed(source='../../buttons.swf', symbol='back_image')]
		private var BackImage:Class;

		[Embed(source='../../buttons.swf', symbol='up_pview')]
		private var UpPviewImage:Class;

		private static const COMPLETE:String                 = "COMPLETE";
		private static const PREVIEW_IMAGE_LOAD_ERROR:String = "PREVIEW_IMAGE_LOAD_ERROR";
		private static const IMAGE_LOAD_ERROR:String         = "IMAGE_LOAD_ERROR";
		private static const XML_LOAD_ERROR:String           = "XML_LOAD_ERROR";

		private static const HEIGHT:Number         = 150;
		private static const HIDE_HEIGHT:Number    = 20;
		private static const UP_HEIGHT_POS:Number  = 5;
		private static const IMAGE_SHIFT:Number    = 5;
		private static const IMAGE_W:Number        = 180;
		private static const IMAGE_H:Number        = 138;
		private static const HORISONT_SHIFT:Number = 30;
		
        private var m_sprite:Restaurant;

        private var m_exhibitions:Array = [];
		
        private var m_pic_view:Sprite     = new Sprite();
		private var m_back:MovieClip      = new TmpImage();
		private var m_left_but:MovieClip  = new LeftShift();
		private var m_right_but:MovieClip = new RightShift();
		private var m_up_pview:MovieClip  = new UpPviewImage();
		private var m_timer:Timer         = new Timer(5, 1);
		
        private var m_shift:Number = -15;
		
        private var m_is_vert:Boolean  = false;
		private var m_is_left:Boolean  = false;
		private var m_is_right:Boolean = false;

		private var m_max_images_h:Number   = 0;
		private var m_cur_images_pos:Number = 0;
		
		public function PictureViewer(sprite:Restaurant, target:IEventDispatcher=null) {
			super(target);
			m_sprite = sprite;
			
			var req:URLRequest = new URLRequest(m_sprite._url + "/exhibitions");
			var loader:URLLoader = new URLLoader();
			loader.addEventListener(Event.COMPLETE, on_loaded_xml);
			loader.addEventListener(IOErrorEvent.IO_ERROR, on_load_xml_error);
			loader.load(req);
    	}

		private function on_load_xml_error(e:Event):void {
			this.dispatchEvent(new Event(XML_LOAD_ERROR));
		}

		private function on_loaded_xml(e:Event):void {
			e.target.removeEventListener(Event.COMPLETE, on_loaded_xml);
			var xml:XML = new XML(e.target.data);
			
			for each (var xml_ex:XML in xml.exhibition) {
				var ex:Exhibition = new Exhibition(m_sprite);
				ex.m_name = xml_ex.@name;
				ex.m_code = xml_ex.@code;
				ex.m_id = xml_ex.@id;
				ex.m_size_width = xml_ex.size.@width;
				ex.m_size_height = xml_ex.size.@height;
				ex.m_image_name = xml_ex.imagePath;
				ex.m_image_preview_name = xml_ex.previewPath;
				ex.m_view_url = xml_ex.viewUrl;
				ex.load();

				ex.addEventListener(Exhibition.COMPLETE, on_loaded_image);
				ex.addEventListener(Exhibition.IMAGE_LOAD_ERROR, on_load_image_error);
				ex.addEventListener(Exhibition.PREVIEW_IMAGE_LOAD_ERROR, on_load_preview_image_error);
				ex.addEventListener(Exhibition.NEW_URL_ERROR, on_new_image_error);
				m_exhibitions[xml_ex.@id] = ex;
			}
		}
		
		private function on_loaded_image(e:Event):void {
			this.dispatchEvent(new Event(COMPLETE));
		}
		
		private function on_load_image_error(e:Event):void {
			this.dispatchEvent(new Event(IMAGE_LOAD_ERROR));
		}
		
		private function on_load_preview_image_error(e:Event):void {
			this.dispatchEvent(new Event(PREVIEW_IMAGE_LOAD_ERROR));
		}
		
		private function on_new_image_error(e:Event):void {
			this.dispatchEvent(new Event(XML_LOAD_ERROR));
		}
		
		public function resize():void {
			m_pic_view.x  = 0;
			m_pic_view.y  = m_sprite.stage.stageHeight - HIDE_HEIGHT;
			m_back.scaleX = m_sprite.stage.stageWidth;
			m_right_but.x = m_sprite.stage.stageWidth - m_right_but.width;
			m_up_pview.x  = m_sprite.stage.stageWidth / 2;
			
            m_up_pview.gotoAndStop(1);
		}
		
		public function add_image(bitmap:Bitmap):void {
			//m_imgs.push(bitmap);
		}
		
		public function init():void {
			m_back.scaleX = m_sprite.stage.stageWidth / 10;
			m_back.scaleY = HEIGHT / 10;
			m_back.gotoAndStop(1);

			//m_left_but.scaleY = HEIGHT / 10;
			m_left_but.gotoAndStop(1);
			
			//m_right_but.scaleY = HEIGHT / 10;
			m_right_but.x = m_sprite.stage.stageWidth - m_right_but.width;
			m_right_but.gotoAndStop(1);
			var pos:Number = 0;

			m_pic_view.addChild(m_back);
			
			for each (var ex:Exhibition in m_exhibitions) {
				ex.m_image_preview.width = IMAGE_W;
				ex.m_image_preview.height = IMAGE_H;

				ex.m_back.x = pos;
				ex.m_back.y = HIDE_HEIGHT;
				pos += IMAGE_SHIFT + IMAGE_W;
				m_pic_view.addChild(ex.m_back);
			}
			m_max_images_h = pos;
			
			m_pic_view.x = 0;
			m_pic_view.y = m_sprite.stage.stageHeight - HIDE_HEIGHT;
			m_pic_view.addChild(m_left_but);
			m_pic_view.addChild(m_right_but);
			
			m_up_pview.x = m_pic_view.width / 2;
			m_up_pview.y = UP_HEIGHT_POS;
			m_up_pview.gotoAndStop(1);
			m_pic_view.addChild(m_up_pview);
			
			m_back.addEventListener(MouseEvent.MOUSE_OVER, on_back_mouse_over);
			m_back.addEventListener(MouseEvent.MOUSE_OUT,  on_back_mouse_out); 
			m_back.addEventListener(MouseEvent.MOUSE_MOVE, on_back_mouse_move);
			m_back.addEventListener(MouseEvent.MOUSE_DOWN, on_back_mouse_down);
			m_back.addEventListener(MouseEvent.MOUSE_UP,   on_back_mouse_up);  
			
			m_left_but.addEventListener(MouseEvent.MOUSE_OVER, on_left_over);
			m_left_but.addEventListener(MouseEvent.MOUSE_OUT, on_left_out);
			m_left_but.addEventListener(MouseEvent.MOUSE_DOWN, on_left_down);
			
			m_right_but.addEventListener(MouseEvent.MOUSE_OVER, on_right_over);
			m_right_but.addEventListener(MouseEvent.MOUSE_OUT, on_right_out);
			m_right_but.addEventListener(MouseEvent.MOUSE_DOWN, on_right_down);
									
			m_timer.addEventListener(TimerEvent.TIMER_COMPLETE, on_timer);
			m_sprite.addChild(m_pic_view);
			//m_sprite.m_text.text = "init picture view: " + m_pic_view.x + ":" + m_pic_view.y;
		}

		private function on_left_over(e:MouseEvent):void {
			m_left_but.gotoAndStop(2);
			m_is_left = true;
		}
		
		private function on_left_out(e:MouseEvent):void {
			m_left_but.gotoAndStop(1);
			m_is_left = false;
		}
		
		private function on_left_down(e:MouseEvent):void {
			if (m_cur_images_pos < 0) {
				for each (var ex:Exhibition in m_exhibitions) {
					ex.m_back.x += HORISONT_SHIFT;
					m_cur_images_pos += HORISONT_SHIFT;
				}
			}
		}
		
		private function on_right_over(e:MouseEvent):void {
			m_right_but.gotoAndStop(2);
			m_is_right = true;
		}
		
		private function on_right_out(e:MouseEvent):void {
			m_right_but.gotoAndStop(1);
			m_is_right = false;
		}
		
		private function on_right_down(e:MouseEvent):void {
			if (
				(m_pic_view.height - 50) < 
				(m_cur_images_pos + m_pic_view.height + IMAGE_W)) {
				
				for each (var ex:Exhibition in m_exhibitions) {
					ex.m_back.x -= HORISONT_SHIFT;
					m_cur_images_pos -= HORISONT_SHIFT;
				}
			}
		}

		private function on_timer(e:TimerEvent):void {
			if (m_shift < 0) {
				var d:Number = -(m_pic_view.y - m_sprite.stage.stageHeight - HEIGHT) / 20;
                trace(d);
                    
			    // поднять картинки
				if ((m_sprite.m_height - HEIGHT) < (m_pic_view.y - d)) {
					if (d < 1) {
						d = 1;
					}
					m_pic_view.y -= d;
					m_timer.start();
				}
				else {
					m_pic_view.y = m_sprite.m_height - HEIGHT;
					m_shift *= -1;
					m_up_pview.gotoAndStop(3);
				}
			}
			else {
				// скрыть картинки
				if (m_pic_view.y < m_sprite.m_height - HIDE_HEIGHT) {
					d = (m_sprite.stage.stageHeight - HIDE_HEIGHT - m_pic_view.y) / 20;
					if (d < 1) {
						d = 1;
					}
					m_pic_view.y += d
					m_timer.start();
				}
				else {
					m_pic_view.y = m_sprite.stage.stageHeight - HIDE_HEIGHT;
					m_shift *= -1;
					m_up_pview.gotoAndStop(1);
				}
			}
		}

		private function on_back_mouse_over(e:MouseEvent):void {
			if (m_shift < 0) {
				m_up_pview.gotoAndStop(2);	
			}
			else {
				m_up_pview.gotoAndStop(4);	
			}
		}

		private function on_back_mouse_move(e:MouseEvent):void {
			//m_shift = (e.stageX - m_sprite.stage.stageWidth / 2) / 10;
		}
		
		private function on_back_mouse_out(e:MouseEvent):void {
			if (m_shift < 0) {
				m_up_pview.gotoAndStop(1);
			}
			else {
				m_up_pview.gotoAndStop(3);
			}
		}
		
		private function on_back_mouse_down(e:MouseEvent):void {
			m_is_vert = true;
		}
		
		private function on_back_mouse_up(e:MouseEvent):void {
			if (m_is_vert) {
				m_timer.start();	
			}
			m_is_vert = false;
		}
	}
}