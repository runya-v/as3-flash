package {
	import flash.display.Loader;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.events.SecurityErrorEvent;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.system.Security;
	
	//import org.osmf.image.ImageLoader;
	
	/**
	 * @author Velichko R.N.; email:rostislav.vel@gmail.com; (c) 6.2011
	 */
	public class SceneLoader extends EventDispatcher {
        public static const ERROR_SECURITY_LOADING_SCENE:String = "ERROR_SECURITY_LOADING_SCENE";
        public static const ERROR_LOADING_SCENE:String          = "ERROR_LOADING_SCENE";
        public static const ERROR_SECURITY_LOADING_IMAGE:String = "ERROR_SECURITY_LOADING_SCENE";
        public static const ERROR_LOADING_IMAGE:String          = "ERROR_LOADING_SCENE";

        public static const LOADED_SCENE_NAME:String = "LOADED_SCENE_XML";
        public static const LOADED_VIEWPOINT:String  = "LOADED_VIEWPOINT";
        public static const LOADED_TRANSITION:String = "LOADED_TRANSITION";
        public static const LOADED_IMAGE:String      = "LOADED_IMAGE";
        public static const LOADED_COMPLETE:String   = "LOADED_COMPLETE"; 
		
		public function SceneLoader(target:IEventDispatcher = null) {
            super(target);
        }
        
        public function load(url:String):void {
            var scene_xml_req:URLRequest   = new URLRequest(url);
            var scene_xml_loader:URLLoader = new URLLoader();

            scene_xml_loader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, function(e:SecurityErrorEvent):void {
                dispatchEvent(new MessageEvent(ERROR_SECURITY_LOADING_SCENE, e.text));
            });
            
            scene_xml_loader.addEventListener(IOErrorEvent.IO_ERROR, function(e:IOErrorEvent):void {
                dispatchEvent(new MessageEvent(ERROR_LOADING_SCENE, e.text));
            });
            
            scene_xml_loader.addEventListener(Event.COMPLETE, function(e:Event):void {
                var scene:XML = new XML(e.target.data);
                
                dispatchEvent(new MessageEvent(LOADED_SCENE_NAME, scene.@name));
                var msg:String;
                var first_id:int = 0;
                
                for each (var vp:XML in scene.viewpoints.viewpoint) {
                    if (vp.@first == "true") {
                        first_id = vp.@id;
                    }
                    dispatchEvent(new MessageEvent(LOADED_VIEWPOINT, (vp.@id + ";" + vp.@img + ";" + vp.@first + ";" + vp.point.@x + ";" + vp.point.@y)));
                }
                
                for each (var trsn:XML in scene.transitions.transition) {
                    dispatchEvent(new MessageEvent(LOADED_TRANSITION, (trsn.@id + ";" + trsn.@from + ";" + trsn.@to)));
                }
                dispatchEvent(new MessageEvent(LOADED_COMPLETE, String(first_id)));
            });
            
            scene_xml_loader.load(scene_xml_req);
        }
	}
}