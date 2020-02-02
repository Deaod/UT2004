// ====================================================================
//  Class:  XInterface.Tab_IADeathMatch
//  Parent: XInterface.Tab_InstantActionBaseRules
//
//  <Enter a description here>
// ====================================================================

class Tab_IADeathMatch extends Tab_InstantActionBaseRules;

var config bool	LastAutoAdjustSkill;

var localized string	GoalScoreText;

function InitComponent(GUIController MyController, GUIComponent MyOwner)
{
	Super.Initcomponent(MyController, MyOwner);
	MyGoalScore.MyLabel.Caption = GoalScoreText;

	moCheckBox(Controls[15]).Checked(LastAutoAdjustSkill);
}

function string Play()
{
	LastAutoAdjustSkill = moCheckBox(Controls[15]).IsChecked();
	SaveConfig();

	return Super.Play()$"?AutoAdjust="$LastAutoAdjustSkill;
}

defaultproperties
{
     GoalScoreText="Frag Limit"
     Begin Object Class=GUIImage Name=IARulesBK4
         Image=Texture'InterfaceContent.Menu.BorderBoxD'
         ImageColor=(A=160)
         ImageStyle=ISTY_Stretched
         WinTop=0.785430
         WinLeft=0.021641
         WinWidth=0.957500
         WinHeight=0.156016
     End Object
     Controls(14)=GUIImage'XInterface.Tab_IADeathMatch.IARulesBK4'

     Begin Object Class=moCheckBox Name=IARulesAutoAdjustSkill
         ComponentJustification=TXTA_Left
         CaptionWidth=0.900000
         Caption="Auto-Adjust Skill"
         OnCreateComponent=IARulesAutoAdjustSkill.InternalOnCreateComponent
         Hint="When enabled, bots will adjust their skill to match yours."
         WinTop=0.858295
         WinLeft=0.375000
         WinWidth=0.250000
         WinHeight=0.156016
     End Object
     Controls(15)=moCheckBox'XInterface.Tab_IADeathMatch.IARulesAutoAdjustSkill'

}
