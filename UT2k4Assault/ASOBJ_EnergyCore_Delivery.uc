//=============================================================================
// ASOBJ_EnergyCore_Delivery
//=============================================================================
// Created by Laurent Delayen (C) 2003 Epic Games
//=============================================================================

class ASOBJ_EnergyCore_Delivery extends ProximityObjective;

#exec OBJ LOAD FILE=AnnouncerAssault.uax

var GameObject_EnergyCore EC;

function bool IsRelevant( Pawn Instigator, bool bAliveCheck )
{
	Local PlayerReplicationInfo	PRI;

	PRI = Instigator.PlayerReplicationInfo;
	if ( super.IsRelevant( Instigator, bAliveCheck )
		&& (PRI != None) && (PRI.HasFlag != None) && PRI.HasFlag.IsA('GameObject_EnergyCore') )
		return true;

	return false;
}

/* triggered by intro cinematic to auto complete objective */
function CompleteObjective( Pawn Instigator )
{
	super.DisableObjective( Instigator );
}

function DisableObjective(Pawn Instigator)
{
	local PlayerReplicationInfo	PRI;
	local GameObject_EnergyCore	EnergyCore;

	PRI = Instigator.PlayerReplicationInfo;

	if ( !IsActive() || PRI == None || PRI.HasFlag == None || !PRI.HasFlag.IsA('GameObject_EnergyCore') )
		return;

	EnergyCore = GameObject_EnergyCore(PRI.HasFlag);
	EnergyCore.ClearHolder();
	EnergyCore.Destroy();

	super.DisableObjective( Instigator );
}


/* TellBotHowToDisable()
tell bot what to do to disable me.
return true if valid/useable instructions were given
*/
function bool TellBotHowToDisable(Bot B)
{
	if ( B.PlayerReplicationInfo.HasFlag != None )
	{
		if ( EC == None )
			EC = GameObject_EnergyCore(B.PlayerReplicationInfo.HasFlag);
		B.GoalString = "Take Energy Core to vehicle";
		return B.Squad.FindPathToObjective(B,self);
	}

	if ( EC == None )
	{
		ForEach DynamicActors(class'GameObject_EnergyCore', EC)
			break;
		if ( EC == None )
		{
			log("NO ENERGY CORE");
			return false;
		}
	}

	if ( EC.Holder != None )
	{
		B.GoalString = "Protect Energy Core holder";
		if ( VSize(EC.Holder.Location - B.Pawn.Location) < 1200 )
			return false;

		return B.Squad.FindPathToObjective(B,EC.Holder);
	}
	B.GoalString = "Go pick up Energy Core";
	return B.Squad.FindPathToObjective(B,EC);
}

defaultproperties
{
     DefenderTeamIndex=1
     ObjectiveName="Energy Core Delivery"
     Announcer_DisabledObjective=Sound'AnnouncerAssault.Generic.JY_vehicle_operational'
     Announcer_ObjectiveInfo=Sound'AnnouncerAssault.Generic.JY_return_core'
     Announcer_DefendObjective=Sound'AnnouncerAssault.Generic.JY_PreventVehicleRepair'
}
