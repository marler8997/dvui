const std = @import("std");
const dvui = @import("dvui");
const Backend = dvui.backend;
const win32 = Backend.win32;

const window_icon_png = @embedFile("zig-favicon.png");

var gpa_instance = std.heap.GeneralPurposeAllocator(.{}){};
const gpa = gpa_instance.allocator();

const vsync = true;

var show_dialog_outside_frame: bool = false;

pub const panic = win32.messageBoxThenPanic(.{ .title = "Dx11 Standalone Panic!" });

/// This example shows how to use the dvui for a normal application:
/// - dvui renders the whole application
/// - render frames only when needed
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

    const dpi = win32.GetDpiForSystem();
    var window_state: Backend.WindowState = undefined;
    const hwnd = Backend.CreateWindow(@src(), gpa, &d3d, class, &callback, &window_state, .{
        .vsync = vsync,
        .style = win32.WS_OVERLAPPEDWINDOW,
        .title = win32.L("DVUI DX11 Standalone Example"),
        .width = win32.scaleDpi(i32, 800, dpi),
        .height = win32.scaleDpi(i32, 600, dpi),
    }) catch |err| switch (err) {
        error.Win32 => win32.panicWin32("CreateWindow", win32.GetLastError()),
        else => |e| return e,
    };
    // .min_size = .{ .w = 250.0, .h = 350.0 },
    // .icon = window_icon_png, // can also call setIconFromFileContent()

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
            try gui_frame();
            _ = try win.end(.{});
            // // cursor management
            // backend.setCursor(win.cursorRequested());

            // // Example of how to show a dialog from another thread (outside of win.begin/win.end)
            // if (show_dialog_outside_frame) {
            //     show_dialog_outside_frame = false;
            //     dvui.dialog(@src(), .{ .window = &win, .modal = false, .title = "Dialog from Outside", .message = "This is a non modal dialog that was created outside win.begin()/win.end(), usually from another thread." }) catch {};
            // }
        },
        .destroy => {
            win32.PostQuitMessage(0);
        },
    }
}

fn gui_frame() !void {
    {
        var m = try dvui.menu(@src(), .horizontal, .{ .background = true, .expand = .horizontal });
        defer m.deinit();

        if (try dvui.menuItemLabel(@src(), "File", .{ .submenu = true }, .{ .expand = .none })) |r| {
            var fw = try dvui.floatingMenu(@src(), dvui.Rect.fromPoint(dvui.Point{ .x = r.x, .y = r.y + r.h }), .{});
            defer fw.deinit();

            if (try dvui.menuItemLabel(@src(), "Close Menu", .{}, .{}) != null) {
                m.close();
            }
        }

        if (try dvui.menuItemLabel(@src(), "Edit", .{ .submenu = true }, .{ .expand = .none })) |r| {
            var fw = try dvui.floatingMenu(@src(), dvui.Rect.fromPoint(dvui.Point{ .x = r.x, .y = r.y + r.h }), .{});
            defer fw.deinit();
            _ = try dvui.menuItemLabel(@src(), "Dummy", .{}, .{ .expand = .horizontal });
            _ = try dvui.menuItemLabel(@src(), "Dummy Long", .{}, .{ .expand = .horizontal });
            _ = try dvui.menuItemLabel(@src(), "Dummy Super Long", .{}, .{ .expand = .horizontal });
        }
    }

    var scroll = try dvui.scrollArea(@src(), .{}, .{ .expand = .both, .color_fill = .{ .name = .fill_window } });
    defer scroll.deinit();

    var tl = try dvui.textLayout(@src(), .{}, .{ .expand = .horizontal, .font_style = .title_4 });
    const lorem = "This example shows how to use dvui in a normal application.";
    try tl.addText(lorem, .{});
    tl.deinit();

    var tl2 = try dvui.textLayout(@src(), .{}, .{ .expand = .horizontal });
    try tl2.addText(
        \\DVUI
        \\- paints the entire window
        \\- can show floating windows and dialogs
        \\- example menu at the top of the window
        \\- rest of the window is a scroll area
    , .{});
    try tl2.addText("\n\n", .{});
    try tl2.addText("Framerate is variable and adjusts as needed for input events and animations.", .{});
    try tl2.addText("\n\n", .{});
    if (vsync) {
        try tl2.addText("Framerate is capped by vsync.", .{});
    } else {
        try tl2.addText("Framerate is uncapped.", .{});
    }
    try tl2.addText("\n\n", .{});
    try tl2.addText("Cursor is always being set by dvui.", .{});
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

    {
        try dvui.labelNoFmt(@src(), "These are drawn directly by the backend, not going through DVUI.", .{ .margin = .{ .x = 4 } });

        var box = try dvui.box(@src(), .horizontal, .{ .expand = .horizontal, .min_size_content = .{ .h = 40 }, .background = true, .margin = .{ .x = 8, .w = 8 } });
        defer box.deinit();

        // Here is some arbitrary drawing that doesn't have to go through DVUI.
        // It can be interleaved with DVUI drawing.
        // NOTE: This only works in the main window (not floating subwindows
        // like dialogs).
    }

    if (try dvui.button(@src(), "Show Dialog From\nOutside Frame", .{}, .{})) {
        show_dialog_outside_frame = true;
    }

    // look at demo() for examples of dvui widgets, shows in a floating window
    try dvui.Examples.demo();
}
