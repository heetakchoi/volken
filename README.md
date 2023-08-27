<h1>volken</h1>

<div>
  <h3>목표</h3>
  perl로 만들어진 utility library.<br />
  추가 설치 권한이 없는 환경에서 어떻게든 사용할 방법을 제공하는 것이 목표.
</div
<div>
  <h3>Volken::File</h3>
  origin, target 디렉토리를 argument로 받아, origin의 하위 디렉토리/파일을 순회하면서 target 디렉토리 아래 동일 위치에 같은 이름의 파일이 있는지 살펴보고 존재하지 않는 경우 복사한다. origin 디렉토리는 반드시 존재해야 한다. target 디렉토리가 해당 위치에 없는 경우 새로 생성한다.
</div>
<div>
  <h3>Volken::HTTP</h3>
  <ul>
    <li>HTTP protocol 을 사용하여 message 를 보내고 받는다.</li>
    <li>IO::Socket::INET 을 직접 이용하여 Socket 을 다룬다.</li>
    <li>GET, POST method 를 지원한다.</li>
    <li>request multipart/form-data 전송을 지원한다.</li>
    <li>response chunked mode 를 지원한다.</li>
  </ul>
<div>
<div>
  <h3>Volken::HTTPS</h3>
  <ul>
    <li>Volken::HTTP 에 대한 HTTPS 구현</li>
    <li>SSL 라이브러리는 직접 제공되지 않는다. 설치가 필요하다.</li>
  </ul>
</div>
<div>
  <h3>Volken::Json</h3>
  Json parser 이다. file 혹은 string 을 parsing 하여 tree 구조를 만든다.
</div>
<div>
  <h3>Volken::Mark</h3>
  간단한 몇 가지 문법을 지원하는 마크업 생성기<br />
  blockquote, ul/li, h1-5, pre 태그 지원
</div>
<div>
  <h3>Volken::ZN Volken::PF Volken::QN</h3>
  <ul>
    <li>ZN - 정수</li>
    <li>PF - Prime Factorization, 소인수 분해</li>
    <li>QN - 정수의 비로 표현된 유리수, 부동 소수점 표현의 부정확함을 해결하기 위해 (속도를 희생한) 유리수 기반 계산 체제</li>
  </ul>
</div>
