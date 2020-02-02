class LevelGameRules extends Info
    placeable;

// allows level designers to override game settings
var()   array< class<Mutator> > MapMutator;

function PreBeginPlay()
{
}

function UpdateGame(GameInfo G)
{
    local int i;

    if (MapMutator.Length > 0)
    {
        for (i=0; i<MapMutator.Length; i++)
            G.AddMutator(string(MapMutator[i]));
    }
}

defaultproperties
{
}
