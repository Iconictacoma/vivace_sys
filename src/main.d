module main;

import vga;

extern (C) void kmain() {
    vga_set_color(Color.LIGHT_GREEN, Color.BLACK);
    vga_clear();

    vga_puts("~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~\n");
    vga_puts("       testtesttesttesttesttest         \n");
    vga_puts("________________________________________\n\n");

    vga_set_color(Color.WHITE, Color.BLACK);
    vga_puts("kernel booted using GRUB\n");

    while (true) {}
}