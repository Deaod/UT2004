//==============================================================================
//  Created on: 11/23/2003
//  Base class for menus that allow configuration of keybinds
//
//  Written by Ron Prestenback
//  © 2003, Epic Games, Inc. All Rights Reserved
//==============================================================================

class KeyBindMenu extends LockedFloatingWindow;

struct InputKeyInfo
{
	var int KeyNumber;
	var string KeyName;
	var string LocalizedKeyName;
};

struct KeyBinding
{
    var             bool            bIsSectionLabel;
    var             string          KeyLabel;
    var             string          Alias;
    var             array<int>  	BoundKeys;
};

var() noexport editconst InputKeyInfo AllKeys[255];

var() array<KeyBinding> Bindings;
var() bool bPendingRawInput;                  // Waiting for input - changing a keybind

var() editconst noexport int  NewIndex, NewSubIndex;
var() editconst noexport GUIStyles SelStyle, SectionStyle;
var() string SectionStyleName;

var automated GUIMultiColumnListBox lb_Binds;
var automated GUIMultiColumnList    li_Binds;
var automated GUIImage				i_Bk;
var automated GUILabel              l_Hint;

var() localized string Headings[3];
var() float SectionLabelMargin;

var() localized string PageCaption;
var() localized string SpeechLabel;
var() localized string CloseCaption, ResetCaption, ClearCaption, ActionText;

function InitComponent(GUIController MyController, GUIComponent MyOwner)
{
	Super.InitComponent(MyController, MyOwner);

	t_WindowTitle.SetCaption(PageCaption);
	li_Binds = lb_Binds.List;
	SectionStyle = Controller.GetStyle(SectionStyleName, li_Binds.FontScale);
	InitializeBindingsArray();
	Initialize();

	b_OK.Caption = CloseCaption;
	b_Cancel.Caption = ResetCaption;
}

function InitializeBindingsArray()
{
	local int i;

	for ( i = 0; i < ArrayCount(AllKeys); i++ )
	{
		AllKeys[i].KeyNumber = i;
		Controller.KeyNameFromIndex( byte(i), AllKeys[i].KeyName, AllKeys[i].LocalizedKeyName );
	}
}

function Initialize()
{
	LoadCommands();
	MapBindings();
}

// Add all possible commands to the guilist
function LoadCommands()
{
	ClearBindings();
}

// query each key's assigned command/alias, and add the key number to the appropriate place
function MapBindings()
{
    local int i, BindingIndex;
    local string Alias;

    for ( i = 1; i < ArrayCount(AllKeys); i++ )
    {
    	// Find out if this key is currently bound to any commands
    	if ( Controller.GetCurrentBind( AllKeys[i].KeyName, Alias ) )
        {
        	// If this key is bound to a command, find out if the command is a known alias
        	BindingIndex = FindAliasIndex( Alias );
        	if ( BindingIndex != -1 )
            	BindKeyToAlias( BindingIndex, i );
        }
    }
}

function CreateAliasMapping(string Command, string FriendlyName, bool bSectionLabel)
{
    local int At;

    At = Bindings.Length;
    Bindings.Length = Bindings.Length + 1;

    Bindings[At].bIsSectionLabel = bSectionLabel;
    Bindings[At].KeyLabel = FriendlyName;
    Bindings[At].Alias = Command;

    li_Binds.AddedItem();
}

function BindKeyToAlias( int BindIndex, int KeyIndex )
{
	local int i;

	if ( !ValidBindIndex(BindIndex) )
		return;

	if ( !ValidKeyIndex(KeyIndex) )
		return;

	for ( i = 0; i < Bindings[BindIndex].BoundKeys.Length; i++ )
	{
		if ( Bindings[BindIndex].BoundKeys[i] == KeyIndex )
			return;

		if ( class'GameInfo'.static.GetBindWeight(Bindings[BindIndex].BoundKeys[i]) < class'GameInfo'.static.GetBindWeight(KeyIndex) )
			break;
	}

	Bindings[BindIndex].BoundKeys.Insert( i, 1 );
	Bindings[BindIndex].BoundKeys[i] = KeyIndex;
}

function ClearBindings()
{
	Bindings.Remove(0,Bindings.Length);
	li_Binds.Clear();
}

function SetKeyBind(int Index, int SubIndex, byte NewKey)
{
	if ( !ValidBindIndex(Index) )
		return;

    if ( SubIndex < Bindings[Index].BoundKeys.Length && Bindings[Index].BoundKeys[SubIndex] == NewKey )
        return;

    RemoveAllOccurance(NewKey);
   	RemoveExistingKey(Index, SubIndex);

    if ( Controller.SetKeyBind(AllKeys[NewKey].KeyName, Bindings[Index].Alias) )
	    BindKeyToAlias(Index,NewKey);

//	Controller.SetKeyBind( AllKeys[NewKey].KeyName, Bindings[Index].Alias );
    li_Binds.UpdatedItem(Index);
}

function bool BeginRawInput(GUIComponent Sender)
{
    local int Index, SubIndex;

    if ( MouseOnCol1() )
        SubIndex = 0;
    else if ( MouseOnCol2() )
        SubIndex = 1;
    else
        return true;

	Index = li_Binds.CurrentListId();
	if ( ValidBindIndex(Index) && Bindings[Index].bIsSectionLabel )
		return true;

    bPendingRawInput = true;
    UpdateHint(Index);

	NewIndex = Index;
    NewSubIndex = SubIndex;

    Controller.OnNeedRawKeyPress = RawKey;
    Controller.Master.bRequireRawJoystick = true;

    PlayerOwner().ClientPlaySound(Controller.EditSound);
    PlayerOwner().ConsoleCommand("toggleime 0");

    return true;
}

function bool RawKey(byte NewKey)
{
   	SetKeyBind( NewIndex, NewSubIndex, NewKey );

    NewSubIndex = -1;
	UpdateHint(NewIndex);
    NewIndex = -1;

    bPendingRawInput = false;
    Controller.OnNeedRawKeyPress = none;
    Controller.Master.bRequireRawJoystick = false;

    PlayerOwner().ClientPlaySound(Controller.ClickSound);
    return true;

}

function string GetCurrentKeyBind(int BindIndex, int SubIndex)
{
	if ( !ValidBindIndex(BindIndex) )
		return "";

    if (Bindings[BindIndex].bIsSectionLabel)
        return "";

    if (BindIndex == NewIndex && SubIndex == NewSubIndex)
        return "???";

    if (SubIndex >= Bindings[BindIndex].BoundKeys.Length)
        return "";

    return AllKeys[Bindings[BindIndex].BoundKeys[SubIndex]].LocalizedKeyName;
}

function string ListGetSortString( int Index )
{
	switch ( li_Binds.SortColumn )
	{
	case 0: return Bindings[Index].KeyLabel;
	case 1: return GetCurrentKeyBind(Index,0);
	case 2: return GetCurrentKeyBind(Index,1);
	}

	return "";
}

function bool ListOnKeyEvent(out byte Key, out byte State, float delta)
{
    local Interactions.EInputKey iKey;

	if ( State != 3 )
		return li_Binds.InternalOnKeyEvent(Key,State,Delta);

	iKey = EInputKey(Key);
	if ( iKey == IK_Backspace )    // Backspace
    {
        // Clear Over
        if ( MouseOnCol1() )
            RemoveExistingKey(li_Binds.CurrentListId(),0);

        else if ( MouseOnCol2() )
            RemoveExistingKey(li_Binds.CurrentListId(),1);

        return true;
    }

    if ( iKey == IK_Enter )
    {
        BeginRawInput(None);
        return true;
    }

	return li_Binds.InternalOnKeyEvent(Key,State,Delta);
}

function ListTrack(GUIComponent Sender, int LastIndex)
{
	local int Index, OldIndex;

	if ( LastIndex >= 0 && LastIndex < li_Binds.ItemCount )
	{
		OldIndex = li_Binds.SortData[LastIndex].SortItem;
		Index = li_Binds.CurrentListId();

		if ( ValidBindIndex(Index) && Bindings[Index].bIsSectionLabel )
			SearchDown(OldIndex);

		if ( !bPendingRawInput )
			UpdateHint(Index);
	}
}

function SearchUp(int OldIndex)
{
    local int cindex;

    cindex = li_Binds.CurrentListId();
    while ( cindex > 0 && cindex < Bindings.length)
    {
        if ( !Bindings[cindex].bIsSectionLabel )
        {
            li_Binds.SetIndex(cIndex);
            return;
        }
        cindex--;
    }
    li_Binds.SetIndex(OldIndex);
}

function SearchDown(int OldIndex)
{
    local int cindex;

    cindex = li_Binds.CurrentListId();
    while ( cindex > 0 && cindex < Bindings.Length )
    {
        if (!Bindings[cindex].bIsSectionLabel)
        {
            li_Binds.SetIndex(cIndex);
            return;
        }
        cindex++;
    }
    li_Binds.SetIndex(OldIndex);
}



function RemoveExistingKey(int Index, int SubIndex)
{
	local int KeyIndex;

	if ( !ValidBindIndex(Index) )
		return;

    if ( SubIndex >= Bindings[Index].BoundKeys.Length || Bindings[Index].BoundKeys[SubIndex] < 0 )
        return;

	KeyIndex = Bindings[Index].BoundKeys[SubIndex];
    Bindings[Index].BoundKeys.Remove(SubIndex, 1);

	Controller.SetKeyBind( AllKeys[KeyIndex].KeyName, "" );
}

function RemoveAllOccurance(byte NewKey)
{
    local int i,j;

	for ( i = 0; i < Bindings.Length; i++ )
	{
		for ( j = 0; j < Bindings[i].BoundKeys.Length; j++ )
		{
			if ( Bindings[i].BoundKeys[j] == NewKey )
			{
				RemoveExistingKey(i,j);
				break;
			}
		}
	}
}


function UpdateHint(int BindIndex)
{
	local int i;
	local string Str, CurrentBindName;

    if ( !ValidBindIndex(BindIndex) || Bindings[BindIndex].bIsSectionLabel )
    {
    	l_Hint.Caption = "";
        return;
    }

	if ( Bindings[BindIndex].BoundKeys.Length > 0 )
	{
		if ( bPendingRawInput )
		{
		DrawCurrentBind:
			for ( i = 0; i < Bindings[BindIndex].BoundKeys.Length; i++ )
			{
				if ( Str != "" )
					Str $= ",";
				Str $= GetCurrentKeyBind(BindIndex, i);
			}

			if ( Str == "" )
				l_Hint.Caption = "";
			else l_Hint.Caption = Repl(ActionText, "%keybinds%", Str);
			return;
		}
		else
		{
			if ( MouseOnCol2() ) i = 1;
			CurrentBindName = GetCurrentKeyBind(BindIndex,i);
			if ( CurrentBindName == "" )
				goto DrawCurrentBind;

			Str = Repl(Repl(ClearCaption,"%backspace%",AllKeys[8].LocalizedKeyName),
			           "%keybind%",CurrentBindName);
			l_Hint.Caption = Repl( Str, "%keyname%", Bindings[BindIndex].KeyLabel );;
		}

	}
	else l_Hint.Caption = "";
}

function bool MouseOnCol1()
{
	local float CellLeft, CellWidth;

	li_Binds.GetCellLeftWidth(1, CellLeft, CellWidth);
	return Controller.MouseX >= CellLeft && Controller.MouseX <= CellLeft + CellWidth;
}

function bool MouseOnCol2()
{
	local float CellLeft, CellWidth;

	li_Binds.GetCellLeftWidth(2, CellLeft, CellWidth);
	return Controller.MouseX >= CellLeft && Controller.MouseX <= CellLeft + CellWidth;
}

function bool ValidBindIndex(int Index)
{
	return Index >= 0 && Index < Bindings.Length;
}

function bool ValidKeyIndex(int Index)
{
	return Index >= 0 && Index < ArrayCount(AllKeys);
}

function int FindAliasIndex( string Alias )
{
	local int i;

	for ( i = 0; i < Bindings.Length; i++ )
		if ( Bindings[i].Alias ~= Alias )
			return i;

	return -1;
}

function InternalOnCreateComponent( GUIComponent NewComp, GUIComponent Sender )
{
	local GUIMultiColumnList L;
	local int i;

	if ( GUIMultiColumnListBox(Sender) != None )
	{
		L = GUIMultiColumnList(NewComp);
		if ( L != None )
		{
			for ( i = 0; i < ArrayCount(Headings); i++ )
				L.ColumnHeadings[i] = Headings[i];

			L.OnKeyEvent = ListOnKeyEvent;
			L.OnDrawItem = DrawBinding;
			L.GetSortString = ListGetSortString;
			L.ExpandLastColumn = True;
			L.SortColumn = -1;
			L.bHotTrack = True;
			L.OnClick = BeginRawInput;
			L.OnTrack = ListTrack;
		}

		GUIMultiColumnListBox(Sender).InternalOnCreateComponent(NewComp,Sender);
	}

	Super.InternalOnCreateComponent(NewComp,Sender);
}

function DrawBinding(Canvas Canvas, int Item, float X, float Y, float W, float H, bool bSelected, bool bPending)
{
    local float CellLeft, CellWidth;
    local GUIStyles DStyle;

	// hack to fix selected item appearing offset
	// real fix would be to create a "NoBackground" style that has the same border offsets as STY2ListSelection
	local int i;
    local int SavedOffset[4];

   	Canvas.Style = 1;
    Item = li_Binds.SortData[Item].SortItem;

	if ( !ValidBindIndex(Item) )
		return;

    if ( Bindings[Item].bIsSectionLabel )
    {
    	li_Binds.GetCellLeftWidth( 0, CellLeft, CellWidth );
    	Canvas.SetPos( CellLeft + 3, Y );
    	Canvas.DrawColor = SectionStyle.ImgColors[li_Binds.MenuState];

    	Canvas.DrawTile(Controller.DefaultPens[0], W - 6, H, 0, 0, 32, 32);
    	SectionStyle.DrawText(Canvas, li_Binds.MenuState, CellLeft + SectionLabelMargin, Y, CellWidth, H, TXTA_Left, Bindings[Item].KeyLabel, li_Binds.FontScale);
        return;
    }

    if ( bPendingRawInput )
    	bSelected = Item - li_Binds.Top == NewIndex;

    if ( bSelected )
    	DStyle = li_Binds.SelectedStyle;
    else DStyle = li_Binds.Style;

	for ( i = 0; i < 4; i++ )
	{
		SavedOffset[i] = DStyle.BorderOffsets[i];
		DStyle.BorderOffsets[i] = class'STY2ListSelection'.default.BorderOffsets[i];
	}

	if ( bSelected && !bPendingRawInput )
		DStyle.Draw( Canvas, li_Binds.MenuState, X + DStyle.BorderOffsets[0], Y, W - DStyle.BorderOffsets[2], H );

	li_Binds.GetCellLeftWidth(0, CellLeft, CellWidth);
	DStyle.DrawText( Canvas, li_Binds.MenuState, CellLeft, Y, CellWidth - DStyle.BorderOffsets[2], H, TXTA_Center, Bindings[Item].KeyLabel, li_Binds.FontScale);

	li_Binds.GetCellLeftWidth(1, CellLeft, CellWidth);
	if ( bPendingRawInput && bSelected && NewSubIndex == 0 )
		DStyle.Draw( Canvas, li_Binds.MenuState, CellLeft, Y, CellWidth - DStyle.BorderOffsets[2], H );
	DStyle.DrawText(Canvas, li_Binds.MenuState, CellLeft, Y, CellWidth - DStyle.BorderOffsets[2], H, TXTA_Center, GetCurrentKeyBind(Item, 0), li_Binds.FontScale);

	li_Binds.GetCellLeftWidth(2, CellLeft, CellWidth);
	if ( bPendingRawInput && bSelected && NewSubIndex == 1 )
		DStyle.Draw(Canvas, li_Binds.MenuState, CellLeft, Y, CellWidth - DStyle.BorderOffsets[2], H);
	DStyle.DrawText(Canvas, li_Binds.MenuState, CellLeft, Y, CellWidth - DStyle.BorderOffsets[2], H, TXTA_Center, GetCurrentKeyBind(Item, 1), li_Binds.FontScale);

	for ( i = 0; i < 4; i++ )
		DStyle.BorderOffsets[i] = SavedOffset[i];
}

function bool InternalOnClick(GUIComponent Sender)
{
	if ( Sender == b_OK )
	{
		Controller.CloseMenu(false);
		return true;
	}

	else if ( Sender == b_Cancel )
	{
		Controller.ResetKeyboard();
		Initialize();
	}
}

function OnFadeIn()
{
	Initialize();
}

defaultproperties
{
     SectionStyleName="ListSection"
     Begin Object Class=GUIMultiColumnListBox Name=BindListBox
         HeaderColumnPerc(0)=0.500000
         HeaderColumnPerc(1)=0.250000
         HeaderColumnPerc(2)=0.250000
         OnCreateComponent=KeyBindMenu.InternalOnCreateComponent
         WinTop=0.085586
         WinLeft=0.043604
         WinWidth=0.911572
         WinHeight=0.705742
         TabOrder=0
         bBoundToParent=True
         bScaleToParent=True
     End Object
     lb_Binds=GUIMultiColumnListBox'GUI2K4.KeyBindMenu.BindListBox'

     Begin Object Class=GUIImage Name=BindBk
         Image=Texture'2K4Menus.NewControls.Display99'
         ImageStyle=ISTY_Stretched
         WinTop=0.057552
         WinLeft=0.031397
         WinWidth=0.937207
         WinHeight=0.808281
         bBoundToParent=True
         bScaleToParent=True
     End Object
     i_bk=GUIImage'GUI2K4.KeyBindMenu.BindBk'

     Begin Object Class=GUILabel Name=HintLabel
         TextAlign=TXTA_Center
         bMultiLine=True
         VertAlign=TXTA_Center
         FontScale=FNS_Small
         StyleName="textLabel"
         WinTop=0.872222
         WinLeft=0.032813
         WinWidth=0.520313
         WinHeight=0.085000
         bBoundToParent=True
         bScaleToParent=True
     End Object
     l_Hint=GUILabel'GUI2K4.KeyBindMenu.HintLabel'

     Headings(1)="Key 1"
     Headings(2)="Key 2"
     SectionLabelMargin=10.000000
     CloseCaption="CLOSE"
     ResetCaption="RESET"
     ClearCaption="Press '%backspace%' to unbind %keybind% from %keyname%."
     ActionText="{%keybinds%} - currently bound to this key."
     sb_Main=None

     DefaultLeft=0.100000
     DefaultTop=0.050000
     DefaultWidth=0.800000
     DefaultHeight=0.900000
     FadedIn=KeyBindMenu.OnFadeIn
     WinTop=0.050000
     WinLeft=0.100000
     WinWidth=0.800000
     WinHeight=0.900000
}
