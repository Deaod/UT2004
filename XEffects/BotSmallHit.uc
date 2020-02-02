//=============================================================================
// BotSmallHit.
//=============================================================================
class BotSmallHit extends BloodSpurt;

#exec OBJ LOAD File=XGameShadersB.utx

#exec TEXTURE IMPORT NAME=BloodSplat1P FILE=TEXTURES\DECALS\BloodSplat1P.tga MODULATED=1 LODSET=2 UCLAMPMODE=CLAMP VCLAMPMODE=CLAMP
#exec TEXTURE IMPORT NAME=BloodSplat2P FILE=TEXTURES\DECALS\BloodSplat2P.tga MODULATED=1 LODSET=2 UCLAMPMODE=CLAMP VCLAMPMODE=CLAMP
#exec TEXTURE IMPORT NAME=BloodSplat3P FILE=TEXTURES\DECALS\BloodSplat3P.tga MODULATED=1 LODSET=2 UCLAMPMODE=CLAMP VCLAMPMODE=CLAMP

defaultproperties
{
     BloodDecalClass=Class'XEffects.bloodsplatterpurple'
     Splats(0)=Texture'XEffects.BloodSplat1P'
     Splats(1)=Texture'XEffects.BloodSplat2P'
     Splats(2)=Texture'XEffects.BloodSplat3P'
     mDelayRange(1)=0.100000
     mLifeRange(0)=0.500000
     mLifeRange(1)=0.900000
     mDirDev=(X=0.700000,Y=0.700000,Z=0.700000)
     mPosDev=(X=5.000000,Y=5.000000,Z=5.000000)
     mSpeedRange(0)=20.000000
     mSpeedRange(1)=70.000000
     mMassRange(0)=0.100000
     mMassRange(1)=0.200000
     mSizeRange(0)=10.000000
     mSizeRange(1)=15.000000
     mNumTileColumns=1
     mNumTileRows=1
     Skins(0)=Texture'XGameShadersB.Blood.BloodPuffOil'
}
