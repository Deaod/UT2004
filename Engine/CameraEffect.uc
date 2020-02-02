class CameraEffect extends Object
	abstract
	native
	noexport
	noteditinlinenew;

var float	Alpha;			// Used to transition camera effects. 0 = no effect, 1 = full effect
var bool	FinalEffect;	// Forces the renderer to ignore effects on the stack below this one.

var int cameraeffect_dummy;  // hammer padding.  --ryan.

//
//	Default properties
//

defaultproperties
{
     Alpha=1.000000
}
