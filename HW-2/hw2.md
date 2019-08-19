# HW2

## **1. hello.asm 분석**

```
global    _start
section   .text
_start:
    mov       rax, 1 // rax에 1을 저장한다. Call code 에 sys_write인 1을 넣는다.
    mov       rdi, 1 // 1번째 인자에 1을 준다. sys_write의 첫번째 인자에 1이 들어가는 셈.
    mov       rsi, message // 2번째 인자에 message를 넣는다. sys_wirte의 두번째 인자에 message를 넣는다.
    mov       rdx, 13 // 3번째 인자에 13을 넣는다. sys_write의 문자열의 크기에 해당하는 인자같음. 여기서는 message의 크기인 13
    syscall // 서비스를 호출한다. 1이 들어있기 때문에 sys_write(1,message,13)
    mov       rax, 60 // rax에 60을 저장함. Call code에 sys_exit를 넣는다.
    xor       rdi, rdi // rdi를 rdi와 rdi를 xor함. 실질적으로는 0 넣는것.
    syscall // 서비스를 호출한다. 60이 들어있기 때문에 sys_exit
    section   .data // data섹션임을 명시한다.
message: // 데이타의 레이블(주소의 또다른 이름)
    db        "Hello, World", 10 // message의 data
```
    
**전체적인 흐름**
    sys_write-> 1,message,13 넣고 syscall -> sys_exit에 0넣고 call -> 종료
    리눅스에서는 stdout의 fd가 1이다.
    
## **2. strlen.asm 분석**
    
``` 
BITS 64

section .text // text섹션이다. 실행할 코드를 적음.
global _start // 시작 지점을 정한다.

strlen: //strlen 정의 
    mov rax,0 //rax에 0 저장  글자수 0으로 초기화               
.looplabel: // 
    cmp byte [rdi],0 //rdi(첫번째 인자)의 메모리 주소와 0을 비교한다.    (null byte인지 비교하는것)       
    je  .end // 0과 같으면 .end로간다.                   
    inc rdi  // rdi ++  rdi의 메모리값 ++   ( 다음 문자를 검사 )              
    inc rax  // rax ++  rax의 메모리값 ++   (여기선 count대신에 쓰이는듯)              
    jmp .looplabel //looplabel으로 점프한다. 즉 rdi가 null을 만날때 까지 반복.       
.end:
    ret //다시 돌아갈 수 있게 초기화.                    
    
_start:
    mov   rdi, msg //1st argument를 msg로 저장한다.             
    call  strlen // strlen label찾아서 호출
    
    add   al, '0' //al(low 8 bit register) 에 '0'(아스키코드)0x30=48 을 더한 값을 저장한다.//숫자로 변환     
    
    mov  [len],al len의 주소값을 al로 저장한다.           
    mov   rax, 1 //call code를 1로 변경 (sys_write)          
    mov   rdi, 1  //1st argument를 1로 변경        
    mov   rsi, len //2nd argument를 len으로 변경      
    mov   rdx, 2  //3rd argument를 2로 변경      
    syscall //write(1,len,2)를 호출          
    mov   rax, 60  //call code를 60으로 변경 (sys_exit)  
    mov   rdi, 0   //1st argument를 0 
    syscall  //exit(0)을 호출      

section .data //data섹션
    msg db "hello",0xA,0 //0xA = 10       
    len db 0,0xA   

```
**전체적인 흐름**

    msg를 하나 하나 읽으며 카운트 한다(rax에 저장)->(al low 8 bit)에 48을 더해 아스키코드 숫자로 변환하고 프린트한다 
    -> 종료한다

### *count를 하고 아스키코드에 48을 더해 숫자로 변환하는 방식이므로 9가 넘어가면 특수문자들이 출력된다.

![아스키 코드표](https://miro.medium.com/max/5040/1*DdgD00dAdXggzMdWDt7GSA.png)


