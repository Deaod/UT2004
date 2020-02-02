//=============================================================================
// AntiPortalActor.
//=============================================================================

class AntiPortalActor extends Actor
	native
	placeable;

//
//	TriggerControl
//

state() TriggerControl
{
	// Trigger

	simulated event Trigger(Actor Other,Pawn EventInstigator)
	{
		SetDrawType(DT_None);
	}

	// UnTrigger

	simulated event UnTrigger(Actor Other,Pawn EventInstigator)
	{
		SetDrawType(DT_AntiPortal);
	}
}

//
//	TriggerToggle
//

state() TriggerToggle
{
	// Trigger

	simulated event Trigger(Actor Other,Pawn EventInstigator)
	{
		if (DrawType == DT_AntiPortal)
			SetDrawType(DT_None);
		else if(DrawType == DT_None)
			SetDrawType(DT_AntiPortal);
	}
}

//
//	Default properties
//

defaultproperties
{
     DrawType=DT_AntiPortal
     bNoDelete=True
     RemoteRole=ROLE_None
     bEdShouldSnap=True
}
