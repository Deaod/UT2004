//=============================================================================
// MatObject
//
// A base class for all Matinee classes.  Just a convenient place to store
// common elements like enums.
//=============================================================================

class MatObject extends Object
	abstract
	native;

struct Orientation
{
	var() ECamOrientation	CamOrientation;
	var() actor LookAt;
	var() actor DollyWith;
	var() float EaseIntime;
	var() int bReversePitch;
	var() int bReverseYaw;
	var() int bReverseRoll;

	var pointer MA;
	var float PctInStart, PctInEnd, PctInDuration;
	var rotator StartingRotation;
};

defaultproperties
{
}
