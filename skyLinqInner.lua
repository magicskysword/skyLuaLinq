local skyLinqInner = {}

function skyLinqInner.mergeSort(t,minFunc)
    local len = 0
    local a = t
    local b = {}
    for index, value in ipairs(t) do
        len = len + 1
        b[index] = 0
    end

    local seg  = 1
    while seg <= len do
        local start = 1
        while start <= len do
            local low = start
            local mid = math.min(start + seg, len)
            local high =  math.min(start + seg + seg, len+1)
            local k = low
            local start1 = low
            local end1 = mid
            local start2 = mid
            local end2 = high
            while start1 < end1 and start2 < end2 do
                if minFunc(a[start1],a[start2]) == a[start1] then
                    b[k] = a[start1]
                    start1 = start1 + 1
                else
                    b[k] = a[start2]
                    start2 = start2 + 1
                end
                k = k + 1
            end
            while start1 < end1 do
                b[k] = a[start1];
                k = k + 1
                start1 = start1 + 1
            end
            while start2 < end2 do
                b[k] = a[start2];
                k = k + 1
                start2 = start2 + 1
            end
            start = start + seg + seg
        end
        a,b = b,a
        seg = seg + seg
    end
end

return skyLinqInner