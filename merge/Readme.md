#run encryptor file
yasm -f elf64 -g dwarf2 -o encryptor.o encryptor.s
yasm -f elf64 -g dwarf2 -o writeFile.o writeFile.s
yasm -f elf64 -g dwarf2 -o readFile.o readFile.s
yasm -f elf64 -g dwarf2 -o removeNewline.o removeNewline.s
yasm -f elf64 -g dwarf2 -o xorFunc.o xorFunc.s
ld -o encrypt_file encryptor.o removeNewline.o xorFunc.o readFile.o writeFile.o
./encrypt_file

#run decryptor file
yasm -f elf64 -g dwarf2 -o decryptor.o decryptor.s
yasm -f elf64 -g dwarf2 -o writeFile.o writeFile.s
yasm -f elf64 -g dwarf2 -o readFile.o readFile.s
yasm -f elf64 -g dwarf2 -o removeNewline.o removeNewline.s
yasm -f elf64 -g dwarf2 -o xorFunc.o xorFunc.s
ld -o decrypt_file decryptor.o removeNewline.o xorFunc.o readFile.o writeFile.o
./decrypt_file

**buffer, input_filename, output_filename สามารถรองรับ 255 ไบต์
