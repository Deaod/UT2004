//=============================================================================
// ASCinematic_SceneManager
//=============================================================================
// Created by Laurent Delayen
// © 2003, Epic Games, Inc.  All Rights Reserved
//=============================================================================

class ASCinematic_SceneManager extends Info
	placeable;

var() name	CameraTag;
var() name	EventSceneStarted;
var() name	EventSceneEnded;

var	ASCinematic_Camera	Camera;


function PostBeginPlay()
{
	super.PostBeginPlay();
	if ( CameraTag != '' )
		ForEach AllActors(class'ASCinematic_Camera', Camera, CameraTag)
			break;
}

function Trigger( Actor Other, Pawn EventInstigator )
{
	PlayScene();
}

function PlayScene()
{
	Level.Game.SceneStarted( None, Self );
	Camera.SetView( Self );
	TriggerEvent(EventSceneStarted, Self, None);
}

event ShotEnded( ASCinematic_Camera Cam )
{
	if ( Cam != None && Cam.NextCamera != None && Cam.NextCamera != Camera )	// safety check, avoid loops
	{
		if ( Cam.NextCamera.bActive )
			Cam.NextCamera.SetView( Self );
		else
			ShotEnded( Cam.NextCamera );	// Skip if not active (use triggers to activate/deactivate cameras)
	}
	else
		SceneEnded();
}

event SceneEnded()
{
	Level.Game.SceneEnded( None, Self );
	TriggerEvent(EventSceneEnded, Self, None);
}

defaultproperties
{
     bNoDelete=True
     Texture=Texture'Engine.S_SceneManager'
}
