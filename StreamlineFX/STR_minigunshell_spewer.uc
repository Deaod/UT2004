class STR_minigunshell_spewer extends Emitter;

defaultproperties
{
     Begin Object Class=MeshEmitter Name=STR_minigunshell_spewer
         StaticMesh=StaticMesh'XEffects.ShellCasing'
         UseCollision=True
         UseSpawnedVelocityScale=True
         FadeOut=True
         SpinParticles=True
         DampRotation=True
         AutomaticInitialSpawning=False
         Acceleration=(Z=-1000.000000)
         DampingFactorRange=(X=(Min=-1.000000),Y=(Min=-1.000000),Z=(Min=0.750000,Max=0.950000))
         MaxCollisions=(Min=4.000000,Max=4.000000)
         MaxParticles=100
         StartLocationShape=PTLS_Sphere
         UseRotationFrom=PTRS_Actor
         SpinCCWorCW=(X=50.000000,Y=15.000000,Z=6.000000)
         SpinsPerSecondRange=(X=(Max=0.300000),Y=(Max=0.400000),Z=(Max=0.200000))
         StartSpinRange=(X=(Min=0.250000,Max=0.500000),Y=(Min=0.250000,Max=0.500000),Z=(Min=0.250000,Max=0.500000))
         RotationDampingFactorRange=(Z=(Min=0.500000,Max=0.900000))
         StartSizeRange=(X=(Min=0.500000,Max=0.500000),Y=(Min=0.500000,Max=0.500000),Z=(Min=0.500000,Max=0.500000))
         ParticlesPerSecond=10.000000
         InitialParticlesPerSecond=10.000000
         LifetimeRange=(Min=64.000000,Max=64.000000)
         StartVelocityRange=(Y=(Min=-30.000000,Max=-50.000000),Z=(Min=180.000000,Max=200.000000))
     End Object
     Emitters(0)=MeshEmitter'StreamlineFX.STR_minigunshell_spewer.STR_minigunshell_spewer'

     bLightChanged=True
     bNoDelete=False
     bHardAttach=True
     bFixedRotationDir=True
     bDirectional=True
}
