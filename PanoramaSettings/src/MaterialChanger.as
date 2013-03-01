package {
	import away3d.core.base.Object3D;
	
	import flash.display.Sprite;
	import flash.events.TimerEvent;
	import flash.utils.Timer;

	public class MaterialChanger {
		private var m_sprite:Sprite;
		private var m_timer:Timer;
		private var m_rate:Number;
		private var m_alpha_rate:Number;
		private var m_obj:Object3D;

		public function MaterialChanger(sprite:ChangeImages, delta_time:Number, rate:Number, obj:Object3D) {
			m_sprite = sprite;
			m_rate = rate;
			m_obj = obj;
			m_alpha_rate = ((1.0 * delta_time) / rate);
			
			// creates a new five-second Timer 
			m_timer = new Timer((1000 * delta_time), (rate > 0 ? rate : -rate)); 
			
			// designates listeners for the interval and completion events 
			m_timer.addEventListener(TimerEvent.TIMER, onTick); 
			m_timer.addEventListener(TimerEvent.TIMER_COMPLETE, onTimerComplete); 
		} 
		
		public function start():void {
			m_timer.start(); 
		}
		
		public function onTick(event:TimerEvent):void {
			m_obj.alpha += m_alpha_rate;
			//trace("tick " + event.target.currentCount); 
		} 
		
		public function onTimerComplete(event:TimerEvent):void {
			m_obj.alpha = 1; //(m_rate > 0 ? 1.0 : 0.0);
			//trace("Time's Up!"); 
		} 
	}
}