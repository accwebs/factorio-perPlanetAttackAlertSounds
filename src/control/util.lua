local util = {}

function util.tablelength(T)
    local count = 0
    for k, v in pairs(T) do
        count = count + 1
    end
    return count
end

return util
