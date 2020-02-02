class KTire extends KActor
    native
    abstract;

// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)

var KCarWheelJoint  WheelJoint;         // joint holding this wheel to chassis etc.

// TYRE MODEL

// FRICTION
var float           RollFriction;       // friction coeff. in tyre direction
var float           LateralFriction;    // friction coeff. in sideways direction

// SLIP
// slip = min(maxSlip, minSlip + (slipRate * angular vel))
var float           RollSlip;           // max first-order (force ~ vel) slip in tyre direction
var float           LateralSlip;        // max first-order (force ~ vel) slip in sideways direction
var float           MinSlip;            // minimum slip (both directions)
var float           SlipRate;           // amount of extra slip per unit velocity

// NORMAL
var float           Softness;           // 'softness' in the normal dir
var float           Adhesion;           // 'stickyness' in the normal dir
var float           Restitution;        // 'bouncyness' in the normal dir

// Other Output information

var const bool      bTireOnGround;		// If this tire is currently in contact with something.

var const float     GroundSlipVel;      // relative tangential velocity of wheel against ground (0 for static, >0 for slipping)
                                        // could use this to trigger squeeling noises/smoke
var const vector	GroundSlipVec;		// full vector version of above (ie GroundSlipVel is magnitude of this vector).

var const float     SpinSpeed;			// current speed (65535 = 1 rev/sec) of this wheel spinning about its axis

var const material		GroundMaterial;		// material that tyre is touching
var const ESurfaceTypes GroundSurfaceType;	// surface type that the tyre is touching

// This is filled in by VehicleStateReceived in KVehicle.
var KRigidBodyState	ReceiveState;
var bool			bReceiveStateNew;

// This even is for updating the state (position, velocity etc.) of the tire's karma
// body when we get new information from the network.
event bool KUpdateState(out KRigidBodyState newState)
{
	if(!bReceiveStateNew)
		return false;
		
	newState = ReceiveState;
	bReceiveStateNew = false;

	return true;
	//return false;
}

// By default, nothing happens if you shoot a tire
function TakeDamage(int Damage, Pawn instigatedBy, Vector hitlocation, 
						Vector momentum, class<DamageType> damageType)
{

}

defaultproperties
{
     RollFriction=0.300000
     LateralFriction=0.300000
     RollSlip=0.085000
     LateralSlip=0.060000
     MinSlip=0.001000
     SlipRate=0.000500
     Softness=0.000200
     Restitution=0.100000
     bNoDelete=False
     bDisturbFluidSurface=True
}
