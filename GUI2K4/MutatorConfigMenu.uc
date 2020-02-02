//==============================================================================
//	This page displays all configurable properties for mutators.
//	Alot of functionality copied from IAMultiColumnRulesPanel
//
//	Written by Ron Prestenback
//	© 2003, Epic Games, Inc.  All Rights Reserved
//==============================================================================
class MutatorConfigMenu extends LockedFloatingWindow;

var PlayInfo MutInfo;
var array<string> ActiveMuts;

var localized string CustomConfigText, ConfigButtonText, EditButtonText, NoPropsMessage;

var automated	GUIMultiOptionListBox		lb_Config;
var				GUIMultiOptionList			li_Config;
var automated moCheckBox ch_Advanced;

var bool bIsMultiplayer; //are we setting up mutators for a multiplayer game?

function InitComponent(GUIController MyController, GUIComponent MyComponent)
{
	Super.InitComponent(MyController, MyComponent);

	sb_Main.LeftPadding = 0.01;
	sb_Main.RightPadding = 0.01;
	sb_Main.ManageComponent(lb_Config);

	MutInfo = new(None) class'PlayInfo';

	li_Config = lb_Config.List;
	li_Config.OnCreateComponent=ListOnCreateComponent;
	li_Config.bHotTrack = True;

	ch_Advanced.Checked(MyController.bExpertMode);
}

function Initialized()
{
	if ( bInit )
		return;

	// if we didn't add any items to the list, display the no configurable properties message in the header
	if (li_Config.Elements.Length == 0)
	{
		sb_Main.Caption = NoPropsMessage;
		RemoveComponent(lb_Config);
	}
}

function Initialize()
{
	local array<class<Mutator> > MutClasses;
	local int i, j;
	local bool bTemp, bFoundMutatorSettings;
	local GUIMenuOption NewComp;

	li_Config.Clear();

	bTemp = Controller.bCurMenuInitialized;
	Controller.bCurMenuInitialized = False;

	MutClasses = class'xUtil'.static.GetMutatorClasses(ActiveMuts);
	MutInfo.Init( MutClasses );

	for (i = 0; i < MutClasses.Length; i++)
	{
		// If this class has a mutator config menu, just show the custom config button
		if (MutClasses[i].default.ConfigMenuClassName != "")
		{
			AddMutatorHeader(MutClasses[i].default.FriendlyName, i == 0);

			NewComp = li_Config.AddItem( "XInterface.moButton", , CustomConfigText );
			if (NewComp == None) break;

			NewComp.bAutoSizeCaption = True;
			NewComp.ComponentWidth = 0.25;
			NewComp.OnChange = OpenCustomConfigMenu;
			moButton(NewComp).MyButton.Caption = ConfigButtonText;
			moButton(NewComp).Value = MutClasses[i].default.ConfigMenuClassName;
		}

		// Otherwise, add all of this mutator's playinfo setting to the list.
		// If the mutator doesn't have any, add the no settings message
		else
		{
			if ( !MutatorHasProps(MutClasses[i]) )
				continue;

			AddMutatorHeader(MutClasses[i].default.FriendlyName, i == 0);
			bFoundMutatorSettings = false;
			for (j = 0; j < MutInfo.Settings.Length; j++)
			{
				if (MutInfo.Settings[j].ClassFrom == MutClasses[i] || (bFoundMutatorSettings && class<Mutator>(MutInfo.Settings[j].ClassFrom) == None))
				{
					bFoundMutatorSettings = true;
					if ((Controller.bExpertMode || !MutInfo.Settings[j].bAdvanced) && (bIsMultiplayer || !MutInfo.Settings[j].bMPOnly))
					{
						NewComp = AddRule(MutInfo.Settings[j]);
						if (NewComp != None)
						{
							NewComp.Tag = j;
							NewComp.LabelJustification = TXTA_Left;
							NewComp.ComponentJustification = TXTA_Right;
							NewComp.bAutoSizeCaption = True;
							NewComp.SetComponentValue(MutInfo.Settings[j].Value);
	//						NewComp.OnChange = InternalOnChange;
						}
						else
							Warn("Error adding new component to multi-options list:"$MutInfo.Settings[j].SettingName);
					}
				}
				else
					bFoundMutatorSettings = false;
			}

			// No settings found for this mutator
			if (GUIListSpacer(li_Config.Elements[li_Config.Elements.Length - 1]) != None)
				li_Config.AddItem("XInterface.GUIListSpacer",,NoPropsMessage);
		}
	}

	bInit = false;
	Initialized();
	Controller.bCurMenuInitialized = bTemp;
}

function AddMutatorHeader(string MutatorName, bool InitialRow)
{
	local int ModResult, i;

	//	If the GUIMultiOptionList has more than one column, add a spacer component
	//	for each column until we are back to the first column
	ModResult = li_Config.Elements.Length % lb_Config.NumColumns;
	while (ModResult-- > 0)
		li_Config.AddItem( "XInterface.GUIListSpacer" );

	if (!InitialRow)
		for (i = 0; i < lb_Config.NumColumns; i++)
			li_Config.AddItem( "XInterface.GUIListSpacer" );
	i = 0;

	// We are now at the first column - safe to add a header row
	li_Config.AddItem( "XInterface.GUIListHeader",, MutatorName );
	while (++i < lb_Config.NumColumns)
		li_Config.AddItem( "XInterface.GUIListHeader" );
}

function GUIMenuOption AddRule(PlayInfo.PlayInfoData NewRule)
{
	local bool bTemp;
	local string		Width, Op;
	local array<string>	Range;
	local GUIMenuOption NewComp;
	local int			i, pos;

	bTemp = Controller.bCurMenuInitialized;
	Controller.bCurMenuInitialized = False;

	switch (NewRule.RenderType)
	{
		case PIT_Check:
			NewComp = li_Config.AddItem("XInterface.moCheckbox",,NewRule.DisplayName);
			if (NewComp == None)
				break;

			NewComp.bAutoSizeCaption = True;
			break;

		case PIT_Select:
			NewComp = li_Config.AddItem("XInterface.moComboBox",,NewRule.DisplayName);
			if (NewComp == None)
				break;

			moCombobox(NewComp).ReadOnly(True);
			NewComp.bAutoSizeCaption = True;

			Split(NewRule.Data, ";", Range);
			for (i = 0; i+1 < Range.Length; i += 2)
				moComboBox(NewComp).AddItem(Range[i+1],,Range[i]);

			break;

		case PIT_Text:
			if ( !Divide(NewRule.Data, ";", Width, Op) )
				Width = NewRule.Data;

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
					NewComp = li_Config.AddItem("XInterface.moFloatEdit",,NewRule.DisplayName);
					if (NewComp == None) break;

					NewComp.bAutoSizeCaption = True;
					NewComp.ComponentWidth = 0.25;
					if (i != -1)
						moFloatEdit(NewComp).Setup( float(Range[0]), float(Range[1]), moFloatEdit(NewComp).MyNumericEdit.Step );
				}

				else
				{
					NewComp = li_Config.AddItem("XInterface.moNumericEdit",,NewRule.DisplayName);
					if (NewComp == None) break;

					moNumericEdit(NewComp).bAutoSizeCaption = True;
					NewComp.ComponentWidth = 0.25;
					if (i != -1)
						moNumericEdit(NewComp).Setup( int(Range[0]), int(Range[1]), moNumericEdit(NewComp).MyNumericEdit.Step);
				}
			}
			else if (NewRule.ArrayDim != -1)
			{
				NewComp = li_Config.AddItem("XInterface.moButton",,NewRule.DisplayName);
				if (NewComp == None) break;

				NewComp.bAutoSizeCaption = True;
				NewComp.ComponentWidth = 0.25;
				NewComp.OnChange = ArrayPropClicked;
			}

			else
			{
				NewComp = li_Config.AddItem("XInterface.moEditBox",,NewRule.DisplayName);
				if (NewComp == None) break;

				NewComp.bAutoSizeCaption = True;
				if (i != -1)
					moEditbox(NewComp).MyEditBox.MaxWidth = i;
			}
			break;
	}

	NewComp.SetHint(NewRule.Description);
	Controller.bCurMenuInitialized = bTemp;
	return NewComp;
}

function ArrayPropClicked(GUIComponent Sender)
{
	local int i;
	local GUIArrayPropPage ArrayPage;
	local string ArrayMenu;

	i = Sender.Tag;
	if (i < 0)
		return;

	if (MutInfo.Settings[i].ArrayDim > 1)
		ArrayMenu = Controller.ArrayPropertyMenu;
	else
		ArrayMenu = Controller.DynArrayPropertyMenu;

	if (Controller.OpenMenu(ArrayMenu, MutInfo.Settings[i].DisplayName, MutInfo.Settings[i].Value))
	{
		ArrayPage = GUIArrayPropPage(Controller.ActivePage);
		ArrayPage.Item = MutInfo.Settings[i];
		ArrayPage.OnClose = ArrayPageClosed;
		ArrayPage.SetOwner(Sender);
	}
}

function ArrayPageClosed(optional bool bCancelled)
{
	local GUIArrayPropPage ArrayPage;
	local GUIComponent CompOwner;

	if (!bCancelled)
	{
		ArrayPage = GUIArrayPropPage(Controller.ActivePage);
		if (ArrayPage != None)
		{
			CompOwner = ArrayPage.GetOwner();
			if (moButton(CompOwner) != None)
			{
				moButton(CompOwner).SetComponentValue(ArrayPage.GetDataString(), true);
				InternalOnChange(CompOwner);
			}
		}
	}
}

function InternalOnChange(GUIComponent Sender)
{
	local int i;
	local GUIMenuOption mo;

	if (Sender == ch_Advanced)
	{
		Controller.bExpertMode = ch_Advanced.IsChecked();
		Controller.SaveConfig();
		Initialize();
	}
	else if (GUIMultiOptionList(Sender) != None)
	{
		mo = GUIMultiOptionList(Sender).Get();
		i = mo.Tag;
		if (i >= 0 && i < MutInfo.Settings.Length)
			MutInfo.StoreSetting(i, mo.GetComponentValue());
	}
	else if ( GUIMenuOption(Sender) != None )
	{
		i = Sender.Tag;
		if ( i >= 0 && i < MutInfo.Settings.Length )
			MutInfo.StoreSetting(i, GUIMenuOption(Sender).GetComponentValue());
	}
}

function OpenCustomConfigMenu(GUIComponent Sender)
{
	if (moButton(Sender) != None)
		Controller.OpenMenu(moButton(Sender).Value);
}

function ListOnCreateComponent(GUIMenuOption NewComp, GUIMultiOptionList Sender)
{
	if (moButton(NewComp) != None)
	{
		moButton(NewComp).ButtonStyleName = "SquareButton";
		moButton(NewComp).ButtonCaption = EditButtonText;
	}

	NewComp.LabelJustification = TXTA_Left;
	NewComp.ComponentJustification = TXTA_Right;
}

function InternalOnCreateComponent(GUIComponent NewComp, GUIComponent Sender)
{
	if (GUIMultiOptionList(NewComp) != None)
	{
		GUIMultiOptionList(NewComp).bDrawSelectionBorder = False;
		GUIMultiOptionList(NewComp).ItemPadding = 0.15;

		if (Sender == lb_Config)
			lb_Config.InternalOnCreateComponent(NewComp, Sender);
	}

	Super.InternalOnCreateComponent(NewComp,Sender);
}

function bool MutatorHasProps( class<Mutator> MutatorClass )
{
	local int i;

	if ( MutInfo == None )
		return false;

	for ( i = 0; i < MutInfo.Settings.Length; i++ )
		if ( MutInfo.Settings[i].ClassFrom == MutatorClass )
			return true;

	return false;
}

function AlignButtons()
{
	Super.AlignButtons();

	ch_Advanced.WinTop = b_OK.WinTop + 0.006511;
}

event Closed(GUIComponent Sender, bool bCancelled)
{
	Super.Closed(Sender,bCancelled);

	if ( !bCancelled )
		MutInfo.SaveSettings();
}

defaultproperties
{
     ConfigButtonText="Open"
     EditButtonText="Edit"
     NoPropsMessage="No Configurable Properties"
     Begin Object Class=GUIMultiOptionListBox Name=ConfigList
         bVisibleWhenEmpty=True
         OnCreateComponent=MutatorConfigMenu.InternalOnCreateComponent
         WinTop=0.143333
         WinLeft=0.037500
         WinWidth=0.918753
         WinHeight=0.697502
         RenderWeight=0.900000
         TabOrder=1
         bBoundToParent=True
         bScaleToParent=True
         OnChange=MutatorConfigMenu.InternalOnChange
     End Object
     lb_Config=GUIMultiOptionListBox'GUI2K4.MutatorConfigMenu.ConfigList'

     Begin Object Class=moCheckBox Name=AdvancedButton
         Caption="View Advanced Options"
         OnCreateComponent=AdvancedButton.InternalOnCreateComponent
         Hint="Toggles whether advanced properties are displayed"
         WinTop=0.911982
         WinLeft=0.037500
         WinWidth=0.310000
         WinHeight=0.040000
         RenderWeight=1.000000
         TabOrder=1
         bBoundToParent=True
         OnChange=MutatorConfigMenu.InternalOnChange
     End Object
     ch_Advanced=moCheckBox'GUI2K4.MutatorConfigMenu.AdvancedButton'

     SubCaption="Mutator Configuration"
     WindowName="Custom Configuration Page"
}
