//=============================================================================
// NavigationPoint.
//
// NavigationPoints are organized into a network to provide AIControllers 
// the capability of determining paths to arbitrary destinations in a level
//
//=============================================================================
class NavigationPoint extends Actor
	hidecategories(Lighting,LightColor,Karma,Force)
	native;

#exec Texture Import File=Textures\S_Pickup.pcx Name=S_Pickup Mips=Off MASKED=1
#exec Texture Import File=Textures\SpwnAI.pcx Name=S_NavP Mips=Off MASKED=1

// not used currently
#exec Texture Import File=Textures\SiteLite.pcx Name=S_Alarm Mips=Off MASKED=1

//------------------------------------------------------------------------------
// NavigationPoint variables

var transient bool bEndPoint;		// used by C++ navigation code
var transient bool bTransientEndPoint; // set right before a path finding attempt, cleared afterward.
var transient bool bHideEditorPaths;	// don't show paths to this node in the editor
var transient bool bCanReach;		// used during paths review in editor

var bool taken;					// set when a creature is occupying this spot
var() bool bBlocked;			// this path is currently unuseable 
var() bool bPropagatesSound;	// this navigation point can be used for sound propagation (around corners)
var() bool bOneWayPath;			// reachspecs from this path only in the direction the path is facing (180 degrees)
var() bool bNeverUseStrafing;	// shouldn't use bAdvancedTactics going to this point
var() bool bAlwaysUseStrafing;	// shouldn't use bAdvancedTactics going to this point
var const bool bForceNoStrafing;// override any LD changes to bNeverUseStrafing
var const bool bAutoBuilt;		// placed during execution of "PATHS BUILD"
var	bool bSpecialMove;			// if true, pawn will call SuggestMovePreparation() when moving toward this node
var bool bNoAutoConnect;		// don't connect this path to others except with special conditions (used by LiftCenter, for example)
var	const bool	bNotBased;		// used by path builder - if true, no error reported if node doesn't have a valid base
var const bool  bPathsChanged;	// used for incremental path rebuilding in the editor
var bool		bDestinationOnly; // used by path building - means no automatically generated paths are sourced from this node
var	bool		bSourceOnly;	// used by path building - means this node is not the destination of any automatically generated path
var bool		bSpecialForced;	// paths that are forced should call the SpecialCost() and SuggestMovePreparation() functions
var bool		bMustBeReachable;	// used for PathReview code
var bool		bBlockable;		// true if path can become blocked (used by pruning during path building)
var	bool		bFlyingPreferred;	// preferred by flying creatures
var bool		bMayCausePain;		// set in C++ if in PhysicsVolume that may cause pain
var bool	bReceivePlayerToucherDiedNotify;
var bool bAlreadyVisited;	// internal use
var() bool 	bVehicleDestination;	// if true, forced paths to this node will have max width to accomodate vehicles
var() bool bMakeSourceOnly;
var() bool	bNoSuperSize;			// hack for Leviathans, which pretend to be smaller than they really are to use the path network - this forces them not to use a path
var	bool	bForcedOnly;			// only connect forced paths to this NavigationPoint

var const array<ReachSpec> PathList; //index of reachspecs (used by C++ Navigation code)
var() name ProscribedPaths[4];	// list of names of NavigationPoints which should never be connected from this path
var() name ForcedPaths[4];		// list of names of NavigationPoints which should always be connected from this path
var int visitedWeight;
var const int bestPathWeight;
var const NavigationPoint nextNavigationPoint;
var const NavigationPoint nextOrdered;	// for internal use during route searches
var const NavigationPoint prevOrdered;	// for internal use during route searches
var const NavigationPoint previousPath;
var int cost;					// added cost to visit this pathnode
var() int ExtraCost;			// Extra weight added by level designer
var transient int TransientCost;	// added right before a path finding attempt, cleared afterward.
var	transient int FearCost;		// extra weight diminishing over time (used for example, to mark path where bot died)

var Pickup	InventoryCache;		// used to point to dropped weapons
var float	InventoryDist;
var const float LastDetourWeight;

var byte BaseVisible[2];		// used by some team game types- whether this point is visible from red base or defense points
var float BaseDist[2];			// used by some team game types - distance to red base

var vector MaxPathSize;

function PostBeginPlay()
{
	local int i;
	
	ExtraCost = Max(ExtraCost,0);
	
	for ( i=0; i<PathList.Length; i++ )
	{
		MaxPathSize.X = FMax(MaxPathSize.X, PathList[i].CollisionRadius);
		MaxPathSize.Z = FMax(MaxPathSize.Z, PathList[i].CollisionHeight);
	}
	MaxPathSize.Y = MaxPathSize.X;
	Super.PostBeginPlay();
}

native final function SetBaseDistance(int BaseNum);

function SetBaseVisibility(int BaseNum)
{
	local NavigationPoint N;
	
	BaseVisible[BaseNum] = 1;
	for ( N=Level.NavigationPointList; N!=None; N=N.NextNavigationPoint )
		if ( (N.BaseVisible[BaseNum] == 0) && FastTrace(N.Location + (88 - 2*N.CollisionHeight)*Vect(0,0,1), Location + (88 - 2*N.CollisionHeight)*Vect(0,0,1)) )
			N.BaseVisible[BaseNum] = 1;
}

event int SpecialCost(Pawn Seeker, ReachSpec Path);

// Accept an actor that has teleported in.
// used for random spawning and initial placement of creatures
event bool Accept( actor Incoming, actor Source )
{
	// Move the actor here.
	taken = Incoming.SetLocation( Location );
	if (taken)
	{
		Incoming.Velocity = vect(0,0,0);
		Incoming.SetRotation(Rotation);
	}
	Incoming.PlayTeleportEffect(true, false);
	TriggerEvent(Event, self, Pawn(Incoming));
	return taken;
}

/* DetourWeight()
value of this path to take a quick detour (usually 0, used when on route to distant objective, but want to grab inventory for example)
*/
event float DetourWeight(Pawn Other,float PathWeight);
 
/* SuggestMovePreparation()
Optionally tell Pawn any special instructions to prepare for moving to this goal
(called by Pawn.PrepareForMove() if this node's bSpecialMove==true
*/
event bool SuggestMovePreparation(Pawn Other)
{
	return false;
}

/* ProceedWithMove()
Called by Controller to see if move is now possible when a mover reports to the waiting
pawn that it has completed its move
*/
function bool ProceedWithMove(Pawn Other)
{
	return true;
}

/* MoverOpened() & MoverClosed() used by NavigationPoints associated with movers */
function MoverOpened();
function MoverClosed();

/* needed for HoldObjectives */
function PlayerToucherDied( Pawn P );

defaultproperties
{
     bPropagatesSound=True
     bMayCausePain=True
     BaseDist(0)=1000000.000000
     BaseDist(1)=1000000.000000
     bStatic=True
     bHidden=True
     bNoDelete=True
     Texture=Texture'Engine.S_NavP'
     bCollideWhenPlacing=True
     SoundVolume=0
     CollisionRadius=40.000000
     CollisionHeight=43.000000
}
