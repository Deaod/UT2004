class xBombDeliveryHole extends Decoration
    notplaceable;

#exec OBJ LOAD File=XGame_StaticMeshes.usx

function Touch(Actor Other)
{
    local xBombFlag bomb;

    bomb = xBombFlag(Other);

    if (bomb != None)
        TryThrowScore(bomb);
    else
        TryJumpScore(Pawn(Other));
}

function bool CheckScorer(Pawn P, bool bKill)
{
	local vector NewVel;
	local Controller ScoreController;
	
    // valid player
    if ( P == None )
		return false;
	if ( P.IsPlayerPawn() )
		ScoreController = P.Controller;
	else if ( !bKill && (P.Controller == None) && P.WasPlayerPawn() )
		ScoreController = xPawn(P).OldController;
	else
		return false;
		
    // opposing team delivery
    if ( (ScoreController == None)
		|| (ScoreController.PlayerReplicationInfo == None)
		|| (ScoreController.PlayerReplicationInfo.Team.TeamIndex == xBombDelivery(Owner).Team) )
    {
		if ( (Bot(ScoreController) != None) && ScoreController.IsInState('Testing') )
			return false;
			
		if ( bKill && (P.Controller != None) )
		{
			// propel him on through
			NewVel = 300 * Normal(P.Velocity);
			NewVel.Z = 100;
			P.AddVelocity(NewVel);
			P.Died( P.Controller, class'Suicided', P.Location );
		}
        return false;
	}
    return true;
}

function TryThrowScore(xBombFlag bomb)
{
	local Controller ScoreController;

    if ( !Bomb.bThrownBomb || !CheckScorer(Bomb.Instigator, false) )
        return;

	if ( Bomb.Instigator.Controller != None )
		ScoreController = Bomb.Instigator.Controller;
	else
		ScoreController = xPawn(Bomb.Instigator).OldController;

    // throwing score!            
    xBombingRun(Level.Game).ScoreBomb(ScoreController, bomb);
    xBombDelivery(Owner).ScoreEffect(false);
}

function TryJumpScore(Pawn holder)
{
    if ( !CheckScorer(holder, true) )
        return;

    if (holder.Controller.PlayerReplicationInfo.HasFlag == None)
        return;

    // contact score!
    xBombingRun(Level.Game).ScoreBomb(holder.Controller, xBombFlag(holder.Controller.PlayerReplicationInfo.HasFlag));			
	TriggerEvent(Event,self, Holder);
    xBombDelivery(Owner).ScoreEffect(true);
}

// !! this uses a simple staticmesh for collision, a cylinder wouldn't suffice.

defaultproperties
{
     DrawType=DT_StaticMesh
     StaticMesh=StaticMesh'XGame_StaticMeshes.GameObjects.BombGateCol'
     bStatic=False
     bHidden=True
     RemoteRole=ROLE_None
     CollisionRadius=60.000000
     CollisionHeight=60.000000
     bCollideActors=True
}
