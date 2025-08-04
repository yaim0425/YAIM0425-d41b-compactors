---------------------------------------------------------------------------------------------------
---> data-final-fixes.lua <---
---------------------------------------------------------------------------------------------------

--- Contenedor de funciones y datos usados
--- unicamente en este archivo
local ThisMOD = {}

---------------------------------------------------------------------------------------------------

---------------------------------------------------------------------------------------------------

--- Iniciar el modulo
function ThisMOD.Start()
    --- Valores de la referencia
    ThisMOD.setSetting()

    --- Entidades a afectar
    ThisMOD.BuildTiers()

    --- --- --- --- --- --- --- --- --- --- --- --- --- ---
    ---> Contenedor de las recetas
    --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    GPrefix.addDataRaw({
        { type = "recipe-category", name = ThisMOD.Prefix .. ThisMOD.Do },
        { type = "recipe-category", name = ThisMOD.Prefix .. ThisMOD.Undo }
    })

    --- --- --- --- --- --- --- --- --- --- --- --- --- ---
    --- Crear los subgrupos y los compactadores
    --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    --- Crear el subgrupo para los compactadores
    local Item = util.copy(GPrefix.items[ThisMOD.Splitter])
    GPrefix.duplicate_subgroup(Item.subgroup, ThisMOD.newSubgroup)

    --- Crear todos los compactadores
    for _, Tier in pairs(ThisMOD.Tiers) do
        ThisMOD.CreateRecipe(Tier)
        ThisMOD.CreateItem(Tier)
        ThisMOD.CreateEntity(Tier)
    end

    --- --- --- --- --- --- --- --- --- --- --- --- --- ---
    ---> Crear los subgroups y los objetos compactados
    --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    --- Crear los subgroups para los
    ThisMOD.CreateSubgroups()

    --- Filtrar los objetos a compactar
    local Items = {}
    for name, item in pairs(GPrefix.items) do
        if GPrefix.get_key(item.flags, "not-stackable") then goto JumpItem end
        if GPrefix.get_key(ThisMOD.AvoidTypes, item.type) then goto JumpItem end
        if GPrefix.get_key(ThisMOD.AvoidItems, item.name) then goto JumpItem end
        Items[name] = item
        :: JumpItem ::
    end

    --- Recorrer los objetos
    for _, item in pairs(Items) do
        ThisMOD.CreateItems(item)
        ThisMOD.CreateRecipes(item)
    end

    --- --- --- --- --- --- --- --- --- --- --- --- --- ---
    ---> Permirte la descompresión sin la maquina
    --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    table.insert(data.raw["character"].character.crafting_categories, ThisMOD.Prefix .. ThisMOD.Undo)
    table.insert(data.raw["god-controller"].default.crafting_categories, ThisMOD.Prefix .. ThisMOD.Undo)
end

--- Valores de la referencia
function ThisMOD.setSetting()
    --- Otros valores
    ThisMOD.Prefix      = "zzzYAIM0425-5200-"
    ThisMOD.name        = "compactors"

    --- Valores configurables
    ThisMOD.StackSize   = GPrefix.setting[ThisMOD.Prefix]["compacted-stack-size"] or 500
    ThisMOD.Ingredients = GPrefix.setting[ThisMOD.Prefix]["ingredients-to-compacted"] or 1000

    --- Referencia
    ThisMOD.newSubgroup = ThisMOD.Prefix .. ThisMOD.name
    ThisMOD.oldSubgroup = "splitter"

    ThisMOD.Splitter    = "splitter"
    ThisMOD.Furnace     = GPrefix.entities["electric-furnace"]

    --- Maquina y recetas
    ThisMOD.Machine     = "compactor"
    ThisMOD.Do          = "compacted"
    ThisMOD.Undo        = "decompacted"
    ThisMOD.Item        = "item-" .. ThisMOD.Do

    --- Colores a usar
    ThisMOD.Tiers       = {
        [""]             = { color = { r = 210, g = 180, b = 080 } },
        ["fast-"]        = { color = { r = 210, g = 060, b = 060 } },
        ["express-"]     = { color = { r = 080, g = 180, b = 210 } },
        ["turbo-"]       = { color = { r = 160, g = 190, b = 080 } },

        ["basic-"]       = { color = { r = 185, g = 185, b = 185 } },
        ["supersonic-"]  = { color = { r = 213, g = 041, b = 209 } },

        ["kr-advanced-"] = { color = { r = 160, g = 190, b = 080 } },
        ["kr-superior-"] = { color = { r = 213, g = 041, b = 209 } },
    }

    --- Valores a evitar
    ThisMOD.AvoidTypes  = {}
    table.insert(ThisMOD.AvoidTypes, "armor")

    ThisMOD.AvoidItems = {}
    table.insert(ThisMOD.AvoidItems, "pistol")

    --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    --- Propiedades a duplicar
    ThisMOD.Properties = {}
    table.insert(ThisMOD.Properties, "localised_name")
    table.insert(ThisMOD.Properties, "inventory_move_sound")
    table.insert(ThisMOD.Properties, "pick_sound")
    table.insert(ThisMOD.Properties, "drop_sound")
    table.insert(ThisMOD.Properties, "order")
    table.insert(ThisMOD.Properties, "icons")

    --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    --- Inicializar la variable
    ThisMOD.Graphics           = {}

    --- Imagenes para los iconos
    ThisMOD.Graphics.Icon      = {
        ArrowU = "__zzzYAIM0425-5200-compactors__/graphics/icons/u.png",
        ArrowD = "__zzzYAIM0425-5200-compactors__/graphics/icons/d.png",
        Base   = "__zzzYAIM0425-5200-compactors__/graphics/icons/base.png",
        Mask   = "__zzzYAIM0425-5200-compactors__/graphics/icons/mask.png"
    }

    --- Imagenes para las entidades
    ThisMOD.Graphics.Entity    = {
        Base    = "__zzzYAIM0425-5200-compactors__/graphics/entities/base.png",
        Mask    = "__zzzYAIM0425-5200-compactors__/graphics/entities/mask.png",
        Shadow  = "__zzzYAIM0425-5200-compactors__/graphics/entities/shadow.png",
        Working = "__zzzYAIM0425-5200-compactors__/graphics/entities/working.png"
    }

    --- Flechas a escala
    ThisMOD.Graphics.ArrowU    = { icon = ThisMOD.Graphics.Icon.ArrowU, scale = 0.30 }
    ThisMOD.Graphics.ArrowD    = { icon = ThisMOD.Graphics.Icon.ArrowD, scale = 0.30 }
    ThisMOD.Graphics.Indicator = {
        icon  = data.raw["virtual-signal"]["signal-item-parameter"].icon,
        scale = 0.15,
        shift = { -14, -14 }
    }
end

---------------------------------------------------------------------------------------------------

---------------------------------------------------------------------------------------------------

--- Entidades a afectar
function ThisMOD.BuildTiers()
    for _, Entity in pairs(data.raw[ThisMOD.Splitter]) do
        --- Validación
        if Entity.hidden then goto JumpEntity end
        if not Entity.minable then goto JumpEntity end
        if not Entity.minable.results then goto JumpEntity end

        --- Eliminar los indicadores
        local tier = GPrefix.delete_prefix(Entity.name)
        tier = string.gsub(tier, "^[0-9%-]+", "")
        tier = string.gsub(tier, ThisMOD.Splitter, "")
        if not ThisMOD.Tiers[tier] then goto JumpEntity end

        --- Crear el espacio para la entidad
        local Space         = ThisMOD.Tiers[tier] or {}
        ThisMOD.Tiers[tier] = Space

        --- Guardar la información
        if Entity.minable and Entity.minable.results then
            for _, result in pairs(Entity.minable.results) do
                local item = GPrefix.items[result.name]
                if item and item.place_result then
                    if item.place_result == Entity.name then
                        Space.item = item
                        break
                    end
                end
            end
        end

        if not Space.item or not GPrefix.recipes[Space.item.name] then
            goto JumpEntity
        end

        Space.name       = tier
        Space.entity     = Entity
        Space.recipe     = GPrefix.recipes[Space.item.name][1]
        Space.technology = GPrefix.getTechnology(Space.recipe.name)

        if not Space.technology then
            local Default    = GPrefix.get_recipe_of_ingredient(Space.recipe)
            Space.technology = GPrefix.getTechnology(Default, true)
        end

        --- Receptor del salto
        :: JumpEntity ::
    end

    --- Niveles sin  entidades
    for key, Tier in pairs(ThisMOD.Tiers) do
        if not Tier.name then
            ThisMOD.Tiers[key] = nil
        end
    end
end

--- Crear las recetas
function ThisMOD.CreateRecipe(tier)
    --- --- --- --- --- --- --- --- --- --- --- --- --- ---
    ---> Cópiar los valores de la receta de referencia
    --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    local recipe                 = util.copy(tier.recipe)

    --- --- --- --- --- --- --- --- --- --- --- --- --- ---
    ---> Sobre escribir los valores variables
    --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    --- Sobre escribir los valores constantes
    recipe.subgroup              = ThisMOD.newSubgroup

    --- Nombre, apodo y descripción
    recipe.name                  = ThisMOD.Prefix .. GPrefix.delete_prefix(recipe.name)
    recipe.name                  = string.gsub(recipe.name, ThisMOD.Splitter, ThisMOD.Machine)

    local localised_name         = { "entity-name." .. ThisMOD.Prefix .. tier.name .. ThisMOD.Machine }
    recipe.localised_name        = { "", localised_name }

    local localised_description  = { "entity-description." .. ThisMOD.Prefix .. ThisMOD.Machine }
    recipe.localised_description = { "", localised_description }

    --- Remplazar el resultado principal
    local result                 = GPrefix.get_table(recipe.results, "name", tier.item.name)
    result.name                  = recipe.name

    --- Remplazar los ingredientes
    for _, ingredient in pairs(recipe.ingredients) do
        if string.find(ingredient.name, ThisMOD.Splitter) then
            local name = GPrefix.delete_prefix(ingredient.name)
            name = string.gsub(name, "^[0-9%-]+", "")
            name = string.gsub(name, ThisMOD.Splitter, "")
            if ThisMOD.Tiers[name] then
                ingredient.name = string.gsub(ingredient.name, ThisMOD.Splitter, ThisMOD.Machine)
                ingredient.name = ThisMOD.Prefix .. GPrefix.delete_prefix(ingredient.name)
            end
        end
    end

    --- Imagen de la receta
    recipe.icons = {
        { icon = ThisMOD.Graphics.Icon.Base },
        { icon = ThisMOD.Graphics.Icon.Mask, tint = tier.color },
    }

    --- --- --- --- --- --- --- --- --- --- --- --- --- ---
    ---> Crear el prototipo
    --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    --- Crear el prototipo
    GPrefix.addDataRaw({ recipe })

    --- Agregar a la tecnología
    GPrefix.addRecipeToTechnology(nil, tier.recipe.name, recipe)
end

--- Crear el objeto
function ThisMOD.CreateItem(tier)
    --- --- --- --- --- --- --- --- --- --- --- --- --- ---
    ---> Cópiar los valores del objeto de referencia
    --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    local item                  = GPrefix.duplicate_item(tier.item)

    --- --- --- --- --- --- --- --- --- --- --- --- --- ---
    ---> Sobre escribir los valores variables
    --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    --- Sobre escribir los valores constantes
    item.subgroup               = ThisMOD.newSubgroup

    --- Nombre, apodo y descripción
    item.name                   = ThisMOD.Prefix .. GPrefix.delete_prefix(tier.item.name)
    item.name                   = string.gsub(item.name, ThisMOD.Splitter, ThisMOD.Machine)

    local localised_name        = { "entity-name." .. ThisMOD.Prefix .. tier.name .. ThisMOD.Machine }
    item.localised_name         = { "", localised_name }

    local localised_description = { "entity-description." .. ThisMOD.Prefix .. ThisMOD.Machine }
    item.localised_description  = { "", localised_description }

    item.place_result           = item.name
    item.icons                  = {
        { icon = ThisMOD.Graphics.Icon.Base },
        { icon = ThisMOD.Graphics.Icon.Mask, tint = tier.color },
    }

    --- --- --- --- --- --- --- --- --- --- --- --- --- ---
    ---> Ordernar y crear el prototipo
    --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    --- Crear el prototipo
    GPrefix.addDataRaw({ item })
end

--- Obtener el color a usar
function ThisMOD.BrighterColor(color)
    local White = 240
    return {
        r = math.floor((color.r + White) / 2),
        g = math.floor((color.g + White) / 2),
        b = math.floor((color.b + White) / 2)
    }
end

--- Crear la entidad a usa
function ThisMOD.CreateEntity(tier)
    --- --- --- --- --- --- --- --- --- --- --- --- --- ---
    ---> Cópiar los valores de la entidad de referencia
    --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    --- Cópiar los valores de la entidad de referencia
    local entity = util.copy(ThisMOD.Furnace)

    --- --- --- --- --- --- --- --- --- --- --- --- --- ---
    ---> Borrar los valores inecesarios
    --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    entity.icon  = nil

    local Key    = GPrefix.get_key(entity.allowed_effects, "productivity")
    if Key then table.remove(entity.allowed_effects, Key) end

    --- --- --- --- --- --- --- --- --- --- --- --- --- ---
    ---> Sobre escribir los valores constantes
    --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    entity.corpse                             = "small-remnants"
    entity.max_health                         = 180
    entity.dying_explosion                    = "explosion"
    entity.collision_box                      = { { -0.2, -0.2 }, { 0.2, 0.2 } }
    entity.selection_box                      = { { -0.5, -0.5 }, { 0.5, 0.5 } }
    entity.crafting_categories                = { ThisMOD.Prefix .. ThisMOD.Do, ThisMOD.Prefix .. ThisMOD.Undo }
    entity.fast_replaceable_group             = ThisMOD.newSubgroup

    --- --- --- --- --- --- --- --- --- --- --- --- --- ---
    ---> Sobre escribir los valores variables
    --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    entity.name                               = ThisMOD.Prefix .. GPrefix.delete_prefix(tier.entity.name)
    entity.name                               = string.gsub(entity.name, ThisMOD.Splitter, ThisMOD.Machine)

    local localised_name                      = { "entity-name." .. ThisMOD.Prefix .. tier.name .. ThisMOD.Machine }
    entity.localised_name                     = { "", localised_name }

    local localised_description               = { "entity-description." .. ThisMOD.Prefix .. ThisMOD.Machine }
    entity.localised_description              = { "", localised_description }

    entity.icons                              = {
        { icon = ThisMOD.Graphics.Icon.Base },
        { icon = ThisMOD.Graphics.Icon.Mask, tint = tier.color },
    }

    entity.graphics_set                       = {
        animation              = {
            layers = {
                {
                    animation_speed = tier.entity.speed,
                    filename        = ThisMOD.Graphics.Entity.Base,
                    shift           = { 0, 0 },
                    width           = 96,
                    height          = 96,
                    scale           = 0.5,

                    frame_count     = 60,
                    line_length     = 10,
                    priority        = "high",
                },
                {
                    animation_speed = tier.entity.speed,
                    filename        = ThisMOD.Graphics.Entity.Mask,
                    shift           = { 0, 0 },
                    width           = 96,
                    height          = 96,
                    scale           = 0.5,

                    repeat_count    = 60,
                    priority        = "high",
                    tint            = tier.color,
                },
                {
                    animation_speed = tier.entity.speed,
                    filename        = ThisMOD.Graphics.Entity.Shadow,
                    shift           = { 0.5, 0 },
                    width           = 144,
                    height          = 96,
                    scale           = 0.5,

                    draw_as_shadow  = true,
                    frame_count     = 60,
                    line_length     = 10,
                },
            },
        },
        working_visualisations = {
            {
                animation = {
                    animation_speed = tier.entity.speed,
                    filename        = ThisMOD.Graphics.Entity.Working,
                    width           = 96,
                    height          = 96,
                    scale           = 0.5,

                    blend_mode      = "additive",
                    frame_count     = 30,
                    line_length     = 10,
                    priority        = "high",
                    tint            = ThisMOD.BrighterColor(tier.color),
                },
                light     = {
                    color     = ThisMOD.BrighterColor(tier.color),
                    shift     = { 0, 0.25 },
                    intensity = 0.4,
                    size      = 3,
                },
            },
        }
    }

    entity.energy_source                      = {
        emissions_per_minute = { pollution = (3 * 0.03125) / tier.entity.speed },
        usage_priority       = "secondary-input",
        type                 = "electric",
        drain                = "15kW"
    }

    entity.minable                            = {
        mining_time = 0.5,
        results     = {
            {
                type = "item",
                name = entity.name,
                amount = 1
            }
        }
    }
    entity.energy_source.emissions_per_minute = { pollution = (3 * 0.03125) / tier.entity.speed }
    entity.energy_usage                       = string.format("%dkW", math.floor((tier.entity.speed / 0.03125) * 90))
    entity.crafting_speed                     = tier.entity.speed

    if entity.next_upgrade then
        local name = GPrefix.delete_prefix(entity.next_upgrade)
        name = string.gsub(name, "^[0-9%-]+", "")
        name = string.gsub(name, ThisMOD.Splitter, "")
        if ThisMOD.Tiers[name] then
            local next_upgrade  = GPrefix.delete_prefix(entity.next_upgrade)
            next_upgrade        = string.gsub(next_upgrade, ThisMOD.Splitter, ThisMOD.Machine)
            entity.next_upgrade = ThisMOD.Prefix .. next_upgrade
        else
            entity.next_upgrade = nil
        end
    else
        entity.next_upgrade = nil
    end

    --- --- --- --- --- --- --- --- --- --- --- --- --- ---
    ---> Crear el prototipo
    --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    --- Crear el prototipo
    GPrefix.addDataRaw({ entity })
end

---------------------------------------------------------------------------------------------------

---------------------------------------------------------------------------------------------------

--- Crear los subgroups
function ThisMOD.CreateSubgroups()
    --- Cargar los subgrupos a duplicar
    local Subgroups = { [ThisMOD.newSubgroup] = {} }
    for _, item in pairs(GPrefix.items) do
        Subgroups[item.subgroup] = {}
    end

    --- Crear los subgrupo de los objetos compactados
    for oldSubgroup, _ in pairs(Subgroups) do
        local subgroup = data.raw["item-subgroup"][oldSubgroup]
        subgroup.order = "0" .. subgroup.order

        for i = 1, 3, 1 do
            local Name     = ""
            local Order    = 0
            local Subgroup = {}

            --- Cambiar el nombre del nuevo subgrupo
            if i == 1 then Name = ThisMOD.Do end
            if i == 2 then Name = ThisMOD.Undo end
            if i == 3 then Name = ThisMOD.Item end

            Name     = ThisMOD.Prefix .. GPrefix.delete_prefix(oldSubgroup) .. "-" .. Name
            Subgroup = GPrefix.duplicate_subgroup(oldSubgroup, Name)

            --- Cambiar el order
            if i == 1 then Order = 7 end
            if i == 2 then Order = 8 end
            if i == 3 then Order = 9 end

            Subgroup.order = Order .. Subgroup.order
        end
    end
end

--- Crear los objetos compactados
function ThisMOD.CreateItems(item)
    --- --- --- --- --- --- --- --- --- --- --- --- --- ---
    ---> Variable a usar
    --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    local Item = {}

    --- --- --- --- --- --- --- --- --- --- --- --- --- ---
    ---> Duplicar la propiedad
    --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    for _, key in pairs(ThisMOD.Properties) do
        Item[key] = util.copy(item[key])
    end

    --- --- --- --- --- --- --- --- --- --- --- --- --- ---
    ---> Modificar las propiedades
    --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    ---> Cambiar la propiedad
    Item.name                  = GPrefix.delete_prefix(item.name)
    Item.name                  = ThisMOD.Prefix .. Item.name .. "-x" .. ThisMOD.Ingredients
    Item.type                  = "item"
    Item.stack_size            = ThisMOD.StackSize
    Item.subgroup              = ThisMOD.Prefix .. GPrefix.delete_prefix(item.subgroup) .. "-" .. ThisMOD.Item

    Item.localised_description = { "" }
    table.insert(Item.localised_description, ThisMOD.Ingredients .. " ")
    table.insert(Item.localised_description, "[item=" .. item.name .. "] ")

    --- Agregar el indicador
    table.insert(Item.icons, ThisMOD.Graphics.Indicator)

    --- --- --- --- --- --- --- --- --- --- --- --- --- ---
    ---> Crear el prototipo
    --- --- --- --- --- --- --- --- --- --- --- --- --- ---
    GPrefix.addDataRaw({ Item })
end

--- Crear las recetas de los objetos compactados
function ThisMOD.CreateRecipes(item)
    --- --- --- --- --- --- --- --- --- --- --- --- --- ---
    ---> Variable a usar
    --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    local newItemName                 = GPrefix.delete_prefix(item.name)
    newItemName                       = ThisMOD.Prefix .. newItemName .. "-x" .. ThisMOD.Ingredients

    --- --- --- --- --- --- --- --- --- --- --- --- --- ---
    ---> Receta de compresión
    --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    --- Receta para la compresión
    local RecipeD                     = {}
    RecipeD.type                      = "recipe"
    RecipeD.name                      = ThisMOD.Prefix .. "d-" .. GPrefix.delete_prefix(item.name)
    RecipeD.localised_name            = util.copy(item.localised_name)
    RecipeD.icons                     = util.copy(item.icons)
    RecipeD.category                  = ThisMOD.Prefix .. ThisMOD.Do
    RecipeD.allow_decomposition       = false
    RecipeD.allow_as_intermediate     = false
    RecipeD.hide_from_player_crafting = true
    RecipeD.results                   = { { type = "item", name = newItemName, amount = 1 } }
    RecipeD.ingredients               = { { type = "item", name = item.name, amount = ThisMOD.Ingredients } }
    RecipeD.subgroup                  = ThisMOD.Prefix .. GPrefix.delete_prefix(item.subgroup) .. "-" .. ThisMOD.Do
    RecipeD.order                     = item.order

    --- Agregar el indicador
    table.insert(RecipeD.icons, ThisMOD.Graphics.ArrowD)

    --- Crear el prototipo
    GPrefix.addDataRaw({ RecipeD })

    --- Agregar la receta a las tecnologias
    GPrefix.addRecipeToTechnology(item.name, nil, RecipeD)

    --- --- --- --- --- --- --- --- --- --- --- --- --- ---
    ---> Receta de descompresión
    --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    --- Receta para la descompresión
    local RecipeU               = {}
    RecipeU.type                = "recipe"
    RecipeU.name                = ThisMOD.Prefix .. "u-" .. GPrefix.delete_prefix(item.name)
    RecipeU.localised_name      = util.copy(item.localised_name)
    RecipeU.icons               = util.copy(item.icons)
    RecipeU.category            = ThisMOD.Prefix .. ThisMOD.Undo
    RecipeU.allow_decomposition = false
    RecipeU.ingredients         = { { type = "item", name = newItemName, amount = 1 } }
    RecipeU.results             = { { type = "item", name = item.name, amount = ThisMOD.Ingredients } }
    RecipeU.subgroup            = ThisMOD.Prefix .. GPrefix.delete_prefix(item.subgroup) .. "-" .. ThisMOD.Undo
    RecipeU.order               = item.order

    --- Agregar el indicador
    table.insert(RecipeU.icons, ThisMOD.Graphics.Indicator)
    table.insert(RecipeU.icons, ThisMOD.Graphics.ArrowU)

    --- Crear el prototipo
    GPrefix.addDataRaw({ RecipeU })

    --- Agregar la receta a las tecnologias
    GPrefix.addRecipeToTechnology(item.name, nil, RecipeU)
end

---------------------------------------------------------------------------------------------------

---------------------------------------------------------------------------------------------------

--- Iniciar el modulo
ThisMOD.Start()

---------------------------------------------------------------------------------------------------
