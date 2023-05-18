const std = @import("std");
const print = @import("util.zig").print;

const g = @import("game.zig");

pub const r = @cImport({
    @cInclude("raylib.h");
});

pub fn main() void {
    print("Hello, World\n");
    const screenWidth = 800;
    const screenHeight = 450;

    r.InitWindow(screenWidth, screenHeight, "MyWindow");
    defer r.CloseWindow();
    r.SetTargetFPS(60);

    while (!r.WindowShouldClose()) {
        g.input();
        g.update();
        r.BeginDrawing();
        defer r.EndDrawing();
        r.ClearBackground(r.WHITE);
        g.draw();
    }
}
