// ====================================================================
//  Class:  XInterface.Tab_InstantActionMapList
//  Parent: XInterface.GUITabPanel
//
//  <Enter a description here>
// ====================================================================

class Tab_InstantActionMapList extends UT2K3TabPanel;

var GUIListBox 			MyFullMapList;
var GUIListBox 			MyCurMapList;

function InitComponent(GUIController MyController, GUIComponent MyOwner)
{
	Super.Initcomponent(MyController, MyOwner);

	MyFullMapList  			= GUIListBox(Controls[0]);
	MyCurMapList 	  		= GUIListBox(Controls[1]);
}

function string Play()
{
/*
	local TAB_InstantActionMain pMain;
	local MapList ML;
	local class<MapList> MLClass;
	local int i;

	if (UT2InstantActionPage(Controller.ActivePage)==None)
		return "";

	pMain = UT2InstantActionPage(Controller.ActivePage).pMain;

	MLClass = class<MapList>(DynamicLoadObject(pMain.GetMapListClass(), class'class'));
	if (MLClass!=None)
	{
		ML = PlayerOwner().spawn(MLClass);
		if (ML!=None)
		{
			ML.Maps.Remove(0,ML.Maps.Length);
			for (i=0;i<MyCurMapList.ItemCount();i++)
				ML.Maps[i]=MyCurMapList.List.GetItemAtIndex(i);

			ML.SaveConfig();
			ML.Destroy();
		}
	}
*/
	return "";
}


function ReadMapList(string MapPreFix, string MapListClass)
{
/*
	local MapList ML;
	local class<MapList> MLClass;
	local int i,j;

	MyFullMapList.List.Clear();
	MyCurMapList.List.Clear();

	Controller.GetMapList(MapPrefix,MyFullMapList.List);
	MyFullMapList.List.SetIndex(0);

	MLClass = class<MapList>(DynamicLoadObject(MapListClass, class'class'));
	if (MLClass!=None)
	{
		ML = PlayerOwner().spawn(MLClass);
		if (ML!=None)
		{
			for (i=0;i<ML.Maps.Length;i++)
			{
				for (j=0;j<MyFullMapList.ItemCount();j++)
				{
					if (MyFullMapList.List.GetItemAtIndex(j) ~= ML.Maps[i])
					{
						MyCurMapList.List.Add(ML.Maps[i]);
						MyFullmapList.List.Remove(j,1);
						break;
					}
				}
			}
			ML.Destroy();
		}
	}
*/
}

function bool MapAdd(GUIComponent Sender)
{
	if ( (MyFullMapList.ItemCount()==0) || (MyFullMapList.List.Index<0) )
		return true;

	MyCurMapList.List.Add(MyFullMapList.List.Get());
	MyFullMapList.List.Remove(MyFullMapList.List.Index,1);

	return true;
}

function bool MapRemove(GUIComponent Sender)
{
	if ( (MyCurMapList.ItemCount()==0) || (MyCurMapList.List.Index<0) )
		return true;

	MyFullMapList.List.Add(MyCurMapList.List.Get());
	MyCurMapList.List.Remove(MyCurMapList.List.Index,1);

	return true;
}

function bool MapAll(GUIComponent Sender)
{
	if (MyFullMapList.ItemCount()==0)
		return true;

	MyCurMapList.List.LoadFrom(MyFullMapList.List,false);
	MyFullMapList.List.Clear();

	return true;
}

function bool MapClear(GUIComponent Sender)
{
	if (MyCurMapList.ItemCount()==0)
		return true;

	MyFullMapList.List.LoadFrom(MyCurMapList.List,false);
	MyCurMapList.List.Clear();

	return true;
}

function bool MapUp(GUIComponent Sender)
{
	local int index;
	if ( (MyCurMapList.ItemCount()==0) || (MyCurMapList.List.Index<0) )
		return true;

	index = MyCurMapList.List.Index;
	if (index>0)
	{
		MyCurMapList.List.Swap(index,index-1);
		MyCurMapList.List.Index = index-1;
	}

	return true;
}

function bool MapDown(GUIComponent Sender)
{
	local int index;
	if ( (MyCurMapList.ItemCount()==0) || (MyCurMapList.List.Index<0) )
		return true;

	index = MyCurMapList.List.Index;
	if (index<MyCurMapList.ItemCount()-1)
	{
		MyCurMapList.List.Swap(index,index+1);
		MyCurMapList.List.Index = index+1;
	}

	return true;
}

defaultproperties
{
     Begin Object Class=GUIListBox Name=IAMapListFullMapList
         bVisibleWhenEmpty=True
         OnCreateComponent=IAMapListFullMapList.InternalOnCreateComponent
         StyleName="SquareButton"
         Hint="Available maps"
         WinTop=0.083281
         WinLeft=0.041406
         WinWidth=0.368359
         WinHeight=0.783942
     End Object
     Controls(0)=GUIListBox'XInterface.Tab_InstantActionMapList.IAMapListFullMapList'

     Begin Object Class=GUIListBox Name=IAMapListCurMapList
         bVisibleWhenEmpty=True
         OnCreateComponent=IAMapListCurMapList.InternalOnCreateComponent
         StyleName="SquareButton"
         Hint="Selected maps"
         WinTop=0.083281
         WinLeft=0.584376
         WinWidth=0.368359
         WinHeight=0.783942
     End Object
     Controls(1)=GUIListBox'XInterface.Tab_InstantActionMapList.IAMapListCurMapList'

     Begin Object Class=GUIButton Name=IAMapListAdd
         Caption="Add"
         Hint="Add this map to your map list"
         WinTop=0.323801
         WinLeft=0.425000
         WinWidth=0.145000
         WinHeight=0.050000
         OnClickSound=CS_Up
         OnClick=Tab_InstantActionMapList.MapAdd
         OnKeyEvent=IAMapListAdd.InternalOnKeyEvent
     End Object
     Controls(2)=GUIButton'XInterface.Tab_InstantActionMapList.IAMapListAdd'

     Begin Object Class=GUIButton Name=IAMapListRemove
         Caption="Remove"
         Hint="Remove this map from your map list"
         WinTop=0.493072
         WinLeft=0.425000
         WinWidth=0.145000
         WinHeight=0.050000
         OnClickSound=CS_Down
         OnClick=Tab_InstantActionMapList.MapRemove
         OnKeyEvent=IAMapListRemove.InternalOnKeyEvent
     End Object
     Controls(3)=GUIButton'XInterface.Tab_InstantActionMapList.IAMapListRemove'

     Begin Object Class=GUIButton Name=IAMapListAll
         Caption="Add All"
         Hint="Add all maps to your map list"
         WinTop=0.388905
         WinLeft=0.425000
         WinWidth=0.145000
         WinHeight=0.050000
         OnClickSound=CS_Up
         OnClick=Tab_InstantActionMapList.MapAll
         OnKeyEvent=IAMapListAll.InternalOnKeyEvent
     End Object
     Controls(4)=GUIButton'XInterface.Tab_InstantActionMapList.IAMapListAll'

     Begin Object Class=GUIButton Name=IAMapListClear
         Caption="Remove All"
         Hint="Remove all maps from your map list"
         WinTop=0.558176
         WinLeft=0.425000
         WinWidth=0.145000
         WinHeight=0.050000
         OnClickSound=CS_Down
         OnClick=Tab_InstantActionMapList.MapClear
         OnKeyEvent=IAMapListClear.InternalOnKeyEvent
     End Object
     Controls(5)=GUIButton'XInterface.Tab_InstantActionMapList.IAMapListClear'

     Begin Object Class=GUIButton Name=IAMapListUp
         Caption="Up"
         Hint="Move this map higher up in the list"
         WinTop=0.121978
         WinLeft=0.425000
         WinWidth=0.145000
         WinHeight=0.050000
         OnClickSound=CS_Up
         OnClick=Tab_InstantActionMapList.MapUp
         OnKeyEvent=IAMapListUp.InternalOnKeyEvent
     End Object
     Controls(6)=GUIButton'XInterface.Tab_InstantActionMapList.IAMapListUp'

     Begin Object Class=GUIButton Name=IAMapListDown
         Caption="Down"
         Hint="Move this map lower down in the list"
         WinTop=0.779531
         WinLeft=0.425000
         WinWidth=0.145000
         WinHeight=0.050000
         OnClickSound=CS_Down
         OnClick=Tab_InstantActionMapList.MapDown
         OnKeyEvent=IAMapListDown.InternalOnKeyEvent
     End Object
     Controls(7)=GUIButton'XInterface.Tab_InstantActionMapList.IAMapListDown'

     Begin Object Class=GUILabel Name=IAMapListAvilLabel
         Caption="Available Map List"
         TextColor=(B=255,G=255,R=255)
         WinTop=0.015885
         WinLeft=0.049022
         WinWidth=0.500000
         WinHeight=32.000000
     End Object
     Controls(8)=GUILabel'XInterface.Tab_InstantActionMapList.IAMapListAvilLabel'

     Begin Object Class=GUILabel Name=IAMapListSelectedLabel
         Caption="Selected Map List"
         TextColor=(B=255,G=255,R=255)
         WinTop=0.015885
         WinLeft=0.592383
         WinWidth=0.500000
         WinHeight=32.000000
     End Object
     Controls(9)=GUILabel'XInterface.Tab_InstantActionMapList.IAMapListSelectedLabel'

     WinTop=0.150000
     WinHeight=0.770000
}
