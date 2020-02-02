// ====================================================================
//  Class:  XInterface.Tab_IACaptureTheFlag
//  Parent: XInterface.Tab_InstantActionBaseRules
//
//  <Enter a description here>
// ====================================================================

class Tab_IACaptureTheFlag extends Tab_InstantActionBaseRules;

var localized string	GoalScoreText;

function InitComponent(GUIController MyController, GUIComponent MyOwner)
{
	Super.Initcomponent(MyController, MyOwner);
	MyGoalScore.MyLabel.Caption = GoalScoreText;
	MyMaxLives.bVisible = false;
}

defaultproperties
{
     GoalScoreText="Capture Limit"
}
