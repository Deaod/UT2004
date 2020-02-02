class KRepulsor extends Actor
	native;

// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)

var()	bool	bEnableRepulsion;
var()   bool    bRepulseWater; // Repulsor should repulse against water volumes
var		bool	bRepulsorInContact; // Repulsor is currently contacting something.
var     bool    bRepulsorOnWater; //Repulsor is contacting water (bRepulseWater must be set)
var()	vector	CheckDir; // In owner ref frame
var()	float	CheckDist;
var()	float	Softness;
var()	float	PenScale;
var()	float	PenOffset;

// Used internally for Karma stuff - DO NOT CHANGE!
var		transient const pointer		KContact;

defaultproperties
{
     bEnableRepulsion=True
     CheckDir=(Z=-1.000000)
     CheckDist=50.000000
     Softness=0.100000
     PenScale=1.000000
     RemoteRole=ROLE_None
     bHardAttach=True
     bBlockZeroExtentTraces=False
     bBlockNonZeroExtentTraces=False
}
