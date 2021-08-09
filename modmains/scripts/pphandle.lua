--gets utf8 string and returns codepoint in decimal and num. of bytes
local function utf8CodePoint(str, k)
    local c0, c1, c2, c3
    local bytes = 1
    local idx = k * -1
    c0 = string.byte(str,idx,idx)
	
	if c0 == nil then return nil, 0 end                                           --nil value
	
    if c0 ~= nil and c0 >= 128 then                                               --if not then it's 1 Byte char
        c1 = string.byte(str,idx-1,idx-1)
		bytes = bytes + 1
		if c1 >= 128 and c1 < 192 then                                            --if not then it's 2 Byte char
		    c2 = string.byte(str,idx-2,idx-2)
			bytes = bytes + 1
			if c2 >= 128 and c2 < 192 then                                        --if not then it's 3 Byte char
			    c3 = string.byte(str,idx-3,idx-3)
				bytes = bytes + 1
				return (c3-240)*262144+(c2-128)*4096+(c1-128)*64+(c0-128), bytes  --4 Bytes char
			else
			    return (c2-224)*4096+(c1-128)*64+(c0-128), bytes --3 Bytes char
			end
		else
		    return (c1-192)*64+(c0-128), bytes --2 Bytes char
	    end
	else
	    return c0, bytes --1 Byte char
	end
end


--finds first char in the field, from the last character
local function FirstValidChar(keyword)
	local searchpoint = 1
	local firstchar, bytelen
	local isValid
	while true do
	    firstchar, bytelen = utf8CodePoint(keyword, searchpoint)
		searchpoint = searchpoint + bytelen
		if firstchar == nil or
				(firstchar >= 44032 and firstchar <= 55203) or  --Hangul Syllable Field
				(firstchar >= 48 and firstchar <= 57) or     --Number Field
				(firstchar >= 65 and firstchar <= 90) or     --Alphabet Uppercase Field
				(firstchar >= 97 and firstchar <= 122) then    --Alphabet Lowercase Field

		    return firstchar
		end
	end
end

--matchtable = 2459AEHIORSTUZaehiorstuz (unused for now)
--0: no coda
--1: has 'ㄹ' coda
--2: has non-'ㄹ' coda
local function PPhandler(keyword)
	-- local matchtable1 = {49, 55, 56, 76, 108}
	-- local matchtable2 = {
	    -- 48, 51, 54, 66,
		-- 67, 68, 71, 75,
		-- 80, 81, 84, 98,
		-- 99, 100, 103,107,
		-- 112, 113, 116
		-- }
	local pp
	local firstchar = FirstValidChar(keyword)
	if firstchar ~= nil and (firstchar >= 44032 and firstchar <= 55203) then  --firstchar in Hangul Syllable Field
	    if firstchar % 28 == 16 then  --A specific coda occurs in every 28 chars
		    return 0
		elseif firstchar % 28 == 24 or firstchar % 28 == 3 then
		    return 1
		else
		    return 2
		end
	else
		return 0
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
	local str = str or ""
	local name = name or ""
	local ppclass = PPhandler(name) or 0

	if ppclass ~= 2 then
		str = str:gsub(name .. "으", name)
	end
	
	if ppclass ~= 0 then
		local oldPP = str:match(name.."([^%s]*)")
		str = pptable[oldPP] and str:gsub(name .. oldPP, name .. pptable[oldPP]) or str
	end
	return str
end

return
{
    utf8CodePoint = utf8CodePoint,
	FirstValidChar = FirstValidChar,
	PPhandler = PPhandler,
	replacePP = replacePP
}
