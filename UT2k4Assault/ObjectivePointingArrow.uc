//=============================================================================
// ObjectivePointingArrow
//=============================================================================
// Created by Laurent Delayen
// © 2003, Epic Games, Inc.  All Rights Reserved
//=============================================================================

class ObjectivePointingArrow extends Actor;

var vector DrawOffset;

var Material	PulseTeamSkin[2], TeamSkin[2];

simulated function SetTeamSkin( byte Team, bool bPulse )
{	
	if ( bPulse )
		Skins[0] = PulseTeamSkin[Team];
	else
		Skins[0] = TeamSkin[Team];
}

simulated function SetYellowColor( bool bPulse )
{
	if ( bPulse )
		Skins[0] = Shader'AS_FX_TX.Skins.OBJ_ArrowPulse_Yellow_S';
	else
		Skins[0] = Shader'AS_FX_TX.Skins.OBJ_ArrowNormal_Yellow_S';
}

simulated function Render( Canvas C, PlayerController PC, Actor TrackedActor )
{
	local rotator	ArrowRot, CamRot;
	local vector	ArrowLoc, CamLoc, X, Y, Z;
	local Actor		A;
	local float		ScreenRatio;

	PC.PlayerCalcView(A, CamLoc, CamRot );

	// Arrow Location
	ScreenRatio = 1.333333333333 / (C.ClipX / C.ClipY);

	PC.GetAxes( CamRot, X, Y, Z );
	ArrowLoc = CamLoc + X * DrawOffset.X + Y * DrawOffset.Y + Z * ScreenRatio * DrawOffset.Z;
	SetLocation( ArrowLoc );

	// Arrow Rotation
	//ArrowRot		= Rotator( ArrowLoc - PC.GetPathTo(CurrentObjective).Location );
	ArrowRot		= Rotator( ArrowLoc - TrackedActor.Location );
	ArrowRot.Pitch += 32768;
	SetRotation( ArrowRot );

	// Draw Arrow
	//C.DrawActor(None, false, true);	// Clear Z-Buffer first!
	C.DrawActor(Self, false, false, 90.0);
}

defaultproperties
{
     DrawOffset=(X=16.000000,Z=9.500000)
     PulseTeamSkin(0)=Shader'AS_FX_TX.Skins.ObjectiveArrow_Red_S'
     PulseTeamSkin(1)=Shader'AS_FX_TX.Skins.ObjectiveArrow_Blue_S'
     TeamSkin(0)=Shader'AS_FX_TX.Skins.OBJ_ArrowNormal_Red_S'
     TeamSkin(1)=Shader'AS_FX_TX.Skins.OBJ_ArrowNormal_Blue_S'
     DrawType=DT_StaticMesh
     StaticMesh=StaticMesh'AS_Weapons_SM.fX.ObjectiveArrow'
     bLightingVisibility=False
     bHidden=True
     bOnlyOwnerSee=True
     bAcceptsProjectors=False
     RemoteRole=ROLE_None
     DrawScale=0.015000
     DrawScale3D=(Y=4.000000)
     bUnlit=True
     bBlockZeroExtentTraces=False
     bBlockNonZeroExtentTraces=False
}
