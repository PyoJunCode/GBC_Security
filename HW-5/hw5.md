# HW5

## 1. YELLOW

### r2

r2로 bomb를 실행해 main - yellow를 들어가본다.

![](https://postfiles.pstatic.net/MjAxOTA3MTVfMjA3/MDAxNTYzMTI3NTIzNzQ4.zSvvCg4cFtUIRVe8fnKk_JUmmfHjigfBaO2dDt6Vuoog.KcVtW6xDbpyKxM_kbdGDGP1uh9Ut2w8qOAY-lPpOtp8g.PNG.potenpanda/%EC%8A%A4%ED%81%AC%EB%A6%B0%EC%83%B7_2019-07-15_%EC%98%A4%EC%A0%84_3.01.34.png?type=w773)

 8 - 4 - 3 - 7 - 1 - 0 - 6 - 5 
 strcmp로 한글자씩 비교하는게 바로 보인다. 마지막 글자 전까지는 cmp 후 맞지 않으면 0x804977c를 호출해 error logic으로 흐르게 하고,

 
     
마지막 글자까지 통과하면 정답 로직으로 들어간 뒤 노란색 선을 해체하고 다시 폭탄 메뉴를 프린트한다.

### gdb

gdb로 실행해본다. yellow에 break point를 걸었다.

위에서 말한 것 처럼 strcmp를 실행한 뒤, 암호가 맞으면 yellow+114로 jump한다.(정답로직)

`► 0x804977a <yellow+97>   ✔ je     yellow+114 <0x804978b> `


```
► 0x80496b7 <main+493>      call   getchar@plt <0x80486c4> 

► 0x8049558 <main+142>    call   fgets@plt <0x8048704>   
```

Password : 84371065

## 2. 아무거나 쓰기

    7/15 월요일에 개인사정으로 인해 결석할 것 같습니다. 해당 날짜의 진도는 제가 레포지토리를 보고 자습해서 가겠습니다.
