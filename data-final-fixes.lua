local grid_scale = settings.startup['equipment-grid-upscale'].value
local leeway_amount = math.floor(math.log(grid_scale / 4, 2))
local do_leeway = settings.startup['equipment-grid-leeway'].value

-- Equipment grids (used by armor and vehicles)

for _, grid in pairs(data.raw['equipment-grid']) do
    grid.width = grid.width * grid_scale
    grid.height = grid.height * grid_scale
    if do_leeway then
        grid.width = grid.width + leeway_amount
        grid.height = grid.height + leeway_amount
    end
end

-- Equipment

local function check_radius(x, y, radius)
    local normalized_x = (x / radius)
    local normalized_y = (y / radius)
    return math.sqrt(normalized_x ^ 2 + normalized_y ^ 2) <= 1
end

local function generate_pill(width, height)
    local diameter = math.min(width, height)
    local straight_length = math.max(width, height) - diameter
    local radius = diameter / 2
    local result = {}
    for x = 0, width - 1 do
        for y = 0, height - 1 do
            local cornered_x = math.abs(x - (width - 1) / 2)
            local cornered_y = math.abs(y - (height - 1) / 2)
            if width > height and (cornered_x < (straight_length / 2)) then
                table.insert(result, { x, y })
            elseif height > width and (cornered_y < (straight_length / 2)) then
                table.insert(result, { x, y })
            else
                local radius_x
                local radius_y
                if width > height then
                    radius_x = cornered_x - (straight_length / 2)
                    radius_y = cornered_y
                else
                    radius_x = cornered_x
                    radius_y = cornered_y - (straight_length / 2)
                end
                if check_radius(radius_x, radius_y, radius) then
                    table.insert(result, { x, y })
                end
            end
        end
    end
    return result
end

local equipment_categories = { 'active-defense-equipment', 'battery-equipment', 'belt-immunity-equipment',
    'energy-shield-equipment', 'equipment-ghost', 'generator-equipment', 'inventory-bonus-equipment',
    'movement-bonus-equipment', 'night-vision-equipment', 'roboport-equipment', 'solar-panel-equipment' }

for _, category_name in pairs(equipment_categories) do
    for _, equipment in pairs(data.raw[category_name]) do
        if equipment.shape ~= nil then
            equipment.shape.width = equipment.shape.width * grid_scale
            equipment.shape.height = equipment.shape.height * grid_scale
            if do_leeway then
                equipment.shape.width = equipment.shape.width - leeway_amount
                equipment.shape.height = equipment.shape.height - leeway_amount
            end
            if settings.startup['equipment-pill-shape'].value and equipment.shape.type ~= 'manual' then
                equipment.shape.type = 'manual'
                -- could set custom width/height to diameter ratio?
                equipment.shape.points = generate_pill(equipment.shape.width, equipment.shape.height)
            end
        end
    end
end


data.raw['utility-sprites']['default'].equipment_slot.scale =
    data.raw['utility-sprites']['default'].equipment_slot.scale / grid_scale
--[[data.raw['utility-sprites']['default'].equipment_slot.width =
    data.raw['utility-sprites']['default'].equipment_slot.width / grid_scale
data.raw['utility-sprites']['default'].equipment_slot.height =
    data.raw['utility-sprites']['default'].equipment_slot.height / grid_scale]]
