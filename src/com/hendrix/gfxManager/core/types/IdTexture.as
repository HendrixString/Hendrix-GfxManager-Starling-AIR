package com.hendrix.gfxManager.core.types
{
  import starling.textures.Texture;
  import com.hendrix.gfxManager.core.interfaces.IIdTexture;
  
  public class IdTexture implements IIdTexture
  {
    protected var _id:  String;
    protected var _tex: Texture;
    
    public function IdTexture($tex: Texture, $id: String = null)
    {
      tex = $tex;
      id  = $id;
    }
    
    public function get id(): String {
      return _id;
    }
    public function set id(value: String): void {
      _id = value;
    }
    
    public function get tex(): Texture {
      return _tex;
    }
    public function set tex(value: Texture): void {
      _tex = value;
    }
  }
}