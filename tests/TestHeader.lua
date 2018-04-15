UTest = require 'tests\\framework\\u-test'
Lib = require 'LibDeflate'

math.randomseed(os.time())
function CheckStr(str, count, level, ...)
	local startTime = os.clock()

	local fileName = "tests\\data\\str.deflate"
	
	local levels = {...}
	if not level then
		levels = {1,2,3,4,5,6,7,8,9}
	else
		table.insert(levels, 1, level)
	end
	local compressed
	for _, level in ipairs(levels) do
		print(("running: %s, len: %d Level: %d"):format(str:sub(1, 10), str:len(), level))
		local startTime = os.clock()
		for i=1, count or 1 do
			compressed = Lib:Compress(str, level)
		end
		local elapsed = os.clock()-startTime
		
		local outputFile = io.open(fileName, "wb")
		outputFile:write(compressed)
		outputFile:close()
	
		-- puff is a small deflate decompression program in the source code of zlib
		-- https://github.com/madler/zlib/tree/master/contrib/puff
		-- How I build it under Windows:
		-- 1. Install Visual Studio
		-- 2. Edit puff.c: in line 23: #if defined(MSDOS) || defined(OS2) || defined(WIN32) || defined(__CYGWIN__)
		--    Add "|| defined(_WIN32)" at the end
		-- 3. Search "x64 native build tools" in the open menu and open it. You'll see a command line prompt
		-- 4. switch the current folder to the source of puff,
		--    Enter the command: "cl puff.c pufftest.c", the executable "puff.c" should be generated.
		-- 5. Put "puff.exe" under the PATH of your computer.
		os.execute("rm -f "..fileName..".decompressed")
		assert(os.execute("puff -w "..fileName.. "> "..fileName..".decompressed") == 0, "puff decompression failed")
	
		local testFile = io.open(fileName..".decompressed", "rb")
		local testFileContent = testFile:read("*all")
		testFile:close()
	
		UTest.equal(str, testFileContent)
		print((">> Done: %s len: %d compressed: %d, time: %.4f, Level: %d"):format(str:sub(1,10), str:len(), compressed:len(), elapsed, level))
	end



end

function CheckFile(inputFileName, count, level, ...)
	local inputFile = io.open(inputFileName, "rb")
	if not inputFile then
		error("Cannot find "..inputFileName)
	end
	local inputFileContent = inputFile:read("*all")
	local inputFileLen = inputFileContent:len()
	inputFile:close()


	local levels = {...}
	if not level then
		levels = {1,2,3,4,5,6,7,8,9}
	else
		table.insert(levels, 1, level)
	end
	local compressed
	for _, level in ipairs(levels) do
		print(("Compressing %s: %d, Level: %d"):format(inputFileName, inputFileLen, level))
		local startTime = os.clock()
		--os.execute("rm -f profileresult.txt")
		--profiler.start("profileresult.txt")

		count = count or 1
		for i=1, count or 1 do
			compressed = Lib:Compress(inputFileContent, level)
		end
		local elapsed = os.clock()-startTime
		
		local outputFile = io.open(inputFileName..".deflate", "wb")
		outputFile:write(compressed)
		outputFile:close()
	
		os.execute("rm -f "..inputFileName..".decompressed")
	
		-- puff is a small deflate decompression program in the source code of zlib
		-- https://github.com/madler/zlib/tree/master/contrib/puff
		-- How I build it under Windows:
		-- 1. Install Visual Studio
		-- 2. Edit puff.c: in line 23: #if defined(MSDOS) || defined(OS2) || defined(WIN32) || defined(__CYGWIN__)
		--    Add "|| defined(_WIN32)" at the end
		-- 3. Search "x64 native build tools" in the open menu and open it. You'll see a command line prompt
		-- 4. switch the current folder to the source of puff,
		--    Enter the command: "cl puff.c pufftest.c", the executable "puff.c" should be generated.
		-- 5. Put "puff.exe" under the PATH of your computer.
		assert(os.execute("puff -w "..inputFileName..".deflate > "..inputFileName..".decompressed"), "Puff decompression failed")
	
		local testFile = io.open(inputFileName..".decompressed", "rb")
		local testFileContent = testFile:read("*all")
		testFile:close()
	
		UTest.equal(inputFileContent, testFileContent, inputFileName)

		print((">> Done: %s: orig: %d compressed: %d, time: %.4f, Level: %d"):format(inputFileName, inputFileLen, compressed:len(), elapsed/count, level))
	end

end
