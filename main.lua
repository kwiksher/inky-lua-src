local widget = require( "widget" )
--
local hx_export = require("inky.lib").
local ink = hx_export["ink"]

--inkRunTime.HashSetString("")

local myStory, selectIndex
local storyGroup  = display.newGroup()
storyGroup.const_X = 10
storyGroup.const_Y = 0
storyGroup.const_LineSpace = 16
storyGroup.scrollView = nil

local choicesGroup = display.newGroup()
choicesGroup.nodes = {}
choicesGroup.const_X = 50
choicesGroup.const_Y = 0
choicesGroup.const_LineSpace = 16

function startStory(inkFile)
    myStory = ink.runtime.Story.new("{\"inkVersion\":12,\"root\":[[{\"->\":\"start\"},null],\"done\",{\"start\":[[\"^Hello world\",\"\\n\",[\"ev\",\"str\",{\"f()\":\".^.s\"},\"/str\",\"/ev\",{\"*\":\".^.c\",\"flg\":18},{\"s\":[\"^Hut 14.\",null],\"c\":[{\"f()\":\".^.^.s\"},\"\\n\",\"^The door was locked after I sat down.\",\"\\n\",\"end\",{\"#f\":5}]}],null],{\"#f\":3}],\"global decl\":[\"ev\",0,{\"VAR=\":\"forceful\"},0,{\"VAR=\":\"evasive\"},0,{\"VAR=\":\"teacup\"},0,{\"VAR=\":\"gotcomponent\"},0,{\"VAR=\":\"drugged\"},0,{\"VAR=\":\"hooper_mentioned\"},0,{\"VAR=\":\"losttemper\"},0,{\"VAR=\":\"admitblackmail\"},0,{\"VAR=\":\"hooperClueType\"},0,{\"VAR=\":\"hooperConfessed\"},0,{\"VAR=\":\"smashingWindowItem\"},0,{\"VAR=\":\"notraitor\"},0,{\"VAR=\":\"revealedhooperasculprit\"},0,{\"VAR=\":\"smashedglass\"},0,{\"VAR=\":\"muddyshoes\"},0,{\"VAR=\":\"framedhooper\"},0,{\"VAR=\":\"putcomponentintent\"},0,{\"VAR=\":\"throwncomponentaway\"},0,{\"VAR=\":\"piecereturned\"},0,{\"VAR=\":\"longgrasshooperframe\"},0,{\"VAR=\":\"DEBUG\"},\"/ev\",\"end\",null],\"#f\":3}]}");
    --print(story:ToJsonString())
    
end

function continueToNextChoice() 
    while (myStory.canContinue) do
        local grafs = myStory.Continue().split("\n")
        for k, text in pairs(grafs) do
            if (text)  then
               storyObj:insertText(text)
               print(text) -- insertBefore($choices)
            end
        end
    end

    local choices = myStory.currentChoices
    for i = 1, #choices do
        local choice = choices[i]
        print (choice.text)
        local obj = choicesGroup:add(choice.text)
        obj:addEventListener("click", onChoiceSelect)
        obj.index = i
    end
end

-----------------
-- 
-----------------
function stoyGroup:add(text)
    if (self.scrollView == nil) then
        self.scrollView = self.newScrollView()
    end
    local numChildren = self.scrolView.numChildren
    local obj = display.newText(text, self.const_X, self.const_Y * numChildren, native.SystemFont, 16 )
    self.scrollView:insert(Obj)
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

local ox, oy = math.abs(display.screenOriginX), math.abs(display.screenOriginY)
local tabBarHeight = 0
local backgroundColor = { 240/255 }

function scrollGroup:newScrollView = function()
    -- Create a scrollView
    local scrollView = widget.newScrollView {
        left = 20-ox,
        top = 62,
        width = display.contentWidth+ox+ox-60,
        height = display.contentHeight-32-tabBarHeight-120,
        hideBackground = false,
        backgroundColor = backgroundColor,
        --isBounceEnabled = false,
        horizontalScrollDisabled = false,
        verticalScrollDisabled = false,
        listener = scrollListener
    }
    self:insert(scrollView)
    return scrollView
end
-----------------
-- 
-----------------
function onChoiceSelect(e) 
    if not choicesGroup.disable then
        choicesGroup.disable = true
        selectedIndex = e.target.index
        TweenLite.delayedCall( 0.1,debounceChoiceSelect);
    end
end

function debounceChoiceSelect() 
    myStory.ChooseChoiceIndex(selectedIndex);
    choicesGroup:empty()
    continueToNextChoice()
    choicesGroup.disabled = false;
end
-----------------
-- 
-----------------
function choicesGroup:add(text)
    local obj = display.newText(self, text, self.const_X,  self.const_Y + #self.nodes* self.const_LineSpace, native.systemFont, 14)
    self.nodes:insert(obj)
end

function choicesGroup:empty()
    for i=0, #self.nodes do
        self.nodes[i].removeEventListener("click", onChoiceSelect)
    end
    self.nodes = {}
end