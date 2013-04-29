package
{
    import flash.display.Sprite;
    import flash.events.Event;
    
    public class SpritesViewerEvent extends Event {
        public var _target:Sprite;
        
        public function SpritesViewerEvent(target:Sprite, type:String, bubbles:Boolean=false, cancelable:Boolean=false) {
            super(type, bubbles, cancelable);
            
            _target = target;
        }
    }
}