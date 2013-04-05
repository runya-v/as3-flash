package
{
    import flash.events.Event;
    
    public class MessageEvent extends Event {
        public var _msg:String = new String;
        
        public function MessageEvent(type:String, msg:String, bubbles:Boolean=false, cancelable:Boolean=false) {
            super(type, bubbles, cancelable);
            _msg = msg;
        }
    }
}