//-----------------------------------------------------------
//
//-----------------------------------------------------------
class ONSPCTeleportTrigger extends Triggers;

function UsedBy(Pawn user)
{
	if (Owner != None)
		Owner.UsedBy(user);
}

function Touch(Actor Other)
{
	local Pawn P;

	//hack so bots realize they're close enough for node teleporting
	P = Pawn(Other);
	if (P != None && AIController(P.Controller) != None && P.Controller.RouteGoal == Owner)
		P.Controller.MoveTimer = -1;
}

defaultproperties
{
     bStasis=True
     CollisionRadius=230.000000
     CollisionHeight=200.000000
}
