//=============================================================================
// FX_LinkTurretShield
//=============================================================================
// Created by Laurent Delayen
// © 2003, Epic Games, Inc.  All Rights Reserved
//=============================================================================

class FX_LinkTurretShield extends Actor;

var float	Flash;
var bool	bSetUp;

#exec load obj FILE=JWAssaultMeshes

simulated function PostBeginPlay()
{
	local ColorModifier Alpha;

	super.PostBeginPlay();

	if ( Level.NetMode == NM_DedicatedServer )
		return;

	Alpha = ColorModifier(Level.ObjectPool.AllocateObject(class'ColorModifier'));
	Alpha.Material = Skins[0];
	Alpha.AlphaBlend = true;
	Alpha.RenderTwoSided = true;
	Alpha.Color.G = 255;
	Alpha.Color.A = 255;
	Skins[0] = Alpha;

	//Skins[1] = Alpha;
	//Skins[2] = Alpha;

	UpdateShieldColor();
	bSetUp = true;
}

simulated function Destroyed()
{
	if ( bSetUp )
	{
		Level.ObjectPool.FreeObject(Skins[0]);
		Skins[0] = None;
	}

	super.Destroyed();
}

simulated function SetOpacity( float pct )
{
	if ( !bSetUp )
		return;

	if ( pct < 0.01 )
	{
		bHidden = true;
		return;
	}

	bHidden = false;
	
	ColorModifier(Skins[0]).Color.A = 255 * pct;
}

simulated function DoFlash()
{
	Flash = 255;
}

simulated function Tick(float deltaTime)
{
	if ( Level.NetMode == NM_DedicatedServer )
	{
		Disable('Tick');
		return;
    }

	if ( bHidden || Flash <= 0)
		return;

	Flash -= (256 * deltatime);

	if ( Flash > 0 )
		UpdateShieldColor();
}

simulated function UpdateShieldColor()
{
	ColorModifier(Skins[0]).Color.R = 0;
	ColorModifier(Skins[0]).Color.G = 255 - int(Flash);
	ColorModifier(Skins[0]).Color.B = int(Flash);
}

defaultproperties
{
     DrawType=DT_StaticMesh
     StaticMesh=StaticMesh'JWAssaultMeshes.ShieldS.LinkTurretShield'
     bReplicateInstigator=True
     bNetInitialRotation=True
     RemoteRole=ROLE_None
     DrawScale=0.330000
     DrawScale3D=(Y=1.100000,Z=1.100000)
     PrePivot=(X=109.000000)
     Skins(0)=FinalBlend'AS_FX_TX.Skins.WhiteShield_FB'
     Skins(1)=FinalBlend'AS_FX_TX.Skins.WhiteShield_FB'
     Skins(2)=FinalBlend'AS_FX_TX.Skins.WhiteShield_FB'
     AmbientGlow=250
     bUnlit=True
     bOwnerNoSee=True
     bHardAttach=True
}
