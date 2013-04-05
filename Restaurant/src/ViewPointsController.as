package {
	import flash.display.Loader;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.geom.Vector3D;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.net.URLRequestMethod;
	import flash.system.Security;
	import flash.system.SecurityPanel;

 
	/**
	 * @author Velichko R.N.; email:rostislav.vel@gmail.com; (c) 12.2010
	 */
	public class ViewPointsController extends EventDispatcher {
		public static const NUM_VIEW_POINTS:String = "NUM_VIEW_POINTS";
		public static const LOAD_COMPLETE:String = "LOAD_COMPLETE";
		public static const LOAD_STEP:String = "LOAD_STEP";
		public static const LOAD_ERROR:String = "LOAD_ERROR";
		
		private var m_sprite:Restaurant;
		private var m_url:String;
		private var m_sid:String;
		private var m_points_count:int = 0;
		public var m_go_points:Array = [];
		public var m_gp_result_count:int = 0;
		public var m_num_elements:int = 0;
		public var m_first_point:int = 0;
 
		public function ViewPointsController(sprite:Restaurant, url:String, session_id:String) {
			m_sprite = sprite;
			m_url = url;
			m_sid = session_id;
			
			Security.loadPolicyFile("http://static.vi-ex.ru/crossdomain.xml");
		}
		
		public function load():void {
			m_sprite.console_.addMessage("cmd:`" + m_url + "/floor/" + m_sid + "/viewpoints`");
			var req:URLRequest = new URLRequest(m_url + "/floor/" + m_sid + "/viewpoints");
			var loader:URLLoader = new URLLoader();
			loader.addEventListener(Event.COMPLETE, loaded_viewpoints);
	        loader.addEventListener(IOErrorEvent.IO_ERROR, load_error);
			loader.load(req);
		}
 
		private function loaded_viewpoints(e:Event):void {
	        e.target.removeEventListener(IOErrorEvent.IO_ERROR, load_error);
			e.target.removeEventListener(Event.COMPLETE, loaded_viewpoints);
			var xml:XML = new XML(e.target.data);
		
			m_num_elements = 0;
			
			for each (var viewpoint:XML in xml.viewpoint) {
				m_num_elements++;
			}
			this.dispatchEvent(new Event(ViewPointsController.NUM_VIEW_POINTS));
			
			m_first_point = xml.viewpoint[0].@id;
			m_sprite.console_.addMessage("recv " + m_num_elements + " viewpoints");
			
			for each (var point:XML in xml.viewpoint) {
				var go:GoPoint = new GoPoint(
					m_sprite,
					"http://static.vi-ex.ru/viewpoints" + point.@img, 
					new Vector3D(point.point.@x, 0, point.point.@y));
				go.addEventListener(GoPoint.GO_COMPLETE, img_complete);
				go.addEventListener(GoPoint.GO_ERROR, load_error);
				go.load();
				go.m_my_id = point.@id; 
				m_go_points[go.m_my_id] = go;
				
				if (point.@first) {
					m_sprite.console_.addMessage(
						"get: " + "http://static.vi-ex.ru/viewpoints" + point.@img + 
						" for first " + point.@id + " viewpoint");
					m_first_point = point.@id;
				}
				else {
					m_sprite.console_.addMessage(
						"get: " + "http://static.vi-ex.ru/viewpoints" + point.@img + 
						" for " + point.@id + " viewpoint");
				}
				
				// загрузка для навигационной карты
				m_sprite.nmap_.addCamera(point.@id, point.point.@x, point.point.@y);
			}
			
			m_sprite.console_.addMessage("cmd:`" + m_url + "/floor/" + m_sid + "/transitions`");
			var req:URLRequest = new URLRequest(m_url + "/floor/" + m_sid + "/transitions");
			var loader:URLLoader = new URLLoader();
			loader.addEventListener(Event.COMPLETE, loaded_transitions);
	        loader.addEventListener(IOErrorEvent.IO_ERROR, load_error);
			loader.load(req);
		}
		
		private function loaded_transitions(e:Event):void {
			m_sprite.console_.addMessage("recv:`transitions`");
			e.target.removeEventListener(Event.COMPLETE, loaded_transitions);
			e.target.removeEventListener(IOErrorEvent.IO_ERROR, load_error);
			var xml:XML = new XML(e.target.data);

			for each (var transition:XML in xml.transition) {
				var from:GoPoint = m_go_points[transition.@from];
				var to:GoPoint = m_go_points[transition.@to];
				m_sprite.console_.addMessage(
					"transitions from: " + transition.@from + " -> to: " + transition.@to);
					
				if (from && to && (from != to)) {
					from.add_to_point_id(transition.@to, to.m_my_vec);
					to.add_to_point_id(transition.@from, from.m_my_vec);

					// загрузка для навигационной карты
					m_sprite.nmap_.addTransition(transition.@id, transition.@from, transition.@to);
				}
			}
			var cam:Camera = m_sprite.nmap_.cameras_[m_first_point];
			//while (1) {
				if (m_gp_result_count == m_num_elements) {
					this.dispatchEvent(new Event(ViewPointsController.LOAD_COMPLETE));
					m_sprite.console_.addMessage("viewpoints is loading complete");
					//break;
				}
			//}
		}
		
		private function img_complete(e:Event):void {
			++m_gp_result_count;
			e.target.removeEventListener(GoPoint.GO_COMPLETE, img_complete);
			e.target.removeEventListener(GoPoint.GO_ERROR, load_error);
		}
		
		private function load_error(e:Event):void {
			++m_gp_result_count;
			m_sprite.m_text.text = "Can`t load view points.";
			m_sprite.console_.addMessage("Can`t load view points.");
		}
	}
}