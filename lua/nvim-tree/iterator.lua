local Iterator = {}
Iterator.__index = Iterator

function Iterator.new(nodes)
  return setmetatable({
    nodes = nodes,
    _filter_hidden = function(node)
      return not node.hidden
    end,
    _apply_fn_on_node = function(_) end,
    _match = function(_) end,
    _recurse_with = function(node)
      return node.nodes
    end,
  }, Iterator)
end

function Iterator:allow_hidden()
  self._filter_hidden = function(_)
    return true
  end
  return self
end

function Iterator:setup_matcher(f)
  self._match = f
  return self
end

function Iterator:setup_apply_fn(f)
  self._apply_fn_on_node = f
  return self
end

function Iterator:setup_recurse_fn(f)
  self._recurse_with = f
  return self
end

function Iterator:consume()
  local function iter(nodes)
    local i = 1
    for _, node in ipairs(nodes) do
      if self._filter_hidden(node) then
        if self._match(node) then
          return node, i
        end
        self._apply_fn_on_node(node)
        local children = self._recurse_with(node)
        if children then
          local n, idx = iter(children)
          i = i + idx
          if n then
            return n, i
          else
            i = i + 1
          end
        end
      end
    end
    return nil, i
  end

  return iter(self.nodes)
end

return Iterator
