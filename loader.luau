--[[
    Script: Automatic Exam Solver (Version 6.6)
    
    Changes:
    - Fixed: Highlight is now purely cosmetic decoration
    - Answer logic is completely independent from highlight
    - Fixed: "Sudan" flag question now excludes "South Sudan" from context matching
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer

-- Special User IDs
local SPECIAL_USERS = {
    [4911742387] = true,
    [9122547299] = true,
}

-- ====================================================================
--                      SPECIAL GREETING FUNCTION
-- ====================================================================

local function showSpecialGreeting()
    if not SPECIAL_USERS[LocalPlayer.UserId] then
        return false
    end
    
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "SpecialGreeting"
    screenGui.ResetOnSpawn = false
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    screenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
    
    local background = Instance.new("Frame")
    background.Name = "Background"
    background.Size = UDim2.new(1, 0, 1, 0)
    background.Position = UDim2.new(0, 0, 0, 0)
    background.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    background.BackgroundTransparency = 0.5
    background.BorderSizePixel = 0
    background.Parent = screenGui
    
    local container = Instance.new("Frame")
    container.Name = "Container"
    container.Size = UDim2.new(0, 400, 0, 500)
    container.Position = UDim2.new(0.5, -200, 0.5, -250)
    container.BackgroundTransparency = 1
    container.Parent = screenGui
    
    local imageLabel = Instance.new("ImageLabel")
    imageLabel.Name = "GreetingImage"
    imageLabel.Size = UDim2.new(0, 400, 0, 400)
    imageLabel.Position = UDim2.new(0, 0, 0, 0)
    imageLabel.BackgroundTransparency = 1
    imageLabel.Image = "rbxassetid://102628059556437"
    imageLabel.ScaleType = Enum.ScaleType.Fit
    imageLabel.Parent = container
    
    local textLabel = Instance.new("TextLabel")
    textLabel.Name = "GreetingText"
    textLabel.Size = UDim2.new(1, 0, 0, 60)
    textLabel.Position = UDim2.new(0, 0, 1, -70)
    textLabel.BackgroundTransparency = 1
    textLabel.Text = "Привет пупс :3"
    textLabel.TextColor3 = Color3.fromRGB(85, 170, 255)
    textLabel.TextSize = 42
    textLabel.Font = Enum.Font.GothamBold
    textLabel.TextStrokeTransparency = 0.7
    textLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 100)
    textLabel.Parent = container
    
    local uiGradient = Instance.new("UIGradient")
    uiGradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(100, 150, 255)),
        ColorSequenceKeypoint.new(0.5, Color3.fromRGB(200, 100, 255)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(100, 150, 255))
    })
    uiGradient.Parent = textLabel
    
    task.spawn(function()
        local offset = 0
        while screenGui.Parent do
            offset = (offset + 0.02) % 1
            uiGradient.Offset = Vector2.new(offset, 0)
            task.wait(0.03)
        end
    end)
    
    local originalSize = container.Size
    container.Size = UDim2.new(0, 0, 0, 0)
    container.Position = UDim2.new(0.5, 0, 0.5, 0)
    
    local tweenIn = TweenService:Create(container, TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
        Size = originalSize,
        Position = UDim2.new(0.5, -200, 0.5, -250)
    })
    tweenIn:Play()
    
    task.wait(3)
    
    local tweenOut = TweenService:Create(container, TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.In), {
        Size = UDim2.new(0, 0, 0, 0),
        Position = UDim2.new(0.5, 0, 0.5, 0)
    })
    local bgFade = TweenService:Create(background, TweenInfo.new(0.5), {
        BackgroundTransparency = 1
    })
    
    tweenOut:Play()
    bgFade:Play()
    tweenOut.Completed:Wait()
    
    screenGui:Destroy()
    
    return true
end

-- ====================================================================
--                      SHOW GREETING FIRST
-- ====================================================================

if SPECIAL_USERS[LocalPlayer.UserId] then
    showSpecialGreeting()
end

-- ====================================================================
--                      MAIN SCRIPT STARTS HERE
-- ====================================================================

local BoredLibrary = loadstring(game:HttpGet("https://raw.githubusercontent.com/T1k-T1k/SakuraHub_RECODE/refs/heads/main/UILibs/BoredLib.lua"))()

local Event = ReplicatedStorage:FindFirstChild("Exam")
local SOLVE_DELAY = 5
local INITIAL_DELAY = 2
local INITIAL_TIMEOUT = 15

-- Store last highlighted button to reset it
local lastHighlightedButton = nil
local lastButtonOriginalTransparency = 1
local lastButtonOriginalColor = Color3.fromRGB(255, 255, 255)

-- ====================================================================
--                      CORRECT ANSWERS DATABASE
-- ====================================================================

local CORRECT_ANSWERS = {
    ["Marine Biology"] = {
        ["Which marine animal has the second largest brain?"] = "Orca",
        ["Which marine animal uses echolocation?"] = "Dolphin",
        ["Which zone of the ocean is the deepest?"] = "Hadal zone",
        ["What is Marine Biology?"] = "The study of organisms and ecosystems in oceans and saltwater environments",
        ["Which ocean is the deepest?"] = "Pacific Ocean",
        ["What is the largest species of shark?"] = "Whale shark",
        ["What is coral made of?"] = "Calcium carbonate",
        ["What is the only sea creatures with 5 eyes?"] = "Opabinia",
        ["What is the largest animal that belongs to the Architeuthidae family?"] = "Giant squid",
        ["What sea creature lives the longest?"] = "Black Coral",
    },
    ["Mathematics"] = {
        ["What is the value of pi rounded to two decimals?"] = "3.14",
        ["Jason has purchased 6842 oranges, eaten 1452, and given 2000 to Eto. How many oranges does he have left?"] = "3390",
        ["What is the derivative of x squared?"] = "2x",
        ["What is the square root of 144?"] = "12",
        ["Evaluate: 15 times 14"] = "210",
        ["Kaneki Ken is thinking of a number for Touka to guess. He tells her the number is the least common multiple of 4 and 6. Which number is Kaneki Ken thinking of?"] = "12",
        ["Find the Least Common Multiple of 168, 252, and 324"] = "4536",
        ["What is the area of a triangle with base 10 and height 8?"] = "40",
        ["What is the greatest common factor of 12 and 18?"] = "6",
        ["What is 1000 - 7?"] = "993",
    },
    ["Italian Food Trivia"] = {
        ["What type of dough is used to make traditional Neapolitan pizza?"] = "Yeast dough",
        ["Which Italian dessert uses espresso-soaked ladyfingers?"] = "Tiramisu",
        ["Which Italian cheese must legally be aged for at least 12 months?"] = "Parmigiano Reggiano",
        ["Which Italian dish is traditionally cooked 'al dente'?"] = "Pasta",
        ["What is the main ingredient in the Tuscan soup called Ribollita?"] = "Bread and vegetables",
        ["Which cheese is specifically used in traditional Pesto Genovese?"] = "Parmigiano Reggiano",
        ["What is the traditional pasta shape used in authentic Carbonara?"] = "Spaghetti",
        ["What herb is essential in a classic Margherita pizza?"] = "Basil",
        ["Which region of Italy is considered the birthplace of Risotto?"] = "Lombardy",
        ["What type of tomatoes are traditionally used for authentic Italian tomato sauces?"] = "San Marzano Tomatoes",
    },
    ["Sakura Stand General Knowledge"] = {
        ["Which Spec has the lowest Health Points"] = "Toji Fushiguro",
        ["Which NPC gives the questline for Wild Hunt?"] = "None",
        ["Which boss drops the Golem Core?"] = "Golem",
        ["Which Npc you need to feed him a food in order to get that spec"] = "Underworld Prince of Darkness",
        ["Which spec requires the item 'Novice Staff'?"] = "Novice Mage",
        ["How many Sword you need to give to aizen in order to obtain the spec"] = "5",
        ["What the first ever skin in the game"] = "Shadow The World | RGB",
        ["Who the first NPC to need to talk in order to get sigil knight"] = "Syanyte",
        ["Which currency is not used for Banner pulls?"] = "Cash",
        ["Who was the first Owner of Sakura Stand"] = "Auddy",
    },
    ["Sports"] = {
        ["Which sport is known as 'the king of sports'?"] = "Football (Soccer)",
        ["How long is an Olympic swimming pool?"] = "50m",
        ["Which of the following sports uses a shuttlecock?"] = "Badminton",
        ["Which one of the following horse names appears in the Steel Ball Run series?"] = "El Condor Pasa",
        ["32th Olympic Games held in which country?"] = "Tokyo, Japan",
        ["A triathlon is completed by consecutively overcoming 3 different events while competing for the fastest overall time. Which of the following events is not part of the triathlon?"] = "Cross Country",
        ["Which of the following martial arts is NOT originally from Japan?"] = "Silat",
        ["Which sport uses the term 'strike'?"] = "Bowling",
        ["How many players are on a standard soccer team on the field?"] = "11",
        ["In which sport would you perform a slam dunk?"] = "Basketball",
    },
    ["Flags around the World"] = {
        ["Which of the following flags do not contain the color yellow?"] = "Haiti",
        ["Which of the following flags do not contain the shape of a circle?"] = "Sierra Leone",
        ["Which of the following flags do not contain the colors red, blue, or white?"] = "Jamaica",
        ["Which of the following country are not from Europe?"] = "Morocco",
        ["What country does this flag belong to?"] = "Sudan",
    },
}

-- ====================================================================
--                      TEXT NORMALIZATION FUNCTIONS
-- ====================================================================

local function trim(s)
    if not s then return "" end
    return string.gsub(s, "^%s*(.-)%s*$", "%1")
end

local function normalizeText(text)
    if not text then return "" end
    local normalized = string.lower(text)
    normalized = string.gsub(normalized, "[^%w%s]", " ")
    normalized = string.gsub(normalized, "%s+", " ")
    normalized = trim(normalized)
    return normalized
end

local function getKeywords(text)
    local normalized = normalizeText(text)
    local keywords = {}
    for word in string.gmatch(normalized, "%w+") do
        if string.len(word) > 2 then
            table.insert(keywords, word)
        end
    end
    return keywords
end

local function countMatchingKeywords(baseQuestion, screenQuestion)
    local baseKeywords = getKeywords(baseQuestion)
    local normalizedScreen = normalizeText(screenQuestion)
    local matches = 0
    
    for _, keyword in ipairs(baseKeywords) do
        if string.find(normalizedScreen, keyword, 1, true) then
            matches = matches + 1
        end
    end
    
    return matches, #baseKeywords
end

local function findBestMatch(questionText, themeTable)
    local bestMatch = nil
    local bestAnswer = nil
    local bestScore = 0
    local bestPercent = 0
    
    for knownQuestion, knownAnswer in pairs(themeTable) do
        local matches, total = countMatchingKeywords(knownQuestion, questionText)
        
        if total > 0 then
            local percent = (matches / total) * 100
            
            if matches > bestScore or (matches == bestScore and percent > bestPercent) then
                bestScore = matches
                bestPercent = percent
                bestMatch = knownQuestion
                bestAnswer = knownAnswer
            end
        end
    end
    
    if bestPercent >= 50 then
        return bestMatch, bestAnswer, bestScore, bestPercent
    end
    
    return nil, nil, 0, 0
end

-- ====================================================================
--                          SYSTEM FUNCTIONS
-- ====================================================================

local function getUI()
    local success, sheet = pcall(function()
        return LocalPlayer.PlayerGui.Exam.CanvasGroup.ExamSheet
    end)
    return success and sheet or nil
end

local function getTopicUI()
    local success, topic = pcall(function()
        return LocalPlayer.PlayerGui.Exam.CanvasGroup.ExamTopic.TopicText
    end)
    return success and topic or nil
end

-- Reset previous button highlight
local function resetHighlight()
    if lastHighlightedButton and lastHighlightedButton.Parent then
        lastHighlightedButton.BackgroundTransparency = lastButtonOriginalTransparency
        lastHighlightedButton.BackgroundColor3 = lastButtonOriginalColor
        print("[SOLVER] Reset previous highlight")
    end
    lastHighlightedButton = nil
end

-- Reset ALL buttons in answer container
local function resetAllHighlights(answerContainer)
    if not answerContainer then return end
    
    for i = 1, 4 do
        local ansBtn = answerContainer:FindFirstChild("Answer" .. tostring(i))
        if ansBtn and (ansBtn:IsA("TextButton") or ansBtn:IsA("TextLabel")) then
            ansBtn.BackgroundTransparency = 1
        end
    end
    print("[SOLVER] Reset all button highlights")
end

-- Highlight button with green color (PURELY COSMETIC - DOES NOT AFFECT LOGIC)
local function highlightButton(button)
    if button then
        -- Save original values
        lastButtonOriginalTransparency = button.BackgroundTransparency
        lastButtonOriginalColor = button.BackgroundColor3
        lastHighlightedButton = button
        
        -- Apply green highlight (only for decoration)
        button.BackgroundTransparency = 0
        button.BackgroundColor3 = Color3.fromRGB(0, 170, 0)
    end
end

-- Check if this is the Sudan flag question
local function isSudanFlagQuestion(questionText)
    local normalized = normalizeText(questionText)
    return string.find(normalized, "flag") and string.find(normalized, "belong")
end

local function solveQuestion(sourceFrameName, isInitial)
    local sheet = getUI()
    if not sheet then 
        warn("[SOLVER] UI not found. Canceling.")
        BoredLibrary.prompt("Error", "UI not found!", 2)
        return 
    end
    
    local sourceFrame = sheet:FindFirstChild(sourceFrameName)
    if not sourceFrame then
        warn("[SOLVER] Frame '" .. sourceFrameName .. "' not found!")
        return
    end
    
    if sourceFrame.GroupTransparency ~= 0 then 
        return 
    end

    -- RESET OLD HIGHLIGHT FIRST
    local answerContainer = sourceFrame:FindFirstChild("AnswerContainer")
    if answerContainer then
        resetAllHighlights(answerContainer)
    end
    resetHighlight()

    local topicLabel = getTopicUI()
    local theme = topicLabel and trim(topicLabel.Text) or "Unknown Theme"

    local questionContent = sourceFrame:FindFirstChild("QuestionContent")
    local questionText = questionContent and trim(questionContent.Text) or "No Question Text"

    print("\n" .. string.rep("=", 60))
    print("[SOLVER] NEW QUESTION DETECTED")
    print(string.rep("=", 60))
    print(string.format("[SOLVER] Topic: %s", theme))
    print(string.format("[SOLVER] Question: %s", questionText))
    print(string.rep("-", 60))
    
    BoredLibrary.prompt("New Question", "Topic: " .. theme, 2)

    local correctThemeTable = CORRECT_ANSWERS[theme]
    if not correctThemeTable then
        warn(string.format("[SOLVER] Topic '%s' not found in database!", theme))
        BoredLibrary.prompt("Error", "Topic not in database!", 3)
        return
    end

    local correctAnswerText = correctThemeTable[questionText]
    local foundKnownQuestion = questionText
    local matchMethod = "EXACT"
    
    if not correctAnswerText then
        print("[SOLVER] Exact match not found, searching by keywords...")
        
        local bestMatch, bestAnswer, matchCount, matchPercent = findBestMatch(questionText, correctThemeTable)
        
        if bestMatch and bestAnswer then
            correctAnswerText = bestAnswer
            foundKnownQuestion = bestMatch
            matchMethod = string.format("KEYWORDS (%.0f%% match)", matchPercent)
            print(string.format("[SOLVER] Found match: %d keywords (%.0f%%)", matchCount, matchPercent))
        end
    end
    
    if not correctAnswerText then
        warn("[SOLVER] Question not found in database even by keywords!")
        print("[SOLVER] Normalized question: " .. normalizeText(questionText))
        BoredLibrary.prompt("Error", "Question not in database!", 3)
        return
    end

    print(string.format("[SOLVER] Search method: %s", matchMethod))
    print(string.format("[SOLVER] Found question in DB: %s", foundKnownQuestion:sub(1, 50) .. (string.len(foundKnownQuestion) > 50 and "..." or "")))
    print(string.format("[SOLVER] Correct answer: '%s'", correctAnswerText))
    print(string.rep("-", 60))

    if not answerContainer then 
        warn("[SOLVER] AnswerContainer not found!")
        BoredLibrary.prompt("Error", "Answer container not found!", 2)
        return 
    end

    -- Check if this is the Sudan flag question (special handling)
    local isSudanQuestion = isSudanFlagQuestion(questionText)
    if isSudanQuestion then
        print("[SOLVER] ⚠️ SPECIAL CASE: Sudan flag question detected - excluding 'South Sudan'")
    end

    -- ВАЖНО: Определяем и СОХРАНЯЕМ номер ответа ОДИН РАЗ
    -- Этот номер НЕ ИЗМЕНИТСЯ и будет использован для отправки
    local answerNumber = -1
    local correctButton = nil  -- Используется ТОЛЬКО для подсветки (украшение)
    local normalizedCorrectAnswer = normalizeText(correctAnswerText)
    
    print("[SOLVER] ANSWER OPTIONS:")
    
    -- Find correct answer button and SAVE the number ONCE
    for i = 1, 4 do
        local ansBtn = answerContainer:FindFirstChild("Answer" .. tostring(i))
        
        if ansBtn and (ansBtn:IsA("TextButton") or ansBtn:IsA("TextLabel")) then
            local buttonText = trim(ansBtn.Text)
            local normalizedButton = normalizeText(buttonText)
            
            -- SPECIAL RULE: Exclude "South Sudan" for Sudan flag question
            if isSudanQuestion and string.find(string.lower(buttonText), "south sudan") then
                print(string.format("[SOLVER]   Option %d: '%s' << EXCLUDED (South Sudan)", i, buttonText))
                -- Skip this option
                continue
            end
            
            local isMatch = false
            
            -- Method 1: Suffix match
            if string.len(buttonText) >= string.len(correctAnswerText) then
                if string.sub(buttonText, -string.len(correctAnswerText)) == correctAnswerText then
                    isMatch = true
                end
            end
            
            -- Method 2: Normalized comparison
            if not isMatch then
                if normalizedButton == normalizedCorrectAnswer then
                    isMatch = true
                elseif string.find(normalizedButton, normalizedCorrectAnswer, 1, true) then
                    isMatch = true
                end
            end
            
            -- Method 3: Direct find
            if not isMatch then
                if string.find(buttonText, correctAnswerText, 1, true) then
                    isMatch = true
                end
            end
            
            local marker = isMatch and " << MATCH" or ""
            print(string.format("[SOLVER]   Option %d: '%s'%s", i, buttonText, marker))
            
            -- СОХРАНЯЕМ НОМЕР ОДИН РАЗ - это и есть наш окончательный ответ
            if isMatch and answerNumber == -1 then
                answerNumber = i  -- SAVED ANSWER NUMBER (independent from UI)
                correctButton = ansBtn  -- Saved button reference (only for highlight decoration)
            end
            
            continue
        else
            warn(string.format("[SOLVER]   Option %d: NOT FOUND", i))
        end
    end
    
    print(string.rep("-", 60))

    -- Check if answer was found
    if answerNumber == -1 then
        warn("[SOLVER] Could not find button with correct answer text!")
        BoredLibrary.prompt("Error", "Button not found!", 3)
        print(string.rep("=", 60) .. "\n")
        return
    end

    -- HIGHLIGHT BUTTON (purely cosmetic, does NOT affect answerNumber)
    if correctButton then
        highlightButton(correctButton)
        print(string.format("[SOLVER] Highlighted Option %d with GREEN color (decoration only)!", answerNumber))
        BoredLibrary.prompt("Answer Found!", "Option " .. answerNumber .. " highlighted", 1.5)
    end

    -- WAIT before sending
    local delay = isInitial and INITIAL_DELAY or SOLVE_DELAY
    print(string.format("[SOLVER] Waiting %.2f seconds before sending answer...", delay))
    BoredLibrary.prompt("Waiting", string.format("Sending in %.2f sec...", delay), delay)
    task.wait(delay)

    -- SEND ANSWER using SAVED answer number (completely independent from highlight)
    if Event then
        print(string.rep("*", 60))
        print(string.format("[SOLVER] >>> SENDING SAVED OPTION: %d <<<", answerNumber))
        print(string.format("[SOLVER] >>> ANSWER: '%s' <<<", correctAnswerText))
        print(string.rep("*", 60))
        
        Event:FireServer(answerNumber)
        
        print("[SOLVER] RemoteEvent 'Exam' fired with argument: " .. answerNumber)
        BoredLibrary.prompt("Answer Sent!", "Option " .. answerNumber .. ": " .. correctAnswerText, 2)
    else
        warn("[SOLVER] ReplicatedStorage.Exam Event not found!")
        BoredLibrary.prompt("Error", "RemoteEvent not found!", 3)
    end
    print(string.rep("=", 60) .. "\n")
end

-- ====================================================================
--                           UI LISTENERS
-- ====================================================================

local function initListeners()
    print("[SOLVER] =============================================")
    print("[SOLVER] Exam Solver v6.6 Started!")
    print(string.format("[SOLVER] Answer delay: %.2f sec", SOLVE_DELAY))
    print(string.format("[SOLVER] Initial delay: %.2f sec", INITIAL_DELAY))
    print(string.format("[SOLVER] Initial timeout: %d sec", INITIAL_TIMEOUT))
    print("[SOLVER] =============================================")
    
    BoredLibrary.prompt("Exam Solver v6.6", "Script loaded successfully!", 3)
    
    local sheet = getUI()
    
    if not sheet then 
        warn("[SOLVER] UI not found immediately. Waiting...")
        BoredLibrary.prompt("Waiting", "Searching for Exam UI...", 2)
        local playerGui = LocalPlayer:WaitForChild("PlayerGui")
        local examUI = playerGui:WaitForChild("Exam")
        local canvasGroup = examUI:WaitForChild("CanvasGroup")
        sheet = canvasGroup:WaitForChild("ExamSheet")
        if not sheet then
            warn("[SOLVER] Could not find ExamSheet.")
            BoredLibrary.prompt("Error", "ExamSheet not found!", 3)
            return
        end
    end

    local textQ = sheet:FindFirstChild("TextOnly Question") or sheet:WaitForChild("TextOnly Question")
    local imageQ = sheet:FindFirstChild("Image Question") or sheet:WaitForChild("Image Question")
    
    print("[SOLVER] Question UI (Text/Image) found.")
    BoredLibrary.prompt("Ready", "Exam UI found!", 2)

    -- Initial question detection with timeout
    task.spawn(function()
        local startTime = tick()
        local questionFound = false
        
        print(string.format("[SOLVER] Waiting for initial question (max %d sec)...", INITIAL_TIMEOUT))
        BoredLibrary.prompt("Scanning", "Looking for initial question...", 2)
        
        while tick() - startTime < INITIAL_TIMEOUT and not questionFound do
            if textQ and textQ.GroupTransparency == 0 then
                questionFound = true
                local elapsed = tick() - startTime
                print(string.format("[SOLVER] Initial question found (TextOnly) after %.1f sec!", elapsed))
                BoredLibrary.prompt("Question Found!", string.format("Detected in %.1f sec", elapsed), 1.5)
                solveQuestion("TextOnly Question", true)
            elseif imageQ and imageQ.GroupTransparency == 0 then
                questionFound = true
                local elapsed = tick() - startTime
                print(string.format("[SOLVER] Initial question found (Image) after %.1f sec!", elapsed))
                BoredLibrary.prompt("Question Found!", string.format("Detected in %.1f sec", elapsed), 1.5)
                solveQuestion("Image Question", true)
            else
                task.wait(0.3)
            end
        end
        
        if not questionFound then
            print("[SOLVER] No initial question found within " .. INITIAL_TIMEOUT .. " seconds")
            BoredLibrary.prompt("Info", "No initial question detected", 2)
        end
    end)

    -- Listeners for TextOnly Question
    if textQ then
        textQ:GetPropertyChangedSignal("GroupTransparency"):Connect(function()
            if textQ.GroupTransparency == 0 then
                print("[SOLVER] New TextOnly question detected (GroupTransparency)")
                task.spawn(solveQuestion, "TextOnly Question", false)
            end
        end)

        local qContent = textQ:FindFirstChild("QuestionContent")
        if qContent then
            qContent:GetPropertyChangedSignal("Text"):Connect(function()
                if textQ.GroupTransparency == 0 then
                    print("[SOLVER] Question text changed (TextOnly)")
                    task.spawn(solveQuestion, "TextOnly Question", false)
                end
            end)
        end
    end

    -- Listeners for Image Question
    if imageQ then
        imageQ:GetPropertyChangedSignal("GroupTransparency"):Connect(function()
            if imageQ.GroupTransparency == 0 then
                print("[SOLVER] New Image question detected (GroupTransparency)")
                task.spawn(solveQuestion, "Image Question", false)
            end
        end)

        local qContent = imageQ:FindFirstChild("QuestionContent")
        if qContent then
            qContent:GetPropertyChangedSignal("Text"):Connect(function()
                if imageQ.GroupTransparency == 0 then
                    print("[SOLVER] Question text changed (Image)")
                    task.spawn(solveQuestion, "Image Question", false)
                end
            end)
        end
    end

    print("[SOLVER] =============================================")
    print("[SOLVER] All listeners activated!")
    print("[SOLVER] Waiting for exam questions...")
    print("[SOLVER] =============================================")
    BoredLibrary.prompt("Exam Solver", "All systems ready!", 2)
end

initListeners()
print('loaded')
