//=============================================================================
// AIScript - used by Level Designers to specify special AI scripts for pawns 
// placed in a level, and to change which type of AI controller to use for a pawn.
// AIScripts can be shared by one or many pawns. 
// Game specific subclasses of AIScript will have editable properties defining game specific behavior and AI
// This is a built-in Unreal class and it shouldn't be modified.
//=============================================================================
class AIScript extends Keypoint 
	native
	placeable;

#exec Texture Import File=Textures\AIScript.pcx Name=S_AIScript Mips=Off MASKED=1

var()	class<AIController> ControllerClass;
var		bool		bNavigate;				// if true, put an associated path in the navigation network
var		bool		bLoggingEnabled;	
var		AIMarker	myMarker;

// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)

/* SpawnController()
Spawn and initialize an AI Controller (called by a non-player controlled Pawn at level startup)
*/
function SpawnControllerFor(Pawn P)
{
	local AIController C;

	if ( ControllerClass == None )
	{
		if ( P.ControllerClass == None )
			return;
		C = Spawn(P.ControllerClass,,,P.Location, P.Rotation);
	}
	else
		C = Spawn(ControllerClass,,,P.Location, P.Rotation);
	C.MyScript = self;
	C.Possess(P);
}

function Actor GetMoveTarget()
{
	if ( MyMarker != None )
		return MyMarker;
	return self;
}

function TakeOver(Pawn P);

defaultproperties
{
     Texture=Texture'Engine.S_AIScript'
     DrawScale=0.500000
}
