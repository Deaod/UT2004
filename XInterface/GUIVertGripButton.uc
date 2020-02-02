class GUIVertGripButton extends GUIGripButtonBase;

function InitComponent(GUIController MyController, GUIComponent MyComponent)
{
	Super(GUIButton).InitComponent(MyController, MyComponent);
}

defaultproperties
{
     StyleName="VertGrip"
}
