-- Copyright (c) 2015, Robzz (https://github.com/Robzz)
-- License : https://github.com/Robzz/computercraft-programs/LICENSE
-- ccsh - A better computercraft shell
-- TODO : environment variables, including PATH and PS2
--        input/output redirections, pipes
--        command history
--        tab autocompletion

local argparse = dofile("lib/argparse")
local version = "v0.1a"

local tArgs = {...}
local environment = {
    ["PATH"] = "rom",
    ["PS2"] = "ccsh> "
}

local function parseArgs()
    -- Default parameters
    local params = {
        ["ok"] = true,
        ["interactive"] = true,
        ["printVer"] = false,
        ["scriptFile"] = nil
    }
    local parser = argparse("ccsh", "A better ComputerCraft shell.")
    parser:argument("script", "Shell script file."):args("?")
    parser:flag("-v --version", "Print ccsh version and exit.")
    local success, parsedArgs = parser:pparse(tArgs)
    if not success then 
        -- In that case, parsedArgs contains the error message
        print(parsedArgs)
        print(parser:get_usage())
        params.ok = false
    else
        if parsedArgs.script then
            params.interactive = false
            params.scriptFile = parsedArgs.script
        end
        if parsedArgs.version then params.printVer = true end
    end
    return params
end

local function parseLine(line)
    for subcommand in string.gmatch(line, "[^;]+") do
        shell.run(subcommand)
    end
end

local function mainLoop() 
    local cmd
    while true do
        term.write(environment.PS2)
        cmd = io.read()
        shell.run(cmd)
    end
end

local function executeScript(filename)
   if not fs.exists(filename) then
       print("Error : file " .. filename .. " does not exist.")
       return
   end
   for line in io.lines(filename) do
       parseLine(line)
   end
end

local params = parseArgs()
if not params.ok then
    return 1
end

if params.printVer then print("ccsh " .. version) 
elseif params.interactive then
    mainLoop()
else
    executeScript(params["scriptFile"])
end
