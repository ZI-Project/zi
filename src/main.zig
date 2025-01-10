const std = @import("std");
const shell = @import("shell.zig");

pub fn main() !void {
    try shell.shell();
}
