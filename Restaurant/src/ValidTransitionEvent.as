package {
	import flash.events.Event;
	
	/**
	 * @author Velichko R.N.; email:rostislav.vel@gmail.com; (c) 8.2011
	 */
	public class ValidTransitionEvent extends Event {
		public var id_:int   = 0;
		public var from_:int = 0;
		public var to_:int   = 0;
		
		public function ValidTransitionEvent(
			id:int, from:int, to:int,
			type:String, bubbles:Boolean=false, cancelable:Boolean=false) {
			
			id_   = id;
			from_ = from;
			to_   = to;
			
			super(type, bubbles, cancelable);
		}
	}
}