# DST-Korean-LanguagePack-Font
Font applying project for DST KOR Language Pack
굶지마 다함께 한글화 모드 폰트 적용 프로젝트

드림님을 위한 안내:

일단 이 소스는 아직 서버 모드로는 테스트되지 않은 상태입니다. 하지만 잘 될 것이라고 장담합니다.

적용하는 방법은 다음과 같습니다.
1. 소스코드 적용
- fontapply_(캐릭터명).lua 파일에 있는 소스코드를 한글화 모드의 modmain.lua의 맨 앞줄에 붙여넣습니다.
- 만약 modmain.lua의 코드를 깔끔하게 유지하시고 싶다면 fontapply 파일을 (모드 폴더)/main 폴더를 만들어 그 안에 넣고, modmain.lua의 맨 앞줄에 다음 코드를 삽입해주세요.
     modimport "main/fontapply_(캐릭터명)"
    
2. 폰트 파일 적용
- 그냥 모드 폴더에 font 폴더를 만들어서 그 안에 .zip 포맷으로 된 폰트 파일들을 삽입하시면 됩니다.

V 0.1
: 첫 개시, 현재 웜우드 폰트 적용됨

V 0.2
: 웜우드 폰트 텍스쳐에 밉맵 적용 해제하여 최적화
