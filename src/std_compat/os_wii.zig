const std = @import("std");
const c = @import("c.zig");
pub const system = @import("system_wii.zig");

pub const heap = .{
    .allocator = std.mem.Allocator {
        .ptr = undefined,
        .vtable = std.mem.Allocator.VTable {
            .alloc = alloc,
            .resize = resize,
            .free = free,
        }
    }
};

fn alloc() void {}

fn resize() void {}

fn free() void {}