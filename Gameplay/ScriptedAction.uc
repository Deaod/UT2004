class ScriptedAction extends Object
		abstract
		hidecategories(Object)
		collapsecategories
		editinlinenew;

var localized string ActionString;
var bool bValidForTrigger;

event ActionCompleted();						// Called when Action is complete
event PostBeginPlay( ScriptedSequence SS );		// Called when level starts
event Reset();									// Called when level resets

function bool InitActionFor(ScriptedController C)
{
	return false;
}

function bool EndsSection()
{
	return false;
}

function bool StartsSection()
{
	return false;
}

function ScriptedSequence GetScript(ScriptedSequence S)
{
	return S;
}

function ProceedToNextAction(ScriptedController C)
{
	C.ActionNum += 1;
}

function ProceedToSectionEnd(ScriptedController C)
{
	local int Nesting;
	local ScriptedAction A;

	While ( C.ActionNum < C.SequenceScript.Actions.Length )
	{
		A = C.SequenceScript.Actions[C.ActionNum];
		if ( A.StartsSection() )
			Nesting++;
		else if ( A.EndsSection() )
		{
			Nesting--;
			if ( Nesting < 0 )
				return;
		}
		C.ActionNum += 1;
	}
}

function string GetActionString()
{
	return ActionString;
}

defaultproperties
{
     ActionString="unspecified action"
     bValidForTrigger=True
}
