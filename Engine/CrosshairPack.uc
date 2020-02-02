//==============================================================================
//	Meta class for custom crosshair texture packs
//  In order for your custom crosshair texture packages to appear in the game, you must
//  export the crosshairs to cache files, using the 'exportcache' commandlet.
//
//  For details on using the 'exportcache' commandlet, see Engine.Mutator or type
//  'ucc help exportcache' at the command prompt.
//
//	Created by Ron Prestenback
//	© 2003, Epic Games, Inc.  All Rights Reserved
//==============================================================================
class CrosshairPack extends Object
	native
	abstract
	notplaceable
	CacheExempt;

struct native CrosshairItem
{
	var() localized string 	FriendlyName;		// Name of crosshair, as it will appear in drop-down list
	var() texture 	CrosshairTexture;
};

var()	const protected cache array<CrosshairItem>	Crosshair;

defaultproperties
{
}
