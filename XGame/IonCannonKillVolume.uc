//if a pawn of a certain class stays within this volume for too long, an ion cannon from space blows it away
class IonCannonKillVolume extends PhysicsVolume;

var() class<Pawn> TargetClass;
var() bool bAffectsFlyingPawns; //does this volume kill pawns that can fly?
var() int CountdownTime; //how long pawn has to get out
var() class<IonEffect> IonEffectClass;
var array<Pawn> Targets;
var int TimeRemaining;

event PawnEnteredVolume(Pawn Other)
{
	Super.PawnEnteredVolume(Other);

	if (Other != None && (Other.Controller != None) && ClassIsChildOf(Other.Class, TargetClass) && (!Other.bCanFly || bAffectsFlyingPawns))
	{
		Targets[Targets.length] = Other;
		if (PainTimer == None)
		{
			TimeRemaining = CountdownTime;
			PainTimer = spawn(class'VolumeTimer', self);
		}
		else
			TimeRemaining = Min(CountdownTime, Max(3, TimeRemaining));
		if (PlayerController(Other.Controller) != None)
			PlayerController(Other.Controller).ReceiveLocalizedMessage(MessageClass, 0);
	}
}

event PawnLeavingVolume(Pawn Other)
{
	Super.PawnLeavingVolume(Other);

	RemoveTarget(Other);
}

function RemoveTarget(Pawn Other)
{
	local int i;

	for (i = 0; i < Targets.length; i++)
		if (Targets[i] == None || Targets[i] == Other)
		{
			Targets.Remove(i, 1);
			i--;
		}

	if (Targets.length == 0 && PainTimer != None)
		PainTimer.Destroy();
}

function TimerPop(VolumeTimer T)
{
	local Actor A;
	local Pawn P;
	local bool bFound;

	if (T != PainTimer)
		return;

	foreach TouchingActors(TargetClass, A)
	{
		P = Pawn(A);
		if (P.Controller == None || (P.bCanFly && !bAffectsFlyingPawns))
		{
			RemoveTarget(P);
			continue;
		}

		if (TimeRemaining > 1)
		{
			if (PlayerController(P.Controller) != None)
			{
				PlayerController(P.Controller).ReceiveLocalizedMessage(MessageClass, 0);
				PlayerController(P.Controller).ReceiveLocalizedMessage(MessageClass, TimeRemaining - 1);
			}
		}
		else if (TimeRemaining == 1)
			SpawnEffects(P.Location);
		else if (TimeRemaining < 1)
			P.Died(None, class'DamTypeIonVolume', P.Location);
		bFound = true;
	}

	if (TimeRemaining == 0)
		PlayGlobalSound(sound'WeaponSounds.redeemer_explosionsound');
	else if (TimeRemaining == 1 && bFound)
		PlayGlobalSound(sound'WeaponSounds.TAGRifle.IonCannonBlast');

	if (bFound || TimeRemaining <= 1)
		TimeRemaining--;
}

function SpawnEffects(vector EffectLoc)
{
	local IonEffect IonBeamEffect;
	local Actor Other;
	local Vector HitLocation, HitNormal, Top, CP;

	Other = Trace(HitLocation, HitNormal, EffectLoc + vect(0,0,10000), EffectLoc, false);

	Top = EffectLoc;
	Top.Z = FMax(HitLocation.Z, EffectLoc.Z + 2000);

	IonBeamEffect = Spawn(IonEffectClass,,, Top);
	if (IonBeamEffect != None)
	    IonBeamEffect.AimAt(EffectLoc, Vect(0,0,1));

	CP = vect(1500,0,0);

	Other = Trace(HitLocation, HitNormal, Top + CP, EffectLoc, false);
	if ( Other == None )
	{
		IonBeamEffect = Spawn(IonEffectClass,,, Top + CP);
		if (IonBeamEffect != None)
			IonBeamEffect.AimAt(EffectLoc, Vect(0,0,1));
	}

	Other = Trace(HitLocation, HitNormal, Top - CP, EffectLoc, false);
	if ( Other == None )
	{
		IonBeamEffect = Spawn(IonEffectClass,,, Top - CP);
		if (IonBeamEffect != None)
			IonBeamEffect.AimAt(EffectLoc, Vect(0,0,1));
	}
}

function PlayGlobalSound(sound S)
{
	local Controller C;

	for (C = Level.ControllerList; C != None; C = C.NextController)
		if (PlayerController(C) != None)
			PlayerController(C).ClientPlaySound(S);
}

defaultproperties
{
     TargetClass=Class'Engine.Pawn'
     CountdownTime=10
     IonEffectClass=Class'XEffects.IonEffect'
     TransientSoundVolume=1.000000
     TransientSoundRadius=2000.000000
     MessageClass=Class'XGame.IonCannonKillWarning'
}
