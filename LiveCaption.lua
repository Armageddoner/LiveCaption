local RunService = game:GetService("RunService")

local LiveCaption = {}
LiveCaption.__index = LiveCaption

--[[
	Creates a new <code>LiveCaption</code> with the provided Audio.
	From there, you will be able to manipulate text once a time marker is reached in the <code>Sound</code> instance via the <code>CaptionCallback</code>
	To run, call the <code>self:Listen()</code> method after setting up lines.
	
	CaptionCallback passes a string "Caption"
	<strong>This module is best used for voicelines/boss theme (synced with lyrics) or alternatively if you want a function callback to occur at a specified time in audio</strong>
]]
function LiveCaption.new(Audio: Sound, CaptionCallback: (Caption: string) -> ())
	local self = {}
	
	self.Audio = Audio :: Sound
	self.TimePositions = {}
	self.Enabled = false :: boolean
	self.ListeningConnection = CaptionCallback :: RBXScriptConnection
	self.CaptionCallbackFunc = nil :: (Caption: string) -> ()
	
	return setmetatable(self, LiveCaption)
end

-- Initiates a marker at <code>TimePosition</code> where <code>Caption</code> will be displayed once reached
-- <em>(You must create driver code to display your captions once reached)</em>
function LiveCaption:CaptionTimePosition(TimePosition: number, Caption: string)
	self.TimePositions[TimePosition] = Caption
end

-- <strong> do not use this :: roblox's table thing is a mess so just use</strong> <code>self:CaptionTimePosition</code>
@deprecated
function LiveCaption:CaptionTimePositionEnMasse(InputTable: {[number]: string})
	--print(TimeTable)
	for Position, Caption in (InputTable) do
		--warn(Position, typeof(Position), Caption, typeof(Caption))
		--print(Caption)
		if Position and Caption then
			LiveCaption:CaptionTimePosition(Position, Caption)
		end
	end
end

--[[
	Listens for any movement in the audio's <code>TimePosition</code> property.
	From there, this method handles firing any events you set up at specified time positions.
]]
function LiveCaption:Listen()
	if self.ListeningConnection then return end
	self.Enabled = true
	local TimeTable = table.clone(self.TimePositions)
	local TimeTableIndexes: {number} = {}
	
	for i, v in TimeTable do
		table.insert(TimeTableIndexes, i)
	end
	table.sort(TimeTableIndexes)
	
	--print(TimeTableIndexes)

	-- Here we will find the closest index ahead of the time position marker.
	local CurrentIndex = nil --or TimeTableIndexes[1]
	
	-- Helper function to get the closest time that isn't behind the scrubber
	local function getCaptionToTime()
		local AudioInitPosition: number = self.Audio.TimePosition
		local TTIndexClone = table.clone(TimeTableIndexes)
		while true do -- this'ere loop allows us to start captions at the closest index to the current time pos
			local Min = math.min(unpack(TTIndexClone))
			if Min >= AudioInitPosition then
				CurrentIndex = Min
				break
			else
				local find = table.find(TTIndexClone, Min)
				table.remove(TTIndexClone, find)
			end
		end
	end
	
	getCaptionToTime()
	--print(CurrentIndex, table.find(TimeTableIndexes, CurrentIndex))
	local RunConnection: RBXScriptConnection = nil
	RunConnection = RunService.Heartbeat:Connect(function()
		
		local CurrentPosition: number = self.Audio.TimePosition
		
		if CurrentIndex and (CurrentPosition >= CurrentIndex --[[and CurrentIndex < CurrentPosition]]) then
			--warn(TimeTable[CurrentIndex])
			
			if self.CaptionCallbackFunc then -- At the proper time, call the callback and send the caption
				self.CaptionCallbackFunc(TimeTable[CurrentIndex]) -- after all, the driver code should handle how captions work
			end
			
			local iPos = table.find(TimeTableIndexes, CurrentIndex) -- never to any table operation inline with another table operation. learned the hard way
			local PrevIndex, NextIndex = next(TimeTableIndexes, iPos)
			CurrentIndex = NextIndex
			
			if not NextIndex then
				-- if we dont have a next, we need to find a safe exit method
				if self.Audio.Looped then
					self.Audio.DidLoop:Wait()
					--CurrentIndex = TimeTableIndexes[1]
					getCaptionToTime()
				else -- be the audio is looped or not
					RunConnection:Disconnect()
					return
				end
			end
			
			
		end
		
	end)
	self.ListeningConnection = RunConnection
end

-- Kills any listening operation done to the <code>TimePosition</code>
-- You may listen to the audio again after calling this method.
function LiveCaption:StopListening()
	if self.ListeningConnection then
		self.ListeningConnection:Disconnect()
	end
end

return LiveCaption
