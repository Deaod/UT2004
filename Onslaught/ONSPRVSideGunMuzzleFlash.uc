class ONSPRVSideGunMuzzleFlash extends Emitter;

defaultproperties
{
     Begin Object Class=MeshEmitter Name=MeshEmitter2
         StaticMesh=StaticMesh'AW-2004Particles.Weapons.ONSMuzzleFlash'
         RenderTwoSided=True
         UseColorScale=True
         RespawnDeadParticles=False
         SpinParticles=True
         UseSizeScale=True
         UseRegularSizeScale=False
         UniformSize=True
         AutomaticInitialSpawning=False
         TriggerDisabled=False
         ResetOnTrigger=True
         ColorScale(1)=(RelativeTime=0.400000,Color=(B=255,G=128,R=64))
         ColorScale(2)=(RelativeTime=0.600000,Color=(B=255,G=128,R=64))
         ColorScale(3)=(RelativeTime=1.000000)
         CoordinateSystem=PTCS_Relative
         MaxParticles=1
         UseRotationFrom=PTRS_Actor
         SpinsPerSecondRange=(Z=(Min=1.000000,Max=1.000000))
         StartSpinRange=(Z=(Max=1.000000))
         SizeScale(1)=(RelativeTime=1.000000,RelativeSize=1.000000)
         StartSizeRange=(X=(Min=-1.000000,Max=-1.500000))
         InitialParticlesPerSecond=500.000000
         DrawStyle=PTDS_Regular
         LifetimeRange=(Min=0.100000,Max=0.100000)
     End Object
     Emitters(0)=MeshEmitter'Onslaught.ONSPRVSideGunMuzzleFlash.MeshEmitter2'

     bNoDelete=False
}
