const std = @import("std");
const c = @import("c.zig");
const Video = @import("Video.zig");

const Console = @This();
enabled: u0,


pub fn init(video: *Video) Console {
    c.CON_Init(video.framebuffers[0], 20, 20, @floatToInt(c_int, video.height), @floatToInt(c_int, video.width), @floatToInt(c_int, video.width) * 2);
    _ = c.printf("\x1b[2;0H");

    return Console{ .enabled = 0 };
}

pub fn print(self: Console, str: [*c] const u8) void {
    if (self.enabled == 0)
        _ = c.printf(str);
}