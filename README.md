# DST-Korean-LanguagePack-Font
Font applying project for DST KOR Language Pack
굶지마 다함께 한글화 모드 폰트 적용 프로젝트

드림님을 위한 안내:

이 패치는 서버 모드에 적합하지 않습니다.

1. ~~fontapply_(캐릭터명).lua 파일에 있는 소스코드를 한글화 모드의 modmain.lua의 맨 앞줄에 붙여넣습니다.~~
코드 가독성을 위해서 직접 삽입하지 마시고 modmain.lua 맨 윗줄에 modimport "main/applyfont_(캐릭터명)"을 삽입해 주세요.
**주의: 서버 모드에는 절대 적용하지 마세요.**
    
2. font 폴더와 main 폴더를 폴더째로 모드 파일에 병합하세요.

V 0.1
: 첫 개시, 현재 웜우드 폰트 적용됨

V 0.2
: 웜우드 폰트 텍스쳐에 밉맵 적용 해제하여 최적화

V 0.3
: 서버 모드에는 폰트를 적용하지 마세요

V 0.4
: 누락된 문자 수정 및 영문/한글 글꼴 통합
