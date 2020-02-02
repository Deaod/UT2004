//=============================================================================
// AlienSmallHit.
//=============================================================================
class AlienSmallHit extends BloodSpurt;

#exec OBJ LOAD File=XGameShadersB.utx

defaultproperties
{
     BloodDecalClass=Class'XEffects.BioDecal'
     Splats(0)=Texture'XEffects.xbiosplat'
     Splats(1)=Texture'XEffects.xbiosplat'
     Splats(2)=Texture'XEffects.xbiosplat'
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
     Skins(0)=Texture'XGameShadersB.Blood.BloodPuffGreen'
}
