const std = @import("std");

// this is gonna be the most basic build file you have ever seen
pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});
    const exe = b.addExecutable(.{ .name = "zi", .root_source_file = b.path("src/main.zig"), .target = target, .optimize = optimize });

    b.installArtifact(exe);

    // run step
    const run_cmd = b.addRunArtifact(exe);
    run_cmd.step.dependOn(b.getInstallStep());
    if (b.args) |args| {
        run_cmd.addArgs(args);
    }
    const run_step = b.step("run", "run the compiled shell");
    run_step.dependOn(&run_cmd.step);
}
