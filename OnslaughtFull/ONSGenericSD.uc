//-----------------------------------------------------------
//
//-----------------------------------------------------------
class ONSGenericSD extends ONSWheeledCraft;

#exec OBJ LOAD FILE=..\sounds\ONSVehicleSounds-S.uax
#exec OBJ LOAD FILE=..\textures\ONSFullTextures.utx

var()	int		CloseSeatRotation;

simulated event Tick(float DeltaSeconds)
{
	local rotator SeatRot;

	Super.Tick(DeltaSeconds);

	if(!bDriving)
		SeatRot.Pitch = CloseSeatRotation;

	SetBoneRotation('Object05', SeatRot, 0, 1.0);
}

static function StaticPrecache(LevelInfo L)
{
    Super.StaticPrecache(L);

	L.AddPrecacheStaticMesh(StaticMesh'ONSDeadVehicles-SM.RVexploded.RVgun');
	L.AddPrecacheStaticMesh(StaticMesh'ONSDeadVehicles-SM.RVexploded.RVrail');
	L.AddPrecacheStaticMesh(StaticMesh'ONSDeadVehicles-SM.RVexploded.Rvtire');
	L.AddPrecacheStaticMesh(StaticMesh'AW-2004Particles.Debris.Veh_Debris2');
	L.AddPrecacheStaticMesh(StaticMesh'AW-2004Particles.Debris.Veh_Debris1');

    L.AddPrecacheMaterial(Material'ExplosionTex.Framed.exp2_frames');
    L.AddPrecacheMaterial(Material'ExplosionTex.Framed.exp1_frames');
    L.AddPrecacheMaterial(Material'ExplosionTex.Framed.we1_frames');
    L.AddPrecacheMaterial(Material'ExplosionTex.Framed.SmokeReOrdered');
    L.AddPrecacheMaterial(Material'AW-2004Particles.Fire.NapalmSpot');
    L.AddPrecacheMaterial(Material'EpicParticles.Fire.SprayFire1');
    L.AddPrecacheMaterial(Material'Engine.GRADIENT_Fade');
}

simulated function UpdatePrecacheStaticMeshes()
{
	Level.AddPrecacheStaticMesh(StaticMesh'ONSDeadVehicles-SM.RVexploded.RVgun');
	Level.AddPrecacheStaticMesh(StaticMesh'ONSDeadVehicles-SM.RVexploded.RVrail');
	Level.AddPrecacheStaticMesh(StaticMesh'ONSDeadVehicles-SM.RVexploded.Rvtire');
	Level.AddPrecacheStaticMesh(StaticMesh'AW-2004Particles.Debris.Veh_Debris2');
	Level.AddPrecacheStaticMesh(StaticMesh'AW-2004Particles.Debris.Veh_Debris1');

    Super.UpdatePrecacheStaticMeshes();
}

simulated function UpdatePrecacheMaterials()
{
    Level.AddPrecacheMaterial(Material'ExplosionTex.Framed.exp2_frames');
    Level.AddPrecacheMaterial(Material'ExplosionTex.Framed.exp1_frames');
    Level.AddPrecacheMaterial(Material'ExplosionTex.Framed.we1_frames');
    Level.AddPrecacheMaterial(Material'ExplosionTex.Framed.SmokeReOrdered');
    Level.AddPrecacheMaterial(Material'AW-2004Particles.Fire.NapalmSpot');
    Level.AddPrecacheMaterial(Material'EpicParticles.Fire.SprayFire1');
    Level.AddPrecacheMaterial(Material'Engine.GRADIENT_Fade');

	Super.UpdatePrecacheMaterials();
}

defaultproperties
{
     CloseSeatRotation=16384
     WheelSoftness=0.015000
     WheelPenScale=1.000000
     WheelPenOffset=0.010000
     WheelRestitution=0.100000
     WheelInertia=0.100000
     WheelLongFrictionFunc=(Points=(,(InVal=100.000000,OutVal=1.000000),(InVal=200.000000,OutVal=0.900000),(InVal=10000000000.000000,OutVal=0.900000)))
     WheelLongSlip=0.001000
     WheelLatSlipFunc=(Points=(,(InVal=30.000000,OutVal=0.009000),(InVal=45.000000),(InVal=10000000000.000000)))
     WheelLongFrictionScale=0.900000
     WheelLatFrictionScale=1.350000
     WheelHandbrakeSlip=0.010000
     WheelHandbrakeFriction=0.100000
     WheelSuspensionTravel=15.000000
     WheelSuspensionOffset=-3.000000
     WheelSuspensionMaxRenderTravel=15.000000
     FTScale=0.030000
     ChassisTorqueScale=0.100000
     MinBrakeFriction=1.500000
     MaxSteerAngleCurve=(Points=((OutVal=25.000000),(InVal=1500.000000,OutVal=11.000000),(InVal=1000000000.000000,OutVal=11.000000)))
     TorqueCurve=(Points=((OutVal=9.000000),(InVal=200.000000,OutVal=10.000000),(InVal=1500.000000,OutVal=11.000000),(InVal=2800.000000)))
     GearRatios(0)=-0.500000
     GearRatios(1)=0.400000
     GearRatios(2)=0.650000
     GearRatios(3)=0.850000
     GearRatios(4)=1.100000
     TransRatio=0.150000
     ChangeUpPoint=2000.000000
     ChangeDownPoint=1000.000000
     LSDFactor=1.000000
     EngineBrakeFactor=0.000100
     EngineBrakeRPMScale=0.100000
     MaxBrakeTorque=20.000000
     SteerSpeed=160.000000
     TurnDamping=35.000000
     StopThreshold=100.000000
     HandbrakeThresh=200.000000
     EngineInertia=0.100000
     IdleRPM=500.000000
     EngineRPMSoundRange=9000.000000
     RevMeterScale=4000.000000
     DaredevilThreshInAirSpin=180.000000
     DaredevilThreshInAirTime=2.000000
     DaredevilThreshInAirDistance=24.000000
     bDoStuntInfo=True
     bAllowBigWheels=True
     AirTurnTorque=35.000000
     AirPitchTorque=55.000000
     AirPitchDamping=35.000000
     AirRollTorque=35.000000
     AirRollDamping=35.000000
     bHasAltFire=False
     RedSkin=Texture'GenericSD.TCTexture.ToiletCar'
     BlueSkin=Texture'GenericSD.TCTexture.ToiletCarBlue'
     IdleSound=Sound'ONSVehicleSounds-S.RV.RVEng01'
     StartUpSound=Sound'ONSVehicleSounds-S.RV.RVStart01'
     ShutDownSound=Sound'ONSVehicleSounds-S.LaserSounds.Laser24'
     StartUpForce="RVStartUp"
     DestroyedVehicleMesh=StaticMesh'GenericSD.TCdead'
     DestructionEffectClass=Class'Onslaught.ONSSmallVehicleExplosionEffect'
     DisintegrationEffectClass=Class'Onslaught.ONSSmallVehicleExplosionEffect'
     DisintegrationHealth=-25.000000
     DestructionLinearMomentum=(Min=200000.000000,Max=300000.000000)
     DestructionAngularMomentum=(Min=100.000000,Max=150.000000)
     DamagedEffectOffset=(X=-32.000000,Z=20.000000)
     ImpactDamageMult=0.001000
     Begin Object Class=SVehicleWheel Name=RRWheel
         bPoweredWheel=True
         bHandbrakeWheel=True
         BoneName="Object02"
         BoneRollAxis=AXIS_Y
         BoneOffset=(Y=7.000000)
         WheelRadius=13.000000
     End Object
     Wheels(0)=SVehicleWheel'OnslaughtFull.ONSGenericSD.RRWheel'

     Begin Object Class=SVehicleWheel Name=LRWheel
         bPoweredWheel=True
         bHandbrakeWheel=True
         BoneName="Object07"
         BoneRollAxis=AXIS_Y
         BoneOffset=(Y=-7.000000)
         WheelRadius=13.000000
     End Object
     Wheels(1)=SVehicleWheel'OnslaughtFull.ONSGenericSD.LRWheel'

     Begin Object Class=SVehicleWheel Name=RFWheel
         bPoweredWheel=True
         SteerType=VST_Steered
         BoneName="Object03"
         BoneRollAxis=AXIS_Y
         BoneOffset=(Y=7.000000)
         WheelRadius=10.000000
     End Object
     Wheels(2)=SVehicleWheel'OnslaughtFull.ONSGenericSD.RFWheel'

     Begin Object Class=SVehicleWheel Name=LFWheel
         bPoweredWheel=True
         SteerType=VST_Steered
         BoneName="Object08"
         BoneRollAxis=AXIS_Y
         BoneOffset=(Y=-7.000000)
         WheelRadius=10.000000
     End Object
     Wheels(3)=SVehicleWheel'OnslaughtFull.ONSGenericSD.LFWheel'

     VehicleMass=3.500000
     bDrawDriverInTP=True
     bDrawMeshInFP=True
     bHasHandbrake=True
     DrivePos=(X=9.000000,Z=70.000000)
     ExitPositions(0)=(Y=-165.000000,Z=100.000000)
     ExitPositions(1)=(Y=165.000000,Z=100.000000)
     ExitPositions(2)=(Y=-165.000000,Z=-100.000000)
     ExitPositions(3)=(Y=165.000000,Z=-100.000000)
     EntryRadius=160.000000
     FPCamPos=(X=7.000000,Z=52.000000)
     TPCamDistance=375.000000
     CenterSpringForce="SpringONSSRV"
     TPCamLookat=(X=0.000000,Z=0.000000)
     TPCamWorldOffset=(Z=100.000000)
     DriverDamageMult=0.800000
     VehiclePositionString="indisposed"
     VehicleNameString="TC-1200"
     HornSounds(0)=Sound'ONSVehicleSounds-S.Horns.Horn04'
     HornSounds(1)=Sound'ONSVehicleSounds-S.Horns.Horn05'
     GroundSpeed=940.000000
     HealthMax=300.000000
     Health=300
     bReplicateAnimations=True
     Mesh=SkeletalMesh'GenericSD.TC'
     SoundVolume=128
     CollisionRadius=100.000000
     CollisionHeight=40.000000
     Begin Object Class=KarmaParamsRBFull Name=KParams0
         KInertiaTensor(0)=1.000000
         KInertiaTensor(3)=3.000000
         KInertiaTensor(5)=3.000000
         KLinearDamping=0.050000
         KAngularDamping=0.050000
         KStartEnabled=True
         bKNonSphericalInertia=True
         bHighDetailOnly=False
         bClientOnly=False
         bKDoubleTickRate=True
         bDestroyOnWorldPenetrate=True
         bDoSafetime=True
         KFriction=0.500000
         KImpactThreshold=700.000000
     End Object
     KParams=KarmaParamsRBFull'OnslaughtFull.ONSGenericSD.KParams0'

}
