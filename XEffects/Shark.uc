class Shark extends Decoration;

#exec TEXTURE   IMPORT      NAME=SharkTex  FILE=textures\shark.tga LODSET=3 DXT=3 MIPS=1 ALPHA=1

#exec DECAANIM  IMPORT      ANIM=SharkAnims ANIMFILE=models\shark.PSA COMPRESS=1
#exec DECAANIM  DIGEST      ANIM=SharkAnims VERBOSE USERAWINFO

#exec DECAMESH  MODELIMPORT MESH=SharkMesh MODELFILE=models\shark.PSK
#exec DECAMESH  ORIGIN      MESH=SharkMesh X=0 Y=0 Z=0 YAW=0 PITCH=0 ROLL=0
#exec DECAMESH  SCALE       MESH=SharkMesh X=1.0 Y=1.0 Z=1.0
#exec DECAMESH  DEFAULTANIM MESH=SharkMesh ANIM=SharkAnims
#exec DECAMESH  SETTEXTURE  MESH=SharkMesh NUM=0 TEXTURE=SharkTex

simulated function PostBeginPlay()
{
    LoopAnim('path');
    Super.PostBeginPlay();
}

defaultproperties
{
     bStatic=False
     bNoDelete=True
     Mesh=SkeletalMesh'XEffects.SharkMesh'
     Skins(0)=FinalBlend'XEffects.Shark.SharkFB'
     bShouldBaseAtStartup=False
     CollisionRadius=0.000000
     CollisionHeight=0.000000
}
