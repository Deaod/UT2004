//=============================================================================
// The Car Wheel joint class.
//=============================================================================

//#exec Texture Import File=Textures\S_KBSJoint.pcx Name=S_KBSJoint Mips=Off MASKED=1

class KCarWheelJoint extends KConstraint
    native
    placeable;

// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)

// STEERING
var(KarmaConstraint) float KSteerAngle;       // desired steering angle to achieve using controller (65535 = 360 deg)
var(KarmaConstraint) float KProportionalGap;  // for steering controller (65535 = 360 deg)
var(KarmaConstraint) float KMaxSteerTorque;   // for steering controller
var(KarmaConstraint) float KMaxSteerSpeed;    // for steering controller (65535 = 1 rotation per second)
var(KarmaConstraint) bool  bKSteeringLocked;   // steering 'locked' in straight ahead direction

// MOTOR
var(KarmaConstraint) float KMotorTorque;      // torque applied to drive this wheel (can be negative)
var(KarmaConstraint) float KMaxSpeed;         // max speed to try and reach using KMotorTorque (65535 = 1 rotation per second)
var(KarmaConstraint) float KBraking;          // torque applied to brake wheel

// SUSPENSION
var(KarmaConstraint) float KSuspLowLimit;
var(KarmaConstraint) float KSuspHighLimit;
var(KarmaConstraint) float KSuspStiffness;
var(KarmaConstraint) float KSuspDamping;
var(KarmaConstraint) float KSuspRef;

// Other output
var const float KWheelHeight; // height of wheel relative to suspension centre

defaultproperties
{
     KProportionalGap=8200.000000
     KMaxSteerTorque=1000.000000
     KMaxSteerSpeed=2600.000000
     bKSteeringLocked=True
     KMaxSpeed=1310700.000000
     KSuspLowLimit=-1.000000
     KSuspHighLimit=1.000000
     KSuspStiffness=50.000000
     KSuspDamping=5.000000
     bNoDelete=False
}
