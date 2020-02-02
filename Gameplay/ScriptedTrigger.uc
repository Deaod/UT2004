//=============================================================================
// ScriptedTrigger
// replaces Counter, Dispatcher, SpecialEventTrigger
//=============================================================================
class ScriptedTrigger extends ScriptedSequence;

#exec Texture Import File=..\engine\textures\TrigSpcl.pcx Name=S_SpecialEvent Mips=Off MASKED=1

var ScriptedTriggerController TriggerController;

function PostBeginPlay()
{
	super.PostBeginPlay();
	
	TriggerController = Spawn(class'ScriptedTriggerController');
	if ( TriggerController != None )
		TriggerController.InitializeFor( Self );
	else
		log("ScriptedTrigger::PostBeginPlay - Couldn't Spawn ScriptedTriggerController");
}


/* WaitingForEvent()
Returns next event this scripted sequence is waiting for with an ACTION_WaitFOrEvent
*/
function name NextNeededEvent()
{
	local int i, Start;
	
	if ( TriggerController != None )
		Start = TriggerController.ActionNum;
		
	for ( i=Start; i<Actions.Length; i++ )
		if ( ACTION_WaitForEvent(Actions[i]) != None )
			return ACTION_WaitForEvent(Actions[i]).ExternalEvent;
			
	return '';
}

/* TriggersEvent()
returns true if this sequence triggers Event E
*/
function  bool TriggersEvent(name E)
{
	local int i, Start;
	
	if ( TriggerController != None )
		Start = TriggerController.ActionNum;

	for ( i=Start; i<Actions.Length; i++ )
		if ( (ACTION_TriggerEvent(Actions[i]) != None)
			&& (ACTION_TriggerEvent(Actions[i]).Event == E) )
			return true;
			
	return false;
}

function bool ValidAction(Int N)
{
	return Actions[N].bValidForTrigger;
}

/* Reset() 
reset actor to initial state - used when restarting level without reloading.
*/
function Reset()
{
	super.Reset();
	
	if ( TriggerController == None )
		TriggerController = Spawn(class'ScriptedTriggerController');

	if ( TriggerController != None )
		TriggerController.InitializeFor( Self );
}

defaultproperties
{
     bNavigate=False
     Texture=Texture'Gameplay.S_SpecialEvent'
}
