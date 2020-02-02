class GUIVertScrollButton extends GUIScrollButtonBase;

function InitComponent(GUIController MyController, GUIComponent MyOwner)
{
	if (bIncreaseButton)
    {
    	StyleName="VertDownButton";
		ImageIndex = 7;
    }

	Super.Initcomponent(MyController, MyOwner);
}

defaultproperties
{
     ImageIndex=6
     StyleName="VertUpButton"
}
