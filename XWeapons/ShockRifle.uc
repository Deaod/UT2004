//=============================================================================
// Shock Rifle
//=============================================================================
class ShockRifle extends Weapon
    config(user);

#EXEC OBJ LOAD FILE=InterfaceContent.utx

#exec OBJ LOAD FILE=..\Sounds\WeaponSounds.uax
#exec OBJ LOAD FILE=XEffectMat.utx
#exec OBJ LOAD FILE=UT2004Weapons.utx

var ShockProjectile ComboTarget;	// used by AI
var bool			bRegisterTarget;
var	bool			bWaitForCombo;
var vector			ComboStart;
var color			EffectColor;

simulated function PostBeginPlay()
{
	ConstantColor'UT2004Weapons.ShockControl'.Color = EffectColor;
	Super.PostBeginPlay();
}

simulated event RenderOverlays( Canvas Canvas )
{
	local float A;

	A = 128 * (1.0 - FMax(0,FMax((FireMode[0].NextFireTime - Level.TimeSeconds)/FireMode[0].FireRate,
								(FireMode[1].NextFireTime - Level.TimeSeconds)/FireMode[1].FireRate)));
	ConstantColor'UT2004Weapons.ShockControl'.Color.A = A;
	Super.RenderOverlays(Canvas);
}

simulated function vector GetEffectStart()
{
	local Coords C;

    if ( Instigator.IsFirstPerson() )
    {
		if ( WeaponCentered() )
			return CenteredEffectStart();
	    C = GetBoneCoords('tip');
		return C.Origin - 15 * C.XAxis;
	}
	return Super.GetEffectStart();
}

simulated function bool WeaponCentered()
{
	return ( bSpectated || (Hand > 1) );
}

// AI Interface
function float GetAIRating()
{
	local Bot B;

	B = Bot(Instigator.Controller);
	if ( B == None )
		return AIRating;

	if ( B.Enemy == None )
	{
		if ( (B.Target != None) && VSize(B.Target.Location - B.Pawn.Location) > 8000 )
			return 0.9;
		return AIRating;
	}

	if ( bWaitForCombo )
		return 1.5;
	if ( !B.ProficientWithWeapon() )
		return AIRating;
	if ( B.Stopped() )
	{
		if ( !B.EnemyVisible() && (VSize(B.Enemy.Location - Instigator.Location) < 5000) )
			return (AIRating + 0.5);
		return (AIRating + 0.3);
	}
	else if ( VSize(B.Enemy.Location - Instigator.Location) > 1600 )
		return (AIRating + 0.1);
	else if ( B.Enemy.Location.Z > B.Location.Z + 200 )
		return (AIRating + 0.15);

	return AIRating;
}

function SetComboTarget(ShockProjectile S)
{
	if ( !bRegisterTarget || (bot(Instigator.Controller) == None) || (Instigator.Controller.Enemy == None) )
		return;

	bRegisterTarget = false;
	ComboStart = Instigator.Location;
	ComboTarget = S;
	ComboTarget.Monitor(Bot(Instigator.Controller).Enemy);
}

function float RangedAttackTime()
{
	local bot B;

	B = Bot(Instigator.Controller);
	if ( (B == None) || (B.Enemy == None) )
		return 0;

	if ( B.CanComboMoving() )
		return 0;

	return FMin(2,0.3 + VSize(B.Enemy.Location - Instigator.Location)/class'ShockProjectile'.default.Speed);
}

function float SuggestAttackStyle()
{
	return -0.4;
}

simulated function bool StartFire(int mode)
{
	if ( bWaitForCombo && (Bot(Instigator.Controller) != None) )
	{
		if ( (ComboTarget == None) || ComboTarget.bDeleteMe )
			bWaitForCombo = false;
		else
			return false;
	}
	return Super.StartFire(mode);
}

function DoCombo()
{
	if ( bWaitForCombo )
	{
		bWaitForCombo = false;
		if ( (Instigator != None) && (Instigator.Weapon == self) )
			StartFire(0);
	}
}

/* BestMode()
choose between regular or alt-fire
*/
function byte BestMode()
{
	local float EnemyDist, MaxDist;
	local bot B;

	bWaitForCombo = false;
	B = Bot(Instigator.Controller);
	if ( (B == None) || (B.Enemy == None) )
		return 0;

	if (B.IsShootingObjective())
		return 0;

	if ( !B.EnemyVisible() )
	{
		if ( (ComboTarget != None) && !ComboTarget.bDeleteMe && B.CanCombo() )
		{
			bWaitForCombo = true;
			return 0;
		}
		ComboTarget = None;
		if ( B.CanCombo() && B.ProficientWithWeapon() )
		{
			bRegisterTarget = true;
			return 1;
		}
		return 0;
	}

	EnemyDist = VSize(B.Enemy.Location - Instigator.Location);
	if ( B.Skill > 5 )
		MaxDist = 4 * class'ShockProjectile'.default.Speed;
	else
		MaxDist = 3 * class'ShockProjectile'.default.Speed;

	if ( (EnemyDist > MaxDist) || (EnemyDist < 150) )
	{
		ComboTarget = None;
		return 0;
	}

	if ( (ComboTarget != None) && !ComboTarget.bDeleteMe && B.CanCombo() )
	{
		bWaitForCombo = true;
		return 0;
	}

	ComboTarget = None;

	if ( (EnemyDist > 2500) && (FRand() < 0.5) )
		return 0;

	if ( B.CanCombo() && B.ProficientWithWeapon() )
	{
		bRegisterTarget = true;
		return 1;
	}
	if ( FRand() < 0.7 )
		return 0;
	return 1;
}
// end AI Interface

defaultproperties
{
     EffectColor=(B=255,R=192,A=128)
     FireModeClass(0)=Class'XWeapons.ShockBeamFire'
     FireModeClass(1)=Class'XWeapons.ShockProjFire'
     SelectAnim="Pickup"
     PutDownAnim="PutDown"
     SelectSound=Sound'WeaponSounds.ShockRifle.SwitchToShockRifle'
     SelectForce="SwitchToShockRifle"
     AIRating=0.630000
     CurrentRating=0.630000
     OldMesh=SkeletalMesh'Weapons.ShockRifle_1st'
     OldPickup="WeaponStaticMesh.ShockRiflePickup"
     OldCenteredOffsetY=-8.000000
     OldPlayerViewOffset=(X=-15.000000,Z=-5.000000)
     OldSmallViewOffset=(X=-8.000000,Y=4.000000,Z=-8.000000)
     OldPlayerViewPivot=(Pitch=1000,Yaw=-800,Roll=-500)
     OldCenteredYaw=-500
     Description="The ASMD Shock Rifle has changed little since its incorporation into the Tournaments. The ASMD sports two firing modes capable of acting in concert to neutralize opponents in a devastating shockwave.||This combination attack is achieved when the weapon operator utilizes the secondary fire mode to deliver a charge of seeded plasma to the target.|Once the slow-moving plasma charge is within range of the target, the weapon operator may fire the photon beam into the plasma core, releasing the explosive energy of the anti-photons contained within the plasma's EM field."
     EffectOffset=(X=65.000000,Y=14.000000,Z=-10.000000)
     DisplayFOV=70.000000
     Priority=10
     HudColor=(B=255,G=0,R=128)
     SmallViewOffset=(X=11.000000,Y=11.500000,Z=-4.000000)
     CenteredOffsetY=1.000000
     CenteredRoll=1000
     CenteredYaw=-1000
     CustomCrosshair=8
     CustomCrossHairColor=(G=0)
     CustomCrossHairScale=1.333000
     CustomCrossHairTextureName="Crosshairs.HUD.Crosshair_Cross2"
     InventoryGroup=4
     PickupClass=Class'XWeapons.ShockRiflePickup'
     PlayerViewOffset=(X=4.000000,Y=8.000000,Z=-2.000000)
     PlayerViewPivot=(Pitch=-1000)
     BobDamping=1.800000
     AttachmentClass=Class'XWeapons.ShockAttachment'
     IconMaterial=Texture'HUDContent.Generic.HUD'
     IconCoords=(X1=250,Y1=110,X2=330,Y2=145)
     ItemName="Shock Rifle"
     LightType=LT_Steady
     LightEffect=LE_NonIncidence
     LightHue=200
     LightSaturation=70
     LightBrightness=255.000000
     LightRadius=4.000000
     LightPeriod=3
     Mesh=SkeletalMesh'NewWeapons2004.ShockRifle'
     DrawScale=0.700000
     HighDetailOverlay=Combiner'UT2004Weapons.WeaponSpecMap2'
}
