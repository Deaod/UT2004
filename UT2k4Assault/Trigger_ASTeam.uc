//=============================================================================
// Trigger_ASTeam: triggers for all pawns with matching team
//=============================================================================

class Trigger_ASTeam extends Trigger;

var()	enum EPSM_AssaultTeam
{
	EPSM_Attackers,
	EPSM_Defenders,
} AssaultTeam;

var() bool bTimed;

function PostBeginPlay()
{
	Super.PostBeginPlay();
	if ( bTimed )
		SetTimer(2.5, true);
}

function Timer()
{
	local Controller P;

	for ( P=Level.ControllerList; P!=None; P=P.NextController )
		if ( (P.Pawn != None) && (abs(Location.Z - P.Pawn.Location.Z) < CollisionHeight + P.CollisionHeight)
			&& (VSize(Location - P.Pawn.Location) < CollisionRadius) )
			Touch(P.Pawn);
	SetTimer(2.5, true);
}

function bool IsRelevant( actor Other )
{
	local Actor Inst;

	Inst = FindInstigator( Other );

	if ( Inst != None )
	{
		if( !bInitiallyActive || !Level.Game.bTeamGame || (Inst.Instigator == None) 
			|| !Level.Game.IsOnTeam(Inst.Instigator.Controller, GetAssaultTeamIndex()) )
			return false;
	}

	return Super.IsRelevant(Other);
}

function Touch( actor Other )
{
	// ugly speed hack ship it (tm)
	// if trigger has been disabled (bTriggerOnceOnly), skip touch event
	// ugly hack to fix robot factory touch event (rarely) called twice from Volume.AssociatedActor, 
	// causing ScriptedTrigger to skip an Action, and therefore not enabling a PlayerSpawn manager...
	if ( bTriggerOnceOnly && bCollideActors != bSavedInitialCollision && !bCollideActors )
		return;

	super.Touch( Other );
}

function TakeDamage( int Damage, Pawn instigatedBy, Vector hitlocation, 
						Vector momentum, class<DamageType> damageType)
{
	if ( (InstigatedBy != None) && Level.Game.bTeamGame
		&& Level.Game.IsOnTeam(InstigatedBy.Controller, GetAssaultTeamIndex()) )
		Super.TakeDamage(Damage, instigatedBy, HitLocation, Momentum, DamageType);
}

function int GetAssaultTeamIndex()
{
	if ( Level.Game.IsA('ASGameInfo') )
	{
		if ( AssaultTeam == EPSM_Attackers )
			return ASGameInfo(Level.Game).GetAttackingTeam();
		
		return ( 1 - ASGameInfo(Level.Game).GetAttackingTeam() );
	}	

	return 0;
}

defaultproperties
{
}
