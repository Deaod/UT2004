//-----------------------------------------------------------
//
//-----------------------------------------------------------
class ONSTreadCraft extends ONSVehicle
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

var		array<vector>		ThrusterOffsets;

var()	float				HoverSoftness;
var()	float				HoverPenScale;
var()	float				HoverCheckDist;

var()	float				UprightStiffness;
var()	float				UprightDamping;

var()	float				MaxThrust;
var()	float				MaxSteerTorque;
var()	float				ForwardDampFactor;
var()   float               TurnDampFactor;
var()	float				LateralDampFactor;
var()   float               ParkingDampFactor;
var()	float				SteerDampFactor;
var()	float				PitchTorqueFactor;
var()	float				PitchDampFactor;
var()	float				BankTorqueFactor;
var()	float				BankDampFactor;

var()	float				InvertSteeringThrottleThreshold;

// MPH meter
var		material			MPHMeterMaterial;
var()	float				MPHMeterPosX;
var()	float				MPHMeterPosY;
var()	float				MPHMeterScale;
var()	float				MPHMeterSizeY;

// Internal
var		float				BikeMPH;

var		float				OutputThrust;
var		float				OutputTurn;

// Replicated
struct native TreadCraftState
{
	var vector				ChassisPosition;
	var Quat				ChassisQuaternion;
	var vector				ChassisLinVel;
	var vector				ChassisAngVel;

	var byte				ServerThrust;
	var	byte				ServerTurn;
	var int                 ServerViewPitch;
	var int                 ServerViewYaw;
};

var		TreadCraftState		TreadState, OldTreadState;
var		KRigidBodyState		ChassisState;
var		bool				bNewTreadState;

replication
{
	reliable if (Role == ROLE_Authority)
		TreadState;
}

simulated event bool KUpdateState(out KRigidBodyState newState)
{
	// This should never get called on the server - but just in case!
	if(Role == ROLE_Authority || !bNewTreadState)
		return false;

	newState = ChassisState;
	bNewTreadState = false;

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

	KSetStayUprightParams( UprightStiffness, UprightDamping );
}

//function DrawHUD(Canvas Canvas)
//{
//	local Color WhiteColor;
//	local float XL, YL;
//
//	Super.DrawHUD(Canvas);
//
//	WhiteColor = class'Canvas'.Static.MakeColor(255,255,255);
//	Canvas.DrawColor = WhiteColor;
//
//	Canvas.Style = ERenderStyle.STY_Normal;
//	Canvas.StrLen("TEST", XL, YL);
//
//	// Draw rev meter
//	Canvas.SetPos(MPHMeterPosX * Canvas.ClipX, MPHMeterPosY * Canvas.ClipY);
//	Canvas.DrawTileStretched(MPHMeterMaterial, (BikeMPH/MPHMeterScale) * Canvas.ClipX, MPHMeterSizeY * Canvas.ClipY);
//
//	Canvas.SetPos( MPHMeterPosX * Canvas.ClipX, (MPHMeterSizeY + MPHMeterPosY) * Canvas.ClipY + YL );
//    Canvas.Font = class'HUD'.Static.GetConsoleFont(Canvas);
//	Canvas.DrawText(BikeMPH);
//}

defaultproperties
{
     MPHMeterMaterial=Texture'InterfaceContent.Menu.BorderBoxD'
     MPHMeterPosX=0.010000
     MPHMeterPosY=0.900000
     MPHMeterScale=70.000000
     MPHMeterSizeY=0.050000
}
