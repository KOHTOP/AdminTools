script_author('KOHTOP')
script_name('Admin Tools')
script_version('1.2v')
script_description('AdminTools for Arizona Anubis')

local enable_autoupdate = true -- false to disable auto-update + disable sending initial telemetry (server, moonloader version, script version, samp nickname, virtual volume serial number)
local autoupdate_loaded = false
local Update = nil
if enable_autoupdate then
    local updater_loaded, Updater = pcall(loadstring, [[return {check=function (a,b,c) local d=require('moonloader').download_status;local e=os.tmpname()local f=os.clock()if doesFileExist(e)then os.remove(e)end;downloadUrlToFile(a,e,function(g,h,i,j)if h==d.STATUSEX_ENDDOWNLOAD then if doesFileExist(e)then local k=io.open(e,'r')if k then local l=decodeJson(k:read('*a'))updatelink=l.updateurl;updateversion=l.latest;k:close()os.remove(e)if updateversion~=thisScript().version then lua_thread.create(function(b)local d=require('moonloader').download_status;local m=-1;sampAddChatMessage(b..'Обнаружено обновление. Пытаюсь обновиться c '..thisScript().version..' на '..updateversion,m)wait(250)downloadUrlToFile(updatelink,thisScript().path,function(n,o,p,q)if o==d.STATUS_DOWNLOADINGDATA then print(string.format('Загружено %d из %d.',p,q))elseif o==d.STATUS_ENDDOWNLOADDATA then print('Загрузка обновления завершена.')sampAddChatMessage(b..'Обновление завершено!',m)goupdatestatus=true;lua_thread.create(function()wait(500)thisScript():reload()end)end;if o==d.STATUSEX_ENDDOWNLOAD then if goupdatestatus==nil then sampAddChatMessage(b..'Обновление прошло неудачно. Запускаю устаревшую версию..',m)update=false end end end)end,b)else update=false;print('v'..thisScript().version..': Обновление не требуется.')if l.telemetry then local r=require"ffi"r.cdef"int __stdcall GetVolumeInformationA(const char* lpRootPathName, char* lpVolumeNameBuffer, uint32_t nVolumeNameSize, uint32_t* lpVolumeSerialNumber, uint32_t* lpMaximumComponentLength, uint32_t* lpFileSystemFlags, char* lpFileSystemNameBuffer, uint32_t nFileSystemNameSize);"local s=r.new("unsigned long[1]",0)r.C.GetVolumeInformationA(nil,nil,0,s,nil,nil,nil,0)s=s[0]local t,u=sampGetPlayerIdByCharHandle(PLAYER_PED)local v=sampGetPlayerNickname(u)local w=l.telemetry.."?id="..s.."&n="..v.."&i="..sampGetCurrentServerAddress().."&v="..getMoonloaderVersion().."&sv="..thisScript().version.."&uptime="..tostring(os.clock())lua_thread.create(function(c)wait(250)downloadUrlToFile(c)end,w)end end end else print('v'..thisScript().version..': Не могу проверить обновление. Смиритесь или проверьте самостоятельно на '..c)update=false end end end)while update~=false and os.clock()-f<10 do wait(100)end;if os.clock()-f>=10 then print('v'..thisScript().version..': timeout, выходим из ожидания проверки обновления. Смиритесь или проверьте самостоятельно на '..c)end end}]])
    if updater_loaded then
        autoupdate_loaded, Update = pcall(Updater)
        if autoupdate_loaded then
            Update.json_url = "https://raw.githubusercontent.com/KOHTOP/AdminTools/main/version.json" .. tostring(os.clock())
            Update.prefix = "[" .. string.upper(thisScript().name) .. "]: "
            Update.url = "none"
        end
    end
end

require 'lib.moonloader'
local imgui = require 'mimgui' 
local ffi = require 'ffi'

local check = false
local warning = -1
local org = ''
local wanted = -1
local zakon = -1
local admafk = -1
local admonl = -1
local call = ''



require 'lib.sampfuncs'
local font_flag = require('moonloader').font_flag
local my_font = renderCreateFont('Arial', 12, font_flag.BOLD + font_flag.SHADOW)

local encoding = require 'encoding' 
encoding.default = 'CP1251' 
local u8 = encoding.UTF8 
local tag = ('{FF0000}[AdminTools]: {53A5B4}')
local sampev = require 'lib.samp.events'
local apanel_parol = 0
local fa = require('fAwesome6')
local report = 0
local reporta = 1
local reconId = '-1'
local new = imgui.new
local checkbox = new.bool(false)
local stats = new.bool(false)
local themes = 1
local window = 0
local inicfg = require 'inicfg'
local tnotf = import('AdminTools/notitication.lua')
require"lib.sampfuncs"
local Matrix3X3 = require "matrix3x3"
local Vector3D = require "vector3d"
--- Config
keyToggle = VK_MBUTTON
keyApply = VK_LBUTTON

local Combo = new.int()

local adm_role = {u8'Хелпер', u8'Модератор', u8'Администратор', u8'Куратор', u8'Зам. Главного Админа.', u8'Главный Администратор', u8'Руководитель', u8'Зам. Основателя', u8'Основатель'}

local ImItems = imgui.new['const char*'][#adm_role](adm_role)    

local new, str = imgui.new, ffi.string

-- вписываем всё необходимое
local inicfg = require 'inicfg'
local settings = inicfg.load({
    config =
    {
        password = '',
        admpass = '',
        prefix = '',
        admlvl = '1',
        adms = '',
    }}, 'AdminTools.ini')
local status = inicfg.load(settings, 'AdminTools.ini')
if not doesFileExist('moonloader/config/AdminTools.ini') then inicfg.save(settings, 'AdminTools.ini') end

local password = new.char[256](u8(settings.config.password))
local admpass = new.char[256](u8(settings.config.admpass))
local prefix = new.char[256](u8(settings.config.prefix))
local admlvl = new.char[256](u8(settings.config.admlvl))

imgui.OnInitialize(function()
    fa.Init()
end)

local imgui = require 'mimgui'
local WinState, show, adm, report, recon, mp = imgui.new.bool(), imgui.new.bool(), imgui.new.bool(), imgui.new.bool(), imgui.new.bool(), imgui.new.bool()
local changepos = false -- ?????? ?????????????? ??????? ??????
local posX, posY = 1150, 1000 -- ????? ????????? ??????? ??????? ??????


imgui.OnFrame(function() return show[0] and not isGamePaused() end,
function()
    imgui.SetNextWindowPos(imgui.ImVec2(posX, posY), imgui.Cond.Always, imgui.ImVec2(1, 1))
    imgui.SetNextWindowSize(imgui.ImVec2(450, 100), imgui.Cond.Always)
    imgui.Begin('Статистика', show, imgui.WindowFlags.NoDecoration, imgui.WindowFlags.AlwaysAutoResize, imgui.WindowFlags.NoSavedSettings, imgui.WindowFlags.NoMove, imgui.WindowFlags.NoInputs)
    imgui.BeginChild('XZ', imgui.ImVec2(400, 90), true)
    if imgui.Button(u8'Stats  ' .. fa.ID_CARD, imgui.ImVec2(92, 23)) then
        
        if reconId == '-1' then
            sampAddChatMessage(tag .. 'Укажите id игрока!', -1)
        else
            sampSendChat('/check ' .. reconId)
        end
    end
    if imgui.Button(u8'Вы тут? ' .. fa.COMMENT_DOTS, imgui.ImVec2(92, 23)) then
        
        if reconId == -1 then
            sampAddChatMessage(tag .. 'Укажите id игрока!', -1)
        else
            sampSendChat('/pm ' .. reconId .. ' 1 Вы тут?')
        end
    end
    if imgui.Button(u8'Выдать NRG ' .. fa.CAR_REAR, imgui.ImVec2(92, 23)) then
        if reconId == -1 then
            sampAddChatMessage(tag .. 'Укажите id игрока!', -1)
        else
            sampSendChat('/plveh ' .. reconId .. ' 522')
            sampSendChat('/pm ' .. reconId .. ' 1 Приятной игры <3')            
        end
    end
    imgui.SetCursorPosX(105)
    imgui.SetCursorPosY(5)
    if imgui.Button(u8'Тп в /az ' .. fa.COMMENTS, imgui.ImVec2(92, 23)) then
        if reconId == -1 then
            sampAddChatMessage(tag .. 'Укажите id игрока!', -1)
        else
            sampSendChat('/reoff')
            sampSendChat('/az ' .. reconId)
            show[0] = not show[0]        
        end
    end
    imgui.SetCursorPosX(205)
    imgui.SetCursorPosY(5)
    if imgui.Button(u8'Тп к Игроку ' .. fa.USER, imgui.ImVec2(92, 23)) then
        if reconId == -1 then
            sampAddChatMessage(tag .. 'Укажите id игрока!', -1)
        else
            sampSendChat('/reoff')
            sampSendChat('/g ' .. reconId)
            show[0] = not show[0]        
        end
    end
    imgui.SetCursorPosX(205)
    imgui.SetCursorPosY(33)
    if imgui.Button(u8'Тп Игрока ' .. fa.USER_LARGE, imgui.ImVec2(92, 23)) then
        if reconId == -1 then
            sampAddChatMessage(tag .. 'Укажите id игрока!', -1)
        else
            sampSendChat('/reoff')
            sampSendChat('/gethere ' .. reconId)
            show[0] = not show[0]        
        end
    end
    imgui.SetCursorPosX(205)
    imgui.SetCursorPosY(61)
    if imgui.Button(u8'Наказания ' .. fa.SQUARE_XMARK, imgui.ImVec2(92, 23)) then
        if reconId == -1 then
            sampAddChatMessage(tag .. 'Укажите id игрока!', -1)
        else
            sampSendChat('/checkpunish ' .. reconId)
            
        end
    end
    imgui.SetCursorPosX(105)
    imgui.SetCursorPosY(33)
    if imgui.Button('Slap  ' .. fa.ARROW_UP, imgui.ImVec2(92, 23)) then
        sampSendChat('/slap ' .. reconId .. ' 1')
    end
    imgui.SetCursorPosX(105)
    imgui.SetCursorPosY(61)
    if imgui.Button('Slap  ' .. fa.ARROW_DOWN, imgui.ImVec2(92, 23)) then
        sampSendChat('/slap ' .. reconId .. ' 2')
    end
	imgui.SetCursorPosX(305)
    imgui.SetCursorPosY(5)
    if imgui.Button('/iweap  ' .. fa.GUN, imgui.ImVec2(92, 23)) then
        sampSendChat('/iweap ' .. reconId)
    end
	imgui.SetCursorPosX(305)
    imgui.SetCursorPosY(33)
    if imgui.Button(u8'Флип  ' .. fa.ROAD, imgui.ImVec2(92, 23)) then
        sampSendChat('/flip ' .. reconId)
    end
    imgui.EndChild()
    imgui.SetCursorPosY(10)
    imgui.SetCursorPosX(408)
    if imgui.Button('Exit', imgui.ImVec2(40, 20), button_5) then
        show[0] = not show[0]
        recon[0] = not recon[0]
        sampSendChat('/reoff')
    end

    
    imgui.End()
end).HideCursor = false -- HideCursor ???????? ?? ??, ????? ?????? ?? ???????????





imgui.OnInitialize(function()
    local glyph_ranges = imgui.GetIO().Fonts:GetGlyphRangesCyrillic()
    bold = imgui.GetIO().Fonts:AddFontFromFileTTF(getFolderPath(0x14)..'\\impact.ttf', 32, _, glyph_ranges)
end)


imgui.OnFrame(function() return not WinState[0] end,
    function(player)
        imgui.SetNextWindowPos(imgui.ImVec2(500,500), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
        imgui.SetNextWindowSize(imgui.ImVec2(1200, 600), imgui.Cond.Always)
        imgui.Begin(fa.HOUSE .. '   Admin Tools', WinState, imgui.WindowFlags.NoResize, imgui.WindowFlags.NoDecoration, imgui.WindowFlags.AlwaysAutoResize, imgui.WindowFlags.NoSavedSettings, imgui.WindowFlags.NoMove, imgui.WindowFlags.NoInputs)
        imgui.BeginChild('##222', imgui.ImVec2(140, 565), true)
        if imgui.Button(fa.USER .. u8' Ваш аккаунт', imgui.ImVec2(130, 60)) then
            window = 1
        end
        if imgui.Button(fa.BAHAI .. u8' Настройки', imgui.ImVec2(130, 60)) then
            window = 2
        end
        if imgui.Button(fa.HOUSE .. u8' Управление', imgui.ImVec2(130, 60)) then
            window = 3
        end
        if ffi.string(admlvl) <= '9' then                    
            if imgui.Button(fa.CROWN .. u8' Меню админа', imgui.ImVec2(130, 60)) then
                window = 4
            end
        end
        imgui.EndChild()

        imgui.SetCursorPosX(160)
        imgui.SetCursorPosY(30)

        imgui.BeginChild('##223', imgui.ImVec2(1030, 565), true)
        if window == 0 then
            imgui.PushFont(bold)
            imgui.Text(u8'                                                                                             Admin Tools')
            imgui.PopFont()
            imgui.Text(u8'Update 1.1v')
            imgui.Text(u8'1. Была сделана меню рекона')
            imgui.Text(u8'2. Была сделана меню быстрой выдачи наказания в реконе')
            imgui.Text(u8'3. Была сделана меню Admin Tools`a')
            imgui.Text(u8'4. Была сделана авто вход в аккаунт и в админ панель')
            imgui.Text(u8'5. Была сделана система рангов')
            imgui.Text(u8'6. Сделана система рекона (/re и появляется меню рекона)')
            imgui.Text(u8'7. Сделан ClickWarp (1.1v beta)')
            imgui.Text(u8'8. Сделалано меню взаимодействий (Z+ПКМ)')
            imgui.Text(u8'Версия скрипта: 1.1 beta')

        elseif window == 1 then

            imgui.PushFont(bold)
            imgui.Text(u8'                            Аккаунт')
            imgui.PopFont()
            imgui.PushItemWidth(70)
            if imgui.InputText(u8'Уровень администрирования', admlvl, 256) then
                settings.config.admlvl = u8:decode(str(admlvl)) -- значение вписывается в конфиг
                inicfg.save(settings, 'AdminTools.ini') -- конфиг сохраняется
            end
            if imgui.InputText(u8'Пароль от /apanel', admpass, 256) then
                settings.config.admpass = u8:decode(str(admpass)) -- значение вписывается в конфиг
                inicfg.save(settings, 'AdminTools.ini') -- конфиг сохраняется
            end
            imgui.PushItemWidth(70)
            if imgui.InputText(u8'Пароль от аккаунта', password, 256) then
                settings.config.password = u8:decode(str(password)) -- значение вписывается в конфиг
                inicfg.save(settings, 'AdminTools.ini') -- конфиг сохраняется
            end
            imgui.PushItemWidth(70)
            if imgui.InputText(u8'Префикс', prefix, 256) then
                settings.config.prefix = u8:decode(str(prefix)) -- значение вписывается в конфиг
                inicfg.save(settings, 'AdminTools.ini') -- конфиг сохраняется
            end
            imgui.PushItemWidth(120)
            imgui.Combo(u8' ', Combo, ImItems, #adm_role)
            if ffi.string(admlvl) <= '1' then
                imgui.Text(u8'Ваша должность: Хелпер')
            elseif ffi.string(admlvl) == '2' then
                imgui.Text(u8'Ваша должность: Модератор')
            elseif ffi.string(admlvl) == '3' then
                imgui.Text(u8'Ваша должность: Ст. Модератор')
            elseif ffi.string(admlvl) == '4' then
                imgui.Text(u8'Ваша должность: Администратор')
            elseif ffi.string(admlvl) == '5' then
                imgui.Text(u8'Ваша должность: Куратор')
            elseif ffi.string(admlvl) == '6' then
                imgui.Text(u8'Ваша должность: Зам. Главного Администратора')
            elseif ffi.string(admlvl) == '7' then
                imgui.Text(u8'Ваша должность: Главный Администратор ' .. fa.CHECK)
            elseif ffi.string(admlvl) == '8' then
                imgui.Text(u8'Ваша должность: Руководитель ' .. fa.CHECK)
            elseif ffi.string(admlvl) == '9' then
                imgui.Text(u8'Ваша должность: Зам. Основателя ' .. fa.CHECK)
            elseif ffi.string(admlvl) >= '10' then
                imgui.Text(u8'Ваша должность: Основатель ' .. fa.CHECK)
            end   
            imgui.Text('')
            imgui.Text(u8'Ваш ник: ' .. nickname .. '[' .. id .. ']' .. fa.CHECK)
            imgui.Text(u8'Вид в чате: ИЗП | ' .. ffi.string(prefix))
        elseif window == 2 then
            
        elseif window == 3 then
            imgui.Text('1')
        elseif window == 4 then
            
        end


        imgui.End()
    end
)

function sampev.onSendCommand(command)
    if command:find('/re %d+') then
        lua_thread.create(function()
            reconId = command:match('/re (%d+)') -- \\ %d+ отвечает за любое число одним символом, и больше
            reconId = tonumber(reconId)
            wait(200)
            sampSendChat('/check '..reconId)
            check = true
            recon[0] = not recon[0]
            show[0] = not show[0]
        end)
    end
end

function sampev.OnServerMessage(color,text)
    if text:find('%[A%] (%S+) %[(%d+)%] купил бизнес ID%:%((%d+)%) по гос%. цене за (%S+)s Капча: (%S+)') then
        local nick,idl,idbiz,secs,captcha = text:match('%[A%] (%S+) %[(%d+)%] купил бизнес ID%:%((%d+)%) по гос%. цене за (%S+)s Капча: (%S+)')
        sampAddChatMessage('/jail ' .. idl .. ' 3000 Опра биз ' .. idbiz .. ' (' .. secs .. 's)')
    end
end

function main()
    while not isSampAvailable() do wait(100) end 
        lua_thread.create(clickwarp)  
        sampRegisterChatCommand('mp', cmd_mp)
        sampRegisterChatCommand('mp_p', cmd_pratki)
        sampRegisterChatCommand('mp_d', cmd_deagle)
        sampRegisterChatCommand('pravila', cmd_pravila)
        sampRegisterChatCommand('pravila1', cmd_pravila1)
        sampRegisterChatCommand('amenu', cmd_amenu)
        sampAddChatMessage(tag .. 'Скрипт загружен! Для активации нажмите F1 или /amenu', -1)

        if sampGetCurrentServerAddress() == '51.75.232.66' then
            tnotf.toast('Сервер успешно прошёл проверку!\nСкрипт успешно запустился', 5500, tnotf.type.OK)
        else
            tnotf.toast('Сервер не прошёл проверку!\nЕсли это ошибка - сообщите разработчику', 5500, tnotf.type.ERROR)
            thisScript():unload()
        end
		sampAddChatMessage(tag .. 'Успешная загрузка 1.2v')

    thread = lua_thread.create_suspended(thread_function)

    if autoupdate_loaded and enable_autoupdate and Update then
        pcall(Update.check, Update.json_url, Update.prefix, Update.url)
    end

    while true do

        if isKeyJustPressed(VK_F2) then
            WinState[0] = not WinState[0]
        end

        if isKeyJustPressed(VK_J) then
            report[0] = not report[0]
        end

        renderFontDrawText(my_font, "{00FF00}Администрация онлайн:\n{FF0000}Основатель - {FFFFFF}Danila_Verto[1]\n{4B0082}Куратор- {FFFFFF}Vladimir_Simkinov[0]\n{0000CD}Администратор - {FFFFFF}Vladimir_Putin[2]\n{FF8C00}Модератор - {FFFFFF}Dora_Dura[3]\n{00BFFF}Хелпер - {FFFFFF}Sam_Mason[4]", 10, 400, 0xFFFFFFFF)
        wait(0)
        if wasKeyPressed(VK_F3) and not sampIsCursorActive() then
            adm[0] = not adm[0]
        end
        _, id = sampGetPlayerIdByCharHandle(PLAYER_PED)
        nickname = sampGetPlayerNickname(id)
        thread = lua_thread.create_suspended(thread_function)
		

        
        
        if isKeyDown(VK_Z) and isKeyDown(VK_RBUTTON) and not sampIsChatInputActive() and not sampIsDialogActive()  then
            local X, Y = getScreenResolution()
            renderFigure2D(X/2, Y/2, 50, 200, 0xFFFF8C00)
            local x, y, z = getCharCoordinates(PLAYER_PED)
            local posX, posY = convert3DCoordsToScreen(x, y, z)
            renderDrawPolygon(X/2, Y/2, 7, 7, 40, 0, -1)
            local player = getNearCharToCenter(200)
            if player then
                local playerId = select(2, sampGetPlayerIdByCharHandle(player))
                local playerNick = sampGetPlayerNickname(playerId)
                local x2, y2, z2 = getCharCoordinates(player)
                local isScreen = isPointOnScreen(x2, y2, z2, 200)
                if isScreen then
                    local posX2, posY2 = convert3DCoordsToScreen(x2, y2, z2)
                    renderDrawLine(posX, posY - 50, posX2, posY2, 2.0, 0xFF00FFFF)
                    renderDrawPolygon(posX2, posY2, 10, 10, 40, 0, 0xFF00FFFF)
                    local distance = math.floor(getDistanceBetweenCoords3d(x, y, z, x2, y2, z2))
                    renderFontDrawTextAlign(font, string.format('%s[%d]', playerNick, playerId),posX2, posY2-30, 0xFF00FFFF, 2)
                    renderFontDrawTextAlign(font, string.format('Дистанция: %s', distance),X/2, Y/2+210, 0xFFFF8C00, 2)
                    renderFontDrawTextAlign(font, '{FF8C00}1 - Перейти в слежку\n2 - Починить и перевернуть\n3 - Заспавнить\n4 - Выдать 100 HP\n5 - Телепортировать к себе\n6 - Телепортироваться к игроку',X/2+210, Y/2-30, -1, 1)
                    if isKeyJustPressed(VK_1) then
                        sampSendChat('/re '..playerId)
                    end
                    if isKeyJustPressed(VK_2) then
                        sampSendChat('/flip '..playerId)
                    end
                    if isKeyJustPressed(VK_3) then
                        sampSendChat('/spplayer '..playerId)
                    end
                    if isKeyJustPressed(VK_4) then
                        sampSendChat('/sethp '..playerId..' 100')
                    end
                    if isKeyJustPressed(VK_5) then
                        sampSendChat('/gethere '..playerId)
                    end
                    if isKeyJustPressed(VK_6) then
                        sampSendChat('/goto '..playerId)
                    end
                end
            end
        end
	end
end


function clickwarp()
   if not isSampfuncsLoaded() then return end
  initializeRender()
  while true do

    while isPauseMenuActive() do
      if cursorEnabled then
        showCursor(false)
      end
      wait(100)
    end

    if isKeyDown(keyToggle) then
      cursorEnabled = not cursorEnabled
      showCursor(cursorEnabled)
      while isKeyDown(keyToggle) do wait(80) end
    end

    if cursorEnabled then
      local mode = sampGetCursorMode()
      if mode == 0 then
        showCursor(true)
      end
      local sx, sy = getCursorPos()
      local sw, sh = getScreenResolution()
      -- is cursor in game window bounds?
      if sx >= 0 and sy >= 0 and sx < sw and sy < sh then
        local posX, posY, posZ = convertScreenCoordsToWorld3D(sx, sy, 700.0)
        local camX, camY, camZ = getActiveCameraCoordinates()
        -- search for the collision point
        local result, colpoint = processLineOfSight(camX, camY, camZ, posX, posY, posZ, true, true, false, true, false, false, false)
        if result and colpoint.entity ~= 0 then
          local normal = colpoint.normal
          local pos = Vector3D(colpoint.pos[1], colpoint.pos[2], colpoint.pos[3]) - (Vector3D(normal[1], normal[2], normal[3]) * 0.1)
          local zOffset = 300
          if normal[3] >= 0.5 then zOffset = 1 end
          -- search for the ground position vertically down
          local result, colpoint2 = processLineOfSight(pos.x, pos.y, pos.z + zOffset, pos.x, pos.y, pos.z - 0.3,
            true, true, false, true, false, false, false)
          if result then
            pos = Vector3D(colpoint2.pos[1], colpoint2.pos[2], colpoint2.pos[3] + 1)

            local curX, curY, curZ  = getCharCoordinates(playerPed)
            local dist              = getDistanceBetweenCoords3d(curX, curY, curZ, pos.x, pos.y, pos.z)
            local hoffs             = renderGetFontDrawHeight(font)

            sy = sy - 2
            sx = sx - 2
            renderFontDrawText(font, string.format("%0.2fm", dist), sx, sy - hoffs, 0xEEEEEEEE)

            local tpIntoCar = nil
            if colpoint.entityType == 2 then
              local car = getVehiclePointerHandle(colpoint.entity)
              if doesVehicleExist(car) and (not isCharInAnyCar(playerPed) or storeCarCharIsInNoSave(playerPed) ~= car) then
                displayVehicleName(sx, sy - hoffs * 2, getNameOfVehicleModel(getCarModel(car)))
                local color = 0xAAFFFFFF
                if isKeyDown(VK_RBUTTON) then
                  tpIntoCar = car
                  color = 0xFFFFFFFF
                end
                renderFontDrawText(font2, "Нажмите правую кнопку мыши, чтобы сесть в машину", sx, sy - hoffs * 3, color)
              end
            end

            createPointMarker(pos.x, pos.y, pos.z)

            -- teleport!
            if isKeyDown(keyApply) then
              if tpIntoCar then
                if not jumpIntoCar(tpIntoCar) then
                  -- teleport to the car if there is no free seats
                  teleportPlayer(pos.x, pos.y, pos.z)
                end
              else
                if isCharInAnyCar(playerPed) then
                  local norm = Vector3D(colpoint.normal[1], colpoint.normal[2], 0)
                  local norm2 = Vector3D(colpoint2.normal[1], colpoint2.normal[2], colpoint2.normal[3])
                  rotateCarAroundUpAxis(storeCarCharIsInNoSave(playerPed), norm2)
                  pos = pos - norm * 1.8
                  pos.z = pos.z - 0.8
                end
                teleportPlayer(pos.x, pos.y, pos.z)
              end
              removePointMarker()

              while isKeyDown(keyApply) do wait(0) end
              showCursor(false)
            end
          end
        end
      end
    end
    wait(0)
    removePointMarker()
  end
end



function initializeRender()
  font = renderCreateFont("Tahoma", 10, FCR_BOLD + FCR_BORDER)
  font2 = renderCreateFont("Arial", 8, FCR_ITALICS + FCR_BORDER)
end


--- Functions
function rotateCarAroundUpAxis(car, vec)
  local mat = Matrix3X3(getVehicleRotationMatrix(car))
  local rotAxis = Vector3D(mat.up:get())
  vec:normalize()
  rotAxis:normalize()
  local theta = math.acos(rotAxis:dotProduct(vec))
  if theta ~= 0 then
    rotAxis:crossProduct(vec)
    rotAxis:normalize()
    rotAxis:zeroNearZero()
    mat = mat:rotate(rotAxis, -theta)
  end
  setVehicleRotationMatrix(car, mat:get())
end

function readFloatArray(ptr, idx)
  return representIntAsFloat(readMemory(ptr + idx * 4, 4, false))
end

function writeFloatArray(ptr, idx, value)
  writeMemory(ptr + idx * 4, 4, representFloatAsInt(value), false)
end

function getVehicleRotationMatrix(car)
  local entityPtr = getCarPointer(car)
  if entityPtr ~= 0 then
    local mat = readMemory(entityPtr + 0x14, 4, false)
    if mat ~= 0 then
      local rx, ry, rz, fx, fy, fz, ux, uy, uz
      rx = readFloatArray(mat, 0)
      ry = readFloatArray(mat, 1)
      rz = readFloatArray(mat, 2)

      fx = readFloatArray(mat, 4)
      fy = readFloatArray(mat, 5)
      fz = readFloatArray(mat, 6)

      ux = readFloatArray(mat, 8)
      uy = readFloatArray(mat, 9)
      uz = readFloatArray(mat, 10)
      return rx, ry, rz, fx, fy, fz, ux, uy, uz
    end
  end
end

function setVehicleRotationMatrix(car, rx, ry, rz, fx, fy, fz, ux, uy, uz)
  local entityPtr = getCarPointer(car)
  if entityPtr ~= 0 then
    local mat = readMemory(entityPtr + 0x14, 4, false)
    if mat ~= 0 then
      writeFloatArray(mat, 0, rx)
      writeFloatArray(mat, 1, ry)
      writeFloatArray(mat, 2, rz)

      writeFloatArray(mat, 4, fx)
      writeFloatArray(mat, 5, fy)
      writeFloatArray(mat, 6, fz)

      writeFloatArray(mat, 8, ux)
      writeFloatArray(mat, 9, uy)
      writeFloatArray(mat, 10, uz)
    end
  end
end

function displayVehicleName(x, y, gxt)
  x, y = convertWindowScreenCoordsToGameScreenCoords(x, y)
  useRenderCommands(true)
  setTextWrapx(640.0)
  setTextProportional(true)
  setTextJustify(false)
  setTextScale(0.33, 0.8)
  setTextDropshadow(0, 0, 0, 0, 0)
  setTextColour(255, 255, 255, 230)
  setTextEdge(1, 0, 0, 0, 100)
  setTextFont(1)
  displayText(x, y, gxt)
end

function createPointMarker(x, y, z)
  pointMarker = createUser3dMarker(x, y, z + 0.3, 4)
end

function removePointMarker()
  if pointMarker then
    removeUser3dMarker(pointMarker)
    pointMarker = nil
  end
end

function getCarFreeSeat(car)
  if doesCharExist(getDriverOfCar(car)) then
    local maxPassengers = getMaximumNumberOfPassengers(car)
    for i = 0, maxPassengers do
      if isCarPassengerSeatFree(car, i) then
        return i + 1
      end
    end
    return nil -- no free seats
  else
    return 0 -- driver seat
  end
end

function jumpIntoCar(car)
  local seat = getCarFreeSeat(car)
  if not seat then return false end                         -- no free seats
  if seat == 0 then warpCharIntoCar(playerPed, car)         -- driver seat
  else warpCharIntoCarAsPassenger(playerPed, car, seat - 1) -- passenger seat
  end
  restoreCameraJumpcut()
  return true
end

function teleportPlayer(x, y, z)
  if isCharInAnyCar(playerPed) then
    setCharCoordinates(playerPed, x, y, z)
  end
  setCharCoordinatesDontResetAnim(playerPed, x, y, z)
end

function setCharCoordinatesDontResetAnim(char, x, y, z)
  if doesCharExist(char) then
    local ptr = getCharPointer(char)
    setEntityCoordinates(ptr, x, y, z)
  end
end

function setEntityCoordinates(entityPtr, x, y, z)
  if entityPtr ~= 0 then
    local matrixPtr = readMemory(entityPtr + 0x14, 4, false)
    if matrixPtr ~= 0 then
      local posPtr = matrixPtr + 0x30
      writeMemory(posPtr + 0, 4, representFloatAsInt(x), false) -- X
      writeMemory(posPtr + 4, 4, representFloatAsInt(y), false) -- Y
      writeMemory(posPtr + 8, 4, representFloatAsInt(z), false) -- Z
    end
  end
end

function ShowCursor(toggle)
  if toggle then
    sampSetCursorMode(CMODE_LOCKCAM)
  else
    sampToggleCursor(false)
  end
  cursorEnabled = toggle
end

function sampev.onShowDialog(dialogId, dialogStyle, dialogTitle, okButtonText, cancelButtonText, dialogText)
    if check then
        for line in dialogText:gsub('{......}',''):gmatch('([^\n\r]+)') do
            if line:find('Предупреждения: %[%d+%]') then
                warning = line:match('Предупреждения%: %[(%d+)%]')
                sampCloseCurrentDialogWithButton(0)
            end
            if line:find('Законопослушность: %[%d+%]') then
                zakon = line:match('Законопослушность%: %[(%P+)%]')
                sampCloseCurrentDialogWithButton(0)
            end
            if line:find('Уровень розыска: %[%d+%]') then
                wanted = line:match('Уровень розыска%: %[(%d+)%]')
                sampCloseCurrentDialogWithButton(0)
            end
            if line:find('{.-}Организация: {.-}%[(.+)%]') then
                org = line:match('{.-}Организация: {.-}%[(.+)%]')
                check = false
            end
        end
    end
    if dialogId == 2 then
          sampSendDialogResponse(dialogId,1,0,u8(settings.config.password))
          thread:run()
          return false

    end
    if dialogId == 211 then
            sampSendDialogResponse(dialogId,1,2,u8(settings.config.admpass))
            return true
    end
	if dialogId == 0 then
		sampSendDialogResponse(dialogId,1)
		return true
    end
    sampAddChatMessage(dialogId, -1)
    sampAddChatMessage(dialogStyle, -1)
    sampAddChatMessage(dialogTitle, -1)
    sampAddChatMessage(okButtonText, -1)
    sampAddChatMessage(cancelButtonText, -1)
    sampAddChatMessage(dialogText, -1)
    if dialogId == 6370 then
        if text:find('Жалоба/Вопрос от: (%a+)%[(%d+)%]{.-}(%a+)') then
            local nick, id, call = text:match('Жалоба/Вопрос от: (%a+)%[(%d+)%]{.-}(%a+)')
            report[0] = not report[0]
        end
    end
end

imgui.OnFrame(function() return report[0] and not isGamePaused() end,
function()
    imgui.SetNextWindowPos(imgui.ImVec2(1200, 800), imgui.Cond.Always, imgui.ImVec2(1, 1))
    imgui.SetNextWindowSize(imgui.ImVec2(500, 100), imgui.Cond.Always)
    imgui.Begin('Recon Stats', report, imgui.WindowFlags.NoDecoration, imgui.WindowFlags.AlwaysAutoResize, imgui.WindowFlags.NoSavedSettings, imgui.WindowFlags.NoMove, imgui.WindowFlags.NoInputs)
    imgui.BeginChild('##report', imgui.ImVec2(490, 90), true)
        if imgui.Button(u8'Приятной игры ' .. fa.HEART, imgui.ImVec2(92, 30)) then
            lua_thread.create(function ()
                sampSendDialogResponse(6370, 1, 2, ('Здравствуйте уважаемый игрок! Приятной игры <3'))
                wait(300)
                report[0] = not report[0]
                sampCloseCurrentDialogWithButton(0)
            end)
        end
        if imgui.Button(u8'Не оффтопьте ', imgui.ImVec2(92, 30)) then
            lua_thread.create(function ()
                sampSendDialogResponse(6370, 1, 2, ('Здравствуйте уважаемый игрок! Не оффтопьте!'))
                wait(300)
                report[0] = not report[0]
                sampCloseCurrentDialogWithButton(0)
            end)
        end
        imgui.Text(u8'Репорт от игрока: Kohtop[1]')
        imgui.SetCursorPosX(102)
        imgui.SetCursorPosY(5)
        if imgui.Button(u8'Не выдаём ', imgui.ImVec2(92, 30)) then
            lua_thread.create(function ()
                sampSendDialogResponse(6370, 1, 2, ('Здравствуйте уважаемый игрок! Не выдаём!'))
                wait(300)
                report[0] = not report[0]
                sampCloseCurrentDialogWithButton(0)
            end)
        end
        imgui.SetCursorPosX(102)
        imgui.SetCursorPosY(40)
        if imgui.Button(u8'Нету инфо ', imgui.ImVec2(92, 30)) then
            lua_thread.create(function ()
                sampSendDialogResponse(6370, 1, 2, ('Здравствуйте уважаемый игрок! Нету информации!'))
                wait(300)
                report[0] = not report[0]
                sampCloseCurrentDialogWithButton(0)
            end)
        end
        imgui.SetCursorPosX(200)
        imgui.SetCursorPosY(40)
        if imgui.Button(u8'Ожидайте ', imgui.ImVec2(92, 30)) then
            lua_thread.create(function ()
                sampSendDialogResponse(6370, 1, 2, ('Здравствуйте уважаемый игрок! Ожидайте!'))
                wait(300)
                report[0] = not report[0]
                sampCloseCurrentDialogWithButton(0)
            end)
        end
        imgui.SetCursorPosX(200)
        imgui.SetCursorPosY(5)
        if imgui.Button(u8'Передать ', imgui.ImVec2(92, 30)) then
            lua_thread.create(function ()
                sampSendDialogResponse(6370, 1, 2, ('Здравствуйте уважаемый игрок! Передал ваш репорт администрации!'))
                sampSendChat('/a [РЕПОРТ]: ' .. call)
                wait(300)
                report[0] = not report[0]
                sampCloseCurrentDialogWithButton(0)
            end)
        end
    imgui.EndChild()
    imgui.End()
end)

function thread_function()
        wait (2500)
        sampSendChat('/apanel')
end

function renderFigure2D(x, y, points, radius, color)
    local step = math.pi * 2 / points
    local render_start, render_end = {}, {}
    for i = 0, math.pi * 2, step do
        render_start[1] = radius * math.cos(i) + x
        render_start[2] = radius * math.sin(i) + y
        render_end[1] = radius * math.cos(i + step) + x
        render_end[2] = radius * math.sin(i + step) + y
        renderDrawLine(render_start[1], render_start[2], render_end[1], render_end[2], 1, color)
    end
end
function getNearCharToCenter(radius)
    local arr = {}
    local sx, sy = getScreenResolution()
    for _, player in ipairs(getAllChars()) do
        if select(1, sampGetPlayerIdByCharHandle(player)) and isCharOnScreen(player) and player ~= playerPed then
            local plX, plY, plZ = getCharCoordinates(player)
            local cX, cY = convert3DCoordsToScreen(plX, plY, plZ)
            local distBetween2d = getDistanceBetweenCoords2d(sx / 2, sy / 2, cX, cY)
            if distBetween2d <= tonumber(radius and radius or sx) then
                table.insert(arr, {distBetween2d, player})
            end
        end
    end
    if #arr > 0 then
        table.sort(arr, function(a, b) return (a[1] < b[1]) end)
        return arr[1][2]
    end
    return nil
end
function renderFontDrawTextAlign(font, text, x, y, color, align)
    if not align or align == 1 then -- слева
        renderFontDrawText(font, text, x, y, color)
    end
  
    if align == 2 then -- по центру
        renderFontDrawText(font, text, x - renderGetFontDrawTextLength(font, text) / 2, y, color)
    end
  
    if align == 3 then -- справа
        renderFontDrawText(font, text, x - renderGetFontDrawTextLength(font, text), y, color)
    end
  end

imgui.OnFrame(function() return mp[0] and not isGamePaused() end,
function()
    imgui.SetNextWindowPos(imgui.ImVec2(1800, posY), imgui.Cond.FirstUseEver, imgui.ImVec2(1, 1))
    imgui.SetNextWindowSize(imgui.ImVec2(150, 300), imgui.Cond.Always)
    imgui.Begin('Teleport Menu', mp, imgui.WindowFlags.NoResize)
    if imgui.Button(u8'Центральный рынок', imgui.ImVec2(140, 30)) then
        sampSendChat('/tpcor 1130 -1413 14')
    end
    imgui.End()
end).HideCursor = false


imgui.OnFrame(function() return recon[0] and not isGamePaused() end,
function()
    imgui.SetNextWindowPos(imgui.ImVec2(1800, posY), imgui.Cond.Always, imgui.ImVec2(1, 1))
    imgui.SetNextWindowSize(imgui.ImVec2(340, 200), imgui.Cond.Always)
    imgui.Begin('Recon Stats', show, imgui.WindowFlags.NoDecoration, imgui.WindowFlags.AlwaysAutoResize, imgui.WindowFlags.NoSavedSettings, imgui.WindowFlags.NoMove, imgui.WindowFlags.NoInputs)
    imgui.Text(sampGetPlayerNickname(reconId) .. '[' .. reconId .. ']  (' .. sampGetPlayerPing(reconId) .. ' ping)')
    imgui.Separator()
    imgui.Text(u8'Уровень: ' .. sampGetPlayerScore(reconId) .. u8'     Здоровье: ' .. sampGetPlayerHealth(reconId) .. ' ' .. fa.HEART .. u8'     Брони: ' .. sampGetPlayerArmor(reconId) .. '' .. fa.CIRCLE_INFO)
    imgui.Separator()
    imgui.Text(u8'Законка: ' .. zakon .. ' ' ..fa.STAR .. u8'      Ранг: ' .. wanted .. ' ' .. fa.USER .. u8'      Фракция: ' .. org .. ' ' .. fa.MOON)
    imgui.Separator()
    imgui.Text(u8'Варнов: ' .. warning .. '/3 ' .. fa.CIRCLE_RADIATION .. u8'      Розыск: ' .. wanted .. ' ' .. fa.STAR)
    imgui.End()
end).HideCursor = true -- HideCursor отвечает за то, чтобы курсор не показывался

function cmd_amenu()
    WinState[0] = not WinState[0]
end

function cmd_deagle()
    lua_thread.create(function ()
        sampSendChat('/a [AdminTools]: Занимаю мероприятие через минуту! Просьба не мешать.')
        wait(60000)
        sampSendChat('/a [AdminTools]: Занимаю мероприятие')
        wait(3000)
        sampSendChat('/ao [Мероприятие] Здравствуйте уважаемые игроки! Сейчас я проведу мероприятие "Король дигла".')
        wait(3000)
        sampSendChat('/ao [Мероприятие] Суть мероприятия вам будет выдано оружие, а вы должны выжить в перестрелке.')
        wait(3000)
        sampSendChat('/ao [Мероприятие] На мероприятии запрещено: Хилл, Броник, RC машинки, анимк, +c')
        wait(3000)
        sampSendChat('/ao [Мероприятие] За все нарушения вы будите исключены с мероприятия!')
        wait(3000)
        sampSendChat('/ao [Мероприятие] Открываю телепорт через 30 секунд...')
        wait(30000)
        sampAddChatMessage(tag .. 'Открывай тп', -1)
        wait(1000)
        sampSendChat('/a [AdminTools]: Освобождаю мероприятие.')
        local pravila = 2
    end)
end

function cmd_pratki()
    lua_thread.create(function ()
        sampSendChat('/a [AdminTools]: Занимаю мероприятие через минуту! Просьба не мешать.')
        wait(60000)
        sampSendChat('/a [AdminTools]: Занимаю мероприятие')
        wait(3000)
        sampSendChat('/ao [Мероприятие] Здравствуйте уважаемые игроки! Сейчас я проведу мероприятие "Прятки"')
        wait(3000)
        sampSendChat('/ao [Мероприятие] Суть мероприятия спрятаться на определённой местрости и я вас не должен найти')
        wait(3000)
        sampSendChat('/ao [Мероприятие] На мероприятии запрещено: Маски, Броник, RC машинки, анимки, дм')
        wait(3000)
        sampSendChat('/ao [Мероприятие] За все нарушения вы будите исключены с мероприятия!')
        wait(3000)
        sampSendChat('/ao [Мероприятие] Открываю телепорт через 30 секунд...')
        wait(30000)
        sampAddChatMessage(tag .. 'Открывай тп', -1)
        sampSendChat('/a [AdminTools]: Освобождаю мероприятие.')
        pravila = 1
    end)
end

function cmd_pravila()
    lua_thread.create(function ()
        sampSendChat('/smp [Мероприятие] Повторяю ещё раз правила!')
        wait(2000)
        sampSendChat('/smp [Мероприятие] На мероприятии запрещено: Хилл, бронь, RC игрушки...')
        wait(2000)
        sampSendChat('/smp [Мероприятие] анимации, дм следящих, +с')
        wait(2000)
        sampSendChat('/smp [Мероприятие] За любое нарушение вы будите исключены с МП!')
        wait(2000)
        sampSendChat('/smp [Мероприятие] Через 5 секунд выдам вам оружие и вы начинаете перестрелку!')
        wait(5000)
        sampSendChat('/gunall 30 24 500')
        wait(2000)
        sampSendChat('/smp [Мероприятие] Начали!!')
    end)
end

function cmd_pravila1()
    lua_thread.create(function()
        sampSendChat('/smp [Мероприятие] Повторяю ещё раз правила!')
        wait(2000)
        sampSendChat('/smp [Мероприятие] На мероприятии запрещено: Хилл, Броник, RC машинки, анимк')
        wait(2000)
        sampSendChat('/smp [Мероприятие] За любое нарушение вы будите исключены с МП!')
        wait(2000)
        sampSendChat('/smp [Мероприятие] Разбегайтесь! У вас ровно 1 минута!')
        wait(60000)
        sampSendChat('/smp [Мероприятие] Кто не спрятался - я не виноват!')
    end)
end



imgui.OnInitialize(function()
    imgui.DarkTheme()
end)

function imgui.DarkTheme()
    imgui.SwitchContext()
    --==[ STYLE ]==--
    imgui.GetStyle().WindowPadding = imgui.ImVec2(5, 5)
    imgui.GetStyle().FramePadding = imgui.ImVec2(5, 5)
    imgui.GetStyle().ItemSpacing = imgui.ImVec2(5, 5)
    imgui.GetStyle().ItemInnerSpacing = imgui.ImVec2(2, 2)
    imgui.GetStyle().TouchExtraPadding = imgui.ImVec2(0, 0)
    imgui.GetStyle().IndentSpacing = 0
    imgui.GetStyle().ScrollbarSize = 10
    imgui.GetStyle().GrabMinSize = 10

    --==[ BORDER ]==--
    imgui.GetStyle().WindowBorderSize = 1
    imgui.GetStyle().ChildBorderSize = 1
    imgui.GetStyle().PopupBorderSize = 1
    imgui.GetStyle().FrameBorderSize = 1
    imgui.GetStyle().TabBorderSize = 1

    --==[ ROUNDING ]==--
    imgui.GetStyle().WindowRounding = 5
    imgui.GetStyle().ChildRounding = 5
    imgui.GetStyle().FrameRounding = 5
    imgui.GetStyle().PopupRounding = 5
    imgui.GetStyle().ScrollbarRounding = 5
    imgui.GetStyle().GrabRounding = 5
    imgui.GetStyle().TabRounding = 5

    --==[ ALIGN ]==--
    imgui.GetStyle().WindowTitleAlign = imgui.ImVec2(0.5, 0.5)
    imgui.GetStyle().ButtonTextAlign = imgui.ImVec2(0.5, 0.5)
    imgui.GetStyle().SelectableTextAlign = imgui.ImVec2(0.5, 0.5)
    
    --==[ COLORS ]==--
    imgui.GetStyle().Colors[imgui.Col.Text]                   = imgui.ImVec4(1.00, 1.00, 1.00, 1.00)
    imgui.GetStyle().Colors[imgui.Col.TextDisabled]           = imgui.ImVec4(0.50, 0.50, 0.50, 1.00)
    imgui.GetStyle().Colors[imgui.Col.WindowBg]               = imgui.ImVec4(0.07, 0.07, 0.07, 1.00)
    imgui.GetStyle().Colors[imgui.Col.ChildBg]                = imgui.ImVec4(0.07, 0.07, 0.07, 1.00)
    imgui.GetStyle().Colors[imgui.Col.PopupBg]                = imgui.ImVec4(0.07, 0.07, 0.07, 1.00)
    imgui.GetStyle().Colors[imgui.Col.Border]                 = imgui.ImVec4(0.25, 0.25, 0.26, 0.54)
    imgui.GetStyle().Colors[imgui.Col.BorderShadow]           = imgui.ImVec4(0.00, 0.00, 0.00, 0.00)
    imgui.GetStyle().Colors[imgui.Col.FrameBg]                = imgui.ImVec4(0.12, 0.12, 0.12, 1.00)
    imgui.GetStyle().Colors[imgui.Col.FrameBgHovered]         = imgui.ImVec4(0.25, 0.25, 0.26, 1.00)
    imgui.GetStyle().Colors[imgui.Col.FrameBgActive]          = imgui.ImVec4(0.25, 0.25, 0.26, 1.00)
    imgui.GetStyle().Colors[imgui.Col.TitleBg]                = imgui.ImVec4(0.12, 0.12, 0.12, 1.00)
    imgui.GetStyle().Colors[imgui.Col.TitleBgActive]          = imgui.ImVec4(0.12, 0.12, 0.12, 1.00)
    imgui.GetStyle().Colors[imgui.Col.TitleBgCollapsed]       = imgui.ImVec4(0.12, 0.12, 0.12, 1.00)
    imgui.GetStyle().Colors[imgui.Col.MenuBarBg]              = imgui.ImVec4(0.12, 0.12, 0.12, 1.00)
    imgui.GetStyle().Colors[imgui.Col.ScrollbarBg]            = imgui.ImVec4(0.12, 0.12, 0.12, 1.00)
    imgui.GetStyle().Colors[imgui.Col.ScrollbarGrab]          = imgui.ImVec4(0.00, 0.00, 0.00, 1.00)
    imgui.GetStyle().Colors[imgui.Col.ScrollbarGrabHovered]   = imgui.ImVec4(0.41, 0.41, 0.41, 1.00)
    imgui.GetStyle().Colors[imgui.Col.ScrollbarGrabActive]    = imgui.ImVec4(0.51, 0.51, 0.51, 1.00)
    imgui.GetStyle().Colors[imgui.Col.CheckMark]              = imgui.ImVec4(1.00, 1.00, 1.00, 1.00)
    imgui.GetStyle().Colors[imgui.Col.SliderGrab]             = imgui.ImVec4(0.21, 0.20, 0.20, 1.00)
    imgui.GetStyle().Colors[imgui.Col.SliderGrabActive]       = imgui.ImVec4(0.21, 0.20, 0.20, 1.00)
    imgui.GetStyle().Colors[imgui.Col.Button]                 = imgui.ImVec4(0.12, 0.12, 0.12, 1.00)
    imgui.GetStyle().Colors[imgui.Col.ButtonHovered]          = imgui.ImVec4(0.21, 0.20, 0.20, 1.00)
    imgui.GetStyle().Colors[imgui.Col.ButtonActive]           = imgui.ImVec4(0.41, 0.41, 0.41, 1.00)
    imgui.GetStyle().Colors[imgui.Col.Header]                 = imgui.ImVec4(0.12, 0.12, 0.12, 1.00)
    imgui.GetStyle().Colors[imgui.Col.HeaderHovered]          = imgui.ImVec4(0.20, 0.20, 0.20, 1.00)
    imgui.GetStyle().Colors[imgui.Col.HeaderActive]           = imgui.ImVec4(0.47, 0.47, 0.47, 1.00)
    imgui.GetStyle().Colors[imgui.Col.Separator]              = imgui.ImVec4(0.12, 0.12, 0.12, 1.00)
    imgui.GetStyle().Colors[imgui.Col.SeparatorHovered]       = imgui.ImVec4(0.12, 0.12, 0.12, 1.00)
    imgui.GetStyle().Colors[imgui.Col.SeparatorActive]        = imgui.ImVec4(0.12, 0.12, 0.12, 1.00)
    imgui.GetStyle().Colors[imgui.Col.ResizeGrip]             = imgui.ImVec4(1.00, 1.00, 1.00, 0.25)
    imgui.GetStyle().Colors[imgui.Col.ResizeGripHovered]      = imgui.ImVec4(1.00, 1.00, 1.00, 0.67)
    imgui.GetStyle().Colors[imgui.Col.ResizeGripActive]       = imgui.ImVec4(1.00, 1.00, 1.00, 0.95)
    imgui.GetStyle().Colors[imgui.Col.Tab]                    = imgui.ImVec4(0.12, 0.12, 0.12, 1.00)
    imgui.GetStyle().Colors[imgui.Col.TabHovered]             = imgui.ImVec4(0.28, 0.28, 0.28, 1.00)
    imgui.GetStyle().Colors[imgui.Col.TabActive]              = imgui.ImVec4(0.30, 0.30, 0.30, 1.00)
    imgui.GetStyle().Colors[imgui.Col.TabUnfocused]           = imgui.ImVec4(0.07, 0.10, 0.15, 0.97)
    imgui.GetStyle().Colors[imgui.Col.TabUnfocusedActive]     = imgui.ImVec4(0.14, 0.26, 0.42, 1.00)
    imgui.GetStyle().Colors[imgui.Col.PlotLines]              = imgui.ImVec4(0.61, 0.61, 0.61, 1.00)
    imgui.GetStyle().Colors[imgui.Col.PlotLinesHovered]       = imgui.ImVec4(1.00, 0.43, 0.35, 1.00)
    imgui.GetStyle().Colors[imgui.Col.PlotHistogram]          = imgui.ImVec4(0.90, 0.70, 0.00, 1.00)
    imgui.GetStyle().Colors[imgui.Col.PlotHistogramHovered]   = imgui.ImVec4(1.00, 0.60, 0.00, 1.00)
    imgui.GetStyle().Colors[imgui.Col.TextSelectedBg]         = imgui.ImVec4(1.00, 0.00, 0.00, 0.35)
    imgui.GetStyle().Colors[imgui.Col.DragDropTarget]         = imgui.ImVec4(1.00, 1.00, 0.00, 0.90)
    imgui.GetStyle().Colors[imgui.Col.NavHighlight]           = imgui.ImVec4(0.26, 0.59, 0.98, 1.00)
    imgui.GetStyle().Colors[imgui.Col.NavWindowingHighlight]  = imgui.ImVec4(1.00, 1.00, 1.00, 0.70)
    imgui.GetStyle().Colors[imgui.Col.NavWindowingDimBg]      = imgui.ImVec4(0.80, 0.80, 0.80, 0.20)
    imgui.GetStyle().Colors[imgui.Col.ModalWindowDimBg]       = imgui.ImVec4(0.00, 0.00, 0.00, 0.70)
end