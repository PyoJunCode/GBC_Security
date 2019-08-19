lobal    _start                                                                            
  1 section   .text
  2 _start:
  3     mov       rax, 1
  4     mov       rdi, 1
  5     mov       rsi, message
  6     mov       rdx, 36
  7     syscall
  8     mov       rax, 60
  9     xor       rdi, rdi
 10     syscall
 11     section   .data
 12 message:
 13     db        "Hello, World", 10, "My name is Seo Jun Pyo", 10

