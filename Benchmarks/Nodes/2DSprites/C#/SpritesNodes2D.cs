using Godot;
using System;

public partial class SpritesNodes2D : Node2D
{
    private Texture2D _spriteTexture = GD.Load<Texture2D>("res://icon.svg");

    public override void _Ready()
    {
        GetNode("%Benchmark").Connect("spawn", Callable.From(OnSpawn));
    }

    private void OnSpawn()
    {
        var sprite = new Sprite2D();
        sprite.Texture = _spriteTexture;
        
        var viewPortSize = GetViewportRect().Size;
        var halfSize = sprite.Texture.GetSize() / 2;
        sprite.Position = new Vector2(
            (float)GD.RandRange(halfSize.X, viewPortSize.X - halfSize.X),
            (float)GD.RandRange(halfSize.Y, viewPortSize.Y - halfSize.Y)
        );
        
        AddChild(sprite);
    }
}
