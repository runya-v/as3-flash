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
		
		private var _pos:int = 0;
		private var _back:Sprite = new Sprite;
		private var _mask:Sprite = new Sprite;
		private var _up:Sprite   = new Sprite;
		private var _down:Sprite = new Sprite;
		
		public function Console(x:int, y:int, w:int, h:int) {
			this.graphics.beginFill(0x212970, 0.7);
			this.graphics.drawRect(0, 0, w, h);
			this.graphics.endFill();
			
			_mask.graphics.beginFill(0x000000);
			_mask.graphics.drawRect(0, 0, w, h);
			_mask.graphics.endFill();
			
			_up.graphics.beginFill(0x0000ff, 0.1);
			_up.graphics.drawRect(0, 0, 20, 20);
			_up.graphics.endFill();
			_up.x = w - 20;
			_up.y = 0;
			var _upview:MovieClip = new UpPviewImage;
			_upview.gotoAndStop(1);
			_upview.x = 10;
			_upview.y = 6;
			_up.addChild(_upview);
			
			_up.addEventListener(MouseEvent.MOUSE_OVER, function(e:MouseEvent):void {
				Mouse.cursor = MouseCursor.BUTTON;	
			});

			_up.addEventListener(MouseEvent.MOUSE_OUT, function(e:MouseEvent):void {
				Mouse.cursor = MouseCursor.AUTO;	
			});

			_up.addEventListener(MouseEvent.MOUSE_DOWN, function(e:MouseEvent):void { 
                _back.y += TEXT_SIZE + SUBLINE_SIZE;
            });

			_down.graphics.beginFill(0x0000ff, 0.1);
			_down.graphics.drawRect(0, 0, 20, 20);
			_down.graphics.endFill();
			_down.x = w - 20;
			_down.y = h - 20;
            
			var _downview:MovieClip = new UpPviewImage;
			_downview.gotoAndStop(3);
			_downview.x = 10;
			_downview.y = 7;
			_down.addChild(_downview);

			_down.addEventListener(MouseEvent.MOUSE_OVER, function(e:MouseEvent):void {
				Mouse.cursor = MouseCursor.BUTTON;	
			});
			
			_down.addEventListener(MouseEvent.MOUSE_OUT, function(e:MouseEvent):void {
				Mouse.cursor = MouseCursor.AUTO;	
			});

			_down.addEventListener(MouseEvent.MOUSE_DOWN, function(e:MouseEvent):void { 
                _back.y -= TEXT_SIZE + SUBLINE_SIZE;
            });
            
			_back.x = 0;
			_back.y = 0;
			_back.mask = DisplayObject(_mask);
			
			this.addChild(_back);
			this.addChild(_mask);
			this.addChild(_up);
			this.addChild(_down);
			
			addMessage("Console is init.");
			addMessage("________________________________________________________________________________");

			this.x = x;
			this.y = y;
			this.width = w;
			this.height = h;
		}

		public function addMessage(str:String):void {
			_pos += TEXT_SIZE + SUBLINE_SIZE;
			var text:TextField = new TextField();
			text.height = TEXT_SIZE;
			text.x = 5;
			text.y = _pos;
			text.textColor = 0xeeeeff;
			text.width = this.width - 10;
			text.text = str;
			_back.addChildAt(text, 0);
		}
	}
}