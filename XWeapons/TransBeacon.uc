//=============================================================================
// Translocator Beacon
//=============================================================================
class TransBeacon extends TranslocatorBeacon;

var bool bCanHitOwner, bHitWater;
var bool bDamaged;
var bool bNoAI;
var xEmitter Trail;
var xEmitter Flare;
var Actor TranslocationTarget;	// for AI
var int Disruption;
var int DisruptionThreshold;
var Pawn Disruptor;
var TransBeaconSparks Sparks;
var class<TransTrail> TransTrailClass;
var class<TransFlareBlue> TransFlareClass;

replication
{
    reliable if ( Role == ROLE_Authority )
        Disruption;
}

simulated function Destroyed()
{
    if ( Trail != None )
        Trail.mRegen = false;
    if ( Flare != None )
    {
		Flare.mRegen = false;
        Flare.Destroy();
    }
    if ( Sparks != None )
        Sparks.Destroy();
	Super.Destroyed();
}

event EncroachedBy( actor Other )
{
	if ( Mover(Other) != None )
		Destroy();
}

simulated function bool Disrupted()
{
	return ( Disruption > DisruptionThreshold );
}

simulated function PostBeginPlay()
{
    local Rotator r;
	local int diff;

    Super.PostBeginPlay();

    if ( Role == ROLE_Authority )
    {
		R = Rotation;
		if ( AimUp() )
		{
			R.Pitch = R.Pitch & 65535;
			if ( R.Pitch > 32768 )
				diff = 65536 - R.Pitch;
			else
				diff = R.Pitch;
			R.Pitch = R.Pitch + (32768 - diff)/8;
		}
        Velocity = Speed * Vector(R);
        R.Yaw = Rotation.Yaw;
        R.Pitch = 0;
        R.Roll = 0;
        SetRotation(R);
        bCanHitOwner = false;
    }
    Trail = Spawn(TransTrailClass, self,, Location, Rotation);
    SetTimer(0.3,false);
}

function bool AimUp()
{
	if ( xPlayer(Instigator.Controller) == None )
		return false;

	return xPlayer(Instigator.Controller).bHighBeaconTrajectory;
}

simulated function PhysicsVolumeChange( PhysicsVolume Volume )
{
}

simulated function Landed( vector HitNormal )
{
    HitWall( HitNormal, None );
}

simulated function ProcessTouch( actor Other, vector HitLocation )
{
	local vector Vel2D;

    if ( Other == Instigator && Physics == PHYS_None )
        Destroy();
    else if ( (Other != Instigator) || bCanHitOwner )
    {
   		if ( (Pawn(Other) != None) && (Vehicle(Other) == None) )
		{
			Vel2D = Velocity;
			Vel2D.Z = 0;
			if ( VSize(Vel2D) < 200 )
				return;
		}
		HitWall( -Normal(Velocity), Other );
        //HitWall( Normal(HitLocation-Other.Location), Other );	// causes problems with actors using large staticmeshes
    }
}

// poll for disruption
simulated function Timer()
{
    if ( Level.NetMode == NM_DedicatedServer )
        return;

    if ( !Disrupted() )
    {
        SetTimer(0.3, false);
        return;
    }

    // create the disrupted effect
    if (Sparks == None)
    {
        Sparks = Spawn(class'TransBeaconSparks',,,Location+vect(0,0,5),Rotator(vect(0,0,1)));
        Sparks.SetBase(self);
    }

    if (Flare != None)
        Flare.Destroy();
}

function TakeDamage(int Damage, Pawn EventInstigator, vector HitLocation, vector Momentum, class<DamageType> DamageType)
{
    if ( Level.Game.bTeamGame && (EventInstigator != None)
		&& (EventInstigator.PlayerReplicationInfo != None)
		&& ((Instigator == None) || (EventInstigator.PlayerReplicationInfo.Team == Instigator.PlayerReplicationInfo.Team)) )
    {
		return;
    }
    else
    {
        Disruption += Damage;
		Disruptor = EventInstigator;
    }
}

function BotTranslocate();

simulated function HitWall( vector HitNormal, actor Wall )
{
	local CTFBase B;

    bCanHitOwner = true;

	Velocity = 0.3*(( Velocity dot HitNormal ) * HitNormal * (-2.0) + Velocity);   // Reflect off Wall w/damping
	Speed = VSize(Velocity);

	if ( Speed < 100 )
	{
		ForEach TouchingActors(class'CTFBase', B)
			break;

		if ( B != None )
		{
			Speed = VSize(Velocity);
			if ( Speed < 100 )
			{
				Speed = 90;
				Velocity = 90 * Normal(Velocity);
			}
			Disruption += 5;
			if ( Disruptor == None )
				Disruptor = Instigator;
		}
	}


	if ( Speed < 20 && Wall.bWorldGeometry && (HitNormal.Z >= 0.7) )
	{
		if ( Level.NetMode != NM_DedicatedServer )
			PlaySound(ImpactSound, SLOT_Misc );
		bBounce = false;
		SetPhysics(PHYS_None);

		if (Trail != None)
			Trail.mRegen = false;

		if ( (Level.NetMode != NM_DedicatedServer) && (Flare == None) )
		{
			Flare = Spawn(TransFlareClass, self,, Location - vect(0,0,5), rot(16384,0,0));
			Flare.SetBase(self);
		}
	}
}

// AI Interface
function SetTranslocationTarget(actor T)
{
	TranslocationTarget = T;
	GotoState('MonitoringThrow');
}

function bool IsMonitoring(actor A)
{
	return false;
}

function EndMonitoring();

State MonitoringThrow
{
	function bool IsMonitoring(actor A)
	{
		return ( A == TranslocationTarget );
	}

	function Destroyed()
	{
		local Bot B;

		B = Bot(Instigator.Controller);
		if ( B != None )
		{
			B.TranslocationTarget = None;
			B.RealTranslocationTarget = None;
			B.bPreparingMove = false;
			B.SwitchToBestWeapon();
		}
		Global.Destroyed();
	}

	function EndMonitoring()
	{
		GotoState('');
	}

	function EndState()
	{
		local Bot B;

		B = Bot(Instigator.Controller);
		if ( (B != None) && !bNoAI )
		{
			B.TranslocationTarget = None;
			B.RealTranslocationTarget = None;
			B.bPreparingMove = false;
			B.SwitchToBestWeapon();
		}
	}

	simulated function HitWall( vector HitNormal, actor Wall )
	{
		Global.HitWall(HitNormal,Wall);
		if ( (GameObject(TranslocationTarget) != None) && (HitNormal.Z > 0.7)
				&& (VSize(Location - TranslocationTarget.Location) < FMin(400, VSize(Instigator.Location - TranslocationTarget.Location))) )
		{
			Instigator.Controller.MoveTarget = TranslocationTarget;
			BotTranslocate();
			return;
		}

		if ( Physics == PHYS_None )
		{
			if ( (Bot(Instigator.Controller) != None) && Bot(Instigator.Controller).bPreparingMove )
			{
				Bot(Instigator.Controller).MoveTimer = -1;
				if ( (JumpSpot(TranslocationTarget) != None) && (Instigator.Controller.MoveTarget == TranslocationTarget) )
					JumpSpot(TranslocationTarget).FearCost += 900;
			}
			EndMonitoring();
		}
	}

	function BotTranslocate()
	{
		if ( TransLauncher(Instigator.Weapon) != None )
			Instigator.Weapon.GetFireMode(1).DoFireEffect();
		EndMonitoring();
	}

	function Touch(Actor Other)
	{
		local Pawn P;

		P = Pawn(Other);
		if ( (P == None) || (P == Instigator) )
			return;
		ProcessTouch( Other, Location );
		if ( (Bot(P.Controller) == None) || Level.Game.IsOnTeam(P.Controller,Instigator.PlayerReplicationInfo.Team.TeamIndex) )
		{
			EndMonitoring();
			return;
		}
		if ( Bot(P.Controller).ProficientWithWeapon() && (2 + FRand() * 8 < Bot(P.Controller).Skill) )
			BotTranslocate();
	}

	// FIXME - consider making this a timer or projectile latent function instead of using tick?
	function Tick(float DeltaTime)
	{
		local vector Dist, Dir, HitLocation, HitNormal;
		local float ZDiff, Dist2D;
		local actor HitActor;

		if ( (TranslocationTarget == None) || (Instigator.Controller == None)
			|| !Bot(Instigator.Controller).Squad.AllowTranslocationBy(Bot(Instigator.Controller))
			|| ((GameObject(Instigator.Controller.MoveTarget) != None) && (Instigator.Controller.MoveTarget != TranslocationTarget))
			|| ((TranslocationTarget != Instigator.Controller.MoveTarget)
				&& (TranslocationTarget != Instigator.Controller.RouteGoal)
				&& (TranslocationTarget != Instigator.Controller.RouteCache[0])
				&& (TranslocationTarget != Instigator.Controller.RouteCache[1])
				&& (TranslocationTarget != Instigator.Controller.RouteCache[2])
				&& (TranslocationTarget != Instigator.Controller.RouteCache[3])) )
		{
			EndMonitoring();
			return;
		}

		Dist = Location - TranslocationTarget.Location;
		ZDiff = Dist.Z;
		Dist.Z = 0;
		Dir = TranslocationTarget.Location - Instigator.Location;
		Dir.Z = 0;
		Dist2D = VSize(Dist);
		if ( Dist2D < TranslocationTarget.CollisionRadius )
		{
			if ( ZDiff > -0.9 * TranslocationTarget.CollisionHeight )
			{
				Instigator.Controller.MoveTarget = TranslocationTarget;
				BotTranslocate();
			}
			return;
		}
		Dir = TranslocationTarget.Location - Instigator.Location;
		Dir.Z = 0;
		if ( (Dist Dot Dir) > 0 )
		{
			if ( (Bot(Instigator.Controller) != None) && Bot(Instigator.Controller).bPreparingMove )
				{
					Bot(Instigator.Controller).MoveTimer = -1;
					if ( (JumpSpot(TranslocationTarget) != None) && (Instigator.Controller.MoveTarget == TranslocationTarget) )
					JumpSpot(TranslocationTarget).FearCost += 400;
			}
			else if ( (GameObject(TranslocationTarget) != None) && (ZDiff > 0) && (Dist2D < FMin(400, VSize(Instigator.Location - TranslocationTarget.Location) - 250)) )
			{
				// if safe underneath, then translocate
				HitActor = Trace(HitLocation, HitNormal, Location - vect(0,0,100), Location, false);
				if ( (HitActor != None) && (HitNormal.Z > 0.7) )
				{
					Instigator.Controller.MoveTarget = TranslocationTarget;
					BotTranslocate();
					return;
				}
			}
			EndMonitoring();
			return;
		}
	}
}
// END AI interface

defaultproperties
{
     DisruptionThreshold=65
     TransTrailClass=Class'XEffects.TransTrail'
     TransFlareClass=Class'XEffects.TransFlareRed'
     Speed=1200.000000
     DamageRadius=100.000000
     MomentumTransfer=50000.000000
     MyDamageType=Class'XWeapons.DamTypeTeleFrag'
     ImpactSound=ProceduralSound'WeaponSounds.PGrenFloor1.P1GrenFloor1'
     ExplosionDecal=Class'XEffects.RocketMark'
     DrawType=DT_StaticMesh
     StaticMesh=StaticMesh'WeaponStaticMesh.NEWTranslocatorPUCK'
     bNetTemporary=False
     bUpdateSimulatedPosition=True
     bOnlyDirtyReplication=True
     Physics=PHYS_Falling
     NetUpdateFrequency=8.000000
     AmbientSound=Sound'WeaponSounds.Misc.redeemer_flight'
     DrawScale=0.350000
     PrePivot=(Z=25.000000)
     AmbientGlow=64
     bUnlit=False
     bOwnerNoSee=True
     SoundVolume=250
     SoundPitch=128
     SoundRadius=7.000000
     CollisionRadius=10.000000
     CollisionHeight=10.000000
     bProjTarget=True
     bNetNotify=True
     bBounce=True
}
