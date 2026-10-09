ASM = nasm
DC = gdc
LD = ld.lld

ASMFLAGS = -f elf32
DFLAGS = -m32 -fno-druntime -Isrc -c
LDFLAGS = -m elf_i386 -T linker.ld

ASM_SRC = boot.asm
D_SRCS = src/object.d src/vga.d src/io.d src/main.d

ASM_OBJ = boot.o
D_OBJS = $(D_SRCS:.d=.o)
OBJS = $(ASM_OBJ) $(D_OBJS)

KERNEL_BIN = kernel.bin
OS_IMAGE = os_image.bin
OS_ISO = os.iso

all: $(OS_ISO)

$(ASM_OBJ): $(ASM_SRC)
	$(ASM) $(ASMFLAGS) $(ASM_SRC) -o $(ASM_OBJ)

%.o: %.d
	$(DC) $(DFLAGS) $< -o $@

$(KERNEL_BIN): $(OBJS) linker.ld
	$(LD) $(LDFLAGS) $(OBJS) -o $(KERNEL_BIN)

$(OS_ISO): $(KERNEL_BIN) grub.cfg
	mkdir -p isodir/boot/grub
	cp $(KERNEL_BIN) isodir/boot/kernel.bin
	cp grub.cfg isodir/boot/grub/grub.cfg
	grub-mkrescue -o $(OS_ISO) isodir 2>/dev/null
	rm -rf isodir

raw: $(KERNEL_BIN)
	cat $(KERNEL_BIN) > $(OS_IMAGE)
	dd if=/dev/zero bs=1 count=10000 >> $(OS_IMAGE) 2>/dev/null

run: $(OS_ISO)
	qemu-system-i386 -cdrom $(OS_ISO)

run-raw: raw
	qemu-system-i386 -drive format=raw,file=$(OS_IMAGE)

clean:
	rm -f $(OBJS) $(KERNEL_BIN) $(OS_IMAGE) $(OS_ISO)
	rm -rf isodir

.PHONY: all raw run run-raw clean