//=============================================================================
// DirtImpact.
//=============================================================================
class DirtImpact extends BloodSpurt;

#exec TEXTURE IMPORT NAME=pcl_Dirta FILE=TEXTURES\Dirta.tga GROUP=Skins Alpha=1  DXT=5

simulated function PostNetBeginPlay() 
{
	if ( Level.NetMode == NM_DedicatedServer )
		LifeSpan = 0.2;
}

defaultproperties
{
     BloodDecalClass=None
     mStartParticles=30
     mMaxParticles=30
     mLifeRange(0)=0.900000
     mLifeRange(1)=1.700000
     mSpeedRange(0)=35.000000
     mSpeedRange(1)=150.000000
     mMassRange(0)=0.400000
     mMassRange(1)=0.700000
     mSizeRange(1)=13.500000
     CullDistance=7000.000000
     Texture=Texture'XEffects.Skins.pcl_Dirta'
     Skins(0)=Texture'XEffects.Skins.pcl_Dirta'
}
