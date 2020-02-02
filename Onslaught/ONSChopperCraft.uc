class ONSChopperCraft extends ONSVehicle
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
var		float				CopterMPH;

var		float				TargetHeading;
var		float				TargetPitch;
var     bool                bHeadingInitialized;

var		float				OutputThrust;
var		float				OutputStrafe;
var		float				OutputRise;

var     vector              RandForce;
var     vector              RandTorque;
var     float               AccumulatedTime;

// Replicated
struct native CopterState
{
	var vector				ChassisPosition;
	var Quat				ChassisQuaternion;
	var vector				ChassisLinVel;
	var vector				ChassisAngVel;

	var byte				ServerThrust;
	var	byte				ServerStrafe;
	var	byte				ServerRise;
	var int                 ServerViewPitch;
	var int                 ServerViewYaw;
};

var		CopterState			CopState, OldCopState;
var		KRigidBodyState		ChassisState;
var		bool				bNewCopterState;

var float PushForce;	// for AI when landing;
var float LastJumpOutCheck;

replication
{
	reliable if ( Role == ROLE_Authority )
		CopState;
}

simulated event bool KUpdateState(out KRigidBodyState newState)
{
	// This should never get called on the server - but just in case!
	if(Role == ROLE_Authority || !bNewCopterState)
		return false;

	newState = ChassisState;
	bNewCopterState = false;

	return true;
	//return false;
}

simulated event SVehicleUpdateParams()
{
	Super.SVehicleUpdateParams();

	KSetStayUprightParams( UprightStiffness, UprightDamping );
}

simulated function SpecialCalcFirstPersonView(PlayerController PC, out actor ViewActor, out vector CameraLocation, out rotator CameraRotation )
{
	ViewActor = self;

	CameraLocation = Location + (FPCamPos >> Rotation);
}

event JumpOutCheck()
{
	local Bot B;

	B = Bot(Controller);
	if ( (B != None) && (ONSPowerCore(B.Movetarget) != None) && (ONSPowerCore(B.MoveTarget).CoreStage == 4) && ((B.Enemy == None) || !B.EnemyVisible()) )
	{
		KDriverLeave(false);
		if ( Controller == None )
		{
			KAddImpulse( PushForce*Vector(Rotation), Location );
			if ( (B.Pawn.Physics == PHYS_Falling) && B.DoWaitForLanding() )
				B.Pawn.Velocity.Z = 0;
		}
	}
}

defaultproperties
{
     PushForce=100000.000000
     bFollowLookDir=True
     bPCRelativeFPRotation=False
     bCanFly=True
     bCanStrafe=True
     bCanBeBaseForPawns=False
     GroundSpeed=1200.000000
}
