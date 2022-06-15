const std = @import("std");
const ogc = @import("ogc");
const Pad = ogc.Pad;
const Cuboid = ogc.Cuboid;

export fn main(_: c_int, _: [*]const [*:0]const u8) void {
    ogc.start(run, .perspective);
}

fn run(video: *ogc.Video) !void {
    var angle: f32 = 0;
    while (true) {
        angle += 1;
        var cube = Cuboid.init(-1, -1, -10, 2, 2, 2, 0xAABBCCFF);
        cube.set_colors(.{
            0x000000FF,
            0xFF0000FF,
            0xFFFF00FF,
            0xFFFFFFFF,
            0x00FFFFFF,
            0x0000FFFF,
        });
        const center = cube.center();
        cube.rotate_x(center, angle);
        cube.rotate_z(center, angle / 8);

        // Draw square
        video.start();
        cube.draw();
        video.finish();
    }
}
