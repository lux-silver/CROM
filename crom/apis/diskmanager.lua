-- diskmanager.lua
-- Gerencia multiplos discos CC dinamicamente.
-- Espalha arquivos por prioridade e tamanho automaticamente.
-- Discos sao detectados automaticamente (disk, disk1, disk2, ...)

local diskmanager = {}

-- Tamanho maximo que deixamos livre em cada disco (em bytes)
local RESERVA_LIVRE = 512

-- Encontra todos os discos montados
function diskmanager.listarDiscos()
    local discos = {}
    -- Disco principal (computador)
    table.insert(discos, { id = "local", path = "/", livre = true })
    -- Discos externos
    for i = 0, 9 do
        local path = i == 0 and "/disk" or "/disk" .. i
        if fs.isDir(path) and disk and disk.isPresent and disk.isPresent(path:sub(2)) then
            local livreBytes = fs.getFreeSpace(path)
            table.insert(discos, {
                id   = path:sub(2),
                path = path,
                livreBytes = livreBytes,
            })
        end
    end
    return discos
end

-- Retorna o disco com mais espaco livre (excluindo "local" para nao lotar o PC)
function diskmanager.discoMaisLivre(excluirLocal)
    local discos = diskmanager.listarDiscos()
    local melhor = nil
    local maiorLivre = -1
    for _, d in ipairs(discos) do
        if not (excluirLocal and d.id == "local") then
            local livre = d.livreBytes or fs.getFreeSpace(d.path)
            if livre > maiorLivre then
                maiorLivre = livre
                melhor = d
            end
        end
    end
    return melhor
end

-- Decide em qual disco salvar um arquivo pelo tamanho
-- Prefere discos externos; volta pro local se nao houver opcao
function diskmanager.escolherDisco(tamanhoBytes)
    local discos = diskmanager.listarDiscos()
    -- Ordena por espaco livre decrescente, priorizando externos
    table.sort(discos, function(a, b)
        local la = a.livreBytes or fs.getFreeSpace(a.path)
        local lb = b.livreBytes or fs.getFreeSpace(b.path)
        -- externos tem prioridade sobre local
        if a.id == "local" and b.id ~= "local" then return false end
        if a.id ~= "local" and b.id == "local" then return true end
        return la > lb
    end)
    for _, d in ipairs(discos) do
        local livre = d.livreBytes or fs.getFreeSpace(d.path)
        if livre - tamanhoBytes >= RESERVA_LIVRE then
            return d
        end
    end
    return nil -- sem espaco em nenhum disco
end

-- Salva um arquivo no disco mais adequado
-- Retorna o caminho completo onde foi salvo, ou nil + erro
function diskmanager.salvar(nomeRelativo, conteudo)
    local tamanho = #conteudo
    local disco = diskmanager.escolherDisco(tamanho)
    if not disco then
        return nil, "Sem espaco em disco!"
    end
    local caminhoCompleto = disco.path .. "/" .. nomeRelativo
    local pasta = fs.getDir(caminhoCompleto)
    if not fs.isDir(pasta) then
        fs.makeDir(pasta)
    end
    local f = fs.open(caminhoCompleto, "wb")
    if not f then
        return nil, "Nao foi possivel escrever em " .. caminhoCompleto
    end
    f.write(conteudo)
    f.close()
    return caminhoCompleto
end

-- Busca um arquivo por nome relativo em todos os discos
function diskmanager.encontrar(nomeRelativo)
    local discos = diskmanager.listarDiscos()
    for _, d in ipairs(discos) do
        local caminho = d.path .. "/" .. nomeRelativo
        if fs.exists(caminho) then
            return caminho, d
        end
    end
    return nil
end

-- Lista todos os arquivos em todos os discos com seus locais
function diskmanager.listarTudo(subpasta)
    subpasta = subpasta or ""
    local resultado = {}
    local discos = diskmanager.listarDiscos()
    local function lerDir(base, rel)
        local full = rel == "" and base or (base .. "/" .. rel)
        if not fs.isDir(full) then return end
        for _, nome in ipairs(fs.list(full)) do
            local relNovo = rel == "" and nome or (rel .. "/" .. nome)
            local fullNovo = base .. "/" .. relNovo
            if fs.isDir(fullNovo) then
                lerDir(base, relNovo)
            else
                table.insert(resultado, { disco = base, relativo = relNovo, completo = fullNovo })
            end
        end
    end
    for _, d in ipairs(discos) do
        lerDir(d.path, subpasta)
    end
    return resultado
end

-- Mostra status de todos os discos
function diskmanager.status()
    local discos = diskmanager.listarDiscos()
    print("=== Status dos Discos ===")
    for _, d in ipairs(discos) do
        local livre  = fs.getFreeSpace(d.path)
        local usado  = fs.getSize and fs.getSize(d.path) or "?"
        print(string.format("  [%s] %s | livre: %d bytes", d.id, d.path, livre))
    end
    print("=========================")
end

return diskmanager
