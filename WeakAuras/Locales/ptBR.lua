if (GAME_LOCALE or GetLocale()) ~= "ptBR" then
  return
end

local L = WeakAuras.L

-- WeakAuras
--[[Translation missing --]]
L[ [=[ Filter formats: 'Name', 'Name-Realm', '-Realm'. 

Supports multiple entries, separated by commas
Can use \ to escape -.]=] ] = [=[ Filter formats: 'Name', 'Name-Realm', '-Realm'. 

Supports multiple entries, separated by commas
Can use \ to escape -.]=]
L["%s Overlay Color"] = "%s Cor de Sobreposição"
L["* Suffix"] = "* Sufixo"
L["/wa help - Show this message"] = "/wa help - Mostrar essa mensagem"
L["/wa minimap - Toggle the minimap icon"] = "/wa minimap - Mostrar/esconder o ícone de minimapa"
L["/wa pprint - Show the results from the most recent profiling"] = "/wa pprint - Mostra os resultados da criação de perfil mais recente"
L["/wa pstart - Start profiling. Optionally include a duration in seconds after which profiling automatically stops. To profile the next combat/encounter, pass a \"combat\" or \"encounter\" argument."] = "/wa pstart - Inicia a criação de perfil. Opcionalmente inclui uma duração em segundos em que a criação de perfis automaticamente para. Para traçar o perfil do próximo combate/encontro, passe um argumento de \"combate\" ou \"encontro\"."
L["/wa pstop - Finish profiling"] = "/wa pstop - Concluir criação de perfil"
L["/wa repair - Repair tool"] = "/wa repair - Ferramenta de reparo"
L["|cffeda55fLeft-Click|r to toggle showing the main window."] = "|cffeda55fLeft-Click|r para alternar a exibição da janela principal."
L["|cffeda55fMiddle-Click|r to toggle the minimap icon on or off."] = "|cffeda55fMiddle-Click|r para esconder ou mostrar o ícone do minimapa."
L["|cffeda55fRight-Click|r to toggle performance profiling window."] = "|cffeda55fRight-Click|r mostrar/esconder a janela de perfil de desempenho."
L["|cffeda55fShift-Click|r to pause addon execution."] = "|cffeda55fShift-Click|r para pausar a execução do addon."
--[[Translation missing --]]
L["|cffff0000deprecated|r"] = "|cffff0000deprecated|r"
--[[Translation missing --]]
L["|cFFFF0000Not|r Item Bonus Id Equipped"] = "|cFFFF0000Not|r Item Bonus Id Equipped"
--[[Translation missing --]]
L["|cFFFF0000Not|r Item Equipped"] = "|cFFFF0000Not|r Item Equipped"
--[[Translation missing --]]
L["|cFFFF0000Not|r Player Name/Realm"] = "|cFFFF0000Not|r Player Name/Realm"
--[[Translation missing --]]
L["|cFFFF0000Not|r Spell Known"] = "|cFFFF0000Not|r Spell Known"
--[[Translation missing --]]
L[ [=[|cFFFF0000Support for unfiltered COMBAT_LOG_EVENT_UNFILTERED is deprecated|r
COMBAT_LOG_EVENT_UNFILTERED without a filter are disabled as it’s very performance costly.
Find more information:
https://github.com/WeakAuras/WeakAuras2/wiki/Custom-Triggers#events]=] ] = [=[|cFFFF0000Support for unfiltered COMBAT_LOG_EVENT_UNFILTERED is deprecated|r
COMBAT_LOG_EVENT_UNFILTERED without a filter are disabled as it’s very performance costly.
Find more information:
https://github.com/WeakAuras/WeakAuras2/wiki/Custom-Triggers#events]=]
L["|cFFffcc00Extra Options:|r %s"] = [=[|cFFffcc00Opções Extra:|r %s

]=]
L["|cFFffcc00Extra Options:|r None"] = "|cFFffcc00Opções Extra:|r Nenhuma"
--[[Translation missing --]]
L[ [=[• |cff00ff00Player|r, |cff00ff00Target|r, |cff00ff00Focus|r, and |cff00ff00Pet|r correspond directly to those individual unitIDs.
• |cff00ff00Specific Unit|r lets you provide a specific valid unitID to watch.
|cffff0000Note|r: The game will not fire events for all valid unitIDs, making some untrackable by this trigger.
• |cffffff00Party|r, |cffffff00Raid|r, |cffffff00Boss|r, |cffffff00Arena|r, and |cffffff00Nameplate|r can match multiple corresponding unitIDs.
• |cffffff00Smart Group|r adjusts to your current group type, matching just the "player" when solo, "party" units (including "player") in a party or "raid" units in a raid.

|cffffff00*|r Yellow Unit settings will create clones for each matching unit while this trigger is providing Dynamic Info to the Aura.]=] ] = [=[• |cff00ff00Player|r, |cff00ff00Target|r, |cff00ff00Focus|r, and |cff00ff00Pet|r correspond directly to those individual unitIDs.
• |cff00ff00Specific Unit|r lets you provide a specific valid unitID to watch.
|cffff0000Note|r: The game will not fire events for all valid unitIDs, making some untrackable by this trigger.
• |cffffff00Party|r, |cffffff00Raid|r, |cffffff00Boss|r, |cffffff00Arena|r, and |cffffff00Nameplate|r can match multiple corresponding unitIDs.
• |cffffff00Smart Group|r adjusts to your current group type, matching just the "player" when solo, "party" units (including "player") in a party or "raid" units in a raid.

|cffffff00*|r Yellow Unit settings will create clones for each matching unit while this trigger is providing Dynamic Info to the Aura.]=]
--[[Translation missing --]]
L["1. Profession 1. Accessory"] = "1. Profession 1. Accessory"
--[[Translation missing --]]
L["1. Profession 2. Accessory"] = "1. Profession 2. Accessory"
--[[Translation missing --]]
L["1. Professsion Tool"] = "1. Professsion Tool"
L["10 Man Raid"] = "Raide de 10 jogadores"
--[[Translation missing --]]
L["10 Player Raid"] = "10 Player Raid"
--[[Translation missing --]]
L["10 Player Raid (Heroic)"] = "10 Player Raid (Heroic)"
--[[Translation missing --]]
L["10 Player Raid (Normal)"] = "10 Player Raid (Normal)"
--[[Translation missing --]]
L["2. Profession 1. Accessory"] = "2. Profession 1. Accessory"
--[[Translation missing --]]
L["2. Profession 2. Accessory"] = "2. Profession 2. Accessory"
--[[Translation missing --]]
L["2. Professsion Tool"] = "2. Professsion Tool"
L["20 Man Raid"] = "Raide de 20 jogadores"
--[[Translation missing --]]
L["20 Player Raid"] = "20 Player Raid"
L["25 Man Raid"] = "Raide de 25 jogadores"
--[[Translation missing --]]
L["25 Player Raid"] = "25 Player Raid"
--[[Translation missing --]]
L["25 Player Raid (Heroic)"] = "25 Player Raid (Heroic)"
--[[Translation missing --]]
L["25 Player Raid (Normal)"] = "25 Player Raid (Normal)"
--[[Translation missing --]]
L["25 Player Raid (Titan Reforged)"] = "25 Player Raid (Titan Reforged)"
L["40 Man Raid"] = "Raide de 40 jogadores"
--[[Translation missing --]]
L["40 Player Raid"] = "40 Player Raid"
L["5 Man Dungeon"] = "Masmorra de 5 jogadores"
--[[Translation missing --]]
L[ [=[A detailed overview of your auras and Musca Auras systems
Copy the whole text to Weakaura's Discord if you need assistance.]=] ] = [=[A detailed overview of your auras and Musca Auras systems
Copy the whole text to Weakaura's Discord if you need assistance.]=]
--[[Translation missing --]]
L["A trigger in this aura is set up to track a soft target unit, but you don't have the CVars set up for this to work correctly. Consider either changing the unit tracked, or configuring the Soft Target CVars."] = "A trigger in this aura is set up to track a soft target unit, but you don't have the CVars set up for this to work correctly. Consider either changing the unit tracked, or configuring the Soft Target CVars."
L["Abbreviate"] = "Abreviar"
L["AbbreviateLargeNumbers (Blizzard)"] = "AbreviarNúmerosGrandes (Blizzard)"
L["AbbreviateNumbers (Blizzard)"] = "AbreviarNúmeros (Blizzard)"
L["Absorb"] = "Absorver"
--[[Translation missing --]]
L["Absorb and Healing"] = "Absorb and Healing"
L["Absorbed"] = "Absorvido"
L["Action Button Glow"] = "Brilho do botão de ação"
L["Actions"] = "Ações"
L["Active"] = "Ativo"
--[[Translation missing --]]
L[ [=[Active boss mod addon: |cFFffcc00BigWigs|r

Note: This trigger will use BigWigs or DBM, in that order if both are installed.]=] ] = [=[Active boss mod addon: |cFFffcc00BigWigs|r

Note: This trigger will use BigWigs or DBM, in that order if both are installed.]=]
--[[Translation missing --]]
L[ [=[Active boss mod addon: |cFFffcc00DBM|r

Note: This trigger will use BigWigs or DBM, in that order if both are installed.]=] ] = [=[Active boss mod addon: |cFFffcc00DBM|r

Note: This trigger will use BigWigs or DBM, in that order if both are installed.]=]
L["Add"] = "Adicionar"
L["Add Missing Auras"] = "Adicionar auras faltantes"
--[[Translation missing --]]
L["Advanced Caster's Target Check"] = "Advanced Caster's Target Check"
L["Affected"] = "Afetado"
L["Affected Unit Count"] = "Contagem de unidades afetadas"
--[[Translation missing --]]
L["Afk"] = "Afk"
L["Aggro"] = "Aggro"
L["Agility"] = "Agilidade"
L["Ahn'Qiraj"] = "Ahn'Qiraj"
--[[Translation missing --]]
L["Alert Type"] = "Tipo de alerta"
L["Alive"] = "Vivo"
L["All"] = "Todos"
--[[Translation missing --]]
L["All children of this aura will also not be loaded, to minimize the chance of further corruption."] = "All children of this aura will also not be loaded, to minimize the chance of further corruption."
--[[Translation missing --]]
L["All States table contains a non table at key: '%s'."] = "All States table contains a non table at key: '%s'."
L["All Triggers"] = "Todos os Gatilhos"
L["Alliance"] = "Aliança"
L["Alpha"] = "Transparência"
L["Always"] = "Sempre"
L["Always active trigger"] = "Gatilho sempre ativo"
L["Always include realm"] = "Sempre incluir reino"
L["Always True"] = "Sempre Verdadeiro"
L["Amount"] = "Quantidade"
--[[Translation missing --]]
L["Anchoring"] = "Anchoring"
L["And Talent"] = "E Também o Talento"
--[[Translation missing --]]
L["Angle and Radius"] = "Angle and Radius"
L["Animations"] = "Animações"
L["Anticlockwise"] = "Anti-horário"
--[[Translation missing --]]
L["Anub'Rekhan"] = "Anub'Rekhan"
L["Any"] = "Qualquer"
L["Any Triggers"] = "Quaisquer gatilhos"
L["AOE"] = "AOE"
L["Arcane Resistance"] = "Resistência Arcana"
--[[Translation missing --]]
L[ [=[Are you sure you want to run the |cffff0000EXPERIMENTAL|r repair tool?
This will overwrite any changes you have made since the last database upgrade.
Last upgrade: %s]=] ] = [=[Are you sure you want to run the |cffff0000EXPERIMENTAL|r repair tool?
This will overwrite any changes you have made since the last database upgrade.
Last upgrade: %s]=]
L["Arena"] = "Arena"
L["Armor Rating"] = "Classificação de armadura"
L["Array"] = "Arranjo"
L["Ascending"] = "Ascendente"
L["Assigned Role"] = "Função Atribuída"
--[[Translation missing --]]
L["Assigned Role Icon"] = "Assigned Role Icon"
--[[Translation missing --]]
L["Assist"] = "Assist"
L["At Least One Enemy"] = "Pelo Menos Um Inimigo"
L["At missing Value"] = "No valor ausente"
L["At Percent"] = "Na porcentagem"
L["At Value"] = "Em valor"
--[[Translation missing --]]
L["At War"] = "At War"
L["Attach to End"] = "Anexar ao final"
--[[Translation missing --]]
L["Attach to End, backwards"] = "Attach to End, backwards"
--[[Translation missing --]]
L["Attach to Point"] = "Attach to Point"
L["Attach to Start"] = "Anexar ao inicio"
L["Attack Power"] = "Poder de ataque"
L["Attackable"] = "Atacável"
L["Attackable Target"] = "Alvo atacável "
--[[Translation missing --]]
L["Aura"] = "Aura"
L["Aura '%s': %s"] = "Aura '%s': %s"
L["Aura Applied"] = "Aura Aplicada"
L["Aura Applied Dose"] = "Dose de Aura Aplicada"
L["Aura Broken"] = "Aura violada"
L["Aura Broken Spell"] = "Feitiço violar de aura"
--[[Translation missing --]]
L["Aura is using deprecated SetDurationInfo"] = "Aura is using deprecated SetDurationInfo"
--[[Translation missing --]]
L["Aura loaded"] = "Aura loaded"
L["Aura Name"] = "Nome da Aura"
L["Aura Names"] = "Nomes das Auras"
L["Aura Refresh"] = "Aura Restaurada"
L["Aura Removed"] = "Aura Removida"
L["Aura Removed Dose"] = "Dose de Aura Removida"
L["Aura Stack"] = "Monte da Aura"
L["Aura Type"] = "Tipo de Aura"
--[[Translation missing --]]
L["Aura Version: %s"] = "Aura Version: %s"
L["Aura(s) Found"] = "Aura(s) Encontrada(s)"
L["Aura(s) Missing"] = "Aura(s) Faltando"
L["Aura:"] = "Aura:"
--[[Translation missing --]]
L["Auras"] = "Auras"
L["Auras:"] = "Auras:"
L["Author Options"] = "Opções de Autor"
L["Auto"] = "Auto"
--[[Translation missing --]]
L["Autocast Shine"] = "Autocast Shine"
L["Automatic"] = "Automático"
L["Automatic Length"] = "Comprimento Automático"
L["Automatic Rotation"] = "Rotação Automática"
--[[Translation missing --]]
L["Available features: %s"] = "Available features: %s"
L["Ayamiss the Hunter"] = "Ayamiss, o Caçador"
--[[Translation missing --]]
L["Azuregos"] = "Azuregos"
L["Back and Forth"] = "Vai e volta"
L["Background"] = "Plano de fundo"
L["Background Color"] = "Cor do Plano de Fundo"
--[[Translation missing --]]
L["Balnazzar"] = "Balnazzar"
--[[Translation missing --]]
L["Bar"] = "Bar"
--[[Translation missing --]]
L["Bar and Icon"] = "Bar and Icon"
--[[Translation missing --]]
L["Bar Color/Gradient Start"] = "Bar Color/Gradient Start"
--[[Translation missing --]]
L["Bar enabled in BigWigs settings"] = "Bar enabled in BigWigs settings"
--[[Translation missing --]]
L["Bar enabled in Boss Mod addon settings"] = "Bar enabled in Boss Mod addon settings"
--[[Translation missing --]]
L["Bar enabled in DBM settings"] = "Bar enabled in DBM settings"
--[[Translation missing --]]
L["Bar Texture"] = "Bar Texture"
--[[Translation missing --]]
L["Bar Type"] = "Bar Type"
L["Baron Geddon"] = "Barão Geddon"
--[[Translation missing --]]
L["Battle for Azeroth"] = "Battle for Azeroth"
L["Battle.net Whisper"] = "Battle.net Sussuro"
L["Battleground"] = "Campo de Batalha"
L["Battleguard Sartura"] = "Guarda de Batalha Sartura"
--[[Translation missing --]]
L["Beastmaster"] = "Beastmaster"
--[[Translation missing --]]
L["Beatrix"] = "Beatrix"
L["BG>Raid>Party>Say"] = "CB>Raide>Grupo>Dizer"
L["BG-System Alliance"] = "CB-Sistema da Aliança"
L["BG-System Horde"] = "CB-Sistema da Horda"
L["BG-System Neutral"] = "CB-Sistema Neutro"
L["Big Number"] = "Número Grande"
L["BigWigs Addon"] = "Addon BigWigs"
L["BigWigs Message"] = "Mensagem do BigWigs"
--[[Translation missing --]]
L["BigWigs Stage"] = "BigWigs Stage"
L["BigWigs Timer"] = "Cronômetro do BigWigs"
--[[Translation missing --]]
L["Black Wing Lair"] = "Covil Asa Negra"
--[[Translation missing --]]
L["Bleed"] = "Bleed"
L["Blizzard Combat Text"] = "Texto de Combate da Blizzard"
--[[Translation missing --]]
L["Blizzard Cooldown Reduction"] = "Blizzard Cooldown Reduction"
L["Block"] = "Bloquear"
L["Block (%)"] = "Bloqueio (%)"
--[[Translation missing --]]
L["Block Value"] = "Block Value"
L["Blocked"] = "Bloqueado"
L["Bloodlord Mandokir"] = "Sangrelorde Mandokir"
L["Border"] = "Borda"
L["Boss"] = "Chefe"
L["Boss Emote"] = "Emote do Chefe"
--[[Translation missing --]]
L["Boss Mod Announce"] = "Boss Mod Announce"
--[[Translation missing --]]
L["Boss Mod Stage"] = "Boss Mod Stage"
--[[Translation missing --]]
L["Boss Mod Stage (Event)"] = "Boss Mod Stage (Event)"
--[[Translation missing --]]
L["Boss Mod Timer"] = "Boss Mod Timer"
L["Boss Whisper"] = "Sussurro do Chefe"
L["Bottom"] = "Embaixo"
L["Bottom Left"] = "Embaixo à esquerda"
L["Bottom Right"] = "Embaixo à direita"
L["Bottom to Top"] = "De baixo para cima"
L["Bounce"] = "Salto"
L["Bounce with Decay"] = "Salto com declínio"
--[[Translation missing --]]
L["Break"] = "Break"
--[[Translation missing --]]
L["BreakUpLargeNumbers (Blizzard)"] = "BreakUpLargeNumbers (Blizzard)"
L["Broodlord Lashlayer"] = "Prolemestre Flagelador"
--[[Translation missing --]]
L["Buff"] = "Buff"
--[[Translation missing --]]
L["Buff/Debuff"] = "Buff/Debuff"
L["Buffed/Debuffed"] = "Buffado/Debuffado"
--[[Translation missing --]]
L["Burning Crusade"] = "Burning Crusade"
L["Buru the Gorger"] = "Buru, o Banqueteador"
--[[Translation missing --]]
L["Caldoran"] = "Caldoran"
--[[Translation missing --]]
L["Callback function"] = "Callback function"
L["Can be used for e.g. checking if \"boss1target\" is the same as \"player\"."] = "Pode ser usado, por exemplo, para checar se \"chefe1alvo\" é o mesmo que \"jogador\"."
L["Cancel"] = "Cancelar"
--[[Translation missing --]]
L[ [=[Cannot change secure frame in combat lockdown. Find more information:
https://github.com/WeakAuras/WeakAuras2/wiki/Protected-Frames]=] ] = [=[Cannot change secure frame in combat lockdown. Find more information:
https://github.com/WeakAuras/WeakAuras2/wiki/Protected-Frames]=]
L["Can't schedule timer with %i, due to a World of Warcraft bug with high computer uptime. (Uptime: %i). Please restart your computer."] = "Não é possível agendar o cronômetro com %i, devido a um bug do World of Warcraft com alto tempo de atividade do computador. (Tempo de atividade: %i). Por favor, reinicie o seu computador."
--[[Translation missing --]]
L["Capped"] = "Capped"
L["Cast"] = "Lançar"
L["Cast Bar"] = "Barra de Lançamento"
L["Cast Failed"] = "Lançamento falho"
L["Cast Start"] = "Começar lançamento"
L["Cast Success"] = "Sucesso no lançamento"
L["Cast Type"] = "Tipo de lançamento"
L["Caster"] = "Lançador"
L["Caster Name"] = "Nome do Lançador"
L["Caster Realm"] = "Reino do Lançador"
L["Caster Unit"] = "Unidade de Lançador"
--[[Translation missing --]]
L["Casters Name/Realm"] = "Casters Name/Realm"
L["Caster's Target"] = "Alvo do Lançador"
--[[Translation missing --]]
L["Cataclysm"] = "Cataclysm"
L["Ceil"] = "Teto"
L["Center"] = "Centro"
--[[Translation missing --]]
L["Center, then alternating bottom and top"] = "Center, then alternating bottom and top"
--[[Translation missing --]]
L["Center, then alternating left and right"] = "Center, then alternating left and right"
--[[Translation missing --]]
L["Center, then alternating right and left"] = "Center, then alternating right and left"
--[[Translation missing --]]
L["Center, then alternating top and bottom"] = "Center, then alternating top and bottom"
L["Centered Horizontal"] = "Centralizado Horizontalmente"
--[[Translation missing --]]
L["Centered Horizontal, then Centered Vertical"] = "Centered Horizontal, then Centered Vertical"
--[[Translation missing --]]
L["Centered Horizontal, then Down"] = "Centered Horizontal, then Down"
--[[Translation missing --]]
L["Centered Horizontal, then Up"] = "Centered Horizontal, then Up"
L["Centered Vertical"] = "Centralizado Verticalmente"
--[[Translation missing --]]
L["Centered Vertical, then Centered Horizontal"] = "Centered Vertical, then Centered Horizontal"
--[[Translation missing --]]
L["Centered Vertical, then Left"] = "Centered Vertical, then Left"
--[[Translation missing --]]
L["Centered Vertical, then Right"] = "Centered Vertical, then Right"
L["Changed"] = "Mudou"
L["Channel"] = "Canal"
L["Channel (Spell)"] = "Canal (Feitiço)"
L["Character Stats"] = "Atributos do Personagem"
L["Character Type"] = "Tipo de personagem"
L["Charge gained/lost"] = "Carga ganha/perdida"
L["Charges"] = "Cargas"
--[[Translation missing --]]
L["Charges Changed Event"] = "Charges Changed Event"
L["Chat Frame"] = "Quadro do bate-papo"
L["Chat Message"] = "Mensagem de bate-papo"
--[[Translation missing --]]
L["Check if a single talent match a Rank"] = "Check if a single talent match a Rank"
--[[Translation missing --]]
L["Check nameplate's target every 0.2s"] = "Check nameplate's target every 0.2s"
--[[Translation missing --]]
L["Chromaggus"] = "Chromaggus"
L["Circle"] = "Círculo"
--[[Translation missing --]]
L["Circular Texture"] = "Circular Texture"
--[[Translation missing --]]
L["Clamp"] = "Clamp"
L["Class"] = "Classe"
L["Class and Specialization"] = "Classe e Especialização"
--[[Translation missing --]]
L["Classic"] = "Classic"
L["Classification"] = "Classificação"
L["Clockwise"] = "Sentido Horário"
--[[Translation missing --]]
L["Clone per Event"] = "Clone per Event"
--[[Translation missing --]]
L["Clone per Match"] = "Clone per Match"
--[[Translation missing --]]
L["Coin Precision"] = "Coin Precision"
L["Color"] = "Cor"
--[[Translation missing --]]
L["Color Animation"] = "Color Animation"
L["Combat Log"] = "Registro de combate"
--[[Translation missing --]]
L["Communities"] = "Communities"
--[[Translation missing --]]
L["Condition Custom Test"] = "Condition Custom Test"
L["Conditions"] = "Condições"
L["Contains"] = "Contém"
--[[Translation missing --]]
L["Continuously update Movement Speed"] = "Continuously update Movement Speed"
L["Cooldown"] = "Tempo de Recarga"
--[[Translation missing --]]
L["Cooldown bars show time before an ability is ready to be use, BigWigs prefix them with '~'"] = "Cooldown bars show time before an ability is ready to be use, BigWigs prefix them with '~'"
L["Cooldown Progress (Item)"] = "Curso do tempo de recarga (Item)"
--[[Translation missing --]]
L["Cooldown Progress (Slot)"] = "Cooldown Progress (Slot)"
--[[Translation missing --]]
L["Cooldown Ready Event"] = "Cooldown Ready Event"
--[[Translation missing --]]
L["Cooldown Ready Event (Item)"] = "Cooldown Ready Event (Item)"
--[[Translation missing --]]
L["Cooldown Ready Event (Slot)"] = "Cooldown Ready Event (Slot)"
--[[Translation missing --]]
L["Cooldown Reduction changes the duration of seconds instead of showing the real time seconds."] = "Cooldown Reduction changes the duration of seconds instead of showing the real time seconds."
--[[Translation missing --]]
L["Cooldown/Charges/Count"] = "Cooldown/Charges/Count"
--[[Translation missing --]]
L["Copper"] = "Copper"
--[[Translation missing --]]
L["Could not load Musca Auras Archive, the addon is %s"] = "Could not load Musca Auras Archive, the addon is %s"
--[[Translation missing --]]
L["Count"] = "Count"
--[[Translation missing --]]
L["Counter Clockwise"] = "Counter Clockwise"
L["Create"] = "Criar"
L["Critical"] = "Crítico"
--[[Translation missing --]]
L["Critical (%)"] = "Critical (%)"
--[[Translation missing --]]
L["Crop X"] = "Crop X"
--[[Translation missing --]]
L["Crop Y"] = "Crop Y"
L["Crowd Controlled"] = "Sob efeito de C/C"
L["Crushing"] = "Esmagador"
--[[Translation missing --]]
L["C'thun"] = "C'thun"
--[[Translation missing --]]
L["Cumulated time used during profiling"] = "Cumulated time used during profiling"
--[[Translation missing --]]
L["Current Experience"] = "Current Experience"
--[[Translation missing --]]
L["Current Instance"] = "Current Instance"
--[[Translation missing --]]
L["Current Movement Speed (%)"] = "Current Movement Speed (%)"
--[[Translation missing --]]
L["Current Zone"] = "Current Zone"
--[[Translation missing --]]
L["Current Zone Group"] = "Current Zone Group"
L["Curse"] = "Maldição"
L["Custom"] = "Personalizado"
--[[Translation missing --]]
L["Custom Action"] = "Custom Action"
--[[Translation missing --]]
L["Custom Anchor"] = "Custom Anchor"
--[[Translation missing --]]
L["Custom Check"] = "Custom Check"
--[[Translation missing --]]
L["Custom Color"] = "Custom Color"
--[[Translation missing --]]
L["Custom Condition Code"] = "Custom Condition Code"
--[[Translation missing --]]
L["Custom Configuration"] = "Custom Configuration"
--[[Translation missing --]]
L["Custom Fade Animation"] = "Custom Fade Animation"
L["Custom Function"] = "Função personalizada"
--[[Translation missing --]]
L["Custom Grow"] = "Custom Grow"
--[[Translation missing --]]
L["Custom Sort"] = "Custom Sort"
--[[Translation missing --]]
L["Custom Text Function"] = "Custom Text Function"
--[[Translation missing --]]
L["Custom Trigger Combination"] = "Custom Trigger Combination"
--[[Translation missing --]]
L["Custom Variables"] = "Custom Variables"
L["Damage"] = "Dano"
L["Damage Shield"] = "Escudo de Dano"
L["Damage Shield Missed"] = "Escudo de dano falho"
L["Damage Split"] = "Dano dividido"
--[[Translation missing --]]
L["DBM Announce"] = "DBM Announce"
--[[Translation missing --]]
L["DBM Stage"] = "DBM Stage"
--[[Translation missing --]]
L["DBM Timer"] = "DBM Timer"
--[[Translation missing --]]
L["Dead"] = "Dead"
--[[Translation missing --]]
L["Debuff"] = "Debuff"
--[[Translation missing --]]
L["Debuff Class"] = "Debuff Class"
--[[Translation missing --]]
L["Debuff Class Icon"] = "Debuff Class Icon"
--[[Translation missing --]]
L["Debuff Type"] = "Debuff Type"
--[[Translation missing --]]
L["Debug Log contains more than 1000 entries"] = "Debug Log contains more than 1000 entries"
--[[Translation missing --]]
L["Debug Logging enabled"] = "Debug Logging enabled"
--[[Translation missing --]]
L["Debug Logging enabled for '%s'"] = "Debug Logging enabled for '%s'"
--[[Translation missing --]]
L["Defensive Stats"] = "Defensive Stats"
--[[Translation missing --]]
L["Deflect"] = "Deflect"
--[[Translation missing --]]
L["Delve"] = "Delve"
--[[Translation missing --]]
L["Desaturate"] = "Desaturate"
--[[Translation missing --]]
L["Desaturate Background"] = "Desaturate Background"
--[[Translation missing --]]
L["Desaturate Foreground"] = "Desaturate Foreground"
--[[Translation missing --]]
L["Descending"] = "Descending"
L["Description"] = "Descrição"
--[[Translation missing --]]
L["Dest Raid Mark"] = "Dest Raid Mark"
--[[Translation missing --]]
L["Destination Affiliation"] = "Destination Affiliation"
--[[Translation missing --]]
L["Destination GUID"] = "Destination GUID"
--[[Translation missing --]]
L["Destination Info"] = "Destination Info"
--[[Translation missing --]]
L["Destination Name"] = "Destination Name"
--[[Translation missing --]]
L["Destination NPC Id"] = "Destination NPC Id"
--[[Translation missing --]]
L["Destination Object Type"] = "Destination Object Type"
--[[Translation missing --]]
L["Destination Reaction"] = "Destination Reaction"
--[[Translation missing --]]
L["Destination Unit"] = "Destination Unit"
--[[Translation missing --]]
L["Destination unit's raid mark index"] = "Destination unit's raid mark index"
--[[Translation missing --]]
L["Destination unit's raid mark texture"] = "Destination unit's raid mark texture"
--[[Translation missing --]]
L["Difficulty"] = "Difficulty"
--[[Translation missing --]]
L["Disable Spell Known Check"] = "Disable Spell Known Check"
--[[Translation missing --]]
L["Disabled"] = "Disabled"
--[[Translation missing --]]
L["Disabled feature %q"] = "Disabled feature %q"
--[[Translation missing --]]
L["Disabled Spell Known Check"] = "Disabled Spell Known Check"
--[[Translation missing --]]
L["Disease"] = "Disease"
--[[Translation missing --]]
L["Dispel"] = "Dispel"
--[[Translation missing --]]
L["Dispel Failed"] = "Dispel Failed"
--[[Translation missing --]]
L["Display"] = "Display"
L["Distance"] = "Distância"
--[[Translation missing --]]
L["Do Not Disturb"] = "Do Not Disturb"
--[[Translation missing --]]
L["Dodge"] = "Dodge"
--[[Translation missing --]]
L["Dodge (%)"] = "Dodge (%)"
--[[Translation missing --]]
L["Down"] = "Down"
--[[Translation missing --]]
L["Down, then Centered Horizontal"] = "Down, then Centered Horizontal"
--[[Translation missing --]]
L["Down, then Left"] = "Down, then Left"
--[[Translation missing --]]
L["Down, then Right"] = "Down, then Right"
--[[Translation missing --]]
L["Dragonflight"] = "Dragonflight"
--[[Translation missing --]]
L["Drain"] = "Drain"
--[[Translation missing --]]
L["Dropdown Menu"] = "Dropdown Menu"
--[[Translation missing --]]
L["Dumping table"] = "Dumping table"
--[[Translation missing --]]
L["Dungeon (Heroic)"] = "Dungeon (Heroic)"
--[[Translation missing --]]
L["Dungeon (Mythic)"] = "Dungeon (Mythic)"
--[[Translation missing --]]
L["Dungeon (Mythic+)"] = "Dungeon (Mythic+)"
--[[Translation missing --]]
L["Dungeon (Normal)"] = "Dungeon (Normal)"
--[[Translation missing --]]
L["Dungeon (Timewalking)"] = "Dungeon (Timewalking)"
--[[Translation missing --]]
L["Durability Damage"] = "Durability Damage"
--[[Translation missing --]]
L["Durability Damage All"] = "Durability Damage All"
--[[Translation missing --]]
L["Duration"] = "Duration"
--[[Translation missing --]]
L["Duration Function"] = "Duration Function"
--[[Translation missing --]]
L["Duration Function (fallback state)"] = "Duration Function (fallback state)"
--[[Translation missing --]]
L["Ease In"] = "Ease In"
--[[Translation missing --]]
L["Ease In and Out"] = "Ease In and Out"
--[[Translation missing --]]
L["Ease Out"] = "Ease Out"
--[[Translation missing --]]
L["Ebonroc"] = "Ebonroc"
--[[Translation missing --]]
L["Edge"] = "Edge"
--[[Translation missing --]]
L["Edge of Madness"] = "Edge of Madness"
--[[Translation missing --]]
L["Effective Spell Id"] = "Effective Spell Id"
--[[Translation missing --]]
L["Elide"] = "Elide"
--[[Translation missing --]]
L["Elite"] = "Elite"
--[[Translation missing --]]
L["Emote"] = "Emote"
--[[Translation missing --]]
L["Empower Cast End"] = "Empower Cast End"
--[[Translation missing --]]
L["Empower Cast Interrupt"] = "Empower Cast Interrupt"
--[[Translation missing --]]
L["Empower Cast Start"] = "Empower Cast Start"
--[[Translation missing --]]
L["Empowered"] = "Empowered"
--[[Translation missing --]]
L["Empty"] = "Empty"
--[[Translation missing --]]
L["Enabled feature %q"] = "Enabled feature %q"
--[[Translation missing --]]
L["Enables (incorrect) round down of seconds, which was the previous default behavior."] = "Enables (incorrect) round down of seconds, which was the previous default behavior."
--[[Translation missing --]]
L["Enchant Applied"] = "Enchant Applied"
--[[Translation missing --]]
L["Enchant Found"] = "Enchant Found"
--[[Translation missing --]]
L["Enchant ID"] = "Enchant ID"
--[[Translation missing --]]
L["Enchant Missing"] = "Enchant Missing"
--[[Translation missing --]]
L["Enchant Name or ID"] = "Enchant Name or ID"
--[[Translation missing --]]
L["Enchant Removed"] = "Enchant Removed"
--[[Translation missing --]]
L["Enchanted"] = "Enchanted"
--[[Translation missing --]]
L["Encounter ID(s)"] = "Encounter ID(s)"
--[[Translation missing --]]
L["Energize"] = "Energize"
--[[Translation missing --]]
L["Enrage"] = "Enrage"
--[[Translation missing --]]
L["Enter a name or a spellId"] = "Enter a name or a spellId"
--[[Translation missing --]]
L["Entering"] = "Entering"
--[[Translation missing --]]
L["Entering/Leaving Combat"] = "Entering/Leaving Combat"
--[[Translation missing --]]
L["Entering/Leaving Encounter"] = "Entering/Leaving Encounter"
--[[Translation missing --]]
L["Entry Order"] = "Entry Order"
--[[Translation missing --]]
L["Environment Type"] = "Environment Type"
--[[Translation missing --]]
L["Environmental"] = "Environmental"
--[[Translation missing --]]
L["Equipment"] = "Equipment"
--[[Translation missing --]]
L["Equipment Slot"] = "Equipment Slot"
--[[Translation missing --]]
L["Equipped"] = "Equipped"
--[[Translation missing --]]
L["Error"] = "Error"
--[[Translation missing --]]
L[ [=[Error '%s' created a secure clone. We advise deleting the aura. For more information:
https://github.com/WeakAuras/WeakAuras2/wiki/Protected-Frames]=] ] = [=[Error '%s' created a secure clone. We advise deleting the aura. For more information:
https://github.com/WeakAuras/WeakAuras2/wiki/Protected-Frames]=]
--[[Translation missing --]]
L["Error decoding."] = "Error decoding."
--[[Translation missing --]]
L["Error decompressing"] = "Error decompressing"
--[[Translation missing --]]
L["Error decompressing. This doesn't look like a Musca Auras import."] = "Error decompressing. This doesn't look like a Musca Auras import."
--[[Translation missing --]]
L["Error deserializing"] = "Error deserializing"
--[[Translation missing --]]
L["Error Frame"] = "Error Frame"
--[[Translation missing --]]
L["ERROR in '%s' unknown or incompatible sub element type '%s'"] = "ERROR in '%s' unknown or incompatible sub element type '%s'"
--[[Translation missing --]]
L["Error in Aura '%s'"] = "Error in Aura '%s'"
--[[Translation missing --]]
L["Error not receiving display information from %s"] = "Error not receiving display information from %s"
--[[Translation missing --]]
L["Evade"] = "Evade"
L["Event"] = "Evento"
L["Event(s)"] = "Evento(s)"
L["Every Frame"] = "Todo Frame"
--[[Translation missing --]]
L["Every Frame (High CPU usage)"] = "Every Frame (High CPU usage)"
--[[Translation missing --]]
L["Exact Spell ID(s)"] = "Exact Spell ID(s)"
--[[Translation missing --]]
L["Execute Conditions"] = "Execute Conditions"
--[[Translation missing --]]
L["Experience (%)"] = "Experience (%)"
--[[Translation missing --]]
L["Extend Outside"] = "Extend Outside"
L["Extra Amount"] = "Quantidade Extra"
L["Extra Attacks"] = "Ataques Extras"
--[[Translation missing --]]
L["Extra Spell Id"] = "Extra Spell Id"
L["Extra Spell Name"] = "Nome da Magia Extra"
--[[Translation missing --]]
L["Faction"] = "Faction"
--[[Translation missing --]]
L["Faction Name"] = "Faction Name"
--[[Translation missing --]]
L["Faction Reputation"] = "Faction Reputation"
--[[Translation missing --]]
L["Fade Animation"] = "Fade Animation"
--[[Translation missing --]]
L["Fade In"] = "Fade In"
--[[Translation missing --]]
L["Fade Out"] = "Fade Out"
--[[Translation missing --]]
L["Fail Alert"] = "Fail Alert"
--[[Translation missing --]]
L["False"] = "False"
--[[Translation missing --]]
L["Fankriss the Unyielding"] = "Fankriss the Unyielding"
--[[Translation missing --]]
L["Feature %q is already disabled"] = "Feature %q is already disabled"
--[[Translation missing --]]
L["Feature %q is already enabled"] = "Feature %q is already enabled"
--[[Translation missing --]]
L["Fill Area"] = "Fill Area"
--[[Translation missing --]]
L["Filter messages with format <message>"] = "Filter messages with format <message>"
--[[Translation missing --]]
L["Fire Resistance"] = "Fire Resistance"
--[[Translation missing --]]
L["Firemaw"] = "Firemaw"
--[[Translation missing --]]
L["First"] = "First"
--[[Translation missing --]]
L["First Value of Tooltip Text"] = "First Value of Tooltip Text"
--[[Translation missing --]]
L["Fixed"] = "Fixed"
--[[Translation missing --]]
L["Fixed Names"] = "Fixed Names"
--[[Translation missing --]]
L["Fixed Size"] = "Fixed Size"
--[[Translation missing --]]
L["Flamegor"] = "Flamegor"
--[[Translation missing --]]
L["Flash"] = "Flash"
--[[Translation missing --]]
L["Flex Raid"] = "Flex Raid"
--[[Translation missing --]]
L["Flip"] = "Flip"
--[[Translation missing --]]
L["Floor"] = "Floor"
--[[Translation missing --]]
L["Follower Dungeon"] = "Follower Dungeon"
--[[Translation missing --]]
L["Font"] = "Font"
--[[Translation missing --]]
L["Font Size"] = "Font Size"
--[[Translation missing --]]
L["Forbidden function or table: %s"] = "Forbidden function or table: %s"
--[[Translation missing --]]
L["Foreground"] = "Foreground"
--[[Translation missing --]]
L["Foreground Color"] = "Foreground Color"
--[[Translation missing --]]
L["Form"] = "Form"
--[[Translation missing --]]
L["Format"] = "Format"
--[[Translation missing --]]
L["Format Gold"] = "Format Gold"
--[[Translation missing --]]
L["Formats |cFFFFCC00%unit|r"] = "Formats |cFFFFCC00%unit|r"
--[[Translation missing --]]
L["Formats Player's |cFFFFCC00%guid|r"] = "Formats Player's |cFFFFCC00%guid|r"
--[[Translation missing --]]
L["Forward"] = "Forward"
--[[Translation missing --]]
L["Forward, Reverse Loop"] = "Forward, Reverse Loop"
--[[Translation missing --]]
L["Fourth Value of Tooltip Text"] = "Fourth Value of Tooltip Text"
--[[Translation missing --]]
L["Frame Selector"] = "Frame Selector"
--[[Translation missing --]]
L["Frequency"] = "Frequency"
L["Friendly"] = "Amigável"
L["Friendly Fire"] = "Fogo Amigo"
--[[Translation missing --]]
L["Frost"] = "Frost"
--[[Translation missing --]]
L["Frost Resistance"] = "Frost Resistance"
--[[Translation missing --]]
L["Full"] = "Full"
--[[Translation missing --]]
L["Full Region"] = "Full Region"
--[[Translation missing --]]
L["Full/Empty"] = "Full/Empty"
--[[Translation missing --]]
L["Gahz'ranka"] = "Gahz'ranka"
--[[Translation missing --]]
L["Gained"] = "Gained"
--[[Translation missing --]]
L["Garr"] = "Garr"
--[[Translation missing --]]
L["Gehennas"] = "Gehennas"
--[[Translation missing --]]
L["General"] = "General"
--[[Translation missing --]]
L["General Rajaxx"] = "General Rajaxx"
--[[Translation missing --]]
L["GetNameAndIcon Function (fallback state)"] = "GetNameAndIcon Function (fallback state)"
--[[Translation missing --]]
L["Glancing"] = "Glancing"
--[[Translation missing --]]
L["Global Cooldown"] = "Global Cooldown"
--[[Translation missing --]]
L["Glow"] = "Glow"
--[[Translation missing --]]
L["Glow External Element"] = "Glow External Element"
--[[Translation missing --]]
L["Gluth"] = "Gluth"
--[[Translation missing --]]
L["Gold"] = "Gold"
--[[Translation missing --]]
L["Golemagg the Incinerator"] = "Golemagg the Incinerator"
--[[Translation missing --]]
L["Gothik the Harvester"] = "Gothik the Harvester"
--[[Translation missing --]]
L["Gradient"] = "Gradient"
--[[Translation missing --]]
L["Gradient Enabled"] = "Gradient Enabled"
--[[Translation missing --]]
L["Gradient End"] = "Gradient End"
--[[Translation missing --]]
L["Gradient Orientation"] = "Gradient Orientation"
--[[Translation missing --]]
L["Gradient Pulse"] = "Gradient Pulse"
--[[Translation missing --]]
L["Grand Widow Faerlina"] = "Grand Widow Faerlina"
--[[Translation missing --]]
L["Grid"] = "Grid"
--[[Translation missing --]]
L["Grobbulus"] = "Grobbulus"
L["Group"] = "Grupo"
--[[Translation missing --]]
L["Group Arrangement"] = "Group Arrangement"
--[[Translation missing --]]
L["Group Leader/Assist"] = "Group Leader/Assist"
--[[Translation missing --]]
L["Group Size"] = "Group Size"
--[[Translation missing --]]
L["Group Type"] = "Group Type"
--[[Translation missing --]]
L["Grow"] = "Grow"
--[[Translation missing --]]
L["GTFO Alert"] = "GTFO Alert"
--[[Translation missing --]]
L["Guardian"] = "Guardian"
--[[Translation missing --]]
L["Guild"] = "Guild"
--[[Translation missing --]]
L["Hakkar"] = "Hakkar"
--[[Translation missing --]]
L["Hardcore"] = "Hardcore"
L["Has Target"] = "Tem Alvo"
--[[Translation missing --]]
L["HasPet"] = "HasPet"
--[[Translation missing --]]
L["Haste (%)"] = "Haste (%)"
--[[Translation missing --]]
L["Heal"] = "Heal"
--[[Translation missing --]]
L["Heal Absorbed"] = "Heal Absorbed"
--[[Translation missing --]]
L["Health"] = "Health"
--[[Translation missing --]]
L["Health (%)"] = "Health (%)"
--[[Translation missing --]]
L["Health Deficit"] = "Health Deficit"
--[[Translation missing --]]
L["Heigan the Unclean"] = "Heigan the Unclean"
--[[Translation missing --]]
L["Height"] = "Height"
--[[Translation missing --]]
L["Heroic Party"] = "Heroic Party"
--[[Translation missing --]]
L["Hide"] = "Hide"
--[[Translation missing --]]
L["Hide 0 cooldowns"] = "Hide 0 cooldowns"
--[[Translation missing --]]
L["Hide Timer Text"] = "Hide Timer Text"
--[[Translation missing --]]
L["High Damage"] = "High Damage"
--[[Translation missing --]]
L["High Priest Thekal"] = "High Priest Thekal"
--[[Translation missing --]]
L["High Priest Venoxis"] = "High Priest Venoxis"
--[[Translation missing --]]
L["High Priestess Arlokk"] = "High Priestess Arlokk"
--[[Translation missing --]]
L["High Priestess Jeklik"] = "High Priestess Jeklik"
--[[Translation missing --]]
L["High Priestess Mar'li"] = "High Priestess Mar'li"
--[[Translation missing --]]
L["Higher Than Tank"] = "Higher Than Tank"
--[[Translation missing --]]
L["Highest Spell Id"] = "Highest Spell Id"
--[[Translation missing --]]
L["Holy Resistance"] = "Holy Resistance"
L["Horde"] = "Horda"
--[[Translation missing --]]
L["Horizontal"] = "Horizontal"
--[[Translation missing --]]
L["Hostile"] = "Hostile"
--[[Translation missing --]]
L["Hostility"] = "Hostility"
L["Humanoid"] = "Humanoide"
--[[Translation missing --]]
L["Hybrid"] = "Hybrid"
--[[Translation missing --]]
L["Icon"] = "Ícone"
--[[Translation missing --]]
L["Icon Function"] = "Icon Function"
--[[Translation missing --]]
L["Icon Function (fallback state)"] = "Icon Function (fallback state)"
--[[Translation missing --]]
L["Id"] = "Id"
--[[Translation missing --]]
L["ID"] = "ID"
--[[Translation missing --]]
L["If you require additional assistance, please open a ticket on GitHub or visit our Discord at https://discord.gg/weakauras!"] = "If you require additional assistance, please open a ticket on GitHub or visit our Discord at https://discord.gg/weakauras!"
--[[Translation missing --]]
L["Ignore Dead"] = "Ignore Dead"
--[[Translation missing --]]
L["Ignore Disconnected"] = "Ignore Disconnected"
--[[Translation missing --]]
L["Ignore Rune CD"] = "Ignore Rune CD"
--[[Translation missing --]]
L["Ignore Rune CDs"] = "Ignore Rune CDs"
--[[Translation missing --]]
L["Ignore Self"] = "Ignore Self"
--[[Translation missing --]]
L["Ignore Spell Cooldown/Charges"] = "Ignore Spell Cooldown/Charges"
--[[Translation missing --]]
L["Ignore Spell Override"] = "Ignore Spell Override"
--[[Translation missing --]]
L["Immune"] = "Imune"
L["Important"] = "Importante"
--[[Translation missing --]]
L["Importing will start after combat ends."] = "Importing will start after combat ends."
L["In Combat"] = "Em Combate"
L["In Encounter"] = "Em Encontro"
L["In Group"] = "Em Grupo"
--[[Translation missing --]]
L["In Party"] = "In Party"
L["In Raid"] = "Em Raide"
--[[Translation missing --]]
L["In Range"] = "In Range"
--[[Translation missing --]]
L["Include Bank"] = "Include Bank"
--[[Translation missing --]]
L["Include Charges"] = "Include Charges"
--[[Translation missing --]]
L["Include Pets"] = "Include Pets"
--[[Translation missing --]]
L["Incoming Heal"] = "Incoming Heal"
--[[Translation missing --]]
L["Increase Precision Below"] = "Increase Precision Below"
--[[Translation missing --]]
L["Increases by one per stage or intermission."] = "Increases by one per stage or intermission."
--[[Translation missing --]]
L["Information"] = "Information"
--[[Translation missing --]]
L["Inherited"] = "Inherited"
--[[Translation missing --]]
L["Instakill"] = "Instakill"
--[[Translation missing --]]
L["Install the addons BugSack and BugGrabber for detailed error logs."] = "Install the addons BugSack and BugGrabber for detailed error logs."
--[[Translation missing --]]
L["Instance"] = "Instance"
--[[Translation missing --]]
L["Instance Id"] = "Instance Id"
--[[Translation missing --]]
L["Instance ID"] = "Instance ID"
--[[Translation missing --]]
L["Instance Info"] = "Instance Info"
--[[Translation missing --]]
L["Instance Name"] = "Instance Name"
--[[Translation missing --]]
L["Instance Size Type"] = "Instance Size Type"
--[[Translation missing --]]
L["Instance Type"] = "Instance Type"
--[[Translation missing --]]
L["Instructor Razuvious"] = "Instructor Razuvious"
--[[Translation missing --]]
L["Insufficient Resources"] = "Insufficient Resources"
--[[Translation missing --]]
L["Intellect"] = "Intellect"
--[[Translation missing --]]
L["Interrupt"] = "Interrupt"
--[[Translation missing --]]
L["Interrupt School"] = "Interrupt School"
--[[Translation missing --]]
L["Interrupted School Text"] = "Interrupted School Text"
--[[Translation missing --]]
L["Interruptible"] = "Interruptible"
--[[Translation missing --]]
L["Inverse"] = "Inverse"
--[[Translation missing --]]
L["Inverse Pet Behavior"] = "Inverse Pet Behavior"
--[[Translation missing --]]
L["Is Away from Keyboard"] = "Is Away from Keyboard"
--[[Translation missing --]]
L["Is Exactly"] = "Is Exactly"
--[[Translation missing --]]
L["Is Moving"] = "Is Moving"
--[[Translation missing --]]
L["Is Off Hand"] = "Is Off Hand"
--[[Translation missing --]]
L["Is Paused"] = "Is Paused"
--[[Translation missing --]]
L["is useable"] = "is useable"
--[[Translation missing --]]
L["Island Expedition (Heroic)"] = "Island Expedition (Heroic)"
--[[Translation missing --]]
L["Island Expedition (Mythic)"] = "Island Expedition (Mythic)"
--[[Translation missing --]]
L["Island Expedition (Normal)"] = "Island Expedition (Normal)"
--[[Translation missing --]]
L["Island Expeditions (PvP)"] = "Island Expeditions (PvP)"
L["Item"] = "Item"
--[[Translation missing --]]
L["Item Bonus Id"] = "Item Bonus Id"
--[[Translation missing --]]
L["Item Bonus Id Equipped"] = "Item Bonus Id Equipped"
L["Item Count"] = "Contagem de Item"
L["Item Equipped"] = "Item Equipado"
--[[Translation missing --]]
L["Item Id"] = "Item Id"
--[[Translation missing --]]
L["Item in Range"] = "Item in Range"
--[[Translation missing --]]
L["Item Name"] = "Item Name"
--[[Translation missing --]]
L["Item Set Equipped"] = "Item Set Equipped"
--[[Translation missing --]]
L["Item Set Id"] = "Item Set Id"
--[[Translation missing --]]
L["Item Slot"] = "Item Slot"
--[[Translation missing --]]
L["Item Slot String"] = "Item Slot String"
--[[Translation missing --]]
L["Item Type"] = "Item Type"
L["Item Type Equipped"] = "Tipo de Item Equipado"
--[[Translation missing --]]
L["ItemId"] = "ItemId"
--[[Translation missing --]]
L["Jin'do the Hexxer"] = "Jin'do the Hexxer"
--[[Translation missing --]]
L["Journal Stage"] = "Journal Stage"
--[[Translation missing --]]
L["Kazzak"] = "Kazzak"
--[[Translation missing --]]
L["Keep Inside"] = "Keep Inside"
--[[Translation missing --]]
L["Kel'Thuzad"] = "Kel'Thuzad"
--[[Translation missing --]]
L["Kurinnaxx"] = "Kurinnaxx"
--[[Translation missing --]]
L["Large"] = "Large"
--[[Translation missing --]]
L["Latency"] = "Latency"
--[[Translation missing --]]
L["Leader"] = "Leader"
--[[Translation missing --]]
L["Least remaining time"] = "Least remaining time"
--[[Translation missing --]]
L["Leaving"] = "Leaving"
L["Leech"] = "Sugar"
L["Left"] = "Esquerda"
L["Left to Right"] = "Da esquerda para direita"
--[[Translation missing --]]
L["Left, then Centered Vertical"] = "Left, then Centered Vertical"
--[[Translation missing --]]
L["Left, then Down"] = "Left, then Down"
--[[Translation missing --]]
L["Left, then Up"] = "Left, then Up"
--[[Translation missing --]]
L["Legacy Looking for Raid"] = "Legacy Looking for Raid"
--[[Translation missing --]]
L["Legacy RGB Gradient"] = "Legacy RGB Gradient"
--[[Translation missing --]]
L["Legacy RGB Gradient Pulse"] = "Legacy RGB Gradient Pulse"
--[[Translation missing --]]
L["Legion"] = "Legion"
--[[Translation missing --]]
L["Length"] = "Length"
--[[Translation missing --]]
L["Level"] = "Level"
--[[Translation missing --]]
L["LibSharedMedia"] = "LibSharedMedia"
--[[Translation missing --]]
L["Lillian Voss"] = "Lillian Voss"
--[[Translation missing --]]
L["Limited"] = "Limited"
--[[Translation missing --]]
L["Linear Texture"] = "Linear Texture"
--[[Translation missing --]]
L["Lines & Particles"] = "Lines & Particles"
--[[Translation missing --]]
L["Load Conditions"] = "Load Conditions"
--[[Translation missing --]]
L["Loatheb"] = "Loatheb"
--[[Translation missing --]]
L["Location"] = "Location"
--[[Translation missing --]]
L["Looking for Raid"] = "Looking for Raid"
--[[Translation missing --]]
L["Loop"] = "Loop"
--[[Translation missing --]]
L["Loot"] = "Loot"
--[[Translation missing --]]
L["Lorewalking"] = "Lorewalking"
--[[Translation missing --]]
L["Lost"] = "Lost"
--[[Translation missing --]]
L["Low Damage"] = "Low Damage"
L["Lower Than Tank"] = "Menor que o tanque"
--[[Translation missing --]]
L["Lowest Spell Id"] = "Lowest Spell Id"
--[[Translation missing --]]
L["Lua error"] = "Lua error"
--[[Translation missing --]]
L["Lua error in Aura '%s': %s"] = "Lua error in Aura '%s': %s"
--[[Translation missing --]]
L["Lucifron"] = "Lucifron"
--[[Translation missing --]]
L["Maexxna"] = "Maexxna"
L["Magic"] = "Mágico"
--[[Translation missing --]]
L["Magmadar"] = "Magmadar"
--[[Translation missing --]]
L["Majordomo Executus"] = "Majordomo Executus"
--[[Translation missing --]]
L["Malformed Musca Auras link"] = "Malformed Musca Auras link"
--[[Translation missing --]]
L["Manual"] = "Manual"
--[[Translation missing --]]
L["Manual Icon"] = "Manual Icon"
--[[Translation missing --]]
L["Manual Rotation"] = "Manual Rotation"
--[[Translation missing --]]
L["Marked First"] = "Marked First"
--[[Translation missing --]]
L["Marked Last"] = "Marked Last"
--[[Translation missing --]]
L["Mason"] = "Mason"
L["Master"] = "Mestre"
--[[Translation missing --]]
L["Match Count"] = "Match Count"
--[[Translation missing --]]
L["Match Count per Unit"] = "Match Count per Unit"
--[[Translation missing --]]
L["Matches (Pattern)"] = "Matches (Pattern)"
--[[Translation missing --]]
L[ [=[Matches stage number of encounter journal.
Intermissions are .5
E.g. 1;2;1;2;2.5;3]=] ] = [=[Matches stage number of encounter journal.
Intermissions are .5
E.g. 1;2;1;2;2.5;3]=]
--[[Translation missing --]]
L["Max Char "] = "Max Char "
--[[Translation missing --]]
L["Max Char"] = "Max Char"
--[[Translation missing --]]
L["Max Charges"] = "Max Charges"
--[[Translation missing --]]
L["Max Health"] = "Max Health"
--[[Translation missing --]]
L["Max Power"] = "Max Power"
--[[Translation missing --]]
L["Maximum Estimate"] = "Maximum Estimate"
--[[Translation missing --]]
L["Maximum Progress"] = "Maximum Progress"
--[[Translation missing --]]
L["Maximum time used on a single frame"] = "Maximum time used on a single frame"
--[[Translation missing --]]
L["Media"] = "Media"
--[[Translation missing --]]
L["Medium"] = "Medium"
--[[Translation missing --]]
L["Melee"] = "Melee"
L["Message"] = "Mensagem"
L["Message Type"] = "Tipo de mensagem"
L["Message type:"] = "Tipo de mensagem:"
--[[Translation missing --]]
L["Meta Data"] = "Meta Data"
--[[Translation missing --]]
L["Mine"] = "Mine"
--[[Translation missing --]]
L["Minimum Estimate"] = "Minimum Estimate"
--[[Translation missing --]]
L["Minimum Progress"] = "Minimum Progress"
--[[Translation missing --]]
L["Minus (Small Nameplate)"] = "Minus (Small Nameplate)"
--[[Translation missing --]]
L["Mirror"] = "Mirror"
--[[Translation missing --]]
L["Miscellaneous"] = "Miscellaneous"
L["Miss"] = "Falha"
L["Miss Type"] = "Tipo de falha"
L["Missed"] = "Falho"
L["Missing"] = "Faltando"
--[[Translation missing --]]
L["Mists of Pandaria"] = "Mists of Pandaria"
--[[Translation missing --]]
L["Moam"] = "Moam"
--[[Translation missing --]]
L["Model"] = "Model"
--[[Translation missing --]]
L["Modern Blizzard (1h 3m | 3m 7s | 10s | 2.4)"] = "Modern Blizzard (1h 3m | 3m 7s | 10s | 2.4)"
--[[Translation missing --]]
L["Modernize"] = "Modernize"
--[[Translation missing --]]
L["Molten Core"] = "Molten Core"
--[[Translation missing --]]
L["Money"] = "Money"
--[[Translation missing --]]
L["Monochrome"] = "Monochrome"
--[[Translation missing --]]
L["Monochrome Outline"] = "Monochrome Outline"
--[[Translation missing --]]
L["Monochrome Thick Outline"] = "Monochrome Thick Outline"
--[[Translation missing --]]
L["Monster Emote"] = "Monster Emote"
--[[Translation missing --]]
L["Monster Party"] = "Monster Party"
--[[Translation missing --]]
L["Monster Say"] = "Monster Say"
--[[Translation missing --]]
L["Monster Whisper"] = "Monster Whisper"
L["Monster Yell"] = "Grito do monstro"
--[[Translation missing --]]
L["Most remaining time"] = "Most remaining time"
--[[Translation missing --]]
L["Mounted"] = "Montado"
--[[Translation missing --]]
L["Mouse Cursor"] = "Mouse Cursor"
L["Multi-target"] = "Multi-alvo"
--[[Translation missing --]]
L["Mythic Keystone"] = "Mythic Keystone"
--[[Translation missing --]]
L["Name"] = "Nome"
--[[Translation missing --]]
L["Name Function"] = "Name Function"
--[[Translation missing --]]
L["Name Function (fallback state)"] = "Name Function (fallback state)"
--[[Translation missing --]]
L["Name of Caster's Target"] = "Name of Caster's Target"
--[[Translation missing --]]
L["Name of the (sub-)zone currently shown above the minimap."] = "Name of the (sub-)zone currently shown above the minimap."
--[[Translation missing --]]
L["Name(s)"] = "Name(s)"
--[[Translation missing --]]
L["Name/Realm of Caster's Target"] = "Name/Realm of Caster's Target"
--[[Translation missing --]]
L["Nameplate"] = "Nameplate"
--[[Translation missing --]]
L["Nameplates"] = "Nameplates"
--[[Translation missing --]]
L["Names of affected Players"] = "Names of affected Players"
--[[Translation missing --]]
L["Names of unaffected Players"] = "Names of unaffected Players"
--[[Translation missing --]]
L["Nature Resistance"] = "Nature Resistance"
--[[Translation missing --]]
L["Naxxramas"] = "Naxxramas"
--[[Translation missing --]]
L["Nefarian"] = "Nefarian"
--[[Translation missing --]]
L["Neutral"] = "Neutro"
L["Never"] = "Nunca"
--[[Translation missing --]]
L["Next Combat"] = "Next Combat"
--[[Translation missing --]]
L["Next Encounter"] = "Next Encounter"
--[[Translation missing --]]
L[ [=[No active boss mod addon detected.

Note: This trigger will use BigWigs or DBM, in that order if both are installed.]=] ] = [=[No active boss mod addon detected.

Note: This trigger will use BigWigs or DBM, in that order if both are installed.]=]
--[[Translation missing --]]
L["No Extend"] = "No Extend"
L["No Instance"] = "Fora da instância"
--[[Translation missing --]]
L["No Profiling information saved."] = "No Profiling information saved."
--[[Translation missing --]]
L["No Progress Information available."] = "No Progress Information available."
L["None"] = "Nenhum"
--[[Translation missing --]]
L["Non-player Character"] = "Non-player Character"
L["Normal"] = "Normal"
--[[Translation missing --]]
L["Normal Party"] = "Normal Party"
--[[Translation missing --]]
L["Not in Group"] = "Not in Group"
--[[Translation missing --]]
L["Not in Smart Group"] = "Not in Smart Group"
--[[Translation missing --]]
L["Not on Cooldown"] = "Not on Cooldown"
--[[Translation missing --]]
L["Not On Threat Table"] = "Not On Threat Table"
--[[Translation missing --]]
L["Note: Due to how complicated the swing timer behavior is and the lack of APIs from Blizzard, results are inaccurate in edge cases."] = "Note: Due to how complicated the swing timer behavior is and the lack of APIs from Blizzard, results are inaccurate in edge cases."
--[[Translation missing --]]
L["Note: This trigger internally stores the shapeshift position, and thus is incompatible with learning stances on the fly, like e.g. the Gladiator Rune."] = "Note: This trigger internally stores the shapeshift position, and thus is incompatible with learning stances on the fly, like e.g. the Gladiator Rune."
--[[Translation missing --]]
L["Note: This trigger type estimates the range to the hitbox of a unit. The actual range of friendly players is usually 3 yards more than the estimate. Range checking capabilities depend on your current class and known abilities as well as the type of unit being checked. Some of the ranges may also not work with certain NPCs.|n|n|cFFAAFFAAFriendly Units:|r %s|n|cFFFFAAAAHarmful Units:|r %s|n|cFFAAAAFFMiscellanous Units:|r %s"] = "Note: This trigger type estimates the range to the hitbox of a unit. The actual range of friendly players is usually 3 yards more than the estimate. Range checking capabilities depend on your current class and known abilities as well as the type of unit being checked. Some of the ranges may also not work with certain NPCs.|n|n|cFFAAFFAAFriendly Units:|r %s|n|cFFFFAAAAHarmful Units:|r %s|n|cFFAAAAFFMiscellanous Units:|r %s"
--[[Translation missing --]]
L["Noth the Plaguebringer"] = "Noth the Plaguebringer"
--[[Translation missing --]]
L["NPC"] = "NPC"
--[[Translation missing --]]
L["Npc ID"] = "Npc ID"
L["Number"] = "Número"
L["Number Affected"] = "Número Afetado"
L["Object"] = "Objeto"
--[[Translation missing --]]
L[ [=[Occurrence of the event
Can be a range of values
Can have multiple values separated by a comma or a space

Examples:
2nd 5th and 6th events: 2, 5, 6
2nd to 6th: 2-6
every 2 events: /2
every 3 events starting from 2nd: 2/3
every 3 events starting from 2nd and ending at 11th: 2-11/3

Works only if Boss Mod addon show counter]=] ] = [=[Occurrence of the event
Can be a range of values
Can have multiple values separated by a comma or a space

Examples:
2nd 5th and 6th events: 2, 5, 6
2nd to 6th: 2-6
every 2 events: /2
every 3 events starting from 2nd: 2/3
every 3 events starting from 2nd and ending at 11th: 2-11/3

Works only if Boss Mod addon show counter]=]
--[[Translation missing --]]
L[ [=[Occurrence of the event, reset when aura is unloaded
Can be a range of values
Can have multiple values separated by a comma or a space

Examples:
2nd 5th and 6th events: 2, 5, 6
2nd to 6th: 2-6
every 2 events: /2
every 3 events starting from 2nd: 2/3
every 3 events starting from 2nd and ending at 11th: 2-11/3

Only if BigWigs shows it on it's bar]=] ] = [=[Occurrence of the event, reset when aura is unloaded
Can be a range of values
Can have multiple values separated by a comma or a space

Examples:
2nd 5th and 6th events: 2, 5, 6
2nd to 6th: 2-6
every 2 events: /2
every 3 events starting from 2nd: 2/3
every 3 events starting from 2nd and ending at 11th: 2-11/3

Only if BigWigs shows it on it's bar]=]
--[[Translation missing --]]
L[ [=[Occurrence of the event, reset when aura is unloaded
Can be a range of values
Can have multiple values separated by a comma or a space

Examples:
2nd 5th and 6th events: 2, 5, 6
2nd to 6th: 2-6
every 2 events: /2
every 3 events starting from 2nd: 2/3
every 3 events starting from 2nd and ending at 11th: 2-11/3

Only if DBM shows it on it's bar]=] ] = [=[Occurrence of the event, reset when aura is unloaded
Can be a range of values
Can have multiple values separated by a comma or a space

Examples:
2nd 5th and 6th events: 2, 5, 6
2nd to 6th: 2-6
every 2 events: /2
every 3 events starting from 2nd: 2/3
every 3 events starting from 2nd and ending at 11th: 2-11/3

Only if DBM shows it on it's bar]=]
L["Officer"] = "Oficial"
--[[Translation missing --]]
L["Offset from progress"] = "Offset from progress"
--[[Translation missing --]]
L["Offset Timer"] = "Offset Timer"
--[[Translation missing --]]
L["Old Blizzard (2h | 3m | 10s | 2.4)"] = "Old Blizzard (2h | 3m | 10s | 2.4)"
--[[Translation missing --]]
L["On Cooldown"] = "On Cooldown"
--[[Translation missing --]]
L["On Taxi"] = "On Taxi"
--[[Translation missing --]]
L["Only if on a different realm"] = "Only if on a different realm"
--[[Translation missing --]]
L["Only if Primary"] = "Only if Primary"
--[[Translation missing --]]
L["Onyxia"] = "Onyxia"
--[[Translation missing --]]
L["Opaque"] = "Opaque"
--[[Translation missing --]]
L["Option Group"] = "Option Group"
--[[Translation missing --]]
L["Options could not be loaded, the addon is %s"] = "Options could not be loaded, the addon is %s"
--[[Translation missing --]]
L["Options will finish loading after combat ends."] = "Options will finish loading after combat ends."
--[[Translation missing --]]
L["Options will open after the login process has completed."] = "Options will open after the login process has completed."
--[[Translation missing --]]
L["Or Talent"] = "Or Talent"
L["Orbit"] = "Órbita"
--[[Translation missing --]]
L["Orientation"] = "Orientation"
--[[Translation missing --]]
L["Ossirian the Unscarred"] = "Ossirian the Unscarred"
--[[Translation missing --]]
L["Other"] = "Other"
--[[Translation missing --]]
L["Other Addons"] = "Other Addons"
--[[Translation missing --]]
L["Other Events"] = "Other Events"
--[[Translation missing --]]
L["Ouro"] = "Ouro"
--[[Translation missing --]]
L["Outline"] = "Outline"
--[[Translation missing --]]
L["Over Energize"] = "Over Energize"
L["Overhealing"] = "Sobrecura"
L["Overkill"] = "Sobreassassinato"
--[[Translation missing --]]
L["Overlay %s"] = "Overlay %s"
--[[Translation missing --]]
L["Overlay Cost of Casts"] = "Overlay Cost of Casts"
--[[Translation missing --]]
L["Overlay Latency"] = "Overlay Latency"
--[[Translation missing --]]
L["Pad"] = "Pad"
--[[Translation missing --]]
L["Pad Mode"] = "Pad Mode"
--[[Translation missing --]]
L["Pad to"] = "Pad to"
--[[Translation missing --]]
L["Parent Frame"] = "Parent Frame"
--[[Translation missing --]]
L["Parent Zone"] = "Parent Zone"
L["Parry"] = "Aparar"
--[[Translation missing --]]
L["Parry (%)"] = "Parry (%)"
L["Party"] = "Grupo"
L["Party Kill"] = "Assassinato do grupo"
--[[Translation missing --]]
L["Patchwerk"] = "Patchwerk"
--[[Translation missing --]]
L["Path of Ascension: Courage"] = "Path of Ascension: Courage"
--[[Translation missing --]]
L["Path of Ascension: Humility"] = "Path of Ascension: Humility"
--[[Translation missing --]]
L["Path of Ascension: Loyalty"] = "Path of Ascension: Loyalty"
--[[Translation missing --]]
L["Path of Ascension: Wisdom"] = "Path of Ascension: Wisdom"
L["Paused"] = "Pausado"
L["Periodic Spell"] = "Feitiço periódico"
--[[Translation missing --]]
L["Personal Resource Display"] = "Personal Resource Display"
L["Pet"] = "Assistente"
--[[Translation missing --]]
L["Pet Behavior"] = "Pet Behavior"
--[[Translation missing --]]
L["Pet Specialization"] = "Pet Specialization"
--[[Translation missing --]]
L["Pet Spell"] = "Pet Spell"
--[[Translation missing --]]
L["Pets only"] = "Pets only"
--[[Translation missing --]]
L["Phase"] = "Phase"
--[[Translation missing --]]
L["Pixel Glow"] = "Pixel Glow"
--[[Translation missing --]]
L["Placement"] = "Placement"
--[[Translation missing --]]
L["Placement %i"] = "Placement %i"
--[[Translation missing --]]
L["Placement Mode"] = "Placement Mode"
--[[Translation missing --]]
L["Play"] = "Play"
L["Player"] = "Jogador"
L["Player Character"] = "Personagem do Jogador"
L["Player Class"] = "Classe do Jogador"
--[[Translation missing --]]
L["Player Experience"] = "Player Experience"
--[[Translation missing --]]
L["Player Faction"] = "Player Faction"
L["Player Level"] = "Nível do Jogador"
--[[Translation missing --]]
L["Player Location ID(s)"] = "Player Location ID(s)"
--[[Translation missing --]]
L["Player Money"] = "Player Money"
L["Player Name/Realm"] = "Nome do Jogador/Reino"
--[[Translation missing --]]
L["Player Race"] = "Player Race"
L["Player(s) Affected"] = "Jogado(res) afetados"
L["Player(s) Not Affected"] = "Jogado(res) não afetados"
--[[Translation missing --]]
L["Player/Unit Info"] = "Player/Unit Info"
--[[Translation missing --]]
L["Players and Pets"] = "Players and Pets"
L["Poison"] = "Veneno"
L["Power"] = "Poder"
L["Power (%)"] = "Poder (%)"
--[[Translation missing --]]
L["Power Deficit"] = "Power Deficit"
L["Power Type"] = "Tipo de Poder"
--[[Translation missing --]]
L["Precision"] = "Precision"
L["Preset"] = "Predefinido"
--[[Translation missing --]]
L["Primary Stats"] = "Primary Stats"
--[[Translation missing --]]
L["Princess Huhuran"] = "Princess Huhuran"
--[[Translation missing --]]
L["Print Profiling Results"] = "Print Profiling Results"
--[[Translation missing --]]
L["Proc Glow"] = "Proc Glow"
--[[Translation missing --]]
L["Profiling already started."] = "Profiling already started."
--[[Translation missing --]]
L["Profiling automatically started."] = "Profiling automatically started."
--[[Translation missing --]]
L["Profiling not running."] = "Profiling not running."
--[[Translation missing --]]
L["Profiling started."] = "Profiling started."
--[[Translation missing --]]
L["Profiling started. It will end automatically in %d seconds"] = "Profiling started. It will end automatically in %d seconds"
--[[Translation missing --]]
L["Profiling still running, stop before trying to print."] = "Profiling still running, stop before trying to print."
--[[Translation missing --]]
L["Profiling stopped."] = "Profiling stopped."
--[[Translation missing --]]
L["Progress"] = "Progress"
--[[Translation missing --]]
L["Progress Source"] = "Progress Source"
--[[Translation missing --]]
L["Progress Total"] = "Progress Total"
--[[Translation missing --]]
L["Progress Value"] = "Progress Value"
--[[Translation missing --]]
L["Pull"] = "Pull"
L["Pulse"] = "Pulsar"
L["PvP Flagged"] = "Marcado para JxJ"
--[[Translation missing --]]
L["PvP Mode Active"] = "PvP Mode Active"
--[[Translation missing --]]
L["Quest Party"] = "Quest Party"
--[[Translation missing --]]
L["Queued Action"] = "Queued Action"
L["Radius"] = "Raio"
--[[Translation missing --]]
L["Ragnaros"] = "Ragnaros"
L["Raid"] = "Raide"
L["Raid (Heroic)"] = "Raide (Heroica)"
L["Raid (Mythic)"] = "Raide (Mítica)"
L["Raid (Normal)"] = "Raide (Normal)"
L["Raid (Timewalking)"] = "Raide (Caminhada Temporal)"
--[[Translation missing --]]
L["Raid Mark"] = "Raid Mark"
--[[Translation missing --]]
L["Raid Mark Icon"] = "Raid Mark Icon"
--[[Translation missing --]]
L["Raid Role"] = "Raid Role"
L["Raid Warning"] = "Aviso de raide"
--[[Translation missing --]]
L["Range"] = "Alcance"
--[[Translation missing --]]
L["Range Check"] = "Range Check"
--[[Translation missing --]]
L["Ranged"] = "Ranged"
--[[Translation missing --]]
L["Rank"] = "Rank"
--[[Translation missing --]]
L["Rare"] = "Rare"
--[[Translation missing --]]
L["Rare Elite"] = "Rare Elite"
--[[Translation missing --]]
L["Rated Arena"] = "Rated Arena"
--[[Translation missing --]]
L["Rated Battleground"] = "Rated Battleground"
--[[Translation missing --]]
L["Raw Threat Percent"] = "Raw Threat Percent"
--[[Translation missing --]]
L["Razorgore the Untamed"] = "Razorgore the Untamed"
--[[Translation missing --]]
L["Ready Check"] = "Ready Check"
--[[Translation missing --]]
L["Realm"] = "Realm"
--[[Translation missing --]]
L["Realm Name"] = "Realm Name"
--[[Translation missing --]]
L["Realm of Caster's Target"] = "Realm of Caster's Target"
--[[Translation missing --]]
L["Reborn Council"] = "Reborn Council"
--[[Translation missing --]]
L["Receiving %s Bytes"] = "Receiving %s Bytes"
--[[Translation missing --]]
L["Receiving display information"] = "Receiving display information"
L["Reflect"] = "Refletir"
--[[Translation missing --]]
L["Region type %s not supported"] = "Region type %s not supported"
L["Relative"] = "Relativo"
--[[Translation missing --]]
L["Relative X-Offset"] = "Relative X-Offset"
--[[Translation missing --]]
L["Relative Y-Offset"] = "Relative Y-Offset"
--[[Translation missing --]]
L["Remaining Duration"] = "Remaining Duration"
L["Remaining Time"] = "Tempo restante"
--[[Translation missing --]]
L["Remove Obsolete Auras"] = "Remove Obsolete Auras"
L["Repair"] = "Reparar"
--[[Translation missing --]]
L["Repeat"] = "Repeat"
--[[Translation missing --]]
L["Report Summary"] = "Report Summary"
--[[Translation missing --]]
L["Reputation"] = "Reputation"
--[[Translation missing --]]
L["Reputation (%)"] = "Reputation (%)"
L["Requested display does not exist"] = "Exibição requerida não existe"
L["Requested display not authorized"] = "Exibição requerida não autorizada"
--[[Translation missing --]]
L["Requesting display information from %s ..."] = "Requesting display information from %s ..."
L["Require Valid Target"] = "Requer um alvo válido"
L["Resist"] = "Resistir"
--[[Translation missing --]]
L["Resistances"] = "Resistances"
L["Resisted"] = "Resistido"
--[[Translation missing --]]
L["Rested"] = "Rested"
--[[Translation missing --]]
L["Rested Experience"] = "Rested Experience"
--[[Translation missing --]]
L["Rested Experience (%)"] = "Rested Experience (%)"
L["Resting"] = "Descansando"
L["Resurrect"] = "Reviver"
--[[Translation missing --]]
L["Resurrect Pending"] = "Resurrect Pending"
L["Right"] = "Direita"
L["Right to Left"] = "Da direita à esquerda"
--[[Translation missing --]]
L["Right, then Centered Vertical"] = "Right, then Centered Vertical"
--[[Translation missing --]]
L["Right, then Down"] = "Right, then Down"
--[[Translation missing --]]
L["Right, then Up"] = "Right, then Up"
--[[Translation missing --]]
L["Role"] = "Role"
--[[Translation missing --]]
L["Rollback snapshot is complete. Thank you for your patience!"] = "Rollback snapshot is complete. Thank you for your patience!"
--[[Translation missing --]]
L["Rotate Animation"] = "Rotate Animation"
L["Rotate Left"] = "Girar à esquerda"
L["Rotate Right"] = "Girar à direita"
--[[Translation missing --]]
L["Rotation"] = "Rotation"
--[[Translation missing --]]
L["Round"] = "Round"
--[[Translation missing --]]
L["Round Mode"] = "Round Mode"
--[[Translation missing --]]
L["Ruins of Ahn'Qiraj"] = "Ruins of Ahn'Qiraj"
--[[Translation missing --]]
L["Run Custom Code"] = "Run Custom Code"
--[[Translation missing --]]
L["Run Speed (%)"] = "Run Speed (%)"
--[[Translation missing --]]
L["Sapphiron"] = "Sapphiron"
--[[Translation missing --]]
L["Say"] = "falar"
--[[Translation missing --]]
L["Scale"] = "Scale"
--[[Translation missing --]]
L["Scarlet Enclave"] = "Scarlet Enclave"
--[[Translation missing --]]
L["Scenario"] = "Scenario"
--[[Translation missing --]]
L["Scenario (Heroic)"] = "Scenario (Heroic)"
--[[Translation missing --]]
L["Scenario (Normal)"] = "Scenario (Normal)"
--[[Translation missing --]]
L["Screen"] = "Screen"
--[[Translation missing --]]
L["Screen/Parent Group"] = "Screen/Parent Group"
--[[Translation missing --]]
L["Season of Discovery"] = "Season of Discovery"
--[[Translation missing --]]
L["Second"] = "Second"
--[[Translation missing --]]
L["Second Value of Tooltip Text"] = "Second Value of Tooltip Text"
--[[Translation missing --]]
L["Secondary Stats"] = "Secondary Stats"
L["Seconds"] = "Segundos"
--[[Translation missing --]]
L[ [=[Secure frame detected. Find more information:
https://github.com/WeakAuras/WeakAuras2/wiki/Protected-Frames]=] ] = [=[Secure frame detected. Find more information:
https://github.com/WeakAuras/WeakAuras2/wiki/Protected-Frames]=]
--[[Translation missing --]]
L["Select Frame"] = "Select Frame"
--[[Translation missing --]]
L["Select the type of timer to filter"] = "Select the type of timer to filter"
--[[Translation missing --]]
L["Selection Mode"] = "Selection Mode"
--[[Translation missing --]]
L["Separator"] = "Separator"
--[[Translation missing --]]
L["Set IDs can be found on websites such as wowhead.com/classic/item-sets"] = "Set IDs can be found on websites such as wowhead.com/classic/item-sets"
--[[Translation missing --]]
L["Shadow Resistance"] = "Shadow Resistance"
--[[Translation missing --]]
L["Shadowlands"] = "Shadowlands"
--[[Translation missing --]]
L["Shake"] = "Sacudir"
--[[Translation missing --]]
L["Shazzrah"] = "Shazzrah"
--[[Translation missing --]]
L["Shift-Click to resume addon execution."] = "Shift-Click to resume addon execution."
L["Show"] = "Mostrar"
--[[Translation missing --]]
L["Show CD of Charge"] = "Show CD of Charge"
--[[Translation missing --]]
L["Show GCD"] = "Show GCD"
--[[Translation missing --]]
L["Show Global Cooldown"] = "Show Global Cooldown"
--[[Translation missing --]]
L["Show Incoming Heal"] = "Show Incoming Heal"
--[[Translation missing --]]
L["Show Loss of Control"] = "Show Loss of Control"
--[[Translation missing --]]
L["Show On"] = "Show On"
--[[Translation missing --]]
L["Show Rested Overlay"] = "Show Rested Overlay"
L["Shrink"] = "Encolher"
--[[Translation missing --]]
L["Silithid Royalty"] = "Silithid Royalty"
--[[Translation missing --]]
L["Silver"] = "Silver"
L["Simple"] = "Simples"
--[[Translation missing --]]
L["Since Active"] = "Since Active"
--[[Translation missing --]]
L["Since Apply"] = "Since Apply"
--[[Translation missing --]]
L["Since Apply/Refresh"] = "Since Apply/Refresh"
--[[Translation missing --]]
L["Since Charge Gain"] = "Since Charge Gain"
--[[Translation missing --]]
L["Since Charge Lost"] = "Since Charge Lost"
--[[Translation missing --]]
L["Since Ready"] = "Since Ready"
--[[Translation missing --]]
L["Since Stack Gain"] = "Since Stack Gain"
--[[Translation missing --]]
L["Since Stack Lost"] = "Since Stack Lost"
--[[Translation missing --]]
L["Size & Position"] = "Size & Position"
--[[Translation missing --]]
L["Slide Animation"] = "Slide Animation"
L["Slide from Bottom"] = "Deslizar de baixo"
L["Slide from Left"] = "Deslizar da esquerda"
L["Slide from Right"] = "Deslizar da direita"
L["Slide from Top"] = "Deslizar de cima"
L["Slide to Bottom"] = "Deslizar para baixo"
L["Slide to Left"] = "Deslizar para esquerda"
L["Slide to Right"] = "Deslizar para direita"
L["Slide to Top"] = "Deslizar para cima"
--[[Translation missing --]]
L["Slider"] = "Slider"
--[[Translation missing --]]
L["Slug"] = "Slug"
--[[Translation missing --]]
L["Slug Outline"] = "Slug Outline"
--[[Translation missing --]]
L["Small"] = "Small"
--[[Translation missing --]]
L["Smart Group"] = "Smart Group"
--[[Translation missing --]]
L["Soft Enemy"] = "Soft Enemy"
--[[Translation missing --]]
L["Soft Friend"] = "Soft Friend"
--[[Translation missing --]]
L["Solistrasza"] = "Solistrasza"
--[[Translation missing --]]
L["Sound"] = "Sound"
--[[Translation missing --]]
L["Sound by Kit ID"] = "Sound by Kit ID"
--[[Translation missing --]]
L["Source"] = "Source"
--[[Translation missing --]]
L["Source Affiliation"] = "Source Affiliation"
--[[Translation missing --]]
L["Source GUID"] = "Source GUID"
--[[Translation missing --]]
L["Source Info"] = "Source Info"
L["Source Name"] = "Origem do nome"
--[[Translation missing --]]
L["Source NPC Id"] = "Source NPC Id"
--[[Translation missing --]]
L["Source Object Type"] = "Source Object Type"
--[[Translation missing --]]
L["Source Raid Mark"] = "Source Raid Mark"
--[[Translation missing --]]
L["Source Reaction"] = "Source Reaction"
L["Source Unit"] = "Origem da unidade"
--[[Translation missing --]]
L["Source Unit Name/Realm"] = "Source Unit Name/Realm"
--[[Translation missing --]]
L["Source unit's raid mark index"] = "Source unit's raid mark index"
--[[Translation missing --]]
L["Source unit's raid mark texture"] = "Source unit's raid mark texture"
--[[Translation missing --]]
L["Space"] = "Space"
L["Spacing"] = "Espaçamento"
--[[Translation missing --]]
L["Spark"] = "Spark"
--[[Translation missing --]]
L["Specialization"] = "Specialization"
--[[Translation missing --]]
L["Specific Type"] = "Specific Type"
L["Specific Unit"] = "Unidade específica"
L["Spell"] = "Feitiço"
L["Spell (Building)"] = "Feitiço (Construção)"
--[[Translation missing --]]
L["Spell Cast Succeeded"] = "Spell Cast Succeeded"
--[[Translation missing --]]
L["Spell Cost"] = "Spell Cost"
--[[Translation missing --]]
L["Spell Count"] = "Spell Count"
--[[Translation missing --]]
L["Spell ID"] = "Spell ID"
--[[Translation missing --]]
L["Spell Id"] = "Spell Id"
--[[Translation missing --]]
L["Spell ID:"] = "Spell ID:"
--[[Translation missing --]]
L["Spell IDs:"] = "Spell IDs:"
--[[Translation missing --]]
L["Spell in Range"] = "Spell in Range"
--[[Translation missing --]]
L["Spell Known"] = "Spell Known"
L["Spell Name"] = "Nome do feitiço"
--[[Translation missing --]]
L["Spell Power"] = "Spell Power"
--[[Translation missing --]]
L["Spell School"] = "Spell School"
--[[Translation missing --]]
L["Spell Usable"] = "Spell Usable"
--[[Translation missing --]]
L["Spellname"] = "Spellname"
--[[Translation missing --]]
L["Spike"] = "Spike"
L["Spin"] = "Girar"
L["Spiral"] = "Espiral"
L["Spiral In And Out"] = "Espiral dentro e fora"
--[[Translation missing --]]
L["Spirit"] = "Spirit"
--[[Translation missing --]]
L["Stack Count"] = "Stack Count"
--[[Translation missing --]]
L["Stack trace:"] = "Stack trace:"
L["Stacks"] = "Pilhas"
--[[Translation missing --]]
L["Stacks Function"] = "Stacks Function"
--[[Translation missing --]]
L["Stacks Function (fallback state)"] = "Stacks Function (fallback state)"
--[[Translation missing --]]
L["Stage"] = "Stage"
--[[Translation missing --]]
L["Stage Counter"] = "Stage Counter"
--[[Translation missing --]]
L["Stagger"] = "Stagger"
--[[Translation missing --]]
L["Stagger Scale"] = "Stagger Scale"
--[[Translation missing --]]
L["Stamina"] = "Stamina"
L["Stance/Form/Aura"] = "Postura/Forma/Aura"
--[[Translation missing --]]
L["Standing"] = "Standing"
--[[Translation missing --]]
L["Star Shake"] = "Star Shake"
--[[Translation missing --]]
L["Start Animation"] = "Start Animation"
--[[Translation missing --]]
L["Start Now"] = "Start Now"
--[[Translation missing --]]
L["Start Profiling"] = "Start Profiling"
L["Status"] = "Estado"
--[[Translation missing --]]
L["Status Bar"] = "Status Bar"
L["Stolen"] = "Roubado"
--[[Translation missing --]]
L["Stop"] = "Stop"
--[[Translation missing --]]
L["Stop Motion"] = "Stop Motion"
--[[Translation missing --]]
L["Story Raid"] = "Story Raid"
--[[Translation missing --]]
L["Strength"] = "Strength"
--[[Translation missing --]]
L["String"] = "String"
--[[Translation missing --]]
L["Subevent Info"] = "Subevent Info"
--[[Translation missing --]]
L["Subtract Cast"] = "Subtract Cast"
--[[Translation missing --]]
L["Subtract Channel"] = "Subtract Channel"
--[[Translation missing --]]
L["Subtract GCD"] = "Subtract GCD"
--[[Translation missing --]]
L["Subzone Name"] = "Subzone Name"
--[[Translation missing --]]
L["Success"] = "Success"
--[[Translation missing --]]
L["Sulfuron Harbinger"] = "Sulfuron Harbinger"
L["Summon"] = "Invocar"
--[[Translation missing --]]
L["Supports multiple entries, separated by commas"] = "Supports multiple entries, separated by commas"
--[[Translation missing --]]
L[ [=[Supports multiple entries, separated by commas
]=] ] = [=[Supports multiple entries, separated by commas
]=]
--[[Translation missing --]]
L["Supports multiple entries, separated by commas. Escape ',' with \\. Prefix with '-' for negation."] = "Supports multiple entries, separated by commas. Escape ',' with \\. Prefix with '-' for negation."
--[[Translation missing --]]
L["Supports multiple entries, separated by commas. Escape with \\. Prefix with '-' for negation."] = "Supports multiple entries, separated by commas. Escape with \\. Prefix with '-' for negation."
--[[Translation missing --]]
L["Supports multiple entries, separated by commas. Prefix with '-' for negation."] = "Supports multiple entries, separated by commas. Prefix with '-' for negation."
--[[Translation missing --]]
L[ [=[Supports multiple entries, separated by commas. To include child zone ids, prefix with 'c', e.g. 'c2022'.
Group Zone IDs must be prefixed with 'g', e.g. 'g277'. 
Supports Area IDs from https://wago.tools/db2/AreaTable prefixed with 'a'. 
Supports Instance IDs prefixed with 'i'.
Entries can be prefixed with '-' to negate.]=] ] = [=[Supports multiple entries, separated by commas. To include child zone ids, prefix with 'c', e.g. 'c2022'.
Group Zone IDs must be prefixed with 'g', e.g. 'g277'. 
Supports Area IDs from https://wago.tools/db2/AreaTable prefixed with 'a'. 
Supports Instance IDs prefixed with 'i'.
Entries can be prefixed with '-' to negate.]=]
--[[Translation missing --]]
L["Swing"] = "Balançar"
L["Swing Timer"] = "Tempo de balanço"
--[[Translation missing --]]
L["Swipe"] = "Swipe"
--[[Translation missing --]]
L["Syntax /wa feature <toggle|on|enable|disable|off> <feature>"] = "Syntax /wa feature <toggle|on|enable|disable|off> <feature>"
--[[Translation missing --]]
L["System"] = "System"
--[[Translation missing --]]
L["Systems"] = "Systems"
--[[Translation missing --]]
L["Tab "] = "Tab "
L["Talent"] = "Talento"
--[[Translation missing --]]
L["Talent |cFFFF0000Not|r Known"] = "Talent |cFFFF0000Not|r Known"
--[[Translation missing --]]
L["Talent |cFFFF0000Not|r Selected"] = "Talent |cFFFF0000Not|r Selected"
--[[Translation missing --]]
L["Talent Known"] = "Talent Known"
--[[Translation missing --]]
L["Talent Selected"] = "Talent Selected"
L["Talent Specialization"] = "Especialização de talentos"
--[[Translation missing --]]
L["Tanking And Highest"] = "Tanking And Highest"
--[[Translation missing --]]
L["Tanking But Not Highest"] = "Tanking But Not Highest"
L["Target"] = "Alvo"
--[[Translation missing --]]
L["Targeted"] = "Targeted"
--[[Translation missing --]]
L["Tertiary Stats"] = "Tertiary Stats"
--[[Translation missing --]]
L["Test if bar is enabled in BigWigs settings"] = "Test if bar is enabled in BigWigs settings"
--[[Translation missing --]]
L["Test if bar is enabled in Boss Mod addon settings"] = "Test if bar is enabled in Boss Mod addon settings"
--[[Translation missing --]]
L["Test if bar is enabled in DBM settings"] = "Test if bar is enabled in DBM settings"
L["Text"] = "Texto"
--[[Translation missing --]]
L["Text To Speech"] = "Text To Speech"
--[[Translation missing --]]
L["Text-to-speech"] = "Text-to-speech"
--[[Translation missing --]]
L["Texture"] = "Texture"
--[[Translation missing --]]
L["Texture Function"] = "Texture Function"
--[[Translation missing --]]
L["Texture Function (fallback state)"] = "Texture Function (fallback state)"
--[[Translation missing --]]
L["Texture Picker"] = "Texture Picker"
--[[Translation missing --]]
L["Texture Rotation"] = "Texture Rotation"
--[[Translation missing --]]
L["Thaddius"] = "Thaddius"
--[[Translation missing --]]
L["The aura has overwritten the global '%s', this might affect other auras."] = "The aura has overwritten the global '%s', this might affect other auras."
--[[Translation missing --]]
L["The aura tried to overwrite the aura_env global, which is not allowed."] = "The aura tried to overwrite the aura_env global, which is not allowed."
--[[Translation missing --]]
L["The Four Horsemen"] = "The Four Horsemen"
--[[Translation missing --]]
L["The 'ID' value can be found in the BigWigs options of a specific spell"] = "The 'ID' value can be found in the BigWigs options of a specific spell"
--[[Translation missing --]]
L["The Prophet Skeram"] = "The Prophet Skeram"
--[[Translation missing --]]
L["The War Within"] = "The War Within"
--[[Translation missing --]]
L["There are %i updates to your auras ready to be installed!"] = "There are %i updates to your auras ready to be installed!"
--[[Translation missing --]]
L["Thick Outline"] = "Thick Outline"
--[[Translation missing --]]
L["Thickness"] = "Thickness"
--[[Translation missing --]]
L["Third"] = "Third"
--[[Translation missing --]]
L["Third Value of Tooltip Text"] = "Third Value of Tooltip Text"
--[[Translation missing --]]
L["This aura calls GetData a lot, which is a slow function."] = "This aura calls GetData a lot, which is a slow function."
--[[Translation missing --]]
L["This aura has caused a Lua error."] = "This aura has caused a Lua error."
--[[Translation missing --]]
L["This aura is saving %s KB of data"] = "This aura is saving %s KB of data"
--[[Translation missing --]]
L["This aura is setting show to nil. This is deprecated and the behavior will change in the future."] = "This aura is setting show to nil. This is deprecated and the behavior will change in the future."
--[[Translation missing --]]
L["This aura plays a sound via a condition."] = "This aura plays a sound via a condition."
--[[Translation missing --]]
L["This aura plays a sound via an action."] = "This aura plays a sound via an action."
--[[Translation missing --]]
L["This aura plays a Text To Speech via a condition."] = "This aura plays a Text To Speech via a condition."
--[[Translation missing --]]
L["This aura plays a Text To Speech via an action."] = "This aura plays a Text To Speech via an action."
--[[Translation missing --]]
L["This filter has been moved to the Location trigger. Change your aura to use the new Location trigger or join the WeakAuras Discord server for help."] = "This filter has been moved to the Location trigger. Change your aura to use the new Location trigger or join the WeakAuras Discord server for help."
--[[Translation missing --]]
L["Threat Percent"] = "Threat Percent"
L["Threat Situation"] = "Situação de ameaça"
--[[Translation missing --]]
L["Threat Value"] = "Threat Value"
--[[Translation missing --]]
L["Tick"] = "Tick"
--[[Translation missing --]]
L["Time"] = "Time"
--[[Translation missing --]]
L["Time Format"] = "Time Format"
--[[Translation missing --]]
L["Time in GCDs"] = "Time in GCDs"
--[[Translation missing --]]
L["Time since initial application"] = "Time since initial application"
--[[Translation missing --]]
L["Time since last refresh"] = "Time since last refresh"
--[[Translation missing --]]
L["Time since stack gain"] = "Time since stack gain"
--[[Translation missing --]]
L["Time since stack lost"] = "Time since stack lost"
L["Timed"] = "Temporizado"
--[[Translation missing --]]
L["Timed Progress"] = "Timed Progress"
--[[Translation missing --]]
L["Timer"] = "Timer"
--[[Translation missing --]]
L["Timer Id"] = "Timer Id"
--[[Translation missing --]]
L["Toggle"] = "Toggle"
--[[Translation missing --]]
L["Toggle List"] = "Toggle List"
--[[Translation missing --]]
L["Toggle Options Window"] = "Toggle Options Window"
--[[Translation missing --]]
L["Toggle Performance Profiling Window"] = "Toggle Performance Profiling Window"
--[[Translation missing --]]
L["Tooltip"] = "Tooltip"
--[[Translation missing --]]
L["Tooltip 1"] = "Tooltip 1"
--[[Translation missing --]]
L["Tooltip 2"] = "Tooltip 2"
--[[Translation missing --]]
L["Tooltip 3"] = "Tooltip 3"
--[[Translation missing --]]
L["Tooltip Value 1"] = "Tooltip Value 1"
--[[Translation missing --]]
L["Tooltip Value 2"] = "Tooltip Value 2"
--[[Translation missing --]]
L["Tooltip Value 3"] = "Tooltip Value 3"
--[[Translation missing --]]
L["Tooltip Value 4"] = "Tooltip Value 4"
L["Top"] = "Topo"
L["Top Left"] = "Topo à esquerda"
L["Top Right"] = "Topo à direita"
L["Top to Bottom"] = "Do topo para base"
--[[Translation missing --]]
L["Torghast"] = "Torghast"
--[[Translation missing --]]
L["Total Duration"] = "Total Duration"
--[[Translation missing --]]
L["Total Experience"] = "Total Experience"
--[[Translation missing --]]
L["Total Match Count"] = "Total Match Count"
--[[Translation missing --]]
L["Total Reputation"] = "Total Reputation"
--[[Translation missing --]]
L["Total Stacks"] = "Total Stacks"
--[[Translation missing --]]
L["Total stacks over all matches"] = "Total stacks over all matches"
--[[Translation missing --]]
L["Total Unit Count"] = "Total Unit Count"
--[[Translation missing --]]
L["Total Units"] = "Total Units"
L["Totem"] = "Totem"
--[[Translation missing --]]
L["Totem #%i"] = "Totem #%i"
--[[Translation missing --]]
L["Totem Icon"] = "Totem Icon"
L["Totem Name"] = "Nome do totem"
--[[Translation missing --]]
L["Totem Name Pattern Match"] = "Totem Name Pattern Match"
--[[Translation missing --]]
L["Totem Number"] = "Totem Number"
--[[Translation missing --]]
L["Track Cooldowns"] = "Track Cooldowns"
--[[Translation missing --]]
L["Tracking Charge %i"] = "Tracking Charge %i"
--[[Translation missing --]]
L["Tracking Charge CDs"] = "Tracking Charge CDs"
--[[Translation missing --]]
L["Tracking Only Cooldown"] = "Tracking Only Cooldown"
L["Transmission error"] = "Erro de transmissão"
--[[Translation missing --]]
L["Trigger"] = "Gatilho"
L["Trigger %i"] = "Gatilho %i"
--[[Translation missing --]]
L["Trigger %s"] = "Trigger %s"
L["Trigger 1"] = "Gatilho 1"
--[[Translation missing --]]
L["Trigger State Updater (Advanced)"] = "Trigger State Updater (Advanced)"
L["Trigger Update"] = "Atualização do gatilho"
L["Trigger:"] = "Gatilho:"
--[[Translation missing --]]
L["Trivial (Low Level)"] = "Trivial (Low Level)"
--[[Translation missing --]]
L["True"] = "True"
--[[Translation missing --]]
L["Trying to repair broken conditions in %s likely caused by a Musca Auras bug."] = "Trying to repair broken conditions in %s likely caused by a Musca Auras bug."
--[[Translation missing --]]
L["Twin Emperors"] = "Twin Emperors"
L["Type"] = "Tipo"
--[[Translation missing --]]
L["Unable to modernize aura '%s'. This is probably due to corrupt data or a bad migration, please report this to the Musca Auras team."] = "Unable to modernize aura '%s'. This is probably due to corrupt data or a bad migration, please report this to the Musca Auras team."
--[[Translation missing --]]
L["Unaffected"] = "Unaffected"
L["Undefined"] = "Indefinido"
L["Unit"] = "Unidade"
L["Unit Characteristics"] = "Características da unidade"
L["Unit Destroyed"] = "Unidade destruída"
L["Unit Died"] = "Unidade morte"
--[[Translation missing --]]
L["Unit Dissipates"] = "Unit Dissipates"
--[[Translation missing --]]
L["Unit Frame"] = "Unit Frame"
--[[Translation missing --]]
L["Unit Frames"] = "Unit Frames"
--[[Translation missing --]]
L["Unit is Unit"] = "Unit is Unit"
--[[Translation missing --]]
L["Unit Name"] = "Unit Name"
--[[Translation missing --]]
L["Unit Name/Realm"] = "Unit Name/Realm"
--[[Translation missing --]]
L["Units Affected"] = "Units Affected"
--[[Translation missing --]]
L["Units of affected Players in a table format"] = "Units of affected Players in a table format"
--[[Translation missing --]]
L["Units of unaffected Players in a table format"] = "Units of unaffected Players in a table format"
--[[Translation missing --]]
L["Unknown action %q"] = "Unknown action %q"
--[[Translation missing --]]
L["Unknown feature %q"] = "Unknown feature %q"
--[[Translation missing --]]
L["unknown location"] = "unknown location"
--[[Translation missing --]]
L["Unlimited"] = "Unlimited"
--[[Translation missing --]]
L["Untrigger %s"] = "Untrigger %s"
L["Up"] = "Acima"
--[[Translation missing --]]
L["Up, then Centered Horizontal"] = "Up, then Centered Horizontal"
--[[Translation missing --]]
L["Up, then Left"] = "Up, then Left"
--[[Translation missing --]]
L["Up, then Right"] = "Up, then Right"
--[[Translation missing --]]
L["Update Position"] = "Update Position"
--[[Translation missing --]]
L["Usage:"] = "Usage:"
--[[Translation missing --]]
L["Use /wa minimap to show the minimap icon again."] = "Use /wa minimap to show the minimap icon again."
--[[Translation missing --]]
L["Use Custom Color"] = "Use Custom Color"
--[[Translation missing --]]
L["Use Legacy floor rounding"] = "Use Legacy floor rounding"
--[[Translation missing --]]
L["Use Texture"] = "Use Texture"
--[[Translation missing --]]
L["Use Watched Faction"] = "Use Watched Faction"
--[[Translation missing --]]
L["Using WeakAuras.clones is deprecated. Use WeakAuras.GetRegion(id, cloneId) instead."] = "Using WeakAuras.clones is deprecated. Use WeakAuras.GetRegion(id, cloneId) instead."
--[[Translation missing --]]
L["Using WeakAuras.regions is deprecated. Use WeakAuras.GetRegion(id) instead."] = "Using WeakAuras.regions is deprecated. Use WeakAuras.GetRegion(id) instead."
--[[Translation missing --]]
L["Vaelastrasz the Corrupt"] = "Vaelastrasz the Corrupt"
--[[Translation missing --]]
L["Vertical"] = "Vertical"
--[[Translation missing --]]
L["Viscidus"] = "Viscidus"
--[[Translation missing --]]
L["Visibility"] = "Visibility"
--[[Translation missing --]]
L["Visions of N'Zoth"] = "Visions of N'Zoth"
--[[Translation missing --]]
L["Warfront (Heroic)"] = "Warfront (Heroic)"
--[[Translation missing --]]
L["Warfront (Normal)"] = "Warfront (Normal)"
--[[Translation missing --]]
L["Warlords of Draenor"] = "Warlords of Draenor"
--[[Translation missing --]]
L["Warning"] = "Warning"
--[[Translation missing --]]
L["Warning for unknown aura:"] = "Warning for unknown aura:"
--[[Translation missing --]]
L["Warning: Anchoring in aura '%s' is imposssible, due to an anchoring cycle"] = "Warning: Anchoring in aura '%s' is imposssible, due to an anchoring cycle"
--[[Translation missing --]]
L["Musca Auras Built-In (63:42 | 3:07 | 10 | 2.4)"] = "Musca Auras Built-In (63:42 | 3:07 | 10 | 2.4)"
--[[Translation missing --]]
L["Musca Auras has detected empty settings. If this is unexpected, ask for assistance on https://discord.gg/weakauras."] = "Musca Auras has detected empty settings. If this is unexpected, ask for assistance on https://discord.gg/weakauras."
--[[Translation missing --]]
L[ [=[Musca Auras has detected that it has been downgraded.
Your saved auras may no longer work properly.
Would you like to run the |cffff0000EXPERIMENTAL|r repair tool? This will overwrite any changes you have made since the last database upgrade.
Last upgrade: %s

|cffff0000You should BACKUP your WTF folder BEFORE pressing this button.|r]=] ] = [=[Musca Auras has detected that it has been downgraded.
Your saved auras may no longer work properly.
Would you like to run the |cffff0000EXPERIMENTAL|r repair tool? This will overwrite any changes you have made since the last database upgrade.
Last upgrade: %s

|cffff0000You should BACKUP your WTF folder BEFORE pressing this button.|r]=]
--[[Translation missing --]]
L["Musca Auras is creating a rollback snapshot of your auras. This snapshot will allow you to revert to the current state of your auras if something goes wrong. This process may cause your framerate to drop until it is complete."] = "Musca Auras is creating a rollback snapshot of your auras. This snapshot will allow you to revert to the current state of your auras if something goes wrong. This process may cause your framerate to drop until it is complete."
--[[Translation missing --]]
L["Musca Auras Profiling"] = "Musca Auras Profiling"
--[[Translation missing --]]
L["Musca Auras Profiling Report"] = "Musca Auras Profiling Report"
--[[Translation missing --]]
L["Weapon"] = "Arma"
--[[Translation missing --]]
L["Weapon Enchant"] = "Weapon Enchant"
L["Whisper"] = "Sussurro"
L["Width"] = "Largura"
L["Wobble"] = "Oscilar"
--[[Translation missing --]]
L["World Boss"] = "World Boss"
--[[Translation missing --]]
L["World Bosses"] = "World Bosses"
--[[Translation missing --]]
L["Wrap"] = "Wrap"
--[[Translation missing --]]
L["Wrath of the Lich King"] = "Wrath of the Lich King"
--[[Translation missing --]]
L["Writing to the WeakAuras table is not allowed."] = "Writing to the WeakAuras table is not allowed."
--[[Translation missing --]]
L["X-Offset"] = "X-Offset"
L["Yell"] = "Gritar"
--[[Translation missing --]]
L["Y-Offset"] = "Y-Offset"
--[[Translation missing --]]
L["You have new auras ready to be installed!"] = "You have new auras ready to be installed!"
--[[Translation missing --]]
L["Your next encounter will automatically be profiled."] = "Your next encounter will automatically be profiled."
--[[Translation missing --]]
L["Your next instance of combat will automatically be profiled."] = "Your next instance of combat will automatically be profiled."
--[[Translation missing --]]
L["Your scheduled automatic profile has been cancelled."] = "Your scheduled automatic profile has been cancelled."
--[[Translation missing --]]
L["Your threat as a percentage of the tank's current threat."] = "Your threat as a percentage of the tank's current threat."
--[[Translation missing --]]
L["Your threat on the mob as a percentage of the amount required to pull aggro. Will pull aggro at 100."] = "Your threat on the mob as a percentage of the amount required to pull aggro. Will pull aggro at 100."
--[[Translation missing --]]
L["Your total threat on the mob."] = "Your total threat on the mob."
--[[Translation missing --]]
L["Zone Group ID"] = "Zone Group ID"
--[[Translation missing --]]
L["Zone ID"] = "Zone ID"
L["Zone Name"] = "Nome da Zona"
--[[Translation missing --]]
L["Zoom"] = "Zoom"
--[[Translation missing --]]
L["Zoom Animation"] = "Zoom Animation"
--[[Translation missing --]]
L["Zul'Gurub"] = "Zul'Gurub"
L["New name, new look: the addon now shows its own name, Musca Auras."] = "Novo nome, novo visual: o addon agora mostra seu próprio nome, Musca Auras."
L["- New colors and a new icon, in the |cffffd100/wa|r window, the Guide, the chat and the minimap."] = "- Novas cores e um novo ícone, na janela |cffffd100/wa|r, no Guia, no chat e no minimapa."
L["- Two more ways to open it: the addon menu of the minimap, and a page in Options > AddOns."] = "- Mais duas formas de abri-lo: o menu de addons do minimapa e uma página em Opções > AddOns."
L["Nothing else changes: |cffffd100/wa|r, your auras, their positions and the Wago imports work as before."] = "Nada mais muda: |cffffd100/wa|r, suas auras, as posições delas e as importações do Wago funcionam como antes."
L["Open Musca Auras"] = "Abrir Musca Auras"
L["You can also type |cffffd100/wa|r in the chat, or click the icon of the minimap."] = "Você também pode digitar |cffffd100/wa|r no chat ou clicar no ícone do minimapa."
L["The Cooldown Manager configuration was updated by Musca Auras. Reload the UI to finish."] = "O Musca Auras atualizou a configuração do Gerenciador de Recarga. Recarregue a interface para concluir."
L["|cffffd100Everything you need to learn Musca Auras on WoW Forever:|r how an aura works, what changed in combat, what works and what does not, step-by-step recipes and ready-made auras to import.\n\nOpen this guide again with the |cffffd100Guide|r button at the top of the |cffffd100/wa|r window, or with |cffffd100/wa tutorial|r."] = "|cffffd100Tudo o que você precisa para aprender o Musca Auras no WoW Forever:|r como uma aura funciona, o que mudou em combate, o que funciona e o que não funciona, receitas passo a passo e auras prontas para importar.\n\nAbra este guia novamente com o botão |cffffd100Guia|r no topo da janela |cffffd100/wa|r, ou com |cffffd100/wa tutorial|r."
L["How Musca Auras works on WoW Forever, and how to build auras that keep working in combat.\n\nWoW Forever looks like Classic, but it runs on the modern 12.1 game engine. This engine hides most combat data from addons. This guide explains what that changes and gives step-by-step recipes.\n\nSection 3 says what was tested in game on Forever, and what was not. When you are not sure, test in game."] = "Como o Musca Auras funciona no WoW Forever e como criar auras que continuam funcionando em combate.\n\nO WoW Forever parece o Classic, mas roda no motor de jogo moderno 12.1. Esse motor esconde dos addons a maior parte dos dados de combate. Este guia explica o que isso muda e traz receitas passo a passo.\n\nA seção 3 diz o que foi testado no jogo no Forever e o que não foi. Na dúvida, teste no jogo."
L["1. Musca Auras in 2 minutes"] = "1. Musca Auras em 2 minutos"
L["An aura is something Musca Auras shows on your screen: an icon, a bar, a text or a texture. Every aura has 4 parts, one per tab in the options:\n\n- |cffffd100Display|r: What it looks like: icon, size, colors, text.\n- |cffffd100Trigger|r: When it shows: a buff, a cooldown, a cast, an item count, a game event.\n- |cffffd100Conditions|r: What changes while it is shown, for example red when less than 3 seconds remain.\n- |cffffd100Load|r: When Musca Auras even looks at it: class, in combat, in a group, zone.\n\nThe |cffffd100Actions|r tab adds a sound, a chat message or a glow when the aura shows or hides.\n\nBasic steps:\n\n1. Type |cff99ccff/wa|r.\n2. Click |cffffd100New|r, then choose a display type: |cffffd100Icon|r, |cffffd100Progress Bar|r, |cffffd100Text|r or |cffffd100Texture|r.\n3. Fill in the |cffffd100Trigger|r tab.\n4. Set the |cffffd100Load|r tab, so the aura only loads when it is useful.\n5. Close the options and test."] = "Uma aura é algo que o Musca Auras mostra na sua tela: um ícone, uma barra, um texto ou uma textura. Toda aura tem 4 partes, uma por aba nas opções:\n\n- |cffffd100Exibição|r: Como ela aparece: ícone, tamanho, cores, texto.\n- |cffffd100Gatilho|r: Quando ela aparece: um bônus, um tempo de recarga, uma conjuração, uma quantidade de itens, um evento do jogo.\n- |cffffd100Condições|r: O que muda enquanto ela aparece, por exemplo vermelho quando restam menos de 3 segundos.\n- |cffffd100Carregar|r: Quando o Musca Auras sequer a considera: classe, em combate, em grupo, zona.\n\nA aba |cffffd100Ações|r adiciona um som, uma mensagem no chat ou um brilho quando a aura aparece ou some.\n\nPassos básicos:\n\n1. Digite |cff99ccff/wa|r.\n2. Clique em |cffffd100Novo|r e escolha um tipo de exibição: |cffffd100Ícone|r, |cffffd100Barra de progresso|r, |cffffd100Texto|r ou |cffffd100Textura|r.\n3. Preencha a aba |cffffd100Gatilho|r.\n4. Configure a aba |cffffd100Carregar|r, para que a aura só seja carregada quando for útil.\n5. Feche as opções e teste."
L["Place your auras on the screen"] = "Posicione suas auras na tela"
L["Type |cff99ccff/wa unlock|r, or click |cffffd100Unlock|r at the top of the |cff99ccff/wa|r window. The screen darkens under a grid and every aura gets a box: drag it where you want. Auras snap to the grid, to the screen edges and to the other auras. Hold |cffffd100Shift|r to turn the snap off. The panel of the selected aura sets its exact position and size. Click |cffffd100Save and quit|r when you are done. Placement mode does not open during combat."] = "Digite |cff99ccff/wa unlock|r, ou clique em |cffffd100Desbloquear|r no topo da janela |cff99ccff/wa|r. A tela escurece sob uma grade e cada aura ganha uma caixa: arraste-a para onde quiser. As auras se alinham à grade, às bordas da tela e às outras auras. Segure |cffffd100Shift|r para desativar o alinhamento. O painel da aura selecionada define sua posição e tamanho exatos. Clique em |cffffd100Salvar e sair|r quando terminar. O modo de posicionamento não abre durante o combate."
L["2. What changed on Forever"] = "2. O que mudou no Forever"
L["Secret values"] = "Valores secretos"
L["During combat, boss encounters and PvP matches, the game gives addons \"secret\" values: Musca Auras receives the data but cannot read it, compare it or do math with it. Out of combat, almost everything works like before.\n\nWhat that means for your auras, tested in game on Forever unless marked otherwise:\n\n- |cffffd100The game draws what Musca Auras cannot read.|r Cooldown swipes and numbers, timer bars, and health or power bars keep moving in combat. A text made only of |cff99ccff%p|r and |cff99ccff%t|r (for example |cff99ccff%p|r or |cff99ccff%p / %t|r) is drawn by the game too, as a raw number.\n- |cffffd100Buffs and debuffs are refused to addons in combat.|r An aura that was showing before the pull keeps counting down from its last known time. Its stacks stay frozen. Everything is read again when combat ends.\n- |cffffd100Your own recast restarts the timer.|r When you cast again a buff that you put on yourself, the timer of an Aura trigger on the Player unit restarts from its last known duration, even if this cast went to someone else. A recast by someone else is not seen.\n- |cffffd100A buff or debuff applied for the first time in combat|r is only seen when combat ends.\n- |cffffd100Logic on secret data keeps its last state.|r A condition such as \"Health < 50%\" keeps the state it had when combat started, then updates when combat ends. The health of a target that is not a player is hidden by the game even out of combat: such a condition on the Target unit never changes. Use \"Show only below (%)\" on the Health trigger instead."] = "Durante o combate, encontros contra chefes e partidas de JxJ, o jogo entrega aos addons valores \"secretos\": o Musca Auras recebe o dado, mas não consegue lê-lo, compará-lo nem fazer contas com ele. Fora de combate, quase tudo funciona como antes.\n\nO que isso significa para as suas auras, testado no jogo no Forever, salvo indicação em contrário:\n\n- |cffffd100O jogo desenha o que o Musca Auras não consegue ler.|r Animações e números de recarga, barras de tempo e barras de vida ou de poder continuam se movendo em combate. Um texto feito apenas de |cff99ccff%p|r e |cff99ccff%t|r (por exemplo |cff99ccff%p|r ou |cff99ccff%p / %t|r) também é desenhado pelo jogo, como um número bruto.\n- |cffffd100Bônus e penalidades são negados aos addons em combate.|r Uma aura que já aparecia antes do início do combate continua a contagem regressiva a partir do último tempo conhecido. Seus acúmulos ficam congelados. Tudo é lido novamente quando o combate termina.\n- |cffffd100Sua própria nova conjuração reinicia o temporizador.|r Quando você conjura de novo um bônus que coloca em si mesmo, o temporizador de um gatilho de Aura na unidade Jogador reinicia a partir da última duração conhecida, mesmo que essa conjuração tenha ido para outra pessoa. Uma nova conjuração feita por outra pessoa não é detectada.\n- |cffffd100Um bônus ou penalidade aplicado pela primeira vez em combate|r só é detectado quando o combate termina.\n- |cffffd100A lógica sobre dados secretos mantém seu último estado.|r Uma condição como \"Vida < 50%\" mantém o estado que tinha quando o combate começou e é atualizada quando o combate termina. O jogo esconde a vida de um alvo que não é jogador mesmo fora de combate: uma condição assim na unidade Alvo nunca muda. Use, em vez disso, \"Mostrar apenas abaixo de (%)\" no gatilho de Vida."
L["The combat log is closed"] = "O registro de combate está fechado"
L["Triggers that use the combat log (|cff99ccffCLEU|r, \"Combat Log\") never fire. For damage taken, use the event |cff99ccffUNIT_COMBAT:player|r."] = "Gatilhos que usam o registro de combate (|cff99ccffCLEU|r, \"Registro de combate\") nunca disparam. Para o dano recebido, use o evento |cff99ccffUNIT_COMBAT:player|r."
L["Other changes"] = "Outras mudanças"
L["- |cffffd100Spells by name or ID.|r In the spell lists of an Aura (Modern) trigger, type a spell name in the game language: it becomes the IDs of all its ranks. Elsewhere, name search may not find spells: type the spell ID. Get the ID of your rank out of combat: |cff99ccff/dump C_Spell.GetSpellInfo(\"Corruption\")|r. Classic spells have one ID per rank.\n- |cffffd100Talent load options|r list the talents of your own specialization only. Select it alone in the |cffffd100Class and Specialization|r load option first.\n- |cffffd100Chat Message action|r can be blocked during encounters and PvP matches.\n- |cffffd100Old functions in custom code|r no longer exist (|cff99ccffGetSpellInfo|r, |cff99ccffGetSpellCooldown|r, |cff99ccffUnitBuff|r...). Use |cff99ccffC_Spell|r, |cff99ccffC_UnitAuras|r, |cff99ccffC_Item|r.\n- |cffffd100Blizzard Cooldown Manager.|r |cff99ccff/wa cdm|r shows or hides it, out of combat. On the Forever beta it is not enabled for every class: for some classes it has no spell and no buff, and the \"From the Cooldown Manager\" lists of the Cooldown and Aura triggers are empty."] = "- |cffffd100Feitiços por nome ou ID.|r Nas listas de feitiços de um gatilho de Aura (Moderno), digite o nome de um feitiço no idioma do jogo: ele se transforma nos IDs de todos os seus níveis. Em outros lugares, a busca por nome pode não encontrar feitiços: digite o ID do feitiço. Obtenha o ID do seu nível fora de combate: |cff99ccff/dump C_Spell.GetSpellInfo(\"Corruption\")|r. Feitiços do Classic têm um ID por nível.\n- |cffffd100As opções de carregamento por talento|r listam apenas os talentos da sua própria especialização. Selecione-a primeiro, sozinha, na opção de carregamento |cffffd100Classe e especialização|r.\n- |cffffd100A ação Mensagem de chat|r pode ser bloqueada durante encontros e partidas de JxJ.\n- |cffffd100Funções antigas em código personalizado|r não existem mais (|cff99ccffGetSpellInfo|r, |cff99ccffGetSpellCooldown|r, |cff99ccffUnitBuff|r...). Use |cff99ccffC_Spell|r, |cff99ccffC_UnitAuras|r, |cff99ccffC_Item|r.\n- |cffffd100Cooldown Manager da Blizzard.|r |cff99ccff/wa cdm|r o mostra ou esconde, fora de combate. No beta do Forever ele não está ativado para todas as classes: para algumas classes não tem nenhum feitiço nem bônus, e as listas \"Do Cooldown Manager\" dos gatilhos de Recarga e de Aura ficam vazias."
L["3. What you can use"] = "3. O que você pode usar"
L["|cffffd100Tested in game, works in combat:|r\n\n- Spell cooldowns: icon swipe and number. With |cffffd100Show Global Cooldown|r, the \"On Global Cooldown\" condition can hide the number during the global cooldown.\n- Buffs on yourself known before combat: icon and timer. Your own recast restarts the timer.\n- Health bar of your target and power bar of yourself, with a |cff99ccff%p / %t|r text.\n- Swing timer, main hand.\n- Your own casts: |cff99ccffUNIT_SPELLCAST_SUCCEEDED:player|r (see the recipes below).\n- |cff99ccffPLAYER_TARGET_DIED|r.\n\n|cffffd100Tested in game:|r\n\n- Temporary weapon enchants (poison, oil, sharpening stone), both hands.\n- |cffffd100Elapsed Time|r filter of the Aura trigger.\n- Bag Space trigger.\n- Role trigger (role chosen in the group finder).\n- |cff99ccff/wa cdm|r, and the \"From the Cooldown Manager\" lists, for the classes that have it.\n\n|cffffd100Works, with limits:|r\n\n- Stacks stay frozen in combat.\n- Conditions and filters on percentages, stacks or remaining time use the value from before combat.\n- A filter checked in the trigger itself (for example \"Health (%) < 50\") freezes the trigger in combat instead of hiding the aura.\n\n|cffffd100Not tested in game yet:|r\n\n- Swing timer off hand, ranged and wand, \"Target In Range\" option.\n- Ammo trigger, Equipment Durability, Tracking, instance difficulty load option.\n- Border and icon colored by dispel type.\n- Aura triggers in party or raid mode, glows, range conditions.\n- Encounter start and end: |cff99ccffENCOUNTER_START|r, |cff99ccffENCOUNTER_END|r.\n\n|cffffd100Does not work:|r\n\n- Aura trigger filtered by |cffffd100Game Categories|r (crowd control, cast by me...): nothing shows at the moment.\n- Other players' casts.\n- Enemy names and IDs in instances.\n- Mana or energy tick timer in combat.\n- Combat log triggers."] = "|cffffd100Testado no jogo, funciona em combate:|r\n\n- Recargas de feitiços: animação do ícone e número. Com |cffffd100Mostrar recarga global|r, a condição \"Em recarga global\" pode esconder o número durante a recarga global.\n- Bônus em você conhecidos antes do combate: ícone e temporizador. Sua própria nova conjuração reinicia o temporizador.\n- Barra de vida do seu alvo e sua própria barra de poder, com um texto |cff99ccff%p / %t|r.\n- Temporizador de golpe, mão principal.\n- Suas próprias conjurações: |cff99ccffUNIT_SPELLCAST_SUCCEEDED:player|r (veja as receitas abaixo).\n- |cff99ccffPLAYER_TARGET_DIED|r.\n\n|cffffd100Testado no jogo:|r\n\n- Encantamentos temporários de arma (veneno, óleo, pedra de afiar), nas duas mãos.\n- Filtro |cffffd100Tempo decorrido|r do gatilho de Aura.\n- Gatilho de espaço nas bolsas.\n- Gatilho de função (função escolhida no localizador de grupos).\n- |cff99ccff/wa cdm|r e as listas \"Do Cooldown Manager\", para as classes que o têm.\n\n|cffffd100Funciona, com limitações:|r\n\n- Os acúmulos ficam congelados em combate.\n- Condições e filtros sobre porcentagens, acúmulos ou tempo restante usam o valor de antes do combate.\n- Um filtro verificado no próprio gatilho (por exemplo \"Vida (%) < 50\") congela o gatilho em combate em vez de esconder a aura.\n\n|cffffd100Ainda não testado no jogo:|r\n\n- Temporizador de golpe da mão secundária, à distância e varinha, opção \"Alvo ao alcance\".\n- Gatilho de munição, Durabilidade do equipamento, Rastreamento, opção de carregamento por dificuldade da instância.\n- Borda e ícone coloridos pelo tipo de dissipação.\n- Gatilhos de Aura em modo grupo ou raide, brilhos, condições de alcance.\n- Início e fim de encontro: |cff99ccffENCOUNTER_START|r, |cff99ccffENCOUNTER_END|r.\n\n|cffffd100Não funciona:|r\n\n- Gatilho de Aura filtrado por |cffffd100Categorias do jogo|r (controle de grupo, conjurado por mim...): por enquanto nada aparece.\n- Conjurações de outros jogadores.\n- Nomes e IDs de inimigos em instâncias.\n- Temporizador do pulso de mana ou energia em combate.\n- Gatilhos do registro de combate."
L["4. New way of thinking: prepare or deduce"] = "4. Nova forma de pensar: preparar ou deduzir"
L["Stop reading the combat. |cffffd100Prepare|r before the pull, or |cffffd100deduce|r from what you do.\n\n- Debuff on target, show its timer: You cast the DoT, start a fixed timer\n- Buff missing in combat, alert: Check buffs and consumables before the pull\n- Boss casts X, alert: Boss timeline from the pull (|cff99ccffENCOUNTER_START|r)\n- Cooldown ready, flash: Let the action bar show the cooldown\n- Low mana, alert: Power trigger, \"Show only below (%)\" option\n\nFor debuffs on enemies, the Blizzard nameplates and target frame can show them (\"only my debuffs\"). Use them for what only the game can see."] = "Pare de ler o combate. |cffffd100Prepare|r antes do início, ou |cffffd100deduza|r a partir do que você faz.\n\n- Penalidade no alvo, mostrar seu temporizador: você conjura o DoT, inicie um temporizador fixo\n- Bônus ausente em combate, alerta: verifique bônus e consumíveis antes do início\n- O chefe conjura X, alerta: linha do tempo do chefe a partir do início (|cff99ccffENCOUNTER_START|r)\n- Recarga pronta, piscar: deixe a barra de ação mostrar a recarga\n- Pouca mana, alerta: gatilho de Poder, opção \"Mostrar apenas abaixo de (%)\"\n\nPara penalidades em inimigos, as placas de nome da Blizzard e o quadro do alvo podem mostrá-las (\"apenas minhas penalidades\"). Use-os para o que só o jogo consegue ver."
L["5. Recipe: DoT or buff timer from your cast"] = "5. Receita: temporizador de DoT ou bônus a partir da sua conjuração"
L["Not tested in game yet. No custom code. Example: Corruption on your target.\n\n1. Out of combat, get the ID of your rank: |cff99ccff/dump C_Spell.GetSpellInfo(\"Corruption\")|r. Note the |cff99ccffspellID|r.\n2. |cff99ccff/wa|r, |cffffd100New|r, |cffffd100Icon|r (or |cffffd100Progress Bar|r).\n3. |cffffd100Trigger|r tab:\n    - Type: |cffffd100Other Events|r, then |cffffd100Spell Cast Succeeded|r\n    - Caster Unit: |cffffd100Player|r\n    - |cffffd100Exact Spell ID(s)|r: your spell ID (for example 11672)\n    - |cffffd100Hide when target dies|r: checked\n    - |cffffd100Hide After|r, Duration: the spell duration from its tooltip (Corruption: 18)\n4. Test on any mob.\n\nThe trigger gives the icon of the spell.\n\nLimits: one aura per spell. Casting again restarts the timer. The aura does not know if the spell was resisted or dispelled. It follows one target only.\n\n|cffffd100Hide when target dies|r only sees the death of your current target. If you change target and the mob with your DoT dies, the timer keeps running. If you change target and the new target dies, the timer is hidden. For a buff on yourself, leave the box unchecked.\n\n|cffffd100Hide when target changes|r hides the timer as soon as you target another mob or clear your target. A target change during a cast is not seen. Targeting the first mob again does not bring the timer back.\n\nA missed or resisted spell still starts the timer: the game reports the cast as succeeded, and the combat log that tells misses is not available to addons on WoW Forever.\n\nReady-made example for Immolate rank 1 (spell ID 348, 15 seconds). Click the import button below."] = "Ainda não testado no jogo. Sem código personalizado. Exemplo: Corrupção no seu alvo.\n\n1. Fora de combate, obtenha o ID do seu nível: |cff99ccff/dump C_Spell.GetSpellInfo(\"Corruption\")|r. Anote o |cff99ccffspellID|r.\n2. |cff99ccff/wa|r, |cffffd100Novo|r, |cffffd100Ícone|r (ou |cffffd100Barra de progresso|r).\n3. Aba |cffffd100Gatilho|r:\n    - Tipo: |cffffd100Outros eventos|r, depois |cffffd100Feitiço conjurado com sucesso|r\n    - Unidade conjuradora: |cffffd100Jogador|r\n    - |cffffd100ID(s) exato(s) do feitiço|r: o ID do seu feitiço (por exemplo 11672)\n    - |cffffd100Esconder quando o alvo morrer|r: marcado\n    - |cffffd100Esconder após|r, Duração: a duração do feitiço conforme sua descrição (Corrupção: 18)\n4. Teste em qualquer monstro.\n\nO gatilho mostra o ícone do feitiço.\n\nLimitações: uma aura por feitiço. Conjurar de novo reinicia o temporizador. A aura não sabe se o feitiço foi resistido ou dissipado. Ela acompanha um único alvo.\n\n|cffffd100Esconder quando o alvo morrer|r só detecta a morte do seu alvo atual. Se você mudar de alvo e o monstro com o seu DoT morrer, o temporizador continua correndo. Se você mudar de alvo e o novo alvo morrer, o temporizador é escondido. Para um bônus em você, deixe a caixa desmarcada.\n\n|cffffd100Esconder quando o alvo mudar|r esconde o temporizador assim que você seleciona outro monstro ou limpa seu alvo. Uma mudança de alvo durante uma conjuração não é detectada. Selecionar o primeiro monstro de novo não traz o temporizador de volta.\n\nUm feitiço errado ou resistido ainda inicia o temporizador: o jogo informa a conjuração como bem-sucedida, e o registro de combate que informa os erros não está disponível para os addons no WoW Forever.\n\nExemplo pronto para Imolar nível 1 (ID do feitiço 348, 15 segundos). Clique no botão de importar abaixo."
L["Import the DoT timer"] = "Importar o temporizador de DoT"
L["Variant: one timer per mob, on its nameplate"] = "Variante: um temporizador por monstro, na sua placa de nome"
L["Tested in game on Forever. Each mob you cast the spell on gets its own icon and timer, above its nameplate.\n\n|cffffd100Only with the default Blizzard nameplates.|r Addons that replace the nameplates (EllesmereUI, ElvUI, Plater, Kui, etc.) hide the Blizzard health bar this aura attaches to: the icons then show nowhere, or at random places. The game does not let addons measure or attach to protected nameplate regions, so this cannot be fixed on the Musca Auras side. With a nameplate addon, use the single timer above.\n\nEnemy nameplates must be shown (key |cffffd100V|r).\n\nHow it works:\n\n- The aura is a |cffffd100Dynamic Group|r with |cffffd100Group by Frame|r set to |cffffd100Nameplates|r, and one icon inside.\n- The icon uses a |cffffd100Trigger State Updater|r on |cff99ccffUNIT_SPELLCAST_SUCCEEDED:player NAME_PLATE_UNIT_REMOVED PLAYER_TARGET_DIED|r.\n- When you cast the spell, the code looks for the nameplate of your target: it tests |cff99ccffnameplate1|r to |cff99ccffnameplate40|r with |cff99ccffUnitIsUnit(token, \"target\")|r, which stays readable in combat. It starts a timer for that nameplate and stores the nameplate in the state (|cff99ccffunit = token|r), so the group puts the icon on it.\n- When a nameplate disappears (the mob died or went out of range), its timer is removed.\n\nLimits: a timer is lost when the nameplate disappears, for example when you move away from the mob. The aura does not know if the spell was resisted or dispelled.\n\nReady-made example for Immolate rank 1 (spell ID 348, 15 seconds). Click the import button below."] = "Testado no jogo no Forever. Cada monstro em que você conjura o feitiço recebe seu próprio ícone e temporizador, acima da sua placa de nome.\n\n|cffffd100Somente com as placas de nome padrão da Blizzard.|r Addons que substituem as placas de nome (EllesmereUI, ElvUI, Plater, Kui, etc.) escondem a barra de vida da Blizzard à qual esta aura se prende: os ícones então não aparecem em lugar nenhum, ou aparecem em lugares aleatórios. O jogo não permite que addons meçam ou se prendam às regiões protegidas das placas de nome, então isso não pode ser corrigido pelo lado do Musca Auras. Com um addon de placas de nome, use o temporizador único acima.\n\nAs placas de nome dos inimigos precisam estar visíveis (tecla |cffffd100V|r).\n\nComo funciona:\n\n- A aura é um |cffffd100Grupo dinâmico|r com |cffffd100Agrupar por quadro|r definido como |cffffd100Placas de nome|r, e um ícone dentro.\n- O ícone usa um |cffffd100Atualizador de estado do gatilho|r em |cff99ccffUNIT_SPELLCAST_SUCCEEDED:player NAME_PLATE_UNIT_REMOVED PLAYER_TARGET_DIED|r.\n- Quando você conjura o feitiço, o código procura a placa de nome do seu alvo: ele testa |cff99ccffnameplate1|r até |cff99ccffnameplate40|r com |cff99ccffUnitIsUnit(token, \"target\")|r, que continua legível em combate. Ele inicia um temporizador para essa placa de nome e guarda a placa no estado (|cff99ccffunit = token|r), de modo que o grupo coloca o ícone nela.\n- Quando uma placa de nome desaparece (o monstro morreu ou saiu do alcance), seu temporizador é removido.\n\nLimitações: um temporizador é perdido quando a placa de nome desaparece, por exemplo quando você se afasta do monstro. A aura não sabe se o feitiço foi resistido ou dissipado.\n\nExemplo pronto para Imolar nível 1 (ID do feitiço 348, 15 segundos). Clique no botão de importar abaixo."
L["Import the nameplate DoT timer"] = "Importar o temporizador de DoT em placa de nome"
L["6. Recipe: pre-pull checklist"] = "6. Receita: lista de verificação pré-combate"
L["The idea: one group of icons that shows what is missing, only out of combat and in a group.\n\n1. |cff99ccff/wa|r, |cffffd100New|r, |cffffd100Dynamic Group|r. Name it \"Pre-pull\".\n2. In the group, |cffffd100Load|r tab: |cffffd100In Combat|r unchecked twice (the box shows a cross = \"not in combat\"), |cffffd100In Group|r checked.\n3. Add one icon per check, inside the group.\n\n|cffffd100Missing buff|r (Power Word: Fortitude, Mark of the Wild, Arcane Intellect, Blessings, Thorns, flask, food):\n\n- Trigger type: |cffffd100Aura|r\n- Unit: |cffffd100Player|r, Type: |cffffd100Buff|r\n- Aura name or spell ID: the buff. For buffs with ranks, add every rank you want to accept.\n- Show On: |cffffd100Aura(s) Missing|r\n\n|cffffd100Weapon enchant|r (poison, oil, stone): trigger |cffffd100Weapon Enchant|r, show when missing.\n\n|cffffd100Reagents and ammo|r (Soul Shards, arrows, Symbol of Kings...):\n\n- Trigger type: |cffffd100Item|r, |cffffd100Item Count|r\n- Item: the item ID\n- Count: lower than the number you want, for example |cff99ccff< 5|r\n\nBecause the group only loads out of combat, secret data never matters here.\n\nReady-made example for a Warlock (tested in game on Forever). Click the import button below.\n\n- Fortitude: the buff is missing (every rank, Prayer of Fortitude included) (in a party or raid)\n- Mark of the Wild: the buff is missing (every rank, Gift of the Wild included) (in a party or raid)\n- Arcane Intellect: the buff is missing (every rank, Arcane Brilliance included) (in a party or raid)\n- Demon Skin / Armor: neither Demon Skin nor Demon Armor is active (Warlock, solo included)\n- Soul Shards: fewer than 3 Soul Shards (item 6265) in your bags (Warlock, solo included)\n\nNone of them loads in combat. Buffs are matched by spell ID, so the group works with any client language. The IDs come from Classic 1.12 data: if an icon stays visible while you have the buff, report it."] = "A ideia: um grupo de ícones que mostra o que está faltando, somente fora de combate e em grupo.\n\n1. |cff99ccff/wa|r, |cffffd100Novo|r, |cffffd100Grupo dinâmico|r. Dê o nome \"Pre-pull\".\n2. No grupo, aba |cffffd100Carregar|r: |cffffd100Em combate|r desmarcado duas vezes (a caixa mostra uma cruz = \"fora de combate\"), |cffffd100Em grupo|r marcado.\n3. Adicione um ícone por verificação, dentro do grupo.\n\n|cffffd100Bônus ausente|r (Palavra de Poder: Fortitude, Marca da Natureza, Intelecto Arcano, Bênçãos, Espinhos, frasco, comida):\n\n- Tipo de gatilho: |cffffd100Aura|r\n- Unidade: |cffffd100Jogador|r, Tipo: |cffffd100Bônus|r\n- Nome da aura ou ID do feitiço: o bônus. Para bônus com níveis, adicione cada nível que você quiser aceitar.\n- Mostrar quando: |cffffd100Aura(s) ausente(s)|r\n\n|cffffd100Encantamento de arma|r (veneno, óleo, pedra): gatilho |cffffd100Encantamento de arma|r, mostrar quando ausente.\n\n|cffffd100Reagentes e munição|r (Fragmentos de Alma, flechas, Símbolo dos Reis...):\n\n- Tipo de gatilho: |cffffd100Item|r, |cffffd100Quantidade do item|r\n- Item: o ID do item\n- Quantidade: menor que o número que você quer, por exemplo |cff99ccff< 5|r\n\nComo o grupo só é carregado fora de combate, dados secretos não importam aqui.\n\nExemplo pronto para um Bruxo (testado no jogo no Forever). Clique no botão de importar abaixo.\n\n- Fortitude: o bônus está ausente (todos os níveis, incluindo Prece de Fortitude) (em grupo ou raide)\n- Marca da Natureza: o bônus está ausente (todos os níveis, incluindo Dádiva da Natureza) (em grupo ou raide)\n- Intelecto Arcano: o bônus está ausente (todos os níveis, incluindo Brilho Arcano) (em grupo ou raide)\n- Pele de Demônio / Armadura: nem Pele de Demônio nem Armadura de Demônio está ativa (Bruxo, inclusive solo)\n- Fragmentos de Alma: menos de 3 Fragmentos de Alma (item 6265) nas suas bolsas (Bruxo, inclusive solo)\n\nNenhum deles carrega em combate. Os bônus são identificados pelo ID do feitiço, então o grupo funciona com qualquer idioma do cliente. Os IDs vêm de dados do Classic 1.12: se um ícone continuar visível enquanto você tem o bônus, avise a gente."
L["Import the pre-pull checklist"] = "Importar a lista de verificação pré-combate"
L["7. Recipe: boss timeline"] = "7. Receita: linha do tempo do chefe"
L["Not tested in game yet.\n\n1. Find the encounter ID. Out of combat, create a test aura on |cff99ccffENCOUNTER_START|r and print the ID, or search it on Wowhead.\n2. For each boss ability, create a |cffffd100Progress Bar|r:\n    - Trigger type: |cffffd100Custom|r, Event Type: |cffffd100Event|r\n    - Event(s): |cff99ccffENCOUNTER_START|r\n    - Custom Trigger:\n\n|cff99ccff    function(event, encounterID, encounterName, difficultyID, groupSize)|r\n|cff99ccff        return encounterID == 610 -- replace with the boss encounter ID|r\n|cff99ccff    end|r\n\n    - Hide: |cffffd100Timed|r, Duration: the time of the first cast after the pull, in seconds.\n3. |cffffd100Load|r tab: |cffffd100Encounter ID(s)|r = the same ID. The aura unloads when the encounter ends, so a wipe does not leave the bar on screen.\n4. If a readable event marks a new phase (an emote, |cff99ccffENCOUNTER_STATE_CHANGED|r), use it to restart the timers.\n\nAbilities based on boss health % or on random timings cannot be predicted."] = "Ainda não testado no jogo.\n\n1. Encontre o ID do encontro. Fora de combate, crie uma aura de teste em |cff99ccffENCOUNTER_START|r e mostre o ID, ou procure-o no Wowhead.\n2. Para cada habilidade do chefe, crie uma |cffffd100Barra de progresso|r:\n    - Tipo de gatilho: |cffffd100Personalizado|r, Tipo de evento: |cffffd100Evento|r\n    - Evento(s): |cff99ccffENCOUNTER_START|r\n    - Gatilho personalizado:\n\n|cff99ccff    function(event, encounterID, encounterName, difficultyID, groupSize)|r\n|cff99ccff        return encounterID == 610 -- replace with the boss encounter ID|r\n|cff99ccff    end|r\n\n    - Esconder: |cffffd100Temporizado|r, Duração: o tempo da primeira conjuração após o início do combate, em segundos.\n3. Aba |cffffd100Carregar|r: |cffffd100ID(s) do encontro|r = o mesmo ID. A aura é descarregada quando o encontro termina, então um wipe não deixa a barra na tela.\n4. Se um evento legível marcar uma nova fase (um emote, |cff99ccffENCOUNTER_STATE_CHANGED|r), use-o para reiniciar os temporizadores.\n\nHabilidades baseadas na % de vida do chefe ou em tempos aleatórios não podem ser previstas."
L["8. Custom code"] = "8. Código personalizado"
L["In custom code, check every value before you compare it or do math with it:\n\n|cff99ccffif issecretvalue and issecretvalue(value) then|r\n|cff99ccff    return false|r\n|cff99ccffend|r\n\nWithout this check, the code stops with a Lua error in combat. Musca Auras does not show those errors: the aura just keeps its last state.\n\nIn combat, the |cff99ccffC_UnitAuras|r functions refuse addon code when auras are secret. They stop the code with \"Auras cannot be accessed when secret while tainted\" (tested in game): call them under |cff99ccffpcall|r, or only out of combat.\n\nFor health events, use |cff99ccffUNIT_HEALTH|r: |cff99ccffUNIT_HEALTH_FREQUENT|r does not exist on Forever.\n\nOther tools:\n\n- |cff99ccff/dump <expression>|r shows the content of a value in chat, secret values included.\n- |cff99ccff/eventtrace|r shows events and which of their values are secret.\n- There are no training dummies on Forever. Test in real combat: pull any mob or duel a friend."] = "Em código personalizado, verifique cada valor antes de compará-lo ou de fazer contas com ele:\n\n|cff99ccffif issecretvalue and issecretvalue(value) then|r\n|cff99ccff    return false|r\n|cff99ccffend|r\n\nSem essa verificação, o código para com um erro de Lua em combate. O Musca Auras não mostra esses erros: a aura simplesmente mantém seu último estado.\n\nEm combate, as funções de |cff99ccffC_UnitAuras|r recusam código de addon quando as auras são secretas. Elas param o código com \"Auras cannot be accessed when secret while tainted\" (testado no jogo): chame-as sob |cff99ccffpcall|r, ou apenas fora de combate.\n\nPara eventos de vida, use |cff99ccffUNIT_HEALTH|r: |cff99ccffUNIT_HEALTH_FREQUENT|r não existe no Forever.\n\nOutras ferramentas:\n\n- |cff99ccff/dump <expressão>|r mostra o conteúdo de um valor no chat, inclusive valores secretos.\n- |cff99ccff/eventtrace|r mostra os eventos e quais dos seus valores são secretos.\n- Não há bonecos de treino no Forever. Teste em combate real: ataque qualquer monstro ou duele com um amigo."
L["9. Importing auras from Wago"] = "9. Importando auras do Wago"
L["Most packs made for Classic Era, Season of Discovery or Retail need work:\n\n- replace combat log triggers (section 5 for DoTs, |cff99ccffUNIT_COMBAT:player|r for damage taken);\n- replace spell names by the spell IDs of your ranks;\n- rewrite custom code that calls old functions;\n- move buff and consumable checks out of combat (section 6).\n\nFound an aura that should work and does not? Report it: https://github.com/dldvlpr-addons-wow/Musca-Auras/issues"] = "A maioria dos pacotes feitos para Classic Era, Temporada de Descoberta ou Retail precisa de ajustes:\n\n- substitua os gatilhos do registro de combate (seção 5 para DoTs, |cff99ccffUNIT_COMBAT:player|r para o dano recebido);\n- substitua os nomes de feitiços pelos IDs dos seus níveis;\n- reescreva o código personalizado que chama funções antigas;\n- mova as verificações de bônus e consumíveis para fora de combate (seção 6).\n\nEncontrou uma aura que deveria funcionar e não funciona? Avise a gente: https://github.com/dldvlpr-addons-wow/Musca-Auras/issues"
L["10. Coming from ForeverAuras"] = "10. Vindo do ForeverAuras"
L["Export your auras from ForeverAuras, then paste the strings in the Musca Auras import window. Groups work too.\nMusca Auras converts them on import, and lists in the chat what it could not convert.\n\nWhat each one becomes:\n\n- Cooldown Manager trigger, cooldown: Cooldown trigger (spell ID, or name if ForeverAuras used names)\n- Cooldown Manager trigger, buff: Aura trigger (your buffs, or your debuffs on the target)\n- Cooldown Manager trigger, item: Item cooldown trigger\n- Aura (Blizzard) trigger: Aura trigger with Game Categories (sorting removed). Game Categories shows nothing at the moment.\n- Dispel type icon: Dispel Type Icon sub element\n- Dispel type border: Border colored by dispel type\n- Swing Timer, Ammo: same triggers (Ammo: the item list now filters the equipped ammo)\n- Role, Tracking, Equipment Durability, Bag Space: same triggers (Tracking: by spell ID only, no \"always\" mode)\n\nNot converted: TimelineParser triggers (they need the ExRT_Reminder addon and a boss timeline, which WoW Forever does not show). A Cooldown Manager cooldown trigger with several spells keeps the first one.\nDo not run both addons at the same time."] = "Exporte suas auras do ForeverAuras e cole as strings na janela de importação do Musca Auras. Grupos também funcionam.\nO Musca Auras as converte na importação e lista no chat o que não conseguiu converter.\n\nNo que cada uma se transforma:\n\n- Gatilho do Cooldown Manager, recarga: gatilho de Recarga (ID do feitiço, ou nome se o ForeverAuras usava nomes)\n- Gatilho do Cooldown Manager, bônus: gatilho de Aura (seus bônus, ou suas penalidades no alvo)\n- Gatilho do Cooldown Manager, item: gatilho de recarga de item\n- Gatilho de Aura (Blizzard): gatilho de Aura com Categorias do jogo (ordenação removida). As Categorias do jogo não mostram nada por enquanto.\n- Ícone do tipo de dissipação: subelemento Ícone do tipo de dissipação\n- Borda do tipo de dissipação: Borda colorida pelo tipo de dissipação\n- Temporizador de golpe, Munição: mesmos gatilhos (Munição: a lista de itens agora filtra a munição equipada)\n- Função, Rastreamento, Durabilidade do equipamento, Espaço nas bolsas: mesmos gatilhos (Rastreamento: apenas por ID de feitiço, sem modo \"sempre\")\n\nNão convertidos: gatilhos do TimelineParser (precisam do addon ExRT_Reminder e de uma linha do tempo do chefe, que o WoW Forever não mostra). Um gatilho de recarga do Cooldown Manager com vários feitiços mantém o primeiro.\nNão execute os dois addons ao mesmo tempo."
L["|cff00ccffMusca Auras|r - Guide"] = "|cff00ccffMusca Auras|r - Guia"
L["Show always"] = "Mostrar sempre"
L["Show in combat"] = "Mostrar em combate"
L["Show out of combat"] = "Mostrar fora de combate"
L["Enable"] = "Ativar"
L["Disable"] = "Desativar"
L["Edit in /wa"] = "Editar em /wa"
L["Click the aura %s will follow. Right click: cancel."] = "Clique na aura que %s vai seguir. Clique direito: cancelar."
L["Keep the changes made to the placement of your auras?"] = "Manter as alterações feitas no posicionamento das suas auras?"
L["Save and quit"] = "Salvar e sair"
L["Discard"] = "Descartar"
L["Snap"] = "Alinhar"
L["Revert"] = "Reverter"
L["Quit"] = "Sair"
L["Placement mode suspended during combat."] = "Modo de posicionamento suspenso durante o combate."
L["Close the Edit Mode first."] = "Feche o Modo de edição primeiro."
L["Anchor to..."] = "Ancorar a..."
L["Remove Anchor"] = "Remover âncora"
L["Its groups"] = "Seus grupos"
L["Drag: moves the whole group. Click inside: selects one level lower."] = "Arrastar: move o grupo inteiro. Clicar dentro: seleciona um nível abaixo."
L["Follows: %s"] = "Segue: %s"
L["Follows: its group"] = "Segue: seu grupo"
L["Follows: the screen"] = "Segue: a tela"
L["The placement mode does not open during combat."] = "O modo de posicionamento não abre durante o combate."
L["Unlock"] = "Desbloquear"
L["Opens the placement mode (/wa unlock): move, size and anchor the auras on the screen."] = "Abre o modo de posicionamento (/wa unlock): mova, redimensione e ancore as auras na tela."
L["Guide"] = "Guia"
L["Guide:"] = "Guia:"
L["learn Musca Auras"] = "aprenda Musca Auras"
L["Musca Auras Guide"] = "Guia do Musca Auras"
L["Learn everything about Musca Auras on WoW Forever: how an aura works, what changed in combat, what works and what does not, step-by-step recipes and ready-made auras to import."] = "Aprenda tudo sobre o Musca Auras no WoW Forever: como uma aura funciona, o que mudou em combate, o que funciona e o que não funciona, receitas passo a passo e auras prontas para importar."
L["/wa tutorial - Guide: learn everything about Musca Auras on WoW Forever, with auras to import"] = "/wa tutorial - Guia: aprenda tudo sobre o Musca Auras no WoW Forever, com auras para importar"
L["/wa cdm - Show or hide the Blizzard Cooldown Manager"] = "/wa cdm - Mostrar ou ocultar o Gerenciador de Recarga da Blizzard"
L["/wa unlock - Place your auras on the screen: move, resize, anchor them to each other"] = "/wa unlock - Posicione suas auras na tela: mova, redimensione, ancore umas nas outras"
L["/wa demo [aura name] - Show every loaded aura, or one aura, with sample timers to set up your layout"] = "/wa demo [nome da aura] - Mostra todas as auras carregadas, ou uma só, com cronômetros de exemplo para ajustar o layout"
L["/wa backups - List the daily copies of your auras"] = "/wa backups - Lista as cópias diárias das suas auras"
L["/wa restore <number> - Replace your auras with a daily copy and reload the UI"] = "/wa restore <número> - Substitui suas auras por uma cópia diária e recarrega a interface"
L["/wa deleted - List the auras deleted in the last 30 days"] = "/wa deleted - Lista as auras excluídas nos últimos 30 dias"
L["/wa undelete <number> - Import a deleted aura again"] = "/wa undelete <número> - Importa de novo uma aura excluída"
L["Time in Musca Auras: %.2fs / %ds (%.1f%%)"] = "Tempo no Musca Auras: %.2fs / %ds (%.1f%%)"
