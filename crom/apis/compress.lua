-- compress.lua
-- Compactacao e descompactacao propria para CC:Tweaked
-- Formato: .crom (arquivo unico com multiplos arquivos dentro)
--
-- Estrutura do .crom:
--   HEADER: "CROM" (4 bytes magicos)
--   Para cada arquivo:
--     [tamanho do caminho: 2 bytes][caminho][tamanho do conteudo: 4 bytes][conteudo]
--   FIM: 4 bytes zeros

local compress = {}

-- Converte numero para bytes (little-endian)
local function numParaBytes(n, tamanho)
    local bytes = ""
    for i = 1, tamanho do
        bytes = bytes .. string.char(n % 256)
        n = math.floor(n / 256)
    end
    return bytes
end

-- Converte bytes para numero (little-endian)
local function bytesParaNum(bytes)
    local n = 0
    for i = #bytes, 1, -1 do
        n = n * 256 + bytes:byte(i)
    end
    return n
end

-- Compacta uma lista de arquivos em um .crom
-- arquivos = { {caminho="programs/x.lua", conteudo="..."}, ... }
-- destino  = caminho do arquivo .crom a criar
function compress.compactar(arquivos, destino)
    local f = fs.open(destino, "wb")
    if not f then
        return false, "Nao foi possivel criar " .. destino
    end

    -- Header magico
    f.write("CROM")

    for _, arq in ipairs(arquivos) do
        local caminho  = arq.caminho
        local conteudo = arq.conteudo

        -- Tamanho do caminho (2 bytes) + caminho
        f.write(numParaBytes(#caminho, 2))
        f.write(caminho)

        -- Tamanho do conteudo (4 bytes) + conteudo
        f.write(numParaBytes(#conteudo, 4))
        f.write(conteudo)
    end

    -- Marcador de fim
    f.write(numParaBytes(0, 4))
    f.close()
    return true
end

-- Descompacta um .crom para uma pasta destino
-- origem  = caminho do .crom
-- destino = pasta onde extrair (ex: "/crom")
function compress.descompactar(origem, destino)
    local f = fs.open(origem, "rb")
    if not f then
        return false, "Arquivo nao encontrado: " .. origem
    end

    -- Verifica header
    local header = f.read(4)
    if header ~= "CROM" then
        f.close()
        return false, "Arquivo invalido (header incorreto)"
    end

    local extraidos = 0

    while true do
        -- Le tamanho do caminho
        local tamCaminhoBytes = f.read(2)
        if not tamCaminhoBytes or #tamCaminhoBytes < 2 then break end
        local tamCaminho = bytesParaNum(tamCaminhoBytes)
        if tamCaminho == 0 then break end -- fim

        -- Le caminho
        local caminho = f.read(tamCaminho)

        -- Le tamanho do conteudo
        local tamConteudoBytes = f.read(4)
        local tamConteudo = bytesParaNum(tamConteudoBytes)

        -- Le conteudo
        local conteudo = tamConteudo > 0 and f.read(tamConteudo) or ""

        -- Cria diretorios necessarios
        local caminhoCompleto = destino .. "/" .. caminho
        local pasta = fs.getDir(caminhoCompleto)
        if not fs.isDir(pasta) then
            fs.makeDir(pasta)
        end

        -- Escreve arquivo
        local saida = fs.open(caminhoCompleto, "wb")
        if saida then
            saida.write(conteudo)
            saida.close()
            extraidos = extraidos + 1
        end
    end

    f.close()
    return true, extraidos .. " arquivos extraidos"
end

-- Lê todos arquivos de uma pasta recursivamente
-- retorna lista de {caminho relativo, conteudo}
function compress.lerPasta(pasta, base)
    base = base or pasta
    local resultado = {}
    for _, nome in ipairs(fs.list(pasta)) do
        local caminhoCompleto = pasta .. "/" .. nome
        if fs.isDir(caminhoCompleto) then
            local sub = compress.lerPasta(caminhoCompleto, base)
            for _, v in ipairs(sub) do
                table.insert(resultado, v)
            end
        else
            local f = fs.open(caminhoCompleto, "rb")
            if f then
                local conteudo = f.readAll()
                f.close()
                -- caminho relativo à base
                local rel = caminhoCompleto:sub(#base + 2)
                table.insert(resultado, { caminho = rel, conteudo = conteudo })
            end
        end
    end
    return resultado
end

return compress
