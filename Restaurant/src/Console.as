package {
	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import flash.ui.Mouse;
	import flash.ui.MouseCursor;
	
	import flashx.textLayout.operations.ModifyInlineGraphicOperation;
	
	public class Console extends Sprite {
		[Embed(source='../../buttons.swf', symbol='up_pview')]
		private var UpPviewImage:Class;

		private static const TEXT_SIZE:int = 20;
		private static const SUBLINE_SIZE:int = -4;
		
		private var pos_:int = 0;
		private var back_:Sprite = new Sprite;
		private var mask_:Sprite = new Sprite;
		private var up_:Sprite   = new Sprite;
		private var down_:Sprite = new Sprite;
		
		public function Console(x:int, y:int, w:int, h:int) {
			this.graphics.beginFill(0x212970, 0.5);
			this.graphics.drawRect(0, 0, w, h);
			this.graphics.endFill();
			
			mask_.graphics.beginFill(0x000000);
			mask_.graphics.drawRect(0, 0, w, h);
			mask_.graphics.endFill();
			
			up_.graphics.beginFill(0x0000ff, 0.1);
			up_.graphics.drawRect(0, 0, 20, 20);
			up_.graphics.endFill();
			up_.x = w - 20;
			up_.y = 0;
			var up_view:MovieClip = new UpPviewImage;
			up_view.gotoAndStop(1);
			up_view.x = 10;
			up_view.y = 6;
			up_.addChild(up_view);
			
			up_.addEventListener(MouseEvent.MOUSE_OVER, function(e:MouseEvent):void {
				Mouse.cursor = MouseCursor.BUTTON;	
			})

			up_.addEventListener(MouseEvent.MOUSE_OUT, function(e:MouseEvent):void {
				Mouse.cursor = MouseCursor.AUTO;	
			})

			up_.addEventListener(MouseEvent.MOUSE_DOWN, onUp);

			down_.graphics.beginFill(0x0000ff, 0.1);
			down_.graphics.drawRect(0, 0, 20, 20);
			down_.graphics.endFill();
			down_.x = w - 20;
			down_.y = h - 20;
			var down_view:MovieClip = new UpPviewImage;
			down_view.gotoAndStop(3);
			down_view.x = 10;
			down_view.y = 7;
			down_.addChild(down_view);

			down_.addEventListener(MouseEvent.MOUSE_OVER, function(e:MouseEvent):void {
				Mouse.cursor = MouseCursor.BUTTON;	
			})
			
			down_.addEventListener(MouseEvent.MOUSE_OUT, function(e:MouseEvent):void {
				Mouse.cursor = MouseCursor.AUTO;	
			})

			down_.addEventListener(MouseEvent.MOUSE_DOWN, onDown)
			
			back_.x = 0;
			back_.y = 0;
			back_.mask = DisplayObject(mask_);
			
			this.addChild(back_);
			this.addChild(mask_);
			this.addChild(up_);
			this.addChild(down_);
			
			addMessage("Console is init.");
			addMessage("________________________________________________________________________________");

			this.x = x;
			this.y = y;
			this.width = w;
			this.height = h;
		}
		
		private function onUp(e:MouseEvent):void {
			//if (back_.y < 0) {
				back_.y += TEXT_SIZE + SUBLINE_SIZE;
			//}	
		}

		private function onDown(e:MouseEvent):void {
			//if ((back_.y + h) > this.h) {
				back_.y -= TEXT_SIZE + SUBLINE_SIZE;
			//}	
		}
		
		public function addMessage(str:String):void {
			pos_ += TEXT_SIZE + SUBLINE_SIZE;
			var text:TextField = new TextField();
			text.height = TEXT_SIZE;
			text.x = 5;
			text.y = pos_;
			text.textColor = 0xeeeeff;
			text.width = this.width - 10;
			text.text = str;
			back_.addChildAt(text, 0);
		}
	}
}