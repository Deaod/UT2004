//=============================================================================
// SVehicle spawner location.
//=============================================================================

class SVehicleFactory extends Actor
	native
	placeable;

#exec Texture Import File=Textures\S_KVehFact.pcx Name=S_KVehFact Mips=Off MASKED=1

var()	class<Vehicle>		VehicleClass;

var()	int					MaxVehicleCount;
var		int					VehicleCount;
var     NavigationPoint     MyMarker;

// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)

function PreBeginPlay()
{
	if (!Level.Game.bAllowVehicles && !bNoDelete)
	{
		Destroy();
		return;
	}

	Super.PreBeginPlay();
}

event VehicleDestroyed( Vehicle V )
{
	VehicleCount--;
}

event VehiclePossessed( Vehicle V );
event VehicleUnPossessed( Vehicle V );


event Trigger( Actor Other, Pawn EventInstigator )
{
	local Vehicle CreatedVehicle;

	if (!Level.Game.bAllowVehicles)
		return;

	if ( VehicleClass == None )
	{
		Log("SVehicleFactory:"@self@"has no VehicleClass");
		return;
	}

	if ( !EventInstigator.IsA('UnrealPawn') )
		return;

	if ( VehicleCount >= MaxVehicleCount )
	{
		// Send a message saying 'too many vehicles already'
		return;
	}

	if ( VehicleClass != None )
	{
		CreatedVehicle = spawn(VehicleClass, , , Location, Rotation);
		if ( CreatedVehicle != None )
		{
			VehicleCount++;
			CreatedVehicle.ParentFactory = self;
		}
	}
}

defaultproperties
{
     MaxVehicleCount=1
     bHidden=True
     bNoDelete=True
     RemoteRole=ROLE_None
     Texture=Texture'Engine.S_KVehFact'
     bDirectional=True
}
