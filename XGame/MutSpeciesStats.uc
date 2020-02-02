//=============================================================================
// MutSpeciesStats - species specific stats for players
//=============================================================================
class MutSpeciesStats extends Mutator;

function PostBeginPlay()
{
	local GameRules G;
	
	Super.PostBeginPlay();
	G = spawn(class'SpeciesGameRules');
	if ( Level.Game.GameRulesModifiers == None )
		Level.Game.GameRulesModifiers = G;
	else    
		Level.Game.GameRulesModifiers.AddGameRules(G);
}

function ModifyPlayer(Pawn Other)
{
    local xPawn xp;

    Super.ModifyPlayer(Other);
    
    xp = xPawn(Other);
    if(xp == None)
        return;
    xp.Species.static.ModifyPawn(xp);
}

defaultproperties
{
     GroupName="Species"
     FriendlyName="Species Statistics"
     Description="Each race has unique combat statistics."
}
