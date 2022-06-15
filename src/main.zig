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
        var cube = Cuboid.init(video.width / 2, video.height / 2, 50, 64, 64, 64, 0xAABBCCFF);
        cube.draw();
        video.finish();
    }
}
