# 1. About SQL injection

앞서 조사했던 OWASP Top 10 에서는 1순위를 SQL injection으로 꼽았다. 대체 이게 뭐길래 이렇게 위험한걸까?

SQL Injection : 서버 보안 상의 허점을 의도적으로 이용하여 악의적인 명령문을 실행되게 함으로 DB를 조작하거나 파괴하는 공격 기법.

이해가 잘되는 간단한 예 :

```
$username = $_POST["username"];
$password = $_POST["password"];

$mysqli->query("SELECT * FROM users WHERE username='{$username}' AND password='{$password}'");
```

매우 허접한 로그인 플랫폼이 있다고 가정하자. password에  ' OR '1' = '1  를 넣으면 항상 true가 되어 패스가된다.

마찬가지의 예로 어떠한 정보 입력창에

```
INSERT INTO students (NAME) VALUES ('test');
DROP TABLE students;
--');
```

를 입력한다면 해당 데이터 테이블이 모두 삭제될 것이다.

이런식으로 공격이 쉬운데 비해 엄청나게 치명적일 수 있다.

결국 쿼리명령어에 능통하고 예상되는 허점을 많이 알수록 공격하기 쉽다. 국내 사이트의 대규모 정보 유출도 고도의 SQL인젝션으로 인해 발생했을 수도 있다.

**그렇다면 방어 방법은 ?**

일반적인 방어 방법으로는 사용자에게 받은 값을 직접 SQL로 바로 넘기지 않는것.

입력을 웹사이트 내에서 자바스크립트로 검사 -> 해당 값을 prepared statement로 sql에 넘겨주기 -> 쿼리의 출력값을 한번 더 컴파일 하고 유저에게 넘겨주기.

(prepared statement : 쿼리를 사전에 컴파일 하고 변수만 따로 넘겨줌)

이렇게하면 SQL Injection과 동시에 XSS도 방어할 수 있다.

*한동대는 어떨까?*

나는 잘 모르겠지만 한번 살펴봤다.
rc.handong.edu의 로그인 페이지 소스를 봤다.

일단 https://api.handong.edu/api/oauth/signin 의/api/oauth/signin 에서 rc페이지가 자체적으로 user에 대한 정보들을
가지고 있는것 같지는 않고 api서버를 경유하는 것 같다. 그리고

```
<script src="/api/js/jquery/jquery-1.11.2.min.js"></script>
<script src="/api/js/bootstrap/bootstrap.min.js"></script>
```

라는것을 발견할 수 있었는데, 이것이 위에서 말한 자바스크립트로 검사를 하는 것인지는 확실치 않다.

확실한건 히즈넷 보다는 괜찮은거같음


# 2. Reversing

## crackme0x00a

첫문제 답게 매우 쉽다. nextcall만 쳐도 strcmp에 다 나옴.


```
► 0x804852a  <main+70>               call   strcmp@plt <0x80483c0>                          
s1: 0x804a024 (pass) ◂— 'g00dJ0B!'                                             
s2: 0xffffd4d3 ◂— 'nextcall'
```

---



## crackme0x00b 


```
        ► 0x80484a5 <main+17>    call   printf@plt <0x8048380>
        format: 0x80485d0 ◂— 'Enter password: '
        vararg: 0x1
    

          0x80484c3 <main+47>    mov    dword ptr [esp + 4], eax
          0x80484c7 <main+51>    mov    dword ptr [esp], pass <0x804a040>
        ► 0x80484ce <main+58>    call   wcscmp@plt <0x8048390>
            s1: 0x804a040 (pass) ◂— 0x77 /* 'w' */
            s2: 0xffffd48c ◂— 0x71 /* 'q' */
```

            
        
  main+58에서 **wcscmp**을 call하는것을 확인할 수 있다. 이때 pass의 조건이 0x77임(아스키 w)
 
  하지만 답이 w가 아님 <0x804a040>참조한다. 
 
  x/10x 0x804a040 ->헥사값이 여러개 나오긴 하는데 뭔지 의아해서 구글링해봄.
         
                The following size modifiers are supported:

        b - byte
        h - halfword (16-bit value)
        w - word (32-bit value)
        g - giant word (64-bit value)

 //http://visualgdb.com/gdbreference/commands/x
 
 ->x/10w 0x0804a040 입력
 
 
```
        0x804a040 <pass.1964>:  119 'w' 48 '0'  119 'w' 103 'g'
        0x804a050 <pass.1964+16>:       114 'r' 101 'e' 97 'a'  116 't'
        0x804a060 <pass.1964+32>:       0 '\000'        0 '\000'

```

왜 이렇게 2바이트 단위로 띄워져 저장되어 있을까?? 찾아보았다.

*wchart는 와이드 문자(wide character)를 저장하기 위한 자료형이다. 보통 영문 알파벳은 1바이트로 표현하지만 유니코드는 2바이트 이상으로 표현하기 때문에 wchart에 저장해야 한다.*

실제로 저장되어있는 형태를 보면 'w' '' '' '0' '' '' 'w' '' '' 'g' '' '' 이런식으로 저장되어있음.


### w0wgreat -> Congrats!
---
 
## crackme0x001

```
        ► 0x8048426 <main+66>    call   scanf@plt <0x804830c>
        format: 0x804854c ◂— 0x49006425 /* '%d' */
        vararg: 0xffffd4f4 —▸ 0xf7fbe000 (_GLOBAL_OFFSET_TABLE_) ◂— 0x1d7d6c

```


        
main+47에서 printf의 call이 있고, 이어서 main+66에 scanf call이 나오는데 **%d(int)**라고 되어있음.


```
           0x804842b <main+71>     cmp    dword ptr [ebp - 4], 0x149a
           0x8048432 <main+78>     je     main+94 <0x8048442>
            
           0x8048434 <main+80>     mov    dword ptr [esp], 0x804854f
           ► 0x804843b <main+87>     call   printf@plt <0x804831c>
           format: 0x804854f ◂— 'Invalid Password!\n'
           vararg: 0xffffd4f4 —▸ 0xf7fbe000 (_GLOBAL_OFFSET_TABLE_) ◂— 0x1d7d6c        
```


 입력하면 main+80 -> Invalid Password! 출력하고 jmp로 exit호출함. 이 전에 별도의 ***strcmp나 wcscmp가 없다.***
 
 
 **cmp가 수상하다**
 
 -> 0x804842b의 cmp -> 0x149a와 비교해서 같으면 main+94로 jump함.
 
 80,87과 형태가 비슷한걸로 보아 pass일듯. 
 그렇다면 0x149a가 패스워드 ??
 
 0x149a 입력 -> Invalid Password! ,,, 답이아니다.
 
 %d 였던 것을 생각해 python3로 간단히 변환해봄 >>> 0x149a -> 5274
 
### 5274 -> Password OK :)
---
 
## crackme0x02
 
 
```
           0x8048441 <main+93>     mov    eax, dword ptr [ebp - 8]
           0x8048444 <main+96>     imul   eax, dword ptr [ebp - 8]
           0x8048448 <main+100>    mov    dword ptr [ebp - 0xc], eax
           0x804844b <main+103>    mov    eax, dword ptr [ebp - 4]
         ► 0x804844e <main+106>    cmp    eax, dword ptr [ebp - 0xc] <0xf7fbe000>
           0x8048451 <main+109>    jne    main+125 <0x8048461>
 
```

    역시나 strcmp나 wcscmp가 보이지 않음. 01과 마찬가지로 cmp찾음. eax, ebp-0xc를 비교하는데, 둘중 뭐가 답인지는 모르겠음.

```
        ► 0x8048426 <main+66>    call   scanf@plt <0x804830c>
        format: 0x804856c ◂— 0x50006425 /* '%d' */
        
        00:0000│ esp  0xffffd4d0 —▸ 0x804856c ◂— and    eax, 0x61500064 /* '%d' */
```
        
        이걸 보면 scanf로 받은 값이 eax에 저장되는것 같기도 하다..
        
        그럼그냥 둘다확인 

        
pwndbg> x/x $eax
0xf7fbe000:     0x001d7d6c

pwndbg> x/x $ebp-0xc
0xffffd4ec:     0x00052b24

ebp-0xc의 값 변환 >>> 338724
crackme0x01이랑 매우 매우 유사했음.

### 338724 -> Password OK :)



---

## crackme0x03

```

        ► 0x80484da <main+66>    call   scanf@plt <0x8048330>
        format: 0x8048634 ◂— 0x6425 /* '%d' */
        vararg: 0xffffd4f4 —▸ 0xf7fbe000 (_GLOBAL_OFFSET_TABLE_) ◂— 0x1d7d6c
```

1,2와 같은 scanf %d 인 진부한 형태.

ni를 치다보면 test라는 것을 call한다. 새로운거니까 step in 해본다.

```

          0x8048474 <test+6>     mov    eax, dword ptr [ebp + 8]
        ► 0x8048477 <test+9>     cmp    eax, dword ptr [ebp + 0xc] <0xf7fbe000>
          0x804847a <test+12>    je     test+28 <0x804848a>
```

어디선가 많이 본 형태. 

pwndbg> x/x $ebp+0xc
0xffffd4d4:     0x00052b24

마찬가지로 0x00052b24를 변환해본다. -> 338724

crack2랑 똑같다,,,;;

### 338724 -> Password OK!!! :)
---

## crackme0x04

리버싱을 하다 보면 crackme 3과 유사하게 check라는 함수를 call한다. step in해보자.

```
        ► 0x8048559 <main+80>    call   check <0x8048484>
        arg[0]: 0xffffd480 ◂— 0x71 /* 'q' */
        arg[1]: 0xffffd480 ◂— 0x71 /* 'q' */
        arg[2]: 0xf7fcf410 —▸ 0x80482c5 ◂— inc    edi /* 'GLIBC_2.0' */
        arg[3]: 0x1
```

```
        x80484a3  <check+31>                 cmp    dword ptr [ebp - 0xc], eax
 
        ► 0x80484c9 <check+69>    call   sscanf@plt <0x80483a4>
        s: 0xffffd44b ◂— 0x71 /* 'q' */
        format: 0x8048638 ◂— 0x50006425 /* '%d' */
        vararg: 0xffffd454 —▸ 0xf7ffd940 ◂— 0x0
```

check+31에 cmp가 쓰였으나 ebp-0xc는 0이다.

check+69에서 처음보는 sscanf를 호출한다. %d 타입.

---




# 3. 아무거나 쓰기

이런 저런 일이 있어 시간이 안돼서 3번까지밖에 못풀었습니다 ㅜ

보안왕이 되는 그날까지 ,, continue