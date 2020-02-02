//=============================================================================
// MutRegen - regenerates players
//=============================================================================
class MutRegen extends Mutator;

#exec OBJ LOAD File=MutatorArt.utx

var() float RegenPerSecond;

// Don't call Actor PreBeginPlay() for Mutator 
event PreBeginPlay()
{
    SetTimer(1.0,true);
}

function Timer()
{
    local Controller C;

    for (C = Level.ControllerList; C != None; C = C.NextController)
    {
		if (C.Pawn != None && C.Pawn.Health < C.Pawn.HealthMax )
        {
            C.Pawn.Health = Min( C.Pawn.Health+RegenPerSecond, C.Pawn.HealthMax );
        }
    }
}

defaultproperties
{
     RegenPerSecond=5.000000
     GroupName="Regen"
     FriendlyName="Regeneration"
     Description="All players regenerate health."
}
