// ====================================================================
// (C) 2002, Epic Games
// ====================================================================

class STY_ListSelection extends GUIStyles;

event Initialize()
{
    local int i;

    super.Initialize();

    for (i=0;i<5;i++)
        Images[i]=Controller.DefaultPens[0];
}

defaultproperties
{
     KeyName="ListSelection"
}
