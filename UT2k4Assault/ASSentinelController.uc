class ASSentinelController extends SentinelController;

var float	StartSearchTime;
var Rotator	LastRotation;

function AnimEnded();
function Awake();
function GoToSleep();


function rotator AdjustAim(FireProperties FiredAmmunition, vector projStart, int aimerror)
{
	if ( (FRand() < 0.45) && (Enemy != None) && (Enemy.Controller != None) )
		Enemy.Controller.ReceiveWarning(Pawn, -1, vector(Rotation)); 

    return Rotation;
}

auto state Sleeping
{
	event SeePlayer(Pawn SeenPlayer)
	{
		if ( IsTargetRelevant( SeenPlayer ) )
			Awake();
	}

	function Awake()
	{
		LastRotation = Rotation;
		if ( ASVehicle_Sentinel(Pawn).Awake() )
			GotoState('Opening');
	}

	function ScanRotation()
	{
		local actor HitActor;
		local vector HitLocation, HitNormal, Dir;
		local float BestDist, Dist;
		local rotator Pick;
		
		DesiredRotation.Yaw = Rotation.Yaw + 16384 + Rand(32768); 
		Dir = vector(DesiredRotation);
		
		// check new pitch not a blocked direction
		HitActor = Trace(HitLocation,HitNormal,Pawn.Location + 2000 * Dir,Pawn.Location,false);
		if ( HitActor == None )
			return;
		BestDist = vsize(HitLocation - Pawn.Location);
		Pick = DesiredRotation;
		
		DesiredRotation.Yaw += 32768;
		Dir = vector(DesiredRotation);
		// check new pitch not a blocked direction
		HitActor = Trace(HitLocation,HitNormal,Pawn.Location + 2000 * Dir,Pawn.Location,false);
		if ( HitActor == None )
			return;
		Dist = vsize(HitLocation - Pawn.Location);
		if ( Dist > BestDist )
		{
			BestDist = Dist;
			Pick = DesiredRotation;
		}
		
		DesiredRotation.Yaw += 16384;
		Dir = vector(DesiredRotation);
		// check new pitch not a blocked direction
		HitActor = Trace(HitLocation,HitNormal,Pawn.Location + 2000 * Dir,Pawn.Location,false);
		if ( HitActor == None )
			return;
		Dist = vsize(HitLocation - Pawn.Location);
		if ( Dist > BestDist )
		{
			BestDist = Dist;
			Pick = DesiredRotation;
		}

		DesiredRotation.Yaw += 32768;
		Dir = vector(DesiredRotation);
		// check new pitch not a blocked direction
		HitActor = Trace(HitLocation,HitNormal,Pawn.Location + 2000 * Dir,Pawn.Location,false);
		if ( HitActor == None )
			return;
		Dist = vsize(HitLocation - Pawn.Location);
		if ( Dist > BestDist )
		{
			BestDist = Dist;
			Pick = DesiredRotation;
		}
		
		DesiredRotation = Pick;
	}	

Begin:
	if ( IsSpawnCampProtecting() )	// spawn camp protection turrets should never sleep...
	{
		AcquisitionYawRate *= 100;
		Pawn.PeripheralVision = -1.0; // Full circle vision :)
		Awake();
	}
	ScanRotation();	
	FocalPoint = Pawn.Location + 1000 * vector(DesiredRotation);
	Sleep(2 + 3*FRand());
	Goto('Begin');
}

state Opening
{
	event SeePlayer(Pawn SeenPlayer);

	function AnimEnded()
	{
		GotoState('Searching');
	}
}

state Closing
{
	event SeePlayer(Pawn SeenPlayer);

	function AnimEnded()
	{
		GotoState('Sleeping');
	}

Begin:
	DesiredRotation			= Rotation;
	DesiredRotation.Pitch	= 0;
	FocalPoint = Pawn.Location + 1000 * vector(DesiredRotation);
	Sleep( 0.5 );
	ASVehicle_Sentinel(Pawn).GoToSleep();
}


state Searching
{
	function BeginState()
	{
		super.BeginState();
		StartSearchTime = Level.TimeSeconds;
	}

	function GoToSleep()
	{
		GotoState('Closing');
	}

Begin:
	if ( !IsSpawnCampProtecting() && (Level.TimeSeconds > StartSearchTime + 10) )
		GoToSleep();
	else
	{
		ScanRotation();	
		FocalPoint = Pawn.Location + 1000 * vector(DesiredRotation);
		Sleep( GetScanDelay() );
		Goto('Begin');
	}
}

function bool IsSpawnCampProtecting()
{
	return ( ASVehicle_Sentinel(Pawn) != None && ASVehicle_Sentinel(Pawn).bSpawnCampProtection );
}

function float GetScanDelay()
{
	if ( IsSpawnCampProtecting() )	// more aggressive scanning if spawn protecting
		return 2;

	return ( 2 + 3*FRand() );
}

function float GetWaitForTargetTime()
{
	if ( IsSpawnCampProtecting() )	// more aggressive scanning if spawn protecting
		return 2;

	return super.GetWaitForTargetTime();
}

function Possess(Pawn aPawn)
{
	super.Possess( aPawn );

	if ( IsSpawnCampProtecting() )	// kill on sight
	{
		Skill = 10;
		FocusLead = 0;
	}
}

defaultproperties
{
}
