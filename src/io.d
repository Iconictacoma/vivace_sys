module io;

extern (C):

void outb(ushort port, ubyte data) {
    asm pure nothrow @nogc {
        mov DX, port;
        mov AL, data;
        out DX, AL;
    }
}

ubyte inb(ushort port) {
    ubyte ret;
    asm pure nothrow @nogc {
        mov DX, port;
        in AL, DX;
        mov ret, AL;
    }
    return ret;
}