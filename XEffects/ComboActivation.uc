class ComboActivation extends xEmitter;

#exec TEXTURE IMPORT NAME=pcl_ball FILE=..\xEffects\TEXTURES\pcl_ball.tga GROUP=Skins ALPHA=1 DXT=5

#exec  TEXTURE IMPORT NAME=RedMarker_t FILE=Textures\RedMarker.TGA LODSET=3 DXT=1
#exec  TEXTURE IMPORT NAME=BlueMarker_t FILE=Textures\BlueMarker.TGA LODSET=3 DXT=1

defaultproperties
{
     mSpawningType=ST_Explode
     mRegenPause=True
     mRegenOnTime(0)=0.250000
     mRegenOnTime(1)=0.250000
     mRegenOffTime(0)=10.000000
     mRegenOffTime(1)=10.000000
     mStartParticles=0
     mLifeRange(0)=0.750000
     mLifeRange(1)=0.750000
     mRegenRange(0)=80.000000
     mRegenRange(1)=80.000000
     mPosDev=(X=10.000000,Y=10.000000,Z=10.000000)
     mSpeedRange(0)=75.000000
     mSpeedRange(1)=75.000000
     mPosRelative=True
     mAirResistance=-4.000000
     mSpinRange(0)=300.000000
     mSpinRange(1)=300.000000
     mSizeRange(0)=3.000000
     mSizeRange(1)=3.000000
     mColorRange(0)=(B=0,G=0)
     mAttenKa=0.000000
     Physics=PHYS_Trailer
     RemoteRole=ROLE_SimulatedProxy
     LifeSpan=2.000000
     Skins(0)=Texture'XEffects.Skins.pcl_ball'
     Style=STY_Additive
}
