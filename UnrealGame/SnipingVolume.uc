class SnipingVolume extends Volume;

var UnrealScriptedSequence SnipingPoints[16];

function AddDefensePoint(UnrealScriptedSequence S)
{
	local int i;

	for ( i=0; i<16; i++ )
		if ( SnipingPoints[i] == None )
		{
			SnipingPoints[i] = S;
			break;
		}
}

event Touch(Actor Other)
{
	local Pawn P;
	local Bot B;
	
	local int i;

	P = Pawn(Other);
	if ( (P == None) || !P.IsPlayerPawn() )
		return;
		
	for ( i=0; i<16; i++ )
	{
		if ( SnipingPoints[i] == None )
			break;
		else
		{
			B = Bot(SnipingPoints[i].CurrentUser);
			if ( (B != None) && B.Squad.SetEnemy(B,P) )
				B.WhatToDoNext(41);
		}
	}
}

			

defaultproperties
{
}
