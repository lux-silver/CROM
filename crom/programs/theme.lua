-- setup_crom.lua
-- Cria uma copia local e gravavel da rom, dentro do PRORIO computador,
-- em /crom. Isso NAO mexe na rom real, NAO troca BIOS, NAO afeta
-- outros jogadores/computadores. E so uma pasta normal, sandboxed
-- dentro do seu computador, que voce pode editar a vontade.

local origem = "rom"
local destino = "crom"

if fs.exists(destino) then
    print("A pasta /crom ja existe. Cancelando para nao sobrescrever.")
    print("Delete /crom manualmente se quiser refazer do zero.")
    return
end

print("Copiando " .. origem .. " para " .. destino .. " ...")
fs.copy(origem, destino)
print("Copia concluida!")

-- Adiciona /crom/programs e /crom/apis ao path do shell,
-- assim os comandos de dentro de /crom passam a funcionar
-- normalmente, igual comandos nativos (e sobrescrevem os
-- originais se voce editar um com o mesmo nome).
local caminhoAtual = shell.path()
local novoCaminho = "/crom/programs:/crom/programs/turtle:" .. caminhoAtual
shell.setPath(novoCaminho)

-- Salva essa configuracao de path para persistir apos reiniciar
local f = fs.open("crom_path.cfg", "w")
f.writeLine(novoCaminho)
f.close()

print("")
print("Pronto! Agora /crom e uma copia gravavel da rom,")
print("disponivel so neste computador.")
print("")
print("Para editar algo, use: edit crom/programs/nomedoarquivo")
print("Para criar programa novo: edit crom/programs/meuprograma")
print("")
print("IMPORTANTE: rode 'crom_startup' uma vez para gerar o")
print("startup que recarrega o path automaticamente ao ligar.")-- setup_crom.lua
-- Cria uma copia local e gravavel da rom, dentro do PRORIO computador,
-- em /crom. Isso NAO mexe na rom real, NAO troca BIOS, NAO afeta
-- outros jogadores/computadores. E so uma pasta normal, sandboxed
-- dentro do seu computador, que voce pode editar a vontade.

local origem = "rom"
local destino = "crom"

if fs.exists(destino) then
    print("A pasta /crom ja existe. Cancelando para nao sobrescrever.")
    print("Delete /crom manualmente se quiser refazer do zero.")
    return
end

print("Copiando " .. origem .. " para " .. destino .. " ...")
fs.copy(origem, destino)
print("Copia concluida!")

-- Adiciona /crom/programs e /crom/apis ao path do shell,
-- assim os comandos de dentro de /crom passam a funcionar
-- normalmente, igual comandos nativos (e sobrescrevem os
-- originais se voce editar um com o mesmo nome).
local caminhoAtual = shell.path()
local novoCaminho = "/crom/programs:/crom/programs/turtle:" .. caminhoAtual
shell.setPath(novoCaminho)

-- Salva essa configuracao de path para persistir apos reiniciar
local f = fs.open("crom_path.cfg", "w")
f.writeLine(novoCaminho)
f.close()

print("")
print("Pronto! Agora /crom e uma copia gravavel da rom,")
print("disponivel so neste computador.")
print("")
print("Para editar algo, use: edit crom/programs/nomedoarquivo")
print("Para criar programa novo: edit crom/programs/meuprograma")
print("")
print("IMPORTANTE: rode 'crom_startup' uma vez para gerar o")
print("startup que recarrega o path automaticamente ao ligar.")