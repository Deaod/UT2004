//=============================================================================
// DMSquad.
// operational AI control for DeathMatch
// each bot is on its own squad
//=============================================================================

class DMSquad extends SquadAI;

function AssignCombo(Bot B)
{
	if ( (B.Enemy != None) && B.EnemyVisible() )
		B.TryCombo("DMRandom");
}

function DisplayDebug(Canvas Canvas, out float YL, out float YPos)
{
	local string EnemyList;
	local int i;

	Canvas.SetDrawColor(255,255,255);
	EnemyList = "     Enemies: ";
	for ( i=0; i<ArrayCount(Enemies); i++ )
		if ( Enemies[i] != None )
			EnemyList = EnemyList@Enemies[i].GetHumanReadableName();
	Canvas.DrawText(EnemyList, false);

	YPos += YL;
	Canvas.SetPos(4,YPos);
}

function bool IsDefending(Bot B)
{
	return false;
}

function AddBot(Bot B)
{
	Super.AddBot(B);
	SquadLeader = B;
}

function RemoveBot(Bot B)
{
	if ( B.Squad != self )
		return;
	Destroy();
}

/*
Return true if squad should defer to C
*/
function bool ShouldDeferTo(Controller C)
{
	return false;
}

function bool CheckSquadObjectives(Bot B)
{
	return false;
}

function bool WaitAtThisPosition(Pawn P)
{
	return false;
}

function bool NearFormationCenter(Pawn P)
{
	return true;
}

/* BeDevious()
return true if bot should use guile in hunting opponent (more expensive)
*/
function bool BeDevious()
{
	return ( (SquadMembers.Skill >= 4)
		&& (FRand() < 0.65 - 0.15 * Level.Game.NumBots) );
}

function name GetOrders()
{
	return CurrentOrders;
}

function bool SetEnemy( Bot B, Pawn NewEnemy )
{
	local bool bResult;
	
	if ( (NewEnemy == None) || (NewEnemy.Health <= 0) || (NewEnemy.Controller == None)
		|| ((Bot(NewEnemy.Controller) != None) && (Bot(NewEnemy.Controller).Squad == self)) )
		return false;

	// add new enemy to enemy list - return if already there
	if ( !AddEnemy(NewEnemy) )
		return false;

	// reassess squad member enemy
	bResult = FindNewEnemyFor(B,(B.Enemy !=None) && B.LineOfSightTo(SquadMembers.Enemy));
	if ( bResult && (B.Enemy == NewEnemy) )
		B.AcquireTime = Level.TimeSeconds;
	return bResult;
}

function bool FriendlyToward(Pawn Other)
{
	return false;
}

function bool AssignSquadResponsibility(Bot B)
{
	local Pawn PlayerPawn;
	local Controller C;
	local actor MoveTarget;

	AssignCombo(B);

	if ( B.Enemy == None )
	{
		// suggest inventory hunt
		if ( (B.Skill > 5) && (Level.Game.NumBots == 1) && ((B.Pawn.Weapon.AIRating > 0.7) || B.Pawn.Weapon.bSniping) )
		{
			// maybe hunt player - only if have a fix on player location from sounds he's made
			for ( C=Level.ControllerList; C!=None; C=C.NextController )
				if ( (PlayerController(C) != None) && (C.Pawn != None) )
				{
					PlayerPawn = C.Pawn;
					if ( (Level.TimeSeconds - C.Pawn.Noise1Time < 5) || (Level.TimeSeconds - C.Pawn.Noise2Time < 5) )
					{
						B.bHuntPlayer = true;
						if ( (Level.TimeSeconds - C.Pawn.Noise1Time < 2) || (Level.TimeSeconds - C.Pawn.Noise2Time < 2) )
							B.LastKnownPosition = C.Pawn.Location;
						break;
					}
					else if ( (VSize(B.LastKnownPosition - C.Pawn.Location) < 800)
								|| (VSize(B.LastKillerPosition - C.Pawn.Location) < 800) )
					{
						B.bHuntPlayer = true;
						break;
					}
				}
		}
		if ( B.FindInventoryGoal(0) )
		{
			B.bHuntPlayer = false;
			B.SetAttractionState();
			return true;
		}
		if ( B.bHuntPlayer )
		{
			B.bHuntPlayer = false;
			B.GoalString = "Hunt Player";
			if ( B.ActorReachable(PlayerPawn) )
				MoveTarget = PlayerPawn;
			else
				MoveTarget = B.FindPathToward(PlayerPawn,B.Pawn.bCanPickupInventory && (Vehicle(B.Pawn) == None));
			if ( MoveTarget != None )
			{
				B.MoveTarget = MoveTarget;
				if ( B.CanSee(PlayerPawn) )
					SetEnemy(B,PlayerPawn);
				B.SetAttractionState();
				return true;
			}
		}

		// roam around level?
		return B.FindRoamDest();
	}
	return false;
}

defaultproperties
{
     CurrentOrders="Freelance"
}
