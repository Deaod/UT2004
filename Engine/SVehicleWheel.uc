class SVehicleWheel extends Object
	native;

// INPUT
var()					float	Steer; // degrees

var()					float	DriveForce; // resultant linear driving force at wheel center
var()					float	LongFriction; // maximum linear longitudinal (roll) friction force
var()					float	LatFriction; // maximum linear longitudinal (roll) friction force
var()					float	LongSlip;
var()					float	LatSlip;
var()					float	ChassisTorque; // Torque applied back to the chassis (equal-and-opposite) from this wheel.

// PARAMS
var()					bool	bPoweredWheel;
var()					bool	bHandbrakeWheel;
var()                   bool    bTrackWheel;
var()                   bool    bLeftTrack;
var()					enum	EVehicleSteerType
{
	VST_Fixed,
	VST_Steered,
	VST_Inverted
} SteerType; // How steering affects this wheel.

var()					name	BoneName;
var()					EAxis	BoneRollAxis; // Local axis to rotate the wheel around for normal rolling movement.
var()					EAxis	BoneSteerAxis; // Local axis to rotate the wheel around for steering.
var()					vector	BoneOffset; // Offset from wheel bone to line check point (middle of tyre). NB: Not affected by scale.
var()					float	WheelRadius; // Length of line check. Usually 2x wheel radius.

var()					float	Softness;
var()					float	PenScale;
var()					float	PenOffset;
var()					float	Restitution;
var()					float	Adhesion;
var()					float	WheelInertia;
var()					float	SuspensionTravel;
var()					float   SuspensionOffset;
var()					float	HandbrakeSlipFactor;
var()					float	HandbrakeFrictionFactor;
var()					float	SuspensionMaxRenderTravel;

var()					name	SupportBoneName; // Name of strut etc. that will be rotated around local X as wheel goes up and down.
var()					EAxis	SupportBoneAxis; // Local axis to rotate support bone around.

// Approximations to Pacejka's Magic Formula
var()					InterpCurve		LongFrictionFunc; // Function of SlipVel
var()					InterpCurve		LatSlipFunc; // Function of SpinVel

// OUTPUT

// Calculated on startup
var						vector	WheelPosition; // Wheel center in actor ref frame. Calculated using BoneOffset above.
var						float	SupportPivotDistance; // If a SupportBoneName is specified, this is the distance used to calculate the anglular displacement.

// Calculated each frame
var						bool	bWheelOnGround;
var						float	TireLoad; // Load on tire
var						vector	WheelDir; // Wheel 'forward' in world ref frame. Unit length.
var						vector	WheelAxle; // Wheel axle in world ref frame. Unit length.

var						float	SpinVel; // Radians per sec
var						float	TrackVel; // Radians per sec

var						float   SlipAngle; // Angle between wheel facing direction and wheel travelling direction. In degrees.

var						float	SlipVel;   // Difference in linear velocity between ground and wheel at contact.

var						float	SuspensionPosition; // Output position of
var						float	CurrentRotation;


// Used internally for Karma stuff - DO NOT CHANGE!
var		transient const pointer		KContact;

defaultproperties
{
     BoneSteerAxis=AXIS_Z
     WheelRadius=35.000000
     Softness=0.050000
     PenScale=1.000000
     WheelInertia=1.000000
     SuspensionTravel=50.000000
     HandbrakeSlipFactor=1.000000
     HandbrakeFrictionFactor=1.000000
     SuspensionMaxRenderTravel=50.000000
     SupportBoneAxis=AXIS_Y
}
