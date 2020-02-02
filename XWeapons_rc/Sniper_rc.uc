class Sniper_rc extends Resource;

// hud
#exec TEXTURE   IMPORT      NAME=SniperInterlace FILE=TEXTURES\interlace.tga GROUP="Icons" MIPS=OFF
#exec TEXTURE   IMPORT      NAME=SniperBorder FILE=TEXTURES\roundedge.tga GROUP="Icons" MIPS=OFF DXT=5 ALPHA=1
//#exec TEXTURE   IMPORT      NAME=SniperFocus FILE=TEXTURES\sniperfocus.tga GROUP="Icons" MIPS=OFF
#exec TEXTURE   IMPORT      NAME=SniperFocus FILE=TEXTURES\ReticleOuter.tga GROUP="Icons" MIPS=OFF DXT=5 ALPHA=1
#exec TEXTURE   IMPORT      NAME=SniperArrows FILE=TEXTURES\RecticleArrows.tga GROUP="Icons" MIPS=OFF DXT=5 ALPHA=1

defaultproperties
{
}
