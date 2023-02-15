const std = @import("std");
const ogc = @import("ogc");
const Pad = ogc.Pad;
const Video = ogc.Video;
const Rectangle = ogc.Rectangle;
const Console = ogc.Console;

pub const os = @import("os_wii.zig");

export fn main(_: c_int, _: [*]const [*:0]const u8) void {
    // ogc.start(run, .orthographic);

    // Initialize Gamepad, video
    Pad.init();
    var video = Video.init(.orthographic);
    // video.console_init();

    var console = Console.init(&video);
    console.print("HELLO WORLD");

    var stdout = std.io.getStdOut();
    stdout.writeAll("Hi from Zig!") catch |err| @panic(@errorName(err));

    // Main Loop
    run() catch |err| @panic(@errorName(err));
}
// fn run(video: *ogc.Video) !void {   
fn run() !void {   
    // State
    // var x: f32 = 0;
    // var y: f32 = 0;
    // const speed: f32 = 3;

    while (true) {
        // Movement
        for (Pad.update()) |controller, i| {
            if (controller) {
                // x += Pad.stick_x(i) * speed;
                // y -= Pad.stick_y(i) * speed;
                if (Pad.button_down(.start, i)) std.os.exit(0);
            }
        }

        Video.wait_vsync();

        // Draw square
        // video.start();
        // var box = Rectangle.init(x, y, 128, 128);
        // box.rotate(box.center(), (x + y) / (video.width + video.height) * 360);
        // box.draw(0xAABBCCFF);
        // box.draw_border(0xCCDDEEFF, 20);
        // video.finish();
    }
}
