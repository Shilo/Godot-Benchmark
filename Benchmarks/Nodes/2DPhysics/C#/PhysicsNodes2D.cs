using Godot;
using System;

public partial class PhysicsNodes2D : Node2D
{
    private PackedScene _body = GD.Load<PackedScene>("res://Assets/IconBody.tscn");
    private Camera2D _camera;
    private Rect2 _cameraBounds;
    
    public override void _Ready()
    {
        _camera = GetNode<Camera2D>("%Camera2D");
        _camera.Position = GetViewportRect().Size / 2;
        _cameraBounds = GetCameraBounds();
        
        var ground = GetNode<CollisionShape2D>("%Ground");
        
        for (int x = 0; x < 2; x++)
        {
            var wall = (CollisionShape2D)ground.Duplicate();
            var shape = new RectangleShape2D();
            shape.Size = ((RectangleShape2D)ground.Shape).Size;
            wall.Position = _camera.Position;
            
            var offset = (_cameraBounds.Size.X + shape.Size.X) / 2;
            if (x == 0) offset = -offset;
            
            wall.Position = new Vector2(wall.Position.X + offset, wall.Position.Y - _cameraBounds.Size.Y / 2);
        
            var size = shape.Size;
            size.Y = _cameraBounds.Size.Y + _cameraBounds.Size.Y;
            shape.Size = size;
        
            wall.Shape = shape;
            
            var wallBody = new StaticBody2D();
            wallBody.AddChild(wall);
            AddChild(wallBody);
        }
        
        var groundPosition = _camera.Position;
        groundPosition.Y += (_cameraBounds.Size.Y + ((RectangleShape2D)ground.Shape).Size.Y) / 2;
        ground.Position = groundPosition;
        
        var groundShape = (RectangleShape2D)ground.Shape;
        groundShape.Size = new Vector2(_cameraBounds.Size.X * 2, groundShape.Size.Y);
        ground.Shape = (Shape2D)groundShape.Duplicate(); // fix bug with Rapier 2D Physics engine
        
        GetNode("%Benchmark").Connect("spawn", Callable.From(OnSpawn));
    }
    
    private void OnSpawn()
    {
        var body = _body.Instantiate<Node2D>();
        
        var halfSize = body.GetNode<Sprite2D>("Sprite").Texture.GetSize() / 2;
        var x = (float)GD.RandRange(_cameraBounds.Position.X + halfSize.Y, _cameraBounds.Position.X + _cameraBounds.Size.X - halfSize.X);
        var y = _cameraBounds.Position.Y - halfSize.Y;
        body.Position = new Vector2(x, y);
        AddChild(body);
    }
    
    private Rect2 GetCameraBounds()
    {
        var size = GetViewportRect().Size / _camera.Zoom;
        var cameraPosition = _camera.GlobalPosition - size / 2;
        return new Rect2(cameraPosition, size);
    }
}
