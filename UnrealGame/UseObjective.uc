class UseObjective extends ProximityObjective;

 // called if this Actor was touching a Pawn who pressed Use
event UsedBy( Pawn User )
{
	if ( IsRelevant(User, true) )
	{
		DisableObjective( User );
	}
}

function Touch(Actor Other)
{
	local Pawn	P;

	P = Pawn(Other);
	if ( P != None && (Bot(P.Controller) != None) )
	{
		UsedBy( P ); // Force bots to Use on Touch()
	}
}

/* TellBotHowToDisable()
tell bot what to do to disable me.
return true if valid/useable instructions were given
*/
function bool TellBotHowToDisable(Bot B)
{
	if ( B.Pawn == None )
		return false;

	if ( !IsRelevant(B.Pawn, true) )
	{
		if ( (Vehicle(B.Pawn) != None) && !B.Squad.NeverBail(B.Pawn)
			&& (Vehicle(B.Pawn).Driver != None) && IsRelevant(Vehicle(B.Pawn).Driver, true) )
		{
			if ( VSize(B.Pawn.Location - Location) < 1200 ) 
			{
				Vehicle(B.Pawn).TeamUseTime = Level.TimeSeconds + 6;
				Vehicle(B.Pawn).KDriverLeave(false);
			}
		}	
		else
			return false;
	}
	
	if ( B.Pawn.ReachedDestination(self) )
	{
		UsedBy(B.Pawn);
		return false;
	}
	return Super.TellBotHowToDisable(B);
}

defaultproperties
{
     ObjectiveDescription="Reach Objective and Use it to disable it."
     Objective_Info_Attacker="Use Objective"
     Announcer_DisabledObjective=Sound'AnnouncerAssault.Generic.Objective_accomplished'
}
