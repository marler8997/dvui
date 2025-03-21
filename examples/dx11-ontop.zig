const std = @import("std");
const dvui = @import("dvui");
const Backend = dvui.backend;

const win32 = @import("win32").everything;

var gpa_instance = std.heap.GeneralPurposeAllocator(.{}){};
const gpa = gpa_instance.allocator();

const log = std.log.scoped(.Dx11Ontop);

pub export fn main(
    _: win32.HINSTANCE,
    _: ?win32.HINSTANCE,
    _: [*:0]u16,
    _: c_int,
) void {
    defer _ = gpa_instance.deinit();
    return main2() catch |e| {
        if (@errorReturnTrace()) |trace| {
            std.debug.dumpStackTrace(trace.*);
        }
        std.debug.panic("{s}", .{@errorName(e)});
    };
}
fn main2() !void {
    const d3d, const debug = Backend.D3d.init(.{});
    _ = debug;
    const class = win32.L("Dx11MainWnd");
    Backend.RegisterClass(class, .{
        .style = .{ .DBLCLKS = 1 },
        .cursor = win32.LoadCursorW(null, win32.IDC_ARROW),
    }) catch win32.panicWin32("RegisterClass", win32.GetLastError());

    var window_state: Backend.WindowState = undefined;
    const hwnd = Backend.CreateWindow(@src(), gpa, &d3d, class, &callback, &window_state, .{
        .vsync = false,
        .style = win32.WS_OVERLAPPEDWINDOW,
        .style_ex = .{ .APPWINDOW = 1, .WINDOWEDGE = 1 },
        .title = win32.L("DVUI Dx11 Test"),
    }) catch |err| switch (err) {
        error.Win32 => win32.panicWin32("CreateWindow", win32.GetLastError()),
        else => |e| return e,
    };

    {
        // const dc = win32.GetDC(hwnd) orelse win32.panicWin32("GetDC", win32.GetLastError());
        // defer if (0 == win32.ReleaseDC(hwnd, dc)) win32.panicWin32("ReleaseDC", win32.GetLastError());
        const dpi = win32.dpiFromHwnd(hwnd);

        const screen_width = win32.GetSystemMetricsForDpi(@intFromEnum(win32.SM_CXSCREEN), dpi);
        const screen_height = win32.GetSystemMetricsForDpi(@intFromEnum(win32.SM_CYSCREEN), dpi);
        const window_width = @min(win32.scaleDpi(i32, 1280, dpi), screen_width);
        const window_height = @min(win32.scaleDpi(i32, 720, dpi), screen_height);

        _ = win32.SetWindowPos(
            hwnd,
            null,
            @divFloor(screen_width - window_width, 2),
            @divFloor(screen_height - window_height, 2),
            window_width,
            window_height,
            .{ .NOCOPYBITS = 1 },
        );
    }

    _ = win32.ShowWindow(hwnd, .{ .SHOWNORMAL = 1 });

    var msg: win32.MSG = undefined;
    while (win32.GetMessageW(&msg, null, 0, 0) != 0) {
        _ = win32.TranslateMessage(&msg);
        _ = win32.DispatchMessageW(&msg);
    }
}

fn callback(context: Backend.CallbackContext, win: *dvui.Window) anyerror!void {
    switch (context) {
        .ready => {
            const nstime = win.beginWait(true);
            try win.begin(nstime);
            try dvui_floating_stuff();
            _ = try win.end(.{});
        },
        .destroy => {
            win32.PostQuitMessage(0);
        },
    }
}

// fn windowProc(hwnd: HWND, umsg: UINT, wparam: w.WPARAM, lparam: w.LPARAM) callconv(WINAPI) w.LRESULT {
//     switch (umsg) {
//         ui.WM_KEYDOWN, ui.WM_SYSKEYDOWN => {
//             switch (wparam) {
//                 @intFromEnum(zwin.ui.input.keyboard_and_mouse.VK_ESCAPE) => { //SHIFT+ESC = EXIT
//                     if (GetAsyncKeyState(@intFromEnum(zwin.ui.input.keyboard_and_mouse.VK_LSHIFT)) & 0x01 == 1) {
//                         ui.PostQuitMessage(0);
//                         return 0;
//                     }
//                 },
//                 else => {},
//             }
//         },
//         else => {},
//     }

//     // Call the wndProc from the Dx11 Backend directly, it handles all sorts of mouse events!
//     return Backend.wndProc(hwnd, umsg, wparam, lparam);
// }

fn dvui_floating_stuff() !void {
    var float = try dvui.floatingWindow(@src(), .{}, .{ .min_size_content = .{ .w = 400, .h = 400 } });
    defer float.deinit();

    try dvui.windowHeader("Floating Window", "", null);

    var scroll = try dvui.scrollArea(@src(), .{}, .{ .expand = .both, .color_fill = .{ .name = .fill_window } });
    defer scroll.deinit();

    var tl = try dvui.textLayout(@src(), .{}, .{ .expand = .horizontal, .font_style = .title_4 });
    const lorem = "This example shows how to use dvui for floating windows on top of an existing application.";
    try tl.addText(lorem, .{});
    tl.deinit();

    var tl2 = try dvui.textLayout(@src(), .{}, .{ .expand = .horizontal });
    try tl2.addText("The dvui is painting only floating windows and dialogs.", .{});
    try tl2.addText("\n\n", .{});
    try tl2.addText("Framerate is managed by the application (in this demo capped at vsync).", .{});
    try tl2.addText("\n\n", .{});
    try tl2.addText("Cursor is only being set by dvui for floating windows.", .{});
    try tl2.addText("\n\n", .{});
    if (dvui.useFreeType) {
        try tl2.addText("Fonts are being rendered by FreeType 2.", .{});
    } else {
        try tl2.addText("Fonts are being rendered by stb_truetype.", .{});
    }
    tl2.deinit();

    const label = if (dvui.Examples.show_demo_window) "Hide Demo Window" else "Show Demo Window";
    if (try dvui.button(@src(), label, .{}, .{})) {
        dvui.Examples.show_demo_window = !dvui.Examples.show_demo_window;
    }

    // look at demo() for examples of dvui widgets, shows in a floating window
    try dvui.Examples.demo();
}
