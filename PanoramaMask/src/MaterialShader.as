package {
    import flash.display.*;
    import flash.events.Event;
    import flash.events.MouseEvent;
    import flash.geom.*;
    
    public class MaterialShader {
        [Embed(source='../Scene.png')]
        private var BaseImage:Class;
        
        [Embed(source='../Texture.png')]
        private var TextureImage:Class;
        
        [Embed(source='../Mask.png')]
        private var MaskImage:Class;
        
        public var bitmap_:Bitmap;
        private var maskPixels_:BitmapData;
        
        private var rect_:Rectangle;
        
        private var mask_r_:Number; 
        private var mask_g_:Number; 
        private var mask_b_:Number; 
        private var mask_a_:Number; 

        private var texture_r_:Number; 
        private var texture_g_:Number; 
        private var texture_b_:Number; 
        private var texture_a_:Number; 
       
        public var sprite_:Sprite
        
        public function MaterialShader(
            mask_r:Number, mask_g:Number, mask_b:Number, mask_a:Number, 
            texture_r:Number, texture_g:Number, texture_b:Number, texture_a:Number) {;
            
            texture_r_ = texture_r; 
            texture_g_ = texture_g; 
            texture_b_ = texture_b; 
            texture_a_ = texture_a; 
            
            mask_r_ = mask_r; 
            mask_g_ = mask_g; 
            mask_b_ = mask_b; 
            mask_a_ = mask_a; 

            // инициализация базовой картинки
            bitmap_ = new BaseImage();
            
            // инициализация прямоугольной области применения масок
            rect_ = new Rectangle(0, 0, bitmap_.width, bitmap_.height);

            sprite_ = new Sprite();
            sprite_.blendMode = BlendMode.OVERLAY;
            sprite_.addChild(bitmap_);
            
            // наложение цветовой маски
            var mask:Bitmap = new MaskImage();
            setColorMask(mask.bitmapData, mask_r_, mask_g_, mask_b_, mask_a_);
            
            var texture:Bitmap = new TextureImage();
            setColorMask(texture.bitmapData, texture_r_, texture_g_, texture_b_, texture_a_);
        }
        
        
        private function setColorMask(bd:BitmapData, r:Number, g:Number, b:Number, a:Number):void {
            bd.colorTransform(rect_, new ColorTransform(r, g, b, a, -1, -1, -1));
            sprite_.addChild(new Bitmap(bd));
        }
    }
}