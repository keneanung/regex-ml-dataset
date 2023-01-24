local lyaml   = require "lyaml"
local rex = require "rex_pcre2"

function readAll(file)
    local f = assert(io.open(file, "rb"))
    local content = f:read("*all")
    f:close()
    return content
end

local yamlContent = readAll("dataset.yaml")

local validYaml, tableOrError = pcall(lyaml.load, yamlContent)

if not validYaml then
    print("The file does not contain valid yaml", tableOrError)
    os.exit(1)
end

local t = tableOrError
local error = false

for index, dataEntry in ipairs(t) do

    if not dataEntry.regex then
        print("missing regex...")
        error = true
    else
        local regex = rex.new(dataEntry.regex)

        if not dataEntry.matching then
            print("missing matching entries:", dataEntry.regex)
            error = true
        else
            for _, str in pairs(dataEntry.matching) do
                if type(str) ~= "string" then
                    print("wrong datatype in matching entries:", dataEntry.regex, type(str))
                    error = true
                elseif not regex:find(str) then
                    print("Found non-matching string (supposed to match):", dataEntry.regex, str)
                    error = true
                end
            end
        end

        if not dataEntry["non-matching"] then
            print("missing non-matching entries:", dataEntry.regex)
            error = true
        else
            for _, str in pairs(dataEntry["non-matching"]) do
                if type(str) ~= "string" then
                    print("wrong datatype in non-matching entries:", dataEntry.regex, type(str))
                    error = true
                elseif regex:find(str) then
                    print("Found matching string (supposed to not match):", dataEntry.regex, str)
                    error = true
                end
            end
        end
    end
end

if error then
    os.exit(1)
end