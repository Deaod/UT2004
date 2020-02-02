//=============================================================================
// ASCinematic_Camera
//=============================================================================
// Created by Laurent Delayen
// © 2003, Epic Games, Inc.  All Rights Reserved
//=============================================================================

class ASCinematic_Camera extends Actor
	placeable;

var()	float				ShotLength;				// length of shot in seconds...
var()	name				EventViewingCamera;		// Event triggered when camera is active
var()	name				NextCameraTag;
var		ASCinematic_Camera	NextCamera;
var()	bool				bInitiallyActive;
var		bool				bActive;

var		ASCinematic_SceneManager	ASCSM;

function PostBeginPlay()
{
	super.PostBeginPlay();

	bActive = bInitiallyActive;

	if ( NextCameraTag != '' )
		ForEach AllActors(class'ASCinematic_Camera', NextCamera, NextCameraTag)
			break;

	if ( ShotLength == 0 )	// safety check
		ShotLength = 2;
}

/* Specific version, when viewing an objective for end of round cam (and attackers didn't win)*/
function ViewFixedObjective( PlayerController PC, GameObjective GO )
{	
	PC.ClientSetFixedCamera( true );
	PC.ClientSetViewTarget( Self );
	PC.SetViewTarget( Self );
}

/* Scene Manager sets the view on this camera */
function SetView( ASCinematic_SceneManager SM )
{
	local Controller		C, NextC;
	local PlayerController	PC;

	C = Level.ControllerList;
	while ( C != None  )
	{
		NextC = C.NextController;
		if ( C.PlayerReplicationInfo != None && !C.PlayerReplicationInfo.bOnlySpectator )
		{
			PC = PlayerController(C);
			if ( PC != None )
			{
				PC.ClientSetFixedCamera( true );
				PC.ClientSetViewTarget( Self );
				PC.SetViewTarget( Self );
			}
		}
		C = NextC;
	}

	TriggerEvent(EventViewingCamera, Self, None);

	if ( SM != None )
	{
		SetTimer( ShotLength, false );
		ASCSM = SM;
	}
}

function Timer()
{
	ASCSM.ShotEnded( Self );
}

function Trigger( Actor Other, Pawn EventInstigator )
{
	bActive = !bActive;
}

/* Reset()
reset actor to initial state - used when restarting level without reloading.
*/
function Reset()
{
	super.Reset();
	bActive = bInitiallyActive;
}

defaultproperties
{
     ShotLength=2.000000
     bInitiallyActive=True
     bHidden=True
     bNoDelete=True
     RemoteRole=ROLE_None
     Texture=Texture'Engine.Proj_Icon'
}
