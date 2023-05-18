const r = @import("main.zig").r;

pub fn input() void {}
pub fn update() void {}
pub fn draw() void {
    r.DrawText("Congrats! You created your first window!", 190, 200, 20, r.LIGHTGRAY);
}
