// purpose: main way to execute commands
const std = @import("std");
const allocater = std.heap.page_allocator;
const ChildProcess = std.process.Child;
const marker = @import("marker.zig");

pub fn execute(input: []u8) !void {
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
    _ = try cmd.wait();

    try marker.printShellMarker();
}
