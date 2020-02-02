class STR_minigun_flash extends Emitter;

defaultproperties
{
     Begin Object Class=MeshEmitter Name=STR_minigun_flash
         StaticMesh=StaticMesh'XEffects.MinigunFlashMesh'
         UseParticleColor=True
         UseColorScale=True
         FadeOut=True
         ResetAfterChange=True
         RespawnDeadParticles=False
         AutoDestroy=True
         UniformMeshScale=False
         SpinParticles=True
         AutomaticInitialSpawning=False
         ColorScale(0)=(RelativeTime=0.200000,Color=(B=64,G=174,R=255))
         Opacity=0.300000
         FadeOutFactor=(W=6.000000,X=6.000000,Y=6.000000,Z=6.000000)
         CoordinateSystem=PTCS_Relative
         MaxParticles=32
         DetailMode=DM_SuperHigh
         MeshSpawning=PTMS_Random
         UseRotationFrom=PTRS_Actor
         SpinsPerSecondRange=(Z=(Min=2.000000,Max=3.000000))
         StartSizeRange=(X=(Min=0.200000,Max=0.500000),Y=(Min=0.200000,Max=0.500000),Z=(Min=0.200000,Max=0.500000))
         UseSkeletalLocationAs=PTSU_Location
         InitialParticlesPerSecond=8.000000
         DrawStyle=PTDS_Brighten
         StartVelocityRange=(X=(Min=-6.000000,Max=6.000000))
     End Object
     Emitters(0)=MeshEmitter'StreamlineFX.STR_minigun_flash.STR_minigun_flash'

     bNoDelete=False
     bHardAttach=True
     bDirectional=True
}
