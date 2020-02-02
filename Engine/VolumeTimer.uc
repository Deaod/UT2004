class VolumeTimer extends info;

var Actor	A;
var float	TimerFrequency;

function PostBeginPlay()
{
	super.PostBeginPlay();
	
	SetTimer(1.0, false);
	A = Owner;
}

function Timer()
{
	A.TimerPop( Self );
	SetTimer(TimerFrequency, false);
}

defaultproperties
{
     TimerFrequency=1.000000
}
