//==============================================================================
//	Each InstantActionRulesPanel handles PlayInfo settings for a single PlayInfo group.
//
//	Created by Ron Prestenback
//	© 2003, Epic Games, Inc.  All Rights Reserved
//==============================================================================
class InstantActionRulesPanel extends UT2K4PlayInfoPanel;

var UT2K4GameTabBase tp_Anchor;
var UT2K4GamePageBase	p_Anchor;

function ClearRules()
{
	local int i, j;

	for (i = 0; i < li_Rules.Elements.Length; i++)
	{
		for (j = 0; j < InfoRules.Length; j++)
			if (InfoRules[j].DisplayName == li_Rules.Elements[i].Caption)
				break;

		if (j == InfoRules.Length)
			li_Rules.RemoveItem(i--);
	}
}

function LoadRules()
{
	local int i;
//log(Name@"LoadRules()");
	for (i = 0; i < InfoRules.Length; i++)
		AddRule(InfoRules[i], i);

	Super.LoadRules();
}

defaultproperties
{
     Begin Object Class=GUIMultiOptionListBox Name=RuleListBox
         OnCreateComponent=RuleListBox.InternalOnCreateComponent
         WinHeight=1.000000
         TabOrder=0
         bBoundToParent=True
         bScaleToParent=True
         OnChange=InstantActionRulesPanel.InternalOnChange
     End Object
     lb_Rules=GUIMultiOptionListBox'GUI2K4.InstantActionRulesPanel.RuleListBox'

}
