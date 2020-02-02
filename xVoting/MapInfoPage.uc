//====================================================================
//  xVoting.MapInfoPage
//  Map Information Page
//
//  Written by Bruce Bickar
//  (c) 2003, Epic Games, Inc.  All Rights Reserved
// ====================================================================
class MapInfoPage extends LockedFloatingWindow;

var automated GUISectionBackground	sb_Info;
var automated GUIScrollTextBox 		lb_MapDesc;
var automated GUIImage         		i_MapImage;
var automated GUILabel         		l_MapAuthor, l_MapPlayers, l_NoPreview;

var array<CacheManager.MapRecord> Maps;

var localized string MessageNoInfo, AuthorText, PlayerText, lmsgLevelPreviewUnavailable;
//------------------------------------------------------------------------------------------------
function InitComponent(GUIController MyController, GUIComponent MyOwner)
{
	Super.Initcomponent(MyController, MyOwner);

    b_Cancel.SetVisibility(false);
	sb_Main.SetPosition(0.042302,0.043286,0.917083,0.451979);
	sb_Main.bBoundToParent=true;
	sb_Main.bScaletoParent=true;
	sb_Main.ManageComponent(i_MapImage);
	sb_Info.Managecomponent(lb_MapDesc);
	sb_Info.bBoundToParent=true;
	sb_Info.bScaletoParent=true;

	class'CacheManager'.static.GetMapList( Maps );
}
//------------------------------------------------------------------------------------------------
function HandleParameters(string Param1, string Param2)
{
    ReadMapInfo(Param1);
}
//------------------------------------------------------------------------------------------------
function ReadMapInfo(string MapName)
{
    local DecoText DText;
    local string mDesc;
    local int Index, i;
    local Material Screenie;
    local string Package, Item;

    if(MapName == "")
        return;

    if (!Controller.bCurMenuInitialized)
        return;

	MapName = StripMapName(MapName);
    Index = FindCacheRecordIndex(MapName);

    if (Maps[Index].FriendlyName != "")
        sb_Main.Caption = Maps[Index].FriendlyName;
    else
		sb_Main.Caption = MapName;

	if ( Maps[Index].ScreenshotRef != "" )
	    Screenie = Material(DynamicLoadObject(Maps[Index].ScreenshotRef, class'Material'));
    i_MapImage.Image = Screenie;

    l_NoPreview.SetVisibility( Screenie == None );
    i_MapImage.SetVisibility( Screenie != None );

    l_MapPlayers.Caption = Maps[Index].PlayerCountMin@"-"@Maps[Index].PlayerCountMax@PlayerText;

	if ( class'CacheManager'.static.Is2003Content(Maps[Index].MapName) )
	{
		if ( Maps[i].TextName != "" )
		{
			if ( !Divide(Maps[Index].TextName, ".", Package, Item) )
			{
				Package = "XMaps";
				Item = Maps[Index].TextName;
			}
			DText = class'xUtil'.static.LoadDecoText( Package, Item );
		}
	}

    if (DText != None)
    {
        for (i = 0; i < DText.Rows.Length; i++)
        {
            if (mDesc != "")
                mDesc $= "|";
            mDesc $= DText.Rows[i];
        }
    }

    else mDesc = Maps[Index].Description;

    if (mDesc == "")
        mDesc = MessageNoInfo;

	lb_MapDesc.SetContent( mDesc );
    if (Maps[Index].Author != "")
        l_MapAuthor.Caption = AuthorText$":"@Maps[Index].Author;
    else l_MapAuthor.Caption = "";
}
//------------------------------------------------------------------------------------------------
// Remove any additional text from the map's name
// Used for getting just the mapname
function string StripMapName( string FullMapName )
{
	local int pos;

	pos = InStr(FullMapName, " ");
	if ( pos != -1 )
		FullMapName = Left(FullMapName, pos);

	return FullMapName;
}
//------------------------------------------------------------------------------------------------
function int FindCacheRecordIndex(string MapName)
{
    local int i;

    for (i = 0; i < Maps.Length; i++)
        if (Maps[i].MapName == MapName)
            return i;

    return -1;
}
//------------------------------------------------------------------------------------------------
function bool ReturnButtonOnClick(GUIComponent Sender)
{
	Controller.CloseMenu(true);
	return true;
}
//------------------------------------------------------------------------------------------------
function SetVisibility(bool bIsVisible)
{
	Super.SetVisibility(bIsVisible);

    l_NoPreview.SetVisibility( i_MapImage.Image == None );
    i_MapImage.SetVisibility( i_MapImage.Image != None );
}

defaultproperties
{
     Begin Object Class=GUISectionBackground Name=sbInfo
         bFillClient=True
         WinTop=0.514698
         WinLeft=0.045305
         WinWidth=0.918322
         WinHeight=0.374167
         OnPreDraw=sbInfo.InternalPreDraw
     End Object
     sb_Info=GUISectionBackground'xVoting.MapInfoPage.sbInfo'

     Begin Object Class=GUIScrollTextBox Name=MapInfoList
         CharDelay=0.002500
         EOLDelay=0.500000
         bVisibleWhenEmpty=True
         OnCreateComponent=MapInfoList.InternalOnCreateComponent
         WinTop=0.620235
         WinLeft=0.284888
         WinWidth=0.918322
         WinHeight=0.207500
         bTabStop=False
         bScaleToParent=True
         bNeverFocus=True
     End Object
     lb_MapDesc=GUIScrollTextBox'xVoting.MapInfoPage.MapInfoList'

     Begin Object Class=GUIImage Name=MapImage
         ImageStyle=ISTY_Scaled
         ImageRenderStyle=MSTY_Normal
         WinTop=0.173177
         WinLeft=0.281885
         WinWidth=0.917083
         WinHeight=0.451979
         RenderWeight=0.200000
         bScaleToParent=True
     End Object
     i_MapImage=GUIImage'xVoting.MapInfoPage.MapImage'

     Begin Object Class=GUILabel Name=MapAuthorLabel
         Caption="MapAuthor"
         TextAlign=TXTA_Center
         TextColor=(B=255,G=255,R=255)
         TextFont="UT2ServerListFont"
         WinTop=0.366257
         WinLeft=0.042804
         WinWidth=0.915313
         WinHeight=0.049359
         RenderWeight=0.300000
         bScaleToParent=True
     End Object
     l_MapAuthor=GUILabel'xVoting.MapInfoPage.MapAuthorLabel'

     Begin Object Class=GUILabel Name=MapPlayersLabel
         Caption="Players"
         TextAlign=TXTA_Center
         TextColor=(B=255,G=255,R=255)
         TextFont="UT2ServerListFont"
         WinTop=0.397652
         WinLeft=0.042804
         WinWidth=0.915313
         WinHeight=0.049359
         RenderWeight=0.300000
         bScaleToParent=True
     End Object
     l_MapPlayers=GUILabel'xVoting.MapInfoPage.MapPlayersLabel'

     Begin Object Class=GUILabel Name=NoPreview
         Caption="No Preview Available"
         TextAlign=TXTA_Center
         TextColor=(B=0,G=255,R=247)
         TextFont="UT2HeaderFont"
         bTransparent=False
         bMultiLine=True
         VertAlign=TXTA_Center
         WinTop=0.173177
         WinLeft=0.281885
         WinWidth=0.917083
         WinHeight=0.451979
         bScaleToParent=True
     End Object
     l_NoPreview=GUILabel'xVoting.MapInfoPage.NoPreview'

     MessageNoInfo="No information available!"
     AuthorText="Author"
     PlayerText="players"
     lmsgLevelPreviewUnavailable="Level Preview Unavailable"
     DefaultLeft=0.264063
     DefaultTop=0.077213
     DefaultWidth=0.468750
     DefaultHeight=0.801954
     bAllowedAsLast=True
     WinTop=0.077213
     WinLeft=0.264063
     WinWidth=0.468750
     WinHeight=0.801954
}
