// ====================================================================
//  Class:  Engine.HudOverlay
//  Parent: Engine.Actor
//
//  HudOverlays are used to display alternate information on the hud
// ====================================================================

class HudOverlay extends Actor;

simulated function Render(Canvas C);

simulated function Destroyed()
{
	if (HUD(Owner) != None)
		HUD(Owner).RemoveHudOverlay(self);

	Super.Destroyed();
}

defaultproperties
{
     bHidden=True
     RemoteRole=ROLE_None
}
