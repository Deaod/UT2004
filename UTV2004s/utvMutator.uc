//-----------------------------------------------------------
//
//-----------------------------------------------------------
class utvMutator extends Mutator;

var string origcontroller;
var class<PlayerController> origcclass;

var array<int> utvId;

//C is the owner
function CreateInitialUtvReplication(Controller c)
{
    local utvReplicationInfo uri;
    local Controller p;

    foreach dynamicactors(class'Controller', p) {
        if (p != c) {
            //Log("Initially spawning utvReplicationInfo for player " $ p.PlayerReplicationInfo.PlayerName $ " owner " $ c.PlayerReplicationInfo.PlayerName);
            uri = Spawn(class'utvReplicationInfo', c);
            uri.OwnerCtrl = p;
        }
    }
}

//C is the possible new player
function CreateUtvReplication(Controller c)
{
    local utvReplicationInfo uri;
    local PlayerController pc;
    local bool found;

    foreach dynamicactors(class'PlayerController', pc) {
        //Only spawn these for controllers that are utv in seeall mode
        if (!pc.bAllActorsRelevant)
            continue;

        found = false;
        foreach dynamicactors(class'utvReplicationInfo', uri) {
            if ((uri.OwnerPlayer == c.PlayerReplicationInfo) && (uri.Owner == pc)) {
                found = true;
                break;
            }
        }
        if (!found) {
            //Log("Spawning utvReplicationInfo for player " $ c.PlayerReplicationInfo.PlayerName $ " owner " $ pc.PlayerReplicationInfo.PlayerName);
            uri = Spawn(class'utvReplicationInfo', pc);
            uri.OwnerCtrl = c;
        }
    }
}

function Tick(float deltaTime)
{
    local PlayerController pc;
    local int i;

    super.Tick(deltaTime);

    if (utvId.Length > 0) {
        foreach dynamicactors(class'PlayerController', pc) {
            for (i = 0; i < utvId.Length; ++i) {
                if (pc.PlayerReplicationInfo.PlayerID == utvId[i]) {
                    CreateInitialUtvReplication(pc);
                    Log(FriendlyName $ ": Found new UTV player: " $ pc.PlayerReplicationInfo.PlayerName);
                    utvId.Remove(i, 1);
                    i--;
                }
            }
        }
    }
}

//Returns a suitable UTV-spectator class. Knows about UTComp and TTM
function string GetNewController()
{
    local string cur;
    local string newc;
    cur = Level.Game.PlayerControllerClassName;

    //Utcomp?
    if (InStr(cur, "BS_") > 0) {
        newc = Repl(cur, "BS_", "UTV_BS_", false);
        Log(FriendlyName $ ": UTComp detected, using class " $ newc);
    }
    else if (InStr(cur, "TTM_PlayerController") > 0) {
        newc = Repl(cur, "TTM_PlayerController", "TTM_UTV_Spectator", false);
        Log(FriendlyName $ ": TTM detected, using class " $ newc);
    }
    else {
        newc = FriendlyName $ ".utvSpectator";
        Log(FriendlyName $ ": Using class " $ newc);
    }

    return newc;
}

function ModifyLogin(out string Portal, out string Options)
{
	local bool bSeeAll;
	local bool bSpectator;

	super.ModifyLogin (Portal, Options);

	if (Level.game == none) {
		Log (FriendlyName $ ": Level.game is none?");
		return;
	}

    //If we replaced the controller last time round, make sure to restore it
	if (origcontroller != "") {
		Level.Game.PlayerControllerClassName = origcontroller;
		Level.Game.PlayerControllerClass = origcclass;
		origcontroller = "";
	}

    bSpectator = ( Level.Game.ParseOption( Options, "SpectatorOnly" ) ~= "1" );
    bSeeAll = ( Level.Game.ParseOption( Options, "UTVSeeAll" ) ~= "1" );

	if (bSeeAll && bSpectator) {
       Log(FriendlyName $ ": Player with id " $ Level.Game.CurrentID $ " is requesting SeeAll");

       utvId[utvId.Length] = Level.Game.CurrentID;

       origcontroller = Level.Game.PlayerControllerClassName;
	   origcclass = Level.Game.PlayerControllerClass;
	   Level.Game.PlayerControllerClassName = GetNewController();
	   Level.Game.PlayerControllerClass = none;
    }
}

function ModifyPlayer(Pawn Other)
{
    super.ModifyPlayer(Other);

    CreateUtvReplication(Other.Controller);
}

function NotifyLogout(Controller Exiting)
{
    local utvReplicationInfo uri;
    local PlayerController pc;

    super.NotifyLogout(Exiting);

    //Log if seeall players leave
    pc = PlayerController(Exiting);
    if ((pc != none) && (pc.bAllActorsRelevant)) {
        Log(FriendlyName $ ": SeeAll enabled player " $ Exiting.PlayerReplicationInfo.PlayerName $ " (" $ Exiting.PlayerReplicationInfo.PlayerID $ ") leaving");
    }

    //Remove all utvReplicationInfos associated with the leaving player
    foreach dynamicactors(class'utvReplicationInfo', uri) {
        if ((uri.OwnerCtrl == Exiting) || (uri.Owner == Exiting)) {
            //Log("Removing utvReplication for pawn " $ Exiting $ " player " $ uri.Owner);
            uri.Destroy();
        }
    }
}

defaultproperties
{
     bAddToServerPackages=True
     FriendlyName="UTV2004S"
     Description="Required to support UTV2004 SeeAll mode"
     bAlwaysTick=True
}
