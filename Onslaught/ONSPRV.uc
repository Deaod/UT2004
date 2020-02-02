//-----------------------------------------------------------
//
//-----------------------------------------------------------
class ONSPRV extends ONSWheeledCraft;

#exec OBJ LOAD FILE=..\Animations\ONSVehicles-A.ukx
#exec OBJ LOAD FILE=..\Sounds\ONSVehicleSounds-S.uax
#exec OBJ LOAD FILE=..\textures\VehicleFX.utx
#exec OBJ LOAD FILE=..\textures\EpicParticles.utx
#exec OBJ LOAD FILE=..\textures\VMVehicles-TX.utx
#exec OBJ LOAD FILE=..\textures\2k4Fonts.utx

var ScriptedTexture LicensePlate;
var Material        LicensePlateFallBack;
var Material        LicensePlateBackground;
var string          LicensePlateName;
var Font            LicensePlateFont;

simulated function PostBeginPlay()
{
    Super.PostBeginPlay();

    if (Level.NetMode != NM_DedicatedServer)
    {
        LicensePlate = ScriptedTexture(Level.ObjectPool.AllocateObject(class'ScriptedTexture'));
        LicensePlate.SetSize(256,128);
        LicensePlate.FallBackMaterial = LicensePlateFallBack;
        LicensePlate.Client = Self;
        Skins[3] = LicensePlate;
        LicensePlateFont = Font(DynamicLoadObject("2k4Fonts.Verdana28", class'Font'));
    }
}

simulated event RenderTexture(ScriptedTexture Tex)
{
    local int SizeX,  SizeY;
    local color BackColor, ForegroundColor, HighLightColor;

    HighLightColor.R=100;
    HighLightColor.G=100;
    HighLightColor.B=100;
    HighLightColor.A=255;

    ForegroundColor.R=25;
    ForegroundColor.G=25;
    ForegroundColor.B=25;
    ForegroundColor.A=255;

    BackColor.R=128;
    BackColor.G=128;
    BackColor.B=128;
    BackColor.A=0;

    if (bDriving)
    {
        Tex.TextSize(LicensePlateName, LicensePlateFont, SizeX, SizeY);
        Tex.DrawTile(0, 0, Tex.USize, Tex.VSize, 0, 0, Tex.USize, Tex.VSize, LicensePlateBackground, BackColor);
        Tex.DrawText(((Tex.USize - SizeX) * 0.5) - 1, 40 - 1, LicensePlateName, LicensePlateFont, HighLightColor);
        Tex.DrawText((Tex.USize - SizeX) * 0.5, 40, LicensePlateName, LicensePlateFont, ForegroundColor);
    }
    else
        Tex.DrawTile(0, 0, Tex.USize, Tex.VSize, 0, 0, Tex.USize, Tex.VSize, LicensePlateFallBack, BackColor);
}

simulated event DrivingStatusChanged()
{
    local array<String> Characters;
    local int i, AscCode;

    if (bDriving && LicensePlate != None)
    {
        LicensePlateName = Caps(PlayerReplicationInfo.PlayerName);
        if (Len(LicensePlateName) > 8)
        {
            // First try removing all brackets, braces, greater/less-thans, and parentheses
            LicensePlateName = Repl(LicensePlateName, "[", "", false);
            LicensePlateName = Repl(LicensePlateName, "]", "", false);
            LicensePlateName = Repl(LicensePlateName, "(", "", false);
            LicensePlateName = Repl(LicensePlateName, ")", "", false);
            LicensePlateName = Repl(LicensePlateName, "{", "", false);
            LicensePlateName = Repl(LicensePlateName, "}", "", false);
            LicensePlateName = Repl(LicensePlateName, "<", "", false);
            LicensePlateName = Repl(LicensePlateName, ">", "", false);

            // If still not small enough, remove symbols one by one from right to left
            if (Len(LicensePlateName) > 8)
            {
                // Split into character array this way since Split() won't do this without crashing
                for (i=0; i<Len(LicensePlateName); i++)
                    Characters[i] = Mid(LicensePlateName, i, 1);

                for (i=Characters.Length-1; i>=0; i--)
                {
                    AscCode = Asc(Characters[i]);

                    if (AscCode < 65 || AscCode > 90)
                        Characters.Remove(i, 1);

                    if (Characters.Length <= 8)
                        break;
                }

                // If still not small enough, remove vowels one by one from right to left
                if (Characters.Length > 8)
                {
                    for (i=Characters.Length-1; i>=0; i--)
                    {
                        AscCode = Asc(Characters[i]);

                        switch(AscCode)
                        {
                            case 65:    Characters.Remove(i, 1);
                                        break;
                            case 69:    Characters.Remove(i, 1);
                                        break;
                            case 73:    Characters.Remove(i, 1);
                                        break;
                            case 79:    Characters.Remove(i, 1);
                                        break;
                            case 85:    Characters.Remove(i, 1);
                                        break;
                        }

                        if (Characters.Length <= 8)
                            break;
                    }
                }

                // Rebuild the string from all our munging
                LicensePlateName = "";
                for (i=0; i<Characters.Length; i++)
                    LicensePlateName $= Characters[i];
            }

            // You can't say I didn't try, but just in case your name is insane...
            LicensePlateName = Left(LicensePlateName, 8);
        }
        LicensePlate.Revision++;
    }

    Super.DrivingStatusChanged();
}

simulated event Destroyed()
{
    if (LicensePlate != None)
    {
        LicensePlate.Client = None;
        Level.ObjectPool.FreeObject(LicensePlate);
    }

    Super.Destroyed();
}

function VehicleFire(bool bWasAltFire)
{
	ServerPlayHorn(0);
}

function float BotDesireability(Actor S, int TeamIndex, Actor Objective)
{
	local Bot B;
	local SquadAI Squad;
	local int Num;

	if ( Level.Game.JustStarted(20) && !Level.Game.IsA('ASGameInfo') )
		return Super.BotDesireability(S, TeamIndex, Objective);

	Squad = SquadAI(S);

	if (Squad.Size == 1)
	{
		if ( (Squad.Team != None) && (Squad.Team.Size == 1) && Level.Game.IsA('ASGameInfo') )
			return Super.BotDesireability(S, TeamIndex, Objective);
		return 0;
	}

	for (B = Squad.SquadMembers; B != None; B = B.NextSquadMember)
		if (Vehicle(B.Pawn) == None && (B.RouteGoal == self || B.Pawn == None || VSize(B.Pawn.Location - Location) < Squad.MaxVehicleDist(B.Pawn)))
			Num++;

	if ( Num < 2 )
		return 0;

	return Super.BotDesireability(S, TeamIndex, Objective);
}

function Vehicle FindEntryVehicle(Pawn P)
{
	local Bot B;
	local int i;

	if ( Level.Game.JustStarted(20) )
		return Super.FindEntryVehicle(P);

	B = Bot(P.Controller);
	if (B == None || WeaponPawns.length == 0 || !IsVehicleEmpty() || ((B.PlayerReplicationInfo.Team != None) && (B.PlayerReplicationInfo.Team.Size == 1) && Level.Game.IsA('ASGameInfo')) )
		return Super.FindEntryVehicle(P);

	for (i = WeaponPawns.length - 1; i >= 0; i--)
		if (WeaponPawns[i].Driver == None)
			return WeaponPawns[i];

	return Super.FindEntryVehicle(P);
}

static function StaticPrecache(LevelInfo L)
{
    Super.StaticPrecache(L);

	L.AddPrecacheStaticMesh(StaticMesh'ONSDeadVehicles-SM.HELLbenderExploded.HellTire');
	L.AddPrecacheStaticMesh(StaticMesh'ONSDeadVehicles-SM.HELLbenderExploded.HellDoor');
	L.AddPrecacheStaticMesh(StaticMesh'ONSDeadVehicles-SM.HELLbenderExploded.HellGun');
	L.AddPrecacheStaticMesh(StaticMesh'AW-2004Particles.Debris.Veh_Debris2');
	L.AddPrecacheStaticMesh(StaticMesh'AW-2004Particles.Debris.Veh_Debris1');

    L.AddPrecacheMaterial(Material'AW-2004Particles.Energy.SparkHead');
    L.AddPrecacheMaterial(Material'ExplosionTex.Framed.exp2_frames');
    L.AddPrecacheMaterial(Material'ExplosionTex.Framed.exp1_frames');
    L.AddPrecacheMaterial(Material'ExplosionTex.Framed.we1_frames');
    L.AddPrecacheMaterial(Material'AW-2004Particles.Fire.MuchSmoke1');
    L.AddPrecacheMaterial(Material'AW-2004Particles.Fire.NapalmSpot');
    L.AddPrecacheMaterial(Material'EpicParticles.Fire.SprayFire1');
    L.AddPrecacheMaterial(Material'VMVehicles-TX.NEWprvGroup.newPRVnoColor');
    L.AddPrecacheMaterial(Material'VMVehicles-TX.NEWprvGroup.PRVcolorRED');
    L.AddPrecacheMaterial(Material'VMVehicles-TX.NEWprvGroup.PRVcolorBLUE');
    L.AddPrecacheMaterial(Material'VMVehicles-TX.NEWprvGroup.EnergyEffectMASKtex');
    L.AddPrecacheMaterial(Material'AW-2004Particles.Energy.PowerSwirl');
    L.AddPrecacheMaterial(Material'VMWeaponsTX.ManualBaseGun.baseGunEffectcopy');
    L.AddPrecacheMaterial(Material'VehicleFX.Particles.DustyCloud2');
    L.AddPrecacheMaterial(Material'VMParticleTextures.DirtKICKGROUP.dirtKICKTEX');
    L.AddPrecacheMaterial(Material'Engine.GRADIENT_Fade');
    L.AddPrecacheMaterial(Material'VMVehicles-TX.NEWprvGroup.PRVtagFallBack');
    L.AddPrecacheMaterial(Material'VMVehicles-TX.NEWprvGroup.prvTAGSCRIPTED');
}

simulated function UpdatePrecacheStaticMeshes()
{
	Level.AddPrecacheStaticMesh(StaticMesh'ONSDeadVehicles-SM.HELLbenderExploded.HellTire');
	Level.AddPrecacheStaticMesh(StaticMesh'ONSDeadVehicles-SM.HELLbenderExploded.HellDoor');
	Level.AddPrecacheStaticMesh(StaticMesh'ONSDeadVehicles-SM.HELLbenderExploded.HellGun');
	Level.AddPrecacheStaticMesh(StaticMesh'AW-2004Particles.Debris.Veh_Debris2');
	Level.AddPrecacheStaticMesh(StaticMesh'AW-2004Particles.Debris.Veh_Debris1');

    Super.UpdatePrecacheStaticMeshes();
}

simulated function UpdatePrecacheMaterials()
{
    Level.AddPrecacheMaterial(Material'AW-2004Particles.Energy.SparkHead');
    Level.AddPrecacheMaterial(Material'ExplosionTex.Framed.exp2_frames');
    Level.AddPrecacheMaterial(Material'ExplosionTex.Framed.exp1_frames');
    Level.AddPrecacheMaterial(Material'ExplosionTex.Framed.we1_frames');
    Level.AddPrecacheMaterial(Material'AW-2004Particles.Fire.MuchSmoke1');
    Level.AddPrecacheMaterial(Material'AW-2004Particles.Fire.NapalmSpot');
    Level.AddPrecacheMaterial(Material'EpicParticles.Fire.SprayFire1');
    Level.AddPrecacheMaterial(Material'VMVehicles-TX.NEWprvGroup.newPRVnoColor');
    Level.AddPrecacheMaterial(Material'VMVehicles-TX.NEWprvGroup.PRVcolorRED');
    Level.AddPrecacheMaterial(Material'VMVehicles-TX.NEWprvGroup.PRVcolorBLUE');
    Level.AddPrecacheMaterial(Material'VMVehicles-TX.NEWprvGroup.EnergyEffectMASKtex');
    Level.AddPrecacheMaterial(Material'AW-2004Particles.Energy.PowerSwirl');
    Level.AddPrecacheMaterial(Material'VMWeaponsTX.ManualBaseGun.baseGunEffectcopy');
    Level.AddPrecacheMaterial(Material'VehicleFX.Particles.DustyCloud2');
    Level.AddPrecacheMaterial(Material'VMParticleTextures.DirtKICKGROUP.dirtKICKTEX');
    Level.AddPrecacheMaterial(Material'Engine.GRADIENT_Fade');
    Level.AddPrecacheMaterial(Material'VMVehicles-TX.NEWprvGroup.PRVtagFallBack');
    Level.AddPrecacheMaterial(Material'VMVehicles-TX.NEWprvGroup.prvTAGSCRIPTED');

	Super.UpdatePrecacheMaterials();
}

defaultproperties
{
     LicensePlate=ScriptedTexture'VMVehicles-TX.NEWprvGroup.PRVtag'
     LicensePlateFallBack=Texture'VMVehicles-TX.NEWprvGroup.PRVtagFallBack'
     LicensePlateBackground=Texture'VMVehicles-TX.NEWprvGroup.prvTAGSCRIPTED'
     WheelSoftness=0.040000
     WheelPenScale=1.500000
     WheelPenOffset=0.010000
     WheelRestitution=0.100000
     WheelInertia=0.100000
     WheelLongFrictionFunc=(Points=(,(InVal=100.000000,OutVal=1.000000),(InVal=200.000000,OutVal=0.900000),(InVal=10000000000.000000,OutVal=0.900000)))
     WheelLongSlip=0.001000
     WheelLatSlipFunc=(Points=(,(InVal=30.000000,OutVal=0.009000),(InVal=45.000000),(InVal=10000000000.000000)))
     WheelLongFrictionScale=1.100000
     WheelLatFrictionScale=1.500000
     WheelHandbrakeSlip=0.010000
     WheelHandbrakeFriction=0.100000
     WheelSuspensionTravel=25.000000
     WheelSuspensionOffset=-10.000000
     WheelSuspensionMaxRenderTravel=25.000000
     FTScale=0.030000
     ChassisTorqueScale=0.700000
     MinBrakeFriction=4.000000
     MaxSteerAngleCurve=(Points=((OutVal=25.000000),(InVal=1500.000000,OutVal=8.000000),(InVal=1000000000.000000,OutVal=8.000000)))
     TorqueCurve=(Points=((OutVal=9.000000),(InVal=200.000000,OutVal=10.000000),(InVal=1500.000000,OutVal=11.000000),(InVal=2500.000000)))
     GearRatios(0)=-0.500000
     GearRatios(1)=0.400000
     GearRatios(2)=0.650000
     GearRatios(3)=0.850000
     GearRatios(4)=1.100000
     TransRatio=0.110000
     ChangeUpPoint=2000.000000
     ChangeDownPoint=1000.000000
     LSDFactor=1.000000
     EngineBrakeFactor=0.000100
     EngineBrakeRPMScale=0.100000
     MaxBrakeTorque=20.000000
     SteerSpeed=110.000000
     TurnDamping=35.000000
     StopThreshold=100.000000
     HandbrakeThresh=200.000000
     EngineInertia=0.100000
     IdleRPM=500.000000
     EngineRPMSoundRange=10000.000000
     SteerBoneAxis=AXIS_Z
     SteerBoneMaxAngle=90.000000
     RevMeterScale=4000.000000
     bMakeBrakeLights=True
     BrakeLightOffset(0)=(X=-173.000000,Y=73.000000,Z=30.000000)
     BrakeLightOffset(1)=(X=-173.000000,Y=-73.000000,Z=30.000000)
     BrakeLightMaterial=Texture'EpicParticles.Flares.FlashFlare1'
     DaredevilThreshInAirSpin=90.000000
     DaredevilThreshInAirTime=1.200000
     bDoStuntInfo=True
     bAllowBigWheels=True
     AirTurnTorque=35.000000
     AirPitchTorque=55.000000
     AirPitchDamping=35.000000
     AirRollTorque=35.000000
     AirRollDamping=35.000000
     PassengerWeapons(0)=(WeaponPawnClass=Class'Onslaught.ONSPRVSideGunPawn',WeaponBone="Dummy01")
     PassengerWeapons(1)=(WeaponPawnClass=Class'Onslaught.ONSPRVRearGunPawn',WeaponBone="Dummy02")
     RedSkin=Shader'VMVehicles-TX.NEWprvGroup.newPRVredSHAD'
     BlueSkin=Shader'VMVehicles-TX.NEWprvGroup.newPRVshad'
     IdleSound=Sound'ONSVehicleSounds-S.PRV.PRVEng01'
     StartUpSound=Sound'ONSVehicleSounds-S.PRV.PRVStart01'
     ShutDownSound=Sound'ONSVehicleSounds-S.PRV.PRVStop01'
     StartUpForce="PRVStartUp"
     ShutDownForce="PRVShutDown"
     DestroyedVehicleMesh=StaticMesh'ONSDeadVehicles-SM.newPRVdead'
     DestructionEffectClass=Class'Onslaught.ONSVehicleExplosionEffect'
     DisintegrationEffectClass=Class'Onslaught.ONSVehDeathPRV'
     DisintegrationHealth=-100.000000
     DestructionLinearMomentum=(Min=250000.000000,Max=400000.000000)
     DestructionAngularMomentum=(Min=100.000000,Max=150.000000)
     DamagedEffectScale=1.200000
     DamagedEffectOffset=(X=100.000000,Y=-10.000000,Z=35.000000)
     ImpactDamageMult=0.001000
     HeadlightCoronaOffset(0)=(X=140.000000,Y=45.000000,Z=11.000000)
     HeadlightCoronaOffset(1)=(X=140.000000,Y=-45.000000,Z=11.000000)
     HeadlightCoronaMaterial=Texture'EpicParticles.Flares.FlashFlare1'
     HeadlightCoronaMaxSize=100.000000
     HeadlightProjectorMaterial=Texture'VMVehicles-TX.NEWprvGroup.PRVprojector'
     HeadlightProjectorOffset=(X=145.000000,Z=11.000000)
     HeadlightProjectorRotation=(Pitch=-1000)
     HeadlightProjectorScale=0.650000
     Begin Object Class=SVehicleWheel Name=RRWheel
         bPoweredWheel=True
         bHandbrakeWheel=True
         BoneName="RightRearTIRe"
         BoneOffset=(X=-15.000000)
         WheelRadius=34.000000
         SupportBoneName="RightRearSTRUT"
     End Object
     Wheels(0)=SVehicleWheel'Onslaught.ONSPRV.RRWheel'

     Begin Object Class=SVehicleWheel Name=LRWheel
         bPoweredWheel=True
         bHandbrakeWheel=True
         BoneName="LeftRearTIRE"
         BoneOffset=(X=15.000000)
         WheelRadius=34.000000
         SupportBoneName="LeftRearSTRUT"
     End Object
     Wheels(1)=SVehicleWheel'Onslaught.ONSPRV.LRWheel'

     Begin Object Class=SVehicleWheel Name=RFWheel
         bPoweredWheel=True
         SteerType=VST_Steered
         BoneName="RightFrontTIRE"
         BoneOffset=(X=-15.000000)
         WheelRadius=34.000000
         SupportBoneName="RightFrontSTRUT"
     End Object
     Wheels(2)=SVehicleWheel'Onslaught.ONSPRV.RFWheel'

     Begin Object Class=SVehicleWheel Name=LFWheel
         bPoweredWheel=True
         SteerType=VST_Steered
         BoneName="LeftFrontTIRE"
         BoneOffset=(X=15.000000)
         WheelRadius=34.000000
         SupportBoneName="LeftFrontSTRUT"
     End Object
     Wheels(3)=SVehicleWheel'Onslaught.ONSPRV.LFWheel'

     VehicleMass=4.000000
     bDrawDriverInTP=True
     bCanDoTrickJumps=True
     bDrawMeshInFP=True
     bHasHandbrake=True
     bDriverHoldsFlag=False
     DrivePos=(X=16.921000,Y=-40.284000,Z=65.793999)
     ExitPositions(0)=(Y=-165.000000,Z=100.000000)
     ExitPositions(1)=(Y=165.000000,Z=100.000000)
     ExitPositions(2)=(Y=-165.000000,Z=-100.000000)
     ExitPositions(3)=(Y=165.000000,Z=-100.000000)
     EntryPosition=(X=20.000000,Y=-60.000000,Z=10.000000)
     EntryRadius=190.000000
     FPCamPos=(X=20.000000,Y=-40.000000,Z=50.000000)
     TPCamDistance=375.000000
     TPCamLookat=(X=0.000000,Z=0.000000)
     TPCamWorldOffset=(Z=100.000000)
     MomentumMult=2.000000
     DriverDamageMult=0.400000
     VehiclePositionString="in a HellBender"
     VehicleNameString="HellBender"
     RanOverDamageType=Class'Onslaught.DamTypePRVRoadkill'
     CrushedDamageType=Class'Onslaught.DamTypePRVPancake'
     ObjectiveGetOutDist=1500.000000
     FlagBone="Dummy01"
     FlagRotation=(Yaw=32768)
     HornSounds(0)=Sound'ONSVehicleSounds-S.Horns.Horn09'
     HornSounds(1)=Sound'ONSVehicleSounds-S.Horns.Horn04'
     VehicleIcon=(Material=Texture'AS_FX_TX.Icons.OBJ_HellBender',bIsGreyScale=True)
     GroundSpeed=840.000000
     HealthMax=600.000000
     Health=600
     Mesh=SkeletalMesh'ONSVehicles-A.PRVchassis'
     DrawScale=0.800000
     SoundVolume=180
     CollisionRadius=175.000000
     Begin Object Class=KarmaParamsRBFull Name=KParams0
         KInertiaTensor(0)=1.000000
         KInertiaTensor(3)=3.000000
         KInertiaTensor(5)=3.500000
         KCOMOffset=(X=-0.300000,Z=-0.500000)
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
         KImpactThreshold=500.000000
     End Object
     KParams=KarmaParamsRBFull'Onslaught.ONSPRV.KParams0'

}
