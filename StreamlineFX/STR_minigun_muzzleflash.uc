class STR_minigun_muzzleflash extends MinigunMuzFlash1st
	placeable;

defaultproperties
{
     mRegen=False
     mRegenPause=True
     mRegenOnTime(1)=100.000000
     mRegenOffTime(1)=12.000000
     mStartParticles=6
     mMaxParticles=6
     mLifeRange(1)=0.300000
     mRegenRange(1)=46.000000
     mRandOrient=True
     mGrowthRate=1.000000
     mAttenKb=0.400000
     mNumTileColumns=0
     mNumTileRows=0
     mMeshNodes(0)=StaticMesh'XEffects.MinigunFlashMesh'
     bLightChanged=True
     LifeSpan=0.300000
     Region=(ZoneNumber=1)
     Tag="MinigunMuzFlash1st"
     Location=(X=-141.000000,Y=379.000000,Z=-189.000000)
     DrawScale=0.200000
     DrawScale3D=(X=0.200000,Y=0.200000)
     Skins(0)=FinalBlend'XGameShaders.WeaponShaders.MinigunFlashFinal'
     Style=STY_None
     bSelected=True
}
