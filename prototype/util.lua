local module = {}

function module.apply_preservation_tint(obj)
  local tint = {r=0.6, g=0.8, b=1.0, a=1.0}

  if type(obj) ~= "table" then return end

  -- Handle sprite-like objects (with filename/tint properties)
  if obj.filename then
      obj.tint = tint
      return
  end

  -- Handle layers property specifically
  if obj.layers then
      for _, layer in pairs(obj.layers) do
          module.apply_preservation_tint(layer)
      end
  end

  -- Recursively process all table values
  for _, value in pairs(obj) do
      if type(value) == "table" then
          module.apply_preservation_tint(value)
      end
  end
end

return module
