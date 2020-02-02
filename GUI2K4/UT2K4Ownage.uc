// ====================================================================
// (C) 2002, Epic Games
// ====================================================================

class UT2K4Ownage extends ModsAndDemosTabs;

var automated GUISectionBackground sb_1, sb_2;

var automated GUIListBox lb_MapList;
var automated GUIScrollTextBox lb_MapInfo;
var automated GUIImage i_Background;
var automated GUIImage i_FileFront;
var automated GUILabel l_FileFront;


var int    								OwnageLevel;
var array<GUIController.eOwnageMap> 	OwnageMaps;

var material FFTex;

function InitComponent(GUIController MyController, GUIComponent MyOwner)
{
	local int i,j;
    local array<int> RLevel;
    local array<string> MName;
    local array<string> MDesc;
    local array<string> MURL;
    Super.InitComponent(MyController, MyOwner);

	Controller.GetOwnageList(RLevel, MName, MDesc, MURL);

	for (i=0;i<RLevel.Length;i++)
    {
		j = OwnageMaps.Length;
        OwnageMaps.Length = OwnageMaps.Length+1;
        OwnageMaps[j].RLevel  = RLevel[i];
        OwnageMaps[j].MapName = MName[i];
        OwnageMaps[j].MapDesc = MDesc[i];
        OwnageMaps[j].MapURL  = MURL[i];

		if (OwnageMaps[j].RLevel > OwnageLevel)
        	OwnageLevel = OwnageMaps[j].RLevel;

    }

    sb_1.ManageComponent(lb_MapList);
    sb_2.ManageComponent(lb_MapInfo);

	PrimeMapList();
    lb_MapList.List.SetIndex(0);
    ListOnChange(lb_MapList);

    MyPage.MyFooter.b_Download.OnClick=DownloadClick;

	FFTex = material(DynamicLoadObject("jwfasterfiles.FF1",class'Texture',true));
	i_FileFront.Image = FFTex;

}

function PrimeMapList()
{
	local int i;
    lb_MapList.List.Clear();
    for (i=0;i<OwnageMaps.Length;i++)
    	lb_MapList.List.Add(OwnageMaps[i].MapName,,string(i));
}

function bool DownloadClick(GUIComponent Sender)
{
	local int index;
	local string url;

    Index = int(lb_MapList.List.GetExtra() );
	url = OwnageMaps[Index].MapURL;

    if (url!="")
    	Controller.LaunchURL(Url);

    return true;
}

function bool GotoFF(GUIComponent Sender)
{
	Controller.LaunchURL("http://www.fasterfiles.com");
	return true;
}

Function ListOnChange(GUIComponent Sender)
{
	local int i;

    i = int(lb_MapList.List.GetExtra());
    lb_MapInfo.SetContent(OwnageMaps[i].MapDesc,"|");
}

function AddMap(int Level, string mName, string mDesc, string mURL)
{
	local int i,Index;

    Index = -1;
    for (i=0;i<OwnageMaps.Length;i++)
    	if (OwnageMaps[i].RLevel == Level)
        	Index = i;

	if (Index==-1)
    {
    	Index = OwnageMaps.Length;
        OwnageMaps.Length = OwnageMaps.Length+1;
        OwnageMaps[Index].RLevel = Level;
    }

	if (mName!="")
    	OwnageMaps[Index].MapName = mName;

    if (mDesc!="")
    	OwnageMaps[Index].MapDesc = OwnageMaps[Index].MapDesc$mDesc;

    if (mURL!="")
    	OwnageMaps[Index].MapURL = mUrl;

	Controller.SaveOwnageList(OwnageMaps);
    PrimeMapList();
}

defaultproperties
{
     Begin Object Class=GUISectionBackground Name=sb1
         bFillClient=True
         Caption="Ownage Maps"
         BottomPadding=0.200000
         WinTop=0.012761
         WinLeft=0.012527
         WinWidth=0.408084
         WinHeight=0.831136
         RenderWeight=0.010000
         OnPreDraw=sb1.InternalPreDraw
     End Object
     sb_1=GUISectionBackground'GUI2K4.UT2K4Ownage.sb1'

     Begin Object Class=AltSectionBackground Name=sb2
         bFillClient=True
         Caption="Map Details"
         WinTop=0.012761
         WinLeft=0.431054
         WinWidth=0.562541
         WinHeight=0.971442
         RenderWeight=0.010000
         OnPreDraw=sb2.InternalPreDraw
     End Object
     sb_2=AltSectionBackground'GUI2K4.UT2K4Ownage.sb2'

     Begin Object Class=GUIListBox Name=lbMapList
         bVisibleWhenEmpty=True
         OnCreateComponent=lbMapList.InternalOnCreateComponent
         WinTop=0.109375
         WinLeft=0.030468
         WinWidth=0.265626
         WinHeight=0.735548
         TabOrder=0
         OnChange=UT2K4Ownage.ListOnChange
     End Object
     lb_MapList=GUIListBox'GUI2K4.UT2K4Ownage.lbMapList'

     Begin Object Class=GUIScrollTextBox Name=lbMapInfo
         bNoTeletype=True
         bVisibleWhenEmpty=True
         OnCreateComponent=lbMapInfo.InternalOnCreateComponent
         WinTop=0.109725
         WinLeft=0.305664
         WinWidth=0.655274
         WinHeight=0.735548
         TabOrder=1
     End Object
     lb_MapInfo=GUIScrollTextBox'GUI2K4.UT2K4Ownage.lbMapInfo'

     Begin Object Class=GUIImage Name=iFF
         ImageStyle=ISTY_Scaled
         WinTop=0.857116
         WinLeft=0.019133
         WinWidth=0.393622
         WinHeight=0.130000
         bAcceptsInput=True
         OnClick=UT2K4Ownage.GotoFF
     End Object
     i_FileFront=GUIImage'GUI2K4.UT2K4Ownage.iFF'

     Tag=2
}
