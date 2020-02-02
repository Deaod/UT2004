// ====================================================================
//  Class:  xVoting.MapVoteGameConfigPage
//
//	this page allows modification of the xVotingHandler GameConfig
//  configuration variables.
//
//  Written by Bruce Bickar
//  (c) 2003, Epic Games, Inc.  All Rights Reserved
// ====================================================================
class MapVoteGameConfigPage extends GUICustomPropertyPage DependsOn(VotingHandler);

var automated GUISectionBackground sb_List, sb_List2;
var automated GUIListBox lb_GameConfigList;
var automated moComboBox co_GameClass;
var automated moEditBox  ed_GameTitle;
var automated moEditBox  ed_Acronym;
var automated moEditBox  ed_Prefix;
var automated MultiSelectListBox lb_Mutator;
var automated moEditBox  ed_Parameter;
var automated GUIButton  b_New;
var automated GUIButton  b_Delete;
var automated moCheckBox ch_Default;

var array<CacheManager.GameRecord> GameTypes;
var array<CacheManager.MutatorRecord> Mutators;

var() editconst noexport CacheManager.GameRecord    CurrentGame;

// autosave
var() int SaveIndex, ListIndex;
var bool bChanged;

// localization
var localized string lmsgNew;
var localized string lmsgAdd;

//------------------------------------------------------------------------------------------------
function InitComponent(GUIController MyController, GUIComponent MyOwner)
{
	local int i;

	Super.Initcomponent(MyController, MyOwner);

	// load existing configuration
	for(i=0; i<class'xVoting.xVotingHandler'.default.GameConfig.Length; i++)
		lb_GameConfigList.List.Add( class'xVoting.xVotingHandler'.default.GameConfig[i].GameName, none, string(i));

	if (lb_GameConfigList.List.ItemCount==0)
		DisableComponent(b_Delete);

	// load game types
	class'CacheManager'.static.GetGameTypeList(GameTypes);
	for(i=0; i<GameTypes.Length; i++)
		co_GameClass.AddItem( GameTypes[i].GameName, none, GameTypes[i].ClassName);

	class'CacheManager'.static.GetMutatorList(Mutators);
	LoadMutators();

	sb_Main.SetPosition(0.483359,0.064678,0.451250,0.716991);
	lb_GameConfigList.List.AddLinkObject(co_GameClass);
	lb_GameConfigList.List.AddLinkObject(ed_GameTitle);
	lb_GameConfigList.List.AddLinkObject(ed_Acronym);
	lb_GameConfigList.List.AddLinkObject(ed_Prefix);
	lb_GameConfigList.List.AddLinkObject(ed_Parameter);
	lb_GameConfigList.List.AddLinkObject(lb_Mutator);
	lb_GameConfigList.List.AddLinkObject(ch_Default);
	lb_GameConfigList.List.AddLinkObject(b_Delete);

	lb_GameConfigList.OnChange=GameConfigList_Changed;
	bChanged = False;

	sb_Main.TopPadding=0.0.5;
	sb_Main.BottomPadding=0.4;
	sb_Main.Caption="Options";

	sb_List.ManageComponent(lb_GameConfigList);
	sb_List.LeftPadding=0.005;
	sb_List.RightPadding=0.005;

	sb_Main.ManageComponent(ch_Default);
	sb_Main.ManageComponent(co_GameClass);
	sb_Main.ManageComponent(ed_GameTitle);
	sb_Main.ManageComponent(ed_Acronym);
	sb_Main.ManageComponent(ed_Prefix);
    sb_Main.ManageComponent(ed_Parameter);

	sb_List2.ManageComponent(lb_Mutator);

	if (lb_GameConfigList.List.ItemCount==0)
		DisableComponent(b_Delete);
	else
		lb_GameConfigList.List.SetIndex(0);


}

function bool InternalOnClick(GUIComponent Sender)
{
	if ( Sender == b_OK )
	{
		SaveChange();
		Controller.CloseMenu(false);
		return true;
	}

	if ( Sender == b_Cancel )
	{
		Controller.CloseMenu(true);
		return true;
	}

	return false;
}


//------------------------------------------------------------------------------------------------
function InternalOnOpen()
{
	lb_GameConfigList.List.SetIndex(0);
}
//------------------------------------------------------------------------------------------------
function LoadMutators()
{
	local int i;

	lb_Mutator.List.Clear();
	for(i=0; i<Mutators.Length; i++)
		lb_Mutator.List.Add( Mutators[i].FriendlyName, none, Mutators[i].ClassName);
}
//------------------------------------------------------------------------------------------------
function GameConfigList_Changed(GUIComponent Sender)
{
	local int i;
	local array<string> MutatorArray;

	if (lb_GameConfigList.List.ItemCount==0 || lb_GameConfigList.List.Index == ListIndex)
		return;

   	SaveChange();

	SaveIndex = int(lb_GameConfigList.List.GetExtra());
	ListIndex = lb_GameConfigList.List.Index;

	LoadMutators();

	co_GameClass.Find(class'xVoting.xVotingHandler'.default.GameConfig[SaveIndex].GameClass, true, True);
	ed_GameTitle.SetComponentValue(class'xVoting.xVotingHandler'.default.GameConfig[SaveIndex].GameName, True);
	ed_Acronym.SetComponentValue(class'xVoting.xVotingHandler'.default.GameConfig[SaveIndex].Acronym, True);
	ed_Prefix.SetComponentValue(class'xVoting.xVotingHandler'.default.GameConfig[SaveIndex].Prefix, True);
	ed_Parameter.SetComponentValue(class'xVoting.xVotingHandler'.default.GameConfig[SaveIndex].Options, True);
	ch_Default.SetComponentValue(string(class'xVoting.xVotingHandler'.default.DefaultGameConfig == SaveIndex), True);

	Split(class'xVoting.xVotingHandler'.default.GameConfig[SaveIndex].Mutators, ",", MutatorArray);
	for(i=0; i<MutatorArray.Length; i++)
		lb_Mutator.List.Find(MutatorArray[i],False,True); // bExtra

	bChanged = False;

}

function int GameIndex()
{
	local string GameClass;
	local int i;

	GameClass = co_GameClass.GetExtra();
	for(i=0; i<GameTypes.Length; i++)
		if(GameTypes[i].ClassName == GameClass)
			return i;

	return -1;
}

//------------------------------------------------------------------------------------------------
function FieldChange(GUIComponent Sender)
{
	local int i,j;

	bChanged=True;

	if(Sender == co_GameClass)
	{
		i = GameIndex();

		for (j=0;j<GameTypes.Length;j++)
			if ( GameTypes[j].GameName == ed_GameTitle.GetText() )
			{
				ed_GameTitle.SetComponentValue(GameTypes[i].GameName, True);
				lb_GameConfigList.List.SetItemAtIndex(ListIndex,GameTypes[i].GameName);
			}

		ed_Acronym.SetComponentValue(GameTypes[i].GameAcronym, True);
		ed_Prefix.SetComponentValue(GameTypes[i].MapPrefix, True);

	}
	else if (Sender == ed_GameTitle)
	{
		if (ListIndex!=-1)
			lb_GameConfigList.List.SetItemAtIndex(ListIndex,ed_GameTitle.GetText());
	}
}
//------------------------------------------------------------------------------------------------
function bool SaveChange()
{
	local int i;

	if (!bChanged)
		return true;

	if( SaveIndex == -1 ) // Adding new record
	{
		i = class'xVoting.xVotingHandler'.default.GameConfig.Length;
		class'xVoting.xVotingHandler'.default.GameConfig.Length = i + 1;
		class'xVoting.xVotingHandler'.default.GameConfig[i].GameClass = co_GameClass.GetExtra();
		class'xVoting.xVotingHandler'.default.GameConfig[i].GameName = ed_GameTitle.GetComponentValue();
		class'xVoting.xVotingHandler'.default.GameConfig[i].Acronym = ed_Acronym.GetComponentValue();
		class'xVoting.xVotingHandler'.default.GameConfig[i].Prefix = ed_Prefix.GetComponentValue();
		class'xVoting.xVotingHandler'.default.GameConfig[i].Options = ed_Parameter.GetComponentValue();
		class'xVoting.xVotingHandler'.default.GameConfig[i].Mutators = lb_Mutator.List.GetExtra();
		if( bool(ch_Default.GetComponentValue()) )
			class'xVoting.xVotingHandler'.default.DefaultGameConfig = i;
		class'xVoting.xVotingHandler'.static.StaticSaveConfig();
		SaveIndex = i;
		lb_GameconfigList.List.SetExtraAtIndex(ListIndex,""$SaveIndex);
	}
	else  // modification of existing record
	{
		i = SaveIndex;
		class'xVoting.xVotingHandler'.default.GameConfig[i].GameClass = co_GameClass.GetExtra();
		class'xVoting.xVotingHandler'.default.GameConfig[i].GameName = ed_GameTitle.GetComponentValue();
		class'xVoting.xVotingHandler'.default.GameConfig[i].Acronym = ed_Acronym.GetComponentValue();
		class'xVoting.xVotingHandler'.default.GameConfig[i].Prefix = ed_Prefix.GetComponentValue();
		class'xVoting.xVotingHandler'.default.GameConfig[i].Options = ed_Parameter.GetComponentValue();
		class'xVoting.xVotingHandler'.default.GameConfig[i].Mutators = lb_Mutator.List.GetExtra();
		if( bool(ch_Default.GetComponentValue()) )
			class'xVoting.xVotingHandler'.default.DefaultGameConfig = i;
		class'xVoting.xVotingHandler'.static.StaticSaveConfig();
	}
	bChanged=False;
	return true;
}

//------------------------------------------------------------------------------------------------
function bool NewButtonClick(GUIComponent Sender)
{
	local int i;

	SaveChange();

	i = GameIndex();

	lb_GameConfigList.List.bNotify = false;
	lb_GameConfigList.List.Insert(0,"** New **",,"-1",true);
	lb_GameConfigList.List.bNotify = true;
	ed_GameTitle.SetComponentValue("** New **", True);
	ed_Acronym.SetComponentValue(GameTypes[i].GameAcronym, True);
	ed_Prefix.SetComponentValue(GameTypes[i].MapPrefix, True);
	ed_Parameter.SetComponentValue("", True);
	ch_Default.SetComponentValue("False", True);
	LoadMutators();

	ListIndex = 0;
	SaveIndex = -1;

	bChanged = true;

	EnableComponent(co_GameClass);
	EnableComponent(ed_GameTitle);
	EnableComponent(ed_Acronym);
	EnableComponent(ed_Prefix);
	EnableComponent(ed_Parameter);
	EnableComponent(lb_Mutator);
	EnableComponent(ch_Default);
	EnableComponent(b_Delete);
	return true;
}

//------------------------------------------------------------------------------------------------
function bool DeleteButtonClick(GUIComponent Sender)
{
	local int i,x;

	if (SaveIndex>=0)
	{
		class'xVoting.xVotingHandler'.default.GameConfig.Remove(SaveIndex,1);
		class'xVoting.xVotingHandler'.static.StaticSaveConfig();
	}

	if (ListIndex>=0)
	{

	    for (i=0;i<lb_GameConfigList.List.ItemCount;i++)
	    {
	    	x = int (lb_GameConfigList.List.GetExtraAtIndex(i));
			if ( x > SaveIndex )
				lb_GameconfigList.List.SetExtraAtIndex(i,""$(x-1));
	    }

		lb_GameConfigList.List.Remove(ListIndex,1);
	}

	SaveIndex = -1;
	ListIndex = -1;

	if (lb_GameConfigList.List.ItemCount==0)
	{
	 	DisableComponent(b_Delete);
	 	co_GameClass.SetIndex(-1);
		ed_GameTitle.SetComponentValue("", True);
		ed_Acronym.SetComponentValue("", True);
		ed_Prefix.SetComponentValue("", True);
		ed_Parameter.SetComponentValue("", True);
		ch_Default.SetComponentValue("False", True);

		DisableComponent(co_GameClass);
		DisableComponent(ed_GameTitle);
		DisableComponent(ed_Acronym);
		DisableComponent(ed_Prefix);
		DisableComponent(ed_Parameter);
		DisableComponent(lb_Mutator);
		DisableComponent(ch_Default);
		bChanged=false;
	}
	else
		lb_GameConfigList.List.SetIndex(0);

	return true;
}

defaultproperties
{
     Begin Object Class=AltSectionBackground Name=SBList
         bFillClient=True
         Caption="GameTypes"
         WinTop=0.044272
         WinLeft=0.042969
         WinWidth=0.377929
         WinHeight=0.753907
         OnPreDraw=SBList.InternalPreDraw
     End Object
     sb_List=AltSectionBackground'xVoting.MapVoteGameConfigPage.SBList'

     Begin Object Class=AltSectionBackground Name=SBList2
         HeaderBase=Texture'2K4Menus.NewControls.Display2'
         Caption="Mutators"
         LeftPadding=0.000000
         RightPadding=0.000000
         TopPadding=0.100000
         BottomPadding=0.100000
         WinTop=0.540159
         WinLeft=0.483359
         WinWidth=0.451250
         WinHeight=0.295899
         RenderWeight=0.490000
         OnPreDraw=SBList2.InternalPreDraw
     End Object
     sb_List2=AltSectionBackground'xVoting.MapVoteGameConfigPage.SBList2'

     Begin Object Class=GUIListBox Name=GameConfigListBox
         bVisibleWhenEmpty=True
         OnCreateComponent=GameConfigListBox.InternalOnCreateComponent
         Hint="Select a game configuration to edit or delete."
         WinTop=0.160775
         WinLeft=0.626758
         WinWidth=0.344087
         WinHeight=0.727759
         TabOrder=0
     End Object
     lb_GameConfigList=GUIListBox'xVoting.MapVoteGameConfigPage.GameConfigListBox'

     Begin Object Class=moComboBox Name=GameClassComboBox
         CaptionWidth=0.400000
         ComponentWidth=0.600000
         Caption="Game Class"
         OnCreateComponent=GameClassComboBox.InternalOnCreateComponent
         Hint="Select a game type for the select game configuration."
         WinTop=0.136135
         WinLeft=0.028955
         WinWidth=0.592970
         WinHeight=0.076855
         TabOrder=4
         OnChange=MapVoteGameConfigPage.FieldChange
     End Object
     co_GameClass=moComboBox'xVoting.MapVoteGameConfigPage.GameClassComboBox'

     Begin Object Class=moEditBox Name=GameTitleEditBox
         CaptionWidth=0.400000
         ComponentWidth=0.600000
         Caption="Game Title"
         OnCreateComponent=GameTitleEditBox.InternalOnCreateComponent
         Hint="Enter a custom game configuration title."
         WinTop=0.223844
         WinLeft=0.028955
         WinWidth=0.592970
         WinHeight=0.074249
         TabOrder=3
         OnChange=MapVoteGameConfigPage.FieldChange
     End Object
     ed_GameTitle=moEditBox'xVoting.MapVoteGameConfigPage.GameTitleEditBox'

     Begin Object Class=moEditBox Name=AcronymEditBox
         CaptionWidth=0.400000
         ComponentWidth=0.600000
         Caption="Abbreviation"
         OnCreateComponent=AcronymEditBox.InternalOnCreateComponent
         Hint="A short abbreviation, description, or acronym that identifies the game configuration. This will be appended to the map name in vote messages."
         WinTop=0.306343
         WinLeft=0.028955
         WinWidth=0.592970
         WinHeight=0.076855
         TabOrder=5
         OnChange=MapVoteGameConfigPage.FieldChange
     End Object
     ed_Acronym=moEditBox'xVoting.MapVoteGameConfigPage.AcronymEditBox'

     Begin Object Class=moEditBox Name=PrefixEditBox
         CaptionWidth=0.400000
         ComponentWidth=0.600000
         Caption="Map Prefixes"
         OnCreateComponent=PrefixEditBox.InternalOnCreateComponent
         Hint="List of map name prefixes. Separate each with commas."
         WinTop=0.393185
         WinLeft=0.028955
         WinWidth=0.592970
         WinHeight=0.074249
         TabOrder=6
         OnChange=MapVoteGameConfigPage.FieldChange
     End Object
     ed_Prefix=moEditBox'xVoting.MapVoteGameConfigPage.PrefixEditBox'

     Begin Object Class=MultiSelectListBox Name=MutatorListBox
         bVisibleWhenEmpty=True
         OnCreateComponent=MutatorListBox.InternalOnCreateComponent
         Hint="Select each mutator that should be loaded with this game configuration."
         WinTop=0.484369
         WinLeft=0.224267
         WinWidth=0.396485
         WinHeight=0.315234
         TabOrder=9
         OnChange=MapVoteGameConfigPage.FieldChange
     End Object
     lb_Mutator=MultiSelectListBox'xVoting.MapVoteGameConfigPage.MutatorListBox'

     Begin Object Class=moEditBox Name=ParameterEditBox
         CaptionWidth=0.400000
         ComponentWidth=0.600000
         Caption="Parameters"
         OnCreateComponent=ParameterEditBox.InternalOnCreateComponent
         Hint="(Advanced) List of game parameters with values. Separated each with a comma. (ex. GoalScore=4,MinPlayers=4)"
         WinTop=0.826949
         WinLeft=0.077783
         WinWidth=0.490431
         TabOrder=7
         OnChange=MapVoteGameConfigPage.FieldChange
     End Object
     ed_Parameter=moEditBox'xVoting.MapVoteGameConfigPage.ParameterEditBox'

     Begin Object Class=GUIButton Name=NewButton
         Caption="New"
         Hint="Create a new game configuration."
         WinTop=0.913925
         WinLeft=0.060047
         WinWidth=0.158281
         TabOrder=1
         OnClick=MapVoteGameConfigPage.NewButtonClick
         OnKeyEvent=NewButton.InternalOnKeyEvent
     End Object
     b_New=GUIButton'xVoting.MapVoteGameConfigPage.NewButton'

     Begin Object Class=GUIButton Name=DeleteButton
         Caption="Delete"
         Hint="Delete the selected game configuration."
         WinTop=0.913925
         WinLeft=0.268403
         WinWidth=0.159531
         TabOrder=2
         OnClick=MapVoteGameConfigPage.DeleteButtonClick
         OnKeyEvent=DeleteButton.InternalOnKeyEvent
     End Object
     b_Delete=GUIButton'xVoting.MapVoteGameConfigPage.DeleteButton'

     Begin Object Class=moCheckBox Name=DefaultCheckBox
         ComponentWidth=0.200000
         Caption="Default"
         OnCreateComponent=DefaultCheckBox.InternalOnCreateComponent
         Hint="The selected game configuration will be the default if all the players leave the server"
         WinTop=0.826949
         WinLeft=0.659814
         WinWidth=0.194922
         TabOrder=8
         OnChange=MapVoteGameConfigPage.FieldChange
     End Object
     ch_Default=moCheckBox'xVoting.MapVoteGameConfigPage.DefaultCheckBox'

     SaveIndex=-1
     ListIndex=-1
     lmsgNew="New"
     lmsgAdd="Add"
     WindowName="Map Voting Game Configuration"
     DefaultLeft=0.041015
     DefaultTop=0.031510
     DefaultWidth=0.917187
     DefaultHeight=0.885075
     OnOpen=MapVoteGameConfigPage.InternalOnOpen
     WinTop=0.031510
     WinLeft=0.041015
     WinWidth=0.917187
     WinHeight=0.885075
     bAcceptsInput=False
}
