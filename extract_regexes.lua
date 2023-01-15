local expat = require("lxp")

local fileExtract = arg[1]

-- function to initialize the XML parser callbacks. It is a function to keep the state variables
-- local. No need to let anybody know the filthy details.
local function initializeXmlParserCallbacks()
    -- keeps track of the current XML tag, otherwise the tag conten (character data) does not
    -- know, which tag it belongs to
    local currentXmlTag = nil

    local callbacks = {
        -- callback for strings and CDATA blocks inside tags.
        -- we basically only care about the content of name or script tags
        CharacterData = function (_, value)

            -- skip character data of tags we don't care about
            if currentXmlTag ~= "string" then
                return
            end

            -- get rid of leading spaces, so we can skip empty script blocks
            value = value:gsub("^%s+", "")
            if value == "" then
                return
            end

	    print(value)
        end,

        -- callback to record the parent XML tag of the next called callback
        StartElement = function (_, elementName)
            currentXmlTag = elementName
        end,

        -- we are done with the XML tag and go backwards in the tree, so discard unneeded information
        EndElement = function (_, elementName)
            currentXmlTag = nil
        end,
    }

    return callbacks
end
local callbacks = initializeXmlParserCallbacks()

-- function to read the content of a given file
local function readFileContent(fileName)
    io.input(fileName)
    local fileContent = io.read("*a")
    io.close()
    return fileContent
end

-- function to do something (run the XML parser) on the file content
local function handleFileContent(content)
    local parser = expat.new(callbacks)
    parser:parse(content)
end

-- function to handle a found file. If the file name does not end on .xml, this is a noop
local function handleXmlFile(fileName)
    if fileName:find(".xml$") then
        print(fileName)
        local content = readFileContent(fileName)
        handleFileContent(content)
    end
end

handleXmlFile(fileExtract)
