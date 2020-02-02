//=============================================================================
// SVehicleTrigger
//=============================================================================
// General trigger to possess vehicles
// This trigger is automatically spawned by the vehicle and cannot be placed
// in levels.
//=============================================================================

class SVehicleTrigger extends Triggers
	notplaceable
	native;

var()	bool	bEnabled;
var		bool	BACKUP_bEnabled; // Backup
var		bool	bMarkWithPath;

var NavigationPoint myMarker;

// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)

function PostBeginPlay()
{
	super.PostBeginPlay();

	BACKUP_bEnabled = bEnabled;
}

event Trigger( Actor Other, Pawn EventInstigator )
{
	bEnabled = !bEnabled;
}

function UsedBy( Pawn user )
{
	if ( !bEnabled )
		return;

	Vehicle(Owner).TryToDrive( User );
}

/* Reset()
reset actor to initial state - used when restarting level without reloading.
*/
function Reset()
{
	super.Reset();

	bEnabled = BACKUP_bEnabled;
}

//=============================================================================
// defaultproperties
//=============================================================================

defaultproperties
{
     bEnabled=True
     bOnlyAffectPawns=True
     bHardAttach=True
     CollisionRadius=80.000000
     CollisionHeight=400.000000
     bCollideActors=False
}
