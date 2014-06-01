local updated = false
function ModuleLoad()
	if ClientLight then updated = true end -- Check to see if the client has the publicbeta build
	if updated then 
		images = {
			-- Place your base64 strings here, comma separated
		}
		
		--[[ The next few lines are a pcall that makes sure an image is created.
			 Sometimes image creation fails with a png memory error, so we do
			 it a second time if the first one fails.
		--]]
		if not pcall(function()
			createdImage = Image.Create(AssetLocation.Base64, table.randomvalue(images))
		end) then
			createdImage = Image.Create(AssetLocation.Base64, table.randomvalue(images))
		end
		
		poshold = LocalPlayer:GetPosition()
		loading = true
		t = nil
	end
end
function GameLoad()
	loading = false
end
function doRender()
	--[[ This if statement uses player position to turn the image off if the player moves.
		 This is for when the script is loaded while players are already in the server, to prevent
		 the image from staying on screen (GameLoad event wouldn't be called)
	--]]
	if poshold and updated then 
		if poshold ~= LocalPlayer:GetPosition() then
			loading = false
			poshold = nil
		end
	end
	
	
	if updated then
		if loading then
			createdImage:Draw(Vector2(0,0), Vector2(Render.Width,Render.Height), Vector2(0,0),Vector2(1,1)) -- Draw the image
			
			-- Render loading text
			local txt = "Loading"
			Render:FillArea(Vector2(Render.Width / 2 - (Render:GetTextWidth(txt, TextSize.VeryLarge) / 2) - 8,0), Vector2(Render:GetTextWidth(txt, TextSize.VeryLarge) + 20, Render:GetTextHeight(txt, TextSize.VeryLarge) + 6), Color(0,0,0,100))
			Render:DrawText(Vector2((Render.Width / 2) - (Render:GetTextWidth(txt, TextSize.VeryLarge) / 2),5), txt, Color(255,255,255), TextSize.VeryLarge)
		end
		if t ~= nil then -- If this timer exists, it means the player just died
			if t:GetSeconds() > 6 then -- Timer to count seconds after death to begin showing a loading image
				loadchecktimer = Timer()
				loading = true
				
				-- Pcall, same as above
				if not pcall(function()
					createdImage = Image.Create(AssetLocation.Base64, table.randomvalue(images))
				end) then
					createdImage = Image.Create(AssetLocation.Base64, table.randomvalue(images))
				end
				t = nil -- clear timer
			end
		end
	end
end

function LocalPlayerDeath(args) -- Create a timer on local player death so that the render function can catch it
	if updated then
		t = Timer()
	end
end

Events:Subscribe("PostRender", doRender)
Events:Subscribe("ModuleLoad", ModuleLoad)
Events:Subscribe("GameLoad", GameLoad)
Events:Subscribe("LocalPlayerDeath", LocalPlayerDeath)
