//-----------------------------------------------------------
//
//-----------------------------------------------------------
class ONSVehicleFactory extends SVehicleFactory
    abstract
	placeable;

var()   float           RespawnTime;
var     float           PreSpawnEffectTime;
var()   bool            bReverseBlueTeamDirection;
var     bool            bActive;
var     bool            bNeverActivate;
var     bool            bPreSpawn; // Neither the vehicle or build effect have been spawned yet
var     class<Emitter>  RedBuildEffectClass, BlueBuildEffectClass;
var     Emitter         BuildEffect;
var     int             TeamNum;
var	    Vehicle		    LastSpawned;

simulated event PostBeginPlay()
{
	Super.PostBeginPlay();

    if ( Level.NetMode != NM_DedicatedServer )
		VehicleClass.static.StaticPrecache(Level);
}

simulated function UpdatePrecacheMaterials()
{
    Level.AddPrecacheMaterial(Material'VMParticleTextures.buildEffects.PC_buildBorderNew');
    Level.AddPrecacheMaterial(Material'VMParticleTextures.buildEffects.PC_buildStreaks');
    VehicleClass.static.StaticPrecache(Level);
}

function PostNetBeginPlay()
{
	local GameObjective O, Best;
	local float BestDist, NewDist;

    Super.PostNetBeginPlay();

    if ( !bDeleteMe && !Level.Game.IsA('ONSOnslaughtGame') )
    {
		ForEach AllActors(class'GameObjective',O)
		{
			NewDist = VSize(Location - O.Location);
			if ( (Best == None) || (NewDist < BestDist) )
			{
				Best = O;
				BestDist = NewDist;
			}
		}

		if ( Best != None )
			Activate(Best.DefenderTeamIndex);
	}
}

function Activate(byte T)
{
    if (!bNeverActivate && (!bActive || TeamNum != T))
    {
        TeamNum = T;
        bActive = True;
        bPreSpawn = True;
        Timer();
    }
}

function Deactivate()
{
    bActive = False;
}

event VehicleDestroyed(Vehicle V)
{
	Super.VehicleDestroyed(V);

    bPreSpawn = True;
    SetTimer(RespawnTime - PreSpawnEffectTime, False);
}

function SpawnVehicle()
{
	local Pawn P;
	local bool bBlocked;

    foreach CollidingActors(class'Pawn', P, VehicleClass.default.CollisionRadius * 1.25)
	{
		bBlocked = true;
		if (PlayerController(P.Controller) != None)
			PlayerController(P.Controller).ReceiveLocalizedMessage(class'ONSOnslaughtMessage', 11);
	}

    if (bBlocked)
    	SetTimer(1, false); //try again later
    else
    {
        if (bReverseBlueTeamDirection && ONSOnslaughtGame(Level.Game) != None && ((TeamNum == 1 && !ONSOnslaughtGame(Level.Game).bSidesAreSwitched) || (TeamNum == 0 && ONSOnslaughtGame(Level.Game).bSidesAreSwitched)))
            LastSpawned = spawn(VehicleClass,,, Location, Rotation + rot(0,32768,0));
        else
            LastSpawned = spawn(VehicleClass,,, Location, Rotation);

		if (LastSpawned != None )
		{
			VehicleCount++;
			LastSpawned.SetTeamNum(TeamNum);
			LastSpawned.Event = Tag;
			LastSpawned.ParentFactory = Self;
			TriggerEvent(Event, Self, LastSpawned);
		}
    }
}

// General purpose check to make sure there aren't any pawns in the way
function bool ValidateSpawnLocation(float Radius)
{
    local Pawn P;

    foreach CollidingActors(class'Pawn', P, Radius)
		return False;

    return True;
}

function SpawnBuildEffect()
{
    local rotator YawRot;

    YawRot = Rotation;
    YawRot.Roll = 0;
    YawRot.Pitch = 0;

    if (TeamNum == 0)
       BuildEffect = spawn(RedBuildEffectClass,,, Location, YawRot);
    else
       BuildEffect = spawn(BlueBuildEffectClass,,, Location, YawRot);
}

function Timer()
{
	if (bActive && Level.Game.bAllowVehicles && VehicleCount < MaxVehicleCount)
	{
        if (bPreSpawn)
        {
            bPreSpawn = False;
            SpawnBuildEffect();
            SetTimer(PreSpawnEffectTime, False);
        }
        else
    	   SpawnVehicle();
    }
}

// Onslaught doesn't use the trigger system
event Trigger( Actor Other, Pawn EventInstigator )
{
}

defaultproperties
{
     RespawnTime=15.000000
     PreSpawnEffectTime=2.000000
     RedBuildEffectClass=Class'Onslaught.ONSVehicleBuildEffect'
     BlueBuildEffectClass=Class'Onslaught.ONSVehicleBuildEffect'
     DrawType=DT_Mesh
}
