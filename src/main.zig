const std = @import("std");
const ogc = @import("ogc");
const Pad = ogc.Pad;
const Cuboid = ogc.Cuboid;

export fn main(_: c_int, _: [*]const [*:0]const u8) void {
    ogc.start(run, .perspective);
}

fn run(video: *ogc.Video) !void {
    while (true) {
        // Draw square
        video.start();
        var cube = Cuboid.init(2, 1, -10, 2, 2, 2, 0xAABBCCFF);
        cube.set_colors(.{
            0x000000FF,
            0xF00000FF,
            0xFF0000FF,
            0xFFF000FF,
            0xFFFF00FF,
            0xFFFFF0FF,
        });
        cube.draw();
        video.finish();
    }
}
