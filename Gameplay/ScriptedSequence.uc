//=============================================================================
// ScriptedSequence
// used for setting up scripted sequences for pawns.
// A ScriptedController is spawned to carry out the scripted sequence.
//=============================================================================
class ScriptedSequence extends AIScript;

var(AIScript) export editinline Array<ScriptedAction> Actions;
var class<ScriptedController>  ScriptControllerClass;

function PostBeginPlay()
{
	local int i;

	super.PostBeginPlay();

	for ( i=0; i<Actions.Length; i++ )
		if ( Actions[i] != None )
			Actions[i].PostBeginPlay( Self );
}


event Reset()
{
	local int i;

	super.Reset();
	
	for ( i=0; i<Actions.Length; i++ )
		if ( Actions[i] != None )
			Actions[i].Reset();
}

/* SpawnController()
Spawn and initialize an AI Controller (called by a non-player controlled Pawn at level startup)
*/
function SpawnControllerFor(Pawn P)
{
	Super.SpawnControllerFor(P);
	TakeOver(P);
}

function bool CheckForErrors()
{
	if ( Actions.Length > 0 )
	{
		log(self$" has no Actions!");
		return true;
	}
	return Super.CheckForErrors();
}

/* TakeOver()
Spawn a scripted controller, which temporarily takes over the actions of the pawn,
unless pawn is currently controlled by a scripted controller - then just change its script
*/
function TakeOver(Pawn P)
{
	local ScriptedController S;

	if ( ScriptedController(P.Controller) != None )
		S = ScriptedController(P.Controller);
	else
	{
		S = spawn(ScriptControllerClass);
		S.PendingController = P.Controller;
		if ( S.PendingController != None )
			S.PendingController.PendingStasis();
	}
	S.MyScript = self;
	S.TakeControlOf(P);
	S.SetNewScript(self);
}
		
//*****************************************************************************************
// Script Changes

function bool ValidAction(Int N)
{
	return true;
}

function SetActions(ScriptedController C)
{
	local ScriptedSequence NewScript;
	local bool bDone;

	if ( C.CurrentAnimation != None )
		C.CurrentAnimation.SetCurrentAnimationFor(C);
	while ( !bDone )
	{
		if ( C.ActionNum < Actions.Length )
		{
			if ( ValidAction(C.ActionNum) )
				NewScript = Actions[C.ActionNum].GetScript(self);
			else
			{
				NewScript = None;
				warn(GetItemName(string(self))$" action "$C.ActionNum@Actions[C.ActionNum].GetActionString()$" NOT VALID!!!");
			}
		}
		else 
			NewScript = None;
		if ( NewScript == None )
		{
			C.CurrentAction = None;
			return;
		}
		if ( NewScript != self )
		{
			C.SetNewScript(NewScript);
			return;
		}
		if ( Actions[C.ActionNum] == None )
		{
			Warn(self$" no action "$C.ActionNum$"!!!");
			C.CurrentAction = None;
			return;
		}
		bDone = Actions[C.ActionNum].InitActionFor(C);
		if ( bLoggingEnabled )
			log(GetItemName(string(C.Pawn))$" script "$GetItemName(string(tag))$" action "$C.ActionNum@Actions[C.ActionNum].GetActionString());
		if  ( !bDone )
		{
			if ( Actions[C.ActionNum] == None )
			{
				Warn(self$" has no action "$C.ActionNum$"!!!");
				C.CurrentAction = None;
				return;
			}
			Actions[C.ActionNum].ActionCompleted();
			Actions[C.ActionNum].ProceedToNextAction(C);
		}
	}
}

defaultproperties
{
     ScriptControllerClass=Class'Gameplay.ScriptedController'
     bNavigate=True
     bCollideWhenPlacing=True
     CollisionRadius=50.000000
     CollisionHeight=100.000000
     bDirectional=True
}
