// ====================================================================
//  Class:  XInterface.Tab_InstantActionMutators
//  Parent: XInterface.GUITabPanel
//
//  <Enter a description here>
// ====================================================================

class Tab_InstantActionMutators extends UT2K3TabPanel;

var config 	string 	LastActiveMutators;

var GUIListBox			MyAvailMutators;
var GUIListBox			MySelectedMutators;
var GUIScrollTextBox	MyDescBox;

var	xMutatorList 		MutList;

var string				MutConfigMenu;

function InitComponent(GUIController MyController, GUIComponent MyOwner)
{
	local int i;
	local string t,m;
	
	Super.Initcomponent(MyController, MyOwner);

	MyAvailMutators=GUIListBox(Controls[1]);
	MyAvailMutators.List.OnDblClick=AvailDblClick;

	MySelectedMutators=GUIListBox(Controls[2]);
	MySelectedMutators.List.OnDblClick=SelectedDblClick;
	MyDescBox=GUIScrollTextBox(Controls[3]);

    MutList = PlayerOwner().Spawn(class'xMutatorList');
    MutList.Init();

	if( PlayerOwner().Level.IsDemoBuild())
	{
		i = 0;	
		while (i<MutList.MutatorList.Length)
		{
			if (MutList.MutatorList[i].ClassName ~= "xgame.mutzoominstagib" || MutList.MutatorList[i].ClassName ~= "unrealgame.mutlowgrav")
				i++;
			else
				MutList.MutatorList.Remove(i,1);
		}
			
	
	}

	for (i=0;i<MutList.MutatorList.Length;i++)
		MyAvailMutators.List.Add(MutList.MutatorList[i].FriendlyName,,MutList.MutatorList[i].Description);
	
	if (MyAvailMutators.List.ItemCount > 0)
	{
		MyDescBox.SetContent(MyAvailMutators.List.GetExtra());
		MutConfigMenu = GetMutatorConfigMenu( MyAvailMutators.List.Get() );
	}
	else if (MySelectedMutators.List.ItemCount > 0)
	{
		MyDescBox.SetContent(MySelectedMutators.List.GetExtra());
		MutConfigMenu = GetMutatorConfigMenu( MySelectedMutators.List.Get() );
	}
	else
		MyDescBox.SetContent("None");
	
	if(MutConfigMenu == "")
		Controls[4].bVisible = false;
	else
		Controls[4].bVisible = true;

 	m = LastActiveMutators;		
	t = NextMutatorInString(m);
	while (t!="")
	{
		SelectMutator(t);
		t = NextMutatorInString(m);
	}			
			
}

// Play is called when the play button is pressed.  It saves any releavent data and then
// returns any additions to the URL
function string Play()
{
	local string url,t;
	local int i;
	
	for (i=0;i<MySelectedMutators.ItemCount();i++)
	{
		t = ResolveMutator(MySelectedMutators.List.GetItemAtIndex(i));
		if (t!="")
		{
			if (url!="")
				url=url$","$t;
			else
				url = t;
		}
	} 

	if (url!="")
	{
		LastActiveMutators=url;
		url="?Mutator="$url;
	}
	else
		LastActiveMutators="";
		
	SaveConfig();
	return url;
}

function string ResolveMutator(string FriendlyName)
{
	local int i;
	
	for (i=0;i<MutList.MutatorList.Length;i++)
		if (MutList.MutatorList[i].FriendlyName~=FriendlyName)
			return MutList.MutatorList[i].ClassName;
	
	return "";
}

function string GetMutatorConfigMenu(string FriendlyName)
{
	local int i;
	
	for (i=0;i<MutList.MutatorList.Length;i++)
		if (MutList.MutatorList[i].FriendlyName~=FriendlyName)
			return MutList.MutatorList[i].ConfigMenuClassName;
	
	return "";
}

function string NextMutatorInString(out string mut)
{
	local string t;
	local int p;
	
	if (Mut=="")
		return "";
	
	p = Instr(Mut,",");
	if (p<0)
	{
		t = Mut;
		Mut = "";
	}
	else
	{
	 	t   = Left(Mut,p);
		Mut = Right(Mut,len(Mut)-P-1);
	}
	return t;
}
	
function SelectMutator(string mutclass)
{
	local int i;
	
	for (i=0;i<MutList.MutatorList.Length;i++)
		if (MutList.MutatorList[i].ClassName~=mutclass)
		{
			MyAvailMutators.List.Find(MutList.MutatorList[i].FriendlyName);
			AddMutator(none);
			return;
		}
}
		 

function bool AvailDBLClick(GUIComponent Sender)
{

	AddMutator(Sender);
	return true;
}

function bool SelectedDBLClick(GUIComponent Sender)
{

	RemoveMutator(Sender);
	return true;
}

function bool MutConfigClick(GUIComponent Sender)
{
	if(MutConfigMenu == "")
		return true;

	Log("Launch: "$MutConfigMenu);
	Controller.OpenMenu(MutConfigMenu);

	return true;
}

function ListChange(GUIComponent Sender)
{
	local string NewDesc;
	
	
	if (Sender==MyAvailMutators)
	{
		NewDesc = MyAvailMutators.List.GetExtra();
		MutConfigMenu = GetMutatorConfigMenu( MyAvailMutators.List.Get() );
	}
	else if (Sender==MySelectedMutators)
	{
		NewDesc = MySelectedMutators.List.GetExtra();
		MutConfigMenu = GetMutatorConfigMenu( MySelectedMutators.List.Get() );
	}
	else
		NewDesc = "";
		
	if (NewDesc!="")
		MyDescBox.SetContent(NewDesc);

	// Turn on mutator config menu if desired.
	if(MutConfigMenu == "")
		Controls[4].bVisible = false;
	else
		Controls[4].bVisible = true;
}		

function string GetGroupFor(string FriendlyName)
{
	local int i;
	for (i=0;i<MutList.MutatorList.Length;i++)
		if (MutList.MutatorList[i].FriendlyName ~= FriendlyName)
			return MutList.MutatorList[i].GroupName;
	
	return "";
}

function bool AddMutator(GUIComponent Sender)
{
	local int index,i;
	local string gname;
	
	Index = MyAvailMutators.List.Index;
	if (Index<0)
		return true;

	// Make sure one 1 mutator for each group is in there
	
	gname = GetGroupFor(MyAvailMutators.List.Get());
	if (gname!="")
	{
		for (i=0;i<MySelectedMutators.List.ItemCount;i++)
		{
			if (GetGroupFor(MySelectedMutators.List.GetItemAtIndex(i)) ~= gname)
			{
			
				MyAvailMutators.List.Add(MySelectedMutators.List.GetItemAtIndex(i),,MySelectedMutators.List.GetExtraAtIndex(i));
				MySelectedMutators.List.Remove(i,1);
				break;
			}
		}
	}
		
	MySelectedMutators.List.Add(MyAvailMutators.List.Get(),,MyAvailMutators.List.GetExtra());
	MyAvailMutators.List.Remove(Index,1);

	
	MyAvailMutators.List.SortList();
	MySelectedMutators.List.SortList();
	
	return true;	
	
}

function bool RemoveMutator(GUIComponent Sender)
{
	local int index;
	
	Index = MySelectedMutators.List.Index;
	if (Index<0)
		return true;

	MyAvailMutators.List.Add(MySelectedMutators.List.Get(),,MySelectedMutators.List.GetExtra());
	MySelectedMutators.List.Remove(Index,1);
	
	MyAvailMutators.List.SortList();
	MySelectedMutators.List.SortList();
	
	return true;	
}	

function bool AddAllMutators(GUIComponent Sender)
{
	if (MyAvailMutators.ItemCount()<=0)
		return true;
		
	MySelectedMutators.List.LoadFrom(MyAvailMutators.List,false);
	MyAvailMutators.List.Clear();

//	MySelectedMutators.List.Sort();

}	

function bool RemoveAllMutators(GUIComponent Sender)
{
	if (MySelectedMutators.ItemCount()<=0)
		return true;
		
	MyAvailMutators.List.LoadFrom(MySelectedMutators.List,false);
	MySelectedMutators.List.Clear();
//	MyAvailMutators.List.Sort();
}	

defaultproperties
{
     Begin Object Class=GUIImage Name=IAMutatorBK1
         Image=Texture'InterfaceContent.Menu.BorderBoxD'
         ImageColor=(A=160)
         ImageStyle=ISTY_Stretched
         WinTop=0.630156
         WinLeft=0.016758
         WinWidth=0.962383
         WinHeight=0.370860
     End Object
     Controls(0)=GUIImage'XInterface.Tab_InstantActionMutators.IAMutatorBK1'

     Begin Object Class=GUIListBox Name=IAMutatorAvailList
         bVisibleWhenEmpty=True
         OnCreateComponent=IAMutatorAvailList.InternalOnCreateComponent
         StyleName="SquareButton"
         Hint="These are the available mutators."
         WinTop=0.083281
         WinLeft=0.041406
         WinWidth=0.368359
         WinHeight=0.502696
         OnChange=Tab_InstantActionMutators.ListChange
     End Object
     Controls(1)=GUIListBox'XInterface.Tab_InstantActionMutators.IAMutatorAvailList'

     Begin Object Class=GUIListBox Name=IAMutatorSelectedList
         bVisibleWhenEmpty=True
         OnCreateComponent=IAMutatorSelectedList.InternalOnCreateComponent
         StyleName="SquareButton"
         Hint="These are the mutators you will play with."
         WinTop=0.083281
         WinLeft=0.584376
         WinWidth=0.368359
         WinHeight=0.502696
         OnChange=Tab_InstantActionMutators.ListChange
     End Object
     Controls(2)=GUIListBox'XInterface.Tab_InstantActionMutators.IAMutatorSelectedList'

     Begin Object Class=GUIScrollTextBox Name=IAMutatorScroll
         CharDelay=0.002500
         EOLDelay=0.500000
         OnCreateComponent=IAMutatorScroll.InternalOnCreateComponent
         WinTop=0.645834
         WinLeft=0.025976
         WinWidth=0.942969
         WinHeight=0.283007
         bNeverFocus=True
     End Object
     Controls(3)=GUIScrollTextBox'XInterface.Tab_InstantActionMutators.IAMutatorScroll'

     Begin Object Class=GUIButton Name=IAMutatorConfig
         Caption="Configure Mutator"
         Hint="Configure the selected mutator"
         WinTop=0.933490
         WinLeft=0.729492
         WinWidth=0.239063
         WinHeight=0.054648
         bVisible=False
         OnClick=Tab_InstantActionMutators.MutConfigClick
         OnKeyEvent=IAMutatorConfig.InternalOnKeyEvent
     End Object
     Controls(4)=GUIButton'XInterface.Tab_InstantActionMutators.IAMutatorConfig'

     Begin Object Class=GUIButton Name=IAMutatorAdd
         Caption="Add"
         Hint="Adds the selection to the list of mutators to play with."
         WinTop=0.194114
         WinLeft=0.425000
         WinWidth=0.145000
         WinHeight=0.050000
         OnClickSound=CS_Up
         OnClick=Tab_InstantActionMutators.AddMutator
         OnKeyEvent=IAMutatorAdd.InternalOnKeyEvent
     End Object
     Controls(5)=GUIButton'XInterface.Tab_InstantActionMutators.IAMutatorAdd'

     Begin Object Class=GUIButton Name=IAMutatorRemove
         Caption="Remove"
         Hint="Removes the selection from the list of mutators to play with."
         WinTop=0.424322
         WinLeft=0.425000
         WinWidth=0.145000
         WinHeight=0.050000
         OnClickSound=CS_Down
         OnClick=Tab_InstantActionMutators.RemoveMutator
         OnKeyEvent=IAMutatorRemove.InternalOnKeyEvent
     End Object
     Controls(6)=GUIButton'XInterface.Tab_InstantActionMutators.IAMutatorRemove'

     Begin Object Class=GUIButton Name=IAMutatorAll
         Caption="Add All"
         Hint="Adds all mutators to the list of mutators to play with."
         WinTop=0.259218
         WinLeft=0.425000
         WinWidth=0.145000
         WinHeight=0.050000
         OnClickSound=CS_Up
         OnClick=Tab_InstantActionMutators.AddAllMutators
         OnKeyEvent=IAMutatorAll.InternalOnKeyEvent
     End Object
     Controls(7)=GUIButton'XInterface.Tab_InstantActionMutators.IAMutatorAll'

     Begin Object Class=GUIButton Name=IAMutatorClear
         Caption="Remove All"
         Hint="Removes all mutators from the list of mutators to play with."
         WinTop=0.360259
         WinLeft=0.425000
         WinWidth=0.145000
         WinHeight=0.050000
         OnClickSound=CS_Down
         OnClick=Tab_InstantActionMutators.RemoveAllMutators
         OnKeyEvent=IAMutatorClear.InternalOnKeyEvent
     End Object
     Controls(8)=GUIButton'XInterface.Tab_InstantActionMutators.IAMutatorClear'

     Begin Object Class=GUILabel Name=IAMutatorAvilLabel
         Caption="Available Mutators"
         TextColor=(B=255,G=255,R=255)
         WinTop=0.015885
         WinLeft=0.049022
         WinWidth=0.500000
         WinHeight=32.000000
     End Object
     Controls(9)=GUILabel'XInterface.Tab_InstantActionMutators.IAMutatorAvilLabel'

     Begin Object Class=GUILabel Name=IAMutatorSelectedLabel
         Caption="Active Mutators"
         TextColor=(B=255,G=255,R=255)
         WinTop=0.015885
         WinLeft=0.592383
         WinWidth=0.500000
         WinHeight=32.000000
     End Object
     Controls(10)=GUILabel'XInterface.Tab_InstantActionMutators.IAMutatorSelectedLabel'

     WinTop=0.150000
     WinHeight=0.770000
}
