module vga;

import io;

enum ubyte VGA_WIDTH = 80;
enum ubyte VGA_HEIGHT = 25;

enum Color : ubyte {
    BLACK = 0,
    BLUE = 1,
    GREEN = 2,
    CYAN = 3,
    RED = 4,
    MAGENTA = 5,
    BROWN = 6,
    LIGHT_GREY = 7,
    DARK_GREY = 8,
    LIGHT_BLUE = 9,
    LIGHT_GREEN = 10,
    LIGHT_CYAN = 11,
    LIGHT_RED = 12,
    LIGHT_MAGENTA = 13,
    LIGHT_BROWN = 14,
    WHITE = 15,
}

private ubyte* vga_buffer = cast(ubyte*) 0xB8000;
private size_t cursor_x = 0;
private size_t cursor_y = 0;
private ubyte current_color = 0x0F;

extern (C):

void vga_set_color(Color fg, Color bg) {
    current_color = cast(ubyte) (fg | (bg << 4));
}

void vga_clear() {
    for (size_t i = 0; i < VGA_WIDTH * VGA_HEIGHT; i++) {
        vga_buffer[i * 2] = ' ';
        vga_buffer[i * 2 + 1] = current_color;
    }
    cursor_x = 0;
    cursor_y = 0;
}

void vga_putc(char c) {
    if (c == '\n') {
        cursor_x = 0;
        cursor_y++;
    } else {
        size_t index = (cursor_y * VGA_WIDTH + cursor_x) * 2;
        vga_buffer[index] = cast(ubyte) c;
        vga_buffer[index + 1] = current_color;
        cursor_x++;
    }

    if (cursor_x >= VGA_WIDTH) {
        cursor_x = 0;
        cursor_y++;
    }

    if (cursor_y >= VGA_HEIGHT) {
        vga_clear();
    }
}

void vga_puts(const(char)* str) {
    for (size_t i = 0; str[i] != 0; i++) {
        vga_putc(str[i]);
    }
}