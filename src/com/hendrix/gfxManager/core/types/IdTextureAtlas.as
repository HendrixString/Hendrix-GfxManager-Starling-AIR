package com.hendrix.gfxManager.core.types
{
  import com.hendrix.contentManager.core.interfaces.IId;
  
  import starling.textures.TextureAtlas;
  import com.hendrix.gfxManager.core.interfaces.IIdTexture;
  
  public class IdTextureAtlas extends TextureAtlas implements IId
  {
    protected var _id:    String;
    protected var _idTex: IIdTexture;
    
    public function IdTextureAtlas($idTex: IIdTexture, $definition: XML, $id: String)
    {
      _idTex = $idTex;
      _id = $id;
      
      super(_idTex.tex, $definition);
    }
    
    public function get id(): String {
      return _id;
    }
    public function set id(value: String): void {
      _id = value;
    }
    
    public function get idTex(): IIdTexture {
      return _idTex;
    }
    public function set idTex(value: IIdTexture): void {
      _idTex = value;
    }
  }
}