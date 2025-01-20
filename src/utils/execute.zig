// purpose: main way to execute commands
const std = @import("std");
const ChildProcess = std.process.Child;
const marker = @import("marker.zig");

pub fn execute(input: []u8, allocater: std.mem.Allocator, useMarker: bool) !void {
    var cmdArgs = std.mem.split(u8, input, " ");
    var args = std.ArrayList([]const u8).init(allocater);
    defer args.deinit();

    while (cmdArgs.next()) |arg| {
        try args.append(arg);
    }

    // https://cookbook.ziglang.cc/08-02-external.html only docs i could find on how to do something like this
    var cmd = ChildProcess.init(args.items, allocater);
    cmd.stdout_behavior = .Inherit;
    cmd.stderr_behavior = .Inherit;

    try cmd.spawn();
    _ = cmd.wait() catch |err| {
        switch (err) {
            error.FileNotFound => {
                return error.CommandNotFound;
            },
            else => {
                return err;
            },
        }
    };
    if (useMarker) {
        try marker.printShellMarker(allocater);
    }
}
