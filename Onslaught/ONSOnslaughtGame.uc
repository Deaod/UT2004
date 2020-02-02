//-----------------------------------------------------------
//
//-----------------------------------------------------------

class ONSOnslaughtGame extends xTeamGame;

var array<ONSPowerCore>         PowerCores;
var int                         FinalCore[2];

// GameUMenuType - This menu is displayed to players when they die - it should contain the map for choosing where to respawn at

struct PowerLinkSetup
{
	var name BaseNode;
	var array<name> LinkedNodes;
};

var array<ONSPowerLinkOfficialSetup> OfficialPowerLinkSetups;
var array<ONSPowerLinkCustomSetup> CustomPowerLinkSetups;
var array<PowerLink> PowerLinks;

var config int OvertimeCoreDrainPerSec;
var config bool bRandSetupAfterReset;	//choose a random link setup to play after a reset
var config bool bSwapSidesAfterReset;
var bool        bSidesAreSwitched;

var bool bCurrentSetupIsOfficial;
var string CurrentSetupName;

// localized PlayInfo descriptions & extra info
const ONSPROPNUM = 3;
var localized string ONSPropsDisplayText[ONSPROPNUM];
var localized string ONSPropDescText[ONSPROPNUM];

var(LoadingHints) private localized array<string> ONSHints;

function bool AllowTransloc()
{
	return false;
}

static function bool NeverAllowTransloc()
{
	return true;
}

static function bool AllowMutator( string MutatorClassName )
{
	if ( MutatorClassName == "" )
		return false;

	if ( MutatorClassName ~= "xGame.MutInstagib" )
		return false;
	if ( MutatorClassName ~= "xGame.MutZoomInstagib" )
		return false;

	return super.AllowMutator(MutatorClassName);
}

event SetGrammar()
{
	LoadSRGrammar("ONS");
}

function bool ApplyOrder( PlayerController Sender, int RecipientID, int OrderID )
{
	local controller P;

	if ( OrderID == 299 )
	{
		for ( P=Level.ControllerList; P!= None; P=P.NextController )
		{
			if ( (Bot(P) != None) && (Bot(P).Pawn != None) && (P.PlayerReplicationInfo != None) && (P.PlayerReplicationInfo.Team == Sender.PlayerReplicationInfo.Team)
				&& ((RecipientID == -1) || (RecipientID == P.PlayerReplicationInfo.TeamID)) )
			{
				Bot(P).GetOutOfVehicle();
				if ( RecipientID == P.PlayerReplicationInfo.TeamID )
					break;
			}
		}
		return true;
	}

	return Super.ApplyOrder(Sender,RecipientID,OrderID);
}

function int ParseOrder(string OrderString)
{
	if ( OrderString == "GET OUT" )
		return 299;
	return Super.ParseOrder(OrderString);
}

static function PrecacheGameAnnouncements(AnnouncerVoice V, bool bRewardSounds)
{
	Super.PrecacheGameAnnouncements(V,bRewardSounds);
	if ( !bRewardSounds )
	{
		V.PrecacheSound('Red_powernode_destroyed');
		V.PrecacheSound('Blue_powernode_destroyed');
		V.PrecacheSound('Red_Powercore_under_attack');
		V.PrecacheSound('Blue_Powercore_under_attack');
		V.PrecacheSound('NewRoundIn');
		V.PrecacheSound('Red_Powercore_destroyed');
		V.PrecacheSound('Blue_Powercore_destroyed');
		V.PrecacheSound('Red_Powercore_critical');
		V.PrecacheSound('Blue_Powercore_critical');
		V.PrecacheSound('Red_Powercore_vulnerable');
		V.PrecacheSound('Blue_Powercore_vulnerable');
		V.PrecacheSound('Red_Powernode_under_construction');
		V.PrecacheSound('Blue_Powernode_under_construction');
		V.PrecacheSound('Red_powercore_damaged');
		V.PrecacheSound('Blue_powercore_damaged');
		V.PrecacheSound('Red_powernode_isolated');
		V.PrecacheSound('Blue_powernode_isolated');
	}
}

function SetInitialState()
{
    Super.SetInitialState();

    SetCoreDistance(PowerCores[FinalCore[0]], 0, 0);
    SetCoreDistance(PowerCores[FinalCore[1]], 1, 0);

    UpdateLinks();
}

event InitGame(string Options, out string Error)
{
	local string InOpt, MapName;
	local ONSPowerLinkOfficialSetup P;
	local int x;
	local NavigationPoint N;
	local array<string> CustomPowerLinkSetupNames;

	Super.InitGame(Options, Error);

	x = 0;
	for(N = Level.NavigationPointList; N != None; N = N.NextNavigationPoint)
	{
		// Reset all PlayerStarts so that the PowerCores can determine their team and Pre-Rate them
		if (N.IsA('PlayerStart'))
			PlayerStart(N).bEnabled = False;

		// Register all the PowerCores
		if (N.IsA('ONSPowerCore'))
		{
			PowerCores[x] = ONSPowerCore(N);
			PowerCores[x].NotifyUpdateLinks = UpdateLinks;
			PowerCores[x].OnCoreDestroyed = MainCoreDestroyed;

			if (PowerCores[x].bFinalCore)
				FinalCore[PowerCores[x].DefenderTeamIndex] = x;
			x++;
		}
	}

	if (PowerCores.Length == 0)
	{
		log("Onslaught: Level doesn't have any PowerCores!",'Error');
		return;
	}

	MapName = Left(string(Level), InStr(string(Level), "."));

	OfficialPowerLinkSetups.length = 0;
	foreach AllActors(class'ONSPowerLinkOfficialSetup', P)
		OfficialPowerLinkSetups[OfficialPowerLinkSetups.length] = P;

	//For PerObjectConfig objects, the Outer overrides the default config file name.
	//This means by giving the Level as the Outer, the .ini name will be the same as the map name,
	//which is really cool because it makes it easy to trade custom setups - just copy that map's .ini
	CustomPowerLinkSetupNames = class'ONSPowerLinkCustomSetup'.static.GetPerObjectNames(MapName);
	for (x = 0; x < CustomPowerLinkSetupNames.length; x++)
		CustomPowerLinkSetups[CustomPowerLinkSetups.length] = new(Level, CustomPowerLinkSetupNames[x]) class'ONSPowerLinkCustomSetup';

	InOpt = ParseOption(Options, "bRandSetupAfterReset");
	if (InOpt != "")
		bRandSetupAfterReset = bool(InOpt);

	InOpt = ParseOption(Options, "LinkSetup");
	if (InOpt ~= "Random")
	{
		FindLinkSetup();
		return;
	}
	if (InOpt == "" || !SetPowerLinkSetup(InOpt, None))
	{
		if (!SetPowerLinkSetup("Default", None))
			FindLinkSetup();
	}

	// Big hack.. you shouldn't break scope this way :)

 	InOpt = ParseOption(Options,"BonusVehicles");
	if ( bool(InOpt) )
	{
		AddMutator("OnslaughtBP.MutBonusVehicles");
	}

}

event PostBeginPlay()
{
	SetupLinks();
	Super.PostBeginPlay();
}

function bool SetupExists(string SetupName)
{
	local int x;

	for (x = 0; x < OfficialPowerLinkSetups.length; x++)
		if (OfficialPowerLinkSetups[x].SetupName ~= SetupName)
			return true;

	for (x = 0; x < CustomPowerLinkSetups.length; x++)
		if (string(CustomPowerLinkSetups[x].Name) ~= SetupName)
			return true;

	return false;
}

function bool SetPowerLinkSetup(string SetupName, PlayerController Caller)
{
	local int x, y, z, i;
	local array<ONSPowerCore> Traveled;

	SetupName = Repl(SetupName, " ", "_");

	for (x = 0; x < OfficialPowerLinkSetups.length; x++)
		if (OfficialPowerLinkSetups[x].SetupName ~= SetupName)
		{
			//activate this setup
			for (y = 0; y < OfficialPowerLinkSetups[x].LinkSetups.length; y++)
				for (z = 0; z < PowerCores.length; z++)
					if (PowerCores[z].Name == OfficialPowerLinkSetups[x].LinkSetups[y].BaseNode)
						PowerCores[z].LinkedNodes = OfficialPowerLinkSetups[x].LinkSetups[y].LinkedNodes;
			ResetPowerLinks();
			Log("Using Official Link Setup: "$SetupName);
			CurrentSetupName = SetupName;
			bCurrentSetupIsOfficial = true;
			if (Caller != None)
				Caller.ReceiveLocalizedMessage(class'ONSLinkDesignMessage', 2);
			return true;
		}

	for (x = 0; x < CustomPowerLinkSetups.length; x++)
		if (string(CustomPowerLinkSetups[x].Name) ~= SetupName)
		{
			//activate this setup
			for (y = 0; y < CustomPowerLinkSetups[x].LinkSetups.length; y++)
				for (z = 0; z < PowerCores.length; z++)
					if (PowerCores[z].Name == CustomPowerLinkSetups[x].LinkSetups[y].BaseNode)
						PowerCores[z].LinkedNodes = CustomPowerLinkSetups[x].LinkSetups[y].LinkedNodes;
			ResetPowerLinks();
			if (PowerLinks.length > 0 && !ExistsLinkPathTo(PowerCores[FinalCore[0]], PowerCores[FinalCore[1]], Traveled))
			{
				//trying to load an invalid setup, revert to previous one
				CustomPowerLinkSetups.Remove(x, 1);
				if (Caller != None)
					Caller.ReceiveLocalizedMessage(class'ONSLinkDesignMessage', 8);
				else
					Log("Failed to load Custom Link Setup"@SetupName$": There is not a complete path between the PowerCores.");
				if (CurrentSetupName != "" && CurrentSetupName != SetupName && SetPowerLinkSetup(CurrentSetupName, None))
					return true;
				if (OfficialPowerLinkSetups.Length > 0)
				{
					FindLinkSetup();
					return true;
				}
				Log("Can't find a better link setup to load, so using"@SetupName@" anyway and forcing a connection between the PowerCores.");
				AddLink(PowerCores[FinalCore[0]], PowerCores[FinalCore[1]]);
				UpdateLinks();
				for (i = 0; i < GameReplicationInfo.PRIArray.Length; i++)
					if (PlayerController(GameReplicationInfo.PRIArray[i].Owner) != None && ONSPlayerReplicationInfo(GameReplicationInfo.PRIArray[i]) != None)
						ONSPlayerReplicationInfo(GameReplicationInfo.PRIArray[i]).ClientReceivePowerLink(PowerCores[FinalCore[0]], PowerCores[FinalCore[1]]);
				return true;
			}
			Log("Using Custom Link Setup: "$SetupName);
			CurrentSetupName = SetupName;
			bCurrentSetupIsOfficial = false;
			if (Caller != None)
				Caller.ReceiveLocalizedMessage(class'ONSLinkDesignMessage', 2);
			return true;
		}

	if (Caller != None)
		Caller.ReceiveLocalizedMessage(class'ONSLinkDesignMessage', 3);
	return false;
}

function ClearLinks()
{
	local int i;

	for ( i = 0; i < PowerLinks.Length; i++ )
		if ( PowerLinks[i] != None )
			PowerLinks[i].Destroy();

	PowerLinks.Remove(0, PowerLinks.Length);
}

function ResetPowerLinks()
{
	local int x;
	local ONSPlayerReplicationInfo PRI;

	if ( PowerLinks.Length == 0 )
		return;

	ClearLinks();

	for ( x = 0; x < PowerCores.Length; x++ )
		PowerCores[x].ResetLinks();

	SetupLinks();

	if (GameReplicationInfo != None)
	{
		for (x = 0; x < GameReplicationInfo.PRIArray.length; x++)
		{
			PRI = ONSPlayerReplicationInfo(GameReplicationInfo.PRIArray[x]);
			if ( PRI == None || PlayerController(PRI.Owner) == None )
				continue;

			PRI.ClientPrepareToReceivePowerLinks();
		}
	}
}

//Save a powercore link setup. Returns true if it successfully created a NEW setup and neither failed nor overwrote an old setup
function bool SavePowerLinkSetup(string SetupName, PlayerController Caller)
{
	local int x, y, z;
	local PowerLinkSetup BlankSetup;
	local string MapName;

	MapName = Left(string(Level), InStr(string(Level), "."));
	SetupName = Repl(SetupName, " ", "_");

	for (x = 0; x < OfficialPowerLinkSetups.length; x++)
		if (OfficialPowerLinkSetups[x].SetupName ~= SetupName)
		{
			Caller.ReceiveLocalizedMessage(class'ONSLinkDesignMessage', 1);
			return false;
		}

	for (x = 0; x < CustomPowerLinkSetups.length; x++)
		if (string(CustomPowerLinkSetups[x].Name) ~= SetupName)
		{
			//overwrite
			CustomPowerLinkSetups[x].LinkSetups.length = 0;
			for (y = 0; y < PowerCores.length; y++)
			{
				CustomPowerLinkSetups[x].LinkSetups[y] = BlankSetup;
				CustomPowerLinkSetups[x].LinkSetups[y].BaseNode = PowerCores[y].Name;
				for (z = 0; z < PowerCores[y].PowerLinks.length; z++)
					CustomPowerLinkSetups[x].LinkSetups[y].LinkedNodes[z] = PowerCores[y].PowerLinks[z].Name;
			}
			CustomPowerLinkSetups[x].SaveConfig();
			Caller.ReceiveLocalizedMessage(class'ONSLinkDesignMessage', 0);
			return false;
		}

	//save new
	x = CustomPowerLinkSetups.length;
	CustomPowerLinkSetups.length = CustomPowerLinkSetups.length + 1;
	CustomPowerLinkSetups[x] = new(Level, SetupName) class'ONSPowerLinkCustomSetup';
	CustomPowerLinkSetups[x].LinkSetups.length = 0;
	for (y = 0; y < PowerCores.length; y++)
	{
		CustomPowerLinkSetups[x].LinkSetups[y] = BlankSetup;
		CustomPowerLinkSetups[x].LinkSetups[y].BaseNode = PowerCores[y].Name;
		for (z = 0; z < PowerCores[y].PowerLinks.length; z++)
			CustomPowerLinkSetups[x].LinkSetups[y].LinkedNodes[z] = PowerCores[y].PowerLinks[z].Name;
	}
	CustomPowerLinkSetups[x].SaveConfig();
	Caller.ReceiveLocalizedMessage(class'ONSLinkDesignMessage', 0);

	return true;
}

//Deletes a powercore link setup. Returns true if successful, false if not
function bool DeletePowerLinkSetup(string SetupName, PlayerController Caller)
{
	local int x;
	local string MapName;

	MapName = Left(string(Level), InStr(string(Level), "."));
	SetupName = Repl(SetupName, " ", "_");

	for (x = 0; x < OfficialPowerLinkSetups.length; x++)
		if (OfficialPowerLinkSetups[x].SetupName ~= SetupName)
		{
			Caller.ReceiveLocalizedMessage(class'ONSLinkDesignMessage', 5);
			return false;
		}

	for (x = 0; x < CustomPowerLinkSetups.length; x++)
		if (string(CustomPowerLinkSetups[x].Name) ~= SetupName)
		{
			CustomPowerLinkSetups[x].ClearConfig();
			CustomPowerLinkSetups.Remove(x, 1);
			Caller.ReceiveLocalizedMessage(class'ONSLinkDesignMessage', 4);
			return true;
		}

	Caller.ReceiveLocalizedMessage(class'ONSLinkDesignMessage', 6);
	return false;
}

function FindLinkSetup(optional string IgnoredSetup)
{
	local int i, Sanity, TotalNumSetups;
	local string NewSetupName;

	TotalNumSetups = OfficialPowerLinkSetups.length + CustomPowerLinkSetups.length;

	if (TotalNumSetups == 0)
		Log("Using default Link Setup");
	else if (TotalNumSetups == 1 && CurrentSetupName != "")
		SetPowerLinkSetup(CurrentSetupName, None);
	else
	{
		do
		{
			i = Rand(TotalNumSetups);
			if (i < OfficialPowerLinkSetups.length)
				NewSetupName = OfficialPowerLinkSetups[i].SetupName;
			else
				NewSetupName = string(CustomPowerLinkSetups[i-OfficialPowerLinkSetups.length].Name);
			Sanity++;
		} until (NewSetupName != IgnoredSetup || Sanity > 1000)

		SetPowerLinkSetup(NewSetupName, None);
	}
}

static simulated function bool ExistsLinkPathTo(ONSPowerCore Start, ONSPowerCore Destination, out array<ONSPowerCore> Traveled)
{
	local int i, j;
	local bool bSkip;

	if (Start == None || Destination == None)
		return false;

	Traveled[Traveled.length] = Start;

	for (i = 0; i < Start.PowerLinks.Length; i++)
	{
		if (Start.PowerLinks[i] == Destination)
			return true;
		bSkip = false;
		for (j = 0; j < Traveled.length; j++)
		{
			if (Traveled[j] == Start.PowerLinks[i])
			{
				bSkip = true;
				break;
			}
		}
		if (!bSkip && ExistsLinkPathTo(Start.PowerLinks[i], Destination, Traveled))
			return true;
	}

	return false;
}

function SetCoreDistance(ONSPowerCore PC, byte T, byte Distance)
{
    local int i;

    PC.FinalCoreDistance[T] = Distance;

    for (i=0; i<PC.PowerLinks.Length; i++)
    {
        if (PC.PowerLinks[i].FinalCoreDistance[T] > Distance + 1)
            SetCoreDistance(PC.PowerLinks[i], T, Distance + 1);
    }
}

function UpdateLinks()
{
    local int i, j;
    local bool bRedCoreWasVulnerable, bBlueCoreWasVulnerable;

    if (!bScriptInitialized)	//PowerCores haven't done PostBeginPlay() yet
        return;

//	log(Name@"UpdateLinks");
    bRedCoreWasVulnerable = PowerCores[FinalCore[0]].bPoweredByBlue;
    bBlueCoreWasVulnerable = PowerCores[FinalCore[1]].bPoweredByRed;

    UpdateSeveredLinks();

    for (i=0; i<PowerCores.Length; i++)
    {
        PowerCores[i].bPoweredByRed = False;
        PowerCores[i].bPoweredByBlue = False;
        for (j=0; j<PowerCores[i].PowerLinks.Length; j++)
            if (PowerCores[i].PowerLinks[j].CoreStage == 0 && !PowerCores[i].PowerLinks[j].bSevered)
            {
                if (PowerCores[i].PowerLinks[j].DefenderTeamIndex == 0)
                    PowerCores[i].bPoweredByRed = True;
                else if (PowerCores[i].PowerLinks[j].DefenderTeamIndex == 1)
                    PowerCores[i].bPoweredByBlue = True;
            }

	if (PowerCores[i].CoreStage == 4 && (PowerCores[i].bPoweredByRed || PowerCores[i].bPoweredByBlue))
		PowerCores[i].CheckTouching();
        PowerCores[i].CheckShield();
    }

    if (!bRedCoreWasVulnerable && PowerCores[FinalCore[0]].bPoweredByBlue)
    	BroadcastLocalizedMessage(class'ONSOnslaughtMessage', 20);
    if (!bBlueCoreWasVulnerable && PowerCores[FinalCore[1]].bPoweredByRed)
    	BroadcastLocalizedMessage(class'ONSOnslaughtMessage', 21);
}

function UpdateSeveredLinks()
{
    local int i;
    local array<byte> WasSevered;

    for (i = 0; i < PowerCores.Length; i++)
    {
        WasSevered[i] = byte(PowerCores[i].bSevered);
        PowerCores[i].bSevered = True;
    }

    Sever(PowerCores[FinalCore[0]], 0);
    Sever(PowerCores[FinalCore[1]], 1);

    for (i = 0; i < PowerCores.Length; i++)
        if (!PowerCores[i].bDisabled && PowerCores[i].CoreStage != 4)
        {
            if (PowerCores[i].bSevered && WasSevered[i] == 0)
		PowerCores[i].Sever();
	    else if (!PowerCores[i].bSevered && WasSevered[i] == 1)
	    	PowerCores[i].UnSever();
	}
}

function Sever(ONSPowerCore PC, int TeamIndex)
{
    local int i;
    PC.bSevered = False;
    if (PC.CoreStage != 0)
        return;
    for (i = 0; i < PC.PowerLinks.Length; i++)
        if (PC.PowerLinks[i].bSevered && PC.PowerLinks[i].DefenderTeamIndex == TeamIndex)
            Sever(PC.PowerLinks[i], TeamIndex);
}

function Reset()
{
	bOverTime = false;
	bOverTimeBroadcast = false;
}

function StartMatch()
{
	local array<ONSPowerCore> Traveled;
	local int i;

	//check if the link setup is valid (in case host/admin edited it before game start)
	if (Level.NetMode != NM_Standalone && !ExistsLinkPathTo(PowerCores[FinalCore[0]], PowerCores[FinalCore[1]], Traveled))
	{
		//trying to load an invalid setup, revert to previous one
		Log("Current link setup is invalid: There is not a complete path between the PowerCores.");
		if (CurrentSetupName == "" || !SetPowerLinkSetup(CurrentSetupName, None))
		{
			if (OfficialPowerLinkSetups.length > 0)
				FindLinkSetup();
			else
			{
				Log("Can't find a better link setup to load, so forcing a connection between the PowerCores.");
				AddLink(PowerCores[FinalCore[0]], PowerCores[FinalCore[1]]);
				UpdateLinks();
				for (i = 0; i < GameReplicationInfo.PRIArray.Length; i++)
					if (PlayerController(GameReplicationInfo.PRIArray[i].Owner) != None && ONSPlayerReplicationInfo(GameReplicationInfo.PRIArray[i]) != None)
						ONSPlayerReplicationInfo(GameReplicationInfo.PRIArray[i]).ClientReceivePowerLink(PowerCores[FinalCore[0]], PowerCores[FinalCore[1]]);
			}
		}
	}

	Super.StartMatch();
}

State MatchInProgress
{
	event Timer()
	{
        local Controller C;
    	local int i, TeamNodes[2], TotalNodes;
    	local Actor A;
    	local bool bOldUnderAttack;

        for(i=0;i<PowerCores.Length;i++)
        {
        	if ( Level.TimeSeconds > PowerCores[i].LastAttackExpirationTime )
        	{
	            bOldUnderAttack = PowerCores[i].bUnderAttack;
	            PowerCores[i].bUnderAttack = (Level.TimeSeconds - PowerCores[i].LastAttackTime < PowerCores[i].LastAttackExpirationTime);
	            if (bOldUnderAttack != PowerCores[i].bUnderAttack)
	                PowerCores[i].UnderAttackChange();
	        }

            if (!PowerCores[i].bFinalCore && PowerCores[i].CoreStage != 255)
    	    {
    	    	if (PowerCores[i].CoreStage == 0 && PowerCores[i].DefenderTeamIndex < 2)
    	            	TeamNodes[PowerCores[i].DefenderTeamIndex]++;
    	        TotalNodes++;
    	    }
        }

        if (bOverTime)
        {
        	PowerCores[FinalCore[0]].TakeDamage(OvertimeCoreDrainPerSec - OvertimeCoreDrainPerSec * (float(TeamNodes[0]) / TotalNodes), None, vect(0,0,0), vect(0,0,0), None);
        	PowerCores[FinalCore[1]].TakeDamage(OvertimeCoreDrainPerSec - OvertimeCoreDrainPerSec * (float(TeamNodes[1]) / TotalNodes), None, vect(0,0,0), vect(0,0,0), None);
        }

        Super.Timer(); // Need this!!!

        if (ResetCountDown > 0)
        {
            ResetCountDown--;
            if ( ResetCountDown < 3 )
            {
				// blow up all redeemer guided warheads
				for ( C=Level.ControllerList; C!=None; C=C.NextController )
					if ( (C.Pawn != None) && C.Pawn.IsA('RedeemerWarhead') )
						C.Pawn.Fire(1);

			}
            if ( ResetCountDown == 8 )
            {
                for ( C = Level.ControllerList; C != None; C = C.NextController )
                    if ( PlayerController(C) != None )
                        PlayerController(C).PlayStatusAnnouncement('NewRoundIn',1,true);
            }
            else if ( (ResetCountDown > 1) && (ResetCountDown < 7) )
                BroadcastLocalizedMessage(class'TimerMessage', ResetCountDown-1);
            else if (ResetCountDown == 1)
            {
                Log("Reset Onslaught.");

            	for (C = Level.ControllerList; C != None; C = C.NextController)
            	{
                    if (PlayerController(C) != None)
                        PlayerController(C).ClientReset();
                    C.Reset();
                }

            	foreach AllActors(class'Actor', A)
            		if (!A.IsA('Controller') && !A.IsA('ONSPowerCore') && !A.IsA('TeamInfo'))
            			A.Reset();

            	//we reset powercores after everything else because their reset might cause
            	//vehiclefactories, etc to activate and spawn new actors that we don't want to affect
            	for (i = 0; i < PowerCores.length; i++)
            	{
                    if (bSwapSidesAfterReset && PowerCores[i].bFinalCore)
                    {
                        if (bSidesAreSwitched)
                            PowerCores[i].DefenderTeamIndex = PowerCores[i].default.DefenderTeamIndex;
                        else
                            PowerCores[i].DefenderTeamIndex = abs(PowerCores[i].default.DefenderTeamIndex - 1);

                        FinalCore[PowerCores[i].DefenderTeamIndex] = i;
                    }
                    else
                        PowerCores[i].DefenderTeamIndex = PowerCores[i].default.DefenderTeamIndex;

                    PowerCores[i].FinalCoreDistance[0] = 255;
                    PowerCores[i].FinalCoreDistance[1] = 255;

            		PowerCores[i].Reset();
            	}

            	if (bSwapSidesAfterReset)
            	{
                    SetCoreDistance(PowerCores[FinalCore[0]], 0, 0);
                    SetCoreDistance(PowerCores[FinalCore[1]], 1, 0);
                    bSidesAreSwitched = !bSidesAreSwitched;
                }

        		//possibly choose a new link setup
            	if (bRandSetupAfterReset && (OfficialPowerLinkSetups.length + CustomPowerLinkSetups.length) > 1)
            		FindLinkSetup(CurrentSetupName);
            	else
            		UpdateLinks();

                FindNewObjectives(None); //update AI

            	//now respawn all the players
            	for (C = Level.ControllerList; C != None; C = C.nextController)
            		if (C.PlayerReplicationInfo != None && !C.PlayerReplicationInfo.bOnlySpectator)
	            		RestartPlayer(C);

            	//reset timelimit
            	RemainingTime = 60 * TimeLimit;
            	GameReplicationInfo.RemainingMinute = RemainingTime;

                ResetCountDown = 0;
           }
        }
    }
}

function MainCoreDestroyed(byte T)
{
    local Controller C;
    local PlayerController PC;
    local int Score;

    if (bOverTime)
    	Score = 1;
    else
    	Score = 2;

    if (T == 1)
    {
        BroadcastLocalizedMessage( class'ONSOnslaughtMessage', 0);
        TeamScoreEvent(0, Score, "enemy_core_destroyed");
        Teams[0].Score += Score;
 		Teams[0].NetUpdateTime = Level.TimeSeconds - 1;
       CheckScore(PowerCores[FinalCore[1]].LastDamagedBy);
    }
    else
    {
        BroadcastLocalizedMessage( class'ONSOnslaughtMessage', 1);
        TeamScoreEvent(1, Score, "enemy_core_destroyed");
        Teams[1].Score += Score;
		Teams[1].NetUpdateTime = Level.TimeSeconds - 1;
        CheckScore(PowerCores[FinalCore[0]].LastDamagedBy);
    }

    //round has ended
    for (C = Level.ControllerList; C != None; C = C.NextController)
    {
    	PC = PlayerController(C);
    	if (PC != None)
    	{
    		PC.ClientSetBehindView(true);
    		PC.ClientSetViewTarget(PowerCores[FinalCore[T]]);
    		PC.SetViewTarget(PowerCores[FinalCore[T]]);
    		if (!bGameEnded)
    			PC.ClientRoundEnded();
    	}
    	if (!bGameEnded)
	    	C.RoundHasEnded();
    }

    ResetCountDown = ResetTimeDelay;
}

function CheckScore(PlayerReplicationInfo Scorer)
{
	if (CheckMaxLives(Scorer))
		return;

	if (GameRulesModifiers != None && GameRulesModifiers.CheckScore(Scorer))
		return;

	if (GoalScore != 0 && (Teams[0].Score >= GoalScore || Teams[1].Score >= GoalScore))
		EndGame(Scorer,"teamscorelimit");
}

function bool CheckEndGame(PlayerReplicationInfo Winner, string Reason)
{
	if (Reason ~= "TimeLimit")
	{
		if ( !bOverTimeBroadcast )
		{
			StartupStage = 7;
			PlayStartupMessage();
			bOverTimeBroadcast = true;
		}
		return false;
	}

	return Super.CheckEndGame(Winner, Reason);
}

function SetEndGameFocus(PlayerReplicationInfo Winner)
{
	local Controller P;
	local PlayerController player;

	if ( Winner != None )
	{
		if (Winner.Team.TeamIndex == 0)
			EndGameFocus = PowerCores[FinalCore[1]];
		else
			EndGameFocus = PowerCores[FinalCore[0]];
	}
	if ( EndGameFocus != None )
		EndGameFocus.bAlwaysRelevant = true;

	for ( P=Level.ControllerList; P!=None; P=P.nextController )
	{
		player = PlayerController(P);
		if ( Player != None )
		{
			if ( !Player.PlayerReplicationInfo.bOnlySpectator )
				PlayWinMessage(Player, (Player.PlayerReplicationInfo.Team == GameReplicationInfo.Winner));
			Player.ClientSetBehindView(true);
			Player.CameraDist = 10;
			if ( EndGameFocus != None )
			{
				Player.ClientSetViewTarget(EndGameFocus);
				Player.SetViewTarget(EndGameFocus);
			}
			Player.ClientGameEnded();
			if ( CurrentGameProfile != None )
				CurrentGameProfile.bWonMatch = (Player.PlayerReplicationInfo.Team == GameReplicationInfo.Winner);
		}
		P.GameHasEnded();
	}
}

function Killed(Controller Killer, Controller Killed, Pawn KilledPawn, class<DamageType> damageType)
{
	if (PlayerController(Killed) != None && ONSPlayerReplicationInfo(Killed.PlayerReplicationInfo) != None)
		ONSPlayerReplicationInfo(Killed.PlayerReplicationInfo).OwnerDied();

	Super.Killed(Killer, Killed, KilledPawn, damageType);
}

function bool CriticalPlayer(Controller Other)
{
	local int x;

	if (Other.Pawn == None || Other.PlayerReplicationInfo == None)
		return Super.CriticalPlayer(Other);

	for (x = 0; x < PowerCores.length; x++)
		if ( (PowerCores[x].CoreStage == 0 || PowerCores[x].CoreStage == 2) && PowerCores[x].DefenderTeamIndex != Other.GetTeamNum()
		     && ((PowerCores[x].bUnderAttack && Other.PlayerReplicationInfo == PowerCores[x].LastDamagedBy) || VSize(Other.Pawn.Location - PowerCores[x].Location) < 2000) )
			return true;

	return Super.CriticalPlayer(Other);
}

function bool ValidSpawnPoint(ONSPowerCore PC, int TeamIndex)
{
    return (PC != None && PC.DefenderTeamIndex == TeamIndex &&
            !PC.IsInState('NeutralCore') && !PC.IsInState('Reconstruction') &&
            (!PC.bUnderAttack || PC.bFinalCore));
}

function NavigationPoint FindPlayerStart( Controller Player, optional byte InTeam, optional string incomingName )
{
    local NavigationPoint N, BestStart;
    local Teleporter Tel;
    local float BestRating, NewRating;
    local byte Team, EnemyTeam;
    local ONSPowerCore SelectedPC;
    local float CoreDistA, CoreDistB;
    local int i;
    local Bot B;

    if ( GameRulesModifiers != None )
    {
        N = GameRulesModifiers.FindPlayerStart(Player,InTeam,incomingName);
        if ( N != None )
            return N;
    }

    // if incoming start is specified, then just use it
    if( incomingName!="" )
        foreach AllActors( class 'Teleporter', Tel )
            if( string(Tel.Tag)~=incomingName )
                return Tel;

    // use InTeam if player doesn't have a team yet
    if ( (Player != None) && (Player.PlayerReplicationInfo != None) )
    {
        if ( Player.PlayerReplicationInfo.Team != None )
            Team = Player.PlayerReplicationInfo.Team.TeamIndex;
        else
            Team = InTeam;
        //Use the powercore the player selected (if it's valid)
		if ( ONSPlayerReplicationInfo(Player.PlayerReplicationInfo) != None )
        {
    		SelectedPC = ONSPlayerReplicationInfo(Player.PlayerReplicationInfo).TemporaryStartCore;
    		ONSPlayerReplicationInfo(Player.PlayerReplicationInfo).TemporaryStartCore = None;
    		if (SelectedPC != None && !ValidSpawnPoint(SelectedPC, Team))
    			SelectedPC = None;
    		if (SelectedPC == None)
    		{
	        	SelectedPC = ONSPlayerReplicationInfo(Player.PlayerReplicationInfo).StartCore;
		        if (!ValidSpawnPoint(SelectedPC, Team))
                    SelectedPC = None;
	        }
        }
        if ( SelectedPC == None )
        {
	        //Bots always want to go to their SquadObjective
	        B = Bot(Player);
        	if (B != None && B.Squad != None && ONSPowerCore(B.Squad.SquadObjective) != None && ValidSpawnPoint(ONSPowerCore(B.Squad.SquadObjective), Team))
        		SelectedPC = ONSPowerCore(B.Squad.SquadObjective);
        }
    }
    else
        Team = InTeam;

    if (SelectedPC == None)
    {
    	if (PowerCores[FinalCore[Team]].PoweredBy(1 - Team))
    		SelectedPC = PowerCores[FinalCore[Team]];

    	if (SelectedPC == None)
    	{
	        // Find the Closest Controlled Node(s) to Enemy PowerCore.
	        EnemyTeam = abs(Team - 1);
	        BestRating = 255;
	        for (i = 0; i < PowerCores.Length; i++)
	        {
	            if (ValidSpawnPoint(PowerCores[i], Team))
	            {
	                NewRating = PowerCores[i].FinalCoreDistance[EnemyTeam];
	                if ( NewRating < BestRating )
	                {
	                    BestRating = NewRating;
	                    SelectedPC = PowerCores[i];
	                }
	                else if ( NewRating == BestRating ) // If we have two nodes at equal link distance, we check geometric distance
	                {
                        CoreDistA = VSize(PowerCores[FinalCore[EnemyTeam]].Location - PowerCores[i].Location);
                        CoreDistB = VSize(PowerCores[FinalCore[EnemyTeam]].Location - SelectedPC.Location);
                        if (CoreDistA < CoreDistB)
                            SelectedPC = PowerCores[i];
                    }
	            }
	        }

	        // If no valid power node found, set to power core.
            if (SelectedPC == None)
		        SelectedPC = PowerCores[FinalCore[Team]];
        }
    }

    for (i = 0; i < SelectedPC.CloseActors.length; i++)
        if (NavigationPoint(SelectedPC.CloseActors[i]) != None)
        {
	        NewRating = RatePlayerStart(NavigationPoint(SelectedPC.CloseActors[i]),Team,Player);
        	if ( NewRating > BestRating )
	        {
        	    BestRating = NewRating;
	            BestStart = NavigationPoint(SelectedPC.CloseActors[i]);
        	}
	}

    if (PlayerStart(BestStart) == None && SelectedPC != PowerCores[FinalCore[Team]])
    {
    	//couldn't find a start at the requested node, so try powercore
    	SelectedPC = PowerCores[FinalCore[Team]];
    	for (i = 0; i < SelectedPC.CloseActors.length; i++)
	        if (NavigationPoint(SelectedPC.CloseActors[i]) != None)
	        {
		        NewRating = RatePlayerStart(NavigationPoint(SelectedPC.CloseActors[i]),Team,Player);
	        	if ( NewRating > BestRating )
		        {
	        	    BestRating = NewRating;
		            BestStart = NavigationPoint(SelectedPC.CloseActors[i]);
	        	}
		}
    }

    if (PlayerStart(BestStart) == None)
    {
        log("Warning - PATHS NOT DEFINED or NO PLAYERSTART with positive rating");
	BestRating = -100000000;
        ForEach AllActors( class 'NavigationPoint', N )
        {
            NewRating = RatePlayerStart(N,0,Player);
            if ( InventorySpot(N) != None )
				NewRating -= 50;
			NewRating += 20 * FRand();
            if ( NewRating > BestRating )
            {
                BestRating = NewRating;
                BestStart = N;
            }
        }
    }

    return BestStart;
}

function ShowPathTo(PlayerController P, int TeamNum)
{
	local int x;
	local ONSPowerCore Best;
	local float BestDist;
	local class<WillowWhisp>	WWclass;

	for (x = 0; x < PowerCores.Length; x++)
		if ( (PowerCores[x].CoreStage != 0 || PowerCores[x].DefenderTeamIndex != TeamNum) && PowerCores[x].PoweredBy(TeamNum)
		     && (Best == None || VSize(P.Pawn.Location - PowerCores[x].Location) < BestDist) )
		{
			Best = PowerCores[x];
			BestDist = VSize(P.Pawn.Location - PowerCores[x].Location);
		}

	if (Best != None && P.FindPathToward(Best, false) != None)
	{
		WWclass = class<WillowWhisp>(DynamicLoadObject(PathWhisps[TeamNum], class'Class'));
		Spawn(WWclass, P,, P.Pawn.Location);
	}
}

function GetServerInfo(out ServerResponseLine ServerState)
{
	Super.GetServerInfo(ServerState);

	if (!bCurrentSetupIsOfficial)
		ServerState.MapName $= "*";
}

function GetServerDetails(out ServerResponseLine ServerState)
{
	Super.GetServerDetails(ServerState);

	AddServerDetail( ServerState, "LinkSetup", CurrentSetupName );
}

function bool ChangeTeam(Controller Other, int num, bool bNewTeam)
{
	local int i;
	local ONSPlayerReplicationInfo PRI;

	if (Super.ChangeTeam(Other, num, bNewTeam))
	{
		if (Other == Level.GetLocalPlayerController())
		{
			//Update client side effects on powercores to reflect which ones the player can go after changing teams
			for (i = 0; i < PowerCores.length; i++)
				PowerCores[i].CheckShield();
		}

		PRI = ONSPlayerReplicationInfo(Other.PlayerReplicationInfo);
		if (PRI != None)
		{
			PRI.StartCore = None;
			PRI.TemporaryStartCore = None;
		}

		return true;
	}

	return false;
}

function PlayStartupMessage()
{
	Super.PlayStartupMessage();

	if (StartupStage == 7 && OvertimeCoreDrainPerSec > 0)
		BroadcastLocalizedMessage(class'ONSOnslaughtMessage', 29);
}

function ScoreObjective(PlayerReplicationInfo Scorer, float Score)
{
	if (Scorer != None)
		Scorer.Score += Score;

	if (GameRulesModifiers != None)
		GameRulesModifiers.ScoreObjective(Scorer,Score);
}

static event bool AcceptPlayInfoProperty(string PropertyName)
{
	if ( InStr(PropertyName, "bAllowTrans") != -1 )
		return false;

	return Super.AcceptPlayInfoProperty(PropertyName);
}

static function FillPlayInfo(PlayInfo PlayInfo)
{
	local int i;

	Super.FillPlayInfo(PlayInfo);  // Always begin with calling parent

	PlayInfo.AddSetting(default.GameGroup, "OvertimeCoreDrainPerSec", default.ONSPropsDisplayText[i++], 40, 1, "Text", "2;0:99");
	PlayInfo.AddSetting(default.GameGroup, "bRandSetupAfterReset",    default.ONSPropsDisplayText[i++], 0,  1, "Check",        ,,     , true);
	PlayInfo.AddSetting(default.GameGroup, "bSwapSidesAfterReset",    default.ONSPropsDisplayText[i++], 0,  1, "Check",        ,,     , true);
}

static event string GetDescriptionText(string PropName)
{
	switch (PropName)
	{
		case "OvertimeCoreDrainPerSec":	return default.ONSPropDescText[0];
		case "bRandSetupAfterReset":	return default.ONSPropDescText[1];
		case "bSwapSidesAfterReset":	return default.ONSPropDescText[2];
	}

	return Super.GetDescriptionText(PropName);
}

static function array<string> GetAllLoadHints(optional bool bThisClassOnly)
{
	local int i;
	local array<string> Hints;

	if ( !bThisClassOnly || default.ONSHints.Length == 0 )
		Hints = Super.GetAllLoadHints();

	for ( i = 0; i < default.ONSHints.Length; i++ )
		Hints[Hints.Length] = default.ONSHints[i];

	return Hints;
}

event Destroyed()
{
	CustomPowerLinkSetups.length = 0;

	Super.Destroyed();
}

function SetupLinks()
{
	local ONSPowerCore Core;
	local int i;

	if ( PowerCores.Length == 0 )
		return;

	Core = PowerCores[0];
	do
	{
		for ( i = 0; i < Core.PowerLinks.Length; i++ )
			AddLink(Core, Core.PowerLinks[i]);

		Core = Core.NextCore;
	} until ( Core == None || Core == PowerCores[0] );
}

function bool AddLink( ONSPowerCore A, ONSPowerCore B )
{
	local PowerLink Link;

	if ( HasLink(A,B) )
		return false;

	Link = Spawn(class'PowerLink');
	Link.SetNodes(A,B);

//	log(Name@"AddLink Link:"$Link.Name@"A:"$A.Name@"B:"$B.Name);
	PowerLinks[PowerLinks.Length] = Link;
//	A.AddPowerLink(B);
//	A.PowerCoreReset();
//	B.PowerCoreReset();
	return True;
}

function bool RemoveLink( ONSPowerCore A, ONSPowerCore B )
{
	local int i;

	for ( i = PowerLinks.Length - 1; i >= 0; i-- )
	{
		if ( PowerLinks[i] == None )
		{
			PowerLinks.Remove(i,1);
			continue;
		}

		if ( PowerLinks[i].HasNodes(A,B) )
		{
//			A.RemovePowerLink(B);

//			A.PowerCoreReset();
//			B.PowerCoreReset();
			PowerLinks[i].Destroy();
			PowerLinks.Remove(i,1);
			return True;
		}
	}

	return False;
}

function bool HasLink( ONSPowerCore A, ONSPowerCore B )
{
	local int i;

	for ( i = PowerLinks.Length - 1; i >= 0; i-- )
	{
		if ( PowerLinks[i] == None )
		{
			PowerLinks.Remove(i,1);
			continue;
		}

		if ( PowerLinks[i].HasNodes(A,B) )
			return True;
	}

	return False;
}

event PostLogin(PlayerController NewPlayer)
{
	Super.PostLogin(NewPlayer);

	if ( ONSPlayerReplicationInfo(NewPlayer.PlayerReplicationInfo) != None )
		ONSPlayerReplicationInfo(NewPlayer.PlayerReplicationInfo).ClientPrepareToReceivePowerLinks();
}

function DeadUse(PlayerController PC)
{
	Super.DeadUse(PC);
	PC.ShowMenu();
}

defaultproperties
{
     OvertimeCoreDrainPerSec=20
     bSwapSidesAfterReset=True
     ONSPropsDisplayText(0)="Core Drain in Overtime"
     ONSPropsDisplayText(1)="Random Link Setup After Reset"
     ONSPropsDisplayText(2)="Teams Swap Sides After Reset"
     ONSPropDescText(0)="In overtime, PowerCores lose a maximum of this much health every second."
     ONSPropDescText(1)="After a reset, a new link setup will be chosen at random."
     ONSPropDescText(2)="After a reset, teams will switch sides so they are defending the PowerCore they were previously attacking."
     ONSHints(0)="If you receive a missile lock warning, try to get out of sight quickly!"
     ONSHints(1)="The Raptor's missiles will automatically lock onto Mantas and other Raptors."
     ONSHints(2)="In the Raptor press %JUMP% to fly higher and %DUCK% to fly lower."
     ONSHints(3)="The Manta can rapidly descend to smash your enemies by pressing %DUCK% or %ALTFIRE%."
     ONSHints(4)="Press %JUMP% to perform a 180 spin out in the Hellbender or Scorpion."
     ONSHints(5)="The Manta is the only vehicle that has the ability to jump."
     ONSHints(6)="When deployed, the Leviathan is highly vulnerable to air attacks."
     ONSHints(7)="You can heal a friendly vehicle with the link gun alt-fire."
     ONSHints(8)="You can heal a friendly PowerNode with the link gun alt-fire."
     ONSHints(9)="It is impossible to heal the final PowerCore, so defend it at all costs!"
     ONSHints(10)="Press %TOGGLERADARMAP% to toggle the radar map on and off."
     ONSHints(11)="You can be hurt or killed by vehicles exploding near you."
     ONSHints(12)="Enemy Spider Mines can be destroyed, but some weapons are better against them than others."
     ONSHints(13)="Pressing %USE% on a PowerNode allows you to teleport to any PowerNode your team controls."
     ONSHints(14)="You won't be able to spawn at a PowerNode that is under attack, even if your team controls it."
     ONSHints(15)="If you die, any Spider Mines or Grenades you fired will explode."
     ONSHints(16)="Press %VOICETALK% to voice chat with your team."
     ONSHints(17)="%BASEPATH 0% will show the way to the nearest PowerNode or PowerCore the Red Team can attack, while %BASEPATH 1% will do the same for the Blue Team."
     ONSHints(18)="Press %TOGGLEBEHINDVIEW% to switch between 1st and 3rd person mode in vehicles."
     ONSHints(19)="AVRiL rockets will home into an occupied enemy vehicle as long as you keep your crosshair on it."
     ONSHints(20)="When you find a target with the AVRiL, press alt-fire to zoom and lock your view to that target."
     ONSHints(21)="The green light on top of the weaponlockers indicates that additional ammo is available at that locker."
     ONSHints(22)="Attack PowerNodes that have the enemy team color sky beams above them."
     ONSHints(23)="You cannot attack the PowerCore or PowerNodes if there is an energy shield present. Remove the shield by controlling a node that is linked to it."
     ONSHints(24)="The Grenade Launcher shoots sticky grenades that attach themselves to vehicles and players. You must detonate them yourself with the alternate fire (press %ALTFIRE%)"
     ONSHints(25)="The bomber that the Target Painter calls in can be shot down by enemy fire."
     ONSHints(26)="In Onslaught, your team earns 2 points for winning before overtime and 1 point for a win during overtime."
     bScoreTeamKills=False
     bSpawnInTeamArea=True
     TeamAIType(0)=Class'Onslaught.ONSTeamAI'
     TeamAIType(1)=Class'Onslaught.ONSTeamAI'
     NetWait=15
     bAlwaysShowLoginMenu=True
     DefaultEnemyRosterClass="XGame.xTeamRoster"
     ADR_Kill=2.000000
     LoginMenuClass="GUI2K4.UT2K4OnslaughtLoginMenu"
     bAllowVehicles=True
     bLiberalVehiclePaths=True
     GameUMenuType="GUI2K4.UT2K4OnslaughtLoginMenu"
     HUDSettingsMenu="GUI2K4.CustomHUDMenuOnslaught"
     HUDType="Onslaught.ONSHUDOnslaught"
     MapListType="Onslaught.ONSMapListOnslaught"
     MapPrefix="ONS"
     BeaconName="ONS"
     ResetTimeDelay=11
     GoalScore=3
     MutatorClass="Onslaught.ONSDefaultMut"
     GameName="Onslaught"
     Description="Your team must take control over PowerNodes in a 'connect the dots' fashion to establish a direct line to the enemy PowerCore. Once you establish a link to the next PowerNode, you can destroy it if controlled by the enemy. Control the PowerNode for your team by touching it to start the build process (Use the linkgun alt-fire to speed things up). Once your team has a link to the enemy PowerCore, attack and destroy it."
     ScreenShotName="UT2004Thumbnails.OnslaughtShots"
     DecoTextName="Onslaught.ONSOnslaughtGame"
     Acronym="ONS"
}
