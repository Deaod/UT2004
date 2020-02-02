//====================================================================
//  xVoting.MatchSetupPage
//  MatchSetup page.
//
//  Written by Bruce Bickar
//  (c) 2003, Epic Games, Inc.  All Rights Reserved
// ====================================================================
class MatchSetupPage extends VotingPage;
/*
var automated GUITreeListBox lb_TreeListBox;
var automated GUIButton b_SaveButton;
var automated GUIButton b_SubmitButton;
var automated GUIButton b_SaveAsDefault;
var automated GUIButton b_RestoreDefault;
var automated GUILabel l_OptionLabel;
var automated GUILabel l_Title;
var automated GUILabel l_AvailableMaps;

// Generic controls (initially hidden)
var automated GUIListBox lb_ListBoxA;
var automated GUIListBox lb_ListBoxB;
var automated MultiSelectListBox lb_MSListBox;
var automated moCheckbox ch_CheckBox;
var automated moComboBox co_ComboBox;
var automated moFloatEdit fl_FloatEdit;
var automated moNumericEdit nu_NumericEdit;
var automated moEditBox ed_EditBox;

var array<CacheManager.GameRecord> GameTypes;
//var array<CacheManager.MapRecord> Maps;
var array<string> Maps;
//var array<CacheManager.MutatorRecord> Mutators;
var array<VotingReplicationInfo.MutatorData> Mutators;

var int SelectedGameTypeIdx;
var string SelectedMapName;
var string SelectedMutators;
var string Parameters;
var bool bTournamentMode;
var string DemoRecFileName;

var PlayInfo PInfo;
var string SelectedOption;
var bool bCurrentSettingChanged;
var bool bInitialized;

// Localization
var localized string	GameTypesCaption, MapNameCaption, MutatorsCaption,
						lmsgMustBeAdmin, lmsgMatchSetupDisabled, ParametersCaption,
						TournamentModeCaption, DemoRecCaption, MiscCaption, lmsgNotPermitted, lmsgMutator;
//------------------------------------------------------------------------------------------------
function InternalOnOpen()
{
	if( MVRI == none || (MVRI != none && !MVRI.bMatchSetup) )
	{
		Controller.OpenMenu("GUI2K4.GUI2K4QuestionPage");
		GUIQuestionPage(Controller.TopPage()).SetupQuestion(lmsgMatchSetupDisabled, QBTN_Ok, QBTN_Ok);
		GUIQuestionPage(Controller.TopPage()).OnButtonClick = OnOkButtonClick;
		return;
	}

	if(MVRI != none && !MVRI.bMatchSetupPermitted)
	{
		if( PlayerOwner().PlayerReplicationInfo.bAdmin )
			MVRI.MatchSetupLogin("Admin", "");  // UserId and Password not checked for admins
		else
			Controller.OpenMenu("xVoting.MatchSetupLoginPage");
	}

	class'CacheManager'.static.GetGameTypeList(GameTypes);
	//class'CacheManager'.static.GetMutatorList(Mutators);
	setTimer(1,true); // wait for login validation
	PInfo = new(None) class'Engine.PlayInfo';
}
//------------------------------------------------------------------------------------------------
function OnOkButtonClick(byte bButton) // triggered by th GUIQuestionPage Ok Button
{
	Controller.CloseAll(true);
}
//------------------------------------------------------------------------------------------------
function Timer()
{
	if( !bInitialized && MVRI != None && MVRI.bMatchSetupPermitted )
	{
		bInitialized = true;
		MVRI.RequestMatchSettings(True);
	}

	if( !MVRI.bMatchSetupAccepted && !b_SubmitButton.bVisible)
		b_SubmitButton.Show();

	if( MVRI.bMatchSetupAccepted && b_SubmitButton.bVisible)
		b_SubmitButton.Hide();
}
//------------------------------------------------------------------------------------------------
function AddGameType(string GameClassString)
{
	local int i;

	//log("____AddGameType", 'MapVoteDebug');
	lb_TreeListBox.List.OnChange = None;
	lb_TreeListBox.List.Clear();  // reload required when game type changed
	PInfo.Clear();

	for(i = 0; i < GameTypes.Length; i++)
	{
		if(GameTypes[i].ClassName ~= GameClassString)
		{
			SelectedGameTypeIdx = i;
			break;
		}
	}
	lb_TreeListBox.List.OnChange = OptionSelected;
	bCurrentSettingChanged=false;
	SelectedOption = "";
	lb_TreeListBox.List.AddItem(GameTypesCaption, "GameType", "");
}
//------------------------------------------------------------------------------------------------
function AddMapName(string MapName)
{
	//log("____AddMapName", 'MapVoteDebug');
	lb_TreeListBox.List.OnChange = None;
	lb_TreeListBox.List.AddItem(MapNameCaption, "MapName", "");
	SelectedMapName = MapName;
	lb_TreeListBox.List.OnChange = OptionSelected;
}
//------------------------------------------------------------------------------------------------
function AddMutators(string MutatorsString)
{
	//log("____AddMutators", 'MapVoteDebug');
	lb_TreeListBox.List.OnChange = None;
	lb_TreeListBox.List.AddItem(MutatorsCaption, "Mutators", "");
	SelectedMutators = MutatorsString;
	lb_TreeListBox.List.OnChange = OptionSelected;
}
//------------------------------------------------------------------------------------------------
function AddParameters(string Value)
{
	//log("____AddParameters", 'MapVoteDebug');
	lb_TreeListBox.List.OnChange = None;
	//lb_TreeListBox.List.AddItem(ParametersCaption, "", "");
	lb_TreeListBox.List.AddItem(MiscCaption, "GameOptions", ParametersCaption);
	lb_TreeListBox.List.OnChange = OptionSelected;
	Parameters = Value;
}
//------------------------------------------------------------------------------------------------
function AddTournamentMode(string Value)
{
	//log("____AddTournamentMode", 'MapVoteDebug');
	lb_TreeListBox.List.OnChange = None;
	lb_TreeListBox.List.AddItem(TournamentModeCaption, "Tournament", ParametersCaption);
	lb_TreeListBox.List.OnChange = OptionSelected;
	bTournamentMode = bool(Value);
}
//------------------------------------------------------------------------------------------------
function AddDemoRecFileName(string Value)
{
	//log("____AddDemoRecFileName", 'MapVoteDebug');
	lb_TreeListBox.List.OnChange = None;
	lb_TreeListBox.List.AddItem(DemoRecCaption, "DemoRec", ParametersCaption);
	lb_TreeListBox.List.OnChange = OptionSelected;
	DemoRecFileName = Value;
}
//------------------------------------------------------------------------------------------------
function AddSetting(string SettingName, string ClassFrom, string Value)
{
	local int i;
	local class<Info> InfoClass;

	Log("___AddSetting " $ SettingName $ ", " $ ClassFrom $ ", " $ Value, 'MapVoteDebug');

	i = PInfo.FindIndex(SettingName);
	if( i == -1 )  // setting not found, need to load it
	{
		InfoClass = class<Info>(DynamicLoadObject(ClassFrom,class'Class'));
		if (InfoClass != None)
		{
			PInfo.AddClass(InfoClass);
			InfoClass.static.FillPlayInfo(PInfo);
			i = PInfo.FindIndex(SettingName);
			if( i == -1 )
			{
				log("Failed to find PlayInfo Setting " $ SettingName);
				return;
			}
		}
		else
		{
			Log("Failed to load " $ ClassFrom);
			return;
		}
	}
	PInfo.StoreSetting( i, Value);
	lb_TreeListBox.List.OnChange = None;

	if( class<Mutator>(InfoClass) != none)
		lb_TreeListBox.List.AddItem(PInfo.Settings[i].DisplayName, PInfo.Settings[i].SettingName, lmsgMutator);
	else
		lb_TreeListBox.List.AddItem(PInfo.Settings[i].DisplayName, PInfo.Settings[i].SettingName, PInfo.Settings[i].Grouping);
	lb_TreeListBox.List.OnChange = OptionSelected;
}
//------------------------------------------------------------------------------------------------
function UpdateSetting(string SettingName, string NewSetting)
{
	local int i,x;

	//log("____UpdateSetting", 'MapVoteDebug');

	switch( SettingName )
	{
		case "MapName":
			SelectedMapName = NewSetting;
			break;
		case "Mutators":
			SelectedMutators = NewSetting;
			break;
		case "GameOptions":
			Parameters = NewSetting;
			break;
		case "Tournament":
			bTournamentMode = bool(NewSetting);
			break;
		case "DemoRec":
			DemoRecFileName = NewSetting;
			break;
		default:
			x = PInfo.FindIndex(SettingName);
			if( x > -1)
				PInfo.StoreSetting(x, NewSetting);
	}
	i = lb_TreeListBox.List.FindIndexByValue(SettingName);
	if( i > -1)
		lb_TreeListBox.List.SetIndex(i);
}
//------------------------------------------------------------------------------------------------
function OptionSelected(GUIComponent Sender)
{
	local int i,x,Idx,pos;
	local array<string> Range;
    local string Width, Op;
	local array<string> MutatorArray;
	local array<string> MapArray;
	local bool bFound;

	if( SelectedOption != lb_TreeListBox.List.GetValue() && bCurrentSettingChanged )
		SaveOption(SelectedOption); // save the previously changed setting
	SelectedOption = lb_TreeListBox.List.GetValue();

	// Hide all generic controls
	lb_ListBoxA.Hide();
	lb_ListBoxB.Hide();
	lb_MSListBox.Hide();
	ch_CheckBox.Hide();
	co_ComboBox.Hide();
	fl_FloatEdit.Hide();
	nu_NumericEdit.Hide();
	ed_EditBox.Hide();
	l_AvailableMaps.Hide();

	// disable change notification
	lb_ListBoxA.OnChange=None;
	lb_ListBoxB.OnChange=None;
	lb_MSListBox.OnChange=None;
	ch_CheckBox.OnChange=None;
	co_ComboBox.OnChange=None;
	fl_FloatEdit.OnChange=None;
	nu_NumericEdit.OnChange=None;
	ed_EditBox.OnChange=None;
	bCurrentSettingChanged=False;
	b_SaveButton.Hide();

	l_OptionLabel.Caption=lb_TreeListBox.List.GetCaption();
	switch( SelectedOption )
	{
		case "GameType":
			lb_ListBoxA.SetHint("");
			lb_ListBoxA.List.Clear();
			for (i = 0; i < GameTypes.Length; i++)
				lb_ListBoxA.List.Add(GameTypes[i].GameName,none,GameTypes[i].ClassName);
			lb_ListBoxA.List.SetIndex(SelectedGameTypeIdx);
			lb_ListBoxA.Show();
			lb_ListBoxA.SetFocus(None);
			lb_ListBoxA.OnChange=SettingChanged;
			break;

		case "MapName":
			lb_ListBoxA.SetHint("");
			ReadMapList();
			lb_ListBoxA.List.Clear();
            Split(SelectedMapName, ",", MapArray);
			for(i=0; i<MapArray.Length; i++)
			{
				bFound = false;
				for(x=0; x<Maps.Length; x++)
				{
					if( Maps[x] ~= MapArray[i] )
					{
                		lb_ListBoxA.List.Add(Maps[x]);
						lb_ListBoxB.List.RemoveItem(Maps[x]);
						bFound = true;
						break;
					}
				}
				if( !bFound )
               		lb_ListBoxA.List.Add(MapArray[i]);
			}
			lb_ListBoxA.Show();
			lb_ListBoxB.Show();
			l_AvailableMaps.Show();
			lb_ListBoxA.OnChange=MapSelected;
			lb_ListBoxB.OnChange=MapSelected;
			break;

		case "Mutators":
			lb_MSListBox.SetHint("");
			lb_MSListBox.List.Clear();
			for (i = 0; i < Mutators.Length; i++)
				lb_MSListBox.List.Add(Mutators[i].FriendlyName,none,Mutators[i].ClassName);
			lb_MSListBox.List.Sort();
			lb_MSListBox.Show();
            Split(SelectedMutators, ",", MutatorArray);
			for(i=0; i<MutatorArray.Length; i++)
                lb_MSListBox.List.Find(MutatorArray[i],False,True); // bExtra

			lb_MSListBox.SetFocus(None);
			lb_MSListBox.OnChange=SettingChanged;
			break;

		case "Tournament":
			ch_CheckBox.SetHint("");
			ch_CheckBox.Show();
			ch_CheckBox.Caption = TournamentModeCaption;
			ch_CheckBox.SetComponentValue(String(bTournamentMode));
			ch_CheckBox.SetFocus(None);
			ch_CheckBox.OnChange=SettingChanged;
			break;

		case "DemoRec":
			ed_EditBox.SetHint("");
			ed_EditBox.Show();
			ed_EditBox.MyEditBox.MaxWidth = 30;
			ed_EditBox.SetComponentValue(DemoRecFileName);
			ed_EditBox.SetFocus(None);
			ed_EditBox.OnChange=SettingChanged;
			break;

		case "GameOptions":
			ed_EditBox.SetHint("");
			ed_EditBox.Show();
			ed_EditBox.MyEditBox.MaxWidth = 255;
			ed_EditBox.SetComponentValue(Parameters);
			ed_EditBox.SetFocus(None);
			ed_EditBox.OnChange=SettingChanged;
			break;

		Default:
			if( SelectedOption != "" )
			{
				Idx = PInfo.FindIndex(SelectedOption);
				if( PInfo.Settings[Idx].SecLevel <= MVRI.SecurityLevel )
				{
					switch(PInfo.Settings[Idx].RenderType)
					{
						case PIT_Check:
							ch_CheckBox.Show();
							ch_CheckBox.Caption = PInfo.Settings[Idx].DisplayName;
							ch_CheckBox.SetComponentValue(PInfo.Settings[Idx].Value);
							ch_CheckBox.SetFocus(None);
							ch_CheckBox.OnChange=SettingChanged;
							ch_CheckBox.SetHint(PInfo.Settings[Idx].Description);
							break;

						case PIT_Select:
							co_ComboBox.SetHint(PInfo.Settings[Idx].Description);
							co_ComboBox.MyComboBox.List.Clear();
							co_ComboBox.Show();
							co_ComboBox.ReadOnly(True);
							Split(PInfo.Settings[Idx].Data, ";", Range);
							for (i = 0; i+1 < Range.Length; i += 2)
								co_ComboBox.AddItem(Range[i+1],,Range[i]);
							co_ComboBox.SetComponentValue(PInfo.Settings[Idx].Value);
							co_ComboBox.SetFocus(None);
							co_ComboBox.OnChange=SettingChanged;
							break;

						case PIT_Text:
							Divide(PInfo.Settings[Idx].Data, ";", Width, Op);
							pos = InStr(Width, ",");
							if (pos != -1)
								Width = Left(Width, pos);

							if (Width != "")
								i = int(Width);
							else i = -1;
							Split(Op, ":", Range);
							if (Range.Length > 1)
							{
								// Ranged data
								if (InStr(Range[0], ".") != -1)
								{
									// float edit
									fl_FloatEdit.Show();
									if (i != -1)
										fl_FloatEdit.Setup( float(Range[0]), float(Range[1]), fl_FloatEdit.MyNumericEdit.Step);
									fl_FloatEdit.SetComponentValue(PInfo.Settings[Idx].Value);
									fl_FloatEdit.SetFocus(None);
									fl_FloatEdit.SetHint(PInfo.Settings[Idx].Description);
									fl_FloatEdit.OnChange=SettingChanged;
								}
								else
								{
									nu_NumericEdit.SetHint(PInfo.Settings[Idx].Description);
									nu_NumericEdit.Show();
									if (i != -1)
										nu_NumericEdit.Setup( int(Range[0]), int(Range[1]), nu_NumericEdit.MyNumericEdit.Step);
									nu_NumericEdit.SetComponentValue(PInfo.Settings[Idx].Value);
									nu_NumericEdit.SetFocus(None);
									nu_NumericEdit.OnChange=SettingChanged;
								}
							}
							else
							{
								ed_EditBox.SetHint(PInfo.Settings[Idx].Description);
								ed_EditBox.Show();
								if (i != -1)
									ed_EditBox.MyEditBox.MaxWidth = i;
								ed_EditBox.SetComponentValue(PInfo.Settings[Idx].Value);
								ed_EditBox.SetFocus(None);
								ed_EditBox.OnChange=SettingChanged;
							}
							break;
					}
				}
				else
					l_OptionLabel.Caption = lmsgNotPermitted;
			}
	}
}
//------------------------------------------------------------------------------------------------
function SettingChanged(GUIComponent Sender)
{
	bCurrentSettingChanged=true; // set to auto-save
	b_SaveButton.Show();
}
//------------------------------------------------------------------------------------------------
function MapSelected(GUIComponent Sender)
{
	local string MapName;

	lb_ListBoxA.OnChange=none;
	lb_ListBoxB.OnChange=none;

	if( Sender == lb_ListBoxA)
	{
		MapName = lb_ListBoxA.List.Get();
		lb_ListBoxB.List.Add(MapName);
		lb_ListBoxA.List.RemoveItem(MapName);
	}

	if( Sender == lb_ListBoxB)
	{
		MapName = lb_ListBoxB.List.Get();
		lb_ListBoxA.List.Add(MapName);
		lb_ListBoxB.List.RemoveItem(MapName);
	}

	bCurrentSettingChanged=true; // set to auto-save
	b_SaveButton.Show();

	lb_ListBoxA.OnChange=MapSelected;
	lb_ListBoxB.OnChange=MapSelected;
}
//------------------------------------------------------------------------------------------------
function bool SaveButtonClick(GUIComponent Sender)
{
	SaveOption(lb_TreeListBox.List.GetValue());
	b_SaveButton.Hide();
	return true;
}
//------------------------------------------------------------------------------------------------
function bool SaveAsDefaultButtonClick(GUIComponent Sender)
{
	if( bCurrentSettingChanged ) // make sure last change was saved
	{
		SaveOption(lb_TreeListBox.List.GetValue());
		b_SaveButton.Hide();
	}

	if( !PlayerOwner().PlayerReplicationInfo.bAdmin )
	{
		Controller.OpenMenu("GUI2K4.GUI2K4QuestionPage");
		GUI2K4QuestionPage(Controller.ActivePage).SetupQuestion(lmsgMustBeAdmin, QBTN_Ok, QBTN_Ok);
	}
	else
		MVRI.SaveAsDefault();
	return true;
}
//------------------------------------------------------------------------------------------------
function bool RestoreDefaultButtonClick(GUIComponent Sender)
{
	b_SaveButton.Hide();
	MVRI.RestoreDefaultProfile();
	return true;
}
//------------------------------------------------------------------------------------------------
function SaveOption(string SettingName)
{
	local int i,pos,Idx;
	local array<string> Range;
    local string Width, Op;

	switch( SettingName )
	{
		case "GameType":
			SelectedGameTypeIdx = lb_ListBoxA.List.Index;
			MVRI.SendMatchSettingChange(SettingName,GameTypes[SelectedGameTypeIdx].ClassName);
			break;

		case "MapName":
			SelectedMapName = "";
			for( i=0; i<lb_ListBoxA.ItemCount(); i++)
			{
				SelectedMapName $= lb_ListBoxA.List.GetItemAtIndex(i);
				if( i < lb_ListBoxA.ItemCount() - 1 )
					SelectedMapName $= ",";
			}
			MVRI.SendMatchSettingChange(SettingName,SelectedMapName);
			break;

		case "Mutators":
			SelectedMutators= lb_MSListBox.List.GetExtra();
			MVRI.SendMatchSettingChange(SettingName,SelectedMutators);
			break;

		case "GameOptions":
			Parameters = ed_EditBox.GetComponentValue();
			MVRI.SendMatchSettingChange(SettingName,Parameters);
			break;
		case "Tournament":
			bTournamentMode = bool(ch_CheckBox.GetComponentValue());
			MVRI.SendMatchSettingChange(SettingName,String(bTournamentMode));
			break;
		case "DemoRec":
			DemoRecFileName = ed_EditBox.GetComponentValue();
			MVRI.SendMatchSettingChange(SettingName,DemoRecFileName);
			break;

		default:
			Idx = PInfo.FindIndex(SettingName);
			switch(PInfo.Settings[Idx].RenderType)
			{
				case PIT_Check:
					PInfo.StoreSetting(Idx, ch_CheckBox.GetComponentValue());
					break;

				case PIT_Select:
					PInfo.StoreSetting(Idx, co_ComboBox.GetComponentValue());
					break;

				case PIT_Text:
					Divide(PInfo.Settings[Idx].Data, ";", Width, Op);
					pos = InStr(Width, ",");
					if (pos != -1)
						Width = Left(Width, pos);

					if (Width != "")
						i = int(Width);
					else i = -1;
					Split(Op, ":", Range);
					if (Range.Length > 1)
					{
						// Ranged data
						if (InStr(Range[0], ".") != -1)
						{
							// float edit
							PInfo.StoreSetting(Idx, fl_FloatEdit.GetComponentValue());
						}
						else
						{
							// numeric edit
							PInfo.StoreSetting(Idx, nu_NumericEdit.GetComponentValue());
						}
					}
					else
					{
						// text edit
						PInfo.StoreSetting(Idx, ed_EditBox.GetComponentValue());
					}
					break;
			} //switch(PInfo.Settings[Idx].RenderType)
			MVRI.SendMatchSettingChange(SettingName, PInfo.Settings[Idx].Value);
	} //switch
	bCurrentSettingChanged = false;
	return;
}
//------------------------------------------------------------------------------------------------
function bool SubmitButtonClick(GUIComponent Sender)
{
	if( MVRI != none )
		MVRI.MatchSettingsSubmit();
	return true;
}
//------------------------------------------------------------------------------------------------
function ReadMapList()
{
	local int i;
	local bool bTemp;

	bTemp = Controller.bCurMenuInitialized;
	Controller.bCurMenuInitialized = False;

	lb_ListBoxB.List.Clear();
	for (i = 0; i < Maps.Length; i++)
		lb_ListBoxB.List.Add(Maps[i]);

	lb_ListBoxB.List.Sort();
	Controller.bCurMenuInitialized = bTemp;
	lb_ListBoxB.List.SetIndex(0);
}
//------------------------------------------------------------------------------------------------
function AddServerMaps(string MapName, int Index)
{
	local int i;

	if( Index == 0 )
	{
		if( SelectedOption == "MapName" )
		{
			Maps.Remove(0,Maps.Length);
			lb_ListBoxB.List.Clear();
		}
	}
	Maps[Maps.Length] = MapName;

	if( SelectedOption == "MapName" )
	{
		i = lb_ListBoxA.List.FindIndex(MapName);
		if( i > -1 )
		{
			// replace uppercase mapnames from maplist
			lb_ListBoxA.OnChange=None;
			lb_ListBoxA.List.Remove(i);
			lb_ListBoxA.List.Add(MapName);
			lb_ListBoxA.List.Sort();
			lb_ListBoxA.OnChange=MapSelected;
		}
		else
		{
			lb_ListBoxB.OnChange=None;
			lb_ListBoxB.List.Add(MapName);
			lb_ListBoxB.List.Sort();
			lb_ListBoxB.OnChange=MapSelected;
		}
	}
}
//------------------------------------------------------------------------------------------------
function AddServerMutators(VotingReplicationInfo.MutatorData M, int Index)
{
	if( Index == 0 )
		Mutators.Remove(0, Mutators.Length);
	Mutators[Mutators.Length] = M;

	if( SelectedOption == "Mutators" )
	{
		lb_MSListBox.List.Add(M.FriendlyName,none,M.ClassName);
		lb_MSListBox.List.Sort();
        if( InStr("," $ Caps(SelectedMutators) $ ",", "," $ Caps(M.ClassName) $ ",") > -1 )
        	lb_MSListBox.List.Find(M.ClassName,False,True); // bExtra
	}
}
//------------------------------------------------------------------------------------------------
function Closed(GUIComponent Sender, bool bCancelled)
{
	if( MVRI != none )
		MVRI.MatchSetupLogout();
	Super.Closed(Sender, bCancelled);
}
//------------------------------------------------------------------------------------------------
defaultproperties
{
	Begin Object class=GUILabel Name=TitleLabel
		Caption="Match Setup"
		TextALign=TXTA_Center
		TextFont="UT2LargeFont"
		TextColor=(R=0,G=0,B=255,A=255)
		WinWidth=0.554921
		WinHeight=0.048632
		WinLeft=0.223438
		WinTop=0.107084
	End Object
	l_Title=TitleLabel

	Begin Object Class=GUITreeListBox Name=TreeControl
		WinWidth=0.393437
		WinHeight=0.487810
		WinLeft=0.108204
		WinTop=0.161405
		bVisibleWhenEmpty=true
		Hint="Select a configuration option to modify."
	End Object
	lb_TreeListBox = TreeControl

	Begin Object class=GUILabel Name=OptionLabel
		Caption=""
		TextALign=TXTA_Center
		TextFont="UT2SmallFont"
		TextColor=(R=0,G=0,B=255,A=255)
		WinWidth=0.386170
		WinHeight=0.032069
		WinLeft=0.505509
		WinTop=0.161823
	End Object
	l_OptionLabel=OptionLabel

	Begin Object Class=GUIListBox Name=ListBoxA
		WinWidth=0.315269
		WinHeight=0.213349
		WinLeft=0.537139
		WinTop=0.193488
		bVisibleWhenEmpty=true
		bVisible=false
		bSorted=false
	End Object
	lb_ListBoxA = ListBoxA

	Begin Object Class=GUIListBox Name=ListBoxB
		WinWidth=0.315269
		WinHeight=0.200848
		WinLeft=0.537139
		WinTop=0.443750
		bVisibleWhenEmpty=true
		bVisible=false
		bSorted=true
		Hint="Selecting a map name in this list will move it to the Map Cycle List."
	End Object
	lb_ListBoxB = ListBoxB

	Begin Object class=GUILabel Name=AvailableMapsLabel
		Caption="Available Maps"
		TextALign=TXTA_Center
		TextFont="UT2SmallFont"
		TextColor=(R=0,G=0,B=255,A=255)
		WinWidth=0.315234
		WinHeight=0.032382
		WinLeft=0.536759
		WinTop=0.412239
		bVisible=False
	End Object
	l_AvailableMaps=AvailableMapsLabel

	Begin Object Class=MultiSelectListBox Name=MSListBox
		WinWidth=0.342769
		WinHeight=0.329599
		WinLeft=0.525890
		WinTop=0.195155
		bVisibleWhenEmpty=true
		bVisible=false
	End Object
	lb_MSListBox = MSListBox

	Begin Object class=GUIButton Name=SaveAsDefaultButton
		Caption="Save As Default"
		Hint="Save this profile as the default profile."
		StyleName="SquareButton"
		OnClick=SaveAsDefaultButtonClick
		WinWidth=0.188855
		WinHeight=0.034616
		WinLeft=0.108749
		WinTop=0.655141
		bVisible=true
	End Object
	b_SaveAsDefault=SaveAsDefaultButton

	Begin Object class=GUIButton Name=RestoreDefaultButton
		Caption="Load Default"
		Hint="Restore the default profile."
		StyleName="SquareButton"
		OnClick=RestoreDefaultButtonClick
		WinWidth=0.169772
		WinHeight=0.034616
		WinLeft=0.332629
		WinTop=0.655141
	End Object
	b_RestoreDefault=RestoreDefaultButton

	Begin Object class=GUIButton Name=SubmitButton
		Caption="Finish/Accept"
		Hint="Accept current settings and implement changes."
		StyleName="SquareButton"
		OnClick=SubmitButtonClick
		WinWidth=0.176277
		WinHeight=0.034616
		WinLeft=0.712919
		WinTop=0.655141
		bVisible=false
	End Object
	b_SubmitButton=SubmitButton

	Begin Object class=GUIButton Name=SaveButton
		Caption="Save/Send"
		Hint="Click to save the changes to the selected option and send the new setting to the server."
		StyleName="SquareButton"
		OnClick=SaveButtonClick
		WinWidth=0.178750
		WinHeight=0.034565
		WinLeft=0.517007
		WinTop=0.655055
	End Object
	b_SaveButton=SaveButton

	Begin Object Class=moCheckbox Name=CheckBox
		WinWidth=0.037733
		WinHeight=0.048437
		WinLeft=0.671131
		WinTop=0.212656
		bVisible=false
		CaptionWidth=0
		ComponentWidth=1
		//Hint="This is a checkbox"
	End Object
	ch_CheckBox = CheckBox

	Begin Object Class=moComboBox Name=ComboBox
		WinWidth=0.313359
		WinHeight=0.038750
		WinLeft=0.539885
		WinTop=0.196822
		bAutoSizeCaption=True
		bVisible=false
		CaptionWidth=0
		ComponentWidth=1
	End Object
	co_ComboBox = ComboBox

	Begin Object Class=moFloatEdit Name=FloatEdit
		WinWidth=0.120545
		WinHeight=0.043750
		WinLeft=0.636444
		WinTop=0.200155
		bVisible=false
		CaptionWidth=0
		ComponentWidth=1
	End Object
	fl_FloatEdit = FloatEdit

	Begin Object Class=moNumericEdit Name=NumericEdit
		WinWidth=0.120545
		WinHeight=0.043750
		WinLeft=0.636444
		WinTop=0.200155
		bVisible=false
		CaptionWidth=0
		ComponentWidth=1
	End Object
	nu_NumericEdit = NumericEdit

	Begin Object Class=moEditBox Name=EditBox
		WinWidth=0.358984
		WinHeight=0.037500
		WinLeft=0.518946
		WinTop=0.198488
		bVisible=false
		CaptionWidth=0
		ComponentWidth=1
	End Object
	ed_EditBox = EditBox

    OnOpen=InternalOnOpen;

	GameTypesCaption="Game Type"
	MapNameCaption="Map Cycle List"
	MutatorsCaption="Mutators"
	ParametersCaption="Parameters"
	TournamentModeCaption="Tournament Mode"
	DemoRecCaption="Record Demo(FileName)"
	MiscCaption="Miscellaneous"
	lmsgMustBeAdmin="You must be logged in as an Admin to perform this."
	lmsgMatchSetupDisabled="Match Setup has been disabled by the server administrator."
	lmsgNotPermitted="Not Permitted"
	lmsgMutator="Mutator"
}
*/

defaultproperties
{
}
