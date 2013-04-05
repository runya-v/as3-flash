package {
	import flash.display.Bitmap;
	import flash.events.Event;
	
	/**
	 * @author Velichko R.N.; email:rostislav.vel@gmail.com; (c) 8.2011
	 */
	public class PanoramaImageEvent extends Event {
		public var _id:int;
        public var _url_image:String;
		public var _bitmap:Bitmap;
		
		public function PanoramaImageEvent(type:String, id:int, url_image:String, bitmap:Bitmap, bubbles:Boolean=false, cancelable:Boolean=false) {
			super(type, bubbles, cancelable);
			
            _id = id;
			_url_image = url_image;
            _bitmap = bitmap;
		}
	}
}