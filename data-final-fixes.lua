---------------------------------------------------------------------------
---[ data-final-fixes.lua ]---
---------------------------------------------------------------------------





---------------------------------------------------------------------------
---[ Información del MOD ]---
---------------------------------------------------------------------------

local This_MOD = GMOD.get_id_and_name()
if not This_MOD then return end
GMOD[This_MOD.id] = This_MOD

---------------------------------------------------------------------------

function This_MOD.start()
    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    --- Valores de la referencia
    This_MOD.reference_values()

    --- Obtener los elementos
    This_MOD.get_elements()

    --- Modificar los elementos
    for _, spaces in pairs(This_MOD.to_be_processed) do
        for _, space in pairs(spaces) do
            --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

            -- --- Crear los elementos
            This_MOD.create_subgroup(space)
            This_MOD.create_item(space)
            This_MOD.create_entity(space)
            This_MOD.create_recipe(space)
            This_MOD.create_tech(space)

            --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
        end
    end

    --- Crear las recetas y los objetos comprimidos
    This_MOD.create_item___compact()
    This_MOD.create_recipe___compact()
    This_MOD.create_tech___compact()

    --- Fijar las posiciones actual
    GMOD.d00b.change_orders()

    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
end

function This_MOD.reference_values()
    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
    --- Validación
    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    --- Contenedor de los elementos que el MOD modoficará
    This_MOD.to_be_processed = {}

    --- Validar si se cargó antes
    if This_MOD.setting then return end

    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---





    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
    --- Valores de la referencia en todos los MODs
    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    --- Cargar la configuración
    This_MOD.setting = GMOD.setting[This_MOD.id] or {}

    --- Imagenes del mod
    This_MOD.path_graphics = "__" .. This_MOD.prefix .. This_MOD.name .. "__/graphics/"

    --- Imagenes para los iconos
    This_MOD.icon_graphics = {
        arrow_u = This_MOD.path_graphics .. "icon-u.png",
        arrow_d = This_MOD.path_graphics .. "icon-d.png",
        base    = This_MOD.path_graphics .. "icon-base.png",
        mask    = This_MOD.path_graphics .. "icon-mask.png"
    }

    --- Imagenes para las tech
    This_MOD.tech_graphics = {
        base = This_MOD.path_graphics .. "tech-base.png",
        mask = This_MOD.path_graphics .. "tech-mask.png"
    }

    --- Imagenes para las entidades
    This_MOD.entity_graphics = {
        base    = This_MOD.path_graphics .. "entities-base.png",
        mask    = This_MOD.path_graphics .. "entities-mask.png",
        shadow  = This_MOD.path_graphics .. "entities-shadow.png",
        working = This_MOD.path_graphics .. "entities-working.png"
    }

    --- Indicadores
    This_MOD.arrow_u___icon = { icon = This_MOD.icon_graphics.arrow_u, scale = 0.30 }
    This_MOD.arrow_d___icon = { icon = This_MOD.icon_graphics.arrow_d, scale = 0.30 }

    This_MOD.indicator = {
        icon  = GMOD.signal["item-parameter"],
        scale = 0.15,
        shift = { -14, -14 }
    }

    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---





    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
    --- Valores de la referencia en este MOD
    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    --- Valores configurables
    This_MOD.stack_size = This_MOD.setting["stack_size"] or true
    This_MOD.amount = This_MOD.setting["amount"] or 10

    --- Nombre de la maquina
    This_MOD.entity_name = "compactor"

    --- Entidad de referencia
    This_MOD.furnace = GMOD.entities["electric-furnace"]

    --- Categorias de fabricación
    This_MOD.category_do = "compressed"
    This_MOD.category_undo = "uncompressed"

    --- Nombre de los subgrupo
    This_MOD.new_subgroup = This_MOD.prefix .. This_MOD.name
    This_MOD.old_subgroup = GMOD.items["splitter"].subgroup

    --- Puntos de referencia
    This_MOD.item_tech = "transport-belt"
    This_MOD.splitter = "splitter"
    This_MOD.speed_base = GMOD.entities[This_MOD.item_tech].speed

    --- Valores a evitar
    This_MOD.ignore_types = { ["armor"] = true }
    This_MOD.ignore_items = { ["pistol"] = true }

    --- Colores a usar
    This_MOD.colors = {
        --- Base
        [""]                       = { r = 210, g = 180, b = 080 },
        ["fast-"]                  = { r = 210, g = 060, b = 060 },
        ["express-"]               = { r = 080, g = 180, b = 210 },
        ["turbo-"]                 = { r = 160, g = 190, b = 080 },

        --- Factorio+
        ["basic-"]                 = { r = 185, g = 185, b = 185 },
        ["supersonic-"]            = { r = 213, g = 041, b = 209 },

        --- Krastorio 2
        ["kr-advanced-"]           = { r = 160, g = 190, b = 080 },
        ["kr-superior-"]           = { r = 213, g = 041, b = 209 },

        --- Space Exploration
        ["se-space-"]              = { r = 200, g = 200, b = 200 },
        ["se-deep-space--black"]   = { r = 000, g = 000, b = 000 },
        ["se-deep-space--white"]   = { r = 255, g = 255, b = 255 },
        ["se-deep-space--red"]     = { r = 255, g = 000, b = 000 },
        ["se-deep-space--magenta"] = { r = 255, g = 000, b = 255 },
        ["se-deep-space--blue"]    = { r = 000, g = 000, b = 255 },
        ["se-deep-space--cyan"]    = { r = 000, g = 255, b = 255 },
        ["se-deep-space--green"]   = { r = 000, g = 255, b = 000 },
        ["se-deep-space--yellow"]  = { r = 255, g = 255, b = 000 },
    }

    --- Propiedades a duplicar
    This_MOD.properties = {}
    table.insert(This_MOD.properties, "localised_name")
    table.insert(This_MOD.properties, "inventory_move_sound")
    table.insert(This_MOD.properties, "pick_sound")
    table.insert(This_MOD.properties, "drop_sound")
    table.insert(This_MOD.properties, "stack_size")
    table.insert(This_MOD.properties, "order")
    table.insert(This_MOD.properties, "icons")

    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
end

---------------------------------------------------------------------------





---------------------------------------------------------------------------
---[ Cambios del MOD ]---
---------------------------------------------------------------------------

function This_MOD.get_elements()
    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
    --- Función para analizar cada entidad
    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    local function valide_entity(item, entity)
        --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
        --- Validación
        --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

        --- Validar el item
        if not item then return end
        if GMOD.is_hidde(item) then return end

        --- Validar la entidad
        if GMOD.is_hidde(entity) then return end

        --- Validar si ya fue procesado
        local That_MOD =
            GMOD.get_id_and_name(entity.name) or
            { ids = "-", name = entity.name }

        --- Identificar el tier
        local Tier = string.gsub(That_MOD.name, This_MOD.splitter, "")
        if not This_MOD.colors[Tier] then return end

        --- Validar si ya fue procesado
        local Name = string.gsub(That_MOD.name, This_MOD.splitter, This_MOD.entity_name)
        Name =
            GMOD.name .. That_MOD.ids ..
            This_MOD.id .. "-" ..
            Name

        if GMOD.entities[Name] ~= nil then return end

        --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---





        --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
        --- Valores para el proceso
        --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

        local Space = {}
        Space.item = item
        Space.entity = entity
        Space.name = Name

        Space.belt = string.gsub(That_MOD.name, This_MOD.splitter, This_MOD.item_tech)
        Space.tech = GMOD.get_technology(GMOD.recipes[Space.belt])

        Space.recipe = GMOD.recipes[Space.item.name]
        Space.recipe = Space.recipe and Space.recipe[1] or nil

        Space.color = This_MOD.colors[Tier]

        Space.localised_name = {
            "",
            { "entity-name." .. This_MOD.prefix .. This_MOD.entity_name },
            " - ",
            { "entity-name." .. Space.belt }
        }

        --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---





        --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
        --- Guardar la información
        --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

        This_MOD.to_be_processed[entity.type] = This_MOD.to_be_processed[entity.type] or {}
        This_MOD.to_be_processed[entity.type][entity.name] = Space

        --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
    end

    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---





    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
    --- Valores a afectar
    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    --- Entidad que se va a duplicar
    for _, entity in pairs(data.raw.splitter) do
        local Result = GMOD.parameter.get_item_create.place_result
        Result = GMOD.get_item_create(entity, Result)
        valide_entity(Result, entity)
    end

    --- Item a afectar
    This_MOD.items = {}
    for _, item in pairs(GMOD.items) do
        This_MOD.add_item(item)
    end

    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
end

function This_MOD.add_item(item)
    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
    --- Validación
    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    if GMOD.get_key(item.flags, "not-stackable") then return end
    if GMOD.get_key(item.flags, "spawnable") then return end
    if This_MOD.ignore_types[item.type] then return end
    if This_MOD.ignore_items[item.name] then return end

    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---





    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
    --- Valores a usar
    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    --- Contenedor de la info
    local Space = {}

    --- Guardar el objeto
    Space.item = item

    --- Calcular la cantidad
    Space.amount = This_MOD.setting.amount
    if This_MOD.setting.stack_size then
        Space.amount = Space.amount * item.stack_size
        if Space.amount > 65000 then
            Space.amount = 65000
        end
    end

    --- Separar el nombre
    local That_MOD =
        GMOD.get_id_and_name(item.name) or
        { ids = "-", name = item.name }

    --- Valores comunes
    local Prefix =
        GMOD.name .. That_MOD.ids ..
        This_MOD.id .. "-"

    local Amount = (
            This_MOD.setting.stack_size and
            item.stack_size .. "x" .. This_MOD.setting.amount or
            Space.amount
        ) .. "u-" ..
        That_MOD.name

    --- Nombre del objeto
    Space.item_name =
        Prefix ..
        Amount

    --- Nombre de la recetas
    Space.do_name =
        Prefix ..
        This_MOD.category_do .. "-" ..
        Amount

    Space.undo_name =
        Prefix ..
        This_MOD.category_undo .. "-" ..
        Amount

    --- Nombre del nuevo subgrupo
    That_MOD =
        GMOD.get_id_and_name(Space.item.subgroup) or
        { ids = "-", name = Space.item.subgroup }

    Prefix =
        GMOD.name .. That_MOD.ids ..
        This_MOD.id .. "-"

    Space.item_subgroup =
        Prefix ..
        That_MOD.name

    Space.do_subgroup =
        Prefix ..
        This_MOD.category_do .. "-" ..
        That_MOD.name

    Space.undo_subgroup =
        Prefix ..
        This_MOD.category_undo .. "-" ..
        That_MOD.name

    --- Guardar los valores
    This_MOD.items[item.name] = Space

    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
end

---------------------------------------------------------------------------

function This_MOD.create_subgroup(space)
    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
    --- Validación
    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    if not space.item then return end

    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---





    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
    --- Crear un nuevo subgrupo
    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    local Old = This_MOD.old_subgroup
    local New = This_MOD.new_subgroup
    GMOD.duplicate_subgroup(Old, New)

    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
end

function This_MOD.create_item(space)
    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
    --- Validación
    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    if not space.item then return end

    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---





    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
    --- Duplicar el elemento
    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    local Item = GMOD.copy(space.item)

    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---





    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
    --- Cambiar algunas propiedades
    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    --- Nombre
    Item.name = space.name

    --- Apodo y descripción
    Item.localised_name = space.localised_name
    Item.localised_description = { "", { "entity-description." .. This_MOD.prefix .. This_MOD.entity_name } }

    --- Entidad a crear
    Item.place_result = space.name

    --- Agregar indicador del MOD
    Item.icons = {
        { icon = This_MOD.icon_graphics.base },
        { icon = This_MOD.icon_graphics.mask, tint = space.color },
    }

    --- Actualizar subgrupo
    Item.subgroup = This_MOD.new_subgroup

    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---





    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
    --- Guardar para afectar
    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    This_MOD.add_item(Item)

    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---





    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
    --- Crear el prototipo
    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    GMOD.extend(Item)

    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
end

function This_MOD.create_entity(space)
    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
    --- Validación
    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    if not space.entity then return end

    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---





    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
    --- Duplicar el elemento
    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    local Entity = GMOD.copy(This_MOD.furnace)

    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---





    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
    --- Cambiar algunas propiedades
    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    --- Nombre
    Entity.name = space.name

    --- Apodo y descripción
    Entity.localised_name = space.localised_name
    Entity.localised_description = { "", { "entity-description." .. This_MOD.prefix .. This_MOD.entity_name } }

    --- Elimnar propiedades inecesarias
    Entity.factoriopedia_simulation = nil

    --- Cambiar icono
    Entity.icons = {
        { icon = This_MOD.icon_graphics.base },
        { icon = This_MOD.icon_graphics.mask, tint = space.color },
    }

    --- Objeto a minar
    Entity.minable.results = { {
        type = "item",
        name = space.name,
        amount = 1
    } }

    --- Siguiente tier
    Entity.next_upgrade = (function(entity)
        --- Validación
        if not entity then return end

        --- Validar si ya fue procesado
        local That_MOD =
            GMOD.get_id_and_name(entity) or
            { ids = "-", name = entity }

        --- Identificar el tier
        local Tier = string.gsub(That_MOD.name, This_MOD.splitter, "")
        if not This_MOD.colors[Tier] then return end

        --- Validar si ya fue procesado
        local Name = string.gsub(That_MOD.name, This_MOD.splitter, This_MOD.entity_name)
        Name =
            GMOD.name .. That_MOD.ids ..
            This_MOD.id .. "-" ..
            Name

        --- La entidad ya existe
        if GMOD.entities[Name] ~= nil then
            return Name
        end

        --- La entidad existirá
        for _, Spaces in pairs(This_MOD.to_be_processed) do
            for _, Space in pairs(Spaces) do
                if Space.entity.name == entity then
                    return Name
                end
            end
        end
    end)(space.entity.next_upgrade)

    --- Cuerpo y explosion
    Entity.corpse = "small-remnants"
    Entity.dying_explosion = "explosion"

    --- Vida
    Entity.max_health = 180

    --- Caja de colision y selección
    Entity.collision_box = { { -0.2, -0.2 }, { 0.2, 0.2 } }
    Entity.selection_box = { { -0.5, -0.5 }, { 0.5, 0.5 } }

    --- Categorias de fabricación
    Entity.crafting_categories = {
        This_MOD.prefix .. This_MOD.category_do,
        This_MOD.prefix .. This_MOD.category_undo
    }

    --- Remplazó rapido
    Entity.fast_replaceable_group = This_MOD.new_subgroup

    --- Imagen de la entidad
    Entity.graphics_set = {
        animation = {
            layers = {
                {
                    animation_speed = space.entity.speed,
                    filename        = This_MOD.entity_graphics.base,
                    shift           = { 0, 0 },
                    width           = 96,
                    height          = 96,
                    scale           = 0.5,

                    frame_count     = 60,
                    line_length     = 10,
                    priority        = "high",
                },
                {
                    animation_speed = space.entity.speed,
                    filename        = This_MOD.entity_graphics.mask,
                    shift           = { 0, 0 },
                    width           = 96,
                    height          = 96,
                    scale           = 0.5,

                    repeat_count    = 60,
                    priority        = "high",
                    tint            = space.color,
                },
                {
                    animation_speed = space.entity.speed,
                    filename        = This_MOD.entity_graphics.shadow,
                    shift           = { 0.5, 0 },
                    width           = 144,
                    height          = 96,
                    scale           = 0.5,

                    draw_as_shadow  = true,
                    frame_count     = 60,
                    line_length     = 10,
                },
            }
        },
        working_visualisations = { {
            animation = {
                animation_speed = space.entity.speed,
                filename        = This_MOD.entity_graphics.working,
                width           = 96,
                height          = 96,
                scale           = 0.5,

                blend_mode      = "additive",
                frame_count     = 30,
                line_length     = 10,
                priority        = "high",
                tint            = space.color,
            },
            light     = {
                color     = space.color,
                shift     = { 0, 0.25 },
                intensity = 0.4,
                size      = 3,
            }
        } }
    }

    --- Tipo de energía a usar
    Entity.energy_source = {
        emissions_per_minute = { pollution = (3 * 0.03125) / space.entity.speed },
        usage_priority = "secondary-input",
        type = "electric",
        drain = "15kW"
    }

    --- Energía a consumir
    Entity.energy_usage = string.format("%dkW", math.floor((space.entity.speed / 0.03125) * 90))

    --- Velocidad de fabricación
    Entity.crafting_speed = space.entity.speed / This_MOD.speed_base
    Entity.crafting_speed = math.floor(Entity.crafting_speed * 10 + 0.5)
    Entity.crafting_speed = Entity.crafting_speed / 10

    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---





    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
    --- Crear el prototipo
    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    GMOD.extend(Entity)

    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---





    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
    --- Crear las categorias de fabricación
    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    GMOD.extend(
        { type = "recipe-category", name = This_MOD.prefix .. This_MOD.category_do },
        { type = "recipe-category", name = This_MOD.prefix .. This_MOD.category_undo }
    )

    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---





    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
    --- Permirte la descompresión sin la maquina
    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    table.insert(data.raw["character"].character.crafting_categories, This_MOD.prefix .. This_MOD.category_undo)
    table.insert(data.raw["god-controller"].default.crafting_categories, This_MOD.prefix .. This_MOD.category_undo)

    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
end

function This_MOD.create_recipe(space)
    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
    --- Validación
    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    if not space.recipe then return end

    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---





    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
    --- Duplicar el elemento
    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    local Recipe = GMOD.copy(space.recipe)

    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---





    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
    --- Cambiar algunas propiedades
    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    --- Nombre
    Recipe.name = space.name

    --- Apodo y descripción
    Recipe.localised_name = space.localised_name
    Recipe.localised_description = { "", { "entity-description." .. This_MOD.prefix .. This_MOD.entity_name } }

    --- Elimnar propiedades inecesarias
    Recipe.main_product = nil

    --- Cambiar icono
    Recipe.icons = {
        { icon = This_MOD.icon_graphics.base },
        { icon = This_MOD.icon_graphics.mask, tint = space.color },
    }

    --- Habilitar la receta
    Recipe.enabled = space.tech == nil

    --- Ingredientes
    for _, ingredient in pairs(Recipe.ingredients) do
        ingredient.name = (function(name)
            --- Validación
            if not name then return end

            --- Validar si ya fue procesado
            local That_MOD =
                GMOD.get_id_and_name(name) or
                { ids = "-", name = name }

            --- Identificar el tier
            local Tier = string.gsub(That_MOD.name, This_MOD.splitter, "")
            if not This_MOD.colors[Tier] then return end

            --- Validar si ya fue procesado
            local Name = string.gsub(That_MOD.name, This_MOD.splitter, This_MOD.entity_name)
            Name =
                GMOD.name .. That_MOD.ids ..
                This_MOD.id .. "-" ..
                Name

            --- La entidad ya existe
            if GMOD.entities[Name] ~= nil then
                return Name
            end

            --- La entidad existirá
            for _, Spaces in pairs(This_MOD.to_be_processed) do
                for _, Space in pairs(Spaces) do
                    if Space.entity.name == name then
                        return Name
                    end
                end
            end
        end)(ingredient.name) or ingredient.name
    end

    --- Resultados
    Recipe.results = { {
        type = "item",
        name = space.name,
        amount = 1
    } }

    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---





    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
    --- Crear el prototipo
    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    GMOD.extend(Recipe)

    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
end

function This_MOD.create_tech(space)
    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
    --- Validación
    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    if not space.tech then return end
    if data.raw.technology[space.name .. "-tech"] then return end

    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---





    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
    --- Duplicar el elemento
    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    local Tech = GMOD.copy(space.tech)

    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---





    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
    --- Cambiar algunas propiedades
    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    --- Nombre
    Tech.name = space.name .. "-tech"

    --- Apodo y descripción
    Tech.localised_name = space.localised_name
    Tech.localised_description = { "", { "entity-description." .. This_MOD.prefix .. This_MOD.entity_name } }

    --- Cambiar icono
    Tech.icons = {
        { icon = This_MOD.tech_graphics.base, icon_size = 128 },
        { icon = This_MOD.tech_graphics.mask, icon_size = 128, tint = space.color },
    }

    --- Tech previas
    Tech.prerequisites = { space.tech.name }
    for _, ingredient in pairs(data.raw.recipe[space.name].ingredients) do
        if GMOD.has_id(ingredient.name, This_MOD.id) then
            if Tech.prerequisites[1] == space.tech.name then
                Tech.prerequisites = {}
            end
            if data.raw.technology[ingredient.name .. "-tech"] then
                table.insert(Tech.prerequisites, ingredient.name .. "-tech")
            end
        end
    end

    --- Efecto de la tech
    Tech.effects = { {
        type = "unlock-recipe",
        recipe = space.name
    } }

    --- Tech se activa con una fabricación
    if Tech.research_trigger then
        Tech.research_trigger = {
            type = "craft-item",
            item = space.belt,
            count = 1
        }
    end

    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---





    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
    --- Crear el prototipo
    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    GMOD.extend(Tech)

    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
end

---------------------------------------------------------------------------

function This_MOD.create_item___compact()
    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
    --- Función de procesamiento
    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    local function create_item(space)
        --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
        --- Validación
        --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

        if GMOD.items[space.name] then return end

        --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---





        --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
        --- Duplicar el objeto
        --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

        local Item = {}
        for _, name in pairs(This_MOD.properties) do
            Item[name] = GMOD.copy(space.item[name])
        end

        --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---





        --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
        --- Cambiar algunas propiedades
        --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

        --- Cambiar tipo
        Item.type = "item"

        --- Nombre
        Item.name = space.item_name

        --- Apodo
        Item.localised_description = { "",
            "[img=virtual-signal.signal-stack-size]"
        }

        local Index = tostring(space.amount)
        for n = 1, #Index do
            table.insert(
                Item.localised_description,
                "[img=virtual-signal.signal-" .. Index:sub(n, n) .. "]"
            )
        end

        table.insert(
            Item.localised_description,
            "[item=" .. space.item.name .. "]"
        )

        --- Nombre del nuevo subgrupo
        Item.subgroup = space.item_subgroup

        --- Agregar indicador del MOD
        table.insert(Item.icons, GMOD.copy(This_MOD.indicator))
        if GMOD.has_id(Item.name, "d01b") then
            Item.icons[#Item.icons].scale = 0.23
        end

        --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---





        --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
        --- Crear el subgrupo para el objeto
        --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

        --- Duplicar el subgrupo
        if not GMOD.subgroups[Item.subgroup] then
            GMOD.duplicate_subgroup(space.item.subgroup, Item.subgroup)

            --- Renombrar
            local Subgroup = GMOD.subgroups[Item.subgroup]
            local Order = GMOD.subgroups[space.item.subgroup].order

            --- Actualizar el order
            Subgroup.order = 2 .. Order:sub(2)
        end

        --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---





        --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
        --- Crear el prototipo
        --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

        GMOD.extend(Item)

        --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
    end

    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---





    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
    --- Recorrer los objetos seleccionados
    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    for _, space in pairs(This_MOD.items) do
        create_item(space)
    end

    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
end

function This_MOD.create_recipe___compact()
    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
    --- Función de procesamiento
    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    local function create_recipe(space, category)
        --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
        --- Validación
        --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

        local Name =
            category == This_MOD.category_do and
            space.do_name or
            space.undo_name

        if data.raw.recipe[Name] then return end

        --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---





        --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
        --- Receta
        --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

        --- Nueva receta
        local Recipe = {}

        ---- Tipo, nombre y apodo
        Recipe.type = "recipe"
        Recipe.name = Name
        Recipe.localised_name = util.copy(space.item.localised_name)

        --- iconos
        Recipe.icons = util.copy(space.item.icons)

        --- Categoria
        Recipe.category = This_MOD.prefix .. category

        --- Nuevo subgrupo
        Recipe.subgroup =
            category == This_MOD.category_do and
            space.do_subgroup or
            space.undo_subgroup

        --- Ocultar receta del menú del jugador
        Recipe.hide_from_player_crafting = category == This_MOD.category_do

        --- Desactivar la recetas
        Recipe.enabled = false

        --- Compresión
        if category == This_MOD.category_do then
            --- Ingredientes y resultado
            Recipe.results = { { type = "item", name = space.item_name, amount = 1 } }
            Recipe.ingredients = { { type = "item", name = space.item.name, amount = space.amount } }

            --- Indicador del MOD
            table.insert(Recipe.icons, This_MOD.arrow_d___icon)
        end

        --- Descompresión
        if category == This_MOD.category_undo then
            --- Ingredientes y resultado
            Recipe.ingredients = { { type = "item", name = space.item_name, amount = 1 } }
            Recipe.results = { { type = "item", name = space.item.name, amount = space.amount } }

            --- Indicador del MOD
            table.insert(Recipe.icons, This_MOD.arrow_u___icon)
        end

        --- Modificar indicador
        if GMOD.has_id(Recipe.name, "d01b") then
            Recipe.icons[#Recipe.icons] = GMOD.copy(Recipe.icons[#Recipe.icons])
            Recipe.icons[#Recipe.icons].scale = 0.5
        end

        --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---





        --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
        --- Crear el subgrupo para el objeto
        --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

        --- Duplicar el subgrupo
        if not GMOD.subgroups[Recipe.subgroup] then
            GMOD.duplicate_subgroup(space.item.subgroup, Recipe.subgroup)

            --- Renombrar
            local Subgroup = GMOD.subgroups[Recipe.subgroup]
            local Order = GMOD.subgroups[space.item.subgroup].order
            local Index = category == This_MOD.category_undo and 1 or 2

            --- Actualizar el order
            Subgroup.order = Index .. Order:sub(2)
        end

        --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---





        --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
        --- Crear el prototipo
        --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

        GMOD.extend(Recipe)

        --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
    end

    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---





    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
    --- Recorrer los objetos seleccionados
    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    for _, space in pairs(This_MOD.items) do
        create_recipe(space, This_MOD.category_do)
        create_recipe(space, This_MOD.category_undo)
    end

    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
end

function This_MOD.create_tech___compact()
    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
    --- Función de procesamiento
    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    local function create_tech(space)
        --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
        --- Validación
        --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

        if not GMOD.items[space.item_name] then return end

        --- Tech previa
        local Prerequisites = GMOD.get_technology(GMOD.recipes[space.item.name], true)
        if not Prerequisites then
            data.raw.recipe[space.do_name].enabled = true
            data.raw.recipe[space.undo_name].enabled = true
            return
        end

        --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---





        --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
        --- Crear la tech
        --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

        local Tech = {}

        --- Tipo y nombre
        Tech.type = "technology"
        Tech.name = space.item_name .. "-tech"

        --- Apodo y descripción
        Tech.localised_name = space.item.localised_name
        Tech.localised_description = { "" }

        --- Cambiar icono
        Tech.icons = space.item.icons
        Tech.icons = GMOD.items[space.item_name].icons
        Tech.icons = GMOD.copy(Tech.icons)
        for _, icon in pairs(Tech.icons) do
            icon.icon_size = icon.icon_size or 64
            icon.scale = icon.scale or 0.5
        end

        --- Tech previas
        Tech.prerequisites = { Prerequisites.name }

        --- Efecto de la tech
        Tech.effects = {
            { type = "unlock-recipe", recipe = space.do_name },
            { type = "unlock-recipe", recipe = space.undo_name }
        }

        --- Tech se activa con una fabricación
        Tech.research_trigger = {
            type = "craft-item",
            item = space.item.name,
            count = space.amount
        }

        --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---





        --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
        --- Crear el prototipo
        --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

        GMOD.extend(Tech)

        --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
    end

    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---





    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
    --- Recorrer los objetos seleccionados
    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    for _, space in pairs(This_MOD.items) do
        create_tech(space)
    end

    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
end

---------------------------------------------------------------------------





---------------------------------------------------------------------------
---[ Iniciar el MOD ]---
---------------------------------------------------------------------------

This_MOD.start()

---------------------------------------------------------------------------
