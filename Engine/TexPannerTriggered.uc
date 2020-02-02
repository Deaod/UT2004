class TexPannerTriggered extends TexPanner
	native;

// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
var() TexOscillatorTriggered.ERetriggerAction RetriggerAction;
var() float StopAfterPeriod;
var transient float TriggeredTime;
var transient bool Reverse;
var transient bool Triggered;

function Trigger( Actor Other, Actor EventInstigator )
{
	if( Triggered )
	{
		switch( RetriggerAction )
		{
		case RTA_Reverse:
			Triggered = False;
			TriggeredTime = Other.Level.TimeSeconds;
			Reverse = True;
			break;
		case RTA_Reset:
			Triggered = False;
			TriggeredTime = -1.0;
			Reverse = True;
			break;
		}		
	}
	else
	{
		if( RetriggerAction != RTA_Retrigger )
			Triggered = True;
		TriggeredTime = Other.Level.TimeSeconds;
		Reverse = False;
	}
}

function Reset()
{
	Triggered = False;
	TriggeredTime = -1.0;
	Reverse = False;
}

defaultproperties
{
     RetriggerAction=RTA_Retrigger
     StopAfterPeriod=0.500000
}
