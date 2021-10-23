-- This information tells other players more about the mod


name = "굶지마 다함께 한글화 [클라이언트 버전]"
version = "1.0.5.20211023.00"
description = [[Version: ]] .. version ..
[[

게임 내 기본 폰트만을 이용합니다.
데디케이티드 서버나 동굴이 포함된 호스트는 서버 버전이 있어야 캐릭터 대사가 번역됩니다.
캐릭터 전용 폰트는 별도의 모드를 사용해 주세요.

모드 사용 시 필요한 설정(게임 내 설정):
저사양 텍스쳐 옵션 비활성화
	
모드 총책임자: Mr.Dream
기술 총책임자: AFS Co. Ltd.
Original mod by wrinos]]

author = "굶지마 다함께 한글화 팀"
forumthread = ""

-- This lets other players know if your mod is out of date, update it to match the current version in the game
api_version = 10
priority = 1

icon_atlas = "hangulpatch.xml"
icon = "hangulpatch.tex"

dont_starve_compatible = false
reign_of_giants_compatible = false
shipwrecked_compatible = false
dst_compatible = true

all_clients_require_mod=false
server_filter_tags = {"korean","language"}
client_only_mod=true
