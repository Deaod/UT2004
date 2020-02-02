class ONSMineLayerAltFire extends WeaponFire;

var ONSMineLayerTargetBeamEffect Beam;
var vector EffectOffset;
var ONSMineLayer Gun;
var float TraceRange;
var bool bDoHit;

function PostBeginPlay()
{
	Super.PostBeginPlay();

	Gun = ONSMineLayer(Weapon);
}

function DestroyEffects()
{
	if (Beam != None)
		Beam.Destroy();

	Super.DestroyEffects();
}

simulated function bool AllowFire()
{
	return true;
}

function ModeHoldFire()
{
	if (Weapon.Role == ROLE_Authority)
	{
		SetTimer(0.5, true);
		bDoHit = true;
	}
}

function PlayFiring() {}

function StopFiring()
{
	if (Weapon.Role == ROLE_Authority)
	{
		if (Beam != None)
			Beam.Cancel();

		SetTimer(0, false);
	}
}

function Timer()
{
	bDoHit = true;
}

simulated function ModeTick(float deltaTime)
{
	local vector HitLocation, HitNormal, StartTrace, EndTrace, X, Y, Z;
	local rotator Aim;
	local Actor Other;
	local int i;

	if (!bIsFiring)
		return;

       Weapon.GetViewAxes(X,Y,Z);

    // the to-hit trace always starts right in front of the eye
	StartTrace = Instigator.Location + Instigator.EyePosition() + X*Instigator.CollisionRadius;
	Aim = AdjustAim(StartTrace, AimError);
	X = Vector(Aim);
	EndTrace = StartTrace + TraceRange * X;

	Other = Weapon.Trace(HitLocation, HitNormal, EndTrace, StartTrace, false);
	if (Other == None || Other == Instigator)
		HitLocation = EndTrace;

	if (Beam == None)
	{
		if (Weapon.Role == ROLE_Authority)
			Beam = Weapon.spawn(class'ONSMineLayerTargetBeamEffect',,, Instigator.Location);
		else
			foreach Weapon.DynamicActors(class'ONSMineLayerTargetBeamEffect', Beam)
				break;
	}

	if (Beam != None)
		Beam.EndEffect = HitLocation;

	if (bDoHit)
		for (i = 0; i < Gun.Mines.Length; i++)
		{
			if (Gun.Mines[i] == None)
			{
				Gun.Mines.Remove(i, 1);
				i--;
			}
			else if (ONSMineProjectile(Gun.Mines[i]) != None)
				ONSMineProjectile(Gun.Mines[i]).SetScurryTarget(HitLocation);
		}
}

defaultproperties
{
     EffectOffset=(X=-5.000000,Y=15.000000,Z=20.000000)
     TraceRange=10000.000000
     bSplashDamage=True
     bRecommendSplashDamage=True
     bFireOnRelease=True
     FireRate=0.600000
     AmmoClass=Class'Onslaught.ONSMineAmmo'
     BotRefireRate=1.000000
     WarnTargetPct=0.100000
}
