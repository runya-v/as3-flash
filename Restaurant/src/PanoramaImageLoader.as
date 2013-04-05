package {
	import away3d.core.utils.Cast;
	import away3d.materials.BitmapMaterial;
	
	import flash.display.Bitmap;
	import flash.display.Loader;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.events.SecurityErrorEvent;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	
	/**
	 * @author Velichko R.N.; email:rostislav.vel@gmail.com; (c) 8.2011
	 */
	public class PanoramaImageLoader extends EventDispatcher {
        public static const ERROR_SECURITY_LOADING_IMAGE:String = "ERROR_SECURITY_LOADING_IMAGE";
        public static const ERROR_LOADING_IMAGE:String          = "ERROR_LOADING_IMAGE";

        public static const LOADED_IMAGE:String = "LOADED_IMAGE";
		
        public var _id:int;
        public var _url_image:String;
		public var _material:BitmapMaterial;
		
		private var _img_loader:Loader;

		public function PanoramaImageLoader(target:IEventDispatcher = null) {
            super(target);
        }
        
        public function load(id:int, url_image:String):void {
            _id = id;
            _url_image = url_image;

            _img_loader = new Loader();
            _img_loader.contentLoaderInfo.addEventListener(SecurityErrorEvent.SECURITY_ERROR, function(e:SecurityErrorEvent):void {
                dispatchEvent(new PanoramaImageEvent(ERROR_SECURITY_LOADING_IMAGE, _id, e.text, null));
            });
            
            _img_loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, function(e:IOErrorEvent):void {
                dispatchEvent(new PanoramaImageEvent(ERROR_LOADING_IMAGE, _id, e.text, null));
            });
            
			_img_loader.contentLoaderInfo.addEventListener(Event.COMPLETE, function(e:Event):void {
                dispatchEvent(new PanoramaImageEvent(LOADED_IMAGE, _id, _url_image, Bitmap(_img_loader.content)));
            });
            
			_img_loader.load(new URLRequest(url_image));
		}
	}
}