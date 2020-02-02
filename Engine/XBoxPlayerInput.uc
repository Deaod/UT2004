class XBoxPlayerInput extends PlayerInput
	config(User)
	transient;

const InputMax = 32768;

var() config float  HScale;
var() config float  HExponent;
var() config float  HLookRateMax;
var() config float  VScale;
var() config float  VExponent;
var() config float  VLookRateMax;
var() config bool   bInvertVLook;
var() config bool   bLookSpring;
var() float         HLook;
var() float         VLook;
var() float         abx, abz; //tmp
var() float         wfor,wstr; //tmp
var() float         wafor,wastr; //tmp

struct LookPreset
{
    var() localized string  PresetName;
    var() float             HScale;
    var() float             HExponent;
    var() float             VScale;
    var() float             VExponent;
};

const NumPresets=4;
var() config LookPreset     LookPresets[NumPresets];
var() config string         SelectedPresetName;
 
var() float                 VelScale;
var() float                 AccelScale;
var() float                 DampeningFactor;
var() float                 MinAccelComponent;

const MaxFilterEntries=4;
var() float                 ForwardFilter[MaxFilterEntries];
var() float                 StrafeFilter[MaxFilterEntries];

// Postprocess the player's input.
function PlayerInput( float DeltaTime )
{
    local float FOVScale;

    if (bSnapLevel != 0)
        bCenterView = true;
    else if (aBaseZ != 0)
        bCenterView = false;

    abx = aBaseX; //tmp
    abz = aBaseZ; //tmp

    if (bInvertVLook)
        aBaseZ *= -1.f;

    // Remap the turn inputs to an exponential curve
    HLook = Remap(aBaseX, HScale, HExponent, HLookRateMax);
    VLook = Remap(aBaseZ, VScale, VExponent, VLookRateMax);

	// Check for Double click move
	// flag transitions
	bEdgeForward    = (bWasForward  ^^ (aBaseY  > 0));
	bEdgeBack       = (bWasBack     ^^ (aBaseY  < 0));
	bEdgeRight      = (bWasRight    ^^ (aStrafe > 0));
	bEdgeLeft       = (bWasLeft     ^^ (aStrafe < 0));
	bWasForward     = (aBaseY  > 0);
	bWasBack        = (aBaseY  < 0);
	bWasRight       = (aStrafe > 0);
	bWasLeft        = (aStrafe < 0);

    // Map to other input axes
    aForward = aBaseY;
 //   if (Pawn != None)
//	    VelToAccel(deltaTime);

    FOVScale = DesiredFOV * 0.01; //should be 1/defaultFOV
    aTurn    = HLook * FOVScale;
    aLookUp  = VLook * FOVScale;
    
	// Handle walking.
	HandleWalking();
}

// exp remap + linear remap
static function float Remap(float in, float scale, float exp, float ratemax)
{
    local float out;
    local bool bNeg;

    in /= InputMax;

    if (in < 0)
    {
        bNeg = true;
        in *= -1.f;
    }

    out = (in * scale) + (in**exp);

    if (bNeg)
        out *= -1.f;

    out *= ratemax/(1.f + scale);

    return out;
}

//try doing this a a vector, instead of components
function VelToAccel(float dt)
{
    local vector x, y, z;
    
    // tmp
    wfor = aForward*VelScale;
    wstr = aStrafe*VelScale;

    GetAxes(Pawn.Rotation, x, y, z);
    aForward = GetComponentAccel(aForward, x, dt, ForwardFilter);
    aStrafe  = GetComponentAccel(aStrafe,  y, dt, StrafeFilter);

    // tmp
    wafor = aForward;
    wastr = aStrafe;
}

function float GetComponentAccel(float input, vector dir, float dt, out float filter[MaxFilterEntries], optional bool blog)
{
    local float speed;
    local float error; 
    local float output;

    // No input ... early out
    if (input == 0.f)
        return FilterOutput(filter, input);

    speed = Pawn.Velocity dot dir;
    error = input*VelScale - speed;

    output = DampeningFactor * error * AccelScale * dt;

    if (sign(output) != sign(input))
        output = MinAccelComponent * sign(input);

    output = FilterOutput(filter, output);

    if (blog) log(Level.TimeSeconds$"    "$input*VelScale$"    "$speed$"    "$error$"    "$output);

    return output;
}

function float sign(float in)
{
    if (in != 0.f)
        return Abs(in) / in;
    return 0.f;
}

function float FilterOutput(out float filter[MaxFilterEntries], float output)
{
    local int i;
    local float total;

    output /= MaxFilterEntries;

    for (i=0; i<MaxFilterEntries-1; i++)
    {
        filter[i] = filter[i+1];
        total += filter[i];
    }
    filter[i] = output;
    total += output;

    return total;
}

function bool InvertLook()
{
    bInvertVLook = !bInvertVLook;
    return bInvertVLook;
}

defaultproperties
{
     HExponent=1.000000
     HLookRateMax=1500.000000
     VExponent=1.000000
     VLookRateMax=750.000000
     bInvertVLook=True
     LookPresets(0)=(PresetName="Linear",HExponent=1.000000,VExponent=1.000000)
     LookPresets(1)=(PresetName="Exponential",HExponent=2.000000,VExponent=2.000000)
     LookPresets(2)=(PresetName="Hybrid",HScale=0.500000,HExponent=4.000000,VScale=0.500000,VExponent=4.000000)
     LookPresets(3)=(PresetName="Custom",HScale=0.500000,HExponent=4.000000,VScale=0.500000,VExponent=4.000000)
     SelectedPresetName="Hybrid"
     VelScale=0.013400
     AccelScale=4.655000
     DampeningFactor=30.000000
     MinAccelComponent=0.100000
}
