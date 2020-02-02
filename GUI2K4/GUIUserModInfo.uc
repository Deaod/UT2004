// ====================================================================
// (C) 2002, Epic Games
//
//
// The GUIUserModInfo is a class that allows mod authors to create TC/Mod records
// for their mods.  Users can then activate the mod from the User Mods menu.
//
// Mod authors subclass this actor in their package.  They then need
// to add the following line to their .INT file
//
// Object=(Class=Class,MetaClass=GUI2K4.GUIUserModInfo,Name=ModPackageName.CustomModInfoClassName)
//
//
//  ModName is the name of the mod.  It will appear in the list of mods.
//  ModInfo is the text to display in the Mod Info box.
//  ModLogo is the string name of an image to use as a logo for the mod
//  ModCmdLine is the command line parameters to use when activating the mod
//
// ====================================================================


class GUIUserModInfo extends GUI
	Abstract;

var localized string ModName;
var localized string ModInfo;
var localized string ModLogo;
var localized string ModCmdLine;

defaultproperties
{
}
