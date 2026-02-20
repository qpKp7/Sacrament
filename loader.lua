-- Adicionamos um timestamp para burlar o cache do GitHub
local tickTime = tostring(math.floor(tick()))
local url = "https://raw.githubusercontent.com/qpKp7/Sacrament/main/loader.lua?t=" .. tickTime

print("[1] Iniciando HttpGet...")
local success, result = pcall(game.HttpGet, game, url, true)

if not success then
    warn("[Erro] Falha na requisição HTTP: " .. tostring(result))
    return
end

-- Verifica se o GitHub retornou uma página HTML (Erro 404)
if result:match("^<!DOCTYPE html>") or result:match("^<html>") then
    warn("[Erro] O link retornou uma página HTML. O arquivo não existe ou o repositório está privado.")
    return
end

print("[2] HttpGet OK. Tamanho do arquivo: " .. #result .. " bytes.")

-- Capturamos o segundo retorno do loadstring, que é a mensagem de erro de compilação
local loaderFn, compileErr = loadstring(result, "@Sacrament_Loader")
if type(loaderFn) ~= "function" then
    warn("[Erro] O loadstring retornou nil. Erro de sintaxe no loader.lua:\n" .. tostring(compileErr))
    return
end

print("[3] Loadstring compilou com sucesso. Executando...")
local execSuccess, Sacrament = pcall(loaderFn)

if not execSuccess then
    warn("[Erro] Falha ao executar o corpo do loader.lua: " .. tostring(Sacrament))
    return
end

if type(Sacrament) ~= "table" or type(Sacrament.Init) ~= "function" then
    warn("[Erro] O loader.lua executou, mas não retornou uma tabela com o método :Init(). Retornou: " .. typeof(Sacrament))
    return
end

print("[4] Tabela Sacrament e :Init() encontrados. Inicializando...")
local initSuccess, initErr = pcall(function()
    Sacrament:Init()
end)

if not initSuccess then
    warn("[Erro] O script explodiu dentro de Sacrament:Init():\n" .. tostring(initErr))
else
    print("[5] Sucesso Total! A GUI deve estar na tela.")
end
