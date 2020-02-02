class ONSAutoBomber extends Actor;

var vector BombTargetCenter;
var float Speed, MinSpeed, BombRange;
var class<Projectile> BombClass;
var int Health;
var byte Team;
var Controller DelayedDamageInstigatorController;
var bool bShotDown;

// Damage attributes.
var float Damage;
var float DamageRadius;
var float MomentumTransfer;
var class<DamageType> MyDamageType;

// camera shakes //
var() vector ShakeRotMag;           // how far to rot view
var() vector ShakeRotRate;          // how fast to rot view
var() float  ShakeRotTime;          // how much time to rot the instigator's view
var() vector ShakeOffsetMag;        // max view offset vertically
var() vector ShakeOffsetRate;       // how fast to offset view vertically
var() float  ShakeOffsetTime;       // how much time to offset view

var class<Emitter> DyingEffectClass;
var Emitter DyingEffect;

replication
{
	reliable if (bNetInitial && Role == ROLE_Authority)
		BombTargetCenter;
	reliable if (bNetDirty && Role == ROLE_Authority)
		bShotDown;
}

function Touch(Actor Other)
{
	if (Vehicle(Other) != None)
	{
		Vehicle(Other).TakeDamage(Vehicle(Other).Health, None, Other.Location, vect(0,0,0), class'DamTypeONSVehicle');
		TakeDamage(Health, Pawn(Other), Location, vect(0,0,0), class'DamTypeONSVehicle');
	}
}

function Bump(Actor Other)
{
	Touch(Other);
}

function SetDelayedDamageInstigatorController(Controller C)
{
	DelayedDamageInstigatorController = C;
}

function TakeDamage(int Damage, Pawn EventInstigator, vector HitLocation, vector Momentum, class<DamageType> DamageType)
{
	local Controller InstigatorController;

	if (EventInstigator != None)
		InstigatorController = EventInstigator.Controller;
	else
		InstigatorController = DelayedDamageInstigatorController;

	if (InstigatorController == None || InstigatorController.GetTeamNum() == Team)
		return;

	Health -= Damage;
	if (Health <= 0)
		GotoState('ShotDown');
}

simulated function PostBeginPlay()
{
	Super.PostBeginPlay();

	if (Role == ROLE_Authority && Instigator != None)
		Team = Instigator.GetTeamNum();

	if (Level.NetMode != NM_DedicatedServer)
	{
		spawn(class'ONSAutoBomberWarpEffect',,,, Rotation + rot(0,16384,0));
		Level.GetLocalPlayerController().PlayStatusAnnouncement('Incoming_air', 0, true);
	}
}

function Bomb(vector Target)
{
	BombTargetCenter = Target;
	SetRotation(rotator(Target - Location));
	Velocity = vector(Rotation) * ((VSize(Location - BombTargetCenter) - BombRange) / 100000 * Speed + MinSpeed);
	SetTimer(0.33, true);
}

simulated event HitWall(vector HitNormal, Actor HitWall)
{
	if (Level.NetMode != NM_DedicatedServer)
		spawn(class'ONSAutoBomberWarpEffect',,,, Rotation + rot(0,16384,0));
	Destroy();
}

function Timer()
{
	local Controller C;

	if (FRand() < 0.5)
	{
		//high skill enemies who don't have anything else to shoot at will try to shoot bomber down
		for (C = Level.ControllerList; C != None; C = C.NextController)
			if ( AIController(C) != None && C.Pawn != None && C.GetTeamNum() != Team && AIController(C).Skill >= 5.0
			     && !C.Pawn.IsFiring() && (C.Enemy == None || !C.LineOfSightTo(C.Enemy)) && C.Pawn.CanAttack(self) )
			{
				C.Focus = self;
				C.FireWeaponAt(self);
			}
	}

	if (VSize(Location - BombTargetCenter) < BombRange)
	{
		//drop a bomb
		spawn(BombClass,,, Location - ((CollisionHeight + BombClass.default.CollisionHeight) * vect(0,0,2)), rotator(vect(0,0,-1)));
		Velocity = Normal(Velocity) * MinSpeed;
		Acceleration = vect(0,0,0);
	}
}

simulated function Tick(float deltaTime)
{
	local float TargetDist;

	//start out really fast, slow down when near target
	TargetDist = VSize(Location - BombTargetCenter);
	if (TargetDist > BombRange)
		Velocity = vector(Rotation) * ((TargetDist - BombRange) / 100000 * Speed + MinSpeed);
}

simulated function PostNetReceive()
{
	if (bShotDown)
		GotoState('ShotDown');
}

simulated function Destroyed()
{
	if (DyingEffect != None)
		DyingEffect.Kill();
}

function bool IsStationary()
{
	return false;
}

state ShotDown
{
	simulated function BeginState()
	{
		bShotDown = true;
		bNetNotify = false;
		SetPhysics(PHYS_Falling);
		if (Level.NetMode != NM_DedicatedServer)
		{
			DyingEffect = spawn(DyingEffectClass, self);
			if (DyingEffect != None)
				DyingEffect.SetBase(self);
		}
	}

	simulated function HitWall(vector HitNormal, Actor HitWall)
	{
		Landed(HitNormal);
	}

	simulated function Landed(vector HitNormal)
	{
		GotoState('BlowingUp');
	}

	simulated function Tick(float deltaTime)
	{
		SetRotation(rotator(Velocity));
	}

	function Timer() {}
	function TakeDamage(int Damage, Pawn EventInstigator, vector HitLocation, vector Momentum, class<DamageType> DamageType) {}
}

state BlowingUp extends ShotDown
{
	simulated function Landed(vector HitNormal) {}

	simulated function BeginState()
	{
		local PlayerController PC;
		local float Dist, Scale;

		InitialState = 'BlowingUp';
		if (Level.NetMode != NM_DedicatedServer)
		{
			Spawn(class'RedeemerExplosion',,, Location - 100 * Normal(Velocity), Rot(0,16384,0));
			Spawn(class'IonCore',,, Location, Rotation);
		}
		MakeNoise(1.0);
		bHidden = true;
		SetPhysics(PHYS_None);
		SetCollision(false,false,false);

		//shakeview
		PC = Level.GetLocalPlayerController();
		if (PC != None && PC.ViewTarget != None)
		{
			Dist = VSize(Location - PC.ViewTarget.Location);
			if (Dist < DamageRadius * 2.0)
			{
				if (Dist < DamageRadius)
					Scale = 1.0;
				else
					Scale = (DamageRadius*2.0 - Dist) / (DamageRadius);
				PC.ShakeView(ShakeRotMag*Scale, ShakeRotRate, ShakeRotTime, ShakeOffsetMag*Scale, ShakeOffsetRate, ShakeOffsetTime);
			}
		}
	}

Begin:
    PlaySound(sound'WeaponSounds.redeemer_explosionsound');
    HurtRadius(Damage, DamageRadius*0.125, MyDamageType, MomentumTransfer, Location);
    Sleep(0.5);
    HurtRadius(Damage, DamageRadius*0.300, MyDamageType, MomentumTransfer, Location);
    Sleep(0.2);
    HurtRadius(Damage, DamageRadius*0.475, MyDamageType, MomentumTransfer, Location);
    Sleep(0.2);
    HurtRadius(Damage, DamageRadius*0.650, MyDamageType, MomentumTransfer, Location);
    Sleep(0.2);
    HurtRadius(Damage, DamageRadius*0.825, MyDamageType, MomentumTransfer, Location);
    Sleep(0.2);
    HurtRadius(Damage, DamageRadius*1.000, MyDamageType, MomentumTransfer, Location);
    Destroy();
}

defaultproperties
{
     Speed=10000.000000
     MinSpeed=2000.000000
     BombRange=5000.000000
     BombClass=Class'OnslaughtFull.ONSAutoBomberBomb'
     Health=150
     Team=255
     Damage=250.000000
     DamageRadius=2000.000000
     MomentumTransfer=200000.000000
     MyDamageType=Class'XWeapons.DamTypeRedeemer'
     ShakeRotMag=(Z=250.000000)
     ShakeRotRate=(Z=2500.000000)
     ShakeRotTime=6.000000
     ShakeOffsetMag=(Z=10.000000)
     ShakeOffsetRate=(Z=200.000000)
     ShakeOffsetTime=10.000000
     DyingEffectClass=Class'OnslaughtFull.ONSAutoBomberDeathFlames'
     DrawType=DT_Mesh
     bAlwaysRelevant=True
     bUpdateSimulatedPosition=True
     Physics=PHYS_Flying
     RemoteRole=ROLE_SimulatedProxy
     Mesh=SkeletalMesh'ONSFullAnimations.Bomber'
     CollisionRadius=200.000000
     CollisionHeight=75.000000
     bCollideActors=True
     bCollideWorld=True
     bBlockActors=True
     bBlockKarma=True
     bNetNotify=True
}
