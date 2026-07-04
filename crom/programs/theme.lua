-- theme.lua
-- Muda as cores do terminal CC dinamicamente.
-- Uso:
--   theme               -> lista temas prontos
--   theme <nome>        -> aplica tema pelo nome
--   theme <texto> <fundo> -> cores customizadas
--   theme reset         -> volta ao padrao do CC
--
-- Exemplos:
--   theme blue
--   theme pink black
--   theme cyan purple
--   theme reset

-- ============================================================
-- MAPA DE CORES
-- ============================================================
local CORES = {
    white   = colors.white,
    orange  = colors.orange,
    magenta = colors.magenta,
    pink    = colors.magenta,
    lightblue = colors.lightBlue,
    lb      = colors.lightBlue,
    yellow  = colors.yellow,
    lime    = colors.lime,
    green   = colors.green,
    red     = colors.red,
    brown   = colors.brown,
    gray    = colors.gray,
    grey    = colors.gray,
    lgray   = colors.lightGray,
    lgrey   = colors.lightGray,
    black   = colors.black,
    blue    = colors.blue,
    purple  = colors.purple,
    cyan    = colors.cyan,
}

-- ============================================================
-- TEMAS PRONTOS
-- ============================================================
local TEMAS = {
    blue    = { texto = colors.blue,      fundo = colors.black },
    red     = { texto = colors.red,       fundo = colors.black },
    green   = { texto = colors.lime,      fundo = colors.black },
    cyan    = { texto = colors.cyan,      fundo = colors.black },
    pink    = { texto = colors.magenta,   fundo = colors.black },
    purple  = { texto = colors.purple,    fundo = colors.black },
    orange  = { texto = colors.orange,    fundo = colors.black },
    white   = { texto = colors.white,     fundo = colors.black },
    hacker  = { texto = colors.lime,      fundo = colors.black },
    ocean   = { texto = colors.cyan,      fundo = colors.blue },
    sunset  = { texto = colors.orange,    fundo = colors.brown },
    night   = { texto = colors.lightGray, fundo = colors.black },
    candy   = { texto = colors.magenta,   fundo = colors.purple },
    forest  = { texto = colors.lime,      fundo = colors.green },
    ice     = { texto = colors.white,     fundo = colors.lightBlue },
    reset   = { texto = colors.yellow,    fundo = colors.black },
}

-- ============================================================
-- APLICA TEMA
-- ============================================================
local function aplicarTema(corTexto, corFundo)
    term.setBackgroundColor(corFundo)
    term.setTextColor(corTexto)
    term.clear()
    term.setCursorPos(1, 1)

    -- Salva no settings para persistir apos reboot
    if settings then
        settings.set("crom.theme.texto", corTexto)
        settings.set("crom.theme.fundo", corFundo)
        settings.save(".settings")
    end
end

local function listarTemas()
    print("Temas disponiveis:")
    print("")
    for nome, t in pairs(TEMAS) do
        term.setBackgroundColor(t.fundo)
        term.setTextColor(t.texto)
        io.write("  " .. nome)
        term.setBackgroundColor(colors.black)
        term.setTextColor(colors.white)
        print("")
    end
    print("")
    print("Cores: white, orange, pink, lightblue, yellow,")
    print("       lime, green, red, gray, black, blue,")
    print("       purple, cyan, brown, magenta")
    print("")
    print("Uso: theme <nome>")
    print("     theme <cor_texto> <cor_fundo>")
    print("     theme reset")
end

-- ============================================================
-- MAIN
-- ============================================================
local args = { ... }

if #args == 0 then
    listarTemas()
    return
end

local arg1 = args[1]:lower()
local arg2 = args[2] and args[2]:lower() or nil

-- Tema pelo nome
if TEMAS[arg1] then
    local t = TEMAS[arg1]
    aplicarTema(t.texto, t.fundo)
    print("Tema aplicado: " .. arg1)
    return
end

-- Cor de texto + fundo custom
local corTexto = CORES[arg1]
if not corTexto then
    print("Cor desconhecida: " .. arg1)
    print("Use 'theme' para ver as cores disponiveis.")
    return
end

local corFundo = colors.black -- fundo padrao se nao especificado
if arg2 then
    corFundo = CORES[arg2]
    if not corFundo then
        print("Cor de fundo desconhecida: " .. arg2)
        return
    end
end

aplicarTema(corTexto, corFundo)
print("Tema aplicado: texto=" .. arg1 .. " fundo=" .. (arg2 or "black"))
