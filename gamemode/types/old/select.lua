AddCSLuaFile()

-- Select Query
do
    local SelectQuery = sym.RegisterType("dbselect")

    function SelectQuery:Init(out, type)
        out.type = type
        out.table = type:GetDatabaseTable()
        out.wheres = {}
        out.joins = {}
        out.fields = {}

        return out
    end

    function SelectQuery:field(...)
        local args = {...}
        local sz = #args
        if sz == 1 and istable(args[1]) then
            args = args[1]
        end
        table.Add(self.fields, args)
        return self
    end

    function SelectQuery:where(field, conditional, value, operator)
        if not value then
            value = conditional
            conditional = "="
        end

        if not operator then
            operator = "AND"
        end

        table.insert(self.wheres, { field, conditional, value, operator })
        return self
    end

    -- tbl: { field, conditional, value, operator(AND/OR) }
    function SelectQuery:whereGroup(tbl, operator)
        table.insert(self.wheres, { operator = operator, items = tbl})
        return self
    end

    function SelectQuery:join(tbl, sourceField, targetField, fields, type)
        type = type or "LEFT JOIN"
        table.insert(self.joins, { tbl, sourceField, targetField, fields, type })
        return self
    end

    function SelectQuery:order(field, direction)
        direction = direction or "ASC"

        self.orders = self.orders or {}
        table.insert(self.orders, { field, direction })
    end

    function SelectQuery:limit(start, fin)
        if not fin then
            fin = start
            start = nil
        end

        self.offset = start
        self.lim = fin
    end

    function SelectQuery:execute(bRunSynchronously)
        local key = self.type:GetDatabaseKey()
        if #self.fields > 0 then
            self:field(key)
        end
        
        local qp = sym.db.Query(tostring(self))
        local outprom = sym.promise(function ()
            if bRunSynchronously then
                qp.query:wait()
            end
            
            local data = qp:Await()
            
            local key = self.type:GetDatabaseKey()
            local propmap = self.type:GetPropertyMetadata()

            local compositeKey = propmap[key]:GetPropertyType() ~= sym.types.uuid
            local typeName = self.type:GetTypeName()

            local out = {}
            for i, r in pairs(data) do
                local id = r[key]
                if compositeKey then
                    id = typeName .. "[" .. id .. "]"
                end

                local inst = sym.NetworkedObjects[id]
                if inst then
                    sym.fine("QRY_REUSED_OBJ", "[Row " .. i .. "] Using existing instance for " .. self.type:GetTypeName())
                    inst.__dbinserted = true
                else
                    inst = sym.CreateUninitializedInstance(self.type, id)
                    sym.fine("QRY_CREATE_OBJ", "[Row " .. i .. "] Instanced " .. self.type:GetTypeName())
                    inst.__dbinserted = true
                end

                local propmap = inst:GetPropertyMetadata()
                for k, f in pairs(propmap) do
                    if f:GetOptions().Transient then
                        continue
                    end
                    
                    local propType = f:GetPropertyType()
                    assert(propType.DbRead, propType:GetTypeName() .. " does not have a DbRead function.")
                    
                    local v = propType:DbRead(r[k])

                    inst:SetProperty(k, v)
                    sym.finest("QRY_SET_PROPERTY", k .. " = " .. tostring(v) .. " <Type:" .. (sym.IsType(v) and v:GetTypeName() or (type(v) .. "*")) .. ">")
                end

                if self.type.Init then
                    self.type:Init(inst)
                end
                out[i] = inst
            end

            return out
        end)
        outprom:Start()
        return outprom, q

    end

    function SelectQuery:__tostring()
        local fields = {}
        for k, v in pairs(self.fields) do
            table.insert(fields, "`" .. self.type:GetDatabaseTable() .. "`.`" .. v .. "`")
        end

        for k, v in pairs(self.joins) do
            local n = v[1]
            for k2, v2 in pairs(v[4]) do
                table.insert(fields, "`" .. n .. "`.`" .. v2 .. "`")
            end
        end

        if #fields == 0 then
            fields = { "*" }
        end

        local wheres = {}
        local first = true
        for k, v in pairs(self.wheres) do
            if v.items then -- whereGroup
                local t = {}
                for k2, v2 in pairs(v.items) do
                    local value = v2[3] == sym.null and "NULL" or sym.db.escape(v2[3])
                    table.insert(t, string.format("`%s` %s %s %s", v2[1], v2[2], value, v2[4] or ""))
                end
                table.insert(wheres, string.format("%s (%s) %s", not first and v.operator or "", string.TrimLeft(string.TrimLeft(table.concat(t, " "), "AND"), "OR"), first and v.operator or ""))
            else
                local value = v[3] == sym.null and "NULL" or sym.db.escape(v[3])
                table.insert(wheres, string.format("`%s` %s %s AND", v[1], v[2], sym.db.escape(v[3])))
            end
            first = false
        end

        local joins = {}
        for k, v in pairs(self.joins) do
            table.insert(joins, string.format("%s `%s` ON `%s`.`%s` = `%s`.`%s`", v[5], v[1], self.table, v[2], v[1], v[3]))
        end

        local out = {}
        table.insert(out, string.format("SELECT %s FROM `%s`", table.concat(fields, ", "), self.table))

        if #joins > 0 then
            table.insert(out, table.concat(joins, " "))
        end

        if #wheres > 0 then
            table.insert(out, string.format("WHERE %s", string.TrimRight(string.TrimRight(table.concat(wheres, " "), "AND"), "OR")))
        end

        if self.orders then
            local orders = {}
            for k, v in pairs(self.orders) do
                table.insert(orders, "`" .. v[1] .. "`" .. " " .. v[2])
            end
            table.insert(out, string.format("ORDER BY %s", table.concat(orders, ",")))
        end

        if self.lim then
            table.insert(out, "LIMIT " .. self.lim)
        end

        if self.offset then
            table.insert(out, "OFFSET " .. self.offset)
        end

        return string.Trim(table.concat(out, " ")) .. ";"
    end
end