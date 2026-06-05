iso: compile
	dd if=/dev/zero of=floppy.img bs=512 count=2880
	dd if=enigma.bin of=floppy.img conv=notrunc
	xorrisofs -o enigma.iso -b floppy.img -boot-load-size 4 floppy.img

compile: rotors.nasm
	nasm -f bin -o enigma.bin -l enigma.lst enigma.nasm
	od -t x2 -A x enigma.bin

rotors.nasm: gen.py
	python gen.py

qemu: compile
	qemu-system-x86_64 \
		-machine pc \
		-audiodev pipewire,id=snd0 \
		-machine pcspk-audiodev=snd0 \
		-fda enigma.bin \
    -display sdl

qemuiso: iso
	qemu-system-x86_64 \
		-machine pc \
		-audiodev pipewire,id=snd0 \
		-machine pcspk-audiodev=snd0 \
		-cdrom enigma.iso \
    -display sdl

qemuusb:
	sudo qemu-system-x86_64 \
		-fda /dev/sda  \
    -display sdl


bochs: compile
	bochs -f bochsrc
