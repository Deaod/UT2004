// ====================================================================
//  Class:  xVoting.MapVoteMapListConfigPage
//
//	this page allows modification of the DefaultMapListLoader
//  configuration variables that could not be
//
//  Written by Bruce Bickar
//  (c) 2003, Epic Games, Inc.  All Rights Reserved
// ====================================================================
class MapVoteMapListConfigPage extends GUICustomPropertyPage DependsOn(VotingHandler);

var automated GUIButton  b_Return;
var automated moCheckBox ch_UseMapList;
var automated moEditBox  ed_MapListPrefix;
var automated MultiSelectListBox lb_MapList;
var localized string sbCaption;
var array<CacheManager.GameRecord> GameTypes;
// autosave
var bool bChanged;
//------------------------------------------------------------------------------------------------
function InitComponent(GUIController MyController, GUIComponent MyOwner)
{
	local int i;

	Super.Initcomponent(MyController, MyOwner);

	// load game types
	class'CacheManager'.static.GetGameTypeList(GameTypes);

	ch_UseMapList.SetComponentValue(string(class'xVoting.DefaultMapListLoader'.default.bUseMapList));
	if( class'xVoting.DefaultMapListLoader'.default.bUseMapList )
	{
		DisableComponent(ed_MapListPrefix);
		EnableComponent(lb_MapList);
	}
	else
	{
		EnableComponent(ed_MapListPrefix);
		DisableComponent(lb_MapList);
	}
	ed_MapListPrefix.SetComponentValue(class'xVoting.DefaultMapListLoader'.default.MapNamePrefixes);
	LoadMapLists();

	for(i=0; i<class'xVoting.DefaultMapListLoader'.default.MapListTypeList.Length; i++)
		lb_MapList.List.Find(class'xVoting.DefaultMapListLoader'.default.MapListTypeList[i],False,True);

	sb_Main.SetPosition(0.040000,0.146615,0.553789,0.507031);

	sb_Main.ManageComponent(lb_MapList);
	sb_Main.bFillClient=true;
	sb_Main.Caption = sbCaption;
	b_Ok.OnClick=OkClick;

	bChanged = False;
}
//------------------------------------------------------------------------------------------------
//function InternalOnOpen()
//{
//}
//------------------------------------------------------------------------------------------------
function LoadMapLists()
{
	local int i;

	lb_MapList.List.Clear();
	for(i=0; i<GameTypes.Length; i++)
		lb_MapList.List.Add(GameTypes[i].GameName $ " MapList", none, GameTypes[i].MapListClassName);
}
//------------------------------------------------------------------------------------------------
function UseMapList_Change(GUIComponent Sender)
{
	bChanged=True;
	if( bool(ch_UseMapList.GetComponentValue()) )
	{
		DisableComponent(ed_MapListPrefix);
		EnableComponent(lb_MapList);
	}
	else
	{
		EnableComponent(ed_MapListPrefix);
		DisableComponent(lb_MapList);
	}
}
//------------------------------------------------------------------------------------------------
function MapListChange(GUIComponent Sender)
{
	bChanged=True;
}
//------------------------------------------------------------------------------------------------
function SaveChange()
{
	local int i;
	local string SelectedMapLists;
	local array<string> MapListArray;

	if( bChanged )
	{
		SelectedMapLists = lb_MapList.List.GetExtra();
		Split(SelectedMapLists, ",", MapListArray);
		class'xVoting.DefaultMapListLoader'.default.MapListTypeList.Length = MapListArray.Length;
		for(i=0; i<MapListArray.Length; i++)
			class'xVoting.DefaultMapListLoader'.default.MapListTypeList[i] = MapListArray[i];
		class'xVoting.DefaultMapListLoader'.default.bUseMapList = bool(ch_UseMapList.GetComponentValue());
		class'xVoting.DefaultMapListLoader'.default.MapNamePrefixes = ed_MapListPrefix.GetComponentValue();
		class'xVoting.DefaultMapListLoader'.static.StaticSaveConfig();
		bChanged=False;
	}
}
//------------------------------------------------------------------------------------------------
function bool OkClick(GUIComponent Sender)
{
   	SaveChange();
   	Controller.CloseMenu(false);
   	return true;
}

defaultproperties
{
     Begin Object Class=moCheckBox Name=MapListCheckBox
         ComponentWidth=0.200000
         Caption="Use Map Cycle List"
         OnCreateComponent=MapListCheckBox.InternalOnCreateComponent
         Hint="Load map names from the specified maps lists or using the prefix."
         WinTop=0.087519
         WinLeft=0.227792
         WinWidth=0.543576
         WinHeight=0.037500
         TabOrder=0
         bBoundToParent=True
         bScaleToParent=True
         OnChange=MapVoteMapListConfigPage.UseMapList_Change
     End Object
     ch_UseMapList=moCheckBox'xVoting.MapVoteMapListConfigPage.MapListCheckBox'

     Begin Object Class=moEditBox Name=MapListLoaderPrefixEditBox
         CaptionWidth=0.400000
         ComponentWidth=0.600000
         Caption="Map Prefixes"
         OnCreateComponent=MapListLoaderPrefixEditBox.InternalOnCreateComponent
         Hint="List of map name prefixes. If more than one separate each with commas."
         WinTop=0.812161
         WinLeft=0.108671
         WinWidth=0.787323
         WinHeight=0.037500
         TabOrder=2
         bBoundToParent=True
         bScaleToParent=True
         OnChange=MapVoteMapListConfigPage.MapListChange
     End Object
     ed_MapListPrefix=moEditBox'xVoting.MapVoteMapListConfigPage.MapListLoaderPrefixEditBox'

     Begin Object Class=MultiSelectListBox Name=MapListListBox
         bVisibleWhenEmpty=True
         OnCreateComponent=MapListListBox.InternalOnCreateComponent
         Hint="Select each maplist type to load map names from."
         WinTop=0.146615
         WinLeft=0.040000
         WinWidth=0.553789
         WinHeight=0.507031
         TabOrder=1
         bBoundToParent=True
         bScaleToParent=True
         OnChange=MapVoteMapListConfigPage.MapListChange
     End Object
     lb_MapList=MultiSelectListBox'xVoting.MapVoteMapListConfigPage.MapListListBox'

     sbCaption="Map Cycle List"
     WindowName="Map Voting List Configuration"
     DefaultLeft=0.200000
     DefaultTop=0.100000
     DefaultWidth=0.600000
     DefaultHeight=0.800000
     WinTop=0.100000
     WinLeft=0.200000
     WinWidth=0.600000
     WinHeight=0.800000
     bAcceptsInput=False
}
