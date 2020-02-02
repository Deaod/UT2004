//==============================================================================
//  Created on: 01/03/2004
//  Configure mutators in match setup
//
//  Written by Ron Prestenback
//  © 2003, Epic Games, Inc. All Rights Reserved
//==============================================================================

class MatchSetupMutator extends MatchSetupPanelBase;

var automated GUISectionBackground sb_Avail, sb_Active;
var automated GUIListBox         lb_Avail, lb_Active;
var() editconst noexport GUIList li_Active, li_Avail;
var automated GUIButton			 b_Add, b_AddAll, b_Remove, b_RemoveAll;

struct MutatorInfo
{
	var string ClassName, FriendlyName;
	var int Index;
};

var() array<MutatorInfo> TrackedMutators;

function InitPanel()
{
	Super.InitPanel();
	Group = class'VotingReplicationInfo'.default.MutatorID;
}

function bool HandleResponse(string Type, string Info, string Data)
{
	local int i;
	local array<string> Indexes;

	if ( Type ~= Group )
	{
		log("MUTATORS HandleResponse Info '"$Info$"'  Data '"$Data$"'",'MapVoteDebug');
		if ( Info ~= class'VotingReplicationInfo'.default.AddID )
		{
			ReceiveNewMutator(Data);
			return true;
		}

		if ( Info ~= class'VotingReplicationInfo'.default.UpdateID && Data != "" )
		{
			Split(Data, ",", Indexes);
			for ( i = 0; i < Indexes.Length; i++ )
				AddMutatorByIndex(int(Indexes[i]));
		}

		return true;
	}

	return false;
}
//MutatorID, AddID, Index $ "," $ M.ClassName $ Chr(27) $ M.FriendlyName
function ReceiveNewMutator( string Data )
{
	local int Index, pos;
	local string ClassName, FriendlyName;

	pos = InStr(Data, ",");
	if ( pos != -1 )
	{
		Index = int(Left(Data,pos));
		Data = Mid(Data, pos+1);
	}
	else
	{
		log("HandleResponse received weird mutator:"@Data);
		assert(false);
	}

	if ( !Divide(Data, Chr(27), ClassName, FriendlyName) )
	{
		log("HandleResponse received invalid mutator string:"$Data);
		assert(false);
	}

	TrackMutatorInfo(Index, ClassName, FriendlyName);
	li_Avail.Add(FriendlyName,,ClassName);
}

function TrackMutatorInfo( int Index, string ClassName, string FriendlyName )
{
	local int i;

	i = FindTrackingIndex(ClassName);
	if ( i == -1 )
	{
		i = TrackedMutators.Length;
		TrackedMutators.Length = TrackedMutators.Length + 1;
	}

	TrackedMutators[i].Index = Index;
	TrackedMutators[i].ClassName = ClassName;
	TrackedMutators[i].FriendlyName = FriendlyName;
}

function int FindTrackingIndex( string ClassName )
{
	local int i;

	for ( i = 0; i < TrackedMutators.Length; i++ )
	{
		if ( TrackedMutators[i].ClassName ~= ClassName )
			return i;
	}

	return -1;
}

function LoggedOut()
{
	Super.LoggedOut();

	li_Avail.Clear();
	li_Active.Clear();
}

function InitComponent(GUIController InController, GUIComponent InOwner)
{
	Super.InitComponent(InController, InOwner);

	li_Avail = lb_Avail.List;
	li_Active = lb_Active.List;

	if (li_Avail != None)
	{
		li_Avail.bDropSource = True;
		li_Avail.bDropTarget = True;
		li_Avail.OnDblClick = ModifyMutatorList;
		li_Avail.AddLinkObject( b_Add, True );
		li_Avail.CheckLinkedObjects = InternalCheckLinkedObj;
		li_Avail.bInitializeList = False;
	}

	if (li_Active != None)
	{
		li_Active.bDropSource = True;
		li_Active.bDropTarget = True;
		li_Active.OnDblClick = ModifyMutatorList;
		li_Active.AddLinkObject( b_Remove, True );
		li_Active.CheckLinkedObjects = InternalCheckLinkedObj;
		li_Active.bInitializeList = False;
	}

	sb_Avail.ManageComponent(lb_Avail);
	sb_Active.ManageComponent(lb_Active);

}

// Mapname has value only when initializing list
function bool AddMutator()
{
	local int i;
	local array<GUIListElem> PendingElements;

	if ( !li_Avail.IsValid() )
		return false;

	li_Avail.bNotify = False;
	PendingElements = li_Avail.GetPendingElements(True);
	for ( i = 0; i < PendingElements.Length; i++ )
	{
		li_Avail.RemoveElement(PendingElements[i],,True);
		li_Active.AddElement(PendingElements[i]);
	}

	li_Avail.bNotify = True;
	li_Avail.ClearPendingElements();
	li_Avail.SetIndex(li_Avail.Index);

	return true;
}

function bool RemoveMutator()
{
	local int i;
	local array<GUIListElem> PendingElements;

	if ( !li_Active.IsValid() )
		return false;

	li_Active.bNotify = False;
	PendingElements = li_Active.GetPendingElements( True );
	for ( i = 0; i < PendingElements.Length; i++ )
	{
		li_Active.RemoveElement( PendingElements[i],,True );
		li_Avail.AddElement( PendingElements[i] );
	}

	li_Active.bNotify = True;
	li_Active.ClearPendingElements();
	li_Active.SetIndex(li_Active.Index);

	return true;
}

function AddMutatorByIndex( int Index )
{
	local int i;

	for ( i = 0; i < TrackedMutators.Length; i++ )
	{
		if ( TrackedMutators[i].Index == Index )
		{
			li_Avail.RemoveExtra(TrackedMutators[i].ClassName);
			if ( li_Active.FindIndex(TrackedMutators[i].ClassName,,True) == -1 )
				li_Active.Add(TrackedMutators[i].FriendlyName,,TrackedMutators[i].ClassName);

			li_Avail.ClearPendingElements();
			return;
		}
	}
}

function RemoveMapByIndex( int Index )
{
	local int i;

	for ( i = 0; i < TrackedMutators.Length; i++ )
	{
		if ( TrackedMutators[i].Index == Index )
		{
			li_Active.RemoveExtra(TrackedMutators[i].ClassName);

			if ( li_Avail.FindIndex(TrackedMutators[i].ClassName,,True) == -1 )
				li_Avail.Add(TrackedMutators[i].FriendlyName,,TrackedMutators[i].ClassName);

			li_Active.ClearPendingElements();
			return;
		}
	}
}

// Called when one of the buttons between the maplists are clicked on
singular function bool ModifyMutatorList(GUIComponent Sender)
{
	if ( Sender == lb_Avail )
	{
		AddMutator();
		return true;
	}

	if ( Sender == lb_Active )
	{
		RemoveMutator();
		return true;
	}

	if ( GUIButton(Sender) == None )
		return false;

	switch ( GUIButton(Sender).Caption )
	{
	case b_Add.Caption:
		return AddMutator();

	case b_AddAll.Caption:
		if (lb_Avail.ItemCount()==0)
			return true;

		li_Active.LoadFrom(li_Avail);
		li_Avail.Clear();

		return true;

	case b_Remove.Caption:
		return RemoveMutator();

	case b_RemoveAll.Caption:
		if ( lb_Active.ItemCount()==0 )
			return true;

		li_Avail.LoadFrom(li_Active);
		li_Active.Clear();

		return true;
	}

	return false;
}

// This function overrides GUIList default behavior because we only want to disable the AddAll and RemoveAll
// if those lists are empty
function InternalCheckLinkedObj( GUIListBase List )
{
	if ( List.IsValid() )
		List.EnableLinkedObjects();
	else List.DisableLinkedObjects();

	if ( li_Avail.ItemCount > 0 )
		EnableComponent(b_AddAll);
	else DisableComponent(b_AddAll);

	if ( li_Active.ItemCount > 0 )
		EnableComponent(b_RemoveAll);
	else DisableComponent(b_RemoveAll);
}

function SubmitChanges()
{
	local int i, idx;
	local string str;

	if ( bDirty )
	{
		for ( i = 0; i < li_Active.ItemCount; i++ )
		{
			idx = FindTrackingIndex(li_Active.GetExtraAtIndex(i));
			if ( idx != -1 )
			{
				if ( str != "" )
					str $= ",";

				str $= idx;
			}
		}

		SendCommand( Group $ ":" $ str );
	}

	Super.SubmitChanges();
}

defaultproperties
{
     Begin Object Class=GUISectionBackground Name=InactiveBackground
         bFillClient=True
         Caption="Inactive Mutators"
         BottomPadding=0.110000
         WinTop=0.030053
         WinLeft=0.013880
         WinWidth=0.483107
         WinHeight=0.965313
         bBoundToParent=True
         bScaleToParent=True
         OnPreDraw=InactiveBackground.InternalPreDraw
     End Object
     sb_Avail=GUISectionBackground'xVoting.MatchSetupMutator.InactiveBackground'

     Begin Object Class=GUISectionBackground Name=ActiveBackground
         bFillClient=True
         Caption="Active Mutators"
         BottomPadding=0.110000
         WinTop=0.030053
         WinLeft=0.511243
         WinWidth=0.474194
         WinHeight=0.965313
         bBoundToParent=True
         bScaleToParent=True
         OnPreDraw=ActiveBackground.InternalPreDraw
     End Object
     sb_Active=GUISectionBackground'xVoting.MatchSetupMutator.ActiveBackground'

     Begin Object Class=GUIListBox Name=MutInactiveList
         bVisibleWhenEmpty=True
         bSorted=True
         OnCreateComponent=MutInactiveList.InternalOnCreateComponent
         WinTop=0.138078
         WinLeft=0.113794
         WinWidth=0.380394
         WinHeight=0.662671
         TabOrder=0
     End Object
     lb_Avail=GUIListBox'xVoting.MatchSetupMutator.MutInactiveList'

     Begin Object Class=GUIListBox Name=MutActiveList
         bVisibleWhenEmpty=True
         bSorted=True
         OnCreateComponent=MutActiveList.InternalOnCreateComponent
         WinTop=0.108021
         WinLeft=0.605861
         WinWidth=0.368359
         WinHeight=0.662671
         TabOrder=1
     End Object
     lb_Active=GUIListBox'xVoting.MatchSetupMutator.MutActiveList'

     Begin Object Class=GUIButton Name=MutAddButton
         Caption="Add"
         Hint="Add the selected mutators to the list"
         WinTop=0.902198
         WinLeft=0.263743
         WinWidth=0.203807
         WinHeight=0.079184
         TabOrder=6
         bRepeatClick=True
         OnClickSound=CS_Up
         OnClick=MatchSetupMutator.ModifyMutatorList
         OnKeyEvent=MutAddButton.InternalOnKeyEvent
     End Object
     b_Add=GUIButton'xVoting.MatchSetupMutator.MutAddButton'

     Begin Object Class=GUIButton Name=MutAddAllButton
         Caption="Add All"
         Hint="Add all mutators to the list"
         WinTop=0.902198
         WinLeft=0.045006
         WinWidth=0.190232
         WinHeight=0.079184
         TabOrder=5
         OnClickSound=CS_Up
         OnClick=MatchSetupMutator.ModifyMutatorList
         OnKeyEvent=MutAddAllButton.InternalOnKeyEvent
     End Object
     b_AddAll=GUIButton'xVoting.MatchSetupMutator.MutAddAllButton'

     Begin Object Class=GUIButton Name=MutRemoveButton
         Caption="Remove"
         AutoSizePadding=(HorzPerc=0.500000)
         Hint="Remove the selected mutators from the list"
         WinTop=0.799682
         WinLeft=0.543747
         WinWidth=0.191554
         WinHeight=0.055068
         TabOrder=10
         bRepeatClick=True
         OnClickSound=CS_Down
         OnClick=MatchSetupMutator.ModifyMutatorList
         OnKeyEvent=MutRemoveButton.InternalOnKeyEvent
     End Object
     b_Remove=GUIButton'xVoting.MatchSetupMutator.MutRemoveButton'

     Begin Object Class=GUIButton Name=MutRemoveAllButton
         Caption="Remove All"
         Hint="Remove all mutators from the list"
         WinTop=0.799682
         WinLeft=0.772577
         WinWidth=0.191554
         WinHeight=0.055068
         TabOrder=11
         OnClickSound=CS_Down
         OnClick=MatchSetupMutator.ModifyMutatorList
         OnKeyEvent=MutRemoveAllButton.InternalOnKeyEvent
     End Object
     b_RemoveAll=GUIButton'xVoting.MatchSetupMutator.MutRemoveAllButton'

     PanelCaption="Mutators"
}
