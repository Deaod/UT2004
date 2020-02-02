//=============================================================================
// ASTurret_LinkTurret
//=============================================================================
// Created by Laurent Delayen
// © 2003, Epic Games, Inc.  All Rights Reserved
//=============================================================================

class ASTurret_LinkTurret extends ASTurret;

#exec OBJ LOAD FILE=Turrets.utx

var 	float	Energy, OldEnergy;

// Shield effect actors
var	class<Actor>	GenericShieldEffect[2];
var	float			NextShieldTime;

var		float	RechargeWait;
var		float	RechargeSpeed;
var 	float  	LastEnergyUse;

var vector ShieldPivot;

replication
{
	reliable if (Role==ROLE_Authority && bNetDirty && bNetOwner )
    	Energy;
}

simulated function UpdateLinkColor( LinkAttachment.ELinkColor Color )
{
	switch ( Color )
	{
		case LC_Gold	:	Skins[2] = material'PowerPulseShaderYellow';	break;
		case LC_Green	:	Skins[2] = material'PowerPulseShader';			break;
		case LC_Red		: 	Skins[2] = material'PowerPulseShaderRed';		break;
		case LC_Blue	: 	Skins[2] = material'PowerPulseShaderBlue';		break;
	}
	Skins[0] = Combiner'AS_Weapons_TX.LinkTurret.LinkTurret_Skin2_C';
}


simulated function bool CheckRecharge()
{
	return ( Energy<default.Energy && (Level.TimeSeconds > LastEnergyUse + RechargeWait) );
}

// FIXME: move this to a timer...
simulated function Tick(float DeltaTime)
{
	if ( Role == Role_Authority && CheckRecharge() ) 
	{
		// Play Recharge Sound
		Energy += Default.Energy * (DeltaTime / RechargeSpeed);
        if ( Energy >= Default.Energy )
        {
        	Energy = Default.Energy;
        }
    }

	super.Tick(DeltaTime);
}

simulated function PlayFiring(optional float Rate, optional name FiringMode )
{
	PlayAnim('Fire', 1.f);
}

simulated function DrawHealthInfo( Canvas C, PlayerController PC );

simulated function DrawVehicleHUD( Canvas C, PlayerController PC )
{
	if ( !PC.bBehindView )
	{
		C.Style = 255;
		C.SetPos(0,0);
		C.DrawColor = class'Canvas'.static.MakeColor(255,255,255);
		C.DrawTile( Material'Turrets.TurretHud2', C.SizeX, C.SizeY, 0, 0, 1024, 768 );
	}
	super.DrawVehicleHUD( C, PC );
}

simulated function DrawWeaponInfo( Canvas C, HUD H )
{
	local float		XL, YL;
	local float		E, XO, YO, myfPulse;

	C.Style = ERenderStyle.STY_Alpha;

	XL = 256 * 0.5 * H.ResScaleX * H.HUDScale;
	YL = 128 * 0.5 * H.ResScaleY * H.HUDScale;

	// Team color overlay
	C.DrawColor = class'HUD_Assault'.static.GetTeamColor( Team );
	C.SetPos( C.ClipX - XL, C.ClipY - YL );
	C.DrawTile(Texture'AS_FX_TX.HUD.SpaceHUD_Weapon_Grey', XL, YL, 0, 0, 256, 128);

	// Solid Background
	C.DrawColor = class'Canvas'.Static.MakeColor(255, 255, 255);
	C.SetPos( C.ClipX - XL, C.ClipY - YL );
	C.DrawTile(WeaponInfoTexture, XL, YL, 0, 0, 256, 128);

    E = Energy / default.Energy;
	XL = 53 * 0.5 * H.ResScaleX * H.HUDScale;
	YL = 10 * 0.5 * H.ResScaleY * H.HUDScale;
	XO = C.ClipX - 57 * 0.5 * H.ResScaleX * H.HUDScale;
	YO = C.ClipY - 63 * 0.5 * H.ResScaleY * H.HUDScale;

	C.DrawColor = class'HUD_Assault'.static.GetGYRColorRamp( E );
	C.DrawColor.A = 96;

	if ( E == 1.f )
	{
		// Ugly hack FIXME
		if ( HUD_Assault(H) != None )
			myfPulse = HUD_Assault(H).fPulse;
		else
			myfPulse = 1.f;

		C.DrawColor = C.DrawColor * myfPulse + class'Canvas'.Static.MakeColor(255, 255, 255) * (1.f-myfPulse);
		C.DrawColor.A = 128 + 127 * ( 1.f - myfPulse );
	}

	C.SetPos( XO - XL*0.5, YO - YL*0.5 );
	C.DrawTile(Texture'InterfaceContent.WhileSquare', XL*E, YL, 0, 0, 8, 8);
}


simulated function vector FPVAdjustBeamStart()
{
	local float				XOffset;
	local float				ZoomPct;
	local PlayerController	PC;

	PC = PlayerController(Controller);
    if ( PC != None && IsLocallyControlled() && !PC.bBehindView )
	{
		ZoomPct	= 1 - (PC.FOVAngle-MinPlayerFOV) / (PC.DefaultFOV-MinPlayerFOV);
        XOffset	= -160 * (1-ZoomPct);
	}

	return GetFireStart( XOffset );
}

simulated function PostZoomAdjust( float ZoomPct )
{
	// Fudge the weapon effects so they look right
    if ( Weapon != None )
		Weapon.SmallViewOffset.X = Weapon.default.SmallViewOffset.X - (ZoomWeaponOffsetAdjust * ZoomPct);
}

function PossessedBy(Controller C)
{
	super.PossessedBy(C);

    if ( Weapon != None )
		Weapon.SmallViewOffset.X = -25;
}


simulated function bool SpecialCalcView(out actor ViewActor, out vector CameraLocation, out rotator CameraRotation )
{
	local bool b;
	
	b = super.SpecialCalcView(ViewActor, CameraLocation, CameraRotation );
    if ( Driver != None )
	    Driver.bOwnerNoSee = false;

    return b;
}

function AdjustDriverDamage(out int Damage, Pawn InstigatedBy, Vector HitLocation, out Vector Momentum, class<DamageType> DamageType)
{
	super.AdjustDriverDamage(Damage, InstigatedBy, HitLocation, Momentum, DamageType);

    if ( PlayerController(Controller) != None )
	    PlayerController(Controller).ClientFlash(DamageType.Default.FlashScale,DamageType.Default.FlashFog);
}

function TakeDamage( int Damage, Pawn instigatedBy, Vector hitlocation,
						Vector momentum, class<DamageType> damageType)
{
	local int		OldHealth, EnergyUsed;
    local vector	x,y,z,v;

	if ( Energy > 0 )
    {
        GetAxes(Rotation, X, Y, Z);
		if ( HitLocation == vect(0,0,0) || HitLocation == Location )
			HitLocation = Location + X * 50;
        V = Normal(HitLocation - Location);
        if ( (V dot X) >= 0 )
	    {
			EnergyUsed = Max(float(Damage)*0.67, 1);
            Damage =  Max(float(Damage)*0.33, 1);
        }
    }

	OldHealth = Health;
	if ( Damage > 0 )
		super.TakeDamage(Damage, InstigatedBy, HitLocation, momentum, DamageType);
	
	if ( Health < OldHealth && EnergyUsed > 0 )
	{
		UseEnergy( EnergyUsed );
		if ( Role == Role_Authority )
			DoShieldEffect(HitLocation, Normal(HitLocation - Location) );
	}
}

function UseEnergy(int Amount)
{
    LastEnergyUse = Level.TimeSeconds;
   	Energy = FMax(Energy-Amount, 0);
}

function DoShieldEffect(vector HitLocation, vector HitNormal)
{
	local Actor ShieldEffect;
	local byte	TeamShield;

	if ( Team > 1 )
		TeamShield = 1;
	else
		TeamShield = Team;

	if ( EffectIsRelevant(HitLocation, true) && NextShieldTime < Level.TimeSeconds )
	{
		NextShieldTime = Level.TimeSeconds + 0.1;
		ShieldEffect = Spawn(GenericShieldEffect[TeamShield], Self,, HitLocation + HitNormal * 10, rotator(HitNormal));
	}
}

static function StaticPrecache(LevelInfo L)
{
    super.StaticPrecache( L );

	L.AddPrecacheMaterial( Material'AS_Weapons_TX.LinkTurret.LinkTurret_skin1' );		// Skins
	L.AddPrecacheMaterial( Material'AS_Weapons_TX.LinkTurret.LinkTurret_skin2' );
	L.AddPrecacheMaterial( material'PowerPulseShader' );
	L.AddPrecacheMaterial( material'PowerPulseShaderRed' );
	L.AddPrecacheMaterial( material'PowerPulseShaderBlue' );
	
	L.AddPrecacheMaterial( Material'Turrets.TurretHud2' );	// HUD
	L.AddPrecacheMaterial( Texture'AS_FX_TX.HUD.SpaceHUD_Weapon_Grey' );
	L.AddPrecacheMaterial( Texture'InterfaceContent.WhileSquare' );

	L.AddPrecacheMaterial( Material'ExplosionTex.Framed.exp7_frames' );			// Explosion Effect
	L.AddPrecacheMaterial( Material'EpicParticles.Flares.SoftFlare' );
	L.AddPrecacheMaterial( Material'AW-2004Particles.Fire.MuchSmoke2t' );
	L.AddPrecacheMaterial( Material'AS_FX_TX.Trails.Trail_red' );
	L.AddPrecacheMaterial( Material'ExplosionTex.Framed.exp1_frames' );
	L.AddPrecacheMaterial( Material'EmitterTextures.MultiFrame.rockchunks02' );

	L.AddPrecacheMaterial( Texture'AS_FX_TX.Flares.Laser_Flare' );	// Fire Effect
	L.AddPrecacheMaterial( Texture'EpicParticles.Smoke.StellarFog1aw' );
	L.AddPrecacheStaticMesh( StaticMesh'AS_Weapons_SM.Projectiles.Skaarj_Energy' );

	L.AddPrecacheStaticMesh( StaticMesh'AS_Weapons_SM.Turret.LinkBase' );
	
	//L.AddPrecacheMaterial( Material'AS_FX_TX.WhiteShield_FB' );		// Shield Effect
	//L.AddPrecacheStaticMesh( StaticMesh'LinkTurretShield' );
	L.AddPrecacheStaticMesh( StaticMesh'WeaponStaticMesh.Shield' );
	L.AddPrecacheMaterial( Material'XEffectMat.RedShell' );
	L.AddPrecacheMaterial( Material'XEffectMat.BlueShell' );
}

simulated function UpdatePrecacheStaticMeshes()
{
	Level.AddPrecacheStaticMesh( StaticMesh'AS_Weapons_SM.Turret.LinkBase' );
	//Level.AddPrecacheStaticMesh( StaticMesh'LinkTurretShield' );
	Level.AddPrecacheStaticMesh( StaticMesh'AS_Weapons_SM.Projectiles.Skaarj_Energy' );
	Level.AddPrecacheStaticMesh( StaticMesh'WeaponStaticMesh.Shield' );

	super.UpdatePrecacheStaticMeshes();
}


simulated function UpdatePrecacheMaterials()
{
	Level.AddPrecacheMaterial( Material'AS_Weapons_TX.LinkTurret.LinkTurret_skin1' );		// Skins
	Level.AddPrecacheMaterial( Material'AS_Weapons_TX.LinkTurret.LinkTurret_skin2' );
	Level.AddPrecacheMaterial( material'PowerPulseShader' );
	Level.AddPrecacheMaterial( material'PowerPulseShaderRed' );
	Level.AddPrecacheMaterial( material'PowerPulseShaderBlue' );
	Level.AddPrecacheMaterial( material'PowerPulseShaderYellow' );
	
	//Level.AddPrecacheMaterial( Material'AS_FX_TX.WhiteShield_FB' );	
	Level.AddPrecacheMaterial( Material'XEffectMat.RedShell' );
	Level.AddPrecacheMaterial( Material'XEffectMat.BlueShell' );

	Level.AddPrecacheMaterial( Material'Turrets.TurretHud2' );	// HUD
	Level.AddPrecacheMaterial( Texture'AS_FX_TX.HUD.SpaceHUD_Weapon_Grey' );
	Level.AddPrecacheMaterial( Texture'InterfaceContent.WhileSquare' );

	Level.AddPrecacheMaterial( Material'ExplosionTex.Framed.exp7_frames' );			// Explosion Effect
	Level.AddPrecacheMaterial( Material'EpicParticles.Flares.SoftFlare' );
	Level.AddPrecacheMaterial( Material'AW-2004Particles.Fire.MuchSmoke2t' );
	Level.AddPrecacheMaterial( Material'AS_FX_TX.Trails.Trail_red' );
	Level.AddPrecacheMaterial( Material'ExplosionTex.Framed.exp1_frames' );
	Level.AddPrecacheMaterial( Material'EmitterTextures.MultiFrame.rockchunks02' );

	Level.AddPrecacheMaterial( Texture'AS_FX_TX.Flares.Laser_Flare' );	// Fire Effect
	Level.AddPrecacheMaterial( Texture'EpicParticles.Smoke.StellarFog1aw' );

	super.UpdatePrecacheMaterials();
}

defaultproperties
{
     Energy=1500.000000
     GenericShieldEffect(0)=Class'UT2k4AssaultFull.FX_SpaceFighter_Shield_Red'
     GenericShieldEffect(1)=Class'UT2k4AssaultFull.FX_SpaceFighter_Shield'
     RechargeWait=4.000000
     RechargeSpeed=10.000000
     TurretBaseClass=Class'UT2k4AssaultFull.ASTurret_LinkTurret_Base'
     TurretSwivelClass=Class'UT2k4AssaultFull.ASTurret_LinkTurret_Swivel'
     RotationInertia=0.500000
     RotPitchConstraint=(Min=8000.000000,Max=5000.000000)
     RotationSpeed=5.000000
     CamRelLocation=(X=250.000000,Z=150.000000)
     CamDistance=(Z=0.000000)
     ZoomWeaponOffsetAdjust=275.000000
     WeaponInfoTexture=Texture'AS_FX_TX.HUD.SpaceHUD_Weapon_Solid_Skaarj'
     DefaultWeaponClassName="UT2k4AssaultFull.Weapon_LinkTurret"
     VehicleProjSpawnOffset=(X=220.000000,Y=0.000000,Z=15.000000)
     bCHZeroYOffset=False
     bRelativeExitPos=False
     bHideRemoteDriver=True
     AutoTurretControllerClass=Class'UT2k4AssaultFull.LinkTurretController'
     DriveAnim="Biggun_Aimed"
     VehiclePositionString="manning a Link Turret"
     VehicleNameString="Link Turret"
     HealthMax=400.000000
     Health=400
     Mesh=SkeletalMesh'AS_VehiclesFull_M.LinkBody'
     DrawScale=0.300000
     CollisionHeight=116.000000
     bNetNotify=True
}
