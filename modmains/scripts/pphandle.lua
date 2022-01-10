--This module should be used under UTF-8 environment, otherwise will not work!

local filterset = 
	{
		"2", "4", "5", "9",
		"a", "e", "h", "i", "o", "r", "s", "t", "u", "z",
		"A", "E", "H", "I", "O", "U", "S", "T", "U", "Z"
	}
local filter = {}

for _, v in pairs(filterset) do
	filter[string.byte(v)] = true
end

local function IsFiltered(bytecode)
	return filter[bytecode]
end

--gets UTF-8 char and returns its decimal code in UTF-8
local function utf8CodePoint(char)
	if string.utf8len(char) > 1 then
		print("\"char\" expected to be a single letter!")
		return
	end

    local c = {}
    c = {string.byte(char, 1, 4)}

    return c[1] or 0 + ((c[2] or 192) - 192) * 64 + ((c[3] or 128) - 128) * 4096 + ((c[4] or 240) - 240) * 262144, #c
end

--finds first char in the word, from the last character
local function FirstValidChar(word)
	for i=1,string.utf8len(word) do
	    local char = utf8CodePoint(string.utf8sub(-i,-i))
		if char == nil or
				(char >= 44032 and char <= 55203) or  --Hangul syllable
				(char >= 48 and char <= 57) or        --Number
				(char >= 65 and char <= 90) or        --Alphabet Uppercase
				(char >= 97 and char <= 122) then     --Alphabet Lowercase
		    return char
		end
	end
end

--matchtable = 2459AEHIORSTUZaehiorstuz
--0: no coda
--1: has 'ㄹ' coda
--2: has non-'ㄹ' coda
local function PPtype(word)
	local char = utf8CodePoint(FirstValidChar(word))
	if char ~= nil and (char >= 44032 and char <= 55203) then  --Hangul syllable
		return (char % 28 == 16 and 0) or ((char % 28 == 24 or char % 28 == 3) and 1) or 2 --specific coda occurs every 28 syllable in UTF-8 Hangul field.
	else
		return IsFiltered(word) and 0 or 2 --Alphabet and number
    end
end

--the keys are for the coda-less syllables
local pptable =
{
	['는']='은',
	['가']='이',
	['를']='을',
	['와']='과',
	['랑']='이랑',
	['고']='이고',
	['야']='아',
	['여']='이여',
	['다']='이다',
}

local function replacePP(str, name)
	if str == nil then
		return ""
	else
		local name = name or ""
		local pptype = PPtype(name) or 0

		if pptype ~= 2 then
			str = str:gsub(name, name.."으")
		end
		
		if pptype ~= 0 then
			local oldPP = string.utf8sub(str:match(name.."([^%s]*)"), 1)
			str = pptable[oldPP] and str:gsub(name .. oldPP, name .. pptable[oldPP]) or str
		end
		return str
	end
end

return
{
    utf8CodePoint = utf8CodePoint,
	FirstValidChar = FirstValidChar,
	PPtype = PPtype,
	replacePP = replacePP
}
