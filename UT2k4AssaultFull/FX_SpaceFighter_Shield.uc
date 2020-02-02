//=============================================================================
// FX_SpaceFighter_Shield
//=============================================================================
// Created by Laurent Delayen
// © 2003, Epic Games, Inc.  All Rights Reserved
//=============================================================================

class FX_SpaceFighter_Shield extends Actor;


simulated function Tick(float deltaTime)
{
	local float pct;

	if ( Level.NetMode == NM_DedicatedServer )
	{
		Disable('Tick');
		return;
	}

	pct = LifeSpan / default.LifeSpan;
	SetDrawScale( 6 + 8*(1-pct) );
}

defaultproperties
{
     DrawType=DT_StaticMesh
     StaticMesh=StaticMesh'WeaponStaticMesh.Shield'
     bNetTemporary=True
     bReplicateInstigator=True
     bNetInitialRotation=True
     RemoteRole=ROLE_SimulatedProxy
     LifeSpan=0.600000
     DrawScale=12.000000
     Skins(0)=FinalBlend'XEffectMat.Shield.BlueShell'
     Skins(1)=FinalBlend'XEffectMat.Shield.BlueShell'
     AmbientGlow=250
     bUnlit=True
     bOwnerNoSee=True
     bHardAttach=True
}
