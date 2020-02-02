//==============================================================================
//	Base class for filter tab panels that contain PlayInfo settings
//
//	Created by Ron Prestenback
//	© 2003, Epic Games, Inc.  All Rights Reserved
//==============================================================================
class GUIFilterPanel extends UT2K4PlayInfoPanel DependsOn(CustomFilter);

var string							CurrentGame;
var UT2K4CustomFilterPage			p_Anchor;
var BrowserFilters					FilterMaster;
var array<CustomFilter.AFilterRule>	FilterRules;

var string FilterTypeString[7];

function InitComponent(GUIController MyC, GUIComponent MyO)
{
	Super.InitComponent(MyC, MyO);

	p_Anchor = UT2K4CustomFilterPage(MyO.MenuOwner.MenuOwner);
	FilterMaster = p_Anchor.FM;
	GamePI = p_Anchor.FilterPI;
}

function bool CanShowPanel()
{
	if (p_Anchor == None || FilterMaster == None)
		return false;

	if (p_Anchor.Index < 0)
		return false;

	return Super.CanShowPanel();
}

function InitPanel()
{
	Super.InitPanel();

	Opened(MenuOwner);
}

function AddFilterRule(CustomFilter.AFilterRule NewRule)
{
}

function PopulateFilterTypes(moCombobox NewCombo, bool Ranged)
{
	if (NewCombo == None)
	{
		Warn("Call to PopulateFilterTypes with value None!");
		return;
	}
	NewCombo.ReadOnly(True);

	NewCombo.AddItem(FilterTypeString[0],,"QT_Disabled");

	if (!Ranged)
	{
		NewCombo.AddItem(FilterTypeString[1],,"QT_Equals");
		NewCombo.AddItem(FilterTypeString[2],,"QT_NotEquals");
		return;
	}

	NewCombo.AddItem(FilterTypeString[3],,"QT_GreaterThan");
	NewCombo.AddItem(FilterTypeString[4],,"QT_GreaterThanEquals");
	NewCombo.AddItem(FilterTypeString[5],,"QT_LessThan");
	NewCombo.AddItem(FilterTypeString[6],,"QT_LessThanEquals");
}

defaultproperties
{
     FilterTypeString(0)="Disabled"
     FilterTypeString(1)="Equals"
     FilterTypeString(2)="Not"
     FilterTypeString(3)="Higher"
     FilterTypeString(4)="Or Higher"
     FilterTypeString(5)="Lower"
     FilterTypeString(6)="Or Lower"
}
