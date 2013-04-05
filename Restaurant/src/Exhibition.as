package {
	import away3d.cameras.SpringCam;
	
	import flash.display.Bitmap;
	import flash.display.Loader;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.events.MouseEvent;
	import flash.net.URLRequest;
	import flash.net.navigateToURL;
	import flash.ui.Mouse;
	import flash.ui.MouseCursor;
	
	/**
	 * @author Velichko R.N.; email:rostislav.vel@gmail.com; (c) 3.2011
	 */
	public class Exhibition extends EventDispatcher {
		public static const COMPLETE:String = "COMPLETE";
		public static const IMAGE_LOAD_ERROR:String = "IMAGE_LOAD_ERROR";
		public static const PREVIEW_IMAGE_LOAD_ERROR:String = "PREVIEW_IMAGE_LOAD_ERROR";
		public static const NEW_URL_ERROR:String = "NEW_URL_ERROR";
		public static const IMAGE_URL:String = "http://vi-ex.ru";

		private var m_sprite:Restaurant;

		public var m_name:String = new String();
		public var m_code:String = new String(); 
		public var m_id:int = 0;
		public var m_size_width:Number;
		public var m_size_height:Number;
		public var m_image_name:String = new String();
		public var m_image_preview_name:String = new String();
		public var m_view_url:String = new String();
		public var m_img_loader:Loader = new Loader();
		public var m_back:Sprite = new Sprite();
		public var m_image:Bitmap = new Bitmap();
		public var m_image_preview:Bitmap = new Bitmap();

		public function Exhibition(sprite:Restaurant) {
			m_sprite = sprite;
			
			m_back.addEventListener(MouseEvent.MOUSE_OVER, on_mouse_over);
			m_back.addEventListener(MouseEvent.MOUSE_OUT, on_mouse_out);
			m_back.addEventListener(MouseEvent.MOUSE_DOWN, on_mouse_down);
		}

		private function on_mouse_over(e:MouseEvent):void {
			Mouse.cursor = MouseCursor.BUTTON;	
		}
		
		private function on_mouse_out(e:MouseEvent):void {
			Mouse.cursor = MouseCursor.AUTO;	
		}
		
		private function on_mouse_down(e:MouseEvent):void {
			var request:URLRequest = new URLRequest(m_view_url);

			try {
				navigateToURL(request, '_blank');
			} 
			catch (e:Error) {
				this.dispatchEvent(new Event(NEW_URL_ERROR));
			}
		}

		public function load():void {
			m_img_loader = new Loader();
			m_img_loader.contentLoaderInfo.addEventListener(Event.COMPLETE, on_loaded_preview);
			m_img_loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, on_load_preview_error);
			m_img_loader.load(new URLRequest(IMAGE_URL + m_image_preview_name));
			//trace(IMAGE_URL + m_image_preview_name);
		}

		private function on_loaded_preview(e:Event):void {
			m_img_loader.contentLoaderInfo.removeEventListener(Event.COMPLETE, on_loaded_preview);
			m_img_loader.contentLoaderInfo.removeEventListener(IOErrorEvent.IO_ERROR, on_load_preview_error);
			m_image_preview = m_img_loader.content as Bitmap;
			m_back.addChild(m_image_preview);

			m_img_loader.contentLoaderInfo.addEventListener(Event.COMPLETE, on_loaded);
			m_img_loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, on_load_error);
			m_img_loader.load(new URLRequest(IMAGE_URL + m_image_name));
			//trace(IMAGE_URL + m_image_name);
		}

		private function on_loaded(e:Event):void {
			m_img_loader.contentLoaderInfo.removeEventListener(Event.COMPLETE, on_loaded);
			m_img_loader.contentLoaderInfo.removeEventListener(IOErrorEvent.IO_ERROR, on_load_error);
			m_image = m_img_loader.content as Bitmap;
			
			this.dispatchEvent(new Event(COMPLETE));
		}
		
		private function on_load_error(e:Event):void {
			this.dispatchEvent(new Event(IMAGE_LOAD_ERROR));
		}

		private function on_load_preview_error(e:Event):void {
			this.dispatchEvent(new Event(PREVIEW_IMAGE_LOAD_ERROR));
		}
	}
}