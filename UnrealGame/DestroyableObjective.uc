class DestroyableObjective extends GameObjective;

// Trigger type.
var() enum EConstraintInstigator
{
	CI_All,				// Anything can deal damage to objective
	CI_PawnClass,		// Only Forced Pawn class can deal damage to objective
} ConstraintInstigator;

var()	class<Pawn>	ConstraintPawnClass;

var()	int		DamageCapacity;			// amount of damage that can be taken before destroyed
var()	name	TakeDamageEvent;
var()	int		DamageEventThreshold;	// trigger damage event whenever this amount of damage is taken
var		int		AccumulatedDamage;
var		int		Health;
var		float	LinkHealMult;			// If > 0, Link Gun secondary heals an amount equal to its damage times this
var()	float	VehicleDamageScaling;
var()   vector  AIShootOffset; //adjust where AI should try to shoot this objective
var ShootTarget ShootTarget;

var()	bool	bCanDefenderDamage;		// can defender damage objective ?
var     bool    bReplicateHealth;
var bool		bMonitorUnderAttack;
var	bool		bIsUnderAttack;
var	VolumeTimer	UnderAttackTimer;
var float		LastDamageTime;
var float		LastWarnTime;

replication
{
    reliable if ( bReplicateHealth && (Role == ROLE_Authority) )
        Health;

	unreliable if ( bMonitorUnderAttack && (Role==ROLE_Authority) && bReplicateObjective && bNetDirty )
		bIsUnderAttack;
}

function PostBeginPlay()
{
	super.PostBeginPlay();
	if (AIShootOffset != vect(0,0,0))
	{
		ShootTarget = spawn(class'ShootTarget', self,, Location + AIShootOffset);
		ShootTarget.SetBase(self);
	}
	Reset();
}

event int SpecialCost(Pawn Other, ReachSpec Path)
{
	return 0;
}

function SetDelayedDamageInstigatorController(Controller C)
{
	DelayedDamageInstigatorController = C;
}

function Destroyed()
{
	if ( UnderAttackTimer != None )
	{
		UnderAttackTimer.Destroy();
		UnderAttackTimer = None;
	}

	super.Destroyed();
}

simulated function bool TeamLink(int TeamNum)
{
	return ( LinkHealMult > 0 && (DefenderTeamIndex == TeamNum) );
}

function Actor GetShootTarget()
{
	if (ShootTarget != None)
		return ShootTarget;

	return self;
}

function bool KillEnemyFirst(Bot B)
{
	return false;
}

function bool LegitimateTargetOf(Bot B)
{
	if ( ConstraintInstigator == CI_PawnClass && !ClassIsChildOf(B.Pawn.Class, ConstraintPawnClass) )
		return false;

	if ( (DamageCapacity > 0) && bActive && !bDisabled )
		return true;
	return false;
}

/* TellBotHowToDisable()
tell bot what to do to disable me.
return true if valid/useable instructions were given
*/
function bool TellBotHowToDisable(Bot B)
{
	local int i;
	local float Best, Next;
	local vector Dir;
	local NavigationPoint BestPath;
	local bool bResult;

	// Only a specific Pawn can deal damage to objective ?
	if ( ConstraintInstigator == CI_PawnClass && !ClassIsChildOf(B.Pawn.Class, ConstraintPawnClass) )
		return false;

	if ( (B.Pawn.Physics == PHYS_Flying) && (B.Pawn.MinFlySpeed > 0) )
	{
		if ( (VehiclePath != None) && B.Pawn.ReachedDestination(VehiclePath) )
		{
			B.Pawn.AirSpeed = FMin(B.Pawn.AirSpeed, 1.05 * B.Pawn.MinFlySpeed);
			B.Pawn.bThumped = true;
			Dir = Normal(B.Pawn.Velocity);
			// go on to next pathnode past VehiclePath
			for ( i=0; i<VehiclePath.PathList.Length; i++ )
			{
				if ( BestPath == None )
				{
					BestPath = VehiclePath.PathList[i].End;
					Best = Dir Dot Normal(BestPath.Location - VehiclePath.Location);
				}
				else
				{
					Next = Dir Dot Normal(VehiclePath.PathList[i].End.Location - VehiclePath.Location);
					if ( Next > Best )
					{
						Best = Next;
						BestPath = VehiclePath.PathList[i].End;
					}
				}
			}
			if ( BestPath != None )
			{
				B.MoveTarget = BestPath;
				B.SetAttractionState();
				return true;
			}
		}
		if ( B.CanAttack(GetShootTarget()) )
		{
			B.Pawn.AirSpeed = FMin(B.Pawn.AirSpeed, 1.05 * B.Pawn.MinFlySpeed);
			B.Focus = self;
			B.FireWeaponAt(self);
			B.GoalString = "Attack Objective";
			if ( !B.Squad.FindPathToObjective(B,self) )
			{
				B.DoRangedAttackOn(GetShootTarget());
				B.Pawn.Acceleration = B.Pawn.AccelRate * Normal(Location - B.Pawn.Location);
			}
			else
				return true;
		}
		bResult = Super.TellBotHowToDisable(B);
		if ( bResult && (FlyingPathNode(B.MoveTarget) != None) && (B.MoveTarget.CollisionRadius < 1000) )
			B.Pawn.AirSpeed = FMin(B.Pawn.AirSpeed, 1.05 * B.Pawn.MinFlySpeed);
		else
			B.Pawn.AirSpeed = B.Pawn.Default.AirSpeed;
		return bResult;
	}
	else if ( !B.Pawn.bStationary && B.Pawn.TooCloseToAttack(GetShootTarget()) )
	{
		B.GoalString = "Back off from objective";
		B.RouteGoal = B.FindRandomDest();
		B.MoveTarget = B.RouteCache[0];
		B.SetAttractionState();
		return true;
	}
	else if ( B.CanAttack(GetShootTarget()) )
	{
		if (KillEnemyFirst(B))
			return false;

		B.GoalString = "Attack Objective";
		B.DoRangedAttackOn(GetShootTarget());
		return true;
	}

	return Super.TellBotHowToDisable(B);
}

function bool NearObjective(Pawn P)
{
	if ( P.CanAttack(GetShootTarget()) )
		return true;
	return Super.NearObjective(P);
}

/* TellBotHowToHeal()
tell bot what to do to heal me
return true if valid/useable instructions were given
*/
function bool TellBotHowToHeal(Bot B)
{
	local Vehicle OldVehicle;

	if (!TeamLink(B.GetTeamNum()) || Health >= DamageCapacity)
		return false;

	if (B.Squad.SquadObjective == None)
	{
		if (Vehicle(B.Pawn) != None)
			return false;
		//hack - if bot has no squadobjective, need this for SwitchToBestWeapon() so bot's weapons' GetAIRating()
		//has some way of figuring out bot is trying to heal me
		B.DoRangedAttackOn(self);
	}

	if (Vehicle(B.Pawn) != None && !Vehicle(B.Pawn).bKeyVehicle && (B.Enemy == None || (!B.EnemyVisible() && Level.TimeSeconds - B.LastSeenTime > 3)))
	{
		OldVehicle = Vehicle(B.Pawn);
		Vehicle(B.Pawn).KDriverLeave(false);
	}

	if (B.Pawn.Weapon != None && B.Pawn.Weapon.CanHeal(self))
	{
		if (!B.Pawn.CanAttack(GetShootTarget()))
		{
			//need to move to somewhere else near objective
			B.GoalString = "Can't shoot"@self@"(obstructed)";
			B.RouteGoal = B.FindRandomDest();
			B.MoveTarget = B.RouteCache[0];
			B.SetAttractionState();
			return true;
		}
		B.GoalString = "Heal "$self;
		B.DoRangedAttackOn(GetShootTarget());
		return true;
	}
	else
	{
		B.SwitchToBestWeapon();
		if (B.Pawn.PendingWeapon != None && B.Pawn.PendingWeapon.CanHeal(self))
		{
			if (!B.Pawn.CanAttack(GetShootTarget()))
			{
				//need to move to somewhere else near objective
				B.GoalString = "Can't shoot"@self@"(obstructed)";
				B.RouteGoal = B.FindRandomDest();
				B.MoveTarget = B.RouteCache[0];
				B.SetAttractionState();
				return true;
			}
			B.GoalString = "Heal "$self;
			B.DoRangedAttackOn(GetShootTarget());
			return true;
		}
		if (B.FindInventoryGoal(0.0005)) //try to find a weapon to heal the objective
		{
			B.GoalString = "Find weapon or ammo to heal "$self;
			B.SetAttractionState();
			return true;
		}
	}

	if (OldVehicle != None)
		OldVehicle.UsedBy(B.Pawn);

	return false;
}

/* Reset()
reset actor to initial state - used when restarting level without reloading.
*/
function Reset()
{
	Health				= DamageCapacity;
	AccumulatedDamage	= 0;
	bProjTarget			= true;
	bIsUnderAttack		= false;

	SetCollision(true, bBlockActors);

	if ( UnderAttackTimer != None )
	{
		UnderAttackTimer.Destroy();
		UnderAttackTimer = None;
	}

	super.Reset();
}

function TakeDamage( int Damage, Pawn instigatedBy, Vector hitlocation,
						Vector momentum, class<DamageType> damageType)
{
	local float			DamagePct, HealthTaken;
	local Controller	InstigatorController;
	local Pawn CurrentInstigator;

	if ( !bActive || bDisabled || (Damage <= 0) || !UnrealMPGameInfo(Level.Game).CanDisableObjective( Self ) )
		return;

	CurrentInstigator = InstigatedBy;
	if ( Vehicle(instigatedBy) != None )
		Damage *= VehicleDamageScaling;

	if ( damageType != None)
		Damage *= damageType.default.VehicleDamageScaling;

	if ( (instigatedBy == None || instigatedBy.Controller == None) && (DelayedDamageInstigatorController != None) )
	{
		instigatedBy			= DelayedDamageInstigatorController.Pawn;
		InstigatorController	= DelayedDamageInstigatorController;
	}

	if ( instigatedBy != None )
	{
		if ( InstigatedBy.Controller != None )
			InstigatorController = InstigatedBy.Controller;
		if ( instigatedBy.HasUDamage() )
			Damage *= 2;
		Damage *= instigatedBy.DamageScaling;
	}

	// Only a specific Pawn can deal damage to objective ?
	if ( ConstraintInstigator == CI_PawnClass
		&& ((InstigatedBy == None) || !ClassIsChildOf(instigatedBy.Class, ConstraintPawnClass)) )
		return;

	// Can defenders damage Objective ?
	if ( !bCanDefenderDamage
		&& ( (InstigatedBy != None && InstigatedBy.GetTeamNum() == DefenderTeamIndex)
		|| (InstigatorController != None && InstigatorController.GetTeamNum() == DefenderTeamIndex) ) )
		return;

	Damage = UnrealMPGameInfo(Level.Game).AdjustDestroyObjectiveDamage( Damage, InstigatorController, Self );
	NetUpdateTime = Level.TimeSeconds - 1;
	AccumulatedDamage += Damage;
	if ( (DamageEventThreshold > 0) && (AccumulatedDamage >= DamageEventThreshold) )
	{
		TriggerEvent(TakeDamageEvent, Self, InstigatedBy);
		AccumulatedDamage = 0;
	}

	HealthTaken = Min(Damage, Health);
	Health	-= Damage;
	if ((DefenseSquad != None) && (CurrentInstigator != None) && (CurrentInstigator.Controller != None) && (Level.TimeSeconds - LastWarnTime > 0.5) )
	{
		LastWarnTime = Level.TimeSeconds;
		DefenseSquad.Team.AI.CriticalObjectiveWarning(self, CurrentInstigator);
	}

	// monitor percentage of damage done for score sharing
	DamagePct = HealthTaken / float(DamageCapacity);
	if ( InstigatedBy != None && InstigatedBy.Controller != None )
		AddScorer( InstigatedBy.Controller, DamagePct );
	else if ( DelayedDamageInstigatorController != None )
		AddScorer( DelayedDamageInstigatorController, DamagePct );

	if ( Health < 1 )
		DisableObjective( instigatedBy );
	else if ( bMonitorUnderAttack )
	{
		bIsUnderAttack	 = true;
		LastDamageTime	 = Level.TimeSeconds;
		CheckPlayCriticalAlarm();

		if ( UnderAttackTimer == None )
			UnderAttackTimer = Spawn(class'VolumeTimer', Self);
	}
}

/* Award Assault score to player(s) who completed the objective */
function AwardAssaultScore( int Score )
{
	ShareScore( Score, "Objective_Completed" );
}

function bool HealDamage(int Amount, Controller Healer, class<DamageType> DamageType)
{
	if ( !bActive || bDisabled || Health <= 0 || Health >= DamageCapacity || Amount <= 0
	     || Healer == None || !TeamLink(Healer.GetTeamNum()) )
		return false;

	Health = Min(Health + (Amount * LinkHealMult), DamageCapacity);
	NetUpdateTime = Level.TimeSeconds - 1;
	return true;
}

function DisableObjective(Pawn Instigator)
{
	if ( !bActive || bDisabled || !UnrealMPGameInfo(Level.Game).CanDisableObjective( Self ) )
		return;

	SetCollision(false, bBlockActors);
	bProjTarget		= false;
	bIsUnderAttack	= false;

	if ( UnderAttackTimer != None )
	{
		UnderAttackTimer.Destroy();
		UnderAttackTimer = None;
	}

	super.DisableObjective(Instigator);
}

function TimerPop(VolumeTimer T)
{
	if ( bIsUnderAttack && Level.TimeSeconds > LastDamageTime + 4 )
	{
		bIsUnderAttack	= false;
		CheckPlayCriticalAlarm();

		if ( UnderAttackTimer != None )
		{
			UnderAttackTimer.Destroy();
			UnderAttackTimer = None;
		}
	}
}

/* DestroyableObjectives are in danger when CriticalVolume is breached or Objective is damaged
	(In case Objective can be damaged from a great distance */
simulated function bool IsCritical()
{
	return (IsActive() && (bIsCritical || bIsUnderAttack));
}

/* returns objective's progress status 1->0 (=disabled) */
simulated function float GetObjectiveProgress()
{
	if ( bDisabled )
		return 0;
	return (float(Health) / float(DamageCapacity));
}

defaultproperties
{
     ConstraintPawnClass=Class'Engine.Pawn'
     DamageCapacity=100
     VehicleDamageScaling=1.000000
     bReplicateHealth=True
     bMonitorUnderAttack=True
     bReplicateObjective=True
     bPlayCriticalAssaultAlarm=True
     ObjectiveName="Destroyable Objective"
     ObjectiveTypeIcon=FinalBlend'AS_FX_TX.Icons.OBJ_Destroy_FB'
     ObjectiveDescription="Destroy Objective to disable it."
     Objective_Info_Attacker="Destroy Objective"
     Objective_Info_Defender="Protect Objective"
     Announcer_DisabledObjective=Sound'AnnouncerAssault.Generic.Objective_destroyed'
     bNotBased=True
     bDestinationOnly=True
     bSpecialForced=False
     bStatic=False
     bAlwaysRelevant=True
     bCanBeDamaged=True
     bCollideActors=True
     bProjTarget=True
}
