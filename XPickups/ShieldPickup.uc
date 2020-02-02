//=============================================================================
// ShieldPickup - cut and paste from TournamentHealth
//=============================================================================
class ShieldPickup extends TournamentPickUp
	abstract notplaceable;

var() int ShieldAmount;

/* DetourWeight()
value of this path to take a quick detour (usually 0, used when on route to distant objective, but want to grab inventory for example)
*/
function float DetourWeight(Pawn Other,float PathWeight)
{
	local float Need;
	
	Need = Other.CanUseShield(ShieldAmount);
	if ( Need <= 0 )
		return 0;
	if ( AIController(Other.Controller).PriorityObjective() && (Need < 0.4 * Other.GetShieldStrengthMax()) )
		return (0.005 * MaxDesireability * Need)/PathWeight; 
	return (0.013 * MaxDesireability * Need)/PathWeight;
}

simulated static function UpdateHUD(HUD H)
{
	H.LastPickupTime = H.Level.TimeSeconds;
	H.LastArmorPickupTime = H.LastPickupTime;
}

event float BotDesireability(Pawn Bot)
{
	return (0.013 * MaxDesireability * Bot.CanUseShield(ShieldAmount));
}

static function string GetLocalString(
	optional int Switch,
	optional PlayerReplicationInfo RelatedPRI_1, 
	optional PlayerReplicationInfo RelatedPRI_2
	)
{
	return Default.PickupMessage$Default.ShieldAmount;
}

auto state Pickup
{	
	function Touch( actor Other )
	{
        local Pawn P;
			
		if ( ValidTouch(Other) ) 
		{			
			P = Pawn(Other);
            if ( P.AddShieldStrength(ShieldAmount) || !Level.Game.bTeamGame )
            {
				AnnouncePickup(P);
                SetRespawn();
            }
		}
	}
}

defaultproperties
{
     ShieldAmount=20
     MaxDesireability=1.500000
     RespawnTime=30.000000
     PickupMessage="You picked up a Shield Pack +"
     AmbientGlow=64
     CollisionHeight=23.000000
     Mass=10.000000
}
