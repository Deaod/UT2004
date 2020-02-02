// ====================================================================
//  Class:  XInterface.Tab_InstantActionMain
//  Parent: XInterface.GUITabPanel
//
//  <Enter a description here>
// ====================================================================

class Tab_InstantActionMain extends UT2K3TabPanel;

var	config string	LastGameType;			// Stores the last known settings
var config string	LastMap;
var	config int		LastBotSkill,
					LastBotCount;
var config bool		LastUseMapBots,
					LastUseCustomBots;

var GUIListBox 			MyMapList;
var moComboBox 			MyGameCombo;
var GUIImage   			MyMapImage;
var GUIScrollTextBox	MyMapScroll;
var	moComboBox			MyBotSkill;
var moCheckBox			MyUseMapBots;
var moCheckBox			MyUseCustomBots;
var moNumericEdit		MyBotCount;
var GUILabel			MyMapName;

var localized string	DifficultyLevels[8];
var localized string	MessageNoInfo;

delegate OnChangeGameType();
delegate OnChangeCustomBots();

function InitComponent(GUIController MyController, GUIComponent MyOwner)
{
	local string Entry, Desc;
	local int index;

	Super.Initcomponent(MyController, MyOwner);

	MyBotCount				= moNumericEdit(Controls[1]);
	MyGameCombo 			= moComboBox(Controls[2]);
	MyMapList   			= GUIListBox(Controls[3]);
	MyMapImage  			= GUIImage(Controls[4]);
	MyMapScroll 			= GUIScrollTextBox(Controls[5]);
	MyBotSkill				= moComboBox(Controls[7]);
	MyUseMapBots			= moCheckBox(Controls[8]);
	MyUseCustomBots			= moCheckBox(COntrols[9]);
	MyMapName				= GUILabel(Controls[12]);

	MyMapList.List.OnChange = MapListChange;
	MyMapList.List.OnDblClick = MapListDblClick;

	Index = 0;
	PlayerOwner().GetNextIntDesc("GameInfo",Index,Entry,Desc);
	while (Entry != "")
	{
		Desc = Entry$"|"$Desc;
		if ( ! ((PlayerOwner().Level.IsDemoBuild()) && (InStr (Desc, "xDoubleDom" ) >= 0) ) )
		{
			MyGameCombo.AddItem(ParseDescStr(Desc,2),,Desc);

//			if ( (LastGameType=="") || (LastGameType~=Entry) )
//			{
//				MyGameCombo.SetText(ParseDescStr(Desc,2));
//				LastGameType=Entry;
//			}
		}

		Index++;
		PlayerOwner().GetNextIntDesc("GameInfo", Index, Entry, Desc);
	}

    MyGameCombo.MyComboBox.List.SortList();
    SelectGameType(LastGameType);


	MyGameCombo.ReadOnly(true);

	// Load Maps for the current GameType

	ReadMapList(GetMapPrefix());

	// Set the original map

	if ( (LastMap=="") || (MyMapList.List.Find(LastMap)=="") )
		MyMapList.List.SetIndex(0);

	ReadMapInfo(MyMapList.List.Get());

	for(index = 0;index < 8;index++)
		MyBotSkill.AddItem(DifficultyLevels[index]);
	MyBotSkill.ReadOnly(True);
	MyBotSkill.SetIndex(LastBotSkill);

	MyBotCount.SetValue(LastBotCount);
	MyUseCustomBots.Checked(LastUseCustomBots);
	MyUseMapBots.Checked(LastUseMapBots);

	if(LastUseMapBots)
	{
		MyUseCustomBots.Checked(false);
		MyUseCustomBots.MenuStateChange(MSAT_Disabled);
		MyBotCount.MenuStateChange(MSAT_Disabled);
	}
	else
	{
		MyUseCustomBots.MenuStateChange(MSAT_Blurry);

		if(LastUseCustomBots)
			MyBotCount.MenuStateChange(MSAT_Disabled);
		else
			MyBotCount.MenuStateChange(MSAT_Blurry);
	}
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


// Play is called when the play button is pressed.  It saves any releavent data and then
// returns any additions to the URL
function string Play()
{
	LastBotCount = MyBotCount.GetValue();
	SaveConfig();

	return "?Difficulty="$LastBotSkill$"?bAutoNumBots="$LastUseMapBots$"?NumBots="$LastBotCount;
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

function string GetMapListClass()
{
	return ParseDescStr(MyGameCombo.GetExtra(),4);
}

function bool GetIsTeamGame()
{
	return bool(ParseDescStr(MyGameCombo.GetExtra(),5));
}

function string GetGameClass()
{
	return ParseDescStr(MyGameCombo.GetExtra(),0);
}

//function ReadMapList(class<GameInfo> GameClass)
function ReadMapList(string MapPreFix)
{
	MyMapList.List.Clear();

	Controller.GetMapList(MapPrefix,MyMapList.List);
	MyMapList.List.SortList();
	MyMapList.List.SetIndex(0);
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
	else
    	MyMapName.Caption = MapName;

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

	GUILabel(Controls[14]).Caption = ""$L.IdealPlayerCountMin@"-"@L.IdealPlayerCountMax@"players";

	mDesc = Controller.LoadDecoText("XMaps",mName);
	if (mDesc=="")
	   mDesc = L.Description;
    else
    {
    	GUILabel(Controls[13]).Caption = "";
	    MyMapScroll.SetContent(mDesc);
        return;
    }

	if (mDesc=="")
    	mDesc = MessageNoInfo;

    if (L.Author!="")
		GUILabel(Controls[13]).Caption = "Author:"@L.Author;
    else
    	GUILabel(Controls[13]).Caption = "";

	MyMapScroll.SetContent(mDesc);
}

function GameTypeChanged(GUIComponent Sender)
{
	local string Desc;

	if (!Controller.bCurMenuInitialized)
		return;

	// Load Maps for the current GameType

	Desc = MyGameCombo.GetExtra();
	ReadMapList(ParseDescStr(Desc,1));

	LastGameType = ParseDescStr(Desc,0);
	SaveConfig();

	OnChangeGameType();
}


function MapListChange(GUIComponent Sender)
{
	if (!Controller.bCurMenuInitialized)
		return;

	LastMap = MyMapList.List.Get();
	SaveConfig();

	ReadMapInfo(LastMap);
}

function BotSkillChanged(GUIComponent Sender)
{
	if (!Controller.bCurMenuInitialized)
		return;

	LastBotSkill=MyBotSkill.GetIndex();
	SaveConfig();
}

function ChangeMapBots(GUIComponent Sender)
{
	if(!Controller.bCurMenuInitialized)
		return;

	LastUseMapBots = MyUseMapBots.IsChecked();
	SaveConfig();

	if(LastUseMapBots)
	{
		MyUseCustomBots.Checked(false);
		MyUseCustomBots.MenuStateChange(MSAT_Disabled);
		MyBotCount.MenuStateChange(MSAT_Disabled);
	}
	else
	{
		MyUseCustomBots.MenuStateChange(MSAT_Blurry);
		MyBotCount.MenuStateChange(MSAT_Blurry);
	}
}

function ChangeCustomBots(GUIComponent Sender)
{
	if(!Controller.bCurMenuInitialized)
		return;

	LastUseCustomBots = MyUseCustomBots.IsChecked();
	SaveConfig();

	if(LastUseCustomBots)
		MyBotCount.MenuStateChange(MSAT_Disabled);
	else
		MyBotCount.MenuStateChange(MSAT_Blurry);

	OnChangeCustomBots();
}

function bool MapListDblClick(GUIComponent Sender)
{
	UT2InstantActionPage(Controller.ActivePage).PlayButtonClick(self);
	return true;
}

defaultproperties
{
     DifficultyLevels(0)="Novice"
     DifficultyLevels(1)="Average"
     DifficultyLevels(2)="Experienced"
     DifficultyLevels(3)="Skilled"
     DifficultyLevels(4)="Adept"
     DifficultyLevels(5)="Masterful"
     DifficultyLevels(6)="Inhuman"
     DifficultyLevels(7)="Godlike"
     MessageNoInfo="No information available!"
     Begin Object Class=GUIImage Name=IAMainBK1
         Image=Texture'InterfaceContent.Menu.BorderBoxD'
         ImageColor=(A=160)
         ImageStyle=ISTY_Stretched
         ImageRenderStyle=MSTY_Normal
         WinTop=0.024687
         WinLeft=0.021641
         WinWidth=0.957500
         WinHeight=0.107188
     End Object
     Controls(0)=GUIImage'XInterface.Tab_InstantActionMain.IAMainBK1'

     Begin Object Class=moNumericEdit Name=IAMain_BotCount
         MinValue=0
         MaxValue=16
         Caption="Number of Bots"
         OnCreateComponent=IAMain_BotCount.InternalOnCreateComponent
         Hint="Choose the number of bots you wish to play with."
         WinTop=0.919531
         WinLeft=0.038476
         WinWidth=0.450000
         WinHeight=0.060000
     End Object
     Controls(1)=moNumericEdit'XInterface.Tab_InstantActionMain.IAMain_BotCount'

     Begin Object Class=moComboBox Name=IAMain_GameType
         ComponentJustification=TXTA_Left
         CaptionWidth=0.300000
         Caption="Game Type:"
         OnCreateComponent=IAMain_GameType.InternalOnCreateComponent
         Hint="Select the type of game you wish to play."
         WinTop=0.047917
         WinLeft=0.250000
         WinHeight=0.060000
         OnChange=Tab_InstantActionMain.GameTypeChanged
     End Object
     Controls(2)=moComboBox'XInterface.Tab_InstantActionMain.IAMain_GameType'

     Begin Object Class=GUIListBox Name=IAMain_MapList
         bVisibleWhenEmpty=True
         OnCreateComponent=IAMain_MapList.InternalOnCreateComponent
         StyleName="SquareButton"
         Hint="Select the map to play"
         WinTop=0.161406
         WinLeft=0.021641
         WinWidth=0.478984
         WinHeight=0.463633
     End Object
     Controls(3)=GUIListBox'XInterface.Tab_InstantActionMain.IAMain_MapList'

     Begin Object Class=GUIImage Name=IAMain_MapImage
         Image=Texture'InterfaceContent.Menu.NoLevelPreview'
         ImageStyle=ISTY_Scaled
         ImageRenderStyle=MSTY_Normal
         WinTop=0.163489
         WinLeft=0.531796
         WinWidth=0.443750
         WinHeight=0.405312
     End Object
     Controls(4)=GUIImage'XInterface.Tab_InstantActionMain.IAMain_MapImage'

     Begin Object Class=GUIScrollTextBox Name=IAMain_MapScroll
         CharDelay=0.002500
         EOLDelay=0.500000
         OnCreateComponent=IAMain_MapScroll.InternalOnCreateComponent
         WinTop=0.689325
         WinLeft=0.534569
         WinWidth=0.435000
         WinHeight=0.300000
         bNeverFocus=True
     End Object
     Controls(5)=GUIScrollTextBox'XInterface.Tab_InstantActionMain.IAMain_MapScroll'

     Begin Object Class=GUIImage Name=IAMainBK3
         Image=Texture'InterfaceContent.Menu.BorderBoxD'
         ImageColor=(A=160)
         ImageStyle=ISTY_Stretched
         WinTop=0.650469
         WinLeft=0.020742
         WinWidth=0.480469
         WinHeight=0.348633
     End Object
     Controls(6)=GUIImage'XInterface.Tab_InstantActionMain.IAMainBK3'

     Begin Object Class=moComboBox Name=IAMain_BotSkill
         Caption="Bot Skill"
         OnCreateComponent=IAMain_BotSkill.InternalOnCreateComponent
         Hint="Choose the skill of the bots you wish to play with."
         WinTop=0.689531
         WinLeft=0.038476
         WinWidth=0.450000
         WinHeight=0.060000
         OnChange=Tab_InstantActionMain.BotSkillChanged
     End Object
     Controls(7)=moComboBox'XInterface.Tab_InstantActionMain.IAMain_BotSkill'

     Begin Object Class=moCheckBox Name=IAMain_UseMapBots
         ComponentJustification=TXTA_Left
         CaptionWidth=0.900000
         Caption="Use Map Bot Count"
         OnCreateComponent=IAMain_UseMapBots.InternalOnCreateComponent
         Hint="When enabled, an appropriate number of bots for the map will be used."
         WinTop=0.769531
         WinLeft=0.038476
         WinWidth=0.450000
         WinHeight=0.060000
         OnChange=Tab_InstantActionMain.ChangeMapBots
     End Object
     Controls(8)=moCheckBox'XInterface.Tab_InstantActionMain.IAMain_UseMapBots'

     Begin Object Class=moCheckBox Name=IAMain_UseCustomBots
         ComponentJustification=TXTA_Left
         CaptionWidth=0.900000
         Caption="Use Custom Bots"
         OnCreateComponent=IAMain_UseCustomBots.InternalOnCreateComponent
         Hint="When enabled, you may use the Bot tab to choose bots to play with."
         WinTop=0.849531
         WinLeft=0.038476
         WinWidth=0.450000
         WinHeight=0.060000
         OnChange=Tab_InstantActionMain.ChangeCustomBots
     End Object
     Controls(9)=moCheckBox'XInterface.Tab_InstantActionMain.IAMain_UseCustomBots'

     Begin Object Class=GUIImage Name=IAMainBK2
         Image=Texture'InterfaceContent.Menu.BorderBoxA1'
         ImageColor=(A=160)
         ImageStyle=ISTY_Stretched
         ImageRenderStyle=MSTY_Normal
         WinTop=0.161406
         WinLeft=0.527891
         WinWidth=0.450000
         WinHeight=0.410000
     End Object
     Controls(10)=GUIImage'XInterface.Tab_InstantActionMain.IAMainBK2'

     Begin Object Class=GUIImage Name=IAMain_DescBack
         Image=Texture'InterfaceContent.Menu.BorderBoxD'
         ImageColor=(A=160)
         ImageStyle=ISTY_Stretched
         ImageRenderStyle=MSTY_Normal
         WinTop=0.591354
         WinLeft=0.527891
         WinWidth=0.450000
         WinHeight=0.410000
     End Object
     Controls(11)=GUIImage'XInterface.Tab_InstantActionMain.IAMain_DescBack'

     Begin Object Class=GUILabel Name=IAMain_MapName
         Caption="Testing"
         TextAlign=TXTA_Center
         TextColor=(B=0,G=180,R=220)
         TextFont="UT2HeaderFont"
         WinTop=0.596822
         WinLeft=0.562304
         WinWidth=0.382813
         WinHeight=32.000000
     End Object
     Controls(12)=GUILabel'XInterface.Tab_InstantActionMain.IAMain_MapName'

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
     Controls(13)=GUILabel'XInterface.Tab_InstantActionMain.IAMain_MapAuthor'

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
     Controls(14)=GUILabel'XInterface.Tab_InstantActionMain.IAMain_MapPlayers'

     WinTop=0.150000
     WinHeight=0.770000
}
