// Contains common fonctionality for Ladder Pages
///////////////////////////////////////////////////

class Tab_SPLadderBase extends Tab_SPPanelBase;

var GUIScrollTextBox    ScrollInfo;
var GUIImage            MapPicHolder;
var GUILabel            MapNameLabel;
var LadderButton        ActiveLadderButton;

function UpdateLadderButton(LadderButton Btn, int LadderIndex, int MatchIndex)
{
local GameProfile GP;

    GP = PlayerOwner().Level.Game.CurrentGameProfile;
    if (GP != None)
    {
        if (Btn.MatchInfo == None)
        {
            Btn.MatchInfo = GP.GetMatchInfo(LadderIndex, MatchIndex);
            Btn.MatchIndex = MatchIndex;
            Btn.LadderIndex = LadderIndex;
        }
        Btn.SetState(GP.LadderRung[LadderIndex]);
    }
    else
        Btn.SetState(-1);
}

function LadderButton NewLadderButton(int LadderIndex, int MatchIndex, float Left, float Top)
{
local LadderButton Btn;

    Btn = new class'LadderButton';
    Btn.WinLeft = Left;
    Btn.WinWidth = 0.090234;
    Btn.WinHeight = 0.113672;
    Btn.WinTop = Top;
    Btn.OnClick=MatchButtonClick;
    Btn.OnDblClick=MatchDoubleClick;
    Btn.InitComponent(Controller, Self);
    Controls[Controls.Length] = Btn;
    UpdateLadderButton(Btn, LadderIndex, MatchIndex);
    return Btn;
}

function bool SetActiveMatch(int ladder, out array<LadderButton> Btns)
{
local int Rung;

    Rung = GetProfile().LadderRung[ladder];
    if (Rung < 0 || Rung >= Btns.Length)
    {
        return false;
    }

    if (GetProfile().FindFirstUnfinishedLadder() == ladder)
        Btns[Rung].OnClick(Btns[Rung]);
    else
        ShowMatchInfo(Btns[Rung].MatchInfo);

    return true;
}

// send DoShowMatchInfo to all ladder pages, keeps the images selected
function bool ShowMatchInfo(MatchInfo MI)
{
local GUITabControl TC;
local int i;
local bool retval;

    retval = true;
    TC = MyTabControl();
    if ( MI != None && TC != None )
    {
        for (i = 0; i<TC.Controls.Length; i++)
        {
            if (Tab_SPLadderBase(TC.Controls[i]) != None)
            {
                retval = retval && Tab_SPLadderBase(TC.Controls[i]).DoShowMatchInfo ( MI );
            }
        }
        return retval;
    }

    return false;
}

function bool DoShowMatchInfo(MatchInfo MI) {
local LevelSummary L;
local Material Screenshot;
local string s,mName;
local int p;

    if ( MI == none ) {
        return false;
    }

    // Load MapShot
    L = LevelSummary(DynamicLoadObject(MI.LevelName$".LevelSummary", class'LevelSummary'));

    p = instr(MI.LevelName,"-");
    if (p<0)
        mName = MI.LevelName;
    else
        mName = Right(MI.LevelName,Len(MI.LevelName)-p-1);

    Screenshot = Material(DynamicLoadObject("MapThumbnails.Shot"$mName, class'Material'));

    if (Screenshot==None)
    {
        Screenshot = Material(DynamicLoadObject(MI.LevelName$".Screenshot", class'Material'));
    }
    if (Screenshot==None)
    {
        if (L.ScreenShot==None)
            Screenshot = Material'InterfaceContent.Menu.NoLevelPreview';
        else
            Screenshot = L.Screenshot;
    }
    MapPicHolder.Image = Screenshot;

    if ( MapPicHolder.Image == None )
    {
        MapPicHolder.Image = Material'InterfaceContent.Menu.NoLevelPreview';
    }

    // Set Scroll Content
    s = Controller.LoadDecoText("XMaps",mName);

    ScrollInfo.SetContent(S$class'Tab_IABombingRun'.default.GoalScoreText$":"@int(MI.GoalScore));

    // Set MapName Label
    if ( MI.MenuName != "" )   // replace mapname with menuname if exists
        MapNameLabel.Caption = MI.MenuName;
    else
        MapNameLabel.Caption = L.Title;

    return true;
}

function bool MatchButtonClick(GUIComponent Sender)
{
local LadderButton LButton;
local GameProfile GP;

    GP = GetProfile();
    if ( GP != None && LadderButton(Sender) != None )
    {
        ShowMatchInfo(LadderButton(Sender).MatchInfo);
        LButton=LadderButton(GP.NextMatchObject);
        if (LButton != None)        // Reset to non active state
            LButton.SetState(GP.LadderRung[LButton.LadderIndex]);
        LButton=LadderButton(Sender);
        GP.CurrentLadder = LButton.LadderIndex;
        GP.CurrentMenuRung = LButton.MatchIndex;
        GP.NextMatchObject = LButton;
        LButton.StyleName = "LadderButtonActive";
        LButton.Style = Controller.GetStyle(LButton.StyleName,LButton.FontScale);
        MatchUpdated(LButton.LadderIndex, LButton.MatchIndex);
        if ( GetProfile().ChampBorderObject != none )
            GUIImage(GetProfile().ChampBorderObject).bVisible=false;
    }
    return true;
}

// quick way of hitting 'play'
function bool MatchDoubleClick(GUIComponent Sender)
{
    local UT2SinglePlayerMain SPM;
    // no need to call single button click (matchbuttonclick) first, apparently
    SPM = UT2SinglePlayerMain(MyButton.MenuOwner.MenuOwner);
    return SPM.ButtonClick(SPM.ButtonPlay);
}

function int SetYellowBar(int ladder, int index, out array<LadderButton> Buttons)
{
local int Rung;
local GUIComponent Ctrl;

    Ctrl = Controls[index];

    if (GetProfile() != None)
        Rung = GetProfile().LadderRung[ladder];
    else
        Rung = -1;

    // Reset Lock & Bars pictures
    if (Rung == -1)
    {
        Ctrl.bVisible=false;
    }
    else if (Rung >= Buttons.Length)
    {
        Ctrl.WinTop = Controls[index-1].WinTop;
        Ctrl.WinHeight = Controls[index-1].WinHeight;
        Ctrl.bVisible = true;
        return 1;
    }
    else
    {
        Ctrl.WinTop = Buttons[Rung].WinTop + Buttons[Rung].WinHeight/2;
        Ctrl.WinHeight = Buttons[0].WinTop - Ctrl.WinTop;
        Ctrl.bVisible = true;
    }
    return 0;
}

function bool CanShowPanel()
{
    if ( GetProfile() == none )
        return false;

    return super.CanShowPanel();
}

function Material DLOMaterial(string MaterialFullName)
{
    return Material(DynamicLoadObject(MaterialFullName, class'Material', true));
}

defaultproperties
{
}
