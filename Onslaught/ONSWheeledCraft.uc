//-----------------------------------------------------------
//
//-----------------------------------------------------------
class ONSWheeledCraft extends ONSVehicle
	abstract
	native
	nativereplication;

#exec OBJ LOAD FILE=..\textures\InterfaceContent.utx
#exec OBJ LOAD FILE=..\textures\HudContent.utx

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
// (cpptext)
// (cpptext)

// wheel params
var()	float			WheelSoftness;
var()	float			WheelPenScale;
var()	float			WheelPenOffset;
var()	float			WheelRestitution;
var()	float			WheelAdhesion;
var()	float			WheelInertia;
var()	InterpCurve		WheelLongFrictionFunc;
var()	float			WheelLongSlip;
var()	InterpCurve		WheelLatSlipFunc;
var()	float			WheelLongFrictionScale;
var()	float			WheelLatFrictionScale;
var()	float			WheelHandbrakeSlip;
var()	float			WheelHandbrakeFriction;
var()	float			WheelSuspensionTravel;
var()	float			WheelSuspensionOffset;
var()	float			WheelSuspensionMaxRenderTravel;

var()	float			FTScale;
var()	float			ChassisTorqueScale;
var()	float			MinBrakeFriction;

var()	InterpCurve		MaxSteerAngleCurve; // degrees based on velocity
var()	InterpCurve		TorqueCurve; // Engine output torque
var()	float			GearRatios[5]; // 0 is reverse, 1-4 are forward
var()	int				NumForwardGears;
var()	float			TransRatio; // Other (constant) gearing
var()	float			ChangeUpPoint;
var()	float			ChangeDownPoint;
var()	float			LSDFactor;

var()	float			EngineBrakeFactor;
var()	float			EngineBrakeRPMScale;

var()	float			MaxBrakeTorque;
var()	float			SteerSpeed; // degrees per second
var()	float			TurnDamping;

var()	float			StopThreshold;
var()	float			HandbrakeThresh;

var()	float			EngineInertia; // Pre-gear box engine inertia (racing flywheel etc.)

var()	float			IdleRPM;
var()	float			EngineRPMSoundRange;

var()	name			SteerBoneName;
var()	EAxis			SteerBoneAxis;
var()	float			SteerBoneMaxAngle; // degrees

// Wheel dirt emitter
var     array<ONSDirtSlipEffect>    Dust; // FL, FR, RL, RR
var()   float                       DustSlipRate; // Ratio between dust kicked up and amount wheels are slipping
var()   float                       DustSlipThresh;

// Internal
var		float			OutputBrake;
var		float			OutputGas;
var		bool			OutputHandbrake;
var		int				Gear;

var		float			ForwardVel;
var		bool			bIsInverted;
var		bool			bIsDriving;
var		float			NumPoweredWheels;

var		float			TotalSpinVel;
var		float			EngineRPM;
var		float			CarMPH;
var		float			ActualSteering;

// Rev meter
var		material		RevMeterMaterial;
var()	float			RevMeterPosX;
var()	float			RevMeterPosY;
var()	float			RevMeterScale;
var()	float			RevMeterSizeY;

// Brake lights
var()	bool				bMakeBrakeLights;
var()	vector				BrakeLightOffset[2];
var		ONSBrakelightCorona	BrakeLight[2];
var()	Material			BrakeLightMaterial;

// Stunts
var		rotator				OldRotation;
var		vector				LastOnGroundLocation;
var		float				LastOnGroundTime;

var		float				InAirSpin; // Degrees
var		float				InAirPitch; // Degrees
var		float				InAirRoll; // Degrees
var		float				InAirTime; // Seconds
var		float				InAirDistance; // Meters

var		int					DaredevilPoints;

var()	float				DaredevilThreshInAirSpin;
var()	float				DaredevilThreshInAirPitch;
var()	float				DaredevilThreshInAirRoll;
var()	float				DaredevilThreshInAirTime;
var()	float				DaredevilThreshInAirDistance;
var()	class<LocalMessage>	DaredevilMessageClass;

struct native SCarState
{
	var vector				ChassisPosition;
	var Quat				ChassisQuaternion;
	var vector				ChassisLinVel;
	var vector				ChassisAngVel;

	var byte				ServerHandbrake;
	var byte				ServerBrake;
	var byte				ServerGas;
	var byte				ServerGear;
	var	byte				ServerSteering;
	var int                 ServerViewPitch;
	var int                 ServerViewYaw;
};

var		SCarState			CarState, OldCarState;
var		KRigidBodyState		ChassisState;
var		bool				bNewCarState;

var		bool				bOldVehicleOnGround;
var()	bool				bDoStuntInfo;
var()	bool				bAllowAirControl;
var()	bool				bAllowChargingJump;
var		bool				bAllowBigWheels;

// Jumping
var	bool				    bPushDown; //jump is being charged

var()	float				MaxJumpForce;
var     float               JumpForce;

var()	float				MaxJumpSpin;
var	    float               JumpSpin;

var()	float				JumpChargeTime;
var     float				DesiredJumpForce; //used by AI
var     string				JumpFeedbackForce;

var		sound				JumpSound;

var()	float				JumpMeterOriginX, JumpMeterOriginY;
var()	float				JumpMeterWidth, JumpMeterHeight, JumpMeterSpacing;
var()	color				JumpMeterColor, SpinMeterColor;
var     Texture				JumpMeterTexture;

// Air control
var		float				OutputPitch;
var()	float				AirTurnTorque;
var()	float				AirPitchTorque;
var()	float				AirPitchDamping; // This is on even if bAllowAirControl is false.
var()	float				AirRollTorque;
var()	float				AirRollDamping;
var()	float				MinAirControlDamping; // To limit max speed you can spin/flip at.

var     float				FenderBenderSpeed;

replication
{
	reliable if (Role == ROLE_Authority)
		CarState;
	reliable if (bNetInitial && Role == ROLE_Authority)
		bAllowAirControl, bAllowChargingJump;
	reliable if (bNetInitial && bAllowChargingJump && Role == ROLE_Authority)
		JumpChargeTime, MaxJumpForce, MaxJumpSpin;
	reliable if (bNetInitial && bDoStuntInfo && Role == ROLE_Authority)
		DaredevilThreshInAirDistance, DaredevilThreshInAirTime, DaredevilThreshInAirSpin, DaredevilThreshInAirPitch, DaredevilThreshInAirRoll;
}
///////////////////////////////////////////
/////////////// CREATION //////////////////
///////////////////////////////////////////

simulated function PostBeginPlay()
{
    LastOnGroundTime = Level.TimeSeconds;
    LastOnGroundLocation = Location;

    Super.PostBeginPlay();
}

simulated function PostNetBeginPlay()
{
    local int i;

	// Count the number of powered wheels on the car
	NumPoweredWheels = 0.0;
	for(i=0; i<Wheels.Length; i++)
	{
		NumPoweredWheels += 1.0;
	}

    Super.PostNetBeginPlay();
}

simulated function PrecacheAnnouncer(AnnouncerVoice V, bool bRewardSounds)
{
	if (bRewardSounds && !bSoundsPrecached)
		V.PrecacheSound('fender_bender');

	Super.PrecacheAnnouncer(V, bRewardSounds);
}

simulated function Destroyed()
{
    local int i;

	if(Level.NetMode != NM_DedicatedServer)
	{
        for(i=0; i<Dust.Length; i++)
            Dust[i].Destroy();

	   if(bMakeBrakeLights)
	   {
            if (BrakeLight[0] != None)
				BrakeLight[0].Destroy();

            if (BrakeLight[1] != None)
				BrakeLight[1].Destroy();
	   }
	}

    Super.Destroyed();
}

///////////////////////////////////////////
/////////////// NETWORKING ////////////////
///////////////////////////////////////////


simulated event bool KUpdateState(out KRigidBodyState newState)
{
	// This should never get called on the server - but just in case!
	if(Role == ROLE_Authority || !bNewCarState)
		return false;

	newState = ChassisState;
	bNewCarState = false;

	return true;
	//return false;
}

///////////////////////////////////////////
////////////////// OTHER //////////////////
///////////////////////////////////////////

simulated event SVehicleUpdateParams()
{
	local int i;

	Super.SVehicleUpdateParams();

	for(i=0; i<Wheels.Length; i++)
	{
		Wheels[i].Softness = WheelSoftness;
		Wheels[i].PenScale = WheelPenScale;
		Wheels[i].PenOffset = WheelPenOffset;
		Wheels[i].LongSlip = WheelLongSlip;
		Wheels[i].LatSlipFunc = WheelLatSlipFunc;
		Wheels[i].Restitution = WheelRestitution;
		Wheels[i].Adhesion = WheelAdhesion;
		Wheels[i].WheelInertia = WheelInertia;
		Wheels[i].LongFrictionFunc = WheelLongFrictionFunc;
		Wheels[i].HandbrakeFrictionFactor = WheelHandbrakeFriction;
		Wheels[i].HandbrakeSlipFactor = WheelHandbrakeSlip;
		Wheels[i].SuspensionTravel = WheelSuspensionTravel;
		Wheels[i].SuspensionOffset = WheelSuspensionOffset;
		Wheels[i].SuspensionMaxRenderTravel = WheelSuspensionMaxRenderTravel;
	}

	if(Level.NetMode != NM_DedicatedServer && bMakeBrakeLights)
	{
		for(i=0; i<2; i++)
		{
            if (BrakeLight[i] != None)
            {
				BrakeLight[i].SetBase(None);
				BrakeLight[i].SetLocation( Location + (BrakelightOffset[i] >> Rotation) );
				BrakeLight[i].SetBase(self);
				BrakeLight[i].SetRelativeRotation( rot(0,32768,0) );
				BrakeLight[i].Skins[0] = BrakeLightMaterial;
			}
		}
	}
}

simulated event DrivingStatusChanged()
{
	local int i;
	local Coords WheelCoords;

	Super.DrivingStatusChanged();

    if (bDriving && Level.NetMode != NM_DedicatedServer && !bDropDetail)
	{
        Dust.length = Wheels.length;
        for(i=0; i<Wheels.Length; i++)
            if (Dust[i] == None)
            {
        		// Create wheel dust emitters.
        		WheelCoords = GetBoneCoords(Wheels[i].BoneName);
        		Dust[i] = spawn(class'ONSDirtSlipEffect', self,, WheelCoords.Origin + ((vect(0,0,-1) * Wheels[i].WheelRadius) >> Rotation));
        		Dust[i].SetBase(self);
			    Dust[i].SetDirtColor( Level.DustColor );
        	}

		if(bMakeBrakeLights)
		{
			for(i=0; i<2; i++)
    			if (BrakeLight[i] == None)
    			{
    				BrakeLight[i] = spawn(class'ONSBrakelightCorona', self,, Location + (BrakeLightOffset[i] >> Rotation) );
    				BrakeLight[i].SetBase(self);
    				BrakeLight[i].SetRelativeRotation( rot(0,32768,0) ); // Point lights backwards.
    				BrakeLight[i].Skins[0] = BrakeLightMaterial;
    			}
		}
	}
    else
    {
        if (Level.NetMode != NM_DedicatedServer)
    	{
            for(i=0; i<Dust.Length; i++)
                Dust[i].Destroy();

            Dust.Length = 0;

            if(bMakeBrakeLights)
            {
            	for(i=0; i<2; i++)
                    if (BrakeLight[i] != None)
                        BrakeLight[i].Destroy();
            }
        }

        TurnDamping = 0.0;
    }
}

simulated function Tick(float dt)
{
    local int i;
    local bool lostTraction;

    Super.Tick(dt);

 	// Dont bother doing effects on dedicated server.
	if(Level.NetMode != NM_DedicatedServer && !bDropDetail)
	{
		lostTraction = true;

   		// Update dust kicked up by wheels.
   		for(i=0; i<Dust.Length; i++)
	   	   Dust[i].UpdateDust(Wheels[i], DustSlipRate, DustSlipThresh);

		if(bMakeBrakeLights)
		{
			for(i=0; i<2; i++)
                if (BrakeLight[i] != None)
                    BrakeLight[i].bCorona = True;

			for(i=0; i<2; i++)
                if (BrakeLight[i] != None)
                    BrakeLight[i].UpdateBrakelightState(OutputBrake, Gear);
		}
	}

	TurnDamping = default.TurnDamping;
}

function float ImpactDamageModifier()
{
    local float Multiplier;
    local vector X, Y, Z;

    GetAxes(Rotation, X, Y, Z);
    if (ImpactInfo.ImpactNorm Dot Z > 0)
        Multiplier = 1-(ImpactInfo.ImpactNorm Dot Z);
    else
        Multiplier = 1.0;

    return Super.ImpactDamageModifier() * Multiplier;
}

//function bool Dodge(eDoubleClickDir DoubleClickMove)
//{
//	if (bAllowChargingJump)
//	{
//		Rise = -1;
//		return true;
//	}
//
//	return false;
//}

simulated event KImpact(Actor Other, vector Pos, vector ImpactVel, vector ImpactNorm)
{
	Super.KImpact(Other, Pos, ImpactVel, ImpactNorm);

	if ( ONSWheeledCraft(Other) != None && ONSWheeledCraft(Other).bDriving && PlayerController(Controller) != None
	     && ONSWheeledCraft(Other).GetTeamNum() != Controller.GetTeamNum()
	     && VSize(ImpactVel) > FenderBenderSpeed && (vector(Rotation) Dot vector(Other.Rotation)) < 0 )
		PlayerController(Controller).ReceiveLocalizedMessage(class'ONSVehicleKillMessage', 7);
}

simulated function DrawHUD(Canvas C)
{
	local float JumpChargeAmount, SpinChargeAmount, BarHeight;
	local PlayerController PC;

    Super.DrawHUD(C);

	// Don't draw if we are dead, scoreboard is visible, etc
	PC = PlayerController(Controller);
	if (!bAllowChargingJump || Health < 1 || PC == None || PC.myHUD == None || PC.MyHUD.bShowScoreboard)
		return;

	// Draw background box
	C.Style = ERenderStyle.STY_Alpha;

	C.SetPos( JumpMeterOriginX * C.ClipX, JumpMeterOriginY * C.ClipY );

	//C.DrawColor = C.MakeColor(255,255,255,255);
	//C.DrawTile( Texture'HudContent.Generic.HUD', JumpMeterWidth * C.ClipX, JumpMeterHeight * C.ClipY, 125, 458, 166, 53);
	C.DrawColor = C.MakeColor(0,0,0,150);
	//C.DrawTile( Texture'HudContent.Generic.HUD', JumpMeterWidth * C.ClipX, JumpMeterHeight * C.ClipY, 168, 211, 166, 44);
	C.DrawTile( Texture'HudContent.Generic.HUD', JumpMeterWidth * C.ClipX, JumpMeterHeight * C.ClipY, 251, 211, 83, 44);

	// Draw charge bars
	C.Style = ERenderStyle.STY_Normal;

	BarHeight = 0.5 * (JumpMeterHeight - (3*JumpMeterSpacing));

	JumpChargeAmount = FClamp( JumpForce/MaxJumpForce, 0.0, 1.0 );
	C.DrawColor	= JumpMeterColor;
	C.SetPos( (JumpMeterOriginX+JumpMeterSpacing) * C.ClipX, (JumpMeterOriginY+JumpMeterSpacing) * C.ClipY );
	C.DrawTile(JumpMeterTexture, (JumpMeterWidth-(2*JumpMeterSpacing)) * C.ClipX * JumpChargeAmount, BarHeight * C.ClipY, 0, 0, JumpMeterTexture.USize, JumpMeterTexture.VSize*JumpChargeAmount);

	SpinChargeAmount = FClamp( Abs(JumpSpin)/MaxJumpSpin, 0.0, 1.0 );
	C.DrawColor	= SpinMeterColor;
	C.SetPos( (JumpMeterOriginX+JumpMeterSpacing) * C.ClipX, (JumpMeterOriginY+(2*JumpMeterSpacing)+BarHeight) * C.ClipY );
	C.DrawTile(JumpMeterTexture, (JumpMeterWidth-(2*JumpMeterSpacing)) * C.ClipX * SpinChargeAmount, BarHeight * C.ClipY, 0, 0, JumpMeterTexture.USize, JumpMeterTexture.VSize*SpinChargeAmount);
}

//if bAllowChargingJump is true, this will be called just BEFORE the vehicle does a jump
simulated event Jumping()
{
	ClientPlayForceFeedback(JumpFeedbackForce);

	if( JumpSound != None )
		PlaySound( JumpSound,, 2.5*TransientSoundVolume );
}

simulated event SetWheelsScale(float NewScale)
{
	local int i;

	Super.SetWheelsScale(NewScale);

	if(!bAllowBigWheels)
		return;

	for(i=0; i<Wheels.Length; i++)
	{
		SetBoneScale(i, NewScale, Wheels[i].BoneName);
	}
}

simulated event OnDaredevil()
{
	local PlayerController PC;
	local TeamPlayerReplicationInfo PRI;

	PC = PlayerController(Controller);
	if (PC != None)
	{
        if (Level.NetMode != NM_DedicatedServer)
        {
    		PC.ReceiveLocalizedMessage(DaredevilMessageClass, 0, None, None, self);
    		PC.ReceiveLocalizedMessage(DaredevilMessageClass, 1, None, None, self);
    	}

        if (Role == ROLE_Authority)
        {
    		PRI = TeamPlayerReplicationInfo(PC.PlayerReplicationInfo);
    		if(PRI != None)
    		{
    			PRI.DaredevilPoints += DaredevilPoints;
    		}
    	}
	}
}

function int LimitPitch(int pitch)
{
	if (bAllowAirControl && !bVehicleOnGround)
		return pitch;

	return Super.LimitPitch(pitch);
}

defaultproperties
{
     NumForwardGears=4
     DustSlipRate=2.800000
     DustSlipThresh=50.000000
     DaredevilThreshInAirSpin=100.000000
     DaredevilThreshInAirPitch=300.000000
     DaredevilThreshInAirRoll=300.000000
     DaredevilThreshInAirTime=1.500000
     DaredevilThreshInAirDistance=17.000000
     DaredevilMessageClass=Class'Onslaught.ONSDaredevilMessage'
     bOldVehicleOnGround=True
     MaxJumpForce=200000.000000
     MaxJumpSpin=30000.000000
     JumpChargeTime=1.000000
     JumpFeedbackForce="HoverBikeJump"
     JumpSound=Sound'ONSVehicleSounds-S.Hydraulics.Hydraulic10'
     JumpMeterOriginX=0.275000
     JumpMeterOriginY=0.943000
     JumpMeterWidth=0.136000
     JumpMeterHeight=0.057000
     JumpMeterSpacing=0.010000
     JumpMeterColor=(R=215,A=255)
     SpinMeterColor=(B=215,G=100,A=255)
     JumpMeterTexture=Texture'Engine.WhiteTexture'
     MinAirControlDamping=0.100000
     FenderBenderSpeed=750.000000
     bCanFlip=True
     CenterSpringRangePitch=5000
     CenterSpringRangeRoll=5000
     StolenAnnouncement="Car_jacked"
}
