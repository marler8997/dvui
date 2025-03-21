const D3d = @This();

const builtin = @import("builtin");
const std = @import("std");
const win32 = @import("win32").everything;
const win32ext = @import("win32ext.zig");

device: *win32.ID3D11Device,
context: *win32.ID3D11DeviceContext,
context1: *win32.ID3D11DeviceContext1,

pub fn init(opt: struct {
    try_debug: bool = switch (builtin.mode) {
        .Debug => true,
        else => false,
    },
}) struct { D3d, bool } {
    const levels = [_]win32.D3D_FEATURE_LEVEL{
        .@"11_0",
    };
    var last_hr: i32 = undefined;

    const Config = struct {
        driver: win32.D3D_DRIVER_TYPE,
        debug: bool,
    };
    const configs = [_]Config{
        .{ .driver = .HARDWARE, .debug = true },
        .{ .driver = .HARDWARE, .debug = false },
        .{ .driver = .SOFTWARE, .debug = true },
        .{ .driver = .SOFTWARE, .debug = false },
    };

    for (configs) |config| {
        const skip_config = config.debug and !opt.try_debug;
        if (skip_config) continue;

        var device: *win32.ID3D11Device = undefined;
        var context: *win32.ID3D11DeviceContext = undefined;
        last_hr = win32.D3D11CreateDevice(
            null,
            config.driver,
            null,
            .{
                .BGRA_SUPPORT = 1,
                .SINGLETHREADED = 1,
                .DEBUG = if (config.debug) 1 else 0,
            },
            &levels,
            levels.len,
            win32.D3D11_SDK_VERSION,
            &device,
            null,
            &context,
        );
        if (last_hr >= 0) {
            std.log.info("d3d11: {s} debug={}", .{ @tagName(config.driver), config.debug });
            return .{
                .{
                    .device = device,
                    .context = context,
                    .context1 = win32ext.queryInterface(context, win32.ID3D11DeviceContext1),
                },
                config.debug,
            };
        }
        std.log.info(
            "D3D11 {s} Driver (with{s} debug) error, hresult=0x{x}",
            .{ @tagName(config.driver), if (config.debug) "" else "out", @as(u32, @bitCast(last_hr)) },
        );
    }
    std.debug.panic("failed to initialize Direct3D11, hresult=0x{x}", .{@as(u32, @bitCast(last_hr))});
}
