// AVRiL alternate fire. Slight zoom and auto-tracking of target
class ONSAVRiLAltFire extends WeaponFire;

var ONSAVRiL Gun;
var float ZoomLevel;
var bool bWaitingForRelease;
var bool bLosingLock;
var float LostLockTime;

function PostBeginPlay()
{
	Super.PostBeginPlay();

	Gun = ONSAVRiL(Weapon);
}

simulated function bool AllowFire()
{
	//return (Gun != None && Gun.bLockedOn && PlayerController(Instigator.Controller) != None);
	if (bWaitingForRelease || Gun == None || !Gun.bLockedOn || PlayerController(Instigator.Controller) == None)
	{
		bWaitingForRelease = true;
		return false;
	}
	else
		return true;

}

function StopFiring()
{
	if (PlayerController(Instigator.Controller) != None)
	{
		ZoomLevel = 0.0;
		PlayerController(Instigator.Controller).DesiredFOV = PlayerController(Instigator.Controller).DefaultFOV;
		bLosingLock = false;
	}
}

function PlayFiring() {}

function ModeTick(float deltaTime)
{
    local vector LockTrace;
    local Actor AlternateTarget;

	//Hack - force player to actually press button to start fire (so can't hold down button and sweep crosshair in the vicinity of targets)
	if (bWaitingForRelease && PlayerController(Instigator.Controller).bAltFire == 0)
		bWaitingForRelease = false;

	if (!bIsFiring)
		return;

	if (!Gun.bLockedOn || Gun.HomingTarget == None)
	{
		if (!bLosingLock)
		{
			bLosingLock = true;
			LostLockTime = Level.TimeSeconds;
			if (Instigator.IsLocallyControlled())
				Instigator.PlaySound(Sound'WeaponSounds.BSeekLost1');
		}
		else if (Level.TimeSeconds > LostLockTime + 1.5)
		{
			Gun.StopFire(1);
			return;
		}
	}
	else if (bLosingLock)
		bLosingLock = false;

	//Custom zooming because we don't want quite as much as normal sniper zoom does
	ZoomLevel += deltaTime;
	if (ZoomLevel > 0.60)
		ZoomLevel = 0.60;
	PlayerController(Instigator.Controller).DesiredFOV = FClamp(90.0 - (ZoomLevel * 88.0), 1, 170);

	if (!bLosingLock && Instigator.IsLocallyControlled())
	{
        // Are we aimed at the HomingTarget or an AlternateTarget...
        AlternateTarget = Gun.HomingTarget.AlternateTarget();
        if (AlternateTarget != None)
        {
            LockTrace = AlternateTarget.Location - (Instigator.Location + Instigator.EyePosition());

            if ((Normal(LockTrace) dot Vector(Instigator.GetViewRotation())) > Gun.LockAim && VSize(LockTrace) < Gun.MaxLockRange)
            {
                Instigator.Controller.SetRotation(rotator(AlternateTarget.Location - Instigator.Location));
                return;
            }
        }
        Instigator.Controller.SetRotation(rotator(Gun.HomingTarget.Location - Instigator.Location));
    }
}

defaultproperties
{
     bModeExclusive=False
     FireRate=0.100000
}
