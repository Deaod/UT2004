class TransEffect extends xEmitter;

#exec OBJ LOAD FILE=XGameShaders.utx
#exec STATICMESH IMPORT NAME=TeleRing FILE=Models\TeleRing.lwo COLLISION=0

simulated event PostBeginPlay()
{
	SetTimer(0.7,true);
    SetRotation(rot(0,0,0));
    PlaySound(Sound'WeaponSounds.P1WeaponSpawn1',SLOT_None);
    Super.PostBeginPlay();
}

simulated event timer()
{
	mRegen = false;
}

defaultproperties
{
     mParticleType=PT_Mesh
     mStartParticles=0
     mLifeRange(0)=0.600000
     mLifeRange(1)=0.600000
     mRegenRange(0)=30.000000
     mRegenRange(1)=30.000000
     mPosDev=(Z=30.000000)
     mSpeedRange(0)=0.000000
     mSpeedRange(1)=0.000000
     mSizeRange(0)=1.100000
     mSizeRange(1)=0.500000
     mGrowthRate=-0.500000
     mMeshNodes(0)=StaticMesh'XEffects.TeleRing'
     Physics=PHYS_Rotating
     RemoteRole=ROLE_SimulatedProxy
     Tag="xEmitter"
     Skins(0)=Shader'XGameShaders.Trans.TransRing'
     bFixedRotationDir=True
}
