// Base class for 4-wheeled vehicles using Karma
// Assumes negative-X is forward, negative-Y is right
class KCar extends KVehicle
    abstract;

var KTire frontLeft, frontRight, rearLeft, rearRight;
var (KCar) class<KTire> FrontTireClass;
var (KCar) class<KTire> RearTireClass;

// Wheel positions
var const float WheelFrontAlong;
var const float WheelFrontAcross;
var const float WheelRearAlong;
var const float WheelRearAcross;
var const float WheelVert;

var (KCar) float       MaxSteerAngle;   // (65535 = 360 deg)
var (KCar) float       MaxBrakeTorque;  // Braking torque applied to all four wheels. Positive only.
var (KCar) float       TorqueSplit;     // front/rear drive torque split. 1 is fully RWD, 0 is fully FWD. 0.5 is standard 4WD.


// KCarWheelJoint setting for steering (see KCarWheelJoint). Duplicated here for handiness.
var (KCar) float       SteerPropGap;
var (KCar) float       SteerTorque;
var (KCar) float       SteerSpeed;

// KCarWheelSuspension setting
var (KCar) float       SuspStiffness;
var (KCar) float       SuspDamping;
var (KCar) float       SuspHighLimit;
var (KCar) float       SuspLowLimit;
var (KCar) float       SuspRef;

// KTire settings. Duplicated here for handy tuning.
var (KCar) float       TireRollFriction;
var (KCar) float       TireLateralFriction;
var (KCar) float       TireRollSlip;
var (KCar) float       TireLateralSlip;
var (KCar) float       TireMinSlip;
var (KCar) float       TireSlipRate;
var (KCar) float       TireSoftness;
var (KCar) float       TireAdhesion;
var (KCar) float       TireRestitution;
var (KCar) float       TireMass;

var (KCar) float	   HandbrakeThresh; // speed above which handbrake comes on =]
var (KCar) float	   TireHandbrakeSlip; // Additional lateral slip when handbrake engaged
var (KCar) float	   TireHandbrakeFriction; // Additional lateral friction when handbrake engaged

var (KCar) float       ChassisMass;

var (KCar) float	   StopThreshold; // Forward velocity under which brakes become drive.

var (KCar) InterpCurve	TorqueCurve; // Engine RPM in, Torque out.

var (KCar) float		FlipTorque;
var (KCar) float		FlipTime;

var (KCar) float		MaxNetUpdateInterval;

var int      Gear;  // 1 is forward, -1 is backward. Currently symmetric power/torque curve

// Car output
var float              WheelSpinSpeed;  // Current (averaged) RPM of rear wheels
var float			   ForwardVel;		// Component of cars velocity in its forward direction.
var bool			   bIsInverted;     // Updated in Tick - indicates if car is not upright.

// Internal
var bool			   IsDriving;
var float			   FlipTimeLeft;
var float			   NextNetUpdateTime;	// Next time we should force an update of vehicles state.

// Low-level drive data (this is replicated)
var bool			   OutputBrake;
var float			   OutputTorque;
var bool			   OutputHandbrakeOn;


// Networking
struct KCarState
{
	var KRBVec				ChassisPosition;
	var Quat				ChassisQuaternion;
	var KRBVec				ChassisLinVel;
	var KRBVec				ChassisAngVel;

	var float				WheelHeight[4]; // FL, FR, RL, RR
	var float				FrontWheelAng[2]; // FL, FR

	var float				WheelVertVel[4];
	//var float				WheelSpinVel[4];

	var float				ServerSteering;

	var float				ServerTorque;
	var bool				ServerBrake;
	var bool			    ServerHandbrakeOn;

	var bool				bNewState; // Set to true whenever a new state is received and should be processed
};

var KRigidBodyState		ChassisState;

var KCarState			CarState; // This is replicated to the car, and processed to update all the parts.
var bool				bNewCarState; // Indicated there is new data processed, and chassis RBState should be updated.

replication
{
	// We replicate the Gear for brake-lights etc.
	unreliable if(Role == ROLE_Authority)
		CarState, Gear;

	reliable if(Role == ROLE_Authority)
		FlipTimeLeft;
}

// When new information is received, see if its new. If so, pass bits off the the wheels.
// Each part will then update its rigid body position via the KUpdateState event.
// JTODO: This is where clever unpacking would happen.
simulated event VehicleStateReceived()
{
	local vector ChassisY, SteerY, ChassisZ, calcPos, WheelY, lPos;
	local vector chassisPos, chassisLinVel, chassisAngVel, WheelLinVel, wPosRel;
	local Quat relQ, WheelQ;

	if(!CarState.bNewState)
		return;

	// Don't do anything if car isn't started up.	
	if(frontLeft == None || frontRight == None || rearLeft == None || rearRight == None)
		return;

	// Get root chassis info
	ChassisState.Position = CarState.ChassisPosition;
	ChassisState.Quaternion = CarState.ChassisQuaternion;
	ChassisState.LinVel = CarState.ChassisLinVel;
	ChassisState.AngVel = CarState.ChassisAngVel;

	chassisPos = KRBVecToVector(CarState.ChassisPosition);
	chassisLinVel = KRBVecToVector(CarState.ChassisLinVel);
	chassisAngVel = KRBVecToVector(CarState.ChassisAngVel);

	// Calc chassis state axes
	ChassisY = QuatRotateVector(CarState.ChassisQuaternion, vect(0, 1, 0));
	ChassisZ = QuatRotateVector(CarState.ChassisQuaternion, vect(0, 0, 1));

	// Get root chassis info
	ChassisState.Position = CarState.ChassisPosition;
	ChassisState.Quaternion = CarState.ChassisQuaternion;
	ChassisState.LinVel = CarState.ChassisLinVel;
	ChassisState.AngVel = CarState.ChassisAngVel;
	

	// Figure out new state of wheels

	// Wheel positions are only supplied with a chassis-space Z (vertical) value - X and Y are assumed no to change
	// Rear wheel orientations are not supplied. The only constraint is their Y-axis (axle) is parallel to 
	// the chassis Y-axis. A quaternion is calculated to go from current orientation to fulfil that criteria, which
	// should produce minimum difference to the 'roll' of the wheel - which is allowed to differ on server and client.
	// For front wheel we do send the current 'steering' angle. That is added after the above process as a quaternion 
	// around chassis Z (up).
	// For linear velocity of wheels - calculate based on linear and angular velocity of chassis, and add on vertical 
	// component sent over the net.

	////////////////////////// FRONT LEFT //////////////////////////
	frontLeft.KGetRigidBodyState(frontLeft.ReceiveState);

	// Position
	lPos.X = WheelFrontAlong;
	lPos.Y = WheelFrontAcross;
	lPos.Z = CarState.WheelHeight[0];
	calcPos = chassisPos + QuatRotateVector(CarState.ChassisQuaternion, lPos); // Convert from chassis state to world space
	frontLeft.ReceiveState.Position = KRBVecFromVector(calcPos);

	// Rotation
	wheelQ = frontLeft.KGetRBQuaternion();
	WheelY = QuatRotateVector(wheelQ, vect(0, 1, 0));
	SteerY = QuatRotateVector( QuatFromAxisAndAngle(ChassisZ, CarState.FrontWheelAng[0]), ChassisY );
	relQ = QuatFindBetween(WheelY, SteerY);
	frontLeft.ReceiveState.Quaternion = QuatProduct(relQ, wheelQ);

	// Velocity
	wPosRel = calcPos - chassisPos;
	WheelLinVel = chassisLinVel + (chassisAngVel Cross wPosRel);
	WheelLinVel += CarState.WheelVertVel[0] * ChassisZ;
	frontLeft.ReceiveState.LinVel = KRBVecFromVector(WheelLinVel);

	//frontLeft.ReceiveState.AngVel = KRBVecFromVector(chassisAngVel + (WheelY * CarState.WheelSpinVel[0]));

	frontLeft.bReceiveStateNew = true;

	////////////////////////// FRONT RIGHT //////////////////////////
	frontRight.KGetRigidBodyState(frontRight.ReceiveState);

	// Position
	lPos.X = WheelFrontAlong;
	lPos.Y = -WheelFrontAcross;
	lPos.Z = CarState.WheelHeight[1];
	calcPos = chassisPos + QuatRotateVector(CarState.ChassisQuaternion, lPos);
	frontRight.ReceiveState.Position = KRBVecFromVector(calcPos);


	// Rotation
	wheelQ = frontRight.KGetRBQuaternion();
	WheelY = QuatRotateVector(wheelQ, vect(0, 1, 0));
	SteerY = QuatRotateVector( QuatFromAxisAndAngle(ChassisZ, CarState.FrontWheelAng[1]), ChassisY );
	relQ = QuatFindBetween(WheelY, SteerY);
	frontRight.ReceiveState.Quaternion = QuatProduct(relQ, wheelQ);

	// Velocity
	wPosRel = calcPos - chassisPos;
	WheelLinVel = chassisLinVel + (chassisAngVel Cross wPosRel);
	WheelLinVel += CarState.WheelVertVel[1] * ChassisZ;
	frontRight.ReceiveState.LinVel = KRBVecFromVector(WheelLinVel);

	//frontRight.ReceiveState.AngVel = KRBVecFromVector(chassisAngVel + (WheelY * CarState.WheelSpinVel[1]));

	frontRight.bReceiveStateNew = true;

	////////////////////////// REAR LEFT //////////////////////////
	rearLeft.KGetRigidBodyState(rearLeft.ReceiveState);

	// Position
	lPos.X = WheelRearAlong;
	lPos.Y = WheelFrontAcross;
	lPos.Z = CarState.WheelHeight[2];
	calcPos = chassisPos + QuatRotateVector(CarState.ChassisQuaternion, lPos);
	rearLeft.ReceiveState.Position = KRBVecFromVector(calcPos);


	// Rotation
	wheelQ = rearLeft.KGetRBQuaternion();
	WheelY = QuatRotateVector(wheelQ, vect(0, 1, 0));
	relQ = QuatFindBetween(WheelY, ChassisY);
	rearLeft.ReceiveState.Quaternion = QuatProduct(relQ, wheelQ);
	
	// Velocity
	wPosRel = calcPos - chassisPos;
	WheelLinVel = chassisLinVel + (chassisAngVel Cross wPosRel);
	WheelLinVel += CarState.WheelVertVel[2] * ChassisZ;
	rearLeft.ReceiveState.LinVel = KRBVecFromVector(WheelLinVel);

	//rearLeft.ReceiveState.AngVel = KRBVecFromVector(chassisAngVel + (WheelY * CarState.WheelSpinVel[2]));

	rearLeft.bReceiveStateNew = true;

	////////////////////////// REAR RIGHT //////////////////////////
	rearRight.KGetRigidBodyState(rearRight.ReceiveState);

	// Position
	lPos.X = WheelRearAlong;
	lPos.Y = -WheelFrontAcross;
	lPos.Z = CarState.WheelHeight[3];
	calcPos = chassisPos + QuatRotateVector(CarState.ChassisQuaternion, lPos);
	rearRight.ReceiveState.Position = KRBVecFromVector(calcPos);

	// Rotation
	wheelQ = rearRight.KGetRBQuaternion();
	WheelY = QuatRotateVector(wheelQ, vect(0, 1, 0));
	relQ = QuatFindBetween(WheelY, ChassisY);
	rearRight.ReceiveState.Quaternion = QuatProduct(relQ, wheelQ);

	// Velocity
	wPosRel = calcPos - chassisPos;
	WheelLinVel = chassisLinVel + (chassisAngVel Cross wPosRel);
	WheelLinVel += CarState.WheelVertVel[3] * ChassisZ;
	rearRight.ReceiveState.LinVel = KRBVecFromVector(WheelLinVel);

	//rearRight.ReceiveState.AngVel = KRBVecFromVector(chassisAngVel + (WheelY * CarState.WheelSpinVel[3]));

	rearRight.bReceiveStateNew = true;

	////// OTHER //////

	// Update control inputs
	Steering = CarState.ServerSteering;
	OutputTorque = CarState.ServerTorque;
	OutputBrake = CarState.ServerBrake;
	OutputHandbrakeOn = CarState.ServerHandbrakeOn;

	// Update flags
	CarState.bNewState = false;
	bNewCarState = true;

	// For debugging...
	//KDrawRigidBodyState(ChassisState, false);
	//KDrawRigidBodyState(frontLeft.ReceiveState, false);
	//KDrawRigidBodyState(frontRight.ReceiveState, false);
	//KDrawRigidBodyState(rearLeft.ReceiveState, false);
	//KDrawRigidBodyState(rearRight.ReceiveState, false);
}

// This only update the chassis. The wheels update themselves.
simulated event bool KUpdateState(out KRigidBodyState newState)
{
	// This should never get called on the server - but just in case!
	if(Role == ROLE_Authority || !bNewCarState)
		return false;
		
	// Apply received data as new position of car chassis.
	newState = ChassisState;
	bNewCarState = false;

	return true;
	//return false;
}

// Pack current state of whole car into the state struct, to be sent to the client.
// Should only get called on the server.
function PackState()
{
	local vector lPos, wPos, chassisPos, chassisLinVel, chassisAngVel, wPosRel, WheelLinVel;
	local vector ChassisX, ChassisZ, WheelY, oldPos, oldLinVel;
	local KRigidBodyState CurrentChassisState, WheelState;

	// Get chassis state.
	KGetRigidBodyState(CurrentChassisState);

	chassisPos = KRBVecToVector(CurrentChassisState.Position);
	chassisLinVel = KRBVecToVector(CurrentChassisState.LinVel);
	chassisAngVel = KRBVecToVector(CurrentChassisState.AngVel);

	// Last position we sent
	oldPos = KRBVectoVector(CarState.ChassisPosition);
	oldLinVel = KRBVectoVector(CarState.ChassisLinVel);

	// See if state has changed enough, or enough time has passed, that we 
	// should send out another update by updating the state struct.
	if( !KIsAwake() )
	{
		return; // Never send updates if physics is at rest
	}

	if( VSize(oldPos - chassisPos) > 5 ||
		VSize(oldLinVel - chassisLinVel) > 1 ||
		Abs(CarState.ServerTorque - OutputTorque) > 0.1 ||
		Abs(CarState.ServerSteering - Steering) > 0.1 ||
		Level.TimeSeconds > NextNetUpdateTime )
	{
		NextNetUpdateTime = Level.TimeSeconds + MaxNetUpdateInterval;
	}
	else
	{
		return;
		//NextNetUpdateTime = Level.TimeSeconds + MaxNetUpdateInterval;
	}

	CarState.ChassisPosition = CurrentChassisState.Position;
	CarState.ChassisQuaternion = CurrentChassisState.Quaternion;
	CarState.ChassisLinVel = CurrentChassisState.LinVel;
	CarState.ChassisAngVel = CurrentChassisState.AngVel;


	ChassisX = QuatRotateVector(CarState.ChassisQuaternion, vect(1, 0, 0));
	ChassisZ = QuatRotateVector(CarState.ChassisQuaternion, vect(0, 0, 1));
	// Get each wheel state.

	////////////////////////// FRONT LEFT //////////////////////////
	frontLeft.KGetRigidBodyState(WheelState);
	wPos = KRBVecToVector(WheelState.Position);
	lPos = QuatRotateVector(QuatInvert(CarState.ChassisQuaternion), wPos - chassisPos); // Convert from world to chassis state space
	CarState.WheelHeight[0] = lPos.Z; // X should be WheelFrontAlong, Y should be WheelFrontAcross

	// For front wheels - we store their current angle around Z as well.
	WheelY = QuatRotateVector(WheelState.Quaternion, vect(0, 1, 0));
	CarState.FrontWheelAng[0] = -ASin(ChassisX Dot WheelY);

	// Find component of relative wheel linear velocity along suspension travel (chassisZ).
	wPosRel = KRBVecToVector(WheelState.Position) - chassisPos;
	WheelLinVel = chassisLinVel + (chassisAngVel Cross wPosRel);

	CarState.WheelVertVel[0] = 
		((WheelState.LinVel.X - WheelLinVel.X)* ChassisZ.X) + 
		((WheelState.LinVel.Y - WheelLinVel.Y)* ChassisZ.Y) + 
		((WheelState.LinVel.Z - WheelLinVel.Z)* ChassisZ.Z);

	//CarState.WheelSpinVel[0] = KRBVecToVector(WheelState.AngVel) Dot WheelY;

	////////////////////////// FRONT RIGHT //////////////////////////
	frontRight.KGetRigidBodyState(WheelState);
	wPos = KRBVecToVector(WheelState.Position);
	lPos = QuatRotateVector(QuatInvert(CarState.ChassisQuaternion), wPos - chassisPos);
	CarState.WheelHeight[1] = lPos.Z;

	WheelY = QuatRotateVector(WheelState.Quaternion, vect(0, 1, 0));
	CarState.FrontWheelAng[1] = -ASin(ChassisX Dot WheelY);

	CarState.WheelVertVel[1] = 
		((WheelState.LinVel.X - WheelLinVel.X)* ChassisZ.X) + 
		((WheelState.LinVel.Y - WheelLinVel.Y)* ChassisZ.Y) + 
		((WheelState.LinVel.Z - WheelLinVel.Z)* ChassisZ.Z);

	//CarState.WheelSpinVel[1] = KRBVecToVector(WheelState.AngVel) Dot WheelY;

	////////////////////////// REAR LEFT //////////////////////////
	rearLeft.KGetRigidBodyState(WheelState);
	wPos = KRBVecToVector(WheelState.Position);
	lPos = QuatRotateVector(QuatInvert(CarState.ChassisQuaternion), wPos - chassisPos);
	CarState.WheelHeight[2] = lPos.Z;

	wPosRel = KRBVecToVector(WheelState.Position) - chassisPos;
	WheelLinVel = chassisLinVel + (chassisAngVel Cross wPosRel);

	CarState.WheelVertVel[2] = 
		((WheelState.LinVel.X - WheelLinVel.X)* ChassisZ.X) + 
		((WheelState.LinVel.Y - WheelLinVel.Y)* ChassisZ.Y) + 
		((WheelState.LinVel.Z - WheelLinVel.Z)* ChassisZ.Z);

	WheelY = QuatRotateVector(WheelState.Quaternion, vect(0, 1, 0));
	//CarState.WheelSpinVel[2] = KRBVecToVector(WheelState.AngVel) Dot WheelY;

	////////////////////////// REAR RIGHT //////////////////////////
	rearRight.KGetRigidBodyState(WheelState);
	wPos = KRBVecToVector(WheelState.Position);
	lPos = QuatRotateVector(QuatInvert(CarState.ChassisQuaternion), wPos - chassisPos);
	CarState.WheelHeight[3] = lPos.Z;

	wPosRel = KRBVecToVector(WheelState.Position) - chassisPos;
	WheelLinVel = chassisLinVel + (chassisAngVel Cross wPosRel);

	CarState.WheelVertVel[3] = 
		((WheelState.LinVel.X - WheelLinVel.X)* ChassisZ.X) + 
		((WheelState.LinVel.Y - WheelLinVel.Y)* ChassisZ.Y) + 
		((WheelState.LinVel.Z - WheelLinVel.Z)* ChassisZ.Z);

	WheelY = QuatRotateVector(WheelState.Quaternion, vect(0, 1, 0));
	//CarState.WheelSpinVel[3] = KRBVecToVector(WheelState.AngVel) Dot WheelY;

	// OTHER
	CarState.ServerSteering = Steering;
	CarState.ServerTorque = OutputTorque;
	CarState.ServerBrake = OutputBrake;
	CarState.ServerHandbrakeOn = OutputHandbrakeOn;

	// This flag lets the client know this data is new.
	CarState.bNewState = true;
}

simulated function PostNetBeginPlay()
{
	local vector RotX, RotY, RotZ, lPos;

    Super.PostNetBeginPlay();

    // Set up suspension graphics

    GetAxes(Rotation,RotX,RotY,RotZ);

    // Spawn wheels, and flip graphics where necessary
    frontLeft = spawn(FrontTireClass, self,, Location + WheelFrontAlong*RotX + WheelFrontAcross*RotY + WheelVert*RotZ, Rotation);
    //frontLeft.SetDrawScale(1);
    frontLeft.SetDrawScale3D(vect(1, 1, 1));

    frontRight = spawn(FrontTireClass, self,, Location + WheelFrontAlong*RotX - WheelFrontAcross*RotY + WheelVert*RotZ, Rotation);
    frontRight.SetDrawScale3D(vect(1, -1, 1));

    rearLeft = spawn(RearTireClass, self,, Location + WheelRearAlong*RotX + WheelRearAcross*RotY + WheelVert*RotZ, Rotation);
    //rearLeft.SetDrawScale(1);
    rearLeft.SetDrawScale3D(vect(1, 1, 1));

    rearRight = spawn(RearTireClass, self,, Location + WheelRearAlong*RotX - WheelRearAcross*RotY + WheelVert*RotZ, Rotation);
    rearRight.SetDrawScale3D(vect(1, -1, 1));

    // Create joints
	lPos.X = WheelFrontAlong;
	lPos.Y = WheelFrontAcross;
	lPos.Z = WheelVert;
    frontLeft.WheelJoint = spawn(class'KCarWheelJoint', self);
    frontLeft.WheelJoint.KPos1 = lPos/50;
    frontLeft.WheelJoint.KPriAxis1 = vect(0, 0, 1);
    frontLeft.WheelJoint.KSecAxis1 = vect(0, 1, 0);
    frontLeft.WheelJoint.KConstraintActor1 = self;
    frontLeft.WheelJoint.KPos2 = vect(0, 0, 0);
    frontLeft.WheelJoint.KPriAxis2 = vect(0, 0, 1);
    frontLeft.WheelJoint.KSecAxis2 = vect(0, 1, 0);
    frontLeft.WheelJoint.KConstraintActor2 = frontLeft;
    frontLeft.WheelJoint.SetPhysics(PHYS_Karma);

	lPos.Y = -WheelFrontAcross;
    frontRight.WheelJoint = spawn(class'KCarWheelJoint', self);
    frontRight.WheelJoint.KPos1 = lPos/50;
    frontRight.WheelJoint.KPriAxis1 = vect(0, 0, 1);
    frontRight.WheelJoint.KSecAxis1 = vect(0, 1, 0);
    frontRight.WheelJoint.KConstraintActor1 = self;
    frontRight.WheelJoint.KPos2 = vect(0, 0, 0);
    frontRight.WheelJoint.KPriAxis2 = vect(0, 0, 1);
    frontRight.WheelJoint.KSecAxis2 = vect(0, 1, 0);
    frontRight.WheelJoint.KConstraintActor2 = frontRight;
    frontRight.WheelJoint.SetPhysics(PHYS_Karma);

	lPos.X = WheelRearAlong;
	lPos.Y = WheelRearAcross;
    rearLeft.WheelJoint = spawn(class'KCarWheelJoint', self);
    rearLeft.WheelJoint.KPos1 = lPos/50;
    rearLeft.WheelJoint.KPriAxis1 = vect(0, 0, 1);
    rearLeft.WheelJoint.KSecAxis1 = vect(0, 1, 0);
    rearLeft.WheelJoint.KConstraintActor1 = self;
    rearLeft.WheelJoint.KPos2 = vect(0, 0, 0);
    rearLeft.WheelJoint.KPriAxis2 = vect(0, 0, 1);
    rearLeft.WheelJoint.KSecAxis2 = vect(0, 1, 0);
    rearLeft.WheelJoint.KConstraintActor2 = rearLeft;
    rearLeft.WheelJoint.SetPhysics(PHYS_Karma);

    lPos.Y = -WheelRearAcross;
	rearRight.WheelJoint = spawn(class'KCarWheelJoint', self);
    rearRight.WheelJoint.KPos1 = lPos/50;
    rearRight.WheelJoint.KPriAxis1 = vect(0, 0, 1);
    rearRight.WheelJoint.KSecAxis1 = vect(0, 1, 0);
    rearRight.WheelJoint.KConstraintActor1 = self;
    rearRight.WheelJoint.KPos2 = vect(0, 0, 0);
    rearRight.WheelJoint.KPriAxis2 = vect(0, 0, 1);
    rearRight.WheelJoint.KSecAxis2 = vect(0, 1, 0);
    rearRight.WheelJoint.KConstraintActor2 = rearRight;
    rearRight.WheelJoint.SetPhysics(PHYS_Karma);

	// Initially make sure parameters are sync'ed with Karma
	KVehicleUpdateParams();
}

// Clean up wheels etc.
simulated event Destroyed()
{
	// Destroy joints holding wheels to car
	frontLeft.WheelJoint.Destroy();
	frontRight.WheelJoint.Destroy();
	rearLeft.WheelJoint.Destroy();
	rearRight.WheelJoint.Destroy();

	// Destroy wheels themselves.
	frontLeft.Destroy();
	frontRight.Destroy();
	rearLeft.Destroy();
	rearRight.Destroy();

	Super.Destroyed();
}

// Call this if you change any parameters (tire, suspension etc.) and they
// will be passed down to each wheel/joint.

simulated event KVehicleUpdateParams()
{
	Super.KVehicleUpdateParams();

    rearLeft.WheelJoint.bKSteeringLocked = true;
    rearRight.WheelJoint.bKSteeringLocked = true;
    
    frontLeft.WheelJoint.bKSteeringLocked = false;
    frontLeft.WheelJoint.KProportionalGap = SteerPropGap;
    frontLeft.WheelJoint.KMaxSteerTorque = SteerTorque;
    frontLeft.WheelJoint.KMaxSteerSpeed = SteerSpeed;

    frontRight.WheelJoint.bKSteeringLocked = false;
    frontRight.WheelJoint.KProportionalGap = SteerPropGap;
    frontRight.WheelJoint.KMaxSteerTorque = SteerTorque;
    frontRight.WheelJoint.KMaxSteerSpeed = SteerSpeed;

    frontLeft.WheelJoint.KSuspHighLimit = SuspHighLimit;
    frontLeft.WheelJoint.KSuspLowLimit = SuspLowLimit;
    frontLeft.WheelJoint.KSuspStiffness = SuspStiffness;
    frontLeft.WheelJoint.KSuspDamping = SuspDamping;

    frontRight.WheelJoint.KSuspHighLimit = SuspHighLimit;
    frontRight.WheelJoint.KSuspLowLimit = SuspLowLimit;
    frontRight.WheelJoint.KSuspStiffness = SuspStiffness;
    frontRight.WheelJoint.KSuspDamping = SuspDamping;

    rearLeft.WheelJoint.KSuspHighLimit = SuspHighLimit;
    rearLeft.WheelJoint.KSuspLowLimit = SuspLowLimit;
    rearLeft.WheelJoint.KSuspStiffness = SuspStiffness;
    rearLeft.WheelJoint.KSuspDamping = SuspDamping;

    rearRight.WheelJoint.KSuspHighLimit = SuspHighLimit;
    rearRight.WheelJoint.KSuspLowLimit = SuspLowLimit;
    rearRight.WheelJoint.KSuspStiffness = SuspStiffness;
    rearRight.WheelJoint.KSuspDamping = SuspDamping;

	// Sync params with Karma.
	frontLeft.WheelJoint.KUpdateConstraintParams();
	frontRight.WheelJoint.KUpdateConstraintParams();
	rearLeft.WheelJoint.KUpdateConstraintParams();
	rearRight.WheelJoint.KUpdateConstraintParams();

    // Mass
    KSetMass(ChassisMass);
    frontLeft.KSetMass(TireMass);
    frontRight.KSetMass(TireMass);
    rearLeft.KSetMass(TireMass);
    rearRight.KSetMass(TireMass);

    // Tire params handy tuning
    frontLeft.RollFriction = TireRollFriction;
    frontLeft.LateralFriction = TireLateralFriction;
    frontLeft.RollSlip = TireRollSlip;
    frontLeft.LateralSlip = TireLateralSlip;
    frontLeft.MinSlip = TireMinSlip;
    frontLeft.SlipRate = TireSlipRate;
    frontLeft.Softness = TireSoftness;
    frontLeft.Adhesion = TireAdhesion;
    frontLeft.Restitution = TireRestitution;

    frontRight.RollFriction = TireRollFriction;
    frontRight.LateralFriction = TireLateralFriction;
    frontRight.RollSlip = TireRollSlip;
    frontRight.LateralSlip = TireLateralSlip;
    frontRight.MinSlip = TireMinSlip;
    frontRight.SlipRate = TireSlipRate;
    frontRight.Softness = TireSoftness;
    frontRight.Adhesion = TireAdhesion;
    frontRight.Restitution = TireRestitution;

    rearLeft.RollFriction = TireRollFriction;
    rearLeft.LateralFriction = TireLateralFriction;
    rearLeft.RollSlip = TireRollSlip;
    rearLeft.LateralSlip = TireLateralSlip;
    rearLeft.MinSlip = TireMinSlip;
    rearLeft.SlipRate = TireSlipRate;
    rearLeft.Softness = TireSoftness;
    rearLeft.Adhesion = TireAdhesion;
    rearLeft.Restitution = TireRestitution;

    rearRight.RollFriction = TireRollFriction;
    rearRight.LateralFriction = TireLateralFriction;
    rearRight.RollSlip = TireRollSlip;
    rearRight.LateralSlip = TireLateralSlip;
    rearRight.MinSlip = TireMinSlip;
    rearRight.SlipRate = TireSlipRate;
    rearRight.Softness = TireSoftness;
    rearRight.Adhesion = TireAdhesion;
    rearRight.Restitution = TireRestitution;
}

// Possibly apply force to flip car over.
simulated event KApplyForce(out vector Force, out vector Torque)
{
	local float torqueScale;
	local vector worldForward, worldUp, worldRight, torqueAxis;

	if(FlipTimeLeft == 0)
		return;

	worldForward = vect(-1, 0, 0) >> Rotation;
	worldUp = vect(0, 0, 1) >> Rotation;
	worldRight = vect(0, 1, 0) >> Rotation;

	torqueAxis = Normal(worldUp Cross vect(0, 0, 1));

	// Torque scaled by how far over we are. 
	// This will be between 0 and PI - so convert to between 0 and 1.
	torqueScale = Acos(worldUp Dot vect(0, 0, 1))/3.1416;

	Torque = FlipTorque * torqueScale * torqueAxis;
}

function StartFlip(Pawn Pusher)
{
	//local vector toPusher, worldUp;

	// if we are already flipping the car - dont do it again!
	if(FlipTimeLeft > 0)
		return;

	// Dont let you push the car if you are going to be underneath it!
  	//worldUp = vect(0, 0, 1) >> Rotation;
	//toPusher = Pusher.Location - Location;
	//if( (worldUp Dot toPusher) < 0)
	//	return;

	FlipTimeLeft = FlipTime; // Start the flip on the server
}

// Tell it your current throttle, and it will give you an output torque
// This is currently like an electric motor
function float Engine(float Throttle)
{
    local float torque;
    
	torque = Abs(Throttle) * Gear * InterpCurveEval(TorqueCurve, WheelSpinSpeed);

	GraphData("SpinSpeed", WheelSpinSpeed);
	GraphData("Torque", torque);

    return -1 * torque;
}

function ProcessCarInput()
{
	local vector worldForward, worldUp;

	//Log("PCI S:"$Steering$" T:"$Throttle);

  	worldForward = vect(-1, 0, 0) >> Rotation;
  	worldUp = vect(0, 0, 1) >> Rotation;
  	  	
  	ForwardVel = Velocity Dot worldForward;

	bIsInverted = worldUp.Z < 0.2;

	// 'ForwardVel' isn't very helpful if we are inverted, so we just pretend its positive.
	if(bIsInverted)
		ForwardVel = 2 * StopThreshold;

	//Log("F:"$ForwardVel$"IsI:"$bIsInverted);

	if( Driver == None )
	{
		if(bAutoDrive == true)
		{
			Gear = 1;
			OutputBrake = false;

			Throttle = 0.4;
			Steering = 1;

			//log("Thr:"$Throttle);

			KWake();
		}
		else
		{
			Gear = 0;
			OutputBrake = true;
		}
	}
	else
	{
		if(Throttle > 0.01) // pressing forwards
		{
			if(ForwardVel < -StopThreshold && Gear != 1) // going backwards - so brake first
			{
				//Log("F - Brake");
				Gear = 0;
				OutputBrake = true;
				IsDriving = false;
			}
			else // stopped or going forwards, so drive
			{
				//Log("F - Drive");
				Gear = 1;
				OutputBrake = false;
				IsDriving = true;
			}
		}
		else if(Throttle < -0.01) // pressing backwards
		{
			// We have to release the brakes and then press reverse again to go into reverse
			if(ForwardVel < StopThreshold && IsDriving == false)
			{
				//Log("B - Drive");
				Gear = -1;
				OutputBrake = false;
				IsDriving = false;
			}
			else // otherwise, we are going forwards, or still holding brake, so just brake
			{
				//Log("B - Brake");
				Gear = 0;
				OutputBrake = true;
				IsDriving = true;
			}
		}
		else // not pressing either
		{
			// If stationary, stick brakes on
			if(Abs(ForwardVel) < StopThreshold)
			{
				//Log("B - Brake");
				Gear = 0;
				OutputBrake = true;
				IsDriving = false;
				OutputHandbrakeOn = false; // force handbrake off if stopped.
			}
			else // otherwise, coast
			{
				//Log("Coast");
				Gear = 0;
				OutputBrake = false;
				IsDriving = false;
			}
		}

		KWake(); // currently, never let the car go to sleep whilst being driven.
	}

	// If we are going forwards, steering, and pressing the brake,
	// enable extra-slippy handbrake.
	if((ForwardVel > HandbrakeThresh || OutputHandbrakeOn == true) && Abs(Steering) > 0.01 && OutputBrake == true)
		OutputHandbrakeOn = true;
	else
		OutputHandbrakeOn = false;

	// Engine model
    OutputTorque = Engine(Throttle);
}

// Car Simulation
simulated function Tick(float Delta)
{
	local float tana, sFactor;

	Super.Tick(Delta);

    WheelSpinSpeed = (rearLeft.SpinSpeed + rearRight.SpinSpeed)/2;
    //log("WheelSpinSpeed:"$WheelSpinSpeed);

	// if we are in the process of flipping the car, keep it enabled!
	if( FlipTimeLeft > 0  )
		KWake();

    // If the server, process input and pack updated car info into struct.
    if(Role == ROLE_Authority)
	{
		ProcessCarInput();
		PackState();
	}

    // Motor

	// FRONT
    frontLeft.WheelJoint.KMotorTorque = 0.5 * OutputTorque * (1-TorqueSplit);
    frontRight.WheelJoint.KMotorTorque = 0.5 * OutputTorque * (1-TorqueSplit);

	// REAR
    rearLeft.WheelJoint.KMotorTorque = 0.5 * OutputTorque * TorqueSplit;
    rearRight.WheelJoint.KMotorTorque = 0.5 * OutputTorque * TorqueSplit;

    // Braking

	if(OutputBrake)
	{
		frontLeft.WheelJoint.KBraking = MaxBrakeTorque;
		frontRight.WheelJoint.KBraking = MaxBrakeTorque;
		rearLeft.WheelJoint.KBraking = MaxBrakeTorque;
		rearRight.WheelJoint.KBraking = MaxBrakeTorque;
	}
	else
	{
		frontLeft.WheelJoint.KBraking = 0.0;
		frontRight.WheelJoint.KBraking = 0.0;
		rearLeft.WheelJoint.KBraking = 0.0;
		rearRight.WheelJoint.KBraking = 0.0;
	}

	// Steering

	tana = Tan(6.283/65536 * Steering * MaxSteerAngle);

    sFactor = 0.5 * tana * (2 * WheelFrontAcross) / Abs(WheelFrontAlong - WheelRearAlong);
    frontLeft.WheelJoint.KSteerAngle = 65536/6.283 * Atan(tana, (1-sFactor));
    frontRight.WheelJoint.KSteerAngle = 65536/6.283 * Atan(tana, (1+sFactor));

	// Handbrake

	if(OutputHandbrakeOn == true)
	{
		//Log("HANDBRAKE!!");
		rearLeft.LateralFriction = TireLateralFriction + TireHandbrakeFriction;
		rearLeft.LateralSlip = TireLateralSlip + TireHandbrakeSlip;

		rearRight.LateralFriction = TireLateralFriction + TireHandbrakeFriction;
		rearRight.LateralSlip = TireLateralSlip + TireHandbrakeSlip;
	}
	else
	{
		rearLeft.LateralFriction = TireLateralFriction;
		rearLeft.LateralSlip = TireLateralSlip;

		rearRight.LateralFriction = TireLateralFriction;
		rearRight.LateralSlip = TireLateralSlip;
	}

	// Flipping
	if(FlipTimeLeft > 0)
	{
		FlipTimeLeft -= Delta;
		FlipTimeLeft = FMax(FlipTimeLeft, 0.0); // Make sure it doesn't go negative
	}

}

defaultproperties
{
     WheelFrontAlong=-180.000000
     WheelFrontAcross=140.000000
     WheelRearAlong=160.000000
     WheelRearAcross=140.000000
     WheelVert=-0.500000
     MaxSteerAngle=3900.000000
     MaxBrakeTorque=50.000000
     TorqueSplit=0.500000
     SteerPropGap=1000.000000
     SteerTorque=1000.000000
     SteerSpeed=15000.000000
     SuspStiffness=50.000000
     SuspDamping=5.000000
     SuspHighLimit=1.000000
     SuspLowLimit=-1.000000
     TireRollFriction=1.000000
     TireLateralFriction=1.000000
     TireRollSlip=0.085000
     TireLateralSlip=0.060000
     TireMinSlip=0.001000
     TireSlipRate=0.000500
     TireSoftness=0.000200
     TireMass=0.500000
     HandbrakeThresh=1000.000000
     TireHandbrakeSlip=0.060000
     TireHandbrakeFriction=-0.500000
     ChassisMass=4.000000
     StopThreshold=100.000000
     TorqueCurve=(Points=((OutVal=150.000000),(InVal=245756.000000,OutVal=150.000000),(InVal=491512.000000)))
     FlipTorque=350.000000
     FlipTime=3.000000
     MaxNetUpdateInterval=0.400000
     Gear=1
}
