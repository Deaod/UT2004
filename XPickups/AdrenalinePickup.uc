//=============================================================================
// AdrenalinePickup
//=============================================================================
class AdrenalinePickup extends TournamentPickUp;

var float AdrenalineAmount;

/* DetourWeight()
value of this path to take a quick detour (usually 0, used when on route to distant objective, but want to grab inventory for example)
*/
function float DetourWeight(Pawn Other,float PathWeight)
{
	if ( (PathWeight > 500) || !Other.Controller.NeedsAdrenaline() )
		return 0;
	if ( (Other.Controller.Enemy != None) && (Level.TimeSeconds - Other.Controller.LastSeenTime < 1) )
		return 0;
	
	return 0.15/PathWeight;
}

event float BotDesireability(Pawn Bot)
{
	if ( Bot.Controller.bHuntPlayer )
		return 0;
	if ( !Bot.Controller.NeedsAdrenaline() )
		return 0;
	return MaxDesireability;
}

auto state Pickup
{	
	function Touch( actor Other )
	{
        local Pawn P;
			
		if ( ValidTouch(Other) ) 
		{			
            P = Pawn(Other);	
    		P.Controller.AwardAdrenaline(AdrenalineAmount);
            AnnouncePickup(P);
            SetRespawn();			
		}
	}
}

defaultproperties
{
     AdrenalineAmount=2.000000
     MaxDesireability=0.300000
     RespawnTime=30.000000
     PickupMessage="Adrenaline "
     PickupSound=Sound'PickupSounds.AdrenelinPickup'
     PickupForce="AdrenelinPickup"
     DrawType=DT_StaticMesh
     StaticMesh=StaticMesh'XPickups_rc.AdrenalinePack'
     CullDistance=5500.000000
     Physics=PHYS_Rotating
     DrawScale=0.070000
     AmbientGlow=128
     ScaleGlow=0.600000
     Style=STY_AlphaZ
     CollisionRadius=32.000000
     CollisionHeight=23.000000
     Mass=10.000000
     RotationRate=(Yaw=24000)
}
