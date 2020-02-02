//-----------------------------------------------------------
//
//-----------------------------------------------------------
class ONSHoverBike extends ONSHoverCraft;

#exec OBJ LOAD FILE=..\Animations\ONSVehicles-A.ukx
#exec OBJ LOAD FILE=..\Sounds\ONSVehicleSounds-S.uax
#exec OBJ LOAD FILE=..\textures\EpicParticles.utx
#exec OBJ LOAD FILE=..\StaticMeshes\ONSWeapons-SM
#exec OBJ LOAD FILE=..\textures\VMVehicles-TX.utx

var()   float   MaxPitchSpeed;

var()   float   JumpDuration;
var()	float	JumpForceMag;
var     float   JumpCountdown;
var     float	JumpDelay, LastJumpTime;

var()   float   DuckDuration;
var()   float   DuckForceMag;
var     float   DuckCountdown;

var()	array<vector>					BikeDustOffset;
var()	float							BikeDustTraceDistance;

var()   sound                           JumpSound;
var()   sound                           DuckSound;

// Force Feedback
var()	string							JumpForce;

var		array<ONSHoverBikeHoverDust>	BikeDust;
var		array<vector>					BikeDustLastNormal;

var		bool							DoBikeJump;
var		bool							OldDoBikeJump;

var		bool							DoBikeDuck;
var		bool							OldDoBikeDuck;
var     bool                            bHoldingDuck;
var     bool                            bOverWater;

replication
{
	reliable if (bNetDirty && Role == ROLE_Authority)
		DoBikeJump;
}

function KDriverEnter(Pawn P)
{
	bHeadingInitialized = False;

	Super.KDriverEnter(P);
}

simulated function ClientKDriverEnter(PlayerController PC)
{
	bHeadingInitialized = False;

	Super.ClientKDriverEnter(PC);
}

// AI hint
function bool FastVehicle()
{
	return true;
}

function ShouldTargetMissile(Projectile P)
{
	if ( (Bot(Controller) != None) 
		&& (Level.Game.GameDifficulty > 4 + 4*FRand())
		&& (VSize(P.Location - Location) < VSize(P.Velocity)) )
	{
		KDriverLeave(false);
		TeamUseTime = Level.TimeSeconds + 4;
		return;
	}
	Super.ShouldTargetMissile(P);
}


function bool TooCloseToAttack(Actor Other)
{
	if ( xPawn(Other) != None )
		return false;
	return super.TooCloseToAttack(Other);
}

function Pawn CheckForHeadShot(Vector loc, Vector ray, float AdditionalScale)
{
    local vector X, Y, Z, newray;

    GetAxes(Rotation,X,Y,Z);

    if (Driver != None)
    {
        // Remove the Z component of the ray
        newray = ray;
        newray.Z = 0;
        if (abs(newray dot X) < 0.7 && Driver.IsHeadShot(loc, ray, AdditionalScale))
            return Driver;
    }

    return None;
}

simulated function Destroyed()
{
	local int i;

	if (Level.NetMode != NM_DedicatedServer)
	{
		for (i = 0; i < BikeDust.Length; i++)
			BikeDust[i].Destroy();

		BikeDust.Length = 0;
	}

	Super.Destroyed();
}

simulated function DestroyAppearance()
{
	local int i;

	if (Level.NetMode != NM_DedicatedServer)
	{
		for (i = 0; i < BikeDust.Length; i++)
			BikeDust[i].Destroy();

		BikeDust.Length = 0;
	}

	Super.DestroyAppearance();
}

function bool Dodge(eDoubleClickDir DoubleClickMove)
{
	Rise = 1;
	return true;
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

simulated event DrivingStatusChanged()
{
	local int i;

	Super.DrivingStatusChanged();

    if (bDriving && Level.NetMode != NM_DedicatedServer && BikeDust.Length == 0 && !bDropDetail)
	{
		BikeDust.Length = BikeDustOffset.Length;
		BikeDustLastNormal.Length = BikeDustOffset.Length;

		for(i=0; i<BikeDustOffset.Length; i++)
    		if (BikeDust[i] == None)
    		{
    			BikeDust[i] = spawn( class'ONSHoverBikeHoverDust', self,, Location + (BikeDustOffset[i] >> Rotation) );
    			BikeDust[i].SetDustColor( Level.DustColor );
    			BikeDustLastNormal[i] = vect(0,0,1);
    		}
	}
    else
    {
        if (Level.NetMode != NM_DedicatedServer)
    	{
    		for(i=0; i<BikeDust.Length; i++)
                BikeDust[i].Destroy();

            BikeDust.Length = 0;
        }
        JumpCountDown = 0.0;
    }
}

simulated function Tick(float DeltaTime)
{
    local float EnginePitch, HitDist;
	local int i;
	local vector TraceStart, TraceEnd, HitLocation, HitNormal;
	local actor HitActor;
	local Emitter JumpEffect;
	local KarmaParams kp;

    Super.Tick(DeltaTime);

    JumpCountdown -= DeltaTime;

    CheckJumpDuck();

	if(DoBikeJump != OldDoBikeJump)
	{
		JumpCountdown = JumpDuration;
        OldDoBikeJump = DoBikeJump;
        if ( (Controller != Level.GetLocalPlayerController()) && EffectIsRelevant(Location,false) )
        {
            JumpEffect = Spawn(class'ONSHoverBikeJumpEffect');
            JumpEffect.SetBase(Self);
            ClientPlayForceFeedback(JumpForce);
        }
	}

	if ( Level.NetMode != NM_DedicatedServer )
	{
		EnginePitch = 64.0 + VSize(Velocity)/MaxPitchSpeed * 64.0;
		SoundPitch = FClamp(EnginePitch, 64, 128);

		if( !bDropDetail )
		{
        	// Check for water
        	bOverWater = false;
        	kp = KarmaParams(KParams);
        	for(i=0;i<kp.Repulsors.Length;i++)
        	{
                if (kp.Repulsors[i].bRepulsorOnWater)
                {
                    bOverWater = true;
                	break;
                }
            }

			for(i=0; i<BikeDust.Length; i++)
			{
				BikeDust[i].bDustActive = false;

				TraceStart = Location + (BikeDustOffset[i] >> Rotation);
				TraceEnd = TraceStart - ( BikeDustTraceDistance * vect(0,0,1) );

				HitActor = Trace(HitLocation, HitNormal, TraceEnd, TraceStart, true);

				if(HitActor == None)
				{
					BikeDust[i].UpdateHoverDust(false, 0);
				}
				else
				{
					if ( bOverWater || ((PhysicsVolume(HitActor) != None) && PhysicsVolume(HitActor).bWaterVolume) )
				        BikeDust[i].SetDustColor(Level.WaterDustColor);
                    else
                        BikeDust[i].SetDustColor(Level.DustColor);

					HitDist = VSize(HitLocation - TraceStart);

					BikeDust[i].SetLocation( HitLocation + 10*HitNormal);

					BikeDustLastNormal[i] = Normal( 3*BikeDustLastNormal[i] + HitNormal );
					BikeDust[i].SetRotation( Rotator(BikeDustLastNormal[i]) );

					BikeDust[i].UpdateHoverDust(true, HitDist/BikeDustTraceDistance);

					// If dust is just turning on, set OldLocation to current Location to avoid spawn interpolation.
					if(!BikeDust[i].bDustActive)
						BikeDust[i].OldLocation = BikeDust[i].Location;

					BikeDust[i].bDustActive = true;
				}
			}
		}
	}
}

function VehicleCeaseFire(bool bWasAltFire)
{
    Super.VehicleCeaseFire(bWasAltFire);

    if (bWasAltFire)
        bHoldingDuck = False;
}

simulated function float ChargeBar()
{
    // Clamp to 0.999 so charge bar doesn't blink when maxed
	if (Level.TimeSeconds - JumpDelay < LastJumpTime)
        return (FMin((Level.TimeSeconds - LastJumpTime) / JumpDelay, 0.999));
    else
		return 0.999;
}

simulated function CheckJumpDuck()
{
	local KarmaParams KP;
	local Emitter JumpEffect, DuckEffect;
	local bool bOnGround;
	local int i;

	KP = KarmaParams(KParams);

	// Can only start a jump when in contact with the ground.
	bOnGround = false;
	for(i=0; i<KP.Repulsors.Length; i++)
	{
		if( KP.Repulsors[i] != None && KP.Repulsors[i].bRepulsorInContact )
			bOnGround = true;
	}

	// If we are on the ground, and press Rise, and we not currently in the middle of a jump, start a new one.
    if (JumpCountdown <= 0.0 && Rise > 0 && bOnGround && !bHoldingDuck && Level.TimeSeconds - JumpDelay >= LastJumpTime)
    {
        PlaySound(JumpSound,,1.0);

        if (Role == ROLE_Authority)
    	   DoBikeJump = !DoBikeJump;

        if(Level.NetMode != NM_DedicatedServer)
        {
            JumpEffect = Spawn(class'ONSHoverBikeJumpEffect');
            JumpEffect.SetBase(Self);
            ClientPlayForceFeedback(JumpForce);
        }

    	if ( AIController(Controller) != None )
    		Rise = 0;

    	LastJumpTime = Level.TimeSeconds;
    }
    else if (DuckCountdown <= 0.0 && (Rise < 0 || bWeaponIsAltFiring))
    {
        if (!bHoldingDuck)
        {
            bHoldingDuck = True;

            PlaySound(DuckSound,,1.0);

			if(Level.NetMode != NM_DedicatedServer)
			{
				DuckEffect = Spawn(class'ONSHoverBikeDuckEffect');
				DuckEffect.SetBase(Self);
			}

            if ( AIController(Controller) != None )
    			Rise = 0;

    		JumpCountdown = 0.0; // Stops any jumping that was going on.
    	}
	}
	else
	   bHoldingDuck = False;
}

simulated function KApplyForce(out vector Force, out vector Torque)
{
	Super.KApplyForce(Force, Torque);

	if (bDriving && JumpCountdown > 0.0)
	{
		Force += vect(0,0,1) * JumpForceMag;
	}

	if (bDriving && bHoldingDuck)
	{
		Force += vect(0,0,-1) * DuckForceMag;
	}
}

static function StaticPrecache(LevelInfo L)
{
    Super.StaticPrecache(L);

	L.AddPrecacheStaticMesh(StaticMesh'ONSDeadVehicles-SM.HoverExploded.HoverWing');
	L.AddPrecacheStaticMesh(StaticMesh'ONSDeadVehicles-SM.HoverExploded.HoverChair');
	L.AddPrecacheStaticMesh(StaticMesh'AW-2004Particles.Debris.Veh_Debris2');
	L.AddPrecacheStaticMesh(StaticMesh'AW-2004Particles.Debris.Veh_Debris1');
	L.AddPrecacheStaticMesh(StaticMesh'ONSWeapons-SM.PC_MantaJumpBlast');

	L.AddPrecacheMaterial(Material'ExplosionTex.Framed.exp2_frames');
    L.AddPrecacheMaterial(Material'ExplosionTex.Framed.exp1_frames');
    L.AddPrecacheMaterial(Material'ExplosionTex.Framed.we1_frames');
    L.AddPrecacheMaterial(Material'AW-2004Particles.Fire.MuchSmoke1');
    L.AddPrecacheMaterial(Material'AW-2004Particles.Fire.NapalmSpot');
    L.AddPrecacheMaterial(Material'EpicParticles.Fire.SprayFire1');
    L.AddPrecacheMaterial(Material'WeaponSkins.Skins.RocketTex0');
    L.AddPrecacheMaterial(Material'AW-2004Particles.Energy.JumpDuck');
    L.AddPrecacheMaterial(Material'VMVehicles-TX.HoverBikeGroup.hovercraftFANSblurTEX');
    L.AddPrecacheMaterial(Material'VMVehicles-TX.HoverBikeGroup.hoverCraftRED');
    L.AddPrecacheMaterial(Material'VMVehicles-TX.HoverBikeGroup.hoverCraftBLUE');
    L.AddPrecacheMaterial(Material'VMVehicles-TX.HoverBikeGroup.NewHoverCraftNOcolor');
    L.AddPrecacheMaterial(Material'AW-2004Particles.Energy.AirBlast');
    L.AddPrecacheMaterial(Material'AW-2004Particles.Weapons.SmokePanels2');
    L.AddPrecacheMaterial(Material'Engine.GRADIENT_Fade');

}

simulated function UpdatePrecacheStaticMeshes()
{
	Level.AddPrecacheStaticMesh(StaticMesh'ONSDeadVehicles-SM.HoverExploded.HoverWing');
	Level.AddPrecacheStaticMesh(StaticMesh'ONSDeadVehicles-SM.HoverExploded.HoverChair');
	Level.AddPrecacheStaticMesh(StaticMesh'AW-2004Particles.Debris.Veh_Debris2');
	Level.AddPrecacheStaticMesh(StaticMesh'AW-2004Particles.Debris.Veh_Debris1');
	Level.AddPrecacheStaticMesh(StaticMesh'ONSWeapons-SM.PC_MantaJumpBlast');
    Level.AddPrecacheMaterial(Material'VMVehicles-TX.HoverBikeGroup.hovercraftFANSblurTEX');

	Super.UpdatePrecacheStaticMeshes();
}

simulated function UpdatePrecacheMaterials()
{
    Level.AddPrecacheMaterial(Material'ExplosionTex.Framed.exp2_frames');
    Level.AddPrecacheMaterial(Material'ExplosionTex.Framed.exp1_frames');
    Level.AddPrecacheMaterial(Material'ExplosionTex.Framed.we1_frames');
    Level.AddPrecacheMaterial(Material'AW-2004Particles.Fire.MuchSmoke1');
    Level.AddPrecacheMaterial(Material'AW-2004Particles.Fire.NapalmSpot');
    Level.AddPrecacheMaterial(Material'EpicParticles.Fire.SprayFire1');
    Level.AddPrecacheMaterial(Material'WeaponSkins.Skins.RocketTex0');
    Level.AddPrecacheMaterial(Material'AW-2004Particles.Energy.JumpDuck');
    Level.AddPrecacheMaterial(Material'VMVehicles-TX.HoverBikeGroup.hoverCraftRED');
    Level.AddPrecacheMaterial(Material'VMVehicles-TX.HoverBikeGroup.hoverCraftBLUE');
    Level.AddPrecacheMaterial(Material'VMVehicles-TX.HoverBikeGroup.NewHoverCraftNOcolor');
    Level.AddPrecacheMaterial(Material'AW-2004Particles.Energy.AirBlast');
    Level.AddPrecacheMaterial(Material'AW-2004Particles.Weapons.SmokePanels2');
    Level.AddPrecacheMaterial(Material'Engine.GRADIENT_Fade');

	Super.UpdatePrecacheMaterials();
}

defaultproperties
{
     MaxPitchSpeed=1000.000000
     JumpDuration=0.220000
     JumpForceMag=100.000000
     JumpDelay=3.000000
     DuckForceMag=150.000000
     BikeDustOffset(0)=(X=25.000000,Y=80.000000,Z=10.000000)
     BikeDustOffset(1)=(X=25.000000,Y=-80.000000,Z=10.000000)
     BikeDustTraceDistance=200.000000
     JumpSound=Sound'ONSVehicleSounds-S.HoverBike.HoverBikeJump05'
     DuckSound=Sound'ONSVehicleSounds-S.HoverBike.HoverBikeTurbo01'
     JumpForce="HoverBikeJump"
     ThrusterOffsets(0)=(X=95.000000,Z=10.000000)
     ThrusterOffsets(1)=(X=-10.000000,Y=80.000000,Z=10.000000)
     ThrusterOffsets(2)=(X=-10.000000,Y=-80.000000,Z=10.000000)
     HoverSoftness=0.090000
     HoverPenScale=1.000000
     HoverCheckDist=150.000000
     UprightStiffness=500.000000
     UprightDamping=300.000000
     MaxThrustForce=27.000000
     LongDamping=0.020000
     MaxStrafeForce=20.000000
     LatDamping=0.100000
     TurnTorqueFactor=1000.000000
     TurnTorqueMax=125.000000
     TurnDamping=40.000000
     MaxYawRate=1.500000
     PitchTorqueFactor=200.000000
     PitchTorqueMax=9.000000
     PitchDamping=20.000000
     RollTorqueTurnFactor=450.000000
     RollTorqueStrafeFactor=50.000000
     RollTorqueMax=12.500000
     RollDamping=30.000000
     StopThreshold=100.000000
     DriverWeapons(0)=(WeaponClass=Class'Onslaught.ONSHoverBikePlasmaGun',WeaponBone="PlasmaGunAttachment")
     bHasAltFire=False
     RedSkin=Shader'VMVehicles-TX.HoverBikeGroup.HoverBikeChassisFinalRED'
     BlueSkin=Shader'VMVehicles-TX.HoverBikeGroup.HoverBikeChassisFinalBLUE'
     IdleSound=Sound'ONSVehicleSounds-S.HoverBike.HoverBikeEng02'
     StartUpSound=Sound'ONSVehicleSounds-S.HoverBike.HoverBikeStart01'
     ShutDownSound=Sound'ONSVehicleSounds-S.HoverBike.HoverBikeStop01'
     StartUpForce="HoverBikeStartUp"
     ShutDownForce="HoverBikeShutDown"
     DestroyedVehicleMesh=StaticMesh'ONSDeadVehicles-SM.HoverBikeDead'
     DestructionEffectClass=Class'Onslaught.ONSSmallVehicleExplosionEffect'
     DisintegrationEffectClass=Class'Onslaught.ONSVehDeathHoverBike'
     DestructionLinearMomentum=(Min=62000.000000,Max=100000.000000)
     DestructionAngularMomentum=(Min=25.000000,Max=75.000000)
     DamagedEffectScale=0.600000
     DamagedEffectOffset=(X=50.000000,Y=-25.000000,Z=10.000000)
     ImpactDamageMult=0.000100
     HeadlightCoronaOffset(0)=(X=73.000000,Y=10.000000,Z=14.000000)
     HeadlightCoronaOffset(1)=(X=73.000000,Y=-10.000000,Z=14.000000)
     HeadlightCoronaMaterial=Texture'EpicParticles.Flares.FlashFlare1'
     HeadlightCoronaMaxSize=60.000000
     bDrawDriverInTP=True
     bTurnInPlace=True
     bShowDamageOverlay=True
     bScriptedRise=True
     bShowChargingBar=True
     bDriverHoldsFlag=False
     bCanCarryFlag=False
     DrivePos=(X=-18.438000,Z=60.000000)
     ExitPositions(0)=(Y=300.000000,Z=100.000000)
     ExitPositions(1)=(Y=-300.000000,Z=100.000000)
     ExitPositions(2)=(X=350.000000,Z=100.000000)
     ExitPositions(3)=(X=-350.000000,Z=100.000000)
     ExitPositions(4)=(X=-350.000000,Z=-100.000000)
     ExitPositions(5)=(X=350.000000,Z=-100.000000)
     ExitPositions(6)=(Y=300.000000,Z=-100.000000)
     ExitPositions(7)=(Y=-300.000000,Z=-100.000000)
     EntryRadius=140.000000
     FPCamPos=(Z=50.000000)
     TPCamDistance=500.000000
     TPCamLookat=(X=0.000000,Z=0.000000)
     TPCamWorldOffset=(Z=120.000000)
     VehiclePositionString="in a Manta"
     VehicleNameString="Manta"
     RanOverDamageType=Class'Onslaught.DamTypeHoverBikeHeadshot'
     CrushedDamageType=Class'Onslaught.DamTypeHoverBikePancake'
     MaxDesireability=0.600000
     ObjectiveGetOutDist=750.000000
     FlagBone="HoverCraft"
     FlagOffset=(Z=45.000000)
     FlagRotation=(Yaw=32768)
     HornSounds(0)=Sound'ONSVehicleSounds-S.Horns.Horn02'
     HornSounds(1)=Sound'ONSVehicleSounds-S.Horns.La_Cucharacha_Horn'
     bCanStrafe=True
     MeleeRange=-100.000000
     GroundSpeed=2000.000000
     HealthMax=200.000000
     Health=200
     Mesh=SkeletalMesh'ONSVehicles-A.HoverBike'
     SoundRadius=900.000000
     Begin Object Class=KarmaParamsRBFull Name=KParams0
         KInertiaTensor(0)=1.300000
         KInertiaTensor(3)=4.000000
         KInertiaTensor(5)=4.500000
         KLinearDamping=0.150000
         KAngularDamping=0.000000
         KStartEnabled=True
         bHighDetailOnly=False
         bClientOnly=False
         bKDoubleTickRate=True
         bKStayUpright=True
         bKAllowRotate=True
         bDestroyOnWorldPenetrate=True
         bDoSafetime=True
         KFriction=0.500000
         KImpactThreshold=700.000000
     End Object
     KParams=KarmaParamsRBFull'Onslaught.ONSHoverBike.KParams0'

     bTraceWater=True
}
