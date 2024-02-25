using Godot;
using System;

public partial class SpritesServer2D : Node2D
{
    private Texture2D _spriteTexture = GD.Load<Texture2D>("res://icon.svg");
    
    private Rid _context;
    
    public override void _Ready()
    {
        _context = RenderingServer.CanvasItemCreate();
        RenderingServer.CanvasItemSetParent(_context, GetCanvasItem());
        
        GetNode("%Benchmark").Connect("spawn", Callable.From(OnSpawn));
    }
    
    private void OnSpawn()
    {
        var viewportSize = GetViewportRect().Size;
        var size = _spriteTexture.GetSize();

        var texturePosition = Vector2.Zero;
        texturePosition.X = (float)GD.RandRange(0, viewportSize.X - size.X);
        texturePosition.Y = (float)GD.RandRange(0, viewportSize.Y - size.Y);
        
        RenderingServer.CanvasItemAddTextureRect(_context, new Rect2(texturePosition, size), _spriteTexture.GetRid());
    }
}
