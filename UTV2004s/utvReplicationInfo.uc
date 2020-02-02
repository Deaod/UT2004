//-----------------------------------------------------------
//
//-----------------------------------------------------------
class utvReplicationInfo extends ReplicationInfo;

var Controller OwnerCtrl;             //Only valid on server side
var PlayerReplicationInfo OwnerPlayer;
var rotator TargetViewRotation;

replication
{
	reliable if (Role == Role_Authority)
	   OwnerPlayer;
	unreliable if (Role == Role_Authority)
	   TargetViewRotation;
}

simulated function Tick(float deltaTime)
{
    local PlayerController p;
    local Pawn curTarget;

    if (Level.NetMode != NM_Client) {

        if (OwnerPlayer == none)
            if (OwnerCtrl.PlayerReplicationInfo != none)
                OwnerPlayer = OwnerCtrl.PlayerReplicationInfo;

        //This should not happen unless something breaks
        if (OwnerCtrl == none)
            return;

        TargetViewRotation = OwnerCtrl.Rotation;
        //Log("Player " $ OwnerPlayer.PlayerName $ " has rotation " $ TargetViewRotation);
    }
    else {
        p = Level.GetLocalPlayerController();
        curTarget = Pawn(p.ViewTarget);
        if (curTarget != none) {
            if (curTarget.PlayerReplicationInfo == OwnerPlayer) {
                p.TargetViewRotation = TargetViewRotation;
                //Log("Updating rotation for target " $ OwnerPlayer.PlayerName);
            }
        }
    }
}

defaultproperties
{
     bAlwaysRelevant=False
     NetUpdateFrequency=100.000000
     bAlwaysTick=True
}
