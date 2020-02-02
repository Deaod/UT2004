//=============================================================================
// DestroyVehicleObjective
//=============================================================================
// Created by Laurent Delayen
// © 2003, Epic Games, Inc.  All Rights Reserved
//=============================================================================

class DestroyVehicleObjective extends GameObjective;

var ASVehicleFactory	TargetFactory;
var Vehicle				TargetVehicle;

replication
{
	reliable if ( Role == Role_Authority )
		TargetVehicle;
}

function PostBeginPlay()
{
	local ASVehicleFactory	ASVF;

	super.PostBeginPlay();

	ForEach AllActors(class'ASVehicleFactory', ASVF)
		if ( ASVF.VehicleEvent == Tag )
		{
			TargetFactory = ASVF;
			TargetVehicle = TargetFactory.Child;
			TargetFactory.MyDestroyVehicleObjective = Self;
			break;
		}
}

function VehicleSpawned( Vehicle NewTargetVehicle )
{
	NetUpdateTime = Level.TimeSeconds - 1;
	TargetVehicle = NewTargetVehicle;
	TargetVehicle.bNoFriendlyFire = true;
}

/* triggered by intro cinematic to auto complete objective */
function CompleteObjective( Pawn Instigator )
{
	if ( TargetVehicle != None && TargetVehicle.Health > 0 )
		TargetVehicle.Died( TargetVehicle.Controller, class'Suicided', TargetVehicle.Location );
	else
		DisableObjective( Instigator );
}

function Trigger(Actor Other, Pawn Instigator)
{
	if ( !bDisabled && UnrealMPGameInfo(Level.Game).CanDisableObjective( Self ) )
		DisableObjective( Instigator );
}

/* TellBotHowToDisable()
tell bot what to do to disable me.
return true if valid/useable instructions were given
*/
function bool TellBotHowToDisable(Bot B)
{
	if ( bDisabled || TargetVehicle == None )
		return false;

	if ( B.CanAttack( TargetVehicle ) )
	{
		B.GoalString = "Attack Objective";
		B.DoRangedAttackOn( TargetVehicle );
		return true;
	}

	return super.TellBotHowToDisable( B );
}

/* returns objective's progress status 1->0 (=disabled) */
simulated function float GetObjectiveProgress()
{
	if ( bDisabled || TargetVehicle == None )
		return 0;
	return (float(TargetVehicle.Health) / TargetVehicle.HealthMax);
}

defaultproperties
{
     bReplicateObjective=True
     bPlayCriticalAssaultAlarm=True
     ObjectiveName="Destroy Vehicle Objective"
     ObjectiveTypeIcon=FinalBlend'AS_FX_TX.Icons.OBJ_Destroy_FB'
     ObjectiveDescription="Destroy Objective to disable it."
     Objective_Info_Attacker="Destroy Vehicle Objective"
     Objective_Info_Defender="Protect Vehicle Objective"
     Announcer_DisabledObjective=Sound'AnnouncerAssault.Generic.Objective_destroyed'
     bNotBased=True
     bDestinationOnly=True
     bAlwaysRelevant=True
}
