//-----------------------------------------------------------
//
//-----------------------------------------------------------
class ONSBomber extends ONSPlaneCraft;

#exec OBJ LOAD FILE=..\Animations\ONSVehicles-A.ukx

var()   float   MaxPitchSpeed;

simulated event DrivingStatusChanged()
{
    if (bDriving)
        Enable('Tick');
    else
        Disable('Tick');
}

simulated function Tick(float DeltaTime)
{
    local float EnginePitch;

    if(Level.NetMode != NM_DedicatedServer)
	{
        EnginePitch = 96.0 + VSize(Velocity)/MaxPitchSpeed * 32.0;
        SoundPitch = FClamp(EnginePitch, 96, 128);
    }

    Super.Tick(DeltaTime);
}

defaultproperties
{
     MaxPitchSpeed=3200.000000
     LiftCoefficientCurve=(Points=((InVal=-180.000000),(InVal=-10.000000),(OutVal=0.400000),(InVal=6.000000,OutVal=0.800000),(InVal=10.000000,OutVal=1.200000),(InVal=12.000000,OutVal=1.400000),(InVal=20.000000,OutVal=0.800000),(InVal=60.000000,OutVal=0.600000),(InVal=90.000000),(InVal=180.000000)))
     DragCoefficientCurve=(Points=((InVal=-180.000000),(InVal=-90.000000,OutVal=1.200000),(InVal=-10.000000,OutVal=0.100000),(InVal=-5.000000,OutVal=0.350000),(OutVal=0.010000),(InVal=5.000000,OutVal=0.350000),(InVal=10.000000,OutVal=0.100000),(InVal=15.000000,OutVal=0.300000),(InVal=60.000000,OutVal=1.000000),(InVal=90.000000,OutVal=1.200000),(InVal=180.000000)))
     AirFactor=0.000050
     MaxThrust=110.000000
     ThrustAcceleration=60.000000
     bHoverOnGround=True
     COMHeight=20.000000
     HoverForceCurve=(Points=((OutVal=500.000000),(InVal=30.000000,OutVal=700.000000),(InVal=250.000000)))
     ThrusterOffsets(0)=(X=200.000000,Z=10.000000)
     ThrusterOffsets(1)=(X=-50.000000,Y=300.000000,Z=10.000000)
     ThrusterOffsets(2)=(X=-50.000000,Y=-300.000000,Z=10.000000)
     HoverSoftness=0.900000
     HoverPenScale=1.500000
     HoverCheckDist=500.000000
     PitchTorque=700.000000
     BankTorque=700.000000
     DriverWeapons(0)=(WeaponClass=Class'OnslaughtFull.ONSBombDropper',WeaponBone="FrontGunMount")
     RedSkin=Shader'ONSFullTextures.BomberGroup.BomberChassisFinalRED'
     BlueSkin=Shader'ONSFullTextures.BomberGroup.BomberChassisFinalBLUE'
     IdleSound=Sound'ONSVehicleSounds-S.Flying.Flying02'
     ImpactDamageThreshold=1000.000000
     ImpactDamageMult=0.030000
     VehicleMass=4.000000
     bDrawMeshInFP=True
     ExitPositions(0)=(Y=500.000000,Z=100.000000)
     ExitPositions(1)=(Y=-500.000000,Z=100.000000)
     ExitPositions(2)=(X=350.000000,Z=100.000000)
     ExitPositions(3)=(X=-350.000000,Z=100.000000)
     MomentumMult=0.050000
     VehiclePositionString="in a DragonFly"
     VehicleNameString="DragonFly"
     HealthMax=600.000000
     Health=600
     Mesh=SkeletalMesh'ONSFullAnimations.Bomber'
     DrawScale=0.700000
     Begin Object Class=KarmaParamsRBFull Name=KParams0
         KInertiaTensor(0)=3.500000
         KInertiaTensor(3)=10.000000
         KInertiaTensor(5)=13.000000
         KCOMOffset=(X=0.650000)
         KLinearDamping=0.000000
         KAngularDamping=1.500000
         KStartEnabled=True
         bKNonSphericalInertia=True
         KActorGravScale=2.000000
         KMaxSpeed=4000.000000
         bHighDetailOnly=False
         bClientOnly=False
         bKDoubleTickRate=True
         bDestroyOnWorldPenetrate=True
         bDoSafetime=True
         KFriction=0.600000
         KImpactThreshold=300.000000
     End Object
     KParams=KarmaParamsRBFull'OnslaughtFull.ONSBomber.KParams0'

}
