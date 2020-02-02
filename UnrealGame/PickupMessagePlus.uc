//
// OptionalObject is an Pickup class
//
class PickupMessagePlus extends LocalMessage;

static simulated function ClientReceive( 
	PlayerController P,
	optional int Switch,
	optional PlayerReplicationInfo RelatedPRI_1, 
	optional PlayerReplicationInfo RelatedPRI_2,
	optional Object OptionalObject
	)
{
	Super.ClientReceive(P, Switch, RelatedPRI_1, RelatedPRI_2, OptionalObject);
	if ( class<Pickup>(OptionalObject) == None )
		return;
		
	if ( P.MyHUD != None )
		class<Pickup>(OptionalObject).static.UpdateHUD(P.MyHUD);
		
    // jdf ---
    if( P.bEnablePickupForceFeedback )
        P.ClientPlayForceFeedback( class<Pickup>(OptionalObject).default.PickupForce );
    // --- jdf
}

defaultproperties
{
     bIsUnique=True
     bFadeMessage=True
     PosY=0.900000
}
