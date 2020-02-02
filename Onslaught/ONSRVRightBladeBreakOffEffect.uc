//-----------------------------------------------------------
//
//-----------------------------------------------------------
class ONSRVRightBladeBreakOffEffect extends Emitter;

defaultproperties
{
     Begin Object Class=MeshEmitter Name=MeshEmitter12
         StaticMesh=StaticMesh'ONSDeadVehicles-SM.RVexploded.ARM'
         RespawnDeadParticles=False
         SpinParticles=True
         AutomaticInitialSpawning=False
         Acceleration=(Z=-500.000000)
         MaxParticles=1
         StartLocationOffset=(X=-24.000000,Y=64.000000,Z=16.000000)
         UseRotationFrom=PTRS_Actor
         SpinCCWorCW=(X=0.000000,Z=0.000000)
         SpinsPerSecondRange=(X=(Min=0.500000,Max=2.000000),Z=(Max=1.000000))
         StartSpinRange=(X=(Min=-0.250000,Max=-0.250000),Z=(Min=-0.250000,Max=-0.250000))
         InitialParticlesPerSecond=500.000000
         LifetimeRange=(Min=1.000000,Max=1.000000)
         StartVelocityRange=(X=(Min=-400.000000,Max=-500.000000),Y=(Min=100.000000,Max=200.000000),Z=(Min=150.000000,Max=200.000000))
     End Object
     Emitters(1)=MeshEmitter'Onslaught.ONSRVRightBladeBreakOffEffect.MeshEmitter12'

     bNoDelete=False
     bUnlit=False
}
