# 목표
설치 권한이 없거나 제한적인 시스템을 사용 중일 때 유용하게 사용할 수 있는 방법을 제공한다.
> Perl 은 설치되어 있다고 가정한다.
# 단독 실행 코드
### console/log10_by_approximation.pl
> 로그표나 내장 로그함수를 사용하지 않고 상용로그의 근사값을 계산한다.
### console/db-query.pl
> mysql client - perl 의 DBI 인터페이스를 사용하여 mysql 에 접근하여 SQL을 전송하고 결과를 반환받는다.
### console/mp3split.pl
> 유튜브 플리와 같이 여러 곡이 하나의 mp3파일에 존재할 경우 mp3info.txt 에 지정된 재생 시간 정보를 기반으로 파일을 나누고 ID3 태그를 생성한다.
### sqrt_by_newton_raphson.pl
> 뉴튼-랩슨 방법으로 제곱근을 구한다.
# Module
## Volken::File
> origin, target 디렉토리를 argument로 받아, origin의 하위 디렉토리/파일을 순회한다. \
> target 디렉토리 아래 동일 위치에 같은 이름의 파일이 있는지 살펴보고 존재하지 않는 경우 복사한다. \
> origin 디렉토리는 반드시 존재해야 한다. \
> target 디렉토리가 해당 위치에 없는 경우 새로 생성한다.
## Volken::HTTP
HTTP 프로토콜을 지원하는 클라이언트
> HTTP protocol 을 사용하여 message 를 보내고 받는다. \
> IO::Socket::INET 을 직접 이용하여 Socket 을 다룬다. \
> GET, POST method 를 지원한다. \
> request multipart/form-data 전송을 지원한다. \
> response chunked mode 를 지원한다.
## Volken::HTTPS
Volken::HTTP 에 대한 HTTPS 지원
> SSL 라이브러리는 직접 제공되지 않는다. 라이브러리 설치가 필요하다. 💩 \
> 그 외 기능은 HTTP와 동일하다.
## Volken::Json
> Json parser 이다.
> file 혹은 string 을 parsing 하여 tree 구조를 만든다.
## Volken::Mark
간단한 몇 가지 문법을 지원하는 html 마크업 생성기.
> blockquote, ul/li, h1-5, pre 태그를 지원한다.
## Volken::NumberOfCases
> 경우의 수를 따져 순열, 조합의 경우로 원소를 재 배열한다.
## Volken::PF, Volken::QN, Volken::ZN
> 부동 소수점을 사용하지 않고 유리수 연산을 제공한다.
> Volken::ZN - 이를 위해 먼저 정수와 정수의 사칙연산을 정의한다. \
> Volken::PF - 나눗셈을 구현하기 위해 소인수 분해를 구현한다. \
> Volken:QN - 정수의 비로 유리수를 정의하고 유리수의 사칙연산을 정수의 사칙연산으로 구현한다.
## Volken::Part
> Multipart form data 로 바이너리파일을 전송하기 위해 사용하는 Multipart 구조체를 생성한다. \
> usage/multipart/send_via_multipart.pl 에서 사용한다.
## Volken::Prop
> java 의 Properties 객체에 상응한다. \
> 구분자로 나뉜 키-값 파일을 로드하여 키에 해당하는 값을 반환한다.
## Volken::Util
> 유틸리티 모음이다.
> pretty_time - 형식화된 시간을 반환하거나 \
> percent_decode - URL 에 사용되는 %숫자 의 값을 디코딩한다. \
> trim - 앞뒤 공백을 제거한다.
# usage
> 모듈에 대한 검증 코드
### echo/Server.pl
> Server socket 을 열고 대기한 후 들어온 요청에 대해 쓰레드를 생성하여 처리를 위임한다. \
> 들어온 데이터를 그대로 돌려준다.
### echo/Client.pl
> 소켓을 열고 입력받은 문자열을 서버에 전송하고 응답내용을 프린트 한 후 종료한다.
### multipart/send.html
> 브라우저에서 multipart-form-data를 전송하도록 하는 예제
### multipart/send_via_multipart.pl
> lib/Volken::Part 객체를 사용하여 multipart-form-data 로 바이너리 파일을 전송한다.
### number/*.pl
> Volken::PF, Volken::QN, Volken::ZN 을 이용하여 파이 계산, 사칙연산 계산 등을 시연
### s-from/*
> file_sync.pl 을 통해 디렉토리 복제를 테스트하기 위한 디렉토리
### data.json
> parse_json.pl 에서 테스트를 위해 준비한 json 파일
### file_sync.pl
> Volken::File 의 기능을 검증하기 위해 s-from 디렉토리를 복제한다.
### http.pl
> Volken::HTTP, Volken::HTTPS 의 기능을 검증한다.
### markup.html
> Volken::Mark 의 기능을 검증하기 위해 준비한 템플릿
### markup.pl
> Voken::Mark 의 기능을 사용하여 markup.html 의 내용을 Markup 한다.
### nPr_nCr.pl
> Volken::NumberOfCases 의 기능을 검증한다. 순열과 조합의 경우의 수를 나열한다.
### parse_json.pl
> Volken::Json 의 기능을 검증한다.
### prettyjson.pl
> Json 포맷의 데이터를 입력받은 indent 를 사용하여 보기좋게 포맷팅한다.
### wasm/*
> wasm 을 이용하여 브라우저에서 사칙연산을 동작한다.
### web/ant_in_web.pl, web/ant.pl
> 랭턴의 개미를 시뮬레이션한다.
### web/article/*
> javascript 를 두 가지 (callback, promise) 방법으로 사용하여 client side 에서 글 목록-상세 이동을 구현한다.
