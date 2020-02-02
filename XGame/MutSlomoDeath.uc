//=============================================================================
// SlomoDeath - slows down the ragdoll simulation!
//=============================================================================
class MutSlomoDeath extends Mutator;

function PostBeginPlay()
{
	// Change the overall speed at which karma is evolved for in the level.
	Level.RagdollTimeScale = 0.3;
}

function ModifyPlayer(Pawn Other)
{
	local xPawn x;
	x = xPawn(Other);

	if(x != None)
	{
		// Increase the amount of time that ragdolls hang around for as well...
		x.RagdollLifeSpan = 18;
	}

	Super.ModifyPlayer(Other);
}

defaultproperties
{
     GroupName="CorpseTimeScale"
     FriendlyName="Slow Motion Corpses"
     Description="Death should not be rushed."
}
