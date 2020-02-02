// ====================================================================
// (C) 2002, Epic Games
// ====================================================================
 
class TAB_IAInvasion extends Tab_IATeamDeathMatch;

function InitComponent(GUIController MyController, GUIComponent MyOwner)
{
    local moNumericEdit a;
    local GUINumericEdit b;

    Super.InitComponent(MyController, MyOwner);

    Controls[14].WinTop = 0.765899;
	Controls[15].WinTop = 0.823138;
	Controls[15].WinLeft = 0.121094;

    Controls[11].MenuStateChange(MSAT_Disabled);

    a = moNumericEdit(Controls[16]);
    a.SetValue(class'invasion'.default.InitialWave+1);
    b = a.MyNumericEdit;
    GUIEditBox(b.Controls[0]).bReadOnly = true;

}

function WaveChange(GUIComponent Sender)
{
	class'invasion'.default.InitialWave = moNumericEdit(Controls[16]).GetValue()-1;
    class'invasion'.static.staticsaveconfig();
}

function bool ConfigClicked(GUIComponent Sender)
{
	Controller.OpenMenu("SkaarjPack.InvasionWaveConfig");
	return true;
}

defaultproperties
{
     Begin Object Class=moNumericEdit Name=IAInvasionInitialWave
         MinValue=1
         MaxValue=16
         Caption="Initial Wave"
         OnCreateComponent=IAInvasionInitialWave.InternalOnCreateComponent
         Hint="Choose the initial wave."
         WinTop=0.823138
         WinLeft=0.605469
         WinWidth=0.250000
         WinHeight=0.060000
         OnChange=TAB_IAInvasion.WaveChange
     End Object
     Controls(16)=moNumericEdit'SkaarjPack.TAB_IAInvasion.IAInvasionInitialWave'

     Begin Object Class=GUIButton Name=IAInvasionWaveConfig
         Caption="Configure Waves"
         StyleName="SquareMenuButton"
         WinTop=0.932031
         WinLeft=0.383789
         WinWidth=0.231250
         WinHeight=0.068750
         OnClick=TAB_IAInvasion.ConfigClicked
         OnKeyEvent=IAInvasionWaveConfig.InternalOnKeyEvent
     End Object
     Controls(17)=GUIButton'SkaarjPack.TAB_IAInvasion.IAInvasionWaveConfig'

}
