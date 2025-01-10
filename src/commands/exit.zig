// purpose: implements the exit command
const std = @import("std");

pub fn exit() !void {
    std.process.exit(0);
}
