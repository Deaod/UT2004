// SpecialVehicleObjectives are used to mark the end of special paths that a vehicle is required to reach, but have something a vehicle cannot
// get (like a pickup). Bots will only consider following one of these paths if it is enabled and the bot is controlling a vehicle of one the
// allowed classes. When they reach this point, they will exit the vehicle and continue to the associated actor on foot.

class SpecialVehicleObjective extends RoadPathNode;

var() array<class<Vehicle> > AccessibleVehicleClasses; //classes of vehicles that are capable of reaching this point
var() name AssociatedActorTag;
var() float MaxDist; //if greater than 0, bots will never go here unless they are already this close
var Actor AssociatedActor;
var bool bEnabled;
var SpecialVehicleObjective NextSpecialVehicleObjective;
var Pawn TeamOwner[4]; //AI pawns currently headed to this point

function PostBeginPlay()
{
	local UnrealMPGameInfo G;

	Super.PostBeginPlay();

	foreach AllActors(class'Actor', AssociatedActor, AssociatedActorTag)
		break;

	G = UnrealMPGameInfo(Level.Game);
	if (G != None)
	{
		NextSpecialVehicleObjective = G.SpecialVehicleObjectives;
		G.SpecialVehicleObjectives = self;
	}
}

function bool IsAccessibleTo(Pawn BotPawn)
{
	local int i;

	if (!bEnabled || (MaxDist > 0 && VSize(BotPawn.Location - Location) > MaxDist))
		return false;

	for (i = 0; i < AccessibleVehicleClasses.length; i++)
		if (ClassIsChildOf(BotPawn.Class, AccessibleVehicleClasses[i]))
			return true;

	return false;
}

function Trigger(Actor Other, Pawn EventInstigator)
{
	bEnabled = false;
}

function Untrigger(Actor Other, Pawn EventInstigator)
{
	if (AssociatedActor != None)
		bEnabled = true;
}

function Reset()
{
	bEnabled = false;
}

defaultproperties
{
     bNotBased=True
}
