class TexOscillator extends TexModifier
	editinlinenew
	native;

// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)

enum ETexOscillationType
{
	OT_Pan,
	OT_Stretch,
	OT_StretchRepeat,
	OT_Jitter
};

var() Float UOscillationRate;
var() Float VOscillationRate;
var() Float UOscillationPhase;
var() Float VOscillationPhase;
var() Float UOscillationAmplitude;
var() Float VOscillationAmplitude;
var() ETexOscillationType UOscillationType;
var() ETexOscillationType VOscillationType;
var() float UOffset;
var() float VOffset;

var Matrix M;

// current state for OT_Jitter.
var float LastSu;
var float LastSv;
var float CurrentUJitter;
var float CurrentVJitter;

defaultproperties
{
     UOscillationRate=1.000000
     VOscillationRate=1.000000
     UOscillationAmplitude=0.100000
     VOscillationAmplitude=0.100000
}
