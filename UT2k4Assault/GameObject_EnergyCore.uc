//==============================================================================
// GameObject_EnergyCore
//==============================================================================
// Created by Laurent Delayen
// © 2003, Epic Games, Inc.  All Rights Reserved
//==============================================================================

class GameObject_EnergyCore extends GameObject;

var		localized string 	PlayerDroppedMessage, DroppedMessage, EnergyCorePickedUp, PlayerPickedUpEnergyCore, PlayerCoreReset;

var		name	Announcer_EnergyCore_Dropped, Announcer_EnergyCore_PickedUp, Announcer_EnergyCore_Reset;
var		bool	bSoundsPrecached;
var		ASOBJ_EnergyCore_Spawn MySpawnObjective;

function bool CanBePickedUpBy(Pawn P)
{
	return  ( P.GetTeamNum() != Level.Game.GetDefenderNum() && !P.IsA('Vehicle') );
}

function bool ValidHolder(Actor Other)
{
	if ( super.ValidHolder( Other ) && Other.IsA('Pawn') )
		return CanBePickedUpBy( Pawn(Other) );

	return false;
}

function SetHolder(Controller C)
{
	local Controller	Ctrl;

	if ( C == None || C.Pawn == None )
		return;
	for ( Ctrl=Level.ControllerList; Ctrl!=None; Ctrl=Ctrl.nextController )
		if ( PlayerController(Ctrl) != None )
			PlayerController(Ctrl).ReceiveLocalizedMessage(class'Message_PowerCore', 3, C.PlayerReplicationInfo,,MySpawnObjective );

	super.SetHolder( C );

	HomeBase.DisableObjective( C.Pawn );
}

function ClearHolder()
{
	super.ClearHolder();
}

function Drop(vector newVel)
{
	local Controller	C;

	if ( Holder != None && Holder.PlayerReplicationInfo != None )
	{
		for ( C=Level.ControllerList; C!=None; C=C.nextController )
			if ( PlayerController(C) != None )
				PlayerController(C).ReceiveLocalizedMessage(class'Message_PowerCore', 0, Holder.PlayerReplicationInfo,, MySpawnObjective );
	}
	else
	{
		for ( C=Level.ControllerList; C!=None; C=C.nextController )
			if ( PlayerController(C) != None )
				PlayerController(C).ReceiveLocalizedMessage(class'Message_PowerCore', 1,,, MySpawnObjective);
	}

	super.Drop( newVel );
}

function HolderDied()
{
	Drop( vect(0,0,0) );
}

function LogReturned()
{
	local Controller C;

	for ( C=Level.ControllerList; C!=None; C=C.nextController )
		if ( PlayerController(C) != None )
			PlayerController(C).ReceiveLocalizedMessage(class'Message_PowerCore', 4,,, MySpawnObjective);
}


simulated function PrecacheAnnouncer(AnnouncerVoice V, bool bRewardSounds)
{
	if ( !bRewardSounds && !bSoundsPrecached )
	{
		bSoundsPrecached = true;
		V.PrecacheSound( Announcer_EnergyCore_Dropped );
		V.PrecacheSound( Announcer_EnergyCore_PickedUp );
	}
}

defaultproperties
{
     PlayerDroppedMessage=" dropped the Power Core!"
     DroppedMessage="Power Core dropped!"
     EnergyCorePickedUp="Power Core picked up!"
     PlayerPickedUpEnergyCore=" picked up the Power Core!"
     PlayerCoreReset="Power Core reset!"
     Announcer_EnergyCore_Dropped="JY_PowerCoreDropped"
     Announcer_EnergyCore_PickedUp="JY_PowerCorePickedUp"
     Announcer_EnergyCore_Reset="JY_PowerCoreReset"
     bHome=True
     GameObjBone="spine"
     GameObjOffset=(X=25.000000,Y=50.000000)
     GameObjRot=(Roll=16384)
     LightType=LT_Steady
     LightEffect=LE_QuadraticNonIncidence
     LightHue=40
     LightBrightness=200.000000
     LightRadius=6.000000
     DrawType=DT_StaticMesh
     StaticMesh=StaticMesh'AS_Decos.HellbenderEngine'
     bStatic=False
     bDynamicLight=True
     bStasis=False
     bAlwaysRelevant=True
     NetUpdateFrequency=100.000000
     NetPriority=3.000000
     DrawScale=0.750000
     PrePivot=(X=2.000000,Z=0.500000)
     bUnlit=True
     CollisionRadius=24.000000
     CollisionHeight=20.000000
     bCollideActors=True
     bCollideWorld=True
     Buoyancy=20.000000
}
