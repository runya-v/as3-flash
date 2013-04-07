package {
    import flash.display.*;
    import flash.geom.*;
    
    public class MaterialShader extends Sprite {
        private var _rect:Rectangle;
        
        public function MaterialShader(back:Bitmap) {
            _rect = new Rectangle(0, 0, back.width, back.height);
            this.addChild(back);
            this.blendMode = BlendMode.OVERLAY;
        }
        
        public function insertMask(bitmap:Bitmap, r:Number, g:Number, b:Number, a:Number):void {
            bitmap.bitmapData.colorTransform(_rect, new ColorTransform(r, g, b, a, -1, -1, -1));
            this.addChild(bitmap);
        }
    }
}