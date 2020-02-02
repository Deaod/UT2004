class MutVehicleArena extends Mutator
    config;

var config string ArenaVehicleClassName;
var class<SVehicle> ArenaVehicleClass;
var localized string ArenaDisplayText, ArenaDescText;
var array<string> VehicleClassNames;

function PostBeginPlay()
{
	local ONSVehicleFactory Factory;

	ArenaVehicleClass = class<SVehicle>( DynamicLoadObject(ArenaVehicleClassName,class'Class') );

	if(ArenaVehicleClass != None)
	{
		foreach AllActors( class 'ONSVehicleFactory', Factory )
		{
			Factory.VehicleClass = ArenaVehicleClass;
		}
	}

	Super.PostBeginPlay();
}

static function FillPlayInfo(PlayInfo PlayInfo)
{
	local string VehicleOptions;
	local class<SVehicle> cn;
	local int i;
	local array<class<SVehicle> > VehicleClasses;

	Super.FillPlayInfo(PlayInfo);

	for (i=0;i<default.VehicleClassNames.Length;i++)
	{
		cn = class<SVehicle>( DynamicLoadObject(default.VehicleClassNames[i],class'class') );
		if (cn!=None)
		{
			VehicleClasses.Length = VehicleClasses.Length + 1;
			VehicleClasses[VehicleClasses.Length-1] = cn;
		}
	}

	for (i=0; i<VehicleClasses.Length; i++)
	{
		if (VehicleOptions != "")
			VehicleOptions $= ";";

		VehicleOptions $= VehicleClasses[i] $ ";" $ VehicleClasses[i].default.VehicleNameString;
	}

	if(class'GUI2K4.UT2K4SP_Main'.default.bEnableTC)
		VehicleOptions $= ";" $ class'OnslaughtFull.ONSGenericSD' $ ";" $ class'OnslaughtFull.ONSGenericSD'.default.VehicleNameString;


	PlayInfo.AddSetting(default.RulesGroup, "ArenaVehicleClassName", default.ArenaDisplayText, 0, 1, "Select", VehicleOptions);
}

static event string GetDescriptionText(string PropName)
{
	if (PropName == "ArenaVehicleClassName")
		return default.ArenaDescText;

	return Super.GetDescriptionText(PropName);
}

defaultproperties
{
     ArenaVehicleClassName="Onslaught.ONSRV"
     ArenaDisplayText="Arena Vehicle"
     ArenaDescText="Determines which vehicle type will be used in the match."
     VehicleClassNames(0)="Onslaught.ONSRV"
     VehicleClassNames(1)="Onslaught.ONSPRV"
     VehicleClassNames(2)="Onslaught.ONSAttackCraft"
     VehicleClassNames(3)="Onslaught.ONSHoverBike"
     VehicleClassNames(4)="Onslaught.ONSHoverTank"
     VehicleClassNames(5)="OnslaughtBP.ONSDualAttackCraft"
     VehicleClassNames(6)="OnslaughtBP.ONSArtillery"
     VehicleClassNames(7)="OnslaughtBP.ONSShockTank"
     GroupName="VehicleArena"
     FriendlyName="Vehicle Arena"
     Description="Replace all vehicles in map with a particular type."
}
