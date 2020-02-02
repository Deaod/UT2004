// ifdef WITH_LIPSinc

//=============================================================================
// Object to facilitate properties editing
//=============================================================================
//  LIPSinc Anim editor object to expose/shuttle only selected editable
//  parameters from TLIPSincAnimation objects back and forth in the editor.

class LIPSincAnimProps extends Object
	hidecategories(Object)
	native;	

// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)

var const int WBrowserLIPSincPtr;

var(Sound) Sound	Sound;

var(Properties) bool    bInterruptible;
var(Properties) float   BlendInTime;
var(Properties) float   BlendOutTime;


// endif

defaultproperties
{
     bInterruptible=True
     BlendInTime=160.000000
     BlendOutTime=220.000000
}
