const std = @import("std");
const win32 = struct {
    usingnamespace @import("win32").zig;
    usingnamespace @import("win32").foundation;
    usingnamespace @import("win32").graphics.gdi;
//    usingnamespace @import("win32").graphics.direct_write;
//    usingnamespace @import("win32").graphics.direct2d.common;
//    usingnamespace @import("win32").graphics.dwm;
//    usingnamespace @import("win32").security;
    usingnamespace @import("win32").system.library_loader;
//    usingnamespace @import("win32").system.system_information;
//    usingnamespace @import("win32").storage.file_system;
//    usingnamespace @import("win32").system.pipes;
//    usingnamespace @import("win32").system.threading;
//    usingnamespace @import("win32").ui.hi_dpi;
    usingnamespace @import("win32").ui.windows_and_messaging;
};
const dvui = @import("dvui");

fn WndProc(
    hwnd: win32.HWND,
    msg: u32,
    wparam: win32.WPARAM,
    lparam: win32.LPARAM,
) callconv(std.os.windows.WINAPI) win32.LRESULT {
    switch (msg) {
//        win32.WM_PAINT => {
//            const dpi = Dpi.fromHwnd(hwnd);
//            const client_size = getClientSize(hwnd);
//            const state = &global.state;
//            const ui = &state.ui;
//
//            var ps: win32.PAINTSTRUCT = undefined;
//            {
//                var err: dui.Error = undefined;
//                ui.beginPaintHwnd(&ps, dpi.value, client_size, &err) catch fatal(
//                    "Direct2D begin paint failed, context={s}, hresult=0x{x}",
//                    .{@tagName(err.context), err.hr},
//                );
//            }
//            ui.Clear(dui.shade8(window_bg_shade));
//            paint(state, dpi, client_size);
//            {
//                var err: dui.Error = undefined;
//                ui.endPaintHwnd(&ps, &err) catch fatal(
//                    "Direct2D paint failed, context={s}, hresult=0x{x}",
//                    .{@tagName(err.context), err.hr},
//                );
//            }
//
//            return 0;
//        },
//        win32.WM_ERASEBKGND => {
//            if (!global.state.bg_erased) {
//                global.state.bg_erased = true;
//                const hdc: win32.HDC = @ptrFromInt(wparam);
//                const client_size = getClientSize(hwnd);
//                const brush = win32.CreateSolidBrush(colorrefFromShade(window_bg_shade)) orelse apifatal(
//                    "CreateSolidBrush", win32.GetLastError()
//                );
//                defer if (0 == win32.DeleteObject(brush)) apifatal(
//                    "DeleteObject", win32.GetLastError()
//                );
//                const client_rect: win32.RECT = .{
//                    .left = 0, .top = 0,
//                    .right = @intCast(client_size.width),
//                    .bottom = @intCast(client_size.height),
//                };
//                if (0 == win32.FillRect(hdc, &client_rect, brush)) apifatal(
//                    "FillRect", win32.GetLastError()
//                );
//            }
//            return 1;
//        },
        win32.WM_CREATE => {
//            var err: dui.Error = undefined;
//            global.state = .{
//                .hwnd = hwnd,
//                .ui = dui.initHwnd(hwnd, &err, .{}) catch fatal(
//                    "failed to initialize Direct2D, context={s}, hresult=0x{x}",
//                    .{ @tagName(err.context), err.hr },
//                ),
//            };
        },
        win32.WM_DESTROY => {
            //win32.PostQuitMessage(0);
            return 0;
        },
        else => {},
    }
    return win32.DefWindowProcW(hwnd, msg, wparam, lparam);

}

pub const WindowClassOptions = struct {
    style: win32.WNDCLASS_STYLES = .{},
    class_extra_len: c_int = 0,
    window_extra_len: c_int = 0,
    cursor: ?win32.HICON = null,
    icon: ?win32.HICON = null,
    icon_small: ?win32.HICON = null,
    background_brush: ?win32.HBRUSH = null,
    menu_name: ?[*:0]const u16 = null,
};
pub fn registerClass(name: [*:0]const u16, opt: WindowClassOptions) !void {
    //const CLASS_NAME = win32.L("");
    const wc = win32.WNDCLASSEXW {
        .cbSize = @sizeOf(win32.WNDCLASSEXW),
        //.style = .{.VREDRAW=1, .HREDRAW=1},
        .style = opt.style,
        .lpfnWndProc = WndProc,
        .cbClsExtra = opt.class_extra_len,
        .cbWndExtra = opt.window_extra_len,
        .hInstance = win32.GetModuleHandleW(null),
        .hIcon = opt.icon,
        .hIconSm = opt.icon_small,
        .hCursor = opt.cursor,//win32.LoadCursorW(null, win32.IDC_ARROW),
        .hbrBackground = opt.background_brush,
        .lpszMenuName = opt.menu_name,
        .lpszClassName = name,
    };
    if (0 == win32.RegisterClassExW(&wc)) return std.os.windows.unexpectedError(
        std.os.windows.kernel32.GetLastError()
    );
}

pub const InitOptions = struct {
    /// The allocator used for temporary allocations used during init()
    //allocator: std.mem.Allocator,
    /// The initial size of the application window
    size: struct { width: u32, height: u32 },
    /// The application title to display
    title: [*:0]const u16,
    /// Class name passed to registerClass
    class: [*:0]const u16,
    style: win32.WINDOW_STYLE = win32.WS_OVERLAPPEDWINDOW,
    style_ex: win32.WINDOW_EX_STYLE = .{},
};

pub const Backend = struct {

    pub fn backend(self: Backend) dvui.Backend {
        return dvui.Backend.init(self, @This());
    }
    pub fn nanoTime(self: Backend) i128 {
        _ = self;
        return std.time.nanoTimestamp();
    }
    pub fn sleep(self: Backend, ns: u64) void {
        _ = self;
        std.time.sleep(ns);
    }
    pub fn begin(self: Backend, arena: std.mem.Allocator) void {
        _ = self;
        _ = arena;
        @panic("todo");
    }
    pub fn end(self: Backend) void {
        _ = self;
        @panic("todo");
    }
    pub fn pixelSize(self: Backend) dvui.Size {
        _ = self;
        @panic("todo");
    }
    pub fn windowSize(self: Backend) dvui.Size {
        _ = self;
        @panic("todo");
    }
    pub fn contentScale(self: Backend) f32 {
        _ = self;
        @panic("todo");
    }

    pub fn drawClippedTriangles(
        self: Backend,
        texture: ?*anyopaque,
        vtx: []const dvui.Vertex,
        idx: []const u16,
        clipr: dvui.Rect,
    ) void {
        _ = self;
        _ = texture;
        _ = vtx;
        _ = idx;
        _ = clipr;
        @panic("todo");
    }

    pub fn textureCreate(self: Backend, pixels: [*]u8, width: u32, height: u32) *anyopaque {
        _ = self;
        _ = pixels;
        _ = width;
        _ = height;
        @panic("todo");
    }

    pub fn textureDestroy(self: Backend, texture: *anyopaque) void {
        _ = self;
        _ = texture;
        @panic("todo");
    }

    pub fn clipboardText(self: Backend) ![]const u8 {
        _ = self;
        @panic("todo");
    }
    pub fn clipboardTextSet(self: Backend, text: []const u8) !void {
        _ = self;
        _ = text;
        @panic("todo");
    }
    pub fn openURL(self: Backend, url: []const u8) !void {
        _ = self;
        _ = url;
        @panic("todo");
    }
    pub fn refresh(self: Backend) void {
        _ = self;
        @panic("todo");
    }
    pub fn hasEvent(self: Backend) bool {
        _ = self;
        @panic("todo");
        //return c.SDL_PollEvent(null) == 1;
    }
    pub fn addAllEvents(self: Backend, win: *dvui.Window) !bool {
        _ = self;
        _ = win;
        @panic("todo");
    }
    pub fn setCursor(self: Backend, cursor: dvui.enums.Cursor) void {
        _ = self;
        _ = cursor;
        @panic("todo");
    }
    pub fn renderPresent(self: Backend) void {
        _ = self;
        @panic("todo");
    }
    pub fn waitEventTimeout(self: Backend, timeout_micros: u32) void {
        _ = self;
        _ = timeout_micros;
        @panic("todo");
    }
};
pub fn create() Backend {
    return .{};
}

pub const Window = struct {
    hwnd: win32.HWND,
//    pub fn backend(self: Window) dvui.Backend {
//        return dvui.Backend.init(self, @This());
//    }
//    pub fn hasEvent(_: Window) bool {
//        return c.SDL_PollEvent(null) == 1;
//    }
};
pub fn createWindow(opt: InitOptions) !Window {

//    {
//        const hr = win32.DWriteCreateFactory(
//            win32.DWRITE_FACTORY_TYPE_SHARED,
//            win32.IID_IDWriteFactory,
//            @ptrCast(&global.dwrite_factory),
//        );
//        if (hr < 0) fatal("DWriteCreateFactory failed, hresult=0x{x}", .{@as(u32, @bitCast(hr))});
//    }
    const hwnd = win32.CreateWindowExW(
        opt.style_ex,
        opt.class,
        opt.title,
        opt.style,
        win32.CW_USEDEFAULT, win32.CW_USEDEFAULT, // Position
        @intCast(opt.size.width),
        @intCast(opt.size.height),
        null,       // Parent window
        null,       // Menu
        win32.GetModuleHandleW(null),
        null        // Additional application data
    ) orelse return std.os.windows.unexpectedError(
        std.os.windows.kernel32.GetLastError()
    );

    return .{ .hwnd = hwnd };
}
    //fatal("CreateWindow failed, error={s}", .{@tagName(win32.GetLastError())});
//
//    {
//        // TODO: maybe use DWMWA_USE_IMMERSIVE_DARK_MODE_BEFORE_20H1 if applicable
//        // see https://stackoverflow.com/questions/57124243/winforms-dark-title-bar-on-windows-10
//        //int attribute = DWMWA_USE_IMMERSIVE_DARK_MODE;
//        const dark_value: c_int = 1;
//        const hr = win32.DwmSetWindowAttribute(
//            hwnd,
//            win32.DWMWA_USE_IMMERSIVE_DARK_MODE,
//            &dark_value,
//            @sizeOf(@TypeOf(dark_value)),
//        );
//        if (hr < 0) std.log.warn(
//            "DwmSetWindowAttribute for dark={} failed, error={}",
//            .{dark_value, win32.GetLastError()},
//        );
//    }
//
//    if (0 == win32.UpdateWindow(hwnd)) apifatal("UpdateWindow", win32.GetLastError());
//
//    // for some reason this causes the window to paint before being shown so we
//    // don't get a white flicker when the window shows up
//    if (0 == win32.SetWindowPos(hwnd, null, 0,0,0,0, .{
//        .NOMOVE = 1,
//        .NOSIZE = 1,
//        .NOOWNERZORDER = 1,
//    })) apifatal(
//        "SetWindowPos", win32.GetLastError()
//    );
//    _ = win32.ShowWindow(hwnd, .{ .SHOWNORMAL = 1 });
//
//    global.state.updateGitDiffFiles();
//
//    var msg : win32.MSG = undefined;
//    while (win32.GetMessageW(&msg, null, 0, 0) != 0) {
//        _ = win32.TranslateMessage(&msg);
//        _ = win32.DispatchMessageW(&msg);
//    }
//    return @intCast(msg.wParam);
//
//
//
//    c.InitWindow(@as(c_int, @intFromFloat(options.size.w)), @as(c_int, @intFromFloat(options.size.h)), options.title);
//
//    if (options.icon) |image_bytes| {
//        const icon = c.LoadImageFromMemory(".png", image_bytes.ptr, @intCast(image_bytes.len));
//        c.SetWindowIcon(icon);
//    }
//
//    if (options.min_size) |min| {
//        c.SetWindowMinSize(@intFromFloat(min.w), @intFromFloat(min.h));
//    }
//    if (options.max_size) |max| {
//        c.SetWindowMaxSize(@intFromFloat(max.w), @intFromFloat(max.h));
//    }
//}
//
