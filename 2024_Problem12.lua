local INPUT_FILE = "2024_Problem12.txt"

local function ReadInput(filename)
  local grid = {}
  for line in io.lines(filename) do
    local row = {}
    for i = 1, line:len() do
      row[i] = line:sub(i, i)
    end
    table.insert(grid, row)
  end
  
  return grid
end

local function FloodFill(grid, x, y, visited, region)
  local plant = grid[y][x]
  
  local area = 1
  local inner_borders = 0
  
  local new_wave
  
  local function check_cell(x, y)
    if x < 1 or  x > #grid[1] or y < 1 or y > #grid or grid[y][x] ~= plant then
      return
    end
    if not visited[y][x] or visited[y][x] == region then
      inner_borders = inner_borders + 1
    end    
    if not visited[y][x] then
      visited[y][x] = region
      table.insert(new_wave, {x, y})
      area = area + 1
    end
  end
  
  local wave = {{x, y}}
  visited[y][x] = region
  while #wave > 0 do
    new_wave = {}
    for _, cell in ipairs(wave) do
      local x, y = cell[1], cell[2]
      check_cell(x - 1, y)
      check_cell(x + 1, y)
      check_cell(x, y - 1)
      check_cell(x, y + 1)
    end
    wave = new_wave
  end
  
  return area, inner_borders
end

local function GetFencePrice(grid)
  local visited = {}
  for y = 0, #grid + 1 do
    visited[y] = {}
    visited[y][0] = true
    visited[y][#grid + 1] = true
  end
  for x = 1, #grid[1] do
    visited[0][x] = true
    visited[#grid + 1][x] = true
  end
  
  local plant_region = {}
  local region = 0
  local price = 0
  for y, row in ipairs(grid) do
    for x, plant in ipairs(row) do
      if not visited[y][x] then
        region = region + 1
        local area, inner_borders = FloodFill(grid, x, y, visited, region)
        local outer_borders = 4 * area - inner_borders
        plant_region[region] = {plant, area, outer_borders}
        price = price + area * outer_borders
      end
    end
  end
  
  return price, visited, plant_region
end

local function CountSides(regions, region)
  local size_x, size_y = #regions[1] - 1, #regions - 1
  
  local grid = {}
  for y = 0, size_y + 1 do
    grid[y] = {}
    for x = 0, size_x + 1 do
      grid[y][x] = (regions[y][x] == region) and 1 or 0
    end
  end
  
  local x_gradient = {}
  for y = 1, size_y do
    x_gradient[y] = {}
    for x = 1, size_x + 1 do
      x_gradient[y][x] = grid[y][x] - grid[y][x - 1]
      value_prev = value
    end
  end
  local x_sides = 0
  for x = 1, size_x + 1 do
    local spans = 0
    local value_prev
    for y = 1, size_y do
      local value = x_gradient[y][x]
      if value ~= 0 and value ~= value_prev then
        spans = spans + 1
      end
      value_prev = value
    end
    x_sides = x_sides + spans
  end
  
  local y_gradient = {}
  for y = 1, size_y + 1 do
    y_gradient[y] = {}
    for x = 1, size_x do
      y_gradient[y][x] = grid[y][x] - grid[y - 1][x]
    end
  end
  local y_sides = 0
  for y = 1, size_y + 1 do
    local spans = 0
    local value_prev
    for x = 1, size_x do
      local value = y_gradient[y][x]
      if value ~= 0 and value ~= value_prev then
        spans = spans + 1
      end
      value_prev = value
    end
    y_sides = y_sides + spans
  end
  
  return x_sides + y_sides
end

local function GetFencePriceBulk(regions, plant_region)
  local size_x, size_y = #regions[1] - 1, #regions - 1
  
  local price = 0
  for region, descr in pairs(plant_region) do
    local plant, area = descr[1], descr[2]
    local sides = CountSides(regions, region)
    price = price + sides * area
  end
  
  return price
end

local grid = ReadInput(INPUT_FILE)
local fence_price, regions, plant_region = GetFencePrice(grid)
local fence_price_bulk = GetFencePriceBulk(regions, plant_region)
print(string.format("Fence Price: %d", fence_price))
print(string.format("Fence Price Bulk: %d", fence_price_bulk))