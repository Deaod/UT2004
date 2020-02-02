// Used for weapons page

class SpinnyWeap extends Actor;

var() int SpinRate;

var()	bool			bPlayRandomAnims;
var()   bool            bPlayCrouches;
var()	float			AnimChangeInterval;
var()	array<name>		AnimNames;

var		float			CurrentTime;
var		float			NextAnimTime;

simulated event PostBeginPlay()
{
	local int i;

	if ( !bPlayCrouches )
	{
		for ( i = AnimNames.Length - 1; i >= 0; i++ )
		{
			if ( AnimNames[i] == 'Crouch' )
				AnimNames.Remove(i,1);
		}
	}
}

function Tick(float Delta)
{
	local rotator NewRot;

	NewRot = Rotation;
	NewRot.Yaw += Delta * SpinRate/Level.TimeDilation;
	SetRotation(NewRot);

	CurrentTime += Delta/Level.TimeDilation;

	// If desired, play some random animations
	if(bPlayRandomAnims && CurrentTime >= NextAnimTime)
	{
		PlayNextAnim();
	}
}

event AnimEnd( int Channel )
{
	Super.AnimEnd(Channel);
	PlayAnim(AnimNames[0], 1.0/Level.TimeDilation, 0.25/Level.TimeDilation);
}

function PlayNextAnim()
{
	local name NewAnimName;

	if(Mesh == None || AnimNames.Length == 0)
		return;

	NewAnimName = AnimNames[Rand(AnimNames.Length)];
	while ( NewAnimName == 'Crouch' && !bPlayCrouches )
		NewAnimName = AnimNames[Rand(AnimNames.Length)];

	PlayAnim(NewAnimName, 1.0/Level.TimeDilation, 0.25/Level.TimeDilation);

	NextAnimTime = CurrentTime + AnimChangeInterval;
}

defaultproperties
{
     spinRate=20000
     bPlayCrouches=True
     AnimChangeInterval=3.000000
     AnimNames(0)="Idle_Rest"
     AnimNames(1)="Crouch"
     AnimNames(2)="AssSmack"
     AnimNames(3)="PThrust"
     AnimNames(4)="ThroatCut"
     AnimNames(5)="gesture_halt"
     AnimNames(6)="gesture_point"
     AnimNames(7)="gesture_beckon"
     DrawType=DT_StaticMesh
     RemoteRole=ROLE_None
     LODBias=100000.000000
     DrawScale=0.500000
     bUnlit=True
     bAlwaysTick=True
}
