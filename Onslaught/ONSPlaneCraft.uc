//-----------------------------------------------------------
//
//-----------------------------------------------------------
class ONSPlaneCraft extends ONSVehicle
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

// Flying Parameters
var()   InterpCurve         LiftCoefficientCurve;
var()   InterpCurve         DragCoefficientCurve;
var()   float               AirFactor; // Technically this should be air density * wingspan area

var()	float				MaxThrust;
var()   float               ThrustAcceleration;

// Hovering Parameters
var()   bool                bHoverOnGround;
var()   float               COMHeight;
var()   InterpCurve         HoverForceCurve;

// Camera Parameters
var()   float               CameraSwingRatio;
var()   float               CameraDistance;

// Hover Stuff
var		array<vector>		ThrusterOffsets;
var()	float				HoverSoftness;
var()	float				HoverPenScale;
var()	float				HoverCheckDist;

// Internal
var		float				OutputThrust;
var		float				OutputStrafe;
var		float				OutputRise;

var     float               CurrentThrust;

var     float               AccumulatedTime;

var     float               LastCamTime;
var     rotator             LastCamRot;

//////////////////////////////////////////////////
// Physics
var()   float           PitchTorque;
var()   float           BankTorque;
//////////////////////////////////////////////////

// Replicated
struct native PlaneStateStruct
{
	var KRBVec				ChassisPosition;
	var Quat				ChassisQuaternion;
	var KRBVec				ChassisLinVel;
	var KRBVec				ChassisAngVel;

	var float				ServerThrust;
	var	float				ServerStrafe;
	var	float				ServerRise;
	var int                 ServerViewPitch;
	var int                 ServerViewYaw;
};

var		PlaneStateStruct	PlaneState, OldPlaneState;
var		KRigidBodyState		ChassisState;
var		bool				bNewPlaneState;

replication
{
	reliable if (Role == ROLE_Authority)
		PlaneState;
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
    	rep.bHidden = true;
    	kp.Repulsors[i] = rep;
    }

    Super.PostNetBeginPlay();
}

simulated event Destroyed()
{
	local KarmaParams kp;
	local int i;

	// Destroy repulsors
	kp = KarmaParams(KParams);
	for(i=0;i<kp.Repulsors.Length;i++)
    	kp.Repulsors[i].Destroy();

	Super.Destroyed();
}

simulated event bool KUpdateState(out KRigidBodyState newState)
{
	// This should never get called on the server - but just in case!
	if(Role == ROLE_Authority || !bNewPlaneState)
		return false;

	newState = ChassisState;
	bNewPlaneState = false;

	return true;
	//return false;
}

simulated event SVehicleUpdateParams()
{
	local KarmaParams kp;
	local int i;

	Super.SVehicleUpdateParams();

	kp = KarmaParams(KParams);

    for(i=0;i<kp.Repulsors.Length;i++)
	{
        kp.Repulsors[i].Softness = HoverSoftness;
        kp.Repulsors[i].PenScale = HoverPenScale;
        kp.Repulsors[i].CheckDist = HoverCheckDist;
    }
}

function int GetRotDiff(int A, int B)
{
	local int comp;

	comp = (A - B) & 65535;
	if(comp > 32768)
		comp -= 65536;

	return comp;
}

simulated function SpecialCalcBehindView(PlayerController PC, out actor ViewActor, out vector CameraLocation, out rotator CameraRotation )
{
   local vector CamLookAt, HitLocation, HitNormal;
   local float LerpAmount;
   local float CurTime;

   ViewActor = self;

   CurTime = Level.TimeSeconds;
   LerpAmount = 1.0 - ( CameraSwingRatio ** (CurTime - LastCamTime) );
   LastCamTime = CurTime;

/*   if(bRearView)
   {
      CamLookAt = Location;
      CameraRotation.Yaw = LastCamRot.Yaw + GetRotDiff(Rotation.Yaw + 32768, LastCamRot.Yaw) * LerpAmount;
      CameraRotation.Roll = 0;
      CameraRotation.Pitch = -4000;
   }
   else
   {*/
      CamLookAt = Location;
      CameraRotation.Roll = 0;
      CameraRotation.Yaw = LastCamRot.Yaw + GetRotDiff(Rotation.Yaw, LastCamRot.Yaw) * LerpAmount;
      CameraRotation.Pitch = -4000;
   //}

    CameraLocation = CamLookAt + (CameraDistance * vect(-1, 0, 0) >> CameraRotation);
    if( Trace( HitLocation, HitNormal, CameraLocation, CamLookAt, false, vect(10, 10, 10) ) != None )
    {
        CameraLocation = HitLocation;
    }

   LastCamRot = CameraRotation;
}

simulated function SpecialCalcFirstPersonView(PlayerController PC, out actor ViewActor, out vector CameraLocation, out rotator CameraRotation )
{
   local vector CamLookAt, HitLocation, HitNormal;
   local float LerpAmount;
   local float CurTime;

   ViewActor = self;

   CurTime = Level.TimeSeconds;
   LerpAmount = 1.0 - ( CameraSwingRatio ** (CurTime - LastCamTime) );
   LastCamTime = CurTime;

/*   if(bRearView)
   {
      CamLookAt = Location;
      CameraRotation.Yaw = LastCamRot.Yaw + GetRotDiff(Rotation.Yaw + 32768, LastCamRot.Yaw) * LerpAmount;
      CameraRotation.Roll = 0;
      CameraRotation.Pitch = -4000;
   }
   else
   {*/
      CamLookAt = Location;
      CameraRotation.Roll = 0;
      CameraRotation.Yaw = 16384 + LastCamRot.Yaw + GetRotDiff(Rotation.Yaw, LastCamRot.Yaw) * LerpAmount;
      CameraRotation.Pitch = -4000;
   //}

    CameraLocation = CamLookAt + (CameraDistance * vect(0, 1, 0) >> CameraRotation);
    if( Trace( HitLocation, HitNormal, CameraLocation, CamLookAt, false, vect(10, 10, 10) ) != None )
    {
        CameraLocation = HitLocation;
    }

   LastCamRot = CameraRotation;
}

defaultproperties
{
     CameraSwingRatio=0.020000
     CameraDistance=900.000000
}
