package com.hendrix.gfxManager
{
	import com.hendrix.collection.idCollection.IdCollection;
	import com.hendrix.contentManager.Package;
	import com.hendrix.contentManager.core.types.BinaryContent;
	import com.hendrix.contentManager.core.types.BitmapContent;
	import com.hendrix.contentManager.core.types.XMLContent;
	import com.hendrix.gfxManager.core.interfaces.IIdTexture;
	import com.hendrix.gfxManager.core.types.IdTexture;
	import com.hendrix.gfxManager.core.types.IdTextureAtlas;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display3D.Context3DTextureFormat;
	
	import starling.textures.Texture;
	
	public class GfxPackage extends Package
	{
		private var _atlases:													IdCollection					=	null;
		private var _textures:												IdCollection					=	null;
		
		private var _textureVRAM: 										Number								=	0;
		private var _loadTexturesAutomatically:				Boolean								=	false;

		public function GfxPackage($pkgId:String, $loadTexturesAutomatically:Boolean = false)
		{
			super($pkgId);
			
			_loadTexturesAutomatically 			 	= $loadTexturesAutomatically;
			
			_atlases													=	new IdCollection("id");
			_textures													=	new IdCollection("id");
		}
				
		/**
		 * complete processing Raw Assets, loading from disk etc..
		 */
		override protected function completeProcessing():void
		{
			if(_loadTexturesAutomatically)
				realizePackageTextures();

			super.completeProcessing();
		}
		
		/**
		 * up until now everything was saved raw, now make texture and upload to the gpu.
		 * - handle texture atlases. this is synchrounous operation.
		 */
		public	function loadTexture($id:String):						void	
		{	
			if($id == "*") {
				realizePackageTextures();
				return;
			}
			
			realizeTexture($id);
		}
		private function realizePackageTextures():	void
		{
			for(var ix:uint = 0; ix < _bitmaps.count; ix++) {
				realizeTexture(_bitmaps.vec[ix].id);
			}
		}
		
		/**
		 * relize a texture or Texture Atlas based on bitmap id. this is synchrounous operation.
		 * supports bitmaps and compressed ATF(i didnt check it works, needs QA for ATF), atfs are in the binary collection
		 */
		private function realizeTexture($id:String):void
		{
			if(_textures.hasById($id) || _atlases.hasById($id))
				return;
			
			var idt:	IdTexture	=	null
			
			if(_bitmaps.getById($id))
				idt = new IdTexture(Texture.fromBitmap((_bitmaps.getById($id) as BitmapContent).bitmap, false), $id);
			else if(_binaries.getById($id))
				idt = new IdTexture(Texture.fromAtfData((_binaries.getById($id) as BinaryContent).data, 1, false), $id);

			// texture atlas
			if(($id + "XML") in _xmls.dic)
			{
				var ita: IdTextureAtlas = new IdTextureAtlas(idt, (_xmls.getById($id + "XML") as XMLContent).xml, $id);
				addTextureAtlas(ita);
			}
			else
			{
				_textures.add(idt);
			}
		}
				
		/**
		 * Texture and assets interface
		 * 
		 */
		public function getTexture($texId:String):IIdTexture
		{
			var tex:IdTexture = _textures.getById($texId) as IdTexture;

			if(tex)
				return tex;

			// in case it is within a texture atlas atlas.texture, realize the atlas first
			var arr:Array = $texId.split(".");
			
			var bmp:BitmapContent = _bitmaps.getById(arr[0]) as BitmapContent;
			
			if(bmp) {
				realizeTexture(arr[0]);
				return _textures.getById($texId) as IdTexture;
			}
			
			return null;
		}
		
		public function getTextureAtlas($texAtlasId:String):IdTextureAtlas
		{
			var texAtlas:IdTextureAtlas = _atlases.getById($texAtlasId) as IdTextureAtlas;
			
			if(texAtlas)
				return texAtlas;
			
			var bmp:BitmapContent = _bitmaps.getById($texAtlasId) as BitmapContent;
			
			if(bmp) {
				realizeTexture($texAtlasId);
				return _atlases.getById($texAtlasId) as IdTextureAtlas;
			}

			return null;
		}
		
		public function getTextures($texAtlasId:String, $prefix:String = ""):Vector.<Texture>
		{			
			var texAtlas:IdTextureAtlas = getTextureAtlas($texAtlasId);;//_atlases.getById($texAtlasId) as IdTextureAtlas;
			
			if(texAtlas)
				return texAtlas.getTextures($prefix);
			
			return null;
		}		
		
		public function addTextureAtlas(atlas: IdTextureAtlas): void
		{
			_atlases.add(atlas);
			
			// Add references to all the textures
			var textures: Vector.<String> = atlas.getNames();
			var tn: String;
			var tex: Texture;
			
			for (var ix: int = 0; ix < textures.length; ix++) {
				tn = textures[ix];
				tex = atlas.getTexture(tn);
				addIdTexture(atlas.id + '.' + tn, tex);
			}
		}

		public function addIdTexture($id: String, src: Object): IdTexture
		{
			if ($id == null)
				throw new Error("$id cannot be null.");
			
			var tex: Texture = makeTexture(src);
			var idTex: IdTexture = new IdTexture(tex, $id);
			
			_textures.add(idTex);
			
			return idTex;
		}

		private function makeTexture(src: Object): Texture
		{
			var tex: Texture
			
			if ((src is Class) || (src is Bitmap))
			{ 
				var bd: BitmapData;
				if (src is Class) {
					var bma: Bitmap = new src as Bitmap;
					bd = bma.bitmapData;
				}
				else if (src is Bitmap)
					bd = (src as Bitmap).bitmapData;
				else
					bd = src as BitmapData;
				
				tex = Texture.fromBitmapData(bd, false, false, 1);
				_textureVRAM += texSize(tex);
			}
			else if (src is Texture)
				tex = src as Texture;
			else if (src == null){
				//tex = _blank;
			}
			else
				throw new Error("setupImage() - pass a BitmapAsset class or a BitmapData object!");
			
			return tex;
		}

		public function texSize(tex: Texture): Number
		{
			if (tex.format != Context3DTextureFormat.BGRA)
				return 0;
			
			return tex.nativeWidth * tex.nativeHeight * 4;
		}

		/**
		 * dispose code
		 */
		public function unloadTexture($id:String):void
		{
			if($id == "*"){
				disposeAllTextures();
				return;
			}
			
			var atlas:IdTextureAtlas = _atlases.getById($id) as IdTextureAtlas;
			if(atlas) {
				atlas.dispose();
				_atlases.removeById($id);
				
				var idTex:IdTexture;

				
				var count:uint = _textures.count;
				for(var ix:uint = 0; ix < count; ix++)
				{
					idTex = _textures.vec[ix] as IdTexture;
					if(idTex.id.indexOf($id + ".") == 0){
						trace("package id: " + id + "," + "disposed: " + idTex.id);
						idTex.tex.dispose();
						_textures.removeById(idTex.id);
						count -= 1;
						ix 		-= 1;
						idTex  = null;
					}
				}

			}
			else {
				var idt:IdTexture = _textures.getById($id) as IdTexture;
				
				idt.tex.dispose();
				
				_textures.removeById($id);
			}
		}
		
		private function disposeAllTextures():void
		{
			// this is faster
			var atlas:IdTextureAtlas = null;
			var tex:IdTexture = null;
			var count:uint = _atlases.count;
			for(var ix:uint = 0; ix < count; ix++)
			{
				atlas = _atlases.vec[ix] as IdTextureAtlas;
				atlas.dispose();
				atlas = null;
			}
			
			_atlases.removeAll();
			
			count = _textures.count;
			for(ix = 0; ix < count; ix++)
			{
				tex = _textures.vec[ix] as IdTexture;
				tex.tex.dispose();
				tex = null;
			}
			
			_textures.removeAll();
		}
		
		/**
		 * only unload the assets from memory, and textures as well, keeps manifest
		 */
		override public function unloadPackage():void
		{
			super.unloadPackage();
			disposeAllTextures();
		}
		
		/**
		 * only unload textures
		 */
		public function unloadTextures():void
		{
			disposeAllTextures();
		}
		
		/**
		 * kills the package completely
		 */
		override public function dispose():void
		{
			super.dispose();
			
			disposeAllTextures();
		}

		public function get loadTexturesAutomatically():							Boolean	{	return _loadTexturesAutomatically;	}
		/**
		 * indicate that all textures are loaded into GPU memory as soon as all the assets are ready.
		 * this is for Starling/Feathers, therefore if you are using other stage3D frameworks make sure this is false;
		 */
		public function set loadTexturesAutomatically(value:Boolean):	void		{	_loadTexturesAutomatically = value;	}
		
	}
}