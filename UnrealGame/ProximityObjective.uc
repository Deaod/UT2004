class ProximityObjective extends GameObjective;

var() class<Pawn> ConstraintPawnClass;


function Touch(Actor Other)
{
	local Pawn P;

	P = Pawn(Other);
	if ( P != None && IsRelevant(P, true) )
		DisableObjective( Instigator );
}

function bool IsRelevant( Pawn P, bool bAliveCheck )
{
	if ( !IsActive() || !UnrealMPGameInfo(Level.Game).CanDisableObjective( Self ) )
		return false;

	if ( !ClassIsChildOf(P.Class, ConstraintPawnClass) )
		return false;

	Instigator = FindInstigator( P );
	if ( (Instigator.GetTeam() == None) || (Instigator.GetTeam().TeamIndex == DefenderTeamIndex) )
		return false;

	if ( bAliveCheck )
	{
		if ( Instigator.Health < 1 || Instigator.bDeleteMe || !Instigator.IsPlayerPawn() )
			return false;
	}

	if ( bBotOnlyObjective && (PlayerController(Instigator.Controller) != None) )
		return false;

	return true;
}

function Pawn FindInstigator( Pawn Other )
{
	// Hack if player is in turret and not controlling vehicle...
	if ( Vehicle(Other) != None && Vehicle(Other).Controller == None )
		return Vehicle(Other).GetInstigator();

	return Other;
}

function SetActive( bool bActiveStatus )
{
	if ( bDisabled )				// Cannot be active if objective is disabled
		bActiveStatus = false;

	super.SetActive( bActiveStatus );

	if ( bActive )
		SetCollision(true, false, false);
	else
		SetCollision(false, false, false);
}


/* TellBotHowToDisable()
tell bot what to do to disable me.
return true if valid/useable instructions were given
*/
function bool TellBotHowToDisable(Bot B)
{
	local bool bResult;
	if ( B.Pawn == None )
		return false;

	if ( !IsRelevant(B.Pawn, true) )
	{
		if ( Vehicle(B.Pawn) != None )
		{
			if ( (B.Pawn.Physics == PHYS_Flying) && (B.Pawn.MinFlySpeed > 0) )
			{
				bResult = Super.TellBotHowToDisable(B);
				if ( bResult && (FlyingPathNode(B.MoveTarget) != None) && (B.MoveTarget.CollisionRadius < 1000) ) 
					B.Pawn.AirSpeed = FMin(B.Pawn.AirSpeed, 1.05 * B.Pawn.MinFlySpeed);
				else
					B.Pawn.AirSpeed = B.Pawn.Default.AirSpeed;
				return bResult;
			}

			if ( (Vehicle(B.Pawn) != None) && !B.Squad.NeverBail(B.Pawn)
				&& (Vehicle(B.Pawn).Driver != None) && IsRelevant(Vehicle(B.Pawn).Driver, true) )
			{
				if ( VSize(B.Pawn.Location - Location) < 1200 ) 
				{
					Vehicle(B.Pawn).TeamUseTime = Level.TimeSeconds + 6;
					Vehicle(B.Pawn).KDriverLeave(false);
				}
			}	
			else if ( (Vehicle(B.Pawn) != None) && (VehiclePath != None) )
				return Super.TellBotHowToDisable(B);
			else 
				return false;
		}
		else
			return false;
	}
	
	if ( B.Pawn.ReachedDestination(self) )
	{
		if ( B.Enemy != None )
		{
			if ( B.EnemyVisible() )
				B.GotoState('ShieldSelf','Begin');
			else
				B.DoStakeOut();
		}
		else
			B.GotoState('RestFormation','Pausing');
		return true;
	}
		
	return Super.TellBotHowToDisable(B);
}

defaultproperties
{
     ConstraintPawnClass=Class'UnrealGame.UnrealPawn'
     bReplicateObjective=True
     bPlayCriticalAssaultAlarm=True
     ObjectiveName="Proximity Objective"
     ObjectiveTypeIcon=FinalBlend'AS_FX_TX.Icons.OBJ_Proximity_FB'
     ObjectiveDescription="Touch Objective to disable it."
     Objective_Info_Attacker="Touch Objective"
     Announcer_DisabledObjective=Sound'AnnouncerAssault.Generic.Objective_reached'
     bNotBased=True
     bStatic=False
     bOnlyAffectPawns=True
     bIgnoreEncroachers=True
     bAlwaysRelevant=True
     bCollideWhenPlacing=False
     bCollideActors=True
}
