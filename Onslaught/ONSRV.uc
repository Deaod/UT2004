//-----------------------------------------------------------
//
//-----------------------------------------------------------
class ONSRV extends ONSWheeledCraft;

#exec OBJ LOAD FILE=..\Animations\ONSVehicles-A.ukx
#exec OBJ LOAD FILE=..\textures\VehicleFX.utx
#exec OBJ LOAD FILE=..\textures\EpicParticles.utx
#exec OBJ LOAD FILE=..\textures\VMVehicles-TX.utx
#exec OBJ LOAD FILE=..\sounds\ONSVehicleSounds-S.uax

var bool bLeftArmBroke;
var bool bRightArmBroke;
var bool bClientLeftArmBroke;
var bool bClientRightArmBroke;

var() sound ArmExtendSound;
var() sound ArmRetractSound;
var() sound BladeBreakSound;

var string ArmExtendForce;
var string ArmRetractForce;

replication
{
    reliable if (bNetDirty && Role == ROLE_Authority)
        bClientLeftArmBroke, bClientRightArmBroke;
}

function ChooseFireAt(Actor A)
{
	if (Pawn(A) != None && Vehicle(A) == None && VSize(A.Location - Location) < 1500 && Controller.LineOfSightTo(A))
	{
		if (!bWeaponIsAltFiring)
			AltFire(0);
	}
	else if (bWeaponIsAltFiring)
		VehicleCeaseFire(true);

	Fire(0);
}

function AltFire(optional float F)
{
	//avoid sending altfire to weapon
	Super(Vehicle).AltFire(F);
}

function ClientVehicleCeaseFire(bool bWasAltFire)
{
	//avoid sending altfire to weapon
	if (bWasAltFire)
		Super(Vehicle).ClientVehicleCeaseFire(bWasAltFire);
	else
		Super.ClientVehicleCeaseFire(bWasAltFire);
}

function VehicleFire(bool bWasAltFire)
{
	if (bWasAltFire)
	{
        PlayAnim('RVArmExtend');
        if (!bLeftArmBroke || !bRightArmBroke)
        {
            PlaySound(ArmExtendSound, SLOT_None, 2.0,,,, False);
            bWeaponIsAltFiring = True;
            ClientPlayForceFeedback(ArmExtendForce);
        }
    }
	else
		Super.VehicleFire(bWasAltFire);
}

function VehicleCeaseFire(bool bWasAltFire)
{
	if (bWasAltFire)
    {
        PlayAnim('RVArmRetract');
        if (!bLeftArmBroke || !bRightArmBroke)
        {
            PlaySound(ArmRetractSound, SLOT_None, 2.0,,,, False);
    		bWeaponIsAltFiring = False;
    		ClientPlayForceFeedback(ArmRetractForce);
    	}
	}
	else
		Super.VehicleCeaseFire(bWasAltFire);
}

function Pawn CheckForHeadShot(Vector loc, Vector ray, float AdditionalScale)
{
    local vector X, Y, Z;

    GetAxes(Rotation,X,Y,Z);

    if (Driver != None && Driver.IsHeadShot(loc, ray, AdditionalScale))
        return Driver;

    return None;
}

simulated function Tick(float DT)
{
    local Coords ArmBaseCoords, ArmTipCoords;
    local vector HitLocation, HitNormal;
    local actor Victim;

    Super.Tick(DT);

    // Left Blade Arm System
    if (Role == ROLE_Authority && bWeaponIsAltFiring && !bLeftArmBroke)
    {
        ArmBaseCoords = GetBoneCoords('CarLShoulder');
        ArmTipCoords = GetBoneCoords('LeftBladeDummy');
        Victim = Trace(HitLocation, HitNormal, ArmTipCoords.Origin, ArmBaseCoords.Origin);

        if (Victim != None && Victim.bBlockActors)
        {
            if (Victim.IsA('Pawn') && !Victim.IsA('Vehicle'))
                Pawn(Victim).TakeDamage(1000, self, HitLocation, Velocity * 100, class'DamTypeONSRVBlade');
            else
            {
                bLeftArmBroke = True;
                bClientLeftArmBroke = True;
                BladeBreakOff(4, 'CarLSlider', class'ONSRVLeftBladeBreakOffEffect');
				// We use slot 4 here because slots 0-3 can be used by BigWheels mutator.
            }
        }
    }
    if (Role < ROLE_Authority && bClientLeftArmBroke)
    {
        bLeftArmBroke = True;
        bClientLeftArmBroke = False;
        BladeBreakOff(4, 'CarLSlider', class'ONSRVLeftBladeBreakOffEffect');
    }

    // Right Blade Arm System
    if (Role == ROLE_Authority && bWeaponIsAltFiring && !bRightArmBroke)
    {
        ArmBaseCoords = GetBoneCoords('CarRShoulder');
        ArmTipCoords = GetBoneCoords('RightBladeDummy');
        Victim = Trace(HitLocation, HitNormal, ArmTipCoords.Origin, ArmBaseCoords.Origin);

        if (Victim != None && Victim.bBlockActors)
        {
            if (Victim.IsA('Pawn') && !Victim.IsA('Vehicle'))
                Pawn(Victim).TakeDamage(1000, self, HitLocation, Velocity * 100, class'DamTypeONSRVBlade');
            else
            {
                bRightArmBroke = True;
                bClientRightArmBroke = True;
                BladeBreakOff(5, 'CarRSlider', class'ONSRVRightBladeBreakOffEffect');
            }
        }
    }
    if (Role < ROLE_Authority && bClientRightArmBroke)
    {
        bRightArmBroke = True;
        bClientRightArmBroke = False;
        BladeBreakOff(5, 'CarRSlider', class'ONSRVRightBladeBreakOffEffect');
    }
}

simulated function BladeBreakOff(int Slot, name BoneName, class<Emitter> BreakEffect)
{
    PlaySound(BladeBreakSound, SLOT_None, 2.0,,,, False);
    SetBoneScale(Slot, 0.0, BoneName);
    if (Level.NetMode != NM_DedicatedServer)
        spawn(BreakEffect);
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
    L.AddPrecacheMaterial(Material'VMVehicles-TX.RVGroup.RVcolorRED');
    L.AddPrecacheMaterial(Material'VMVehicles-TX.RVGroup.NEWrvNoCOLOR');
    L.AddPrecacheMaterial(Material'VMVehicles-TX.RVGroup.RVblades');
    L.AddPrecacheMaterial(Material'VMVehicles-TX.Environments.ReflectionTexture');
    L.AddPrecacheMaterial(Material'VMWeaponsTX.RVgunGroup.RVnewGUNtex');
    L.AddPrecacheMaterial(Material'AW-2004Particles.Weapons.MuzzleSpray');
    L.AddPrecacheMaterial(Material'VehicleFX.Particles.DustyCloud2');
    L.AddPrecacheMaterial(Material'VMParticleTextures.DirtKICKGROUP.dirtKICKTEX');
    L.AddPrecacheMaterial(Material'VMVehicles-TX.RVGroup.RVcolorBlue');
    L.AddPrecacheMaterial(Material'Engine.GRADIENT_Fade');
    L.AddPrecacheMaterial(Material'XEffectMat.Link.link_spark_green');
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
    Level.AddPrecacheMaterial(Material'VMVehicles-TX.RVGroup.RVcolorRED');
    Level.AddPrecacheMaterial(Material'VMVehicles-TX.RVGroup.NEWrvNoCOLOR');
    Level.AddPrecacheMaterial(Material'VMVehicles-TX.RVGroup.RVblades');
    Level.AddPrecacheMaterial(Material'VMVehicles-TX.Environments.ReflectionTexture');
    Level.AddPrecacheMaterial(Material'VMWeaponsTX.RVgunGroup.RVnewGUNtex');
    Level.AddPrecacheMaterial(Material'AW-2004Particles.Weapons.MuzzleSpray');
    Level.AddPrecacheMaterial(Material'VehicleFX.Particles.DustyCloud2');
    Level.AddPrecacheMaterial(Material'VMParticleTextures.DirtKICKGROUP.dirtKICKTEX');
    Level.AddPrecacheMaterial(Material'VMVehicles-TX.RVGroup.RVcolorBlue');
    Level.AddPrecacheMaterial(Material'Engine.GRADIENT_Fade');
    Level.AddPrecacheMaterial(Material'XEffectMat.Link.link_spark_green');

	Super.UpdatePrecacheMaterials();
}

function ShouldTargetMissile(Projectile P)
{
	if ( (Health < 200) && (Bot(Controller) != None) 
		&& (Level.Game.GameDifficulty > 4 + 4*FRand())
		&& (VSize(P.Location - Location) < VSize(P.Velocity)) )
	{
		KDriverLeave(false);
		TeamUseTime = Level.TimeSeconds + 4;
	}
}

defaultproperties
{
     ArmExtendSound=Sound'ONSVehicleSounds-S.RV.Shing1'
     ArmRetractSound=Sound'ONSVehicleSounds-S.RV.Shing2'
     BladeBreakSound=Sound'ONSVehicleSounds-S.RV.RVBladeBreakOff'
     ArmExtendForce="RVBladeOpen"
     ArmRetractForce="RVBladeClose"
     WheelSoftness=0.025000
     WheelPenScale=1.200000
     WheelPenOffset=0.010000
     WheelRestitution=0.100000
     WheelInertia=0.100000
     WheelLongFrictionFunc=(Points=(,(InVal=100.000000,OutVal=1.000000),(InVal=200.000000,OutVal=0.900000),(InVal=10000000000.000000,OutVal=0.900000)))
     WheelLongSlip=0.001000
     WheelLatSlipFunc=(Points=(,(InVal=30.000000,OutVal=0.009000),(InVal=45.000000),(InVal=10000000000.000000)))
     WheelLongFrictionScale=1.100000
     WheelLatFrictionScale=1.350000
     WheelHandbrakeSlip=0.010000
     WheelHandbrakeFriction=0.100000
     WheelSuspensionTravel=15.000000
     WheelSuspensionMaxRenderTravel=15.000000
     FTScale=0.030000
     ChassisTorqueScale=0.400000
     MinBrakeFriction=4.000000
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
     SteerBoneName="SteeringWheel"
     SteerBoneAxis=AXIS_Z
     SteerBoneMaxAngle=90.000000
     RevMeterScale=4000.000000
     bMakeBrakeLights=True
     BrakeLightOffset(0)=(X=-100.000000,Y=23.000000,Z=7.000000)
     BrakeLightOffset(1)=(X=-100.000000,Y=-23.000000,Z=7.000000)
     BrakeLightMaterial=Texture'EpicParticles.Flares.FlashFlare1'
     DaredevilThreshInAirSpin=180.000000
     DaredevilThreshInAirTime=1.700000
     DaredevilThreshInAirDistance=21.000000
     bDoStuntInfo=True
     bAllowBigWheels=True
     AirTurnTorque=35.000000
     AirPitchTorque=55.000000
     AirPitchDamping=35.000000
     AirRollTorque=35.000000
     AirRollDamping=35.000000
     DriverWeapons(0)=(WeaponClass=Class'Onslaught.ONSRVWebLauncher',WeaponBone="ChainGunAttachment")
     bHasAltFire=False
     RedSkin=Shader'VMVehicles-TX.RVGroup.RVChassisFinalRED'
     BlueSkin=Shader'VMVehicles-TX.RVGroup.RVChassisFinalBLUE'
     IdleSound=Sound'ONSVehicleSounds-S.RV.RVEng01'
     StartUpSound=Sound'ONSVehicleSounds-S.RV.RVStart01'
     ShutDownSound=Sound'ONSVehicleSounds-S.RV.RVStop01'
     StartUpForce="RVStartUp"
     DestroyedVehicleMesh=StaticMesh'ONSDeadVehicles-SM.RVDead'
     DestructionEffectClass=Class'Onslaught.ONSSmallVehicleExplosionEffect'
     DisintegrationEffectClass=Class'Onslaught.ONSVehDeathRV'
     DisintegrationHealth=-25.000000
     DestructionLinearMomentum=(Min=200000.000000,Max=300000.000000)
     DestructionAngularMomentum=(Min=100.000000,Max=150.000000)
     DamagedEffectOffset=(X=60.000000,Y=10.000000,Z=10.000000)
     ImpactDamageMult=0.001000
     HeadlightCoronaOffset(0)=(X=86.000000,Y=30.000000,Z=7.000000)
     HeadlightCoronaOffset(1)=(X=86.000000,Y=-30.000000,Z=7.000000)
     HeadlightCoronaMaterial=Texture'EpicParticles.Flares.FlashFlare1'
     HeadlightCoronaMaxSize=65.000000
     HeadlightProjectorMaterial=Texture'VMVehicles-TX.RVGroup.RVprojector'
     HeadlightProjectorOffset=(X=90.000000,Z=7.000000)
     HeadlightProjectorRotation=(Pitch=-1000)
     HeadlightProjectorScale=0.300000
     Begin Object Class=SVehicleWheel Name=RRWheel
         bPoweredWheel=True
         bHandbrakeWheel=True
         BoneName="tire02"
         BoneRollAxis=AXIS_Y
         BoneOffset=(Y=7.000000)
         WheelRadius=24.000000
         SupportBoneName="RrearStrut"
         SupportBoneAxis=AXIS_X
     End Object
     Wheels(0)=SVehicleWheel'Onslaught.ONSRV.RRWheel'

     Begin Object Class=SVehicleWheel Name=LRWheel
         bPoweredWheel=True
         bHandbrakeWheel=True
         BoneName="tire04"
         BoneRollAxis=AXIS_Y
         BoneOffset=(Y=-7.000000)
         WheelRadius=24.000000
         SupportBoneName="LrearStrut"
         SupportBoneAxis=AXIS_X
     End Object
     Wheels(1)=SVehicleWheel'Onslaught.ONSRV.LRWheel'

     Begin Object Class=SVehicleWheel Name=RFWheel
         bPoweredWheel=True
         SteerType=VST_Steered
         BoneName="tire"
         BoneRollAxis=AXIS_Y
         BoneOffset=(Y=7.000000)
         WheelRadius=24.000000
         SupportBoneName="RFrontStrut"
         SupportBoneAxis=AXIS_X
     End Object
     Wheels(2)=SVehicleWheel'Onslaught.ONSRV.RFWheel'

     Begin Object Class=SVehicleWheel Name=LFWheel
         bPoweredWheel=True
         SteerType=VST_Steered
         BoneName="tire03"
         BoneRollAxis=AXIS_Y
         BoneOffset=(Y=-7.000000)
         WheelRadius=24.000000
         SupportBoneName="LfrontStrut"
         SupportBoneAxis=AXIS_X
     End Object
     Wheels(3)=SVehicleWheel'Onslaught.ONSRV.LFWheel'

     VehicleMass=3.500000
     bDrawDriverInTP=True
     bCanDoTrickJumps=True
     bDrawMeshInFP=True
     bHasHandbrake=True
     bSeparateTurretFocus=True
     DrivePos=(X=2.000000,Z=38.000000)
     ExitPositions(0)=(Y=-165.000000,Z=100.000000)
     ExitPositions(1)=(Y=165.000000,Z=100.000000)
     ExitPositions(2)=(Y=-165.000000,Z=-100.000000)
     ExitPositions(3)=(Y=165.000000,Z=-100.000000)
     EntryRadius=160.000000
     FPCamPos=(X=15.000000,Z=25.000000)
     TPCamDistance=375.000000
     CenterSpringForce="SpringONSSRV"
     TPCamLookat=(X=0.000000,Z=0.000000)
     TPCamWorldOffset=(Z=100.000000)
     DriverDamageMult=0.800000
     VehiclePositionString="in a Scorpion"
     VehicleNameString="Scorpion"
     RanOverDamageType=Class'Onslaught.DamTypeRVRoadkill'
     CrushedDamageType=Class'Onslaught.DamTypeRVPancake'
     MaxDesireability=0.400000
     ObjectiveGetOutDist=1500.000000
     HornSounds(0)=Sound'ONSVehicleSounds-S.Horns.Horn06'
     HornSounds(1)=Sound'ONSVehicleSounds-S.Horns.Dixie_Horn'
     GroundSpeed=940.000000
     HealthMax=300.000000
     Health=300
     bReplicateAnimations=True
     Mesh=SkeletalMesh'ONSVehicles-A.RV'
     SoundVolume=180
     CollisionRadius=100.000000
     CollisionHeight=40.000000
     Begin Object Class=KarmaParamsRBFull Name=KParams0
         KInertiaTensor(0)=1.000000
         KInertiaTensor(3)=3.000000
         KInertiaTensor(5)=3.000000
         KCOMOffset=(X=-0.250000,Z=-0.400000)
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
     KParams=KarmaParamsRBFull'Onslaught.ONSRV.KParams0'

}
