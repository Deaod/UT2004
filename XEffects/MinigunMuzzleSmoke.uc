class MinigunMuzzleSmoke extends MuzzleSmoke;

#exec  TEXTURE IMPORT NAME=SmokeTex FILE=Textures\smoke.tga LODSET=1 NormalLOD=1 DXT=5 ALPHA=1 Mips=1

defaultproperties
{
     mSizeRange(0)=15.000000
     mSizeRange(1)=20.000000
     Skins(0)=Texture'XEffects.SmokeTex'
     Style=STY_Alpha
}
