//==============================================================================
// DestroyableObjective_SM
//==============================================================================
// Created by Laurent Delayen
// © 2003, Epic Games, Inc.  All Rights Reserved
//==============================================================================
// Specific subclass using staticmesh collision instead of cylinder collision.
// also provides an optional "destroyed version" staticmesh
//==============================================================================

class DestroyableObjective_SM extends DestroyableObjective;

var()	StaticMesh	DestroyedStaticMesh;
var		StaticMesh	OriginalMesh, OldStaticMesh;

// Used for controlling antiportals
var array<AntiPortalActor>	AntiPortals;	
var() name					AntiPortalTag;


simulated function PostBeginPlay()
{
	local AntiPortalActor AntiPortalA;

	OriginalMesh	= StaticMesh;
	OldStaticMesh	= StaticMesh;
	
	if ( AntiPortalTag != '' )
	{
		foreach AllActors(class'AntiPortalActor', AntiPortalA, AntiPortalTag)
			AntiPortals[AntiPortals.Length] = AntiPortalA;
	}

	super.PostBeginPlay();
}

simulated function AdjustAntiPortals()
{
	local int i;

	if ( AntiPortals.Length > 0 )
	{
		if ( StaticMesh == OriginalMesh )
		{
			for (i=0; i<AntiPortals.Length; i++)
				if ( AntiPortals[i].DrawType != DT_AntiPortal )
					AntiPortals[i].SetDrawType( DT_AntiPortal );
		}
		else
		{
			for (i=0; i<AntiPortals.Length; i++)
				if ( AntiPortals[i].DrawType != DT_None )
					AntiPortals[i].SetDrawType( DT_None );
		}
	}
}

simulated function PostNetReceive()
{
	super.PostNetReceive();

	if ( OldStaticMesh != StaticMesh )
	{
		KSetBlockKarma( false );
		KSetBlockKarma( true );				// Update karma collision
		OldStaticMesh = StaticMesh;
		AdjustAntiPortals();
	}
}

/* Reset()
reset actor to initial state - used when restarting level without reloading.
*/
function Reset()
{
	if ( DestroyedStaticMesh != None )
	{
		KSetBlockKarma( false );
		SetStaticMesh( OriginalMesh );
		KSetBlockKarma( true );
		AdjustAntiPortals();
	}
	else
		bHidden = false;
	
	super.Reset();
}

function DisableObjective(Pawn Instigator)
{
	if ( !bActive || bDisabled || !UnrealMPGameInfo(Level.Game).CanDisableObjective( Self ) )
		return;

	super.DisableObjective(Instigator);

	if ( DestroyedStaticMesh != None )
	{
		KSetBlockKarma( false );
		SetStaticMesh( DestroyedStaticMesh );
		SetCollision(true, bBlockActors);
		KSetBlockKarma( true );				// Update karma collision
		AdjustAntiPortals();
	}
	else
		bHidden = true;
}

simulated function UpdatePrecacheStaticMeshes()
{
	super.UpdatePrecacheStaticMeshes();

	if ( DestroyedStaticMesh != None )
		Level.AddPrecacheStaticMesh( DestroyedStaticMesh );
}

defaultproperties
{
     DrawType=DT_StaticMesh
     StaticMesh=StaticMesh'Editor.TexPropCube'
     bHidden=False
     bStaticLighting=True
     bBlockActors=True
     bBlockKarma=True
     bBlocksTeleport=True
     bEdShouldSnap=True
}
