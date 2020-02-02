// ====================================================================
// (C) 2002, Epic Games
// ====================================================================

class UT2K4Demos extends ModsAndDemosTabs;

var automated GUIListBox lb_DemoList,lb_DemoInfo;
var automated GUIScrollTextBox lb_ReqPacks;
var automated GUILabel lbl_Game, l_NoPreview;
var automated GUIImage i_MapShot;
var automated GUISectionBackground sb_1, sb_2, sb_3, sb_4;

var localized string ltScoreLimit, ltTimeLimit, UnknownText, CorruptDemText,ltSelectMsg;
var localized string ltClientSide, ltServerSide, ltRecordedBy,ltGoodMsg, ltBadMsg;
var array<CacheManager.MapRecord> Maps;
var array<CacheManager.GameRecord> Games;

function InitComponent(GUIController MyController, GUIComponent MyOwner)
{
	local array<string> Demos;
    local int i;

	Super.InitComponent(MyController,MyOwner);

	class'CacheManager'.static.GetMapList(Maps);
	class'CacheManager'.static.GetGameTypeList(Games);

    MyController.GetDEMList(Demos);
    for (i=0;i<Demos.Length;i++)
    	lb_DemoList.List.Add(TrimName(Demos[i]));

	bInit = False;
    if (lb_DemoList.ItemCount()>0)
	    DemoListClick(none);

	MyPage.MyFooter.b_Watch.OnClick=WatchClick;
	MyPage.MyFooter.b_Dump.OnClick=DumpClick;

	sb_1.ManageComponent(lb_DemoList);
	sb_2.Managecomponent(i_MapShot);
	sb_3.ManageComponent(lb_ReqPacks);
}

function string TrimName(string s)
{
	local int p;
	p = InStr(Caps(s),".DEMO4");
	if (p>=0)
		return Left(s,p);

	return s;
}

function bool DumpClick(GUIComponent Sender)
{
	Controller.OpenMenu("GUI2K4.UT2K4Demo2AVI",lb_DemoList.List.Get());
    return true;
}

function bool WatchClick(GUIComponent Sender)
{
	Console(Controller.Master.Console).DelayedConsoleCommand("demoplay"@lb_DemoList.List.Get());
    return true;
}


function DemoListClick(GUIComponent Sender)
{
	local string MapName, GameType, RecordedBy, TimeStamp,ReqPackages;
    local int	 i, ScoreLimit, TimeLimit, ClientSide;
    local Material Screenie;

	if ( bInit )
		return;

	lb_DemoInfo.List.Clear();
	if ( LB_DemoList.List.ItemCount<=0 )
	{
		lbl_Game.Caption = "";
		sb_2.Caption = "";
		lb_ReqPacks.SetContent("");
		i_MapShot.SetVisibility( false);
		l_NoPreview.SetVisibility( true );
		return;
	}

	if ( Controller.GetDEMHeader(lb_DemoList.List.Get( True )$".DEMO4",MapName,GameType,ScoreLimit,TimeLimit,ClientSide,RecordedBy,TimeStamp,ReqPackages) )
    {
    	lbl_Game.Caption=Caps(MapName);
    	i = GetGameIndex(GameType);

    	if ( i != -1 )
    		sb_2.Caption = Games[i].GameName;
		else sb_2.Caption = UnknownText;

		lb_DemoInfo.List.Add(ltScoreLimit@ScoreLimit@"  "@ltTimeLimit@TimeLimit);

        if (ClientSide!=0)
	        lb_DemoInfo.List.Add(ltClientSide);
    	else
	    	lb_DemoInfo.List.Add(ltServerSide);

       	lb_DemoInfo.List.Add(ltRecordedBy@RecordedBy);

        if (ReqPackages!="")
        	lb_ReqPacks.SetContent(ltBadMsg$"||"$ReqPackages);
        else
        	lb_ReqPacks.SetContent(ltGoodMsg);

		i = GetMapIndex(MapName);
		if ( i != -1 )
			Screenie = Material(DynamicLoadObject(Maps[i].ScreenshotRef, class'Material'));

    }
    else
    {
    	sb_2.Caption="";
        lbl_Game.Caption=UnknownText;
    	lb_DemoInfo.List.Clear();
    	lb_ReqPacks.SetContent(CorruptDemText);
    }

    i_MapShot.Image = Screenie;
	i_MapShot.SetVisibility( Screenie != None );
	l_NoPreview.SetVisibility( Screenie == None );

    lb_ReqPacks.Restart();
    lb_ReqPacks.Stop();

    return;
}

function SetVisibility( bool bIsVisible )
{
	Super.SetVisibility(bIsVisible);

	i_MapShot.SetVisibility( i_MapShot.Image != none );
	l_NoPreview.SetVisibility( i_MapShot.Image == None );
}

function int GetMapIndex( string MapName )
{
	local int i;

	for ( i = 0; i < Maps.Length; i++ )
		if ( Maps[i].MapName ~= MapName )
			return i;

	return -1;
}

function int GetGameIndex( string GameClass )
{
	local int i;

	for ( i = 0; i < Games.Length; i++ )
		if ( Games[i].ClassName ~= GameClass || GameClass ~= ("class " $ Games[i].ClassName ) )
			return i;

	return -1;
}

function InfoClick(GUIComponent Sender)
{
	lb_DemoInfo.List.Index=0;
}

defaultproperties
{
     Begin Object Class=GUIListBox Name=lbDemoList
         SelectedStyleName="NoBackground"
         SectionStyleName="NoBackground"
         OutlineStyleName="NoBackground"
         bVisibleWhenEmpty=True
         OnCreateComponent=lbDemoList.InternalOnCreateComponent
         WinTop=0.109375
         WinLeft=0.030468
         WinWidth=0.265626
         WinHeight=0.735548
         TabOrder=0
         OnChange=UT2K4Demos.DemoListClick
     End Object
     lb_DemoList=GUIListBox'GUI2K4.UT2K4Demos.lbDemoList'

     Begin Object Class=GUIListBox Name=lbDemoInfo
         bVisibleWhenEmpty=True
         OnCreateComponent=lbDemoInfo.InternalOnCreateComponent
         WinTop=0.155622
         WinLeft=0.529180
         WinWidth=0.276054
         WinHeight=0.078998
         bAcceptsInput=False
         OnChange=UT2K4Demos.InfoClick
     End Object
     lb_DemoInfo=GUIListBox'GUI2K4.UT2K4Demos.lbDemoInfo'

     Begin Object Class=GUIScrollTextBox Name=lbReqPacks
         bNoTeletype=True
         bVisibleWhenEmpty=True
         OnCreateComponent=lbReqPacks.InternalOnCreateComponent
         WinTop=0.650090
         WinLeft=0.310547
         WinWidth=0.650391
         WinHeight=0.193555
         TabOrder=2
     End Object
     lb_ReqPacks=GUIScrollTextBox'GUI2K4.UT2K4Demos.lbReqPacks'

     Begin Object Class=GUILabel Name=lblGame
         TextAlign=TXTA_Center
         TextColor=(B=0,G=200,R=230)
         TextFont="UT2LargeFont"
         WinTop=0.103929
         WinLeft=0.355370
         WinWidth=0.634467
         WinHeight=0.061558
         RenderWeight=0.600000
     End Object
     lbl_Game=GUILabel'GUI2K4.UT2K4Demos.lblGame'

     Begin Object Class=GUILabel Name=NoPreview
         Caption="No Preview Available"
         TextAlign=TXTA_Center
         TextColor=(B=0,G=255,R=247)
         TextFont="UT2HeaderFont"
         bTransparent=False
         bMultiLine=True
         VertAlign=TXTA_Center
         WinTop=0.286842
         WinLeft=0.517749
         WinWidth=0.318399
         WinHeight=0.226862
         RenderWeight=1.000000
     End Object
     l_NoPreview=GUILabel'GUI2K4.UT2K4Demos.NoPreview'

     Begin Object Class=GUIImage Name=iMapShot
         ImageStyle=ISTY_Scaled
         ImageRenderStyle=MSTY_Normal
         DropShadowX=8
         DropShadowY=8
         WinTop=0.199687
         WinLeft=0.619686
         WinWidth=0.326562
         WinHeight=0.288124
         RenderWeight=1.000000
     End Object
     i_MapShot=GUIImage'GUI2K4.UT2K4Demos.iMapShot'

     Begin Object Class=GUISectionBackground Name=sb1
         bFillClient=True
         Caption="Demos"
         BottomPadding=0.200000
         WinTop=0.012761
         WinLeft=0.012527
         WinWidth=0.328364
         WinHeight=0.962274
         RenderWeight=0.500000
         OnPreDraw=sb1.InternalPreDraw
     End Object
     sb_1=GUISectionBackground'GUI2K4.UT2K4Demos.sb1'

     Begin Object Class=AltSectionBackground Name=sb2
         bFillClient=True
         WinTop=0.228215
         WinLeft=0.492837
         WinWidth=0.368224
         WinHeight=0.346441
         RenderWeight=0.500000
         OnPreDraw=sb2.InternalPreDraw
     End Object
     sb_2=AltSectionBackground'GUI2K4.UT2K4Demos.sb2'

     Begin Object Class=GUISectionBackground Name=sb3
         bFillClient=True
         Caption="Required Packages"
         BottomPadding=0.200000
         WinTop=0.656193
         WinLeft=0.354323
         WinWidth=0.637278
         WinHeight=0.318539
         RenderWeight=0.500000
         OnPreDraw=sb3.InternalPreDraw
     End Object
     sb_3=GUISectionBackground'GUI2K4.UT2K4Demos.sb3'

     Begin Object Class=AltSectionBackground Name=iInfoBk
         HeaderBase=Texture'2K4Menus.NewControls.Display2'
         Caption="... Information ..."
         WinTop=0.011296
         WinLeft=0.354323
         WinWidth=0.637278
         WinHeight=0.629445
         RenderWeight=0.200000
         OnPreDraw=iInfoBk.InternalPreDraw
     End Object
     sb_4=AltSectionBackground'GUI2K4.UT2K4Demos.iInfoBk'

     ltScoreLimit="Score Limit:"
     ltTimeLimit="Time Limit:"
     UnknownText="Unknown"
     CorruptDemText="Corrupted or missing .DEMO4 file !"
     ltSelectMsg="Please select a demo from the list to the left."
     ltClientSide="Client Side Demo"
     ltServerSide="Server Side/Single Player Demo"
     ltRecordedBy="Recorded By:"
     ltGoodMsg="All of the packages required for this demo are installed"
     ltBadMsg="In order to be played, this demo requires the packages listed below.  If you are connected to the Internet, they will be autodownloaded when the demo is played||::Required Packages::"
     Tag=3
}
