//=============================================================================
// ReachSpec.
//
// A Reachspec describes the reachability requirements between two NavigationPoints
//
//=============================================================================
class ReachSpec extends Object
	native;

/*
enum EReachSpecFlags
{
	R_WALK = 1,	//walking required
	R_FLY = 2,   //flying required 
	R_SWIM = 4,  //swimming required
	R_JUMP = 8,   // jumping required
	R_DOOR = 16,
	R_SPECIAL = 32,
	R_LADDER = 64,
	R_PROSCRIBED = 128,
	R_FORCED = 256,
	R_PLAYERONLY = 512
}; 
*/
var	int		Distance; 
var	const NavigationPoint	Start;		// navigationpoint at start of this path
var	const NavigationPoint	End;		// navigationpoint at endpoint of this path (next waypoint or goal)
var	int		CollisionRadius; 
var	int		CollisionHeight; 
var	int		reachFlags;			// see EReachSpecFlags definition in UnPath.h
var	int		MaxLandingVelocity;
var	byte	bPruned;
var	bool	bForced;

defaultproperties
{
}
