//=============================================================================
// lightning.
//=============================================================================
class lightning extends Effects;
 
#exec MESH IMPORT MESH=LightningMesh ANIVFILE=MODELS\lightning_a.3d DATAFILE=MODELS\lightning_d.3d X=0 Y=0 Z=0
#exec MESH ORIGIN MESH=LightningMesh X=0 Y=0 Z=0 PITCH=64
#exec MESH SEQUENCE MESH=LightningMesh SEQ=All STARTFRAME=0 NUMFRAMES=10
#exec TEXTURE IMPORT NAME=Jpb_lightning FILE=MODELS\lightning.tga GROUP=Skins 
#exec MESHMAP NEW MESHMAP=LightningMesh MESH=pb_lightning
#exec MESHMAP SCALE MESHMAP=LightningMesh X=1.0 Y=1.0 Z=2.5
#exec MESHMAP SETTEXTURE MESHMAP=LightningMesh NUM=0 TEXTURE=Jpb_lightning

#exec AUDIO IMPORT FILE="SOUNDS\Lightning1.wav" NAME="LightningSound" 
 
var float Count;

simulated function PrebeginPlay()
{
	// merge_hack AnimFrame=FRand();
}




Simulated function Tick(float Deltatime)
{
	if ( Level.NetMode  != NM_DedicatedServer)
	{
		if (Count >0.07)
		{
			Style=STY_Translucent;
			ScaleGlow = (Lifespan/Default.Lifespan)*0.2;
			AmbientGlow = ScaleGlow * 210;
		}
		else Count += Deltatime;
	}
}

simulated simulated function PostBeginPlay()
{
	PlaySound(Sound'LightningSound',,,,,,false);
}

defaultproperties
{
     DrawType=DT_Mesh
     LifeSpan=0.600000
     Mesh=VertMesh'XEffects.LightningMesh'
     LODBias=9.000000
     AmbientGlow=255
     ScaleGlow=10.000000
}
