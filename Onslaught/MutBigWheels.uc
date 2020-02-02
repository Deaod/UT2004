class MutBigWheels extends Mutator;

function PostBeginPlay()
{
	local BigWheelsRules G;
	
	Super.PostBeginPlay();
	G = spawn(class'BigWheelsRules');
	G.BigWheelsMutator = self;

	if ( Level.Game.GameRulesModifiers == None )
		Level.Game.GameRulesModifiers = G;
	else    
		Level.Game.GameRulesModifiers.AddGameRules(G);
}	
	
function float GetWheelsScaleFor(PlayerReplicationInfo P)
{
	local float NewScale;
	
	if(P == None)
		return 1.0;

	if ( abs(P.Deaths) < 1 )
		NewScale = 0.4 * (P.Score + 1);
	else
		NewScale = 0.4 * ((P.Score+1)/(P.Deaths+1));

	return FClamp(NewScale, 1.0, 3.0);	
}

function bool CheckReplacement(Actor Other, out byte bSuperRelevant)
{
	local Vehicle V;

	V = Vehicle(Other);

	if(V != None && V.Driver != None)
		V.SetWheelsScale( GetWheelsScaleFor(V.PlayerReplicationInfo) );

	return true;
}

function DriverEnteredVehicle(Vehicle V, Pawn P)
{
	V.SetWheelsScale( GetWheelsScaleFor(V.PlayerReplicationInfo) );

	if ( NextMutator != None )
		NextMutator.DriverEnteredVehicle(V, P);
}

function DriverLeftVehicle(Vehicle V, Pawn P)
{
	V.SetWheelsScale(1.0);

	if ( NextMutator != None )
		NextMutator.DriverLeftVehicle(V, P);
}

defaultproperties
{
     GroupName="BigWheels"
     FriendlyName="BigWheels"
     Description="Vehicle wheel size depends on how well you are doing."
}
