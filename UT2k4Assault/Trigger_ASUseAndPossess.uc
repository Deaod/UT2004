//=============================================================================
// Trigger_ASUseAndRespawn
//=============================================================================
// Allows Player to Possess a Pawn with the "Use" Key.
// Pawn is found using its Tag name.
//
// Several Pawns are supported.
// - EventFull is called when no more Pawns can be possessed
// - EventNonFull is called when a Pawn to possess is freed
//=============================================================================
//	Created by Laurent Delayen
//	© 2003, Epic Games, Inc.  All Rights Reserved
//=============================================================================

class Trigger_ASUseAndPossess extends SVehicleTrigger
	placeable;

var()	enum AT_AssaultTeam
{
	AT_All,
	AT_Attackers,
	AT_Defenders,
} AssaultTeam;


var()	name	PawnTag;		// Tag of Pawn(s) to possess

var()	name	EventFull;		// called when there's no more pawns to possess
var()	name	EventNonFull;	// ''     when there is a free spot available
var		bool	bFullCapacity;

var     Array<ASVehicleFactory>	 FactoryList;


event PostBeginPlay()
{
	local ASVehicleFactory	ASVF;

	ForEach DynamicActors(class'ASVehicleFactory', ASVF)
		if ( ASVF.VehicleTag == PawnTag )
			FactoryList[FactoryList.Length] = ASVF;

	super.PostBeginPlay();

	if ( !bEnabled )
		NotifyAvailability( false );
}

event Trigger( Actor Other, Pawn EventInstigator )
{
	bEnabled = !bEnabled;

	if ( bEnabled )
	{
		// Check capacity, we might try to enable something that doesn't have any Pawns to possess...
		UpdateCapacity();

		if ( !bFullCapacity )
			NotifyAvailability( true );
	}
	else
	{
		SetCollision( false );
		if ( !bFullCapacity )
			NotifyAvailability( false );
	}
}

event VehicleSpawned()
{
	if ( bEnabled && bFullCapacity )	// free spot, only check if full
		UpdateCapacity();
}

event VehicleDestroyed()
{
	if ( bEnabled && !bFullCapacity )	// one less spot... check only if not full
		UpdateCapacity();
}

event VehicleUnPossessed()
{
	if ( bEnabled && bFullCapacity )	// free spot, only check if full
		UpdateCapacity();
}

event VehiclePossessed()
{
	if ( bEnabled && !bFullCapacity )	// free spot, only check if full
		UpdateCapacity();
}


// Check if a Team is valid
function bool ApprovePlayerTeam(byte Team)
{
	if ( AssaultTeam == AT_All )
		return true;

	if ( Level.Game.IsA('ASGameInfo') )
	{
		if ( AssaultTeam == AT_Attackers ) {
			if ( ASGameInfo(Level.Game).IsAttackingTeam(Team) ) return true; }
		else if ( !ASGameInfo(Level.Game).IsAttackingTeam(Team) ) return true;
	}

	return false;
}


function Touch( Actor Other )
{
	local xPawn			User;
	local Controller	C;

	User = xPawn(Other);

	if ( !bEnabled || bFullCapacity || (User == None) || (User.Controller == None) )
		return;

	C = User.Controller;

	if ( (AIController(C) != None)
		&& ((C.RouteGoal == self) || (C.Movetarget == self) || (C.RouteGoal == myMarker) || (C.Movetarget == myMarker) )  )
	{
		if ( (C.PlayerReplicationInfo != None) && !C.PlayerReplicationInfo.bOnlySpectator
			&& ApprovePlayerTeam(C.PlayerReplicationInfo.Team.TeamIndex) )
			UsedBy(User);

		return;
	}

	// Send a string message to the toucher.
	User.ReceiveLocalizedMessage(class'Vehicles.BulldogMessage', 0);
}


function UsedBy( Pawn user )
{
	local Vehicle	V;
	local int		i;

	if ( !bEnabled || bFullCapacity || (User == None) || (User.Controller == None) || !ApprovePlayerTeam( User.GetTeamNum() ) )
		return;

	for (i=0; i<FactoryList.Length; i++)
	{
		V = FactoryList[i].Child;

		if ( (V != None) && (V.Health > 0) && !V.bDeleteMe )
		{
			if ( V.Controller == None || !V.Controller.IsA('PlayerController') )
			{
				V.TryToDrive( User );
				break;
			}
		}
	}

	UpdateCapacity();
}


function UpdateCapacity()
{
	local Vehicle	V;
	local bool		bOldCapacity;
	local int		i;

	bOldCapacity	= bFullCapacity;
	bFullCapacity	= true;

	// Check if there is a Pawn left to possess...
	for (i=0; i<FactoryList.Length; i++)
	{
		V = FactoryList[i].Child;
		if ( (V != None) && (V.Health > 0) && !V.bDeleteMe )
		{
			if ( V.Controller == None || !V.Controller.IsA('PlayerController') )
				bFullCapacity = false;
		}
	}

	if ( bEnabled && bOldCapacity && !bFullCapacity )
		NotifyAvailability( true );

	if ( bEnabled && !bOldCapacity && bFullCapacity )
		NotifyAvailability( false );
}


/* Reset()
reset actor to initial state - used when restarting level without reloading.
*/
function Reset()
{
	local bool bOldEnabled;

	bOldEnabled = bEnabled;
	super.Reset();

	if ( bOldEnabled != bEnabled || (bEnabled && bFullCapacity) )
		NotifyAvailability( bEnabled );

	bFullCapacity = false;
}

/* Called when the controller changes its status from "FULL or DISABLED" to "AVAILABLE" */
event NotifyAvailability( bool bAvailableSpace )
{
	SetCollision( bAvailableSpace );

	if ( bAvailableSpace )
		TriggerEvent( EventNonFull, Self, None);
	else
		TriggerEvent( EventFull, Self, None);
}

event PrevVehicle( ASVehicleFactory ASVF, Vehicle V )
{
	local int				i, CurrentIndex;
	local ASVehicleFactory	newASVF;
	local PlayerController	PC;
	local Vector			ExitPos;

	PC = PlayerController(V.Controller);
	if ( !bEnabled || bFullCapacity || (V==None) || (PC==None) )
		return;

	// Lookup current ASVF index
	for (i=0; i<FactoryList.Length; i++)
		if ( FactoryList[i] == ASVF )
		{
			CurrentIndex = i;
			break;
		}

	// Scan from CurrentIndex - 1 -> 0
	i = CurrentIndex - 1;
	while ( i >= 0 )
	{
		if ( FactoryList[i].Child != None && ( FactoryList[i].Child.Controller == None || !FactoryList[i].Child.Controller.IsA('PlayerController') ) )
		{
			newASVF = FactoryList[i];
			break;
		}
		i--;
	}

	// Scan fron Length -> CurrentIndex
	if ( newASVF == None )
	{
		i = FactoryList.Length - 1;
		while ( i > CurrentIndex )
		{
			if ( FactoryList[i].Child != None && ( FactoryList[i].Child.Controller == None || !FactoryList[i].Child.Controller.IsA('PlayerController') ) )
			{
				newASVF = FactoryList[i];
				break;
			}
			i--;
		}
	}

	// Exit current vehicle, and possess next one
	if ( newASVF != None )
	{
		if ( !V.bRelativeExitPos )
			ExitPos = V.ExitPositions[0];
		V.KDriverLeave( true );		
		newASVF.Child.TryToDrive( PC.Pawn );
		if ( !newASVF.Child.bRelativeExitPos )
			newASVF.Child.ExitPositions[0] = ExitPos;
	}
}

event NextVehicle( ASVehicleFactory ASVF, Vehicle V )
{
	local int				i, CurrentIndex;
	local ASVehicleFactory	newASVF;
	local PlayerController	PC;
	local Vector			ExitPos;

	PC = PlayerController(V.Controller);
	if ( !bEnabled || bFullCapacity || (V==None) || (PC==None) )
		return;

	// Lookup current ASVF index
	for (i=0; i<FactoryList.Length; i++)
		if ( FactoryList[i] == ASVF )
		{
			CurrentIndex = i;
			break;
		}

	// Scan from CurrentIndex + 1 -> Length - 1
	i = CurrentIndex + 1;
	while ( i < FactoryList.Length )
	{
		if ( FactoryList[i].Child != None && ( FactoryList[i].Child.Controller == None || !FactoryList[i].Child.Controller.IsA('PlayerController') ) )
		{
			newASVF = FactoryList[i];
			break;
		}
		i++;
	}

	// Scan from 0 -> CurrentIndex - 1
	if ( newASVF == None )
	{
		i = 0;
		while ( i < CurrentIndex )
		{
			if ( FactoryList[i].Child != None && ( FactoryList[i].Child.Controller == None || !FactoryList[i].Child.Controller.IsA('PlayerController') ) )
			{
				newASVF = FactoryList[i];
				break;
			}
			i++;
		}
	}

	// Exit current vehicle, and possess next one
	if ( newASVF != None )
	{
		if ( !V.bRelativeExitPos )
			ExitPos = V.ExitPositions[0];
		V.KDriverLeave( true );		
		newASVF.Child.TryToDrive( PC.Pawn );
		if ( !newASVF.Child.bRelativeExitPos )
			newASVF.Child.ExitPositions[0] = ExitPos;
	}
}

//=============================================================================
// defaultproperties
//=============================================================================

defaultproperties
{
     bMarkWithPath=True
     bNoDelete=True
     bHardAttach=False
     bCollideActors=True
}
