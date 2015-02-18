package com.hendrix.gfxManager
{
  import com.hendrix.contentManager.ContentManager;
  import com.hendrix.contentManager.Package;
  import com.hendrix.contentManager.core.types.BaseContent;
  import com.hendrix.gfxManager.core.interfaces.IIdTexture;
  import com.hendrix.gfxManager.core.types.IdTextureAtlas;
  
  import starling.display.MovieClip;
  import starling.textures.Texture;
  
  public class GfxManager extends ContentManager
  {
    public static var CONTENT_LOADED: String            = "CONTENT_LOADED";
    
    private static var _instance:     GfxManager        = null;
    
    public static var empty:          Texture           = null; 
    
    public static var animationLoading:MovieClip        = null;
    
    public function GfxManager()
    {
      super();
      
      if(_instance  !=  null)
        throw new Error("MrGfxManager is singleton!");
      
      _instance = this;
      
      empty     = Texture.fromColor(4,  4,  0xffffffff);//D7D7D7);;//Texture.fromColor(64,  64, 0xff00ff);
    }
    
    public static function get instance(): GfxManager
    {
      if (_instance ==  null)
        _instance = new GfxManager();
      
      return _instance;
    }
    
    public function addContent($content:BaseContent):void
    {
    }
    
    override public function addOrGetContentPackage($pkgId:String):Package
    {
      var mrContentBatch: GfxPackage = _packages.getById($pkgId) ? _packages.getById($pkgId) as GfxPackage : new GfxPackage($pkgId);
      
      if(!_packages.hasById($pkgId))
        _packages.add(mrContentBatch);
      
      return mrContentBatch;
    }
    
    public function addOrGetGfxPackage($pkgId:String):GfxPackage
    {
      var mrContentBatch: GfxPackage = _packages.getById($pkgId) ? _packages.getById($pkgId) as GfxPackage : new GfxPackage($pkgId);
      
      if(!_packages.hasById($pkgId))
        _packages.add(mrContentBatch);
      
      return mrContentBatch;
    }
    
    /**
     * dispose a texture or atlas, example: disposeTexture("packA::tex1"), disposeTexture("packA::*") 
     */
    public function unloadTexture($id:String):void
    {
      var arr:Array = $id.split("::");
      
      var mrb:GfxPackage = _packages.getById(arr[0]) as GfxPackage;
      
      mrb.unloadTexture(arr[1]);
    }
    
    /**
     * loads texture to gpu: loadTexture("packA::tex1"), loadTexture("packA::*")
     */
    public function loadTexture($id:String):void
    {
      var arr:Array = $id.split("::");
      
      var mrb:GfxPackage = _packages.getById(arr[0]) as GfxPackage;
      
      mrb.loadTexture(arr[1]);
    }
    
    /**
     * get a texture, loads it into gpu if it is not already
     */
    public function getTexture($id:String):IIdTexture
    {
      var arr:Array = $id.split("::");
      
      var mrb:GfxPackage = _packages.getById(arr[0]) as GfxPackage;
      
      return mrb ? mrb.getTexture(arr[1]) : null;
    }
    
    public function getTextureAtlas($id:String):IdTextureAtlas
    {
      var arr:Array = $id.split("::");
      
      var mrb:GfxPackage = _packages.getById(arr[0]) as GfxPackage;
      
      return mrb.getTextureAtlas(arr[1]);
    }
    
    public function getTextures($id:String, $prefix:String = ""):Vector.<Texture>
    {
      var arr:Array = $id.split("::");
      
      var mrb:GfxPackage = _packages.getById(arr[0]) as GfxPackage;
      
      return mrb.getTextures(arr[1], $prefix);
    }
    
  }
}