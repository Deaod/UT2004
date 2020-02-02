//=============================================================================
// Minigun
//=============================================================================
class Minigun extends Weapon
    config(user);

#EXEC OBJ LOAD FILE=InterfaceContent.utx

var     float           CurrentRoll;
var     float           RollSpeed;
//var     float           FireTime;
var() xEmitter          ShellCaseEmitter;
var() vector            AttachLoc;
var() rotator           AttachRot;
var   int               CurrentMode;
var() float             GearRatio;
var() float             GearOffset;
var() float             Blend;

simulated function PostBeginPlay()
{
    Super.PostBeginPlay();

    if ( Level.NetMode == NM_DedicatedServer )
        return;

    ShellCaseEmitter = spawn(class'ShellSpewer');
	if ( ShellCaseEmitter != None )
	{
		ShellCaseEmitter.Trigger(Self, Instigator); //turn off
		AttachToBone(ShellCaseEmitter, 'shell');
	}
}

function DropFrom(vector StartLocation)
{
	Super.DropFrom(StartLocation);
}

simulated function OutOfAmmo()
{
    if ( (Instigator == None) || !Instigator.IsLocallyControlled() || HasAmmo() )
        return;

	Instigator.AmbientSound = None;
	Instigator.SoundVolume = Instigator.default.SoundVolume;
    DoAutoSwitch();
}

simulated function Destroyed()
{
    if (ShellCaseEmitter != None)
    {
        ShellCaseEmitter.Destroy();
        ShellCaseEmitter = None;
    }

    Super.Destroyed();
}

/* BotFire()
called by NPC firing weapon. Weapon chooses appropriate firing Mode to use (typically no change)
bFinished should only be true if called from the Finished() function
FiringMode can be passed in to specify a firing Mode (used by scripted sequences)
*/
function bool BotFire(bool bFinished, optional name FiringMode)
{
    local int newmode;
    local Controller C;

    C = Instigator.Controller;
	newMode = BestMode();

	if ( newMode == 0 )
	{
		C.bFire = 1;
		C.bAltFire = 0;
	}
	else
	{
		C.bFire = 0;
		C.bAltFire = 1;
	}

	if ( bFinished )
		return true;

    if ( FireMode[BotMode].bIsFiring && (NewMode != BotMode) )
		StopFire(BotMode);

    if ( !ReadyToFire(newMode) || ClientState != WS_ReadyToFire )
		return false;

    BotMode = NewMode;
    StartFire(NewMode);
    return true;
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
			return 0.5;
		return AIRating;
	}
		
	if ( !B.EnemyVisible() )
		return AIRating - 0.15;

	return AIRating * FMin(Pawn(Owner).DamageScaling, 1.5);
}

/* BestMode()
choose between regular or alt-fire
*/
function byte BestMode()
{
	local float EnemyDist;
	local bot B;

	B = Bot(Instigator.Controller);
	if ( (B == None) || (B.Enemy == None) )
		return 0;

	if ( FireMode[0].bIsFiring )
		return 0;
	else if ( FireMode[1].bIsFiring )
		return 1;
	EnemyDist = VSize(B.Enemy.Location - Instigator.Location);
	if ( EnemyDist < 2000 )
		return 0;
	return 1;
}
// end AI Interface

simulated function SpawnShells(float amountPerSec)
{
    if(ShellCaseEmitter == None || !FirstPersonView())
        return;
	if ( Bot(Instigator.Controller) != None )
	{
		ShellCaseEmitter.Destroy();
		return;
	}

	ShellCaseEmitter.mRegenRange[0] = amountPerSec;
	ShellCaseEmitter.mRegenRange[1] = amountPerSec;
    ShellCaseEmitter.Trigger(self, Instigator);
}

simulated function bool FirstPersonView()
{
    return (Instigator.IsLocallyControlled() && (PlayerController(Instigator.Controller) != None) && !PlayerController(Instigator.Controller).bBehindView);
}

// Prevents wrong anims from playing
simulated function AnimEnd(int channel)
{
}

// Client-side only: update the first person barrel rotation
simulated function UpdateRoll(float dt, float speed, int mode)
{
    local rotator r;

    if (Level.NetMode == NM_DedicatedServer)
        return;

    if (mode == CurrentMode) // to limit to one mode
    {
       // log(self$" updateroll (mode="$mode$") speed="$speed);

        RollSpeed = speed;
        CurrentRoll += dt*RollSpeed;
        CurrentRoll = CurrentRoll % 65536.f;
        r.Roll = int(CurrentRoll);
        SetBoneRotation('Bone Barrels', r, 0, Blend);

        r.Roll = GearOffset + r.Roll*GearRatio;
        SetBoneRotation('Bone gear', r, 0, Blend);
    }
}

simulated function bool StartFire(int mode)
{
    local bool bStart;

	if ( !MinigunFire(FireMode[0]).IsIdle() || !MinigunFire(FireMode[1]).IsIdle() )
		return false;

    bStart = Super.StartFire(mode);
    if (bStart)
        FireMode[mode].StartFiring();

    return bStart;
}

// Allow fire modes to return to idle on weapon switch (server)
simulated function DetachFromPawn(Pawn P)
{
    //log(self$" detach from pawn p="$p);

    ReturnToIdle();

    Super.DetachFromPawn(P);
}

// Allow fire modes to return to idle on weapon switch (client)
simulated function bool PutDown()
{
   // log(self$" putdown");

    ReturnToIdle();

    return Super.PutDown();
}

simulated function ReturnToIdle()
{
    local int mode;

    for (mode=0; mode<NUM_FIRE_MODES; mode++)
    {
        if (FireMode[mode] != None)
        {
            FireMode[mode].GotoState('Idle');
        }
    }
}

defaultproperties
{
     AttachLoc=(X=-77.000000,Y=6.000000,Z=4.000000)
     AttachRot=(Pitch=22000,Yaw=-16384)
     GearRatio=-2.370000
     Blend=1.000000
     FireModeClass(0)=Class'XWeapons.MinigunFire'
     FireModeClass(1)=Class'XWeapons.MinigunAltFire'
     PutDownAnim="PutDown"
     SelectSound=Sound'WeaponSounds.Minigun.SwitchToMiniGun'
     SelectForce="SwitchToMiniGun"
     AIRating=0.710000
     CurrentRating=0.710000
     Description="The Schultz-Metzger T23-A 23mm rotary cannon is capable of firing both high-velocity caseless ammunition and cased rounds. With an unloaded weight of only 8 kilograms, the T23 is portable and maneuverable, easily worn across the back when employing the optional carrying strap.|The T23-A is the rotary cannon of choice for the discerning soldier."
     EffectOffset=(X=100.000000,Y=18.000000,Z=-16.000000)
     DisplayFOV=60.000000
     Priority=16
     HudColor=(B=255)
     SmallViewOffset=(X=8.000000,Y=1.000000,Z=-2.000000)
     CenteredOffsetY=-6.000000
     CenteredRoll=0
     CenteredYaw=-500
     CustomCrosshair=2
     CustomCrossHairTextureName="Crosshairs.HUD.Crosshair_Circle1"
     InventoryGroup=6
     PickupClass=Class'XWeapons.MinigunPickup'
     PlayerViewOffset=(X=2.000000,Y=-1.000000)
     PlayerViewPivot=(Yaw=500)
     BobDamping=2.250000
     AttachmentClass=Class'XWeapons.MinigunAttachment'
     IconMaterial=Texture'HUDContent.Generic.HUD'
     IconCoords=(X1=246,Y1=80,X2=332,Y2=106)
     ItemName="Minigun"
     LightType=LT_Pulse
     LightEffect=LE_NonIncidence
     LightHue=30
     LightSaturation=150
     LightBrightness=255.000000
     LightRadius=5.000000
     LightPeriod=3
     Mesh=SkeletalMesh'Weapons.Minigun_1st'
     DrawScale=0.400000
     SoundRadius=400.000000
     HighDetailOverlay=Combiner'UT2004Weapons.WeaponSpecMap2'
}
