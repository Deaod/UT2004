class ONSPlayerReplicationInfo extends xPlayerReplicationInfo
	config(user);

var ONSPowerCore StartCore; //always try to spawn player here. None means auto-select, value ignored if TemporaryStartCore != None
var ONSPowerCore TemporaryStartCore; //next time player respawns try to put him here (then this value is cleared)

enum EMapPreference
{
	MAP_Never,
	MAP_WhenBodyStill,
	MAP_Immediately
};

var globalconfig EMapPreference ShowMapOnDeath;
var bool bPendingMapDisplay;
var globalconfig string LinkDesignerClass;	//class of Link Designer menu
var Material TransMaterials[2];
var float PendingHealBonus; //node healing score bonus that hasn't yet been added to Score

replication
{
	reliable if (bNetDirty && Role == ROLE_Authority)
		StartCore;
	reliable if (Role < ROLE_Authority)
		SetStartCore, ServerSendPowerLinks, ServerReceivePowerLink, ServerRemovePowerLink, ServerClearPowerLinks, ServerSendSetupNames,
		ServerSetPowerLinkSetup, ServerSavePowerLinkSetup, ServerDeletePowerLinkSetup, RequestLinkDesigner, TeleportTo;
	reliable if (Role == ROLE_Authority)
		ClientPrepareToReceivePowerLinks, ClientReceivePowerLink, ClientRemovePowerLink, ClientReceiveSetupName,
		ClientReceiveCurrentSetup, ClientShowMap;
}

//these are set by the link designer
delegate OnReceiveLink( ONSPowerCore A, ONSPowerCore B );
delegate OnRemoveLink( ONSPowerCore A, ONSPowerCore B );
delegate ResetLinks();
delegate ProcessSetupName(string SetupName);
delegate RemoveSetupName(string SetupName);
delegate SetCurrentSetup(string SetupName);
delegate UpdateGUIMapLists(); //listen/standalone servers only

function SetStartCore(ONSPowerCore Core, bool bTemporary)
{
	if ( Core == None || ONSOnslaughtGame(Level.Game).ValidSpawnPoint(Core, Team.TeamIndex))
	{
		if (bTemporary)
			TemporaryStartCore = Core;
		else
			StartCore = Core;
	}
}

// returns the powecore/node the player is currently standing on or in the node teleport trigger radius of,
// if that core/node is currently constructed for the same team as the player
simulated function ONSPowerCore GetCurrentNode()
{
	local ONSPowerCore Core;
	local ONSPCTeleportTrigger T;

	if (Controller(Owner).Pawn != None)
	{
		if (Controller(Owner).Pawn.Base != None)
		{
			Core = ONSPowerCore(Controller(Owner).Pawn.Base);
			if (Core == None)
				Core = ONSPowerCore(Controller(Owner).Pawn.Base.Owner);
		}

		if (Core == None)
			foreach Controller(Owner).Pawn.TouchingActors(class'ONSPCTeleportTrigger', T)
			{
				Core = ONSPowerCore(T.Owner);
				if (Core != None)
					break;
			}
	}

	if (Core != None && Core.CoreStage == 0 && Core.DefenderTeamIndex == Team.TeamIndex)
		return Core;

	return None;
}

function TeleportTo(ONSPowerCore Core)
{
	local ONSPowerCore OldStartCore;
	local ONSPowerCore OwnerBase;

	OwnerBase = GetCurrentNode();
	if (OwnerBase != None && ONSOnslaughtGame(Level.Game).ValidSpawnPoint(Core, Team.TeamIndex))
	{
		OldStartCore = StartCore;
		StartCore = Core;
		if (!DoTeleport() && !DoTeleport()) //two tries
		{
			//FIXME error localmessage here!
		}
		StartCore = OldStartCore;
	}
}

function bool DoTeleport()
{
	local NavigationPoint NewStart;
	local vector PrevLocation;

	PrevLocation = Controller(Owner).Pawn.Location;
	NewStart = Level.Game.FindPlayerStart(Controller(Owner));
	if (NewStart != None && Controller(Owner).Pawn.SetLocation(NewStart.Location))
	{
		Controller(Owner).ClientSetRotation(NewStart.Rotation);
		if (xPawn(Controller(Owner).Pawn) != None)
			xPawn(Controller(Owner).Pawn).DoTranslocateOut(PrevLocation);
		Controller(Owner).Pawn.SetOverlayMaterial(TransMaterials[Team.TeamIndex], 1.0, false);
		Controller(Owner).Pawn.PlayTeleportEffect(false, false);
		return true;
	}

	return false;
}

function OwnerDied()
{
	if (PlayerController(Owner) != None )
		ClientShowMap();
}

simulated function ClientShowMap()
{
	if (ShowMapOnDeath > MAP_Never)
	{
		bPendingMapDisplay = true;
		SetTimer(0.75, true);
	}
}

simulated event Timer()
{
	local PlayerController PC;

	if (bPendingMapDisplay)
	{
		PC = Level.GetLocalPlayerController();
		if (PC != None && !PC.bDemoOwner && PC.Player != None && GUIController(PC.Player.GUIController) != None && !GUIController(PC.Player.GUIController).bActive)
		{
			if (PC.Pawn != None && PC.Pawn.Health > 0) //never automatically pop up map while player is playing!
			{
				bPendingMapDisplay = false;
				SetTimer(0, false);
			}
			else if (ShowMapOnDeath == MAP_Immediately || PC.ViewTarget == None || PC.ViewTarget == PC || VSize(PC.ViewTarget.Velocity) < 100)
			{
				PC.bMenuBeforeRespawn = false;
				bPendingMapDisplay = false;
				SetTimer(0, false);
				PC.ShowMidGameMenu(false);
			}
			else
				PC.bMenuBeforeRespawn = true;
		}
		else
		{
			bPendingMapDisplay = False;
			SetTimer(0, false);
		}
	}

	Super.Timer();
}

simulated function ClientPrepareToReceivePowerLinks()
{
	ResetLinks();
}

function ServerSendPowerLinks()
{
	local int i;
	local ONSOnslaughtGame Game;

	Game = ONSOnslaughtGame(Level.Game);
	for ( i = 0; i < Game.PowerLinks.Length; i++ )
		ClientReceivePowerLink(Game.PowerLinks[i].Nodes[0].Node, Game.PowerLinks[i].Nodes[1].Node);
}

simulated function ClientReceivePowerLink(ONSPowerCore From, ONSPowerCore To)
{
//	log(Name@"ClientReceivePowerLink A:"$From.Name@"B:"$To.Name);
	OnReceiveLink(From,To);
}

simulated function ClientRemovePowerLink(ONSPowerCore From, ONSPowerCore To)
{
	OnRemoveLink(From,To);
}

function ServerReceivePowerLink(ONSPowerCore From, ONSPowerCore To)
{
	local int i;
	local GameReplicationInfo GRI;

	if (PlayerController(Owner) == None || (Owner != Level.GetLocalPlayerController() && !bAdmin) || From == To)
		return;

	if ( ONSOnslaughtGame(Level.Game).AddLink(From,To) )
	{
		ONSOnslaughtGame(Level.Game).UpdateLinks();
		GRI = Level.Game.GameReplicationInfo;
		for ( i = 0; i < GRI.PRIArray.Length; i++ )
		{
			if ( PlayerController(GRI.PRIArray[i].Owner) == None ||
				 ONSPlayerReplicationInfo(GRI.PRIArray[i]) == None )
				continue;

			ONSPlayerReplicationInfo(GRI.PRIArray[i]).ClientReceivePowerLink(From,To);
		}
	}

}

function ServerRemovePowerLink(ONSPowerCore From, ONSPowerCore To)
{
	local int i;
	local GameReplicationInfo GRI;

	if (PlayerController(Owner) == None || (Owner != Level.GetLocalPlayerController() && !bAdmin) || From == To)
		return;

	if ( ONSOnslaughtGame(Level.Game).RemoveLink(From,To) )
	{
		ONSOnslaughtGame(Level.Game).UpdateLinks();
		GRI = Level.Game.GameReplicationInfo;
		for ( i = 0; i < GRI.PRIArray.Length; i++ )
		{
			if ( PlayerController(GRI.PRIArray[i].Owner) == None ||
				 ONSPlayerReplicationInfo(GRI.PRIArray[i]) == None )
				continue;

			ONSPlayerReplicationInfo(GRI.PRIArray[i]).ClientRemovePowerLink(From,To);
		}
	}
}

function ServerClearPowerLinks()
{
	local int i;
	local ONSOnslaughtGame Game;

	Game = ONSOnslaughtGame(Level.Game);

	while (Game.PowerLinks.length > 0)
		ServerRemovePowerLink(Game.PowerLinks[i].Nodes[0].Node, Game.PowerLinks[i].Nodes[1].Node);
}

function ServerSendSetupNames()
{
	local int x;

	for (x = 0; x < ONSOnslaughtGame(Level.Game).OfficialPowerLinkSetups.length && x < 1000; x++)
		ClientReceiveSetupName(ONSOnslaughtGame(Level.Game).OfficialPowerLinkSetups[x].SetupName);

	for (x = 0; x < ONSOnslaughtGame(Level.Game).CustomPowerLinkSetups.length && x < 1000; x++)
		ClientReceiveSetupName(string(ONSOnslaughtGame(Level.Game).CustomPowerLinkSetups[x].Name));

	ClientReceiveSetupName("");		//Indicate end of setup names

	ClientReceiveCurrentSetup(ONSOnslaughtGame(Level.Game).CurrentSetupName);
}

simulated function ClientReceiveSetupName(string SetupName)
{
	ProcessSetupName(SetupName);
}

simulated function ClientReceiveCurrentSetup(string SetupName)
{
	SetCurrentSetup(SetupName);
}

function ServerSetPowerLinkSetup(string SetupName)
{
	if (PlayerController(Owner) == None || (Owner != Level.GetLocalPlayerController() && !bAdmin))
		return;

	ONSOnslaughtGame(Level.Game).SetPowerLinkSetup(SetupName, PlayerController(Owner));
}

function ServerSavePowerLinkSetup(string SetupName)
{
	local array<ONSPowerCore> Traveled;

	if (PlayerController(Owner) == None || (Owner != Level.GetLocalPlayerController() && !bAdmin))
		return;

	if ( !ONSOnslaughtGame(Level.Game).ExistsLinkPathTo( ONSOnslaughtGame(Level.Game).PowerCores[ONSOnslaughtGame(Level.Game).FinalCore[0]],
							     ONSOnslaughtGame(Level.Game).PowerCores[ONSOnslaughtGame(Level.Game).FinalCore[1]],
							     Traveled ) )
	{
		PlayerController(Owner).ReceiveLocalizedMessage(class'ONSLinkDesignMessage', 7);
		return;
	}

	if (ONSOnslaughtGame(Level.Game).SavePowerLinkSetup(SetupName, PlayerController(Owner)))
	{
		ClientReceiveSetupName(SetupName);
		UpdateGUIMapLists();
	}
}

function ServerDeletePowerLinkSetup(string SetupName)
{
	if (PlayerController(Owner) == None || (Owner != Level.GetLocalPlayerController() && !bAdmin))
		return;

	if (ONSOnslaughtGame(Level.Game).DeletePowerLinkSetup(SetupName, PlayerController(Owner)))
	{
		ClientRemoveSetupName(SetupName);
		UpdateGUIMapLists();
	}
}

simulated function ClientRemoveSetupName(string SetupName)
{
	RemoveSetupName(SetupName);
}

function RequestLinkDesigner()
{
	if (PlayerController(Owner) != None && (Owner == Level.GetLocalPlayerController() || bAdmin))
		PlayerController(Owner).ClientOpenMenu(LinkDesignerClass);
}

//scoring bonus for healing powernodes
//we wait until the healing bonus >= 1 point before adding to score to minimize ScoreEvent() calls
function AddHealBonus(float Bonus)
{
	PendingHealBonus += Bonus;
	if (PendingHealBonus >= 1.f)
	{
		Level.Game.ScoreObjective(self, PendingHealBonus);
		Level.Game.ScoreEvent(self, PendingHealBonus, "heal_powernode");
		PendingHealBonus = 0;
	}
}

function Reset()
{
	HasFlag = None;
	NumLives = 0;
	bOutOfLives = false;
}

defaultproperties
{
     ShowMapOnDeath=MAP_WhenBodyStill
     LinkDesignerClass="GUI2K4.UT2K4OnslaughtPowerLinkDesigner"
     TransMaterials(0)=Shader'XGameShaders.PlayerShaders.PlayerTransRed'
     TransMaterials(1)=Shader'XGameShaders.PlayerShaders.PlayerTrans'
}
