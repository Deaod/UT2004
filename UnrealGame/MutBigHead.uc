class MutBigHead extends Mutator;

function PostBeginPlay()
{
	local BigHeadRules G;
	
	Super.PostBeginPlay();
	G = spawn(class'BigHeadRules');
	G.BigHeadMutator = self;
	if ( Level.Game.GameRulesModifiers == None )
		Level.Game.GameRulesModifiers = G;
	else    
		Level.Game.GameRulesModifiers.AddGameRules(G);
}	
	
function float GetHeadScaleFor(Pawn P)
{
	local float NewScale;
	
	if ( abs(P.PlayerReplicationInfo.Deaths) < 1 )
		NewScale = P.PlayerReplicationInfo.Score + 1;
	else
		NewScale = (P.PlayerReplicationInfo.Score+1)/(P.PlayerReplicationInfo.Deaths+1);
	return FClamp(NewScale, 0.5, 4.0);	
}

function ModifyPlayer(Pawn Other)
{
	Other.SetHeadScale(GetHeadScaleFor(Other));

	if ( NextMutator != None )
		NextMutator.ModifyPlayer(Other);
}

defaultproperties
{
     GroupName="BigHead"
     FriendlyName="BigHead"
     Description="Head size depends on how well you are doing."
}
