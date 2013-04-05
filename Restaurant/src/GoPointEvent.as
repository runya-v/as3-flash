package {
    import away3d.core.base.Object3D;
    
    import flash.events.Event;
    
    public class GoPointEvent extends Event {
        public var _cursor_back:Object3D;
        public var _cursor:Object3D;
        
        public function GoPointEvent(type:String, cursor_back:Object3D, cursor:Object3D, bubbles:Boolean=false, cancelable:Boolean=false) {
            super(type, bubbles, cancelable);

            _cursor_back = cursor_back;
            _cursor = cursor;
        }
    }
}