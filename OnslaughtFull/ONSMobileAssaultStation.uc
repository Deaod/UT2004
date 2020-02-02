//-----------------------------------------------------------
//
//-----------------------------------------------------------
class ONSMobileAssaultStation extends ONSWheeledCraft;

#exec OBJ LOAD FILE=..\Sounds\MenuSounds.uax
#exec OBJ LOAD FILE=..\Textures\ONSFullTextures.utx

var()       sound   DeploySound;
var()       sound   HideSound;
var()		string	DeployForce;
var()		string	HideForce;
var         EPhysics    ServerPhysics;

var			bool	bDeployed;
var			bool	bOldDeployed;

var			vector  UnDeployedTPCamLookat;
var			vector  UnDeployedTPCamWorldOffset;
var			vector  DeployedTPCamLookat;
var			vector  DeployedTPCamWorldOffset;

var			vector  UnDeployedFPCamPos;
var			vector  DeployedFPCamPos;

replication
{
	unreliable if(Role==ROLE_Authority)
        ServerPhysics, bDeployed;
}

simulated event PostNetReceive()
{
    Super.PostNetReceive();

    if (ServerPhysics != Physics)
    {
        bMovable = (ServerPhysics == PHYS_Karma);
        SetPhysics(ServerPhysics);
    }

	if( bDeployed != bOldDeployed )
	{
		if(bDeployed)
		{
			TPCamLookat = DeployedTPCamLookat;
			TPCamWorldOffset = DeployedTPCamWorldOffset;
			FPCamPos = DeployedFPCamPos;
			bEnableProximityViewShake = False;
		}
		else
		{
			TPCamLookat = UnDeployedTPCamLookat;
			TPCamWorldOffset = UnDeployedTPCamWorldOffset;
			FPCamPos = UnDeployedFPCamPos;
			bEnableProximityViewShake = True;
		}

		bOldDeployed = bDeployed;
	}
}

function bool ImportantVehicle()
{
	return true;
}

function bool IsArtillery()
{
	return true;
}

function float BotDesireability(Actor S, int TeamIndex, Actor Objective)
{
	local SquadAI Squad;

	Squad = SquadAI(S);

	if ( Squad.GetOrders() == 'Defend' )
		return 0;

	return super.BotDesireability(S,TeamIndex,Objective);
}

function VehicleFire(bool bWasAltFire)
{
	if (bWasAltFire && PlayerController(Controller) != None)
		PlayerController(Controller).ClientPlaySound(sound'MenuSounds.Denied1');
}

function ChooseFireAt(Actor A)
{
	Fire(0);
}

auto state UnDeployed
{
	function Deploy()
	{
		AltFire(0);
	}

	function ChooseFireAt(Actor A)
	{
		local Bot B;

		B = Bot(Controller);
		if ( B == None || B.Squad == None || ONSPowerCore(B.Squad.SquadObjective) == None )
		{
			Fire(0);
			return;
		}

		if ( ONSPowerCore(B.Squad.SquadObjective).LegitimateTargetOf(B) && CanAttack(B.Squad.SquadObjective) )
			AltFire(0);
		else
			Fire(0);
	}

	function VehicleFire(bool bWasAltFire)
    {
    	if (bWasAltFire)
    	{
            if (PlayerController(Controller) != None && VSize(Velocity) > 15.0)
                PlayerController(Controller).ClientPlaySound(sound'MenuSounds.Denied1');
            else
                GotoState('Deploying');
        }
    	else
    		bWeaponIsFiring = True;
    }
}

state Deployed
{
	function MayUndeploy()
	{
		GotoState('UnDeploying');
	}

	function bool IsDeployed()
	{
		return true;
	}

    function VehicleFire(bool bWasAltFire)
    {
    	if (bWasAltFire)
            GotoState('UnDeploying');
    	else
    		bWeaponIsFiring = True;
    }
}

state UnDeploying
{
Begin:
    if (Controller != None)
    {
    	if (PlayerController(Controller) != None)
    	{
	        PlayerController(Controller).ClientPlaySound(HideSound);
        	if (PlayerController(Controller).bEnableGUIForceFeedback)
			PlayerController(Controller).ClientPlayForceFeedback(HideForce);
	}
        Weapons[1].bForceCenterAim = True;
        Weapons[1].PlayAnim('MASMainGunHide');
        sleep(2.3);
        PlayAnim('MASMainGunHide');
        sleep(4.03);
        bMovable = True;
    	SetPhysics(PHYS_Karma);
    	ServerPhysics = PHYS_Karma;
    	bStationary = False;
    	SetActiveWeapon(0);
    	TPCamLookat = UnDeployedTPCamLookat;
    	TPCamWorldOffset = UnDeployedTPCamWorldOffset;
    	FPCamPos = UnDeployedFPCamPos;
    	bEnableProximityViewShake = True;
    	bDeployed = False;
        GotoState('UnDeployed');
    }
}

state Deploying
{
Begin:
    if (Controller != None)
    {
    	SetPhysics(PHYS_None);
    	ServerPhysics = PHYS_None;
    	bMovable = False;
    	bStationary = True;
    	if (PlayerController(Controller) != None)
    	{
	        PlayerController(Controller).ClientPlaySound(DeploySound);
        	if (PlayerController(Controller).bEnableGUIForceFeedback)
			PlayerController(Controller).ClientPlayForceFeedback(DeployForce);
	}
        PlayAnim('MASMainGunDeploy');
        sleep(3.46);
        Weapons[1].PlayAnim('MASMainGunDeploy');
        sleep(2.873);
        Weapons[1].bForceCenterAim = False;
        SetActiveWeapon(1);
    	bWeaponisFiring = false; //so bots don't immediately fire until the gun has a chance to move
    	TPCamLookat = DeployedTPCamLookat;
    	TPCamWorldOffset = DeployedTPCamWorldOffset;
    	FPCamPos = DeployedFPCamPos;
    	bEnableProximityViewShake = False;
    	bDeployed = True;
        GotoState('Deployed');
    }
}

function Died(Controller Killer, class<DamageType> damageType, vector HitLocation)
{
    bMovable = True;
    SetPhysics(PHYS_Karma);

    Super.Died(Killer, damageType, HitLocation);
}

simulated event ClientVehicleExplosion(bool bFinal)
{
	local int SoundNum;
    local Actor DestructionEffect;

    // Explosion effect
	if(ExplosionSounds.Length > 0)
	{
		SoundNum = Rand(ExplosionSounds.Length);
		PlaySound(ExplosionSounds[SoundNum], SLOT_None, ExplosionSoundVolume*TransientSoundVolume,, ExplosionSoundRadius);
	}

	if (bFinal)
    {
        if (Level.NetMode != NM_DedicatedServer)
            DestructionEffect = spawn(DisintegrationEffectClass,,, Location, Rotation);

        GotoState('VehicleDisintegrated');
    }
}

state VehicleDisintegrated
{
    function Died(Controller Killer, class<DamageType> damageType, vector HitLocation)
    {
    }

Begin:
    sleep(0.75);
    Destroy();
}

static function StaticPrecache(LevelInfo L)
{
    Super.StaticPrecache(L);

	L.AddPrecacheStaticMesh(StaticMesh'ParticleMeshes.Complex.ExplosionRing');
	L.AddPrecacheStaticMesh(StaticMesh'ONSFullStaticMeshes.LEVexploded.BayDoor');
	L.AddPrecacheStaticMesh(StaticMesh'ONSFullStaticMeshes.LEVexploded.MainGun');
	L.AddPrecacheStaticMesh(StaticMesh'ONSFullStaticMeshes.LEVexploded.SideFlap');
	L.AddPrecacheStaticMesh(StaticMesh'AW-2004Particles.Debris.Veh_Debris1');

    L.AddPrecacheMaterial(Material'AW-2004Particles.Energy.SparkHead');
    L.AddPrecacheMaterial(Material'ExplosionTex.Framed.exp2_frames');
    L.AddPrecacheMaterial(Material'ExplosionTex.Framed.exp1_frames');
    L.AddPrecacheMaterial(Material'ExplosionTex.Framed.we1_frames');
    L.AddPrecacheMaterial(Material'AW-2004Particles.Fire.NapalmSpot');
    L.AddPrecacheMaterial(Material'EpicParticles.Fire.SprayFire1');
    L.AddPrecacheMaterial(Material'ONSFullTextures.MASGroup.LEVcolorRED');
    L.AddPrecacheMaterial(Material'ONSFullTextures.MASGroup.LEVnoColor');
    L.AddPrecacheMaterial(Material'ONSFullTextures.MASGroup.LEVcolorBlue');
    L.AddPrecacheMaterial(Material'VehicleFX.Particles.DustyCloud2');
    L.AddPrecacheMaterial(Material'VMParticleTextures.DirtKICKGROUP.dirtKICKTEX');
    L.AddPrecacheMaterial(Material'Engine.GRADIENT_Fade');
}

simulated function UpdatePrecacheStaticMeshes()
{
	Level.AddPrecacheStaticMesh(StaticMesh'ParticleMeshes.Complex.ExplosionRing');
	Level.AddPrecacheStaticMesh(StaticMesh'ONSFullStaticMeshes.LEVexploded.BayDoor');
	Level.AddPrecacheStaticMesh(StaticMesh'ONSFullStaticMeshes.LEVexploded.MainGun');
	Level.AddPrecacheStaticMesh(StaticMesh'ONSFullStaticMeshes.LEVexploded.SideFlap');
	Level.AddPrecacheStaticMesh(StaticMesh'AW-2004Particles.Debris.Veh_Debris1');

    Super.UpdatePrecacheStaticMeshes();
}

simulated function UpdatePrecacheMaterials()
{
    Level.AddPrecacheMaterial(Material'AW-2004Particles.Energy.SparkHead');
    Level.AddPrecacheMaterial(Material'ExplosionTex.Framed.exp2_frames');
    Level.AddPrecacheMaterial(Material'ExplosionTex.Framed.exp1_frames');
    Level.AddPrecacheMaterial(Material'ExplosionTex.Framed.we1_frames');
    Level.AddPrecacheMaterial(Material'AW-2004Particles.Fire.NapalmSpot');
    Level.AddPrecacheMaterial(Material'EpicParticles.Fire.SprayFire1');
    Level.AddPrecacheMaterial(Material'ONSFullTextures.MASGroup.LEVcolorRED');
    Level.AddPrecacheMaterial(Material'ONSFullTextures.MASGroup.LEVnoColor');
    Level.AddPrecacheMaterial(Material'ONSFullTextures.MASGroup.LEVcolorBlue');
    Level.AddPrecacheMaterial(Material'VehicleFX.Particles.DustyCloud2');
    Level.AddPrecacheMaterial(Material'VMParticleTextures.DirtKICKGROUP.dirtKICKTEX');
    Level.AddPrecacheMaterial(Material'Engine.GRADIENT_Fade');

	Super.UpdatePrecacheMaterials();
}

function ShouldTargetMissile(Projectile P)
{
}

defaultproperties
{
     DeploySound=Sound'ONSVehicleSounds-S.MAS.MASDeploy01'
     HideSound=Sound'ONSVehicleSounds-S.MAS.MASDeploy01'
     DeployForce="MASDeploy"
     HideForce="MASDeploy"
     ServerPhysics=PHYS_Karma
     UnDeployedTPCamLookat=(X=-200.000000,Z=300.000000)
     UnDeployedTPCamWorldOffset=(Z=200.000000)
     DeployedTPCamLookat=(X=100.000000)
     DeployedTPCamWorldOffset=(Z=800.000000)
     UnDeployedFPCamPos=(X=-240.000000,Z=350.000000)
     DeployedFPCamPos=(Z=600.000000)
     WheelSoftness=0.040000
     WheelPenScale=1.000000
     WheelPenOffset=0.010000
     WheelRestitution=0.100000
     WheelInertia=0.010000
     WheelLongFrictionFunc=(Points=(,(InVal=100.000000,OutVal=1.000000),(InVal=200.000000,OutVal=0.900000),(InVal=10000000000.000000,OutVal=0.900000)))
     WheelLongSlip=0.001000
     WheelLatSlipFunc=(Points=(,(InVal=30.000000,OutVal=0.009000),(InVal=45.000000),(InVal=10000000000.000000)))
     WheelLongFrictionScale=0.900000
     WheelLatFrictionScale=1.500000
     WheelHandbrakeSlip=0.010000
     WheelHandbrakeFriction=0.100000
     WheelSuspensionTravel=40.000000
     WheelSuspensionMaxRenderTravel=40.000000
     FTScale=0.010000
     ChassisTorqueScale=0.100000
     MinBrakeFriction=4.000000
     MaxSteerAngleCurve=(Points=((OutVal=35.000000),(InVal=1500.000000,OutVal=25.000000),(InVal=1000000000.000000,OutVal=20.000000)))
     TorqueCurve=(Points=((OutVal=36.000000),(InVal=200.000000,OutVal=4.000000),(InVal=1500.000000,OutVal=5.500000),(InVal=2500.000000)))
     GearRatios(0)=-0.200000
     GearRatios(1)=0.200000
     NumForwardGears=1
     TransRatio=0.110000
     ChangeUpPoint=2000.000000
     ChangeDownPoint=1000.000000
     LSDFactor=1.000000
     EngineBrakeFactor=0.002000
     EngineBrakeRPMScale=0.100000
     MaxBrakeTorque=20.000000
     SteerSpeed=110.000000
     StopThreshold=100.000000
     HandbrakeThresh=200.000000
     EngineInertia=0.500000
     IdleRPM=1000.000000
     EngineRPMSoundRange=8000.000000
     SteerBoneAxis=AXIS_Z
     SteerBoneMaxAngle=90.000000
     RevMeterScale=4000.000000
     bAllowBigWheels=True
     AirPitchDamping=45.000000
     DriverWeapons(0)=(WeaponClass=Class'OnslaughtFull.ONSMASRocketPack',WeaponBone="RocketPackAttach")
     DriverWeapons(1)=(WeaponClass=Class'OnslaughtFull.ONSMASCannon',WeaponBone="maingunpostBase")
     PassengerWeapons(0)=(WeaponPawnClass=Class'OnslaughtFull.ONSMASSideGunPawn',WeaponBone="RightFrontgunAttach")
     PassengerWeapons(1)=(WeaponPawnClass=Class'OnslaughtFull.ONSMASSideGunPawn',WeaponBone="LeftFrontGunAttach")
     PassengerWeapons(2)=(WeaponPawnClass=Class'OnslaughtFull.ONSMASSideGunPawn',WeaponBone="RightRearGunAttach")
     PassengerWeapons(3)=(WeaponPawnClass=Class'OnslaughtFull.ONSMASSideGunPawn',WeaponBone="LeftRearGunAttach")
     bHasAltFire=False
     RedSkin=Shader'ONSFullTextures.MASGroup.MASredSHAD'
     BlueSkin=Shader'ONSFullTextures.MASGroup.MASblueSHAD'
     IdleSound=Sound'ONSVehicleSounds-S.MAS.MASEng01'
     StartUpSound=Sound'ONSVehicleSounds-S.MAS.MASStart01'
     ShutDownSound=Sound'ONSVehicleSounds-S.MAS.MASStop01'
     StartUpForce="MASStartUp"
     ShutDownForce="MASShutDown"
     ViewShakeRadius=1000.000000
     ViewShakeOffsetMag=(X=0.700000,Z=2.700000)
     ViewShakeOffsetFreq=7.000000
     DestroyedVehicleMesh=StaticMesh'ONSFullStaticMeshes.leviathanDEAD'
     DestructionEffectClass=Class'Onslaught.ONSVehicleExplosionEffect'
     DisintegrationEffectClass=Class'OnslaughtFull.ONSVehDeathMAS'
     DisintegrationHealth=0.000000
     DestructionLinearMomentum=(Min=250000.000000,Max=400000.000000)
     DestructionAngularMomentum=(Min=100.000000,Max=300.000000)
     UpsideDownDamage=500.000000
     DamagedEffectScale=2.500000
     DamagedEffectOffset=(X=300.000000,Z=185.000000)
     bEnableProximityViewShake=True
     bNeverReset=True
     bCannotBeBased=True
     HeadlightCoronaOffset(0)=(X=365.000000,Y=-87.000000,Z=130.000000)
     HeadlightCoronaMaterial=Texture'EpicParticles.Flares.FlashFlare1'
     HeadlightCoronaMaxSize=120.000000
     Begin Object Class=SVehicleWheel Name=RightRearTIRe
         bPoweredWheel=True
         bHandbrakeWheel=True
         BoneName="RightRearTIRe"
         BoneRollAxis=AXIS_Y
         WheelRadius=99.000000
     End Object
     Wheels(0)=SVehicleWheel'OnslaughtFull.ONSMobileAssaultStation.RightRearTIRe'

     Begin Object Class=SVehicleWheel Name=LeftRearTIRE
         bPoweredWheel=True
         bHandbrakeWheel=True
         BoneName="LeftRearTIRE"
         BoneRollAxis=AXIS_Y
         WheelRadius=99.000000
     End Object
     Wheels(1)=SVehicleWheel'OnslaughtFull.ONSMobileAssaultStation.LeftRearTIRE'

     Begin Object Class=SVehicleWheel Name=RightFrontTIRE
         bPoweredWheel=True
         SteerType=VST_Steered
         BoneName="RightFrontTIRE"
         BoneRollAxis=AXIS_Y
         WheelRadius=99.000000
     End Object
     Wheels(2)=SVehicleWheel'OnslaughtFull.ONSMobileAssaultStation.RightFrontTIRE'

     Begin Object Class=SVehicleWheel Name=LeftFrontTIRE
         bPoweredWheel=True
         SteerType=VST_Steered
         BoneName="LeftFrontTIRE"
         BoneRollAxis=AXIS_Y
         WheelRadius=99.000000
     End Object
     Wheels(3)=SVehicleWheel'OnslaughtFull.ONSMobileAssaultStation.LeftFrontTIRE'

     VehicleMass=10.000000
     bDrawMeshInFP=True
     bKeyVehicle=True
     bDriverHoldsFlag=False
     DrivePos=(X=16.921000,Y=-40.284000,Z=65.793999)
     ExitPositions(0)=(Y=-365.000000,Z=200.000000)
     ExitPositions(1)=(Y=365.000000,Z=200.000000)
     ExitPositions(2)=(Y=-365.000000,Z=-100.000000)
     ExitPositions(3)=(Y=365.000000,Z=-100.000000)
     EntryRadius=500.000000
     FPCamPos=(X=-240.000000,Z=350.000000)
     TPCamDistance=780.000000
     TPCamLookat=(X=-200.000000,Z=300.000000)
     TPCamWorldOffset=(Z=200.000000)
     TPCamDistRange=(Min=0.000000,Max=2500.000000)
     MaxViewPitch=30000
     ShadowCullDistance=2000.000000
     MomentumMult=0.010000
     DriverDamageMult=0.000000
     VehiclePositionString="in a Leviathan"
     VehicleNameString="Leviathan"
     RanOverDamageType=Class'OnslaughtFull.DamTypeMASRoadkill'
     CrushedDamageType=Class'OnslaughtFull.DamTypeMASPancake'
     MaxDesireability=2.000000
     ObjectiveGetOutDist=2000.000000
     FlagBone="LeftFrontGunAttach"
     HornSounds(0)=Sound'ONSVehicleSounds-S.Horns.LevHorn01'
     HornSounds(1)=Sound'ONSVehicleSounds-S.Horns.LevHorn02'
     bSuperSize=True
     NavigationPointRange=190.000000
     HealthMax=5000.000000
     Health=5000
     bReplicateAnimations=True
     Mesh=SkeletalMesh'ONSFullAnimations.MASchassis'
     SoundRadius=255.000000
     CollisionRadius=260.000000
     CollisionHeight=60.000000
     bNetNotify=True
     Begin Object Class=KarmaParamsRBFull Name=KParams0
         KInertiaTensor(0)=1.260000
         KInertiaTensor(3)=3.099998
         KInertiaTensor(5)=4.499996
         KLinearDamping=0.050000
         KAngularDamping=0.050000
         KStartEnabled=True
         bKNonSphericalInertia=True
         KMaxSpeed=650.000000
         bHighDetailOnly=False
         bClientOnly=False
         bKDoubleTickRate=True
         bDestroyOnWorldPenetrate=True
         bDoSafetime=True
         KFriction=0.500000
         KImpactThreshold=500.000000
     End Object
     KParams=KarmaParamsRBFull'OnslaughtFull.ONSMobileAssaultStation.KParams0'

}
