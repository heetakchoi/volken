# 목표
추가 설치 권한이 없는 시스템에서 어떻게든 사용할 방법을 제공한다.
## 가정
perl 은 설치되어 있다고 가정한다.
# console
## log10_by_approximation.pl
상용로그의 값을 반환한다. 
## db-query.pl
mysql 에 접근하여 SQL을 전송하고 결과를 반환받는다.
## mp3split.pl
유튜브 플리와 같이 여러 곡이 하나의 mp3파일에 존재할 경우 mp3info.txt 에 지정된 재생 시간 정보를 기반으로 파일을 나누고 ID3 태그를 생성한다.
## sqrt_by_newton_raphson.pl
뉴튼-랩슨 방법으로 제곱근을 구한다.
# lib
## Volken::File
- origin, target 디렉토리를 argument로 받아, origin의 하위 디렉토리/파일을 순회하면서 target 디렉토리 아래 동일 위치에 같은 이름의 파일이 있는지 살펴보고 존재하지 않는 경우 복사한다. 
- origin 디렉토리는 반드시 존재해야 한다.
- target 디렉토리가 해당 위치에 없는 경우 새로 생성한다.
## Volken::HTTP
HTTP 프로토콜을 지원하는 클라이언트
- HTTP protocol 을 사용하여 message 를 보내고 받는다.
- IO::Socket::INET 을 직접 이용하여 Socket 을 다룬다.
- GET, POST method 를 지원한다.
- request multipart/form-data 전송을 지원한다.
- response chunked mode 를 지원한다.
## Volken::HTTPS
Volken::HTTP 에 대한 HTTPS 지원
- SSL 라이브러리는 직접 제공되지 않는다. 라이브러리 설치가 필요하다. 💩
- 그 외 기능은 HTTP와 동일하다.
## Volken::Json
Json parser 이다.
- file 혹은 string 을 parsing 하여 tree 구조를 만든다.
## Volken::Mark
간단한 몇 가지 문법을 지원하는 html 마크업 생성기.
- blockquote, ul/li, h1-5, pre 태그를 지원한다.
## Volken::NumberOfCases
경우의 수를 따져 순열, 조합의 경우로 원소를 재 배열한다.
## Volken::PF Volken::QN Volken::ZN
부동 소수점을 사용하지 않고 유리수 연산을 제공한다.
- Volken::ZN - 이를 위해 먼저 정수와 정수의 사칙연산을 정의한다
- Volken::PF - 나눗셈을 구현하기 위해 소인수 분해를 구현한다.
- Volken:QN - 정수의 비로 유리수를 정의하고 유리수의 사칙연산을 정수의 사칙연산으로 구현한다.
## Volken::Part
- Multipart form data 로 바이너리파일을 전송하기 위해 사용하는 Multipart 구조체를 생성한다.
- usage/multipart/send_via_multipart.pl 에서 사용한다.
## Volken::Prop
- java 의 Properties 객체에 상응한다.
- 구분자로 나뉜 키-값 파일을 로드하여 키에 해당하는 값을 반환한다.
## Volken::Util
유틸리티 모음이다.
- pretty_time - 형식화된 시간을 반환하거나
- percent_decode - URL 에 사용되는 %숫자 의 값을 디코딩한다.
- trim - 앞뒤 공백을 제거한다.
# usage
## echo
### Server.pl
- Server socket 을 열고 대기한 후 들어온 요청에 대해 쓰레드를 생성하여 처리를 위임한다.
- 들어온 데이터를 그대로 돌려준다.
### Client.pl
소켓을 열고 입력받은 문자열을 서버에 전송하고 응답내용을 프린트 한 후 종료한다.
## multipart
### send.html
브라우저에서 multipart-form-data를 전송하도록 하는 예제
### send_via_multipart.pl
lib/Volken::Part 객체를 사용하여 multipart-form-data 로 바이너리 파일을 전송한다.
## number
Volken::PF, Volken::QN, Volken::ZN 을 이용하여 파이 계산, 사칙연산 계산 등을 시연

