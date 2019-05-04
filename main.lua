local widget = require( "widget" )
_K = {}
_K.utils  = require("dmc_corona.dmc_utils")

local tfd = require("plugin.tinyfiledialogs")
--
local hx_export = require("inky.lib")
local ink = hx_export["ink"]

--inkRunTime.HashSetString("")
local ox, oy = math.abs(display.screenOriginX), math.abs(display.screenOriginY)
local tabBarHeight = 0
local backgroundColor = { 240/255 }
local _H, _W = display.contentHeight, display.contentWidth
--
local commands = {} -- for event listers
--

local myStory, selectIndex
local storyGroup  = display.newGroup()
-- storyGroup.x = _W/2
-- storyGroup.y = _H/2
storyGroup.const_X = _W*.5
storyGroup.const_Y = _H*.25
storyGroup.const_LineSpace = 16
storyGroup.scrollView = nil 
storyGroup.anchorChildren = false

local choicesGroup = display.newGroup()
-- choicesGroup.x = _W/2
-- choicesGroup.y = _H/2
choicesGroup.const_X = _W*.5
choicesGroup.const_Y = _H*.5
choicesGroup.const_LineSpace = 16

-- this is main
function storyGroup:startStory(inkJsonString)
    --myStory = ink.runtime.Story.new("{\"inkVersion\":12,\"root\":[[{\"->\":\"start\"},null],\"done\",{\"start\":[[\"^Hello world\",\"\\n\",[\"ev\",\"str\",{\"f()\":\".^.s\"},\"/str\",\"/ev\",{\"*\":\".^.c\",\"flg\":18},{\"s\":[\"^Hut 14.\",null],\"c\":[{\"f()\":\".^.^.s\"},\"\\n\",\"^The door was locked after I sat down.\",\"\\n\",\"end\",{\"#f\":5}]}],null],{\"#f\":3}],\"global decl\":[\"ev\",0,{\"VAR=\":\"forceful\"},0,{\"VAR=\":\"evasive\"},0,{\"VAR=\":\"teacup\"},0,{\"VAR=\":\"gotcomponent\"},0,{\"VAR=\":\"drugged\"},0,{\"VAR=\":\"hooper_mentioned\"},0,{\"VAR=\":\"losttemper\"},0,{\"VAR=\":\"admitblackmail\"},0,{\"VAR=\":\"hooperClueType\"},0,{\"VAR=\":\"hooperConfessed\"},0,{\"VAR=\":\"smashingWindowItem\"},0,{\"VAR=\":\"notraitor\"},0,{\"VAR=\":\"revealedhooperasculprit\"},0,{\"VAR=\":\"smashedglass\"},0,{\"VAR=\":\"muddyshoes\"},0,{\"VAR=\":\"framedhooper\"},0,{\"VAR=\":\"putcomponentintent\"},0,{\"VAR=\":\"throwncomponentaway\"},0,{\"VAR=\":\"piecereturned\"},0,{\"VAR=\":\"longgrasshooperframe\"},0,{\"VAR=\":\"DEBUG\"},\"/ev\",\"end\",null],\"#f\":3}]}");
    myStory = ink.runtime.Story.new(inkJsonString)
    self:init()
    self:continueToNextChoice()
end

function storyGroup:continueToNextChoice()
    while (myStory:get_canContinue()) do
        local grafs = _K.utils.split(myStory:Continue(), "\n")
        for k, text in pairs(grafs) do
            if (text)  then
               print(text) -- insertBefore($choices)
               self:add(text)
            end
        end
    end

    local choices = myStory:get_currentChoices() or {}
    print (choices.length)
    for i = 1, choices.length do
        local choice = choices:pop() 
        print ("choice["..choice.index.."]", choice.text)
        local obj = choicesGroup:add(choice.index..": "..choice.text)
        obj:addEventListener("tap", commands.onChoiceSelect)
        obj.index = choice.index
    end
end

-----------------
--
-----------------
function storyGroup:add(text)
    local numChildren = self.scrollView:getView().numChildren
    print("num", numChildren)
    local obj = display.newText(text, self.const_X, self.const_Y * numChildren, native.SystemFont, 16 )
    obj:setFillColor( 0.2, 0.6, 0.8 )
    self.scrollView:insert(obj)
end

-- scrollView listener
local function scrollListener( event )
    local phase = event.phase
    local direction = event.direction
    if "began" == phase then
        --print( "Began" )
    elseif "moved" == phase then
        --print( "Moved" )
    elseif "ended" == phase then
        --print( "Ended" )
    end
    -- If the scrollView has reached its scroll limit
    if event.limitReached then
        if "up" == direction then
            --print( "Reached Top Limit" )
        elseif "down" == direction then
            --print( "Reached Bottom Limit" )
        elseif "left" == direction then
            --print( "Reached Left Limit" )
        elseif "right" == direction then
            --print( "Reached Right Limit" )
        end
    end
    return true
end

function storyGroup:init()
   self.scrollView =  widget.newScrollView {
        left = 0,
        top = 0,
        width = display.contentWidth,
        height = display.contentHeight,
        hideBackground = false,
        backgroundColor = backgroundColor,
        --isBounceEnabled = false,
        horizontalScrollDisabled = false,
        verticalScrollDisabled = false,
        listener = scrollListener
    }
    self.scrollView:toBack()
end
-----------------
--
-----------------
local function debounceChoiceSelect()
    myStory:ChooseChoiceIndex(selectedIndex);
    choicesGroup:empty()
    storyGroup:continueToNextChoice()
    choicesGroup.disabled = false;
end

function commands.onChoiceSelect(e)
    print("choice is clicked", e.target.index)
    if not choicesGroup.disable then
        choicesGroup.disable = true
        selectedIndex = e.target.index
        timer.performWithDelay(1000, debounceChoiceSelect)
    end
end

-----------------
--
-----------------
function choicesGroup:add(text)
    local obj = display.newText("text", self.const_X,  self.const_Y + self.numChildren* self.const_LineSpace, native.systemFont, 14)
    obj:setFillColor( 0, 0, 1 )
    print(obj.x, obj.y)
    self:insert(obj)
    return obj
end

function choicesGroup:empty()
    for i=1, self.numChildren do
        self[i]:removeEventListener("tap", commands.onChoiceSelect)
    end
end
-----------------
-- main
-----------------

local filePath = tfd.openFileDialog{
				title = "Open single file", default_path_and_file = system.pathForFile("Text/"),
				filter_patterns = "*.json", -- may also be an array, cf. next button
				filter_description = "inky json" -- name that can substitute for patterns
            }

local file = io.open( filePath, "r" )

if file then
	-- read all contents of file into a string
	local contents = file:read( "*a" )
	print( "Contents of " .. filePath )
	--print( contents )
	io.close( file )
    --
    storyGroup:startStory(contents)
end
            


