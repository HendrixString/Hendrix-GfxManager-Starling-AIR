package com.hendrix.gfxManager.core.interfaces
{ 
  import com.hendrix.contentManager.core.interfaces.IId;
  
  import starling.textures.Texture;
  
  public interface IIdTexture extends IId
  {
    function get tex(): Texture;
    function set tex(value: Texture): void;
  }
}