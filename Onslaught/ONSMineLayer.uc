//-----------------------------------------------------------
//
//-----------------------------------------------------------
class ONSMineLayer extends Weapon
	config(User);

#exec OBJ LOAD FILE=HudContent.utx

const NUM_BARRELS = 4;
const BARREL_ROTATION_RATE = 2.0;

var()   float   ReloadDelay;
var     float   BarrelRotation;
var     float   FinalRotation;
var     bool    bRotateBarrel;

var array<Projectile> Mines;
var int CurrentMines, MaxMines;
var color FadedColor;

replication
{
	reliable if (bNetOwner && bNetDirty && Role == ROLE_Authority)
		CurrentMines;
}

simulated function DrawWeaponInfo(Canvas Canvas)
{
	NewDrawWeaponInfo(Canvas, 0.705*Canvas.ClipY);
}

simulated function NewDrawWeaponInfo(Canvas Canvas, float YPos)
{
	local int i, Half;
	local float ScaleFactor;

	ScaleFactor = 99 * Canvas.ClipX/3200;
	Half = (MaxMines + 1) / 2;
	Canvas.Style = ERenderStyle.STY_Alpha;
	Canvas.DrawColor = class'HUD'.Default.WhiteColor;
	for (i = 0; i < Half; i++)
	{
		if (i >= CurrentMines)
			Canvas.DrawColor = FadedColor;
		Canvas.SetPos(Canvas.ClipX - (i+1) * ScaleFactor * 1.25, YPos);
		Canvas.DrawTile(Material'HudContent.Generic.HUD', ScaleFactor, ScaleFactor, 391, 383, 44, 49);
	}
	for (i = Half; i < MaxMines; i++)
	{
		if (i >= CurrentMines)
			Canvas.DrawColor = FadedColor;
		Canvas.SetPos(Canvas.ClipX - (i-Half+1) * ScaleFactor * 1.25, YPos - ScaleFactor);
		Canvas.DrawTile(Material'HudContent.Generic.HUD', ScaleFactor, ScaleFactor, 391, 383, 44, 49);
	}
}

simulated function bool HasAmmo()
{
    if (CurrentMines > 0)
    	return true;

    return (FireMode[0] != None && AmmoAmount(0) >= FireMode[0].AmmoPerFire);
}

simulated function bool CanThrow()
{
	if ( AmmoAmount(0) <= 0 )
		return false;

	return Super.CanThrow();
}

simulated function Destroyed()
{
	local int x;

	if (Role == ROLE_Authority)
		for (x = 0; x < Mines.Length; x++)
			if (Mines[x] != None)
				Mines[x].Explode(Mines[x].Location, vect(0,0,1));

	Super.Destroyed();
}

// AI Interface
function float GetAIRating()
{
	local Bot B;
	local float EnemyDist;
	local vector EnemyDir;

	if ( AmmoAmount(0) <= 0 )
		return 0;

	B = Bot(Instigator.Controller);
	if (B == None)
		return AIRating;
	if (B.Enemy == None)
	{
		if (B.Formation() && B.Squad.SquadObjective != None && B.Squad.SquadObjective.BotNearObjective(B))
		{
			if ( DestroyableObjective(B.Squad.SquadObjective) != None && B.Squad.SquadObjective.TeamLink(B.Squad.Team.TeamIndex)
			     && DestroyableObjective(B.Squad.SquadObjective).Health < DestroyableObjective(B.Squad.SquadObjective).DamageCapacity )
				return 1.1; //hackish - don't want higher priority than anything that can heal objective

			return 1.5;
		}

		return AIRating;
	}

	// if retreating, favor this weapon
	EnemyDir = B.Enemy.Location - Instigator.Location;
	EnemyDist = VSize(EnemyDir);
	if ( EnemyDist > 1500 )
		return 0.1;
	if ( B.IsRetreating() )
		return (AIRating + 0.4);
	if ( -1 * EnemyDir.Z > EnemyDist )
		return AIRating + 0.1;
	if ( (B.Enemy.Weapon != None) && B.Enemy.Weapon.bMeleeWeapon )
		return (AIRating + 0.3);
	if ( EnemyDist > 1000 )
		return 0.35;
	return AIRating;
}

/* BestMode()
choose between regular or alt-fire
*/
function byte BestMode()
{
	local AIController C;

	C = AIController(Instigator.Controller);
	if (C == None || C.Enemy == None)
		return 0;

	if (CurrentMines < 2 || VSize(C.Enemy.Location - Instigator.Location) < 2500 || FRand() < 0.5)
		return 0;

	return 1;
}

function float SuggestAttackStyle()
{
	local Bot B;
	local float EnemyDist;

	B = Bot(Instigator.Controller);
	if ( (B == None) || (B.Enemy == None) )
		return 0.4;

	EnemyDist = VSize(B.Enemy.Location - Instigator.Location);
	if ( EnemyDist > 1500 )
		return 1.0;
	if ( EnemyDist > 1000 )
		return 0.4;
	return -0.4;
}

function float SuggestDefenseStyle()
{
	local Bot B;

	B = Bot(Instigator.Controller);
	if ( (B == None) || (B.Enemy == None) )
		return 0;

	if ( VSize(B.Enemy.Location - Instigator.Location) < 1600 )
		return -0.6;
	return 0;
}

function bool ShouldFireWithoutTarget()
{
	local ONSPowerCore OPC;
	if ( ShootTarget(Instigator.Controller.Target) != None )
	{
		OPC = ONSPowerCore(Instigator.Controller.Target.Owner);
		if ( (OPC != None) && !OPC.Shield.bHidden )
		{
			Instigator.Controller.Target = OPC.PathList[Rand(OPC.PathList.Length)].End;
			return ( Instigator.Controller.Target != None );
		}
	}
	if (CurrentMines < MaxMines)
		return true;

	return false;
}

// End AI Interface

simulated function PlayFiring(bool plunge)
{
    GotoState('AnimateLoad', 'Begin');
}

simulated function RotateBarrel()
{
    FinalRotation -= 65535.0 / NUM_BARRELS;
    if (FinalRotation <= 0.0)
    {
        FinalRotation += 65535.0;
        BarrelRotation += 65535.0;
    }
    bRotateBarrel = True;
}

simulated function UpdateBarrel(float dt)
{
    local Rotator R;

    BarrelRotation -= dt * 65535.0 * BARREL_ROTATION_RATE / NUM_BARRELS;
    if (BarrelRotation < FinalRotation)
    {
        BarrelRotation = FinalRotation;
        bRotateBarrel = False;
        GotoState('');
    }

    R.Roll = BarrelRotation;
    SetBoneRotation('drum', R, 0, 1);
}

simulated state AnimateLoad
{
    simulated function Tick(float dt)
    {
        if (bRotateBarrel)
            UpdateBarrel(dt);
    }

Begin:
    sleep(ReloadDelay);
    RotateBarrel();
    PlaySound(sound'PickupSounds.FlakAmmoPickup', SLOT_Misc);
    ClientPlayForceFeedback("FlakAmmoPickup");
}

defaultproperties
{
     ReloadDelay=0.400000
     MaxMines=8
     FadedColor=(B=128,G=128,R=128,A=160)
     FireModeClass(0)=Class'Onslaught.ONSMineThrowFire'
     FireModeClass(1)=Class'Onslaught.ONSMineLayerAltFire'
     PutDownAnim="PutDown"
     SelectAnimRate=2.000000
     PutDownAnimRate=4.000000
     PutDownTime=0.400000
     BringUpTime=0.350000
     SelectSound=Sound'WeaponSounds.FlakCannon.SwitchToFlakCannon'
     SelectForce="SwitchToFlakCannon"
     AIRating=0.550000
     CurrentRating=0.550000
     Description="The Spider Mine Layer is used for deploying spider mines, autonomous mobile mines that are highly effective against both foot soldiers and vehicles."
     EffectOffset=(X=100.000000,Y=32.000000,Z=-20.000000)
     DisplayFOV=45.000000
     Priority=7
     HudColor=(B=255,G=0,R=0)
     SmallViewOffset=(X=116.000000,Y=43.500000,Z=-40.500000)
     CustomCrosshair=4
     CustomCrossHairTextureName="ONSInterface-TX.MineLayerReticle"
     InventoryGroup=3
     GroupOffset=1
     PickupClass=Class'Onslaught.ONSMineLayerPickup'
     PlayerViewOffset=(X=100.000000,Y=35.500000,Z=-32.500000)
     BobDamping=2.200000
     AttachmentClass=Class'Onslaught.ONSMineLayerAttachment'
     IconMaterial=Texture'HUDContent.Generic.HUD'
     IconCoords=(X1=229,Y1=258,X2=296,Y2=307)
     ItemName="Mine Layer"
     Mesh=SkeletalMesh'ONSWeapons-A.MineLayer_1st'
     AmbientGlow=64
}
