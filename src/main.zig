const std = @import("std");
const builtin = @import("builtin");

const ogc = @import("ogc/ogc.zig");
const Pad = ogc.Pad;
const Video = ogc.Video;

pub const os = @import("std_compat/os_wii.zig");

export fn main(_: c_int, _: [*]const [*:0]const u8) void {

    // Initialize Gamepad, video
    Pad.init();
    var video = Video.init(.orthographic);
    video.init_console();

    var stdout = std.io.getStdOut();
    stdout.writeAll("Hi from Zig!") catch |err| @panic(@errorName(err));



    // Main Loop
    while (true) {
        // Return when home button pressed
        for (Pad.update()) |controller, i| {
            if (controller) {
                if (Pad.button_down(.start, i)) std.os.exit(0);
            }
        }

        Video.wait_vsync();
    }
}