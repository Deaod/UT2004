// ====================================================================
//  Class: BonusPack.DamTypeMutant
//
//  Damage class for mutant losing health over time.
//
//  Written by James Golding
//  (c) 2003, Epic Games, Inc.  All Rights Reserved
// ====================================================================

class DamTypeMutant extends DamageType
	abstract;

defaultproperties
{
     DeathString="%o suffered a fatal mutation!"
     FemaleSuicide="%o suffered a fatal mutation!"
     MaleSuicide="%o suffered a fatal mutation!"
     bArmorStops=False
     bLocationalHit=False
     bCausesBlood=False
}
