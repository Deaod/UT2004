//-----------------------------------------------------------
//
//-----------------------------------------------------------
class ONSNodeBeamBlueEffect extends Emitter;

defaultproperties
{
     Begin Object Class=BeamEmitter Name=BeamEmitter0
         BeamDistanceRange=(Min=10000.000000,Max=10000.000000)
         DetermineEndPointBy=PTEP_Distance
         RotatingSheets=3
         AutomaticInitialSpawning=False
         MaxParticles=1
         StartLocationOffset=(Z=256.000000)
         StartSizeRange=(X=(Min=110.000000,Max=110.000000))
         InitialParticlesPerSecond=50000.000000
         DrawStyle=PTDS_AlphaBlend
         Texture=Texture'AW-2004Particles.Energy.PowerBeam'
         LifetimeRange=(Min=0.100000,Max=0.100000)
         StartVelocityRange=(Z=(Min=1.000000,Max=1.000000))
     End Object
     Emitters(0)=BeamEmitter'Onslaught.ONSNodeBeamBlueEffect.BeamEmitter0'

     Begin Object Class=BeamEmitter Name=BeamEmitter3
         BeamDistanceRange=(Min=10000.000000,Max=10000.000000)
         DetermineEndPointBy=PTEP_Distance
         RotatingSheets=3
         AutomaticInitialSpawning=False
         ColorMultiplierRange=(X=(Min=0.200000,Max=0.200000),Y=(Min=0.200000,Max=0.200000))
         MaxParticles=1
         StartLocationOffset=(Z=256.000000)
         StartSizeRange=(X=(Min=200.000000,Max=200.000000))
         InitialParticlesPerSecond=50000.000000
         Texture=Texture'AW-2004Particles.Energy.PowerBeam'
         LifetimeRange=(Min=0.100000,Max=0.100000)
         StartVelocityRange=(Z=(Min=1.000000,Max=1.000000))
     End Object
     Emitters(1)=BeamEmitter'Onslaught.ONSNodeBeamBlueEffect.BeamEmitter3'

     Begin Object Class=MeshEmitter Name=MeshEmitter1
         StaticMesh=StaticMesh'AW-2004Particles.ONS.BeamMask'
         UseParticleColor=True
         Disabled=True
         Backup_Disabled=True
         AutomaticInitialSpawning=False
         ColorMultiplierRange=(X=(Min=0.400000,Max=0.400000),Y=(Min=0.400000,Max=0.400000))
         MaxParticles=1
         StartLocationOffset=(Z=300.000000)
         StartSizeRange=(X=(Min=3.000000,Max=3.000000),Y=(Min=3.000000,Max=3.000000))
         InitialParticlesPerSecond=50000.000000
     End Object
     Emitters(2)=MeshEmitter'Onslaught.ONSNodeBeamBlueEffect.MeshEmitter1'

     bNoDelete=False
     AmbientGlow=254
}
