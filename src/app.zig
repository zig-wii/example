const std = @import("std");
const root = @import("root");

const Pad = root.Pad;
const Video = root.Video;

pub fn main() callconv(.Inline) void {

    // Initialize Gamepad, video
    if (@hasDecl(root, "platform_wii")) {
        Pad.init();
        var video = Video.init();
        video.init_console();
    }

    var stdout = std.io.getStdOut();
    stdout.writeAll("Hi from Zig!") catch |err| @panic(@errorName(err));

    // Main Loop
    while (true) {
        // On Wii, return when home button pressed
        if (@hasDecl(root, "platform_wii")) {
            for (Pad.update()) |controller, i| {
                if (controller) {
                    if (Pad.button_down(.start, i)) std.os.exit(0);
                }
            }
            Video.wait_vsync();
        }
        else {
            std.os.exit(0);
        }
    }
}