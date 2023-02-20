const c = @import("c.zig");
const std = @import("std");

pub const Video = @This();
index: u8,
width: f32,
height: f32,
display: Display,
mode: *c.GXRModeObj,
framebuffers: [2]*anyopaque,
zoom: f32 = 1,
first: bool = true,
view: c.Mtx = undefined,
perspective: c.Mtx44 = undefined,

pub const Display = enum { orthographic, perspective };

pub const Vector = extern struct {
    x: f32,
    y: f32,
    z: f32,
};

pub const Camera = union(Display) {
    orthographic: struct {
        x: f32,
        y: f32,
    },
    perspective: struct {
        up: Vector = .{ .x = 0, .y = -1, .z = 0 },
        position: Vector = .{ .x = 0, .y = 0, .z = 0 },
        target: Vector,
    },
};

/// Creates a framebuffer from video mode
pub fn init_framebuffer(mode: *c.GXRModeObj) *anyopaque {
    return c.MEM_K0_TO_K1(c.SYS_AllocateFramebuffer(mode)) orelse unreachable;
}

pub fn init(comptime display: Display) Video {
    c.VIDEO_Init();
    var fbi: u8 = 0;
    var mode: *c.GXRModeObj = c.VIDEO_GetPreferredMode(null);
    var fbs: [2]*anyopaque = .{ init_framebuffer(mode), init_framebuffer(mode) };
    c.VIDEO_Configure(mode);
    c.VIDEO_SetNextFramebuffer(fbs[fbi]);
    c.VIDEO_SetBlack(false);
    c.VIDEO_Flush();
    c.VIDEO_WaitVSync();
    if (mode.viTVMode & c.VI_NON_INTERLACE != 0) c.VIDEO_WaitVSync();

    // const fifo_size: u32 = 256 * 1024;
    // const buffer: [fifo_size]u32 = undefined;
    // var fifo_buffer = c.MEM_K0_TO_K1(&buffer[0]) orelse unreachable;
    // _ = c.GX_Init(fifo_buffer, fifo_size);

    // // TODO: Fix background color
    // // const background = c.GXColor{ .r = 100, .g = 100, .b = 100, .a = 100 };
    // // c.GX_SetCopyClear(background, 0x00FFFFFF);

    const width = mode.fbWidth;
    const height = mode.efbHeight;
    // c.GX_SetViewport(0, 0, @intToFloat(f32, width), @intToFloat(f32, height), 0, 1);

    // const y_scale = c.GX_GetYScaleFactor(mode.efbHeight, mode.xfbHeight);
    // const xfbHeight = c.GX_SetDispCopyYScale(y_scale);

    // c.GX_SetViewport(0, 0, @intToFloat(f32, width), @intToFloat(f32, height), 0, 1);
    // c.GX_SetScissor(0, 0, width, height);
    // c.GX_SetDispCopySrc(0, 0, mode.fbWidth, mode.efbHeight);
    // c.GX_SetDispCopyDst(mode.fbWidth, @intCast(u16, xfbHeight));
    // c.GX_SetCopyFilter(mode.aa, &mode.sample_pattern, c.GX_TRUE, &mode.vfilter);
    // c.GX_SetFieldMode(mode.field_rendering, @boolToInt(mode.viHeight == 2 * mode.xfbHeight));

    // if (mode.aa != 0) c.GX_SetPixelFmt(c.GX_PF_RGB565_Z16, c.GX_ZC_LINEAR) else c.GX_SetPixelFmt(c.GX_PF_RGB8_Z24, c.GX_ZC_LINEAR);

    // c.GX_SetCullMode(c.GX_CULL_NONE);
    // c.GX_CopyDisp(fbs[fbi], c.GX_TRUE);
    // c.GX_SetDispCopyGamma(c.GX_GM_1_0);

    // c.GX_InvVtxCache();
    // c.GX_ClearVtxDesc();
    // c.GX_SetVtxDesc(c.GX_VA_POS, c.GX_DIRECT);
    // c.GX_SetVtxDesc(c.GX_VA_CLR0, c.GX_DIRECT);
    // c.GX_SetVtxDesc(c.GX_VA_TEX0, c.GX_DIRECT);

    // c.GX_SetVtxAttrFmt(c.GX_VTXFMT0, c.GX_VA_POS, c.GX_POS_XYZ, c.GX_F32, 0);
    // c.GX_SetVtxAttrFmt(c.GX_VTXFMT0, c.GX_VA_CLR0, c.GX_CLR_RGBA, c.GX_RGBA8, 0);
    // c.GX_SetVtxAttrFmt(c.GX_VTXFMT0, c.GX_VA_TEX0, c.GX_TEX_ST, c.GX_F32, 0);

    // c.GX_SetNumChans(1);
    // c.GX_SetChanCtrl(c.GX_COLOR0A0, c.GX_DISABLE, c.GX_SRC_REG, c.GX_SRC_VTX, c.GX_LIGHTNULL, c.GX_DF_NONE, c.GX_AF_NONE);
    // c.GX_SetNumTexGens(1);

    // c.GX_SetTevOp(c.GX_TEVSTAGE0, c.GX_PASSCLR);
    // c.GX_SetTevOrder(c.GX_TEVSTAGE0, c.GX_TEXCOORD0, c.GX_TEXMAP0, c.GX_COLOR0A0);
    // c.GX_SetTexCoordGen(c.GX_TEXCOORD0, c.GX_TG_MTX2x4, c.GX_TG_TEX0, c.GX_IDENTITY);

    // c.GX_InvalidateTexAll();

    // // Set perspective matrix
    // var perspective: c.Mtx44 = undefined;
    // if (display == .orthographic) {
    //     c.guOrtho(&perspective, 0, @intToFloat(f32, height), 0, @intToFloat(f32, width), 0, 300);
    //     c.GX_LoadProjectionMtx(&perspective, c.GX_ORTHOGRAPHIC);
    // } else {
    //     const fov = 90;
    //     const aspect_ratio = @intToFloat(f32, width) / @intToFloat(f32, height);
    //     c.guPerspective(&perspective, fov, aspect_ratio, 0.1, 300);
    //     c.GX_LoadProjectionMtx(&perspective, c.GX_PERSPECTIVE);
    // }

    // // Final scissor box
    // c.GX_SetScissorBoxOffset(0, 0);
    // c.GX_SetScissor(0, 0, width, height);

    return Video{
        .index = fbi,
        .mode = mode,
        .framebuffers = fbs,
        // .perspective = perspective,
        .width = @intToFloat(f32, width),
        .height = @intToFloat(f32, height),
        .display = display,
    };
}

pub fn init_console(self: *Video) void {
    c.CON_Init(self.framebuffers[0], 20, 20, @floatToInt(c_int, self.height), @floatToInt(c_int, self.width), @floatToInt(c_int, self.width) * 2);
    var stdout = std.io.getStdOut();
    stdout.writeAll("\x1b[2;0H") catch |err| @panic(@errorName(err));
}

pub fn wait_vsync() void {
    c.VIDEO_WaitVSync();
}

/// Initialize drawing to screen
pub fn start(self: *Video) void {
    c.GX_SetViewport(0, 0, self.width, self.height, 0, 1);
}

/// Finish drawing to screen
pub fn finish(self: *Video) void {
    self.index ^= 1;
    c.GX_DrawDone();
    c.GX_SetZMode(c.GX_TRUE, c.GX_LEQUAL, c.GX_TRUE);
    if (self.display == .orthographic)
        c.GX_SetBlendMode(c.GX_BM_BLEND, c.GX_BL_SRCALPHA, c.GX_BL_INVSRCALPHA, c.GX_LO_CLEAR);
    c.GX_SetAlphaUpdate(c.GX_TRUE);
    c.GX_SetColorUpdate(c.GX_TRUE);
    c.GX_CopyDisp(self.framebuffers[self.index], c.GX_TRUE);
    c.VIDEO_SetNextFramebuffer(self.framebuffers[self.index]);
    if (self.first) {
        self.first = false;
        c.VIDEO_SetBlack(false);
    }
    c.VIDEO_Flush();
    c.VIDEO_WaitVSync();
}

/// Sets current camera
pub fn set_camera(self: *Video, camera: Camera) void {
    switch (camera) {
        .orthographic => |data| {
            const width = self.width / self.zoom;
            const height = self.height / self.zoom;
            c.guOrtho(&self.perspective, data.y, data.y + height, data.x, data.x + width, 0, 300);
            c.GX_LoadProjectionMtx(&self.perspective, c.GX_ORTHOGRAPHIC);
        },
        .perspective => |data| {
            c.guLookAt(
                &self.view,
                &@bitCast(c.guVector, data.position),
                &@bitCast(c.guVector, data.up),
                &@bitCast(c.guVector, data.target),
            );
            c.GX_LoadPosMtxImm(&self.view, c.GX_PNMTX0);
        },
    }
}

/// Loads TPL from path
pub fn load_tpl(comptime path: []const u8) void {
    const data = &struct {
        var bytes = @embedFile(path).*;
    }.bytes;
    var sprite: c.TPLFile = undefined;
    var texture: c.GXTexObj = undefined;
    _ = c.TPL_OpenTPLFromMemory(&sprite, data, data.len);
    _ = c.TPL_GetTexture(&sprite, 0, &texture);
    c.GX_LoadTexObj(&texture, 0);

    c.GX_InvVtxCache();
    c.GX_ClearVtxDesc();
    c.GX_SetVtxDesc(c.GX_VA_POS, c.GX_DIRECT);
    c.GX_SetVtxDesc(c.GX_VA_CLR0, c.GX_DIRECT);
    c.GX_SetVtxDesc(c.GX_VA_TEX0, c.GX_DIRECT);

    c.GX_SetVtxAttrFmt(c.GX_VTXFMT0, c.GX_VA_POS, c.GX_POS_XYZ, c.GX_F32, 0);
    c.GX_SetVtxAttrFmt(c.GX_VTXFMT0, c.GX_VA_CLR0, c.GX_CLR_RGBA, c.GX_RGBA8, 0);
    c.GX_SetVtxAttrFmt(c.GX_VTXFMT0, c.GX_VA_TEX0, c.GX_TEX_ST, c.GX_F32, 0);

    c.GX_SetNumChans(1);
    c.GX_SetChanCtrl(c.GX_COLOR0A0, c.GX_DISABLE, c.GX_SRC_REG, c.GX_SRC_VTX, c.GX_LIGHTNULL, c.GX_DF_NONE, c.GX_AF_NONE);
    c.GX_SetNumTexGens(1);

    c.GX_SetTevOp(c.GX_TEVSTAGE0, c.GX_PASSCLR);
    c.GX_SetTevOrder(c.GX_TEVSTAGE0, c.GX_TEXCOORD0, c.GX_TEXMAP0, c.GX_COLOR0A0);
    c.GX_SetTexCoordGen(c.GX_TEXCOORD0, c.GX_TG_MTX2x4, c.GX_TG_TEX0, c.GX_IDENTITY);

    c.GX_InvalidateTexAll();
}