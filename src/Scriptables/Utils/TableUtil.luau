local TableUtil = {}

function TableUtil.InsertTableInTable(destination: table, source: table)
	for _, value in ipairs(source) do
		table.insert(destination, value)
	end
end

return TableUtil
