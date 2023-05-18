const std = @import("std");

const addRaylib = @import("raylib/src/build.zig").addRaylib;

fn addRaylibDependencies(step: *std.build.LibExeObjStep, raylib: *std.build.LibExeObjStep) void {
    step.addIncludePath("raylib/src");

    // raylib's build.zig file specifies all libraries this executable must be
    // linked with, so let's copy them from there.
    for (raylib.link_objects.items) |o| {
        if (o == .system_lib) {
            step.linkSystemLibrary(o.system_lib.name);
        }
    }
    if (step.target.isWindows()) {
        step.addObjectFile("zig-out/lib/raylib.lib");
    } else {
        step.addObjectFile("zig-out/lib/libraylib.a");
    }
}

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const raylib = addRaylib(b, target, optimize);

    const exe = b.addExecutable(.{
        .name = "gd50",
        .root_source_file = .{ .path = "src/main.zig" },
        .target = target,
        .optimize = optimize,
    });
    exe.linkLibC();
    b.installArtifact(raylib);
    addRaylibDependencies(exe, raylib);

    b.installArtifact(exe);
    const run_cmd = b.addRunArtifact(exe);

    run_cmd.step.dependOn(b.getInstallStep());

    // This allows the user to pass arguments to the application in the build
    // command itself, like this: `zig build run -- arg1 arg2 etc`
    if (b.args) |args| {
        run_cmd.addArgs(args);
    }

    const run_step = b.step("run", "Run the app");
    run_step.dependOn(&run_cmd.step);

    // Creates a step for unit testing. This only builds the test executable
    // but does not run it.
    const unit_tests = b.addTest(.{
        .root_source_file = .{ .path = "src/main.zig" },
        .target = target,
        .optimize = optimize,
    });

    const run_unit_tests = b.addRunArtifact(unit_tests);

    // Similar to creating the run step earlier, this exposes a `test` step to
    // the `zig build --help` menu, providing a way for the user to request
    // running the unit tests.
    const test_step = b.step("test", "Run unit tests");
    test_step.dependOn(&run_unit_tests.step);
}
