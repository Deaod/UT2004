//=============================================================================
// RocketLaucher
//=============================================================================
class RocketLauncher extends Weapon
    config(user);

#EXEC OBJ LOAD FILE=InterfaceContent.utx

const NUM_BARRELS = 3;
const BARREL_ROTATION_RATE = 2.95;

var float BarrelRotation;
var float FinalRotation;
var bool bRotateBarrel;

var Pawn SeekTarget;
var float LockTime, UnLockTime, SeekCheckTime;
var bool bLockedOn, bBreakLock;
var bool bTightSpread;
var() float SeekCheckFreq, SeekRange;
var() float LockRequiredTime, UnLockRequiredTime;
var() float LockAim;
var() Color CrosshairColor;
var() float CrosshairX, CrosshairY;

replication
{
    reliable if (Role == ROLE_Authority && bNetOwner)
        bLockedOn;

    reliable if (Role < ROLE_Authority)
        ServerSetTightSpread, ServerClearTightSpread;
}

function Tick(float dt)
{
    local Pawn Other;
    local Vector StartTrace;
    local Rotator Aim;
    local float BestDist, BestAim;

    if (Instigator == None || Instigator.Weapon != self)
        return;

	if ( Role < ROLE_Authority )
		return;

    if ( !Instigator.IsHumanControlled() )
        return;

    if (Level.TimeSeconds > SeekCheckTime)
    {
        if (bBreakLock)
        {
            bBreakLock = false;
            bLockedOn = false;
            SeekTarget = None;
        }

        StartTrace = Instigator.Location + Instigator.EyePosition();
        Aim = Instigator.GetViewRotation();

        BestAim = LockAim;
        Other = Instigator.Controller.PickTarget(BestAim, BestDist, Vector(Aim), StartTrace, SeekRange);

        if ( CanLockOnTo(Other) )
        {
            if (Other == SeekTarget)
            {
                LockTime += SeekCheckFreq;
                if (!bLockedOn && LockTime >= LockRequiredTime)
                {
                    bLockedOn = true;
                    PlayerController(Instigator.Controller).ClientPlaySound(Sound'WeaponSounds.LockOn');
                 }
            }
            else
            {
                SeekTarget = Other;
                LockTime = 0.0;
            }
            UnLockTime = 0.0;
        }
        else
        {
            if (SeekTarget != None)
            {
                UnLockTime += SeekCheckFreq;
                if (UnLockTime >= UnLockRequiredTime)
                {
                    SeekTarget = None;
                    if (bLockedOn)
                    {
                        bLockedOn = false;
                        PlayerController(Instigator.Controller).ClientPlaySound(Sound'WeaponSounds.SeekLost');
                    }
                }
            }
            else
                 bLockedOn = false;
         }

        SeekCheckTime = Level.TimeSeconds + SeekCheckFreq;
    }
}

function bool CanLockOnTo(Actor Other)
{
    local Pawn P;
    
    P = Pawn(Other);

    if (P == None || P == Instigator || !P.bProjTarget)
        return false;

    if (!Level.Game.bTeamGame)
        return true;

	if ( (Instigator.Controller != None) && Instigator.Controller.SameTeamAs(P.Controller) )
		return false;
		
    return ( (P.PlayerReplicationInfo == None) || (P.PlayerReplicationInfo.Team != Instigator.PlayerReplicationInfo.Team) );
}

simulated event RenderOverlays( Canvas Canvas )
{
    if (bLockedOn)
    {
        Canvas.DrawColor = CrosshairColor;
        Canvas.DrawColor.A = 255;
        Canvas.Style = ERenderStyle.STY_Alpha;

        Canvas.SetPos(Canvas.SizeX*0.5-CrosshairX, Canvas.SizeY*0.5-CrosshairY);
        Canvas.DrawTile(Texture'SniperArrows', CrosshairX*2.0, CrosshairY*2.0, 0.0, 0.0, Texture'SniperArrows'.USize, Texture'SniperArrows'.VSize);
    }

    Super.RenderOverlays(Canvas);
}

function Projectile SpawnProjectile(Vector Start, Rotator Dir)
{
    local RocketProj Rocket;
    local SeekingRocketProj SeekingRocket;
	local bot B;

    bBreakLock = true;

	// decide if bot should be locked on
	B = Bot(Instigator.Controller);
	if ( (B != None) && (B.Skill > 2 + 5 * FRand()) && (FRand() < 0.6) && (B.Target != None)
		&& (B.Target == B.Enemy) && (VSize(B.Enemy.Location - B.Pawn.Location) > 2000 + 2000 * FRand())
		&& (Level.TimeSeconds - B.LastSeenTime < 0.4) && (Level.TimeSeconds - B.AcquireTime > 1.5) )
	{
		bLockedOn = true;
		SeekTarget = B.Enemy;
	}

    if (bLockedOn && SeekTarget != None)
    {
        SeekingRocket = Spawn(class'SeekingRocketProj',,, Start, Dir);
        SeekingRocket.Seeking = SeekTarget;
        if ( B != None )
        {
			//log("LOCKED");
			bLockedOn = false;
			SeekTarget = None;
		}
        return SeekingRocket;
    }
    else
    {
        Rocket = Spawn(class'RocketProj',,, Start, Dir);
        return Rocket;
    }
}

simulated function PlayIdle()
{
    LoopAnim(IdleAnim, IdleAnimRate, 0.25);
}

simulated function PlayFiring(bool plunge)
{
    if (plunge)
    {
        GotoState('AnimateLoad', 'Begin');
    }
}

simulated function PlayLoad(bool full)
{
    if (!full)
    {
        GotoState('AnimateLoad', 'Begin');
    }
}

simulated function AnimEnd(int Channel)
{
    if ( (Channel == 0) && (ClientState == WS_ReadyToFire) )
    {
        PlayIdle();
		if ( (Role < ROLE_Authority) && !HasAmmo() )
			DoAutoSwitch(); //FIXME HACK
	}
}

simulated function RotateBarrel()
{
    FinalRotation += 65535.0 / NUM_BARRELS;
    if (FinalRotation >= 65535.0)
    {
        FinalRotation -= 65535.0;
        BarrelRotation -= 65535.0;
    }
    bRotateBarrel = true;
}

simulated function UpdateBarrel(float dt)
{
    local Rotator R;

    BarrelRotation += dt * 65535.0 * BARREL_ROTATION_RATE / NUM_BARRELS;
    if (BarrelRotation > FinalRotation)
    {
        BarrelRotation = FinalRotation;
        bRotateBarrel = false;
    }

    R.Roll = BarrelRotation;
    SetBoneRotation('Bone_Barrel', R, 0, 1);
}

simulated function Plunge()
{
    PlayAnim('load', 0.8, 0.0, 1);
    PlayAnim('load', 0.8, 0.0, 2);
}

simulated event ClientStartFire(int Mode)
{
	local int OtherMode;

	if ( RocketMultiFire(FireMode[Mode]) != None )
	{
		SetTightSpread(false);
	}
    else
    {
		if ( Mode == 0 )
			OtherMode = 1;
		else
			OtherMode = 0;

		if ( FireMode[OtherMode].bIsFiring || (FireMode[OtherMode].NextFireTime > Level.TimeSeconds) )
		{
			if ( FireMode[OtherMode].Load > 0 )
				SetTightSpread(true);
			if ( bDebugging )
				log("No RL reg fire because other firing "$FireMode[OtherMode].bIsFiring$" next fire "$(FireMode[OtherMode].NextFireTime - Level.TimeSeconds));
			return;
		}
	}
    Super.ClientStartFire(Mode);
}

simulated function bool StartFire(int Mode)
{
	local int OtherMode;

	if ( Mode == 0 )
		OtherMode = 1;
	else
		OtherMode = 0;
	if ( FireMode[OtherMode].bIsFiring || (FireMode[OtherMode].NextFireTime > Level.TimeSeconds) )
		return false;

	return Super.StartFire(Mode);
}

simulated function SetTightSpread(bool bNew, optional bool bForce)
{
	if ( (bTightSpread != bNew) || bForce )
	{
		bTightSpread = bNew;
		if ( bTightSpread )
			ServerSetTightSpread();
		else
			ServerClearTightSpread();
	}
}

function ServerClearTightSpread()
{
	bTightSpread = false;
}

function ServerSetTightSpread()
{
	bTightSpread = true;
}

simulated function BringUp(optional Weapon PrevWeapon)
{
    SetTightSpread(false,true);
    if (Instigator.IsLocallyControlled())
    {
        AnimBlendParams( 1, 1.0, 0.0, 0.0, 'bone_shell' );
        AnimBlendParams( 2, 1.0, 0.0, 0.0, 'bone_feed' );
        SetBoneRotation('Bone_Barrel', Rot(0,0,0), 0, 1);
    }
    Super.BringUp(PrevWeapon);
}

simulated state AnimateLoad
{
    simulated function Tick(float dt)
    {
        if (bRotateBarrel)
            UpdateBarrel(dt);
    }

Begin:
    Sleep(0.15);
    RotateBarrel();
    Sleep(0.07);
    PlayOwnedSound(Sound'WeaponSounds.RocketLauncher.RocketLauncherLoad', SLOT_None,,,,,false);
    ClientPlayForceFeedback( "RocketLauncherLoad" );  // jdf
    Sleep(0.28);
    Plunge();
    PlayOwnedSound(Sound'WeaponSounds.RocketLauncher.RocketLauncherPlunger', SLOT_None,,,,,false);
    ClientPlayForceFeedback( "RocketLauncherPlunger" );  // jdf
    Sleep(0.29);
    GotoState('');
}

// AI Interface
function float SuggestAttackStyle()
{
	local float EnemyDist;

	// recommend backing off if target is too close
	EnemyDist = VSize(Instigator.Controller.Enemy.Location - Owner.Location);
	if ( EnemyDist < 750 )
	{
		if ( EnemyDist < 500 )
			return -1.5;
		else
			return -0.7;
	}
	else if ( EnemyDist > 1600 )
		return 0.5;
	else
		return -0.1;
}

// tell bot how valuable this weapon would be to use, based on the bot's combat situation
// also suggest whether to use regular or alternate fire mode
function float GetAIRating()
{
	local Bot B;
	local float EnemyDist, Rating, ZDiff;
	local vector EnemyDir;

	B = Bot(Instigator.Controller);
	if ( (B == None) || (B.Enemy == None) )
		return AIRating;

	// if standing on a lift, make sure not about to go around a corner and lose sight of target
	// (don't want to blow up a rocket in bot's face)
	if ( (Instigator.Base != None) && (Instigator.Base.Velocity != vect(0,0,0))
		&& !B.CheckFutureSight(0.1) )
		return 0.1;

	EnemyDir = B.Enemy.Location - Instigator.Location;
	EnemyDist = VSize(EnemyDir);
	Rating = AIRating;

	// don't pick rocket launcher if enemy is too close
	if ( EnemyDist < 360 )
	{
		if ( Instigator.Weapon == self )
		{
			// don't switch away from rocket launcher unless really bad tactical situation
			if ( (EnemyDist > 250) || ((Instigator.Health < 50) && (Instigator.Health < B.Enemy.Health - 30)) )
				return Rating;
		}
		return 0.05 + EnemyDist * 0.001;
	}

	// rockets are good if higher than target, bad if lower than target
	ZDiff = Instigator.Location.Z - B.Enemy.Location.Z;
	if ( ZDiff > 120 )
		Rating += 0.25;
	else if ( ZDiff < -160 )
		Rating -= 0.35;
	else if ( ZDiff < -80 )
		Rating -= 0.05;
	if ( (B.Enemy.Weapon != None) && B.Enemy.Weapon.bMeleeWeapon && (EnemyDist < 2500) )
		Rating += 0.25;

	return Rating;
}

/* BestMode()
choose between regular or alt-fire
*/
function byte BestMode()
{
	local bot B;

	B = Bot(Instigator.Controller);
	if ( (B == None) || (B.Enemy == None) )
		return 0;

	if ( (FRand() < 0.3) && !B.IsStrafing() && (Instigator.Physics != PHYS_Falling) )
		return 1;
	return 0;
}
// end AI Interface

defaultproperties
{
     SeekCheckFreq=0.500000
     SeekRange=8000.000000
     LockRequiredTime=1.250000
     UnLockRequiredTime=0.500000
     LockAim=0.996000
     CrossHairColor=(R=250,A=255)
     CrosshairX=16.000000
     CrosshairY=16.000000
     FireModeClass(0)=Class'XWeapons.RocketFire'
     FireModeClass(1)=Class'XWeapons.RocketMultiFire'
     SelectAnim="Pickup"
     PutDownAnim="PutDown"
     IdleAnimRate=0.500000
     SelectSound=Sound'WeaponSounds.RocketLauncher.SwitchToRocketLauncher'
     SelectForce="SwitchToRocketLauncher"
     AIRating=0.780000
     CurrentRating=0.780000
     Description="The Trident Tri-barrel Rocket Launcher is extremely popular among competitors who enjoy more bang for their buck.|The rotating rear loading barrel design allows for both single- and multi-warhead launches, letting you place up to three dumb fire rockets on target.|The warheads are designed to deliver maximum concussive force to the target and surrounding area upon detonation."
     EffectOffset=(X=50.000000,Y=1.000000,Z=10.000000)
     DisplayFOV=60.000000
     Priority=26
     HudColor=(G=0)
     SmallViewOffset=(X=12.000000,Y=14.000000,Z=-6.000000)
     CenteredOffsetY=-5.000000
     CenteredYaw=-500
     CustomCrosshair=15
     CustomCrossHairColor=(B=0,G=0)
     CustomCrossHairTextureName="Crosshairs.HUD.Crosshair_Triad2"
     InventoryGroup=8
     PickupClass=Class'XWeapons.RocketLauncherPickup'
     PlayerViewOffset=(Y=8.000000)
     PlayerViewPivot=(Yaw=500,Roll=1000)
     BobDamping=1.500000
     AttachmentClass=Class'XWeapons.RocketAttachment'
     IconMaterial=Texture'HUDContent.Generic.HUD'
     IconCoords=(X1=253,Y1=146,X2=333,Y2=181)
     ItemName="Rocket Launcher"
     Mesh=SkeletalMesh'Weapons.RocketLauncher_1st'
     HighDetailOverlay=Combiner'UT2004Weapons.WeaponSpecMap2'
}
