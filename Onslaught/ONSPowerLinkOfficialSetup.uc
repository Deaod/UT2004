// Official PowerLink setups for Onslaught maps (can't be deleted)
// Should be placed in the map
//
// For easy creation, use the console command "CopyLinkSetup" while in the map.
// Then open the map in UnrealEd, use Paste, and open the properties of the new actor to give it a SetupName.

class ONSPowerLinkOfficialSetup extends Actor
	DependsOn(ONSOnslaughtGame);

var(LinkSetup) string SetupName;

var(LinkSetup) array<ONSOnslaughtGame.PowerLinkSetup> LinkSetups;

defaultproperties
{
     SetupName="Default"
     bHidden=True
     bStasis=True
     RemoteRole=ROLE_None
     bMovable=False
     bBlockZeroExtentTraces=False
     bBlockNonZeroExtentTraces=False
}
