// ====================================================================
//  Class:  XInterface.Tab_MultiplayerHostMain
//  Parent: XInterface.GUITabPanel
//
//  <Enter a description here>
// ====================================================================

class Tab_MultiplayerHostMain extends UT2K3TabPanel;

var	config string LastGameType;			// Stores the last known settings
var	config string LastMap;

var moComboBox 			MyGameCombo;
var GUIImage   			MyMapImage;
var GUIScrollTextBox	MyMapScroll;
var GUIListBox 			MyFullMapList;
var GUIListBox 			MyCurMapList;
var GUILabel			MyMapName;

var localized string	MessageNoInfo;

delegate OnChangeGameType();

function InitComponent(GUIController MyController, GUIComponent MyOwner)
{
	local string Entry, Desc;
	local int index;

	Super.Initcomponent(MyController, MyOwner);

	MyGameCombo 			= moComboBox(Controls[2]);
	MyMapImage  			= GUIImage(Controls[3]);
	MyMapScroll 			= GUIScrollTextBox(Controls[4]);
	MyFullMapList			= GUIListBox(Controls[6]);
	MyFullMapList.List.OnDblClick=MapAdd;
	MyCurMapList			= GUIListBox(Controls[13]);
	MyCurMapList.List.OnDblClick=MapRemove;
	MyMapName				= GUILabel(Controls[14]);

	Index = 0;

	PlayerOwner().GetNextIntDesc("GameInfo",Index,Entry,Desc);
	while (Entry != "")
	{
		Desc = Entry$"|"$Desc;

		if ( ! ((PlayerOwner().Level.IsDemoBuild()) && (InStr (Desc, "xDoubleDom" ) >= 0) ) )
		{
			MyGameCombo.AddItem(ParseDescStr(Desc,2),,Desc);

/*
			if ( (LastGameType=="") || (LastGameType==Entry) )
			{
				MyGameCombo.SetText(ParseDescStr(Desc,2));
				LastGameType=Entry;
			}
*/
		}

		Index++;
		PlayerOwner().GetNextIntDesc("GameInfo", Index, Entry, Desc);
	}

	MyGamecombo.MyComboBox.List.SortList();
    SelectGameType(LastGameType);

	MyGameCombo.ReadOnly(true);

	// Load Maps for the current GameType

	ReadMapList(GetMapPrefix(),GetMapListClass());

	// Set the original map

	if ( (LastMap=="") || (MyFullMapList.List.Find(LastMap)=="") )
		MyFullMapList.List.SetIndex(0);

	Entry = MyFullMapList.List.Get();
	if (Entry=="")
	{
		Entry = MyCurMapList.List.GetItemAtIndex(0);
	}
	if (Entry!="")
		ReadMapInfo(Entry);

}

// Play is called when the play button is pressed.  It saves any releavent data and then
// returns any additions to the URL
function string Play()
{
/*
	local MapList ML;
	local class<MapList> MLClass;
	local int i;

	MLClass = class<MapList>(DynamicLoadObject(GetMapListClass(), class'class'));
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

//	return "?Difficulty="$LastBotSkill$"?AutoAdjust="$LastAutoAdjust;
*/
	return "";
}

function string ParseDescStr(string DescStr, int index)
{
	local string temp;
	local int p,i;

	i = 0;

	while (DescStr!="")
	{
		p = instr(DescStr,"|");
		if (p<0)
		{
			Temp = DescStr;
			DescStr = "";
		}
		else
		{
			Temp = Left(DescStr,p);
			DescStr = Right(DescStr,Len(DescStr)-p-1);
		}
		if (i==Index)

			return Temp;

		i++;
	}
}

function string GetMapPrefix()
{
	return ParseDescStr(MyGameCombo.GetExtra(),1);
}

function string GetRulesClass()
{
	return ParseDescStr(MyGameCombo.GetExtra(),3);
}

function bool GetIsTeamGame()
{
	return bool(ParseDescStr(MyGameCombo.GetExtra(),5));
}

function string GetMapListClass()
{
	return ParseDescStr(MyGameCombo.GetExtra(),4);
}

function string GetGameClass()
{
	return ParseDescStr(MyGameCombo.GetExtra(),0);
}

function ReadMapInfo(string MapName)
{
	local LevelSummary L;
	local string mName,mDesc;
	local int p;

	if(MapName == "")
		return;

	L = LevelSummary(DynamicLoadObject(MapName$".LevelSummary", class'LevelSummary'));

	if ( L != none )
		MyMapName.Caption = L.Title;

	MyMapImage.Image = Material(DynamicLoadObject(MapName$".Screenshot", class'Material'));
	if (MyMapImage.Image==None)
	{
		if (L == none || L.ScreenShot==None)
			MyMapImage.Image = material'InterfaceContent.Menu.NoLevelPreview';
		else
			MyMapImage.Image = L.Screenshot;
	}

	p = instr(MapName,"-");
	if (p<0)
		mName = MapName;
	else
		mName = Right(MapName,Len(MapName)-p-1);

    if (L!=None)
		GUILabel(Controls[16]).Caption = ""$L.IdealPlayerCountMin@"-"@L.IdealPlayerCountMax@"players";
    else
	    GUILabel(Controls[16]).Caption = "";

	mDesc = Controller.LoadDecoText("XMaps",mName);
	if (mDesc=="")
    {
    	if (L!=None)
			mDesc = L.Description;
    	else
        	mDesc = "No Description Available!";
    }
    else
    {
    	GUILabel(Controls[15]).Caption = "";
	    MyMapScroll.SetContent(mDesc);
        return;
    }

	if (mDesc=="")
    	mDesc = MessageNoInfo;

    if (L!=None && L.Author!="")
		GUILabel(Controls[15]).Caption = "Author:"@L.Author;
    else
    	GUILabel(Controls[15]).Caption = "";

	MyMapScroll.SetContent(mDesc);
}

function ReadMapList(string MapPreFix, string MapListClass)
{
/*	local MapList ML;
	local class<MapList> MLClass;
	local int i,j;

	MyFullMapList.List.Clear();
	MyCurMapList.List.Clear();

	Controller.GetMapList(MapPrefix,MyFullMapList.List);
    MyFullMapList.List.SortList();
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
	MyFullMapList.List.SortList();
	MyCurMapList.List.Remove(MyCurMapList.List.Index,1);
	MapListChange(MyFullMapList);

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
	MapListChange(MyFullMapList);

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

function GameTypeChanged(GUIComponent Sender)
{
	local string Desc;

	if (!Controller.bCurMenuInitialized)
		return;

	// Load Maps for the current GameType

	Desc = MyGameCombo.GetExtra();
	ReadMapList(GetMapPrefix(),GetMapListClass());

	LastGameType = ParseDescStr(Desc,0);
	SaveConfig();

	OnChangeGameType();
}


function MapListChange(GUIComponent Sender)
{

	local string map;

	if (!Controller.bCurMenuInitialized)
		return;

	Map = GUIListBox(Sender).List.Get();

	if (Map=="")
		return;
	else
		LastMap = Map;

	SaveConfig();
	ReadMapInfo(LastMap);
}

function SelectGameType(string GameType)
{
	local int i;
    local GUIList List;
    local string desc;

    List = MyGameCombo.MyComboBox.List;
	for (i=0;i<List.Elements.Length;i++)
    {
    	Desc = List.GetExtraAtIndex(i);
		if (ParseDescStr(Desc,0) ~= GameType)
        {
        	List.Index = i;
			MyGameCombo.SetText(ParseDescStr(Desc,2));
        	return;
    	}
    }
}

defaultproperties
{
     MessageNoInfo="No information available!"
     Begin Object Class=GUIImage Name=MPHostBK1
         Image=Texture'InterfaceContent.Menu.BorderBoxD'
         ImageColor=(A=160)
         ImageStyle=ISTY_Stretched
         WinTop=0.024687
         WinLeft=0.016758
         WinWidth=0.957500
         WinHeight=0.107188
     End Object
     Controls(0)=GUIImage'XInterface.Tab_MultiplayerHostMain.MPHostBK1'

     Begin Object Class=GUIImage Name=MPHostBK2
         Image=Texture'InterfaceContent.Menu.BorderBoxD'
         ImageColor=(A=160)
         ImageStyle=ISTY_Stretched
         WinTop=0.160885
         WinLeft=0.022695
         WinWidth=0.451172
         WinHeight=0.416016
     End Object
     Controls(1)=GUIImage'XInterface.Tab_MultiplayerHostMain.MPHostBK2'

     Begin Object Class=moComboBox Name=MPHost_GameType
         ComponentJustification=TXTA_Left
         CaptionWidth=0.300000
         Caption="Game Type:"
         OnCreateComponent=MPHost_GameType.InternalOnCreateComponent
         Hint="Select the type of game you wish to play."
         WinTop=0.047917
         WinLeft=0.250000
         WinHeight=0.060000
         OnChange=Tab_MultiplayerHostMain.GameTypeChanged
     End Object
     Controls(2)=moComboBox'XInterface.Tab_MultiplayerHostMain.MPHost_GameType'

     Begin Object Class=GUIImage Name=MPHost_MapImage
         Image=Texture'InterfaceContent.Menu.NoLevelPreview'
         ImageStyle=ISTY_Scaled
         ImageRenderStyle=MSTY_Normal
         WinTop=0.165573
         WinLeft=0.518984
         WinWidth=0.444063
         WinHeight=0.406562
     End Object
     Controls(3)=GUIImage'XInterface.Tab_MultiplayerHostMain.MPHost_MapImage'

     Begin Object Class=GUIScrollTextBox Name=MPHost_MapScroll
         CharDelay=0.002500
         EOLDelay=0.500000
         OnCreateComponent=MPHost_MapScroll.InternalOnCreateComponent
         WinTop=0.255209
         WinLeft=0.030859
         WinWidth=0.430274
         WinHeight=0.302539
     End Object
     Controls(4)=GUIScrollTextBox'XInterface.Tab_MultiplayerHostMain.MPHost_MapScroll'

     Begin Object Class=GUIImage Name=MPHostBK3
         Image=Texture'InterfaceContent.Menu.BorderBoxA1'
         ImageColor=(A=160)
         ImageStyle=ISTY_Stretched
         ImageRenderStyle=MSTY_Normal
         WinTop=0.160104
         WinLeft=0.515781
         WinWidth=0.450664
         WinHeight=0.416758
     End Object
     Controls(5)=GUIImage'XInterface.Tab_MultiplayerHostMain.MPHostBK3'

     Begin Object Class=GUIListBox Name=MPHostListFullMapList
         bVisibleWhenEmpty=True
         OnCreateComponent=MPHostListFullMapList.InternalOnCreateComponent
         StyleName="SquareButton"
         Hint="Select the map to play"
         WinTop=0.604115
         WinLeft=0.021875
         WinWidth=0.392773
         WinHeight=0.386486
         OnChange=Tab_MultiplayerHostMain.MapListChange
     End Object
     Controls(6)=GUIListBox'XInterface.Tab_MultiplayerHostMain.MPHostListFullMapList'

     Begin Object Class=GUIButton Name=MPHostListAdd
         Caption="Add"
         Hint="Add this map to your map list"
         WinTop=0.679530
         WinLeft=0.433203
         WinWidth=0.123828
         WinHeight=0.050000
         OnClickSound=CS_Up
         OnClick=Tab_MultiplayerHostMain.MapAdd
         OnKeyEvent=MPHostListAdd.InternalOnKeyEvent
     End Object
     Controls(7)=GUIButton'XInterface.Tab_MultiplayerHostMain.MPHostListAdd'

     Begin Object Class=GUIButton Name=MPHostListRemove
         Caption="Remove"
         Hint="Remove this map from your map list"
         WinTop=0.862864
         WinLeft=0.433203
         WinWidth=0.123828
         WinHeight=0.050000
         OnClickSound=CS_Down
         OnClick=Tab_MultiplayerHostMain.MapRemove
         OnKeyEvent=MPHostListRemove.InternalOnKeyEvent
     End Object
     Controls(8)=GUIButton'XInterface.Tab_MultiplayerHostMain.MPHostListRemove'

     Begin Object Class=GUIButton Name=MPHostListUp
         Caption="Up"
         Hint="Move this map higher up in the list"
         WinTop=0.610259
         WinLeft=0.433203
         WinWidth=0.123828
         WinHeight=0.050000
         OnClickSound=CS_Up
         OnClick=Tab_MultiplayerHostMain.MapUp
         OnKeyEvent=MPHostListUp.InternalOnKeyEvent
     End Object
     Controls(9)=GUIButton'XInterface.Tab_MultiplayerHostMain.MPHostListUp'

     Begin Object Class=GUIButton Name=MPHostListAll
         Caption="Add All"
         Hint="Add all maps to your map list"
         WinTop=0.733697
         WinLeft=0.433203
         WinWidth=0.123828
         WinHeight=0.050000
         OnClickSound=CS_Up
         OnClick=Tab_MultiplayerHostMain.MapAll
         OnKeyEvent=MPHostListAll.InternalOnKeyEvent
     End Object
     Controls(10)=GUIButton'XInterface.Tab_MultiplayerHostMain.MPHostListAll'

     Begin Object Class=GUIButton Name=MPHostListClear
         Caption="Remove All"
         Hint="Remove all maps from your map list"
         WinTop=0.808697
         WinLeft=0.433203
         WinWidth=0.123828
         WinHeight=0.050000
         OnClickSound=CS_Down
         OnClick=Tab_MultiplayerHostMain.MapClear
         OnKeyEvent=MPHostListClear.InternalOnKeyEvent
     End Object
     Controls(11)=GUIButton'XInterface.Tab_MultiplayerHostMain.MPHostListClear'

     Begin Object Class=GUIButton Name=MPHostListDown
         Caption="Down"
         Hint="Move this map lower down in the list"
         WinTop=0.932135
         WinLeft=0.433203
         WinWidth=0.123828
         WinHeight=0.050000
         OnClickSound=CS_Down
         OnClick=Tab_MultiplayerHostMain.MapDown
         OnKeyEvent=MPHostListDown.InternalOnKeyEvent
     End Object
     Controls(12)=GUIButton'XInterface.Tab_MultiplayerHostMain.MPHostListDown'

     Begin Object Class=GUIListBox Name=MPHostListCurMapList
         bVisibleWhenEmpty=True
         OnCreateComponent=MPHostListCurMapList.InternalOnCreateComponent
         StyleName="SquareButton"
         Hint="Select the map to play"
         WinTop=0.604115
         WinLeft=0.574610
         WinWidth=0.391796
         WinHeight=0.386486
         OnChange=Tab_MultiplayerHostMain.MapListChange
     End Object
     Controls(13)=GUIListBox'XInterface.Tab_MultiplayerHostMain.MPHostListCurMapList'

     Begin Object Class=GUILabel Name=MPHostMapName
         Caption="Testing"
         TextAlign=TXTA_Center
         TextColor=(B=0,G=180,R=220)
         TextFont="UT2HeaderFont"
         WinTop=0.175468
         WinLeft=0.057617
         WinWidth=0.382813
         WinHeight=32.000000
     End Object
     Controls(14)=GUILabel'XInterface.Tab_MultiplayerHostMain.MPHostMapName'

     Begin Object Class=GUILabel Name=IAMain_MapAuthor
         Caption="Testing"
         TextAlign=TXTA_Center
         TextColor=(B=255,G=255,R=255)
         TextFont="UT2SmallHeaderFont"
         WinTop=0.471822
         WinLeft=0.531054
         WinWidth=0.445313
         WinHeight=17.000000
     End Object
     Controls(15)=GUILabel'XInterface.Tab_MultiplayerHostMain.IAMain_MapAuthor'

     Begin Object Class=GUILabel Name=IAMain_MapPlayers
         Caption="Best for 4 to 8 players"
         TextAlign=TXTA_Center
         TextColor=(B=255,G=255,R=255)
         TextFont="UT2SmallHeaderFont"
         WinTop=0.513489
         WinLeft=0.531054
         WinWidth=0.445313
         WinHeight=17.000000
     End Object
     Controls(16)=GUILabel'XInterface.Tab_MultiplayerHostMain.IAMain_MapPlayers'

     WinTop=0.150000
     WinHeight=0.770000
}
