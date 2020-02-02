//=============================================================================
// The Karma Collision parameters class.
// This provides 'extra' parameters needed to create Karma collision for this Actor.
// You can _only_ turn on collision, not dynamics.
// NB: All parameters are in KARMA scale!
//=============================================================================

class KarmaParamsCollision extends Object
	editinlinenew
	native;

// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)

// Used internally for Karma stuff - DO NOT CHANGE!
var const transient pointer				KarmaData;

var const float				KScale;  // Usually kept in sync with actor's DrawScale, this is how much to scale moi/com-offset (but not mass!)
var const vector			KScale3D;

var      vector  KAcceleration;      // Instantaneous acceleration.

var()    float   KFriction;          // Multiplied pairwise to get contact friction
var()    float   KRestitution;       // 'Bouncy-ness' - Normally between 0 and 1. Multiplied pairwise to get contact restitution.
var()    float   KImpactThreshold;   // threshold velocity magnitude to call KImpact event

var	  const bool bContactingLevel;	 // This actor currently has contacts with some level geometry (bsp, static mesh etc.). OUTPUT VARIABLE.

// OUTPUT. The 'contact region' below refers to collision against the world, not between dynamics bodies. Use CalcContactRegion to update.
var		 const vector	 ContactRegionCenter;
var		 const vector  ContactRegionNormal;
var		 const float	 ContactRegionRadius;
var		 const float	 ContactRegionNormalForce;

native function CalcContactRegion(); // Fills in ContactRegion variables above. Will do nothing if bContactingLevel is false.

// default is sphere with mass 1 and radius 1

defaultproperties
{
     KScale=1.000000
     KScale3D=(X=1.000000,Y=1.000000,Z=1.000000)
     KImpactThreshold=1000000.000000
}
