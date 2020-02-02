//-----------------------------------------------------------
//
//-----------------------------------------------------------
class ONSWheeledVehicleExplosionEffect extends ONSVehicleExplosionEffect;

#exec OBJ LOAD FILE="..\StaticMeshes\ONSDeadVehicles-SM.usx"

defaultproperties
{
     Begin Object Class=MeshEmitter Name=MeshEmitter0
         StaticMesh=StaticMesh'ONSDeadVehicles-SM.PRVWheelMesh'
         UseCollision=True
         UseColorScale=True
         RespawnDeadParticles=False
         AlphaTest=False
         SpinParticles=True
         DampRotation=True
         UseSizeScale=True
         UseRegularSizeScale=False
         UniformSize=True
         AutomaticInitialSpawning=False
         Acceleration=(Z=-500.000000)
         ExtentMultiplier=(Z=0.500000)
         DampingFactorRange=(X=(Min=0.600000,Max=0.600000),Y=(Min=0.600000,Max=0.600000),Z=(Min=0.200000,Max=0.200000))
         ColorScale(0)=(Color=(B=255,G=255,R=255,A=255))
         ColorScale(1)=(RelativeTime=1.000000,Color=(B=255,G=255,R=255))
         FadeOutStartTime=2.000000
         MaxParticles=1
         AddLocationFromOtherEmitter=0
         SpinsPerSecondRange=(X=(Max=0.500000),Y=(Min=1.000000,Max=-1.000000),Z=(Max=0.500000))
         StartSpinRange=(Z=(Min=0.250000,Max=0.250000))
         SizeScale(0)=(RelativeSize=1.000000)
         SizeScale(1)=(RelativeTime=0.900000,RelativeSize=1.000000)
         SizeScale(2)=(RelativeTime=0.970000,RelativeSize=1.000000)
         SizeScale(3)=(RelativeTime=1.000000)
         StartSizeRange=(X=(Min=0.700000,Max=0.700000),Y=(Min=0.700000,Max=0.700000),Z=(Min=0.700000,Max=0.700000))
         InitialParticlesPerSecond=1000.000000
         DrawStyle=PTDS_Regular
         Texture=None
         LifetimeRange=(Min=5.000000,Max=5.000000)
         AddVelocityFromOtherEmitter=0
     End Object
     Emitters(6)=MeshEmitter'Onslaught.ONSWheeledVehicleExplosionEffect.MeshEmitter0'

}
