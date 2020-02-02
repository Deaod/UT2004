class GUIHorzScrollButton extends GUIScrollButtonBase;

var()	bool	LeftButton;

function InitComponent(GUIController MyController, GUIComponent MyOwner)
{
	if (bIncreaseButton)
		ImageIndex = 3;

	Super.Initcomponent(MyController, MyOwner);
}

defaultproperties
{
     ImageIndex=2
}
