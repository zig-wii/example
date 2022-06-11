const std = @import("std");
const ogc = @import("ogc");
const Pad = ogc.Pad;
const rectangle = ogc.utils.rectangle;

export fn main(_: c_int, _: [*]const [*:0]const u8) void {
    ogc.start(run);
}

fn run(video: *ogc.Video) !void {
    // State
    var x: f32 = 0;
    var y: f32 = 0;
    const speed: f32 = 3;

    while (true) {
        // Movement
        for (Pad.update()) |controller, i| {
            if (controller) {
                x += Pad.stick_x(i) * speed;
                y -= Pad.stick_y(i) * speed;
                if (Pad.button_down(.start, i)) std.os.exit(0);
            }
        }

        // Draw square
        video.start();
        rectangle(ogc.Rectangle.init(x, y, 128, 128), 0xAABBCCFF);
        video.finish();
    }
}
