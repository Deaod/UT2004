// ====================================================================
//  Class:  XGame.CrowdTrigger
//  Parent: Engine.Triggers
//
//  When triggered, tells a group of Crowd Pawns to play a given animation
// ====================================================================

class CrowdTrigger extends Triggers;

struct AnimParams
{
	var() name		SeqName;
	var() float		Rate;
	var() float		TweenTime;
	var() float		OffsetClamp;
};	

var(Crowd) export editinline array<AnimParams>	Anims;		// Info about what sequence to have the pawns play
var(Crowd) export float MaxDelay;

event Trigger( Actor Other, Pawn EventInstigator )
{

	local int i,max;
	local Intro_Crowd C;
	
	max = Anims.Length;
	
	if (max>0)
	{
		Foreach AllActors(class 'Intro_Crowd',c,event)
		{
			i = rand(max);
			C.MultiSetup(frand()*MaxDelay, Anims[i].SeqName, Anims[i].Rate, Anims[i].TweenTime, Anims[i].OffsetClamp);
		}
	}
}

defaultproperties
{
     bCollideActors=False
}
