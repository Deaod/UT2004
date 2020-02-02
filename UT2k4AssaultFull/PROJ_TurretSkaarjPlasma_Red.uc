//=============================================================================
// PROJ_TurretSkaarjPlasma_Red
//=============================================================================
// Created by Laurent Delayen
// © 2003, Epic Games, Inc.  All Rights Reserved
//=============================================================================

class PROJ_TurretSkaarjPlasma_Red extends PROJ_TurretSkaarjPlasma;


simulated function SetupProjectile()
{
	super.SetupProjectile();
	FX_SpaceFighter_SkaarjPlasma(FX).SetRedColor();
}

simulated function SpawnExplodeFX(vector HitLocation, vector HitNormal)
{
	super.SpawnExplodeFX(HitLocation, HitNormal);

	if ( FX_Impact != None )
		FX_Impact.SetRedColor();
}

defaultproperties
{
}
