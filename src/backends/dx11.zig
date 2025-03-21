//!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
//! NOTE: right now this is a bit weird...but...a Dx11Device is actually a Window!
const std = @import("std");
const builtin = @import("builtin");
const dvui = @import("dvui");
const win = @import("win32"); // TODO: remove this

pub const win32 = @import("win32").everything;

pub const D3d = @import("D3d.zig");
const win32ext = @import("win32ext.zig");

const w = std.os.windows;

const graphics = win.graphics;
const key = win.ui.input.keyboard_and_mouse;

const HWND = win.foundation.HWND;
const BOOL = win.foundation.BOOL;

const dxgi = graphics.dxgi;
const dx = graphics.direct3d11;

pub const Context = *align(1) @This();

const log = std.log.scoped(.Dx11Backend);

const DvuiKey = union(enum) {
    /// A keyboard button press
    keyboard_key: dvui.enums.Key,
    /// A mouse button press
    mouse_key: dvui.enums.Button,
    /// Mouse move event
    mouse_event: struct { x: i16, y: i16 },
    /// Mouse wheel scroll event
    wheel_event: i16,
    /// No action
    none: void,
};

const KeyEvent = struct {
    /// The type of event emitted
    target: DvuiKey,
    /// What kind of action the event emitted
    action: enum { down, up, none },
};

// const WindowOptions = struct {
//     /// Whether the Dx11 Backend shall manage the window resources.
//     is_window_owned: bool = false,
//     /// The general allocator used for the window initialization code
//     alloc: ?std.mem.Allocator = null,
//     /// The instance of the program
//     instance: ?HINSTANCE = null,
//     /// The instance of the Window
//     hwnd: win.foundation.HWND,
//     // /// The window DC (= Device Context)
//     // hwnd_dc: ?win32.HDC = null,

//     /// The title as *allocated* utf16 string.
//     /// Thank you windows for doing this... still.
//     /// Long live UTF-8 !!!!!
//     utf16_wnd_title: ?[:0]u16 = null,

//     pub fn deinit(self: WindowOptions) void {
//         // if (!self.is_window_owned) return;

//         // if (self.alloc) |alloc| {
//         //     _ = win32.ReleaseDC(self.hwnd, self.hwnd_dc);
//         //     _ = ui.DestroyWindow(self.hwnd);
//         //     _ = ui.UnregisterClassW(self.utf16_wnd_title.?, self.instance.?);
//         //     alloc.free(self.utf16_wnd_title.?);
//         // }
//     }
// };

pub const InitOptions = struct {
    //     /// The allocator used for temporary allocations used during init()
    //     allocator: std.mem.Allocator,
    //     /// The initial size of the application window
    //     // size: dvui.Size,
    //     // /// Set the minimum size of the window
    //     // min_size: ?dvui.Size = null,
    //     // /// Set the maximum size of the window
    //     // max_size: ?dvui.Size = null,
    //     // vsync: bool,
    //     // /// The application title to display
    //     // title: [:0]const u8,
    //     // /// content of a PNG image (or any other format stb_image can load)
    //     // /// tip: use @embedFile
    //     // icon: ?[]const u8 = null,
};

// pub const Directx11Options = struct {
//     /// The device
//     device: *dx.ID3D11Device,
//     /// The Context
//     device_context: *dx.ID3D11DeviceContext,
//     /// The Swap chain
//     swap_chain: *dxgi.IDXGISwapChain,
// };

const XMFLOAT2 = extern struct { x: f32, y: f32 };
const XMFLOAT3 = extern struct { x: f32, y: f32, z: f32 };
const XMFLOAT4 = extern struct { r: f32, g: f32, b: f32, a: f32 };
const SimpleVertex = extern struct { position: XMFLOAT3, color: XMFLOAT4, texcoord: XMFLOAT2 };

const shader =
    \\struct PSInput
    \\{
    \\    float4 position : SV_POSITION;
    \\    float4 color : COLOR;
    \\    float2 texcoord : TEXCOORD0;
    \\};
    \\
    \\PSInput VSMain(float4 position : POSITION, float4 color : COLOR, float2 texcoord : TEXCOORD0)
    \\{
    \\    PSInput result;
    \\
    \\    result.position = position;
    \\    result.color = color;
    \\    result.texcoord = texcoord;
    \\
    \\    return result;
    \\}
    \\
    \\Texture2D myTexture : register(t0);
    \\SamplerState samplerState : register(s0);
    \\
    \\float4 PSMain(PSInput input) : SV_TARGET
    \\{
    \\    if(input.texcoord.x < 0 || input.texcoord.x > 1 || input.texcoord.y < 0 || input.texcoord.y > 1) return input.color;
    \\    float4 sampled = myTexture.Sample(samplerState, input.texcoord);
    \\    return sampled * input.color;
    \\}
;

// /// Sets the directx viewport to the internally used dvui.Size
// /// Call this *after* setDimensions
// pub fn setViewport(ctx: Context) void {
//     var vp = dx.D3D11_VIEWPORT{
//         .TopLeftX = 0.0,
//         .TopLeftY = 0.0,
//         .Width = self.options.size.w,
//         .Height = self.options.size.h,
//         .MinDepth = 0.0,
//         .MaxDepth = 1.0,
//     };

//     self.device_context.RSSetViewports(1, @ptrCast(&vp));
// }

// /// Sets the dimensions of a window and maps it to a dvui.Size
// /// Call this *before* setViewport
// pub fn setDimensions(ctx: Context, rect: win32.RECT) void {
//     _ = ctx;
//     _ = rect;
//     @panic("todo");
//     // self.options.size.w = @floatFromInt(rect.right - rect.left);
//     // self.options.size.h = @floatFromInt(rect.bottom - rect.top);
// }

// /// Sets the global dvui.Window instance
// /// Call this after you created the dvui.Window
// /// ```zig
// /// const window = ...;
// /// Backend.setWindow(&window);
// /// ```
// pub fn setWindow(window: ?*dvui.Window) void {
//     wind = window;
// }

// /// Sets the global Dx11Backend
// /// Call this on the Backend (not the instance!) after the Backend has been created
// /// Example:
// /// ```zig
// /// const backend = ...;
// /// Backend.setBackend(&backend);
// /// ```
// pub fn setBackend(ins: ?*Dx11Backend) void {
//     inst = ins;
// }

// pub fn init(
//     hwnd: win32.HWND,
//     opt: struct {
//         //shader: ?[:0]const u8 = null,
//     },
// ) !Dx11Backend {
//     _ = opt;
//     std.debug.assert(!global.init_called);
//     global.init_called = true;

//     const try_debug = switch (builtin.mode) {
//         .Debug => true,
//         else => false,
//     };

//     global.d3d, const debug = D3d.init(.{ .try_debug = try_debug });

//     if (debug) {
//         const info = win32ext.queryInterface(global.d3d.device, win32.ID3D11InfoQueue);
//         defer _ = info.IUnknown.Release();
//         {
//             const hr = info.SetBreakOnSeverity(.CORRUPTION, 1);
//             if (hr < 0) fatalHr("SetBreakOnCorruption", hr);
//         }
//         {
//             const hr = info.SetBreakOnSeverity(.ERROR, 1);
//             if (hr < 0) fatalHr("SetBreakOnError", hr);
//         }
//         {
//             const hr = info.SetBreakOnSeverity(.WARNING, 1);
//             if (hr < 0) fatalHr("SetBreakOnWarning", hr);
//         }
//     }

//     //global.shaders = Shaders.init(opt.shader);

//     // {
//     //     const desc: win32.D3D11_BUFFER_DESC = .{
//     //         // d3d requires constants be sized in multiples of 16
//     //         .ByteWidth = std.mem.alignForward(u32, @sizeOf(shader.GridConfig), 16),
//     //         .Usage = .DYNAMIC,
//     //         .BindFlags = .{ .CONSTANT_BUFFER = 1 },
//     //         .CPUAccessFlags = .{ .WRITE = 1 },
//     //         .MiscFlags = .{},
//     //         .StructureByteStride = 0,
//     //     };
//     //     const hr = global.d3d.device.CreateBuffer(&desc, null, &global.const_buf);
//     //     if (hr < 0) fatalHr("CreateBuffer for grid config", hr);
//     // }
//     return .{ .hwnd = hwnd };
//     //return dvui.Backend.init(undefined, @This());
// }

// /// Inits a new instance of the Dx11Backend
// /// The caller has to manage their DirectX device, swapchain and device context.
// pub fn init(options: InitOptions, dx_options: Directx11Options, hwnd: HWND) !Dx11Backend {
//     return Dx11Backend{
//         .device = dx_options.device,
//         .swap_chain = dx_options.swap_chain,
//         .device_context = dx_options.device_context,
//         .options = options,
//         .window = .{
//             .hwnd = hwnd,
//         },
//     };
// }

// pub const InitWindowOptions = struct {
//     // class: [*:0]const u16,
//     // create: windows.CreateWindowOptions,
//     d3d: D3dOptions,
// };

pub const Error = struct {
    what: [:0]const u8,
    code: Code,

    pub fn setZig(self: *Error, what: [:0]const u8, code: anyerror) error{Error} {
        self.* = .{ .what = what, .code = .{ .zig = code } };
        return error.Error;
    }
    pub fn setWin32(self: *Error, what: [:0]const u8, code: win32.WIN32_ERROR) error{Error} {
        self.* = .{ .what = what, .code = .{ .win32 = code } };
        return error.Error;
    }
    pub fn setHresult(self: *Error, what: [:0]const u8, code: i32) error{Error} {
        self.* = .{ .what = what, .code = .{ .hresult = code } };
        return error.Error;
    }

    const Code = union(enum) {
        zig: anyerror,
        win32: win32.WIN32_ERROR,
        hresult: win32.HRESULT,
        pub fn format(
            self: Code,
            comptime fmt: []const u8,
            options: std.fmt.FormatOptions,
            writer: anytype,
        ) !void {
            switch (self) {
                .zig => |e| try writer.print("error {s}", .{@errorName(e)}),
                .win32 => |c| try c.format(fmt, options, writer),
                .hresult => |hr| try writer.print("HRESULT 0x{x}", .{@as(u32, @bitCast(hr))}),
            }
        }
    };

    pub fn format(
        self: Error,
        comptime fmt: []const u8,
        options: std.fmt.FormatOptions,
        writer: anytype,
    ) !void {
        _ = fmt;
        _ = options;
        try writer.print("{s} failed with {}", .{ self.what, self.code });
    }
};

pub const RegisterClassOptions = struct {
    style: win32.WNDCLASS_STYLES = .{},
    // NOTE: we could allow the user to provide their own wndproc which we could
    //       call before or after ours
    //wndproc: ...,
    class_extra: c_int = 0,
    // NOTE: the dx11 backend uses the first @sizeOf(*anyopaque) bytes, any length
    //       added here will be offset by that many bytes
    window_extra_after_sizeof_ptr: c_int = 0,
    instance: union(enum) { this_module, custom: ?win32.HINSTANCE } = .this_module,
    cursor: ?win32.HICON = null,
    icon: ?win32.HICON = null,
    icon_small: ?win32.HICON = null,
    bg_brush: ?win32.HBRUSH = null,
    menu_name: ?[*:0]const u16 = null,
};

// Wraps win32.RegisterClassExW but sets lpfnWndProc to this file's wndProc
// and adds space for a pointer in cbWndExtra. Call win32.GetLastError() to
// get the error code if this function returns error.Win32.
// Reuse this class for any windows that share the same options.
pub fn RegisterClass(name: [*:0]const u16, opt: RegisterClassOptions) error{Win32}!void {
    const wc: win32.WNDCLASSEXW = .{
        .cbSize = @sizeOf(win32.WNDCLASSEXW),
        .style = opt.style,
        .lpfnWndProc = wndProc,
        .cbClsExtra = opt.class_extra,
        .cbWndExtra = @sizeOf(usize) + opt.window_extra_after_sizeof_ptr,
        .hInstance = win32.GetModuleHandleW(null),
        .hIcon = opt.icon,
        .hIconSm = opt.icon_small,
        .hCursor = opt.cursor,
        .hbrBackground = opt.bg_brush,
        .lpszMenuName = opt.menu_name,
        .lpszClassName = name,
    };
    if (0 == win32.RegisterClassExW(&wc)) return error.Win32;
}

pub const CreateWindowOptions = struct {
    vsync: bool = false,
    style: win32.WINDOW_STYLE = .{},
    style_ex: win32.WINDOW_EX_STYLE = .{},
    title: ?[*:0]const u16,
    x: i32 = win32.CW_USEDEFAULT,
    y: i32 = win32.CW_USEDEFAULT,
    width: i32 = win32.CW_USEDEFAULT,
    height: i32 = win32.CW_USEDEFAULT,
    parent: ?win32.HWND = null,
    menu: ?win32.HMENU = null,
    instance: union(enum) { this_module, custom: ?win32.HINSTANCE } = .this_module,
};

pub const CallbackContext = enum { ready, destroy };

const CreateWindowArgs = struct {
    create_error: ?anyerror,
    src: std.builtin.SourceLocation,
    gpa: std.mem.Allocator,
    d3d: *const D3d,
    vsync: bool,
    callback: *const fn (CallbackContext, *dvui.Window) anyerror!void,
    state: *WindowState,
};

// Wraps win32.CreateWindowExW. If this function returns error.Win32,
// then call win32.GetLastError() to get the error code.
pub fn CreateWindow(
    src: std.builtin.SourceLocation,
    gpa: std.mem.Allocator,
    d3d: *const D3d,
    /// class should be the name of a class registered via RegisterClass
    class: [*:0]const u16,
    callback: *const fn (CallbackContext, *dvui.Window) anyerror!void,
    state: *WindowState,
    opt: CreateWindowOptions,
) !win32.HWND {
    const create_args: CreateWindowArgs = .{
        .create_error = null,
        .src = src,
        .gpa = gpa,
        .d3d = d3d,
        .vsync = opt.vsync,
        .callback = callback,
        .state = state,
    };
    return win32.CreateWindowExW(
        opt.style_ex,
        class,
        opt.title,
        opt.style,
        opt.x,
        opt.y,
        opt.width,
        opt.height,
        opt.parent,
        opt.menu,
        switch (opt.instance) {
            .this_module => win32.GetModuleHandleW(null),
            .custom => |m| m,
        },
        @constCast(@ptrCast(&create_args)),
    ) orelse {
        if (create_args.create_error) |e| return e;
        return error.Win32;
    };
}

// /// Creates a new DirectX window for you, as well as initializes all the
// /// DirectX options for you
// /// The caller just needs to clean up everything by calling `deinit` on the Dx11Backend
// pub fn initWindow(d3d: *const D3d, hwnd: win32.HWND) !Dx11Backend {
//     //     _ = out_err;
//     //     // const hwnd = try windows.CreateWindow(options.class, options.create);
//     //     const dx_options = createDeviceD3D(hwnd, d3d_options) orelse return error.D3dDeviceInitFailed;

//     //     // _ = ui.ShowWindow(window_options.hwnd, @bitCast(cmd_show));
//     //     // _ = win32.UpdateWindow(window_options.hwnd);

//     //     var rc: RECT = undefined;
//     //     _ = ui.GetClientRect(hwnd, &rc);
//     //     //std.debug.print("GetClientRect -> {}\n", .{rc});

//     //     var res = Dx11Backend{
//     //         .device = dx_options.device,
//     //         .device_context = dx_options.device_context,
//     //         .swap_chain = dx_options.swap_chain,
//     //         .window = .{
//     //             // !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
//     //             .hwnd = hwnd,
//     //         },
//     //         .options = .{},
//     //     };

//     //     res.setDimensions(rc);
//     //     res.setViewport();

//     //     res.handleSwapChainResizing(@intCast(rc.right - rc.left), @intCast(rc.bottom - rc.top)) catch {
//     //         log.err("Failed to handle swap chain resizing...", .{});
//     //     };

//     //return .{ .d3d = d3d, .hwnd = hwnd };
//     return hwnd;
// }

// /// Cleanup routine
// pub fn deinit(ctx: Context) void {
//     _ = ctx;
//     @panic("todo");
//     // if (self.window.is_window_owned) {
//     //     self.window.deinit();
//     //     _ = self.device.IUnknown.Release();
//     //     _ = self.device_context.IUnknown.Release();
//     //     _ = self.swap_chain.IUnknown.Release();
//     // }

//     // if (self.render_target) |rt| {
//     //     _ = rt.IUnknown.Release();
//     // }

//     // self.dx_options.deinit();

//     // setWindow(null);
//     // // setBackend(null);
// }

/// Resizes the SwapChain based on the new window size
/// This is only useful if you have your own directx stuff to manage
pub fn handleSwapChainResizing(ctx: Context, width: c_uint, height: c_uint) !void {
    _ = ctx;
    _ = width;
    _ = height;
    @panic("todo");
    // self.cleanupRenderTarget();
    // _ = self.swap_chain.ResizeBuffers(0, width, height, win32.DXGI_FORMAT_UNKNOWN, 0);
    // return self.createRenderTarget();
}

// /// Call this first in your main event loop.
// /// This is NON-OPTIONAL!
// /// Your window will freeze otherwise.
// /// Time spent figuring this out: ~4 hours
// pub fn isExitRequested() bool {
//     var msg: ui.MSG = std.mem.zeroes(ui.MSG);

//     while (ui.PeekMessageA(&msg, null, 0, 0, ui.PM_REMOVE) != 0) {
//         _ = ui.TranslateMessage(&msg);
//         _ = ui.DispatchMessageW(&msg);
//         if (msg.message == ui.WM_QUIT) {
//             return true;
//         }
//     }

//     return false;
// }

fn isOk(res: win.foundation.HRESULT) bool {
    return res == win.foundation.S_OK;
}

const Shaders = struct {
    vertex: *win32.ID3D11VertexShader,
    pixel: *win32.ID3D11PixelShader,
    pub fn init(d3d: *const D3d) Shaders {
        var error_blob: ?*win32.ID3DBlob = null;

        var vs_blob: ?*win32.ID3DBlob = undefined;
        {
            const hr = win32.D3DCompile(
                shader.ptr,
                shader.len,
                null,
                null,
                null,
                "VSMain",
                "vs_4_0",
                win32.D3DCOMPILE_ENABLE_STRICTNESS,
                0,
                &vs_blob,
                &error_blob,
            );
            reportShaderError(.vertex, error_blob);
            error_blob = null;
            if (hr < 0) {
                fatalHr("D3DCompileVertexShader", hr);
            }
        }
        defer _ = vs_blob.IUnknown.Release();

        var ps_blob: ?*win32.ID3DBlob = undefined;
        {
            const hr = win32.D3DCompile(
                shader.ptr,
                shader.len,
                null,
                null,
                null,
                "PSMain",
                "ps_4_0",
                win32.D3DCOMPILE_ENABLE_STRICTNESS,
                0,
                &ps_blob,
                &error_blob,
            );
            reportShaderError(.vertex, error_blob);
            error_blob = null;
            if (hr < 0) {
                fatalHr("D3DCompilePixelShader", hr);
            }
        }
        defer _ = ps_blob.IUnknown.Release();

        var vertex_shader: *win32.ID3D11VertexShader = undefined;
        {
            const hr = d3d.device.CreateVertexShader(
                @ptrCast(vs_blob.GetBufferPointer()),
                vs_blob.GetBufferSize(),
                null,
                &vertex_shader,
            );
            if (hr < 0) fatalHr("CreateVertexShader", hr);
        }
        errdefer vertex_shader.IUnknown.Release();

        var pixel_shader: *win32.ID3D11PixelShader = undefined;
        {
            const hr = d3d.device.CreatePixelShader(
                @ptrCast(ps_blob.GetBufferPointer()),
                ps_blob.GetBufferSize(),
                null,
                &pixel_shader,
            );
            if (hr < 0) fatalHr("CreatePixelShader", hr);
        }
        errdefer pixel_shader.IUnknown.Release();

        return .{
            .vertex = vertex_shader,
            .pixel = pixel_shader,
        };
    }
    pub fn deinit(self: Shaders) void {
        _ = self.pixel.IUnknown.Release();
        _ = self.vertex.IUnknown.Release();
    }
};
fn reportShaderError(kind: enum { vertex, pixel }, maybe_error_blob: ?*win32.ID3DBlob) void {
    const err = maybe_error_blob orelse return;
    defer _ = err.IUnknown.Release();
    const ptr: [*]const u8 = @ptrCast(err.GetBufferPointer() orelse return);
    const str = ptr[0..err.GetBufferSize()];
    log.err("{s} shader error:\n{s}\n", .{ @tagName(kind), str });
    std.debug.panic("{s} shader error:\n{s}\n", .{ @tagName(kind), str });
}

fn createRasterizerState(ctx: Context) !void {
    const state = stateFromHwnd(hwndFromCtx(ctx));

    var raster_desc = std.mem.zeroes(dx.D3D11_RASTERIZER_DESC);
    raster_desc.FillMode = dx.D3D11_FILL_MODE.SOLID;
    raster_desc.CullMode = dx.D3D11_CULL_BACK;
    raster_desc.FrontCounterClockwise = 1;
    raster_desc.DepthClipEnable = 0;
    raster_desc.ScissorEnable = 1;

    var rasterizer_result: @TypeOf(state.rasterizer.?) = undefined;
    const rasterizer_res = state.d3d.device.CreateRasterizerState(&raster_desc, &rasterizer_result);
    state.rasterizer = rasterizer_result;
    if (!isOk(rasterizer_res)) {
        return error.RasterizerInitFailed;
    }

    state.d3d.context.RSSetState(state.rasterizer);
}

fn createRenderTarget(ctx: Context) !void {
    const state = stateFromHwnd(hwndFromCtx(ctx));
    var back_buffer: ?*dx.ID3D11Texture2D = null;

    _ = state.swap_chain.GetBuffer(0, dx.IID_ID3D11Texture2D, @ptrCast(&back_buffer));
    defer _ = back_buffer.?.IUnknown.Release();

    var render_target_result: @TypeOf(state.render_target.?) = undefined;
    _ = state.d3d.device.CreateRenderTargetView(
        @ptrCast(back_buffer),
        null,
        &render_target_result,
    );
    state.render_target = render_target_result;
}

fn cleanupRenderTarget(state: *WindowState) void {
    if (state.render_target) |mrtv| {
        _ = mrtv.IUnknown.Release();
        state.render_target = null;
    }
}

fn createInputLayout(state: *WindowState) !void {
    const input_layout_desc = &[_]dx.D3D11_INPUT_ELEMENT_DESC{
        .{ .SemanticName = "POSITION", .SemanticIndex = 0, .Format = win32.DXGI_FORMAT_R32G32B32_FLOAT, .InputSlot = 0, .AlignedByteOffset = 0, .InputSlotClass = dx.D3D11_INPUT_PER_VERTEX_DATA, .InstanceDataStepRate = 0 },
        .{ .SemanticName = "COLOR", .SemanticIndex = 0, .Format = win32.DXGI_FORMAT_R32G32B32A32_FLOAT, .InputSlot = 0, .AlignedByteOffset = 12, .InputSlotClass = dx.D3D11_INPUT_PER_VERTEX_DATA, .InstanceDataStepRate = 0 },
        .{ .SemanticName = "TEXCOORD", .SemanticIndex = 0, .Format = win32.DXGI_FORMAT_R32G32_FLOAT, .InputSlot = 0, .AlignedByteOffset = 28, .InputSlotClass = dx.D3D11_INPUT_PER_VERTEX_DATA, .InstanceDataStepRate = 0 },
    };

    const num_elements = input_layout_desc.len;

    var vertex_layout_result: @TypeOf(state.vertex_layout.?) = undefined;
    const res = state.d3d.device.CreateInputLayout(
        input_layout_desc,
        num_elements,
        @ptrCast(state.vertex_bytes.?.GetBufferPointer()),
        state.vertex_bytes.?.GetBufferSize(),
        &vertex_layout_result,
    );
    state.vertex_layout = vertex_layout_result;

    if (!isOk(res)) {
        return error.VertexLayoutCreationFailed;
    }

    state.d3d.context.IASetInputLayout(state.vertex_layout);
}

fn recreateShaderView(state: *WindowState, texture: *anyopaque) void {
    const tex: *dx.ID3D11Texture2D = @ptrCast(@alignCast(texture));

    const rvd = dx.D3D11_SHADER_RESOURCE_VIEW_DESC{
        .Format = win32.DXGI_FORMAT.R8G8B8A8_UNORM,
        .ViewDimension = win32.D3D_SRV_DIMENSION_TEXTURE2D,
        .Anonymous = .{
            .Texture2D = .{
                .MostDetailedMip = 0,
                .MipLevels = 1,
            },
        },
    };

    if (state.texture_view) |tv| {
        _ = tv.IUnknown.Release();
    }

    var texture_view_result: @TypeOf(state.texture_view.?) = undefined;
    const rv_result = state.d3d.device.CreateShaderResourceView(
        &tex.ID3D11Resource,
        &rvd,
        &texture_view_result,
    );
    state.texture_view = texture_view_result;

    if (!isOk(rv_result)) {
        log.err("Texture View creation failed", .{});
        @panic("couldn't create texture view");
    }
}

fn createSampler(state: *WindowState) !void {
    var samp_desc = std.mem.zeroes(dx.D3D11_SAMPLER_DESC);
    samp_desc.Filter = dx.D3D11_FILTER.MIN_MAG_POINT_MIP_LINEAR;
    samp_desc.AddressU = dx.D3D11_TEXTURE_ADDRESS_MODE.WRAP;
    samp_desc.AddressV = dx.D3D11_TEXTURE_ADDRESS_MODE.WRAP;
    samp_desc.AddressW = dx.D3D11_TEXTURE_ADDRESS_MODE.WRAP;

    var blend_desc = std.mem.zeroes(dx.D3D11_BLEND_DESC);
    blend_desc.RenderTarget[0].BlendEnable = 1;
    blend_desc.RenderTarget[0].SrcBlend = dx.D3D11_BLEND_ONE;
    blend_desc.RenderTarget[0].DestBlend = dx.D3D11_BLEND_INV_SRC_ALPHA;
    blend_desc.RenderTarget[0].BlendOp = dx.D3D11_BLEND_OP_ADD;
    blend_desc.RenderTarget[0].SrcBlendAlpha = dx.D3D11_BLEND_ONE;
    blend_desc.RenderTarget[0].DestBlendAlpha = dx.D3D11_BLEND_INV_SRC_ALPHA;
    blend_desc.RenderTarget[0].BlendOpAlpha = dx.D3D11_BLEND_OP_ADD;
    blend_desc.RenderTarget[0].RenderTargetWriteMask = @intFromEnum(dx.D3D11_COLOR_WRITE_ENABLE_ALL);

    // TODO: Handle errors better
    var blend_state_result: @TypeOf(state.blend_state.?) = undefined;
    _ = state.d3d.device.CreateBlendState(&blend_desc, &blend_state_result);
    state.blend_state = blend_state_result;
    _ = state.d3d.device_context.OMSetBlendState(state.blend_state, null, 0xffffffff);

    var sampler_result: @TypeOf(state.sampler.?) = undefined;
    const sampler = state.d3d.device.CreateSamplerState(&samp_desc, &sampler_result);
    state.sampler = sampler_result;

    if (!isOk(sampler)) {
        log.err("sampler state could not be iniitialized", .{});
        return error.SamplerStateUninitialized;
    }
}

// If you don't know what they are used for... just don't use them, alright?
fn createBuffer(state: *WindowState, bind_type: anytype, comptime InitialType: type, initial_data: []const InitialType) !*dx.ID3D11Buffer {
    var bd = std.mem.zeroes(dx.D3D11_BUFFER_DESC);
    bd.Usage = dx.D3D11_USAGE_DEFAULT;
    bd.ByteWidth = @intCast(@sizeOf(InitialType) * initial_data.len);
    bd.BindFlags = bind_type;
    bd.CPUAccessFlags = .{};

    var data: dx.D3D11_SUBRESOURCE_DATA = undefined;
    data.pSysMem = @ptrCast(initial_data.ptr);

    var buffer: *dx.ID3D11Buffer = undefined;
    _ = state.d3d.device.CreateBuffer(&bd, &data, &buffer);

    // argument no longer pointer-to-optional since zigwin32 update - 2025-01-10
    //if (buffer) |buf| {
    return buffer;
    //} else {
    //    return error.BufferFailedToCreate;
    //}
}

pub fn backendFromHwnd(hwnd: win32.HWND) dvui.Backend {
    return dvui.Backend.init(@ptrCast(hwnd), @This());
}

fn hwndFromCtx(ctx: Context) win32.HWND {
    return @ptrCast(ctx);
}
pub fn contextFromHwnd(hwnd: win32.HWND) Context {
    return @ptrCast(hwnd);
}

fn stateFromHwnd(hwnd: win32.HWND) *WindowState {
    const addr: usize = @bitCast(win32.GetWindowLongPtrW(hwnd, @enumFromInt(0)));
    if (addr == 0) std.debug.panic("window is missing it's state!", .{});
    return @ptrFromInt(addr);
}

// ############ Satisfy DVUI interfaces ############
pub fn textureCreate(ctx: Context, pixels: [*]u8, width: u32, height: u32, ti: dvui.enums.TextureInterpolation) dvui.Texture {
    const state = stateFromHwnd(hwndFromCtx(ctx));
    _ = ti;
    var texture: *dx.ID3D11Texture2D = undefined;
    var tex_desc = dx.D3D11_TEXTURE2D_DESC{
        .Width = width,
        .Height = height,
        .MipLevels = 1,
        .ArraySize = 1,
        .Format = win32.DXGI_FORMAT.R8G8B8A8_UNORM,
        .SampleDesc = .{
            .Count = 1,
            .Quality = 0,
        },
        .Usage = dx.D3D11_USAGE_DEFAULT,
        .BindFlags = dx.D3D11_BIND_SHADER_RESOURCE,
        .CPUAccessFlags = .{},
        .MiscFlags = .{},
    };

    var resource_data = std.mem.zeroes(dx.D3D11_SUBRESOURCE_DATA);
    resource_data.pSysMem = pixels;
    resource_data.SysMemPitch = width * 4; // 4 byte per pixel (RGBA)

    const tex_creation = state.d3d.device.CreateTexture2D(
        &tex_desc,
        &resource_data,
        &texture,
    );

    if (!isOk(tex_creation)) {
        log.err("Texture creation failed.", .{});
        @panic("couldn't create texture");
    }

    return dvui.Texture{ .ptr = texture, .width = width, .height = height };
}

pub fn textureCreateTarget(ctx: Context, width: u32, height: u32, interpolation: dvui.enums.TextureInterpolation) !dvui.Texture {
    _ = ctx;
    _ = width;
    _ = height;
    _ = interpolation;
    dvui.log.debug("dx11 textureCreateTarget unimplemented", .{});
    return error.TextureCreate;
}

pub fn textureRead(ctx: Context, texture: dvui.Texture, pixels_out: [*]u8) error{TextureRead}!void {
    _ = ctx;
    _ = texture;
    _ = pixels_out;
    dvui.log.debug("dx11 textureRead unimplemented", .{});
    return error.TextureRead;
}

pub fn textureDestroy(ctx: Context, texture: dvui.Texture) void {
    _ = ctx;
    const tex: *dx.ID3D11Texture2D = @ptrCast(@alignCast(texture.ptr));
    _ = tex.IUnknown.Release();
}

pub fn renderTarget(ctx: Context, texture: ?dvui.Texture) void {
    _ = ctx;
    _ = texture;
    dvui.log.debug("dx11 renderTarget unimplemented", .{});
}

pub fn drawClippedTriangles(
    ctx: Context,
    texture: ?dvui.Texture,
    vtx: []const dvui.Vertex,
    idx: []const u16,
    clipr: ?dvui.Rect,
) void {
    _ = ctx;
    _ = texture;
    _ = vtx;
    _ = idx;
    _ = clipr;
    // self.setViewport();

    // if (self.render_target == null) {
    //     self.createRenderTarget() catch |err| {
    //         log.err("render target could not be initialized: {}", .{err});
    //         return;
    //     };
    // }

    // if (state.vertex_shader == null or state.pixel_shader == null) {
    //     self.initShader() catch |err| {
    //         log.err("shaders could not be initialized: {}", .{err});
    //         return;
    //     };
    // }

    // if (state.vertex_layout == null) {
    //     self.createInputLayout() catch |err| {
    //         log.err("Failed to create vertex layout: {}", .{err});
    //         return;
    //     };
    // }

    // if (state.sampler == null) {
    //     self.createSampler() catch |err| {
    //         log.err("sampler could not be initialized: {}", .{err});
    //         return;
    //     };
    // }

    // if (state.rasterizer == null) {
    //     self.createRasterizerState() catch |err| {
    //         log.err("Creating rasterizer failed: {}", .{err});
    //     };
    // }

    // var stride: usize = @sizeOf(SimpleVertex);
    // var offset: usize = 0;
    // const converted_vtx = self.convertVertices(vtx, texture == null) catch @panic("OOM");
    // defer self.arena.free(converted_vtx);

    // // Do yourself a favour and don't touch it.
    // // End() isn't being called all the time, so it's kind of futile.
    // if (state.vertex_buffer) |vb| {
    //     _ = vb.IUnknown.Release();
    // }
    // state.vertex_buffer = self.createBuffer(dx.D3D11_BIND_VERTEX_BUFFER, SimpleVertex, converted_vtx) catch {
    //     log.err("no vertex buffer created", .{});
    //     return;
    // };

    // // Do yourself a favour and don't touch it.
    // // End() isn't being called all the time, so it's kind of futile.
    // if (state.index_buffer) |ib| {
    //     _ = ib.IUnknown.Release();
    // }
    // state.index_buffer = self.createBuffer(dx.D3D11_BIND_INDEX_BUFFER, u16, idx) catch {
    //     log.err("no index buffer created", .{});
    //     return;
    // };

    // self.setViewport();

    // if (texture) |tex| self.recreateShaderView(tex.ptr);

    // var scissor_rect: ?RECT = std.mem.zeroes(RECT);
    // var nums: u32 = 1;
    // self.device_context.RSGetScissorRects(&nums, @ptrCast(&scissor_rect));

    // if (clipr) |cr| {
    //     const new_clip: RECT = .{
    //         .left = @intFromFloat(cr.x),
    //         .top = @intFromFloat(cr.y),
    //         .right = @intFromFloat(@ceil(cr.x + cr.w)),
    //         .bottom = @intFromFloat(@ceil(cr.y + cr.h)),
    //     };
    //     self.device_context.RSSetScissorRects(nums, @ptrCast(&new_clip));
    // } else {
    //     scissor_rect = null;
    // }

    // self.device_context.IASetVertexBuffers(0, 1, @ptrCast(&state.vertex_buffer), @ptrCast(&stride), @ptrCast(&offset));
    // self.device_context.IASetIndexBuffer(state.index_buffer, win32.DXGI_FORMAT.R16_UINT, 0);
    // self.device_context.IASetPrimitiveTopology(d3d.D3D11_PRIMITIVE_TOPOLOGY_TRIANGLELIST);

    // self.device_context.OMSetRenderTargets(1, @ptrCast(&self.render_target), null);
    // self.device_context.VSSetShader(state.vertex_shader, null, 0);
    // self.device_context.PSSetShader(state.pixel_shader, null, 0);

    // self.device_context.PSSetShaderResources(0, 1, @ptrCast(&state.texture_view));
    // self.device_context.PSSetSamplers(0, 1, @ptrCast(&state.sampler));
    // self.device_context.DrawIndexed(@intCast(idx.len), 0, 0);
    // if (scissor_rect) |srect| self.device_context.RSSetScissorRects(nums, @ptrCast(&srect));
}

pub const WindowState = struct {
    d3d: *const D3d,
    callback: *const fn (CallbackContext, *dvui.Window) anyerror!void,
    vsync: bool,
    swap_chain: *win32.IDXGISwapChain2,

    dvui_window: ?dvui.Window = null,

    shaders: ?Shaders = null,
    vertex_layout: ?*dx.ID3D11InputLayout = null,
    vertex_buffer: ?*dx.ID3D11Buffer = null,
    index_buffer: ?*dx.ID3D11Buffer = null,
    texture_view: ?*dx.ID3D11ShaderResourceView = null,
    sampler: ?*dx.ID3D11SamplerState = null,
    rasterizer: ?*dx.ID3D11RasterizerState = null,
    blend_state: ?*dx.ID3D11BlendState = null,

    arena: ?std.mem.Allocator = null,

    pub fn init(d3d: *const D3d, hwnd: win32.HWND) WindowState {
        const swap_chain = initSwapChain(d3d.device, hwnd);
        return .{ .swap_chain = swap_chain };
    }

    pub fn deinit(self: *WindowState) void {
        if (self.blend_state) |bs| _ = bs.IUnknown.Release();
        if (self.rasterizer) |r| _ = r.IUnknown.Release();
        if (self.sampler) |s| _ = s.IUnknown.Release();
        if (self.texture_view) |tv| _ = tv.IUnknown.Release();
        if (self.index_buffer) |ib| _ = ib.IUnknown.Release();
        if (self.vertex_buffer) |vb| _ = vb.IUnknown.Release();
        if (self.vertex_layout) |vl| _ = vl.IUnknown.Release();
        if (self.shaders) |s| s.deinit();
        if (self.dvui_window) |*dvui_win| {
            dvui_win.deinit();
        }
        self.* = undefined;
    }

    pub fn getArena(self: *const WindowState, comptime context: []const u8) std.mem.Allocator {
        return self.arena orelse @panic(context ++ " without an allocator");
    }
};
// const WindowState2 = struct {
//     /// The render target
//     render_target: ?*dx.ID3D11RenderTargetView = null,
//     // TODO: Implement touch events
//     //   might require help with that,
//     //   since i have no touch input device that runs windows.
//     /// Whether there are touch events
//     touch_mouse_events: bool = false,
//     /// Whether to log events
//     log_events: bool = false,
//     /// The scaling of DVUI
//     initial_scale: f32 = 1.0,

//     /// The cursor that has been set
//     cursor_last: dvui.enums.Cursor = .arrow,

//     /// The arena allocator (usually)
//     arena: std.mem.Allocator = undefined,
// };

pub fn begin(ctx: Context, arena: std.mem.Allocator) void {
    const hwnd = hwndFromCtx(ctx);
    const state = stateFromHwnd(hwnd);
    state.arena = arena;

    // const dpi = win32.dpiFromHwnd(hwnd);
    // const pixel_size = self.pixelSize();
    // var scissor_rect: RECT = .{
    //     .left = 0,
    //     .top = 0,
    //     //.right = win32.scaleDpi(i32, @intFromFloat(@round(pixel_size.w)),
    //     //.bottom = @intFromFloat(@round(pixel_size.h)),
    // };
    // self.d3d.context.RSSetScissorRects(1, @ptrCast(&scissor_rect));
    {
        var rect: win32.RECT = undefined;
        _ = win32.GetClientRect(hwnd, &rect);
        state.d3d.context.RSSetScissorRects(1, @ptrCast(&rect));
    }

    // !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
    // var clear_color = [_]f32{ 1.0, 1.0, 1.0, 0.0 };
    // state.d3d.context.ClearRenderTargetView(state.render_target orelse return, @ptrCast((&clear_color).ptr));
}

pub fn end(ctx: Context) void {
    const state = stateFromHwnd(hwndFromCtx(ctx));

    // NOTE: don't enable vsync, it causes the gpu to lag behind horribly
    //       if we flood it with resize events
    {
        const hr = state.swap_chain.IDXGISwapChain.Present(if (state.vsync) 1 else 0, 0);
        if (hr < 0) fatalHr("SwapChainPresent", hr);
    }
}

pub fn pixelSize(ctx: Context) dvui.Size {
    const size = win32.getClientSize(hwndFromCtx(ctx));
    return .{
        .w = @floatFromInt(size.cx),
        .h = @floatFromInt(size.cy),
    };
}

pub fn windowSize(ctx: Context) dvui.Size {
    var rect: win32.RECT = undefined;
    if (0 == win32.GetWindowRect(hwndFromCtx(ctx), &rect)) win32.panicWin32(
        "GetWindowRect",
        win32.GetLastError(),
    );
    return .{
        .w = @floatFromInt(rect.right - rect.left),
        .h = @floatFromInt(rect.bottom - rect.top),
    };
}

pub fn contentScale(ctx: Context) f32 {
    _ = ctx;
    return 1.0; // what is this...is it related to DPI?
    //return self.initial_scale;
}

// pub fn hasEvent(_: Context) bool {
//     return false;
// }

pub fn backend(ctx: Context) dvui.Backend {
    return dvui.Backend.init(ctx, @This());
}

pub fn nanoTime(ctx: Context) i128 {
    _ = ctx;
    return std.time.nanoTimestamp();
}

pub fn sleep(ctx: Context, ns: u64) void {
    _ = ctx;
    std.time.sleep(ns);
}

pub fn clipboardText(ctx: Context) ![]const u8 {
    const state = stateFromHwnd(hwndFromCtx(ctx));
    const arena = state.getArena("clipboardText called");
    const data_x = win.system.data_exchange;
    const opened = data_x.OpenClipboard(hwndFromCtx(ctx)) == win.zig.TRUE;
    defer _ = data_x.CloseClipboard();
    if (!opened) {
        return "";
    }

    // istg, windows. why. why utf16.
    const data_handle = data_x.GetClipboardData(@intFromEnum(win.system.system_services.CF_UNICODETEXT)) orelse return "";

    var res: []u8 = undefined;
    {
        const handle: isize = @intCast(@intFromPtr(data_handle));
        const data: [*:0]u16 = @ptrCast(@alignCast(win.system.memory.GlobalLock(handle) orelse return ""));
        defer _ = win.system.memory.GlobalUnlock(handle);

        // we want this to be a sane format.
        const len = std.mem.indexOfSentinel(u16, 0, data);
        res = std.unicode.utf16LeToUtf8Alloc(arena, data[0..len]) catch return error.OutOfMemory;
    }

    return res;
}

pub fn clipboardTextSet(ctx: Context, text: []const u8) !void {
    const state = stateFromHwnd(hwndFromCtx(ctx));
    const arena = state.getArena("clipboardTextSet called");
    const data_x = win.system.data_exchange;
    const memory = win.system.memory;
    const opened = data_x.OpenClipboard(hwndFromCtx(ctx)) == win.zig.TRUE;
    defer _ = data_x.CloseClipboard();
    if (!opened) {
        return;
    }

    const handle = memory.GlobalAlloc(memory.GMEM_MOVEABLE, text.len * @sizeOf(u16) + 1); // don't forget the nullbyte
    if (handle != 0x0) {
        const as_utf16 = std.unicode.utf8ToUtf16LeAlloc(arena, text) catch return error.OutOfMemory;
        defer arena.free(as_utf16);

        const data: [*:0]u16 = @ptrCast(@alignCast(win.system.memory.GlobalLock(handle) orelse return));
        defer _ = win.system.memory.GlobalUnlock(handle);

        for (as_utf16, 0..) |wide, i| {
            data[i] = wide;
        }
    } else {
        return error.OutOfMemory;
    }

    _ = data_x.EmptyClipboard();
    const handle_usize: usize = @intCast(handle);
    _ = data_x.SetClipboardData(@intFromEnum(win.system.system_services.CF_UNICODETEXT), @ptrFromInt(handle_usize));
}

pub fn openURL(ctx: Context, url: []const u8) !void {
    _ = ctx;
    _ = url;
}

pub fn refresh(ctx: Context) void {
    _ = ctx;
}

pub fn addEvent(ctx: Context, window: *dvui.Window, key_event: KeyEvent) !bool {
    _ = ctx;
    const event = key_event.target;
    const action = key_event.action;
    switch (event) {
        .keyboard_key => |ev| {
            return window.addEventKey(.{
                .code = ev,
                .action = if (action == .up) .up else .down,
                .mod = dvui.enums.Mod.none,
            });
        },
        .mouse_key => |ev| {
            return window.addEventMouseButton(ev, if (action == .up) .release else .press);
        },
        .mouse_event => |ev| {
            return window.addEventMouseMotion(@floatFromInt(ev.x), @floatFromInt(ev.y));
        },
        .wheel_event => |ev| {
            return window.addEventMouseWheel(@floatFromInt(ev), .vertical);
        },
        .none => return false,
    }
}

pub fn addAllEvents(ctx: Context, window: *dvui.Window) !bool {
    _ = ctx;
    _ = window;
    return false;
}

pub fn setCursor(ctx: Context, new_cursor: dvui.enums.Cursor) void {
    _ = ctx;
    const converted_cursor = switch (new_cursor) {
        .arrow => win32.IDC_ARROW,
        .ibeam => win32.IDC_IBEAM,
        .wait, .wait_arrow => win32.IDC_WAIT,
        .crosshair => win32.IDC_CROSS,
        .arrow_nw_se => win32.IDC_ARROW,
        .arrow_ne_sw => win32.IDC_ARROW,
        .arrow_w_e => win32.IDC_ARROW,
        .arrow_n_s => win32.IDC_ARROW,
        .arrow_all => win32.IDC_ARROW,
        .bad => win32.IDC_NO,
        .hand => win32.IDC_HAND,
    };

    _ = win32.LoadCursorW(null, converted_cursor);
}

// ############ Event Handling via wnd proc ############
pub fn wndProc(hwnd: HWND, umsg: u32, wparam: win32.WPARAM, lparam: win32.LPARAM) callconv(w.WINAPI) w.LRESULT {
    // !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
    //std.log.info("msg {}", .{umsg});

    //const instance = inst orelse return win32.DefWindowProcW(hwnd, umsg, wparam, lparam);

    switch (umsg) {
        win32.WM_CREATE => {
            const create_struct: *win32.CREATESTRUCTW = @ptrFromInt(@as(usize, @bitCast(lparam)));
            const args: *CreateWindowArgs = @alignCast(@ptrCast(create_struct.lpCreateParams));
            args.state.* = .{
                .d3d = args.d3d,
                .callback = args.callback,
                .vsync = args.vsync,
                .swap_chain = initSwapChain(args.d3d.device, hwnd),
            };
            std.debug.assert(0 == win32.SetWindowLongPtrW(
                hwnd,
                @enumFromInt(0),
                @bitCast(@intFromPtr(args.state)),
            ));
            std.debug.assert(stateFromHwnd(hwnd) == args.state);
            args.state.dvui_window = dvui.Window.init(args.src, args.gpa, backendFromHwnd(hwnd), .{}) catch |e| {
                args.create_error = e;
                return -1; // fail
            };
            return 0;
        },
        win32.WM_DESTROY => {
            const state = stateFromHwnd(hwnd);
            if (state.dvui_window) |*dvui_win| {
                state.callback(.destroy, dvui_win) catch {};
            }
            state.deinit();
            return 0;
        },
        win32.WM_CLOSE => {
            _ = win32.DestroyWindow(hwnd);
            return 0;
        },
        win32.WM_PAINT => {
            _, const ps = win32.beginPaint(hwnd);
            defer win32.endPaint(hwnd, &ps);

            const state = stateFromHwnd(hwnd);
            state.callback(.ready, &state.dvui_window.?) catch |e| std.debug.panic(
                "ready callback failed with {s}",
                .{@errorName(e)},
            );
            // _ = win32.FillRect(hdc, @ptrCast(&ps.rcPaint), @ptrFromInt(@intFromEnum(win32.COLOR_WINDOW) + 1));
            return 0;
        },
        // win32.WM_SIZE => {
        //     const resize: packed struct { width: i16, height: i16, _upper: i32 } = @bitCast(lparam);
        //     instance.options.size.w = @floatFromInt(resize.width);
        //     instance.options.size.h = @floatFromInt(resize.height);
        //     instance.handleSwapChainResizing(@intCast(resize.width), @intCast(resize.height)) catch {
        //         log.err("Failed to handle swap chain resizing...", .{});
        //     };
        // },
        // win32.WM_KEYDOWN, win32.WM_SYSKEYDOWN => {
        //     if (std.meta.intToEnum(key.VIRTUAL_KEY, wparam)) |as_vkey| {
        //         const conv_vkey = convertVKeyToDvuiKey(as_vkey);
        //         if (wind) |window| {
        //             const dk = DvuiKey{ .keyboard_key = conv_vkey };
        //             _ = instance.addEvent(
        //                 window,
        //                 KeyEvent{ .target = dk, .action = .down },
        //             ) catch {};
        //         }
        //     } else |err| {
        //         log.err("invalid key found: {}", .{err});
        //     }
        // },
        // win32.WM_LBUTTONDOWN, win32.WM_LBUTTONDBLCLK => {
        //     const lbutton = dvui.enums.Button.left;
        //     if (wind) |window| {
        //         const dk = DvuiKey{ .mouse_key = lbutton };
        //         _ = instance.addEvent(
        //             window,
        //             KeyEvent{ .target = dk, .action = .down },
        //         ) catch {};
        //     }
        // },
        // win32.WM_RBUTTONDOWN => {
        //     const rbutton = dvui.enums.Button.right;
        //     if (wind) |window| {
        //         const dk = DvuiKey{ .mouse_key = rbutton };
        //         _ = instance.addEvent(
        //             window,
        //             KeyEvent{ .target = dk, .action = .down },
        //         ) catch {};
        //     }
        // },
        // win32.WM_MBUTTONDOWN => {
        //     const mbutton = dvui.enums.Button.middle;
        //     if (wind) |window| {
        //         const dk = DvuiKey{ .mouse_key = mbutton };
        //         _ = instance.addEvent(
        //             window,
        //             KeyEvent{ .target = dk, .action = .down },
        //         ) catch {};
        //     }
        // },
        // win32.WM_XBUTTONDOWN => {
        //     const xbutton: packed struct { _upper: u16, which: u16, _lower: u32 } = @bitCast(wparam);
        //     const variant = if (xbutton.which == 1) dvui.enums.Button.four else dvui.enums.Button.five;
        //     if (wind) |window| {
        //         const dk = DvuiKey{ .mouse_key = variant };
        //         _ = instance.addEvent(
        //             window,
        //             KeyEvent{ .target = dk, .action = .down },
        //         ) catch {};
        //     }
        // },
        // win32.WM_MOUSEMOVE => {
        //     const lparam_low: i32 = @truncate(lparam);
        //     const bits: packed struct { x: i16, y: i16 } = @bitCast(lparam_low);
        //     if (wind) |window| {
        //         const mouse_x, const mouse_y = .{ bits.x, bits.y };
        //         _ = instance.addEvent(
        //             window,
        //             KeyEvent{ .target = DvuiKey{
        //                 .mouse_event = .{ .x = mouse_x, .y = mouse_y },
        //             }, .action = .down },
        //         ) catch {};
        //     }
        // },
        // win32.WM_KEYUP, win32.WM_SYSKEYUP => {
        //     if (std.meta.intToEnum(key.VIRTUAL_KEY, wparam)) |as_vkey| {
        //         const conv_vkey = convertVKeyToDvuiKey(as_vkey);
        //         if (wind) |window| {
        //             const dk = DvuiKey{ .keyboard_key = conv_vkey };
        //             _ = instance.addEvent(
        //                 window,
        //                 KeyEvent{ .target = dk, .action = .up },
        //             ) catch {};
        //         }
        //     } else |err| {
        //         log.err("invalid key found: {}", .{err});
        //     }
        // },
        // win32.WM_LBUTTONUP => {
        //     const lbutton = dvui.enums.Button.left;
        //     if (wind) |window| {
        //         const dk = DvuiKey{ .mouse_key = lbutton };
        //         _ = instance.addEvent(
        //             window,
        //             KeyEvent{ .target = dk, .action = .up },
        //         ) catch {};
        //     }
        // },
        // win32.WM_RBUTTONUP => {
        //     const rbutton = dvui.enums.Button.right;
        //     if (wind) |window| {
        //         const dk = DvuiKey{ .mouse_key = rbutton };
        //         _ = instance.addEvent(
        //             window,
        //             KeyEvent{ .target = dk, .action = .up },
        //         ) catch {};
        //     }
        // },
        // win32.WM_MBUTTONUP => {
        //     const mbutton = dvui.enums.Button.middle;
        //     if (wind) |window| {
        //         const dk = DvuiKey{ .mouse_key = mbutton };
        //         _ = instance.addEvent(
        //             window,
        //             KeyEvent{ .target = dk, .action = .up },
        //         ) catch {};
        //     }
        // },
        // win32.WM_XBUTTONUP => {
        //     const xbutton: packed struct { _upper: u16, which: u16, _lower: u32 } = @bitCast(wparam);
        //     const variant = if (xbutton.which == 1) dvui.enums.Button.four else dvui.enums.Button.five;
        //     if (wind) |window| {
        //         const dk = DvuiKey{ .mouse_key = variant };
        //         _ = instance.addEvent(
        //             window,
        //             KeyEvent{ .target = dk, .action = .up },
        //         ) catch {};
        //     }
        // },
        // win32.WM_MOUSEWHEEL => {
        //     const higher: isize = @intCast(wparam >> 16);
        //     const wheel_info: i16 = @truncate(higher);
        //     if (wind) |window| {
        //         _ = instance.addEvent(window, KeyEvent{
        //             .target = .{ .wheel_event = wheel_info },
        //             .action = .none,
        //         }) catch {};
        //     }
        // },
        // win32.WM_CHAR => {
        //     if (wind) |window| {
        //         const ascii_char: u8 = @truncate(wparam);
        //         if (std.ascii.isPrint(ascii_char)) {
        //             const string: []const u8 = &.{ascii_char};
        //             _ = window.addEventText(string) catch {};
        //         }
        //     }
        // },
        else => return win32.DefWindowProcW(hwnd, umsg, wparam, lparam),
    }
}

// ############ Utilities ############
fn convertSpaceToNDC(ctx: Context, x: f32, y: f32) XMFLOAT3 {
    _ = ctx;
    _ = x;
    _ = y;
    @panic("todo");
    // return XMFLOAT3{
    //     .x = (2.0 * x / self.options.size.w) - 1.0,
    //     .y = 1.0 - (2.0 * y / self.options.size.h),
    //     .z = 0.0,
    // };
}

fn convertVertices(ctx: Context, vtx: []const dvui.Vertex, signal_invalid_uv: bool) ![]SimpleVertex {
    const state = stateFromHwnd(hwndFromCtx(ctx));
    const arena = state.getArena("countVertices called");
    const simple_vertex = try arena.alloc(SimpleVertex, vtx.len);
    for (vtx, simple_vertex) |v, *s| {
        const r: f32 = @floatFromInt(v.col.r);
        const g: f32 = @floatFromInt(v.col.g);
        const b: f32 = @floatFromInt(v.col.b);
        const a: f32 = @floatFromInt(v.col.a);

        s.* = .{
            .position = ctx.convertSpaceToNDC(v.pos.x, v.pos.y),
            .color = .{ .r = r / 255.0, .g = g / 255.0, .b = b / 255.0, .a = a / 255.0 },
            .texcoord = if (signal_invalid_uv) .{ .x = -1.0, .y = -1.0 } else .{ .x = v.uv[0], .y = v.uv[1] },
        };
    }

    return simple_vertex;
}

// pub const RegisterClass = windows.RegisterClass;
// pub const createWindow = windows.createWindow;
// fn createWindow(instance: HINSTANCE, options: InitOptions) !WindowOptions {
//     const wnd_title = try std.unicode.utf8ToUtf16LeAllocZ(options.allocator, options.title);
//     const wnd_class: WNDCLASSEX = .{
//         .cbSize = @sizeOf(WNDCLASSEX),
//         .style = .{ .DBLCLKS = 1, .OWNDC = 1 },
//         .lpfnWndProc = wndProc,
//         .cbClsExtra = 0,
//         .cbWndExtra = 0,
//         .hInstance = instance,
//         .hIcon = null,
//         .hCursor = ui.LoadCursorW(null, ui.IDC_ARROW),
//         .hbrBackground = null,
//         .lpszMenuName = null,
//         .lpszClassName = @ptrCast(wnd_title.ptr),
//         .hIconSm = null,
//     };
//     var wnd_size: RECT = .{
//         .left = 0,
//         .top = 0,
//         .right = @intFromFloat(options.size.w),
//         .bottom = @intFromFloat(options.size.h),
//     };

//     _ = ui.RegisterClassExW(&wnd_class);
//     var overlap = ui.WS_OVERLAPPEDWINDOW;
//     _ = ui.AdjustWindowRectEx(
//         @ptrCast(&wnd_size),
//         overlap,
//         w.FALSE,
//         .{ .APPWINDOW = 1, .WINDOWEDGE = 1 },
//     );
//     overlap.VISIBLE = 1;

//     const min_size = options.min_size orelse dvui.Size{
//         .w = @floatFromInt(wnd_size.right - wnd_size.left),
//         .h = @floatFromInt(wnd_size.bottom - wnd_size.top),
//     };
//     const wnd = ui.CreateWindowExW(
//         .{ .APPWINDOW = 1, .WINDOWEDGE = 1 },
//         wnd_title,
//         wnd_title,
//         overlap,
//         ui.CW_USEDEFAULT,
//         ui.CW_USEDEFAULT,
//         @intFromFloat(min_size.w),
//         @intFromFloat(min_size.h),
//         null,
//         null,
//         instance,
//         null,
//     ) orelse {
//         log.err("Failed to create window: {}\nQuitting...", .{win.foundation.GetLastError()});
//         std.process.exit(1);
//     };

//     const wnd_dc = win32.GetDC(wnd).?;
//     const dpi = hi_dpi.GetDpiForWindow(wnd);
//     const xcenter = @divFloor(hi_dpi.GetSystemMetricsForDpi(@intFromEnum(ui.SM_CXSCREEN), dpi), 2);
//     const ycenter = @divFloor(hi_dpi.GetSystemMetricsForDpi(@intFromEnum(ui.SM_CYSCREEN), dpi), 2);

//     const width_floor: i32 = @intFromFloat(@divFloor(options.size.w, 2));
//     const height_floor: i32 = @intFromFloat(@divFloor(options.size.h, 2));

//     wnd_size.left = xcenter - width_floor;
//     wnd_size.top = ycenter - height_floor;
//     wnd_size.right = wnd_size.left + width_floor;
//     wnd_size.bottom = wnd_size.top + height_floor;

//     _ = ui.SetWindowPos(wnd, null, wnd_size.left, wnd_size.top, wnd_size.right, wnd_size.bottom, ui.SWP_NOCOPYBITS);

//     return WindowOptions{
//         .is_window_owned = true,
//         .alloc = options.allocator,
//         .instance = instance,
//         .hwnd = wnd,
//         .hwnd_dc = wnd_dc,
//         .utf16_wnd_title = wnd_title,
//     };
// }

fn getDxgiFactory(device: *win32.ID3D11Device) *win32.IDXGIFactory2 {
    const dxgi_device = win32ext.queryInterface(device, win32.IDXGIDevice);
    defer _ = dxgi_device.IUnknown.Release();

    var adapter: *win32.IDXGIAdapter = undefined;
    {
        const hr = dxgi_device.GetAdapter(&adapter);
        if (hr < 0) fatalHr("GetDxgiAdapter", hr);
    }
    defer _ = adapter.IUnknown.Release();

    var factory: *win32.IDXGIFactory2 = undefined;
    {
        const hr = adapter.IDXGIObject.GetParent(win32.IID_IDXGIFactory2, @ptrCast(&factory));
        if (hr < 0) fatalHr("GetDxgiFactory", hr);
    }
    return factory;
}

const swap_chain_flags: u32 = @intFromEnum(win32.DXGI_SWAP_CHAIN_FLAG_FRAME_LATENCY_WAITABLE_OBJECT);

fn initSwapChain(
    device: *win32.ID3D11Device,
    hwnd: win32.HWND,
) *win32.IDXGISwapChain2 {
    const factory = getDxgiFactory(device);
    defer _ = factory.IUnknown.Release();

    const swap_chain1: *win32.IDXGISwapChain1 = blk: {
        var swap_chain1: *win32.IDXGISwapChain1 = undefined;
        const desc = win32.DXGI_SWAP_CHAIN_DESC1{
            .Width = 0,
            .Height = 0,
            .Format = .B8G8R8A8_UNORM,
            .Stereo = 0,
            .SampleDesc = .{ .Count = 1, .Quality = 0 },
            .BufferUsage = win32.DXGI_USAGE_RENDER_TARGET_OUTPUT,
            .BufferCount = 2,
            .Scaling = .NONE,
            .SwapEffect = .FLIP_DISCARD,
            .AlphaMode = .IGNORE,
            .Flags = swap_chain_flags,
        };
        {
            const hr = factory.CreateSwapChainForHwnd(
                &device.IUnknown,
                hwnd,
                &desc,
                null,
                null,
                &swap_chain1,
            );
            if (hr < 0) fatalHr("CreateD3dSwapChain", hr);
        }
        break :blk swap_chain1;
    };
    defer _ = swap_chain1.IUnknown.Release();

    {
        const color: win32.DXGI_RGBA = .{ .r = 0.075, .g = 0.075, .b = 0.075, .a = 1.0 };
        const hr = swap_chain1.SetBackgroundColor(&color);
        if (hr < 0) fatalHr("SetBackgroundColor", hr);
    }

    var swap_chain2: *win32.IDXGISwapChain2 = undefined;
    {
        const hr = swap_chain1.IUnknown.QueryInterface(win32.IID_IDXGISwapChain2, @ptrCast(&swap_chain2));
        if (hr < 0) fatalHr("QuerySwapChain2", hr);
    }

    // refterm is doing this but I don't know why
    if (false) {
        const hr = factory.IDXGIFactory.MakeWindowAssociation(hwnd, 0); //DXGI_MWA_NO_ALT_ENTER | DXGI_MWA_NO_WINDOW_CHANGES);
        if (hr < 0) fatalHr("MakeWindowAssoc", hr);
    }

    return swap_chain2;
}

// fn createDeviceD3D(hwnd: HWND, opt: D3dOptions) ?Dx11Backend.Directx11Options {
//     var rc: RECT = undefined;
//     _ = ui.GetClientRect(hwnd, &rc);

//     var sd = std.mem.zeroes(dxgi.DXGI_SWAP_CHAIN_DESC);
//     sd.BufferCount = 6;
//     sd.BufferDesc.Width = @intFromFloat(opt.size.w);
//     sd.BufferDesc.Height = @intFromFloat(opt.size.h);
//     sd.BufferDesc.Format = win32.DXGI_FORMAT_R8G8B8A8_UNORM;
//     sd.BufferDesc.RefreshRate.Numerator = 60;
//     sd.BufferDesc.RefreshRate.Denominator = 1;
//     sd.Flags = @intFromEnum(dxgi.DXGI_SWAP_CHAIN_FLAG_ALLOW_MODE_SWITCH);
//     sd.BufferUsage = dxgi.DXGI_USAGE_RENDER_TARGET_OUTPUT;
//     @setRuntimeSafety(false);
//     sd.OutputWindow = hwnd;
//     @setRuntimeSafety(true);
//     sd.SampleDesc.Count = 1;
//     sd.SampleDesc.Quality = 0;
//     sd.Windowed = w.TRUE;
//     sd.SwapEffect = dxgi.DXGI_SWAP_EFFECT_DISCARD;

//     const createDeviceFlags: dx.D3D11_CREATE_DEVICE_FLAG = .{
//         .DEBUG = 0,
//     };
//     //createDeviceFlags |= D3D11_CREATE_DEVICE_DEBUG;
//     var featureLevel: win32.D3D_FEATURE_LEVEL = undefined;
//     const featureLevelArray = &[_]win32.D3D_FEATURE_LEVEL{ win32.D3D_FEATURE_LEVEL_11_0, win32.D3D_FEATURE_LEVEL_10_0 };

//     var device: *dx.ID3D11Device = undefined;
//     var device_context: *dx.ID3D11DeviceContext = undefined;
//     var swap_chain: *dxgi.IDXGISwapChain = undefined;

//     var res: win.foundation.HRESULT = dx.D3D11CreateDeviceAndSwapChain(
//         null,
//         win32.D3D_DRIVER_TYPE_HARDWARE,
//         null,
//         createDeviceFlags,
//         featureLevelArray,
//         2,
//         dx.D3D11_SDK_VERSION,
//         &sd,
//         &swap_chain,
//         &device,
//         &featureLevel,
//         &device_context,
//     );

//     if (res == dxgi.DXGI_ERROR_UNSUPPORTED) {
//         res = dx.D3D11CreateDeviceAndSwapChain(
//             null,
//             win32.D3D_DRIVER_TYPE_WARP,
//             null,
//             createDeviceFlags,
//             featureLevelArray,
//             2,
//             dx.D3D11_SDK_VERSION,
//             &sd,
//             &swap_chain,
//             &device,
//             &featureLevel,
//             &device_context,
//         );
//     }
//     if (!isOk(res))
//         return null;

//     return Dx11Backend.Directx11Options{
//         .device = device,
//         .device_context = device_context,
//         .swap_chain = swap_chain,
//     };
// }

fn convertVKeyToDvuiKey(vkey: key.VIRTUAL_KEY) dvui.enums.Key {
    const K = dvui.enums.Key;
    return switch (vkey) {
        .@"0", .NUMPAD0 => K.kp_0,
        .@"1", .NUMPAD1 => K.kp_1,
        .@"2", .NUMPAD2 => K.kp_2,
        .@"3", .NUMPAD3 => K.kp_3,
        .@"4", .NUMPAD4 => K.kp_4,
        .@"5", .NUMPAD5 => K.kp_5,
        .@"6", .NUMPAD6 => K.kp_6,
        .@"7", .NUMPAD7 => K.kp_7,
        .@"8", .NUMPAD8 => K.kp_8,
        .@"9", .NUMPAD9 => K.kp_9,
        .A => K.a,
        .B => K.b,
        .C => K.c,
        .D => K.d,
        .E => K.e,
        .F => K.f,
        .G => K.g,
        .H => K.h,
        .I => K.i,
        .J => K.j,
        .K => K.k,
        .L => K.l,
        .M => K.m,
        .N => K.n,
        .O => K.o,
        .P => K.p,
        .Q => K.q,
        .R => K.r,
        .S => K.s,
        .T => K.t,
        .U => K.u,
        .V => K.v,
        .W => K.w,
        .X => K.x,
        .Y => K.y,
        .Z => K.z,
        .BACK => K.backspace,
        .TAB => K.tab,
        .RETURN => K.enter,
        .F1 => K.f1,
        .F2 => K.f2,
        .F3 => K.f3,
        .F4 => K.f4,
        .F5 => K.f5,
        .F6 => K.f6,
        .F7 => K.f7,
        .F8 => K.f8,
        .F9 => K.f9,
        .F10 => K.f10,
        .F11 => K.f11,
        .F12 => K.f12,
        .F13 => K.f13,
        .F14 => K.f14,
        .F15 => K.f15,
        .F16 => K.f16,
        .F17 => K.f17,
        .F18 => K.f18,
        .F19 => K.f19,
        .F20 => K.f20,
        .F21 => K.f21,
        .F22 => K.f22,
        .F23 => K.f23,
        .F24 => K.f24,
        .SHIFT, .LSHIFT => K.left_shift,
        .RSHIFT => K.right_shift,
        .CONTROL, .LCONTROL => K.left_control,
        .RCONTROL => K.right_control,
        .MENU => K.menu,
        .PAUSE => K.pause,
        .ESCAPE => K.escape,
        .SPACE => K.space,
        .END => K.end,
        .HOME => K.home,
        .LEFT => K.left,
        .RIGHT => K.right,
        .UP => K.up,
        .DOWN => K.down,
        .PRINT => K.print,
        .INSERT => K.insert,
        .DELETE => K.delete,
        .LWIN => K.left_command,
        .RWIN => K.right_command,
        .PRIOR => K.page_up,
        .NEXT => K.page_down,
        .MULTIPLY => K.kp_multiply,
        .ADD => K.kp_add,
        .SUBTRACT => K.kp_subtract,
        .DIVIDE => K.kp_divide,
        .NUMLOCK => K.num_lock,
        .OEM_1 => K.semicolon,
        .OEM_2 => K.slash,
        .OEM_3 => K.grave,
        .OEM_4 => K.left_bracket,
        .OEM_5 => K.backslash,
        .OEM_6 => K.right_bracket,
        .OEM_7 => K.apostrophe,
        .CAPITAL => K.caps_lock,
        .OEM_PLUS => K.kp_equal,
        .OEM_MINUS => K.minus,
        else => |e| {
            log.warn("Key {s} not supported.", .{@tagName(e)});
            return K.unknown;
        },
    };
}

fn fatalHr(what: []const u8, hresult: win32.HRESULT) noreturn {
    std.debug.panic("{s} failed, hresult=0x{x}", .{ what, @as(u32, @bitCast(hresult)) });
}
