# Hendrix-GfxManager-Starling-AIR
Graphics content manager for `stage3d/Starling/Feathers` applications.

## How to use
simply fork or download the project, you can also download the binary itself and link it
to your project, or import to your IDE of choice such as `Flash Builder 4.7`. requires `Adobe AIR SDK`.

## Features
- supports multi packages asynchronous loadin of assets from local or remote host.
- assets supported:
  - `Textures`
  - `Texture Atlases` (TexturePacker) 
  - `Bitmaps`
  - `Xmls`
  - `Raw Binaries`
  - `Swf MovieClip`
  - `Mp3`
- each asset types has it's own dedicated parser/loader.
- ability to unload and reload textures from the GPU.
- based on [Hendrix Content Manager](https://github.com/HendrixString/Hendrix-ContentManager-Air-as3)

## How to use
1 Single pack loading:

* use simple queries to the `GfxPackage` in string format by id:
  - `pack.getTexture("content_id")`
  - `pack.getTexture("texture_atlas_id.textute_name")`
  - `pack.getTextures(..)`
  - `pack.getTextureAtlas("content_id")`
  - load texture atlases using:
    - `gfxPack.enqueue("url_to_png",       "id",     LocalResource.TYPE_BITMAP)` 
    - `gfxPack.enqueue("url_to_xml",       "idXML", LocalResource.TYPE_XML)`
    - the id of the xml has to be the id of the png + "XML"
  - unload texture using `pack.unloadTexture("tex_id")` or `pack.unloadTexture("*")`
  - reload unloaded texture using `pack.loadTexture("tex_id")`, `pack.getTexture("tex_id")`
```
public function loadSinglePack():void
{      
  var gfxPack:GfxPackage    = new GfxPackage("gfx");
  
  // texture atlas load
  gfxPack.enqueue("assets/packages/main/ssMain.png",      "ssMain",     LocalResource.TYPE_BITMAP);
  gfxPack.enqueue("assets/packages/main/ssMain.xml",      "ssMainXML",  LocalResource.TYPE_XML);
  // single texture loading
  gfxPack.enqueue("assets/packages/general/spinner.png",  "spinner",    LocalResource.TYPE_BITMAP);
  
  gfxPack.process(gfxPack_onFinished);
}

private function pack_onFinished(pack:GfxPackage):void
{
  var tex_icon:     Texture = pack.getTexture("ssMain.icon");
  var tex_spinner:  Texture = pack.getTexture("spinner");
  
  pack.unloadTexture("spinner");
}

```

2 Multi Pack loading: using the `GfxManager` singleton instance

* get or add package with `GfxManager.instance.addOrGetGfxPackage("pack_id")`
* load multiple registered packages with elegant command `GfxManager.instance.loadPackages("pak1_id,pak2_id", cm_onComplete);`
* load all registered packages with elegant command `GfxManager.instance.loadPackages("*", cm_onComplete);`
* use simple queries to the `ContentManager` in string format by id:
`GfxManager.instance.getTexture("pack_id::tex_id")`, `GfxManager.instance.getTexture("pack_id::texture_atlas_id.tex_id")`

```
private var gfxManager:GfxManager = GfxManager.instance;

public function loadMultiPacks():void
{      
  var pack1:GfxPackage     = gfxManager.addOrGetGfxPackage("pack1");
  var pack2:GfxPackage     = gfxManager.addOrGetGfxPackage("pack2");
  
  // texture atlas load
  pack1.enqueue("assets/packages/main/ssMain.png",      "ssMain",     LocalResource.TYPE_BITMAP);
  pack1.enqueue("assets/packages/main/ssMain.xml",      "ssMainXML",  LocalResource.TYPE_XML);
  // single texture loading
  pack1.enqueue("assets/packages/general/spinner.png",  "spinner",    LocalResource.TYPE_BITMAP);  
  
  pack2.loadTexturesAutomatically         = true;
  pack2.enqueue("assets/packages/avatarSelection/avatarSelection.png", "avatarSelection");
  pack2.enqueue("assets/packages/avatarSelection/avatarSelection.xml", "avatarSelectionXML");
  
  gfxManager.loadPackages("*", gfx_onComplete);
}

private function gfx_onComplete(pm:ProcessManager):void
{
  var tex_icon:       Texture = gfxManager.getTexture("pack1::ssMain.icon");
  var tex_spinner:    Texture = gfxManager.getTexture("pack1::spinner");
  var tex_avatar_btn: Texture = gfxManager.getTexture("pack2::avatarSelection.btn");  
}
```

### Terms
* completely free source code.
* if you like it -> star or share it with others

### Contact
[tomer.shalev@gmail.com](tomer.shalev@gmail.com)
