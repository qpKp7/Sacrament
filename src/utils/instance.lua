--!strict

local InstanceUtil = {}

export type Props = { [string]: any }
export type Children = { Instance }

function InstanceUtil.create(className: string, props: Props?, children: Children?): Instance
	local inst = Instance.new(className)

	if props then
		for k, v in pairs(props) do
			(inst :: any)[k] = v
		end
	end

	if children then
		for _, child in ipairs(children) do
			child.Parent = inst
		end
	end

	return inst
end

return InstanceUtil
