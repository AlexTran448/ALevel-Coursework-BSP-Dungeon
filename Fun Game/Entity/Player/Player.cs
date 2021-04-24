using Godot;
using System;
/*
public class Player : KinematicBody2D
{
    [Export] private int ACCELERATION = 500;

    [Export] private int MAX_SPEED = 80;

    [Export] private int ROLL_SPEED = 120;

    [Export] private int FRICTION = 500;

    private Sprite mySprite = GetNode("Sprite");
    private Position2D myWeapon = GetNode("Weapon");

    private bool isAttacking = false;
    private Vector2 velocity = Vector2.Zero;
    private Vector2 fire_vector = Vector2.Right;

    static void attackProjectile()
    {
        myWeapon.direction = fire_vector;
        myWeapon.create_projectile();
        isAttacking = false;
    }


    public override void _PhysicsProcess(float delta)
    {
        Vector2 InputVector = Vector2.Zero;
        InputVector.x = Input.GetActionStrength("Right") - Input.GetActionStrength("Left");
        InputVector.y = Input.GetActionStrength("Down") - Input.GetActionStrength("Up");
        InputVector.Normalized();

        if (InputVector != Vector2.Zero)
        {
            velocity = velocity.MoveToward(InputVector * MAX_SPEED, ACCELERATION * delta);
            velocity = MoveAndSlide(velocity);
            mySprite.flip_h = velocity.x < 0;
            
        }

    }
}
*/