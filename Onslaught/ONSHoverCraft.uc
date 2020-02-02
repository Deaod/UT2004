//-----------------------------------------------------------
//
//-----------------------------------------------------------
class ONSHoverCraft extends ONSVehicle
	abstract
	native
	nativereplication;

// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)

var()	array<vector>		ThrusterOffsets;
var()	float				HoverSoftness;
var()	float				HoverPenScale;
var()	float				HoverCheckDist;

var()	float				UprightStiffness;
var()	float				UprightDamping;

var()	float				MaxThrustForce;
var()	float				LongDamping;

var()	float				MaxStrafeForce;
var()	float				LatDamping;

var()	float				MaxRiseForce;
var()	float				UpDamping;

var()	float				TurnTorqueFactor;
var()	float				TurnTorqueMax;
var()	float				TurnDamping;
var()	float				MaxYawRate;

var()	float				PitchTorqueFactor;
var()	float				PitchTorqueMax;
var()	float				PitchDamping;

var()	float				RollTorqueTurnFactor;
var()	float				RollTorqueStrafeFactor;
var()	float				RollTorqueMax;
var()	float				RollDamping;

var()	float				StopThreshold;

var()   float               MaxRandForce;
var()   float               RandForceInterval;

// Internal
var		float				HoverMPH;

var		float				TargetHeading;
var		float				TargetPitch;
var     bool                bHeadingInitialized;

var		float				OutputThrust;
var		float				OutputStrafe;

var     Pawn                OldDriver;

// Replicated
struct native HoverCraftState
{
	var vector				ChassisPosition;
	var Quat				ChassisQuaternion;
	var vector				ChassisLinVel;
	var vector				ChassisAngVel;

	var byte				ServerThrust;
	var	byte				ServerStrafe;
	var int                 ServerViewPitch;
	var int                 ServerViewYaw;
};

var		HoverCraftState		HoverState, OldHoverState;
var		KRigidBodyState		ChassisState;
var		bool				bNewHoverState;

replication
{
	reliable if ( Role == ROLE_Authority )
		HoverState;
}

simulated event bool KUpdateState(out KRigidBodyState newState)
{
	// This should never get called on the server - but just in case!
	if(Role == ROLE_Authority || !bNewHoverState)
		return false;

	newState = ChassisState;
	bNewHoverState = false;

	return true;
	//return false;
}

simulated function PostNetBeginPlay()
{
	local vector RotX, RotY, RotZ;
	local KarmaParams kp;
	local KRepulsor rep;
	local int i;

    GetAxes(Rotation,RotX,RotY,RotZ);

	// Spawn and assign 'repulsors' to hold bike off the ground
	kp = KarmaParams(KParams);
	kp.Repulsors.Length = ThrusterOffsets.Length;

	for(i=0;i<ThrusterOffsets.Length;i++)
	{
    	rep = spawn(class'KRepulsor', self,, Location + ThrusterOffsets[i].X * RotX + ThrusterOffsets[i].Y * RotY + ThrusterOffsets[i].Z * RotZ);
    	rep.SetBase(self);
    	rep.bHidden = True;
    	rep.bRepulseWater = True;
    	kp.Repulsors[i] = rep;
    }

    Super.PostNetBeginPlay();
}

function Died(Controller Killer, class<DamageType> damageType, vector HitLocation)
{
	local KarmaParams kp;
	local int i;

	// Destroy repulsors
	kp = KarmaParams(KParams);
	for(i=0;i<kp.Repulsors.Length;i++)
    	kp.Repulsors[i].Destroy();

    kp.Repulsors.Length = 0;

	Super.Died(Killer, damageType, HitLocation);
}

simulated event SVehicleUpdateParams()
{
	local KarmaParams kp;
	local int i;

	Super.SVehicleUpdateParams();

	kp = KarmaParams(KParams);

    for(i=0;i<kp.Repulsors.Length;i++)
	{
        kp.Repulsors[i].CheckDist = HoverCheckDist;
        kp.Repulsors[i].PenScale = HoverPenScale;
        kp.Repulsors[i].Softness = HoverSoftness;
    }

	KSetStayUprightParams( UprightStiffness, UprightDamping );
}

simulated function SpecialCalcFirstPersonView(PlayerController PC, out actor ViewActor, out vector CameraLocation, out rotator CameraRotation )
{
	ViewActor = self;

	CameraLocation = Location + (FPCamPos >> Rotation);
}

defaultproperties
{
     bFollowLookDir=True
     bCanHover=True
     bPCRelativeFPRotation=False
}
