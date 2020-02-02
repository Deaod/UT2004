class VariableTexPanner extends TexModifier
	editinlinenew
	native;

// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)

var() rotator PanDirection;
var() float PanRate;
var Matrix M;

var float LastTime;
var float PanOffset;

defaultproperties
{
     PanRate=0.100000
}
