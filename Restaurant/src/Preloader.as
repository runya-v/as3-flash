package {
	import flash.display.MovieClip;

	/**
	 * @author Velichko R.N.; email:rostislav.vel@gmail.com; (c) 12.2010
	 */
	public class Preloader {
		[Embed(source='../../buttons.swf', symbol='bt_cam_move')]
		private var ploader:Class;

		public var MAX_STEPS:Number;
		public var m_movie:MovieClip;
		private var m_steps:Number;
		private var m_step:Number;
		private var m_count:Number = 0;
		private var m_width:int;
		private var m_height:int;

		public function Preloader(width:int, height:int) {
			m_movie = new ploader();
			m_movie.gotoAndStop(1);
			m_movie.scaleX = 0.2;
			m_movie.scaleY = 0.1;
			m_movie.x = width / 2;
			m_movie.y = -2;
			MAX_STEPS = 7;
		}
		
		public function init(steps:Number):void {
			m_steps = steps;
			m_step = steps / MAX_STEPS;
			trace("ms=" + MAX_STEPS + "; steps= " + m_steps + "; step= " + m_step);
		}
		
		public function next():void {
			m_count++;
			m_movie.scaleX = (m_count / m_step);
			trace("sx=" + m_movie.scaleX);
			//m_movie.scaleY = 0.1;
			//m_movie.gotoAndStop(m_count / m_step);
		}
		
		public function complete():void {
			//m_movie.gotoAndStop(MAX_STEPS);
		}
	}
}