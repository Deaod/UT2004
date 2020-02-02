class BallLauncher extends Weapon
    config(user)
    HideDropDown
	CacheExempt;

#EXEC OBJ LOAD FILE=InterfaceContent.utx

var() transient bool launchedBall;
var() transient Pawn PassTarget;
var() Sound PassAmbient;
var() Sound PassTargetLocked;
var() Sound PassTargetLost;
var() String PassTargetLockedForce;
var() String PassTargetLostForce;
var() float HealRate;
var transient float HealAccum;
var transient float SwitchTestTime;

var Actor AITarget;		// used by AI

#exec OBJ LOAD File=IndoorAmbience.uax

replication
{
    reliable if ( Role == ROLE_Authority )
        PassTarget;
}

simulated function OutOfAmmo()
{
}

function SynchronizeWeapon(Weapon ClientWeapon)
{
	if ( Instigator.PlayerReplicationInfo.HasFlag == None )
		return;
	if ( Instigator.Controller != None )
		Instigator.Controller.ClientSetWeapon(class);
}

simulated function DrawWeaponInfo(Canvas Canvas)
{
	NewDrawWeaponInfo(Canvas, 0);
}

simulated function NewDrawWeaponInfo(Canvas Canvas, float YPos)
{
    local xPlayer PC;

	PC = xPlayer(Instigator.Controller);
	if ( PC == None )
		return;

    if( PassTarget != None )
        PC.myHUD.SetTargeting( true, PassTarget.Location, 1.0 );

	PC.myHUD.DrawTargeting(Canvas);
    PC.myHUD.SetTargeting(false);
}

simulated function BringUp(optional Weapon PrevWeapon)
{
    Super.BringUp();

    if (Instigator.IsLocallyControlled() && !PrevWeapon.IsA('BallLauncher'))
        Instigator.PendingWeapon = PrevWeapon;

    // prevent shooting ball until button is released
    FireMode[0].bIsFiring = true;
    FireMode[0].bNowWaiting = true;
}

simulated function Weapon NextWeapon(Weapon CurrentChoice, Weapon CurrentWeapon)
{
	if ( CurrentWeapon == self )
		return Instigator.PendingWeapon;
	else
		return Super.NextWeapon(CurrentChoice,CurrentWeapon);
}

simulated function Weapon PrevWeapon(Weapon CurrentChoice, Weapon CurrentWeapon)
{
	if ( CurrentWeapon == self )
		return Instigator.PendingWeapon;
	else
		return Super.PrevWeapon(CurrentChoice,CurrentWeapon);
}

simulated function bool PutDown()
{
    if ( launchedBall || Instigator.PlayerReplicationInfo.HasFlag == None )
    {
        launchedBall = false;
        return Super.PutDown();
    }
	if ( Instigator.PendingWeapon == self )
		Instigator.PendingWeapon = None;
    return( false ); // Never let them put the weapon away.
}

function SetPassTarget( Pawn passTarg )
{
    if ( (PassTarget != None) && (PassTarget != PassTarg) && (PlayerController(PassTarget.Controller) != None) )
		PlayerController(PassTarget.Controller).ClientPlaySound(PassTargetLost);	
    PassTarget = passTarg;
    if ( PassTarget == None )
		Level.Game.GameReplicationInfo.FlagTarget = None;
    else
		Level.Game.GameReplicationInfo.FlagTarget = PassTarget.PlayerReplicationInfo;
    if ( PlayerController(Instigator.Controller) != None )
    {
        if ( passTarg != None )
            PlayerController(Instigator.Controller).ClientPlaySound(PassTargetLocked);
        else
            PlayerController(Instigator.Controller).ClientPlaySound(PassTargetLost);
    }
    if ( (PassTarget != None) && (PlayerController(PassTarget.Controller) != None) )
		PlayerController(PassTarget.Controller).ClientPlaySound(PassTargetLocked);	
}

function ModifyPawn( float dt )
{
    if ( Instigator.Weapon == self && Instigator.PlayerReplicationInfo.HasFlag != None)
    {
	    if ( Instigator.Health < Instigator.HealthMax )
	    {
            HealAccum += HealRate * dt;
            if( HealAccum > 1 )
            {
                Instigator.Health = Min(Instigator.HealthMax, Instigator.Health + HealAccum);
                HealAccum -= int(HealAccum);
            }
	    }
    }

    if ( Instigator.Weapon != self && Instigator.PlayerReplicationInfo.HasFlag != None)
    {
        xBombFlag(Instigator.PlayerReplicationInfo.HasFlag).SetHolder( Instigator.Controller );
    }
}

simulated function Tick(float dt)
{
    if ( (Level.NetMode == NM_Client) || Instigator == None || Instigator.PlayerReplicationInfo == None)
        return;

	if ( Instigator.PlayerReplicationInfo.HasFlag == None )
	{
		if ( Level.TimeSeconds - SwitchTestTime > 0.8 )
		{
			if ( (Instigator.Weapon == self) && ((Instigator.PendingWeapon == None) || (Instigator.PendingWeapon == self)) )
				Instigator.Controller.ClientSwitchToBestWeapon();
			SwitchTestTime = Level.TimeSeconds;
		}

		if ( Instigator.AmbientSound == PassAmbient )
			AmbientSound = None;
		return;
    }

    // safeguard - to be absoulutly certain the ball launcher is up when player has the ball and not up otherwise
    if (Level.TimeSeconds - SwitchTestTime > 0.5)
    {
        if ( (Instigator.Weapon != self) && (Instigator.PendingWeapon != self) )
        {
			if ( PassTarget != None )
				SetPassTarget(None);
            Instigator.Controller.ClientSetWeapon(class'BallLauncher');
        }
        else if ( (PassTarget != None) && ((Passtarget.Controller == None) || (VSize(PassTarget.Location - Instigator.Location) > 6000)) )
			SetPassTarget(None);
        SwitchTestTime = Level.TimeSeconds;
    }

	ModifyPawn(dt);
 }

// todo: disallow switching away from this while this weapon is coming is up!!
simulated function bool StartFire( int modeNum )
{
	local bool bResult;

	bResult = Super.StartFire(modeNum);

	if ( bResult )
	{
		if ( modeNum == 0 )
		{
			launchedBall = true;
			ClientPlayForceFeedback(PassTargetLockedForce);
		}
		else
			ClientPlayForceFeedback(PassTargetLostForce);
	}
	return bResult;
}

simulated function bool HasAmmo()
{
	if ( xBombFlag(Instigator.PlayerReplicationInfo.HasFlag) != None )
		return true;
    return( false ); // Never let them change to this weapon for fun.
}

simulated function Weapon RecommendWeapon( out float rating )
{
    local Weapon Recommended;
    local float oldRating;

	if ( xBombFlag(Instigator.PlayerReplicationInfo.HasFlag) != None )
	{
		rating = 10000000;
		return self;
	}

    if ( inventory != None )
    {
        Recommended = inventory.RecommendWeapon(oldRating);
        if ( Recommended != None )
        {
            rating = oldRating;
            return Recommended;
        }
    }
    // Never return the ball launcher if no bomb!
    return None;
}

function bool CanAttack(Actor Other)
{
	return true;
}

function SetAITarget(Actor T)
{
	AITarget = T;
}

function bool BotFire(bool bFinished, optional name FiringMode)
{
	local xBombFlag Bomb;
	local vector ShootLoc;
	local Bot B;

    Bomb = xBombFlag( Instigator.PlayerReplicationInfo.HasFlag );
	B = Bot(Instigator.Controller);
	if ( !B.bPlannedShot || (Bomb == None) || (AITarget == None) )
	{
		B.bPlannedShot = false;
		return false;
	}

	// find correct initial velocity
	ShootLoc = AITarget.Location;
    Bomb.PassTarget = None;
	if ( Pawn(AITarget) != None )
	{
		ShootLoc = ShootLoc + 0.5 * (VSize(ShootLoc - Bomb.Location)/Bomb.ThrowSpeed) * Pawn(AITarget).Velocity;
		Bomb.PassTarget = Pawn(AITarget);
	}
	else if ( (GameObjective(AITarget) == None) && (AITarget.Location.Z <= Bomb.Location.Z) )
		ShootLoc = ShootLoc - AITarget.CollisionHeight * vect(0,0,1);

	return ShootHoop(B,ShootLoc);
}

function bool ShootHoop(Controller B, Vector ShootLoc)
{
	local xBombFlag Bomb;

    Bomb = xBombFlag( Instigator.PlayerReplicationInfo.HasFlag );

	// shoot hoop
    FireMode[0].PlayFiring();
    FireMode[0].FlashMuzzleFlash();
    FireMode[0].StartMuzzleSmoke();
    IncrementFlashCount(0);
    launchedBall = true;

    Bomb.Throw(Instigator.Location, B.AdjustToss(Bomb.ThrowSpeed, Bomb.Location, ShootLoc,true) ); //fixme experiment with bNormalize==false
	if ( Bot(B) != None )
		Bot(B).bPlannedShot = false;
	AITarget = None;
	return true;
}

defaultproperties
{
     PassAmbient=Sound'IndoorAmbience.machinery36'
     PassTargetLocked=Sound'WeaponSounds.BaseGunTech.BLockOn1'
     PassTargetLost=Sound'WeaponSounds.BaseGunTech.BSeekLost1'
     PassTargetLockedForce="LockOn"
     PassTargetLostForce="SeekLost"
     HealRate=5.000000
     FireModeClass(0)=Class'XWeapons.BallShoot'
     FireModeClass(1)=Class'XWeapons.BallTarget'
     PutDownAnim="PutDown"
     PutDownAnimRate=2.500000
     PutDownTime=0.200000
     SelectSound=Sound'WeaponSounds.Misc.ballgun_change'
     SelectForce="ballgun_change"
     AIRating=0.100000
     CurrentRating=0.100000
     bCanThrow=False
     bForceSwitch=True
     bNoVoluntarySwitch=True
     bNoInstagibReplace=True
     EffectOffset=(X=30.000000,Y=10.000000,Z=-10.000000)
     DisplayFOV=60.000000
     Priority=17
     SmallViewOffset=(X=23.000000,Y=6.000000,Z=-6.000000)
     CenteredOffsetY=-5.000000
     CenteredRoll=5000
     CenteredYaw=-300
     CustomCrosshair=11
     CustomCrossHairColor=(B=0)
     CustomCrossHairTextureName="Crosshairs.Hud.Crosshair_Bracket2"
     MinReloadPct=0.000000
     InventoryGroup=15
     PlayerViewOffset=(X=11.000000)
     BobDamping=2.200000
     AttachmentClass=Class'XWeapons.BallAttachment'
     ItemName="Ball Launcher"
     Mesh=SkeletalMesh'Weapons.BallLauncher_1st'
     DrawScale=0.400000
}
