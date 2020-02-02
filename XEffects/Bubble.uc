//=============================================================================
// Bubble.
//=============================================================================
class Bubble extends Effects;

// TODO: replace with non-UT content
#exec MESH IMPORT MESH=SBubbles ANIVFILE=Models\SRocket_a.3D DATAFILE=Models\SRocket_d.3D X=0 Y=0 Z=0
#exec MESH ORIGIN MESH=SBubbles X=0 Y=0 Z=0 YAW=0 ROLL=0 PITCH=0
#exec MESH SEQUENCE MESH=SBubbles SEQ=All       STARTFRAME=0   NUMFRAMES=16
#exec MESH SEQUENCE MESH=SBubbles SEQ=Ignite    STARTFRAME=0   NUMFRAMES=3
#exec MESH SEQUENCE MESH=SBubbles SEQ=Flying    STARTFRAME=3   NUMFRAMES=13
#exec MESHMAP SCALE MESHMAP=SBubbles  X=0.3 Y=0.3 Z=0.4

#exec TEXTURE IMPORT File=models\bubble1.tga  Name=S_bubble1 LODSET=3 Alpha=1 DXT=5
#exec TEXTURE IMPORT File=models\bubble2.tga  Name=S_bubble2 LODSET=3 Alpha=1 DXT=5
#exec TEXTURE IMPORT File=models\bubble3.tga  Name=S_bubble3 LODSET=3 Alpha=1 DXT=5

simulated function PhysicsVolumeChange( PhysicsVolume Volume )
{
	if ( !Volume.bWaterVolume )
		Destroy();
}

simulated function BeginPlay()
{
	Super.BeginPlay();
	if ( Level.NetMode != NM_DedicatedServer )
	{
		LifeSpan = 3 + 4 * FRand();
		if (FRand()<0.3) Texture = texture'S_Bubble2';
		else if (FRand()<0.3) Texture = texture'S_Bubble3';
		LoopAnim('Flying',0.6);
	}
}

defaultproperties
{
     DrawType=DT_Mesh
     Physics=PHYS_Falling
     RemoteRole=ROLE_SimulatedProxy
     LifeSpan=2.000000
     Mesh=VertMesh'XEffects.SBubbles'
     Texture=Texture'XEffects.S_bubble1'
     DrawScale=0.200000
     Style=STY_Translucent
     Mass=3.000000
     Buoyancy=5.000000
}
