local Weapons = {}

Citizen.CreateThread(function()
	Citizen.Wait(30000)
	while true do
		local playerPed = GetPlayerPed(-1)

		for i=1, #Config.RealWeapons, 1 do

    		local weaponHash = GetHashKey(Config.RealWeapons[i].name)

    		if HasPedGotWeapon(playerPed, weaponHash, false) then
    			local onPlayer = false

				for k, entity in pairs(Weapons) do
				  if entity then
      				if entity.weapon == Config.RealWeapons[i].name then
      					onPlayer = true
      					break
      				end
				  end
      			end
	      		
      			if not onPlayer and weaponHash ~= GetSelectedPedWeapon(playerPed) then
	      			SetGear(Config.RealWeapons[i].name)
      			elseif onPlayer and weaponHash == GetSelectedPedWeapon(playerPed) then
	      			RemoveGear(Config.RealWeapons[i].name)
      			end
			else
				RemoveGear(Config.RealWeapons[i].name)
    		end
  		end
		Wait(500)
	end
end)

RegisterNetEvent('removeWeapon')
AddEventHandler('removeWeapon', function(weaponName)
	RemoveGear(weaponName)
end)
RegisterNetEvent('removeWeapons')
AddEventHandler('removeWeapons', function()
	RemoveGears()
end)

function RemoveGear(weapon)
	local _Weapons = {}

	for i, entity in pairs(Weapons) do
		if entity.weapon ~= weapon then
			_Weapons[i] = entity
		else
			DeleteWeapon(entity.obj)
		end
	end

	Weapons = _Weapons
end

function RemoveGears()
	for i, entity in pairs(Weapons) do
		DeleteWeapon(entity.obj)
	end
	Weapons = {}
end

function SpawnObject(model, coords, cb)

  local model = (type(model) == 'number' and model or GetHashKey(model))

  Citizen.CreateThread(function()

    RequestModel(model)

    while not HasModelLoaded(model) do
      Citizen.Wait(5)
    end

    local obj = CreateObject(model, coords.x, coords.y, coords.z, true, true, true)

    if cb ~= nil then
      cb(obj)
    end

  end)

end

function DeleteWeapon(object)
  DeleteObject(object)
end

function SetGear(weapon)
	local bone       = nil
	local boneX      = 0.0
	local boneY      = 0.0
	local boneZ      = 0.0
	local boneXRot   = 0.0
	local boneYRot   = 0.0
	local boneZRot   = 0.0
	local playerPed  = GetPlayerPed(-1)
	local model      = nil
	local playerWeapons = getWeapons()
		
	for i=1, #Config.RealWeapons, 1 do
		if Config.RealWeapons[i].name == weapon then
			bone     = Config.RealWeapons[i].bone
			boneX    = Config.RealWeapons[i].x
			boneY    = Config.RealWeapons[i].y
			boneZ    = Config.RealWeapons[i].z
			boneXRot = Config.RealWeapons[i].xRot
			boneYRot = Config.RealWeapons[i].yRot
			boneZRot = Config.RealWeapons[i].zRot
			model    = Config.RealWeapons[i].model
			break
		end
	end

	SpawnObject(model, {
		x = x,
		y = y,
		z = z
	}, function(obj)
		local playerPed = GetPlayerPed(-1)
		local boneIndex = GetPedBoneIndex(playerPed, bone)
		local bonePos 	= GetWorldPositionOfEntityBone(playerPed, boneIndex)
		AttachEntityToEntity(obj, playerPed, boneIndex, boneX, boneY, boneZ, boneXRot, boneYRot, boneZRot, false, false, false, false, 2, true)
		table.insert(Weapons,{weapon = weapon, obj = obj})
	end)
end

local weapon_types = {
	"WEAPON_SMG",
	"WEAPON_COMBATPDW",
	"WEAPON_ASSAULTSMG",
	"WEAPON_ASSAULTRIFLE",
	"WEAPON_ADVANCEDRIFLE",
	"WEAPON_SPECIALCARBINE",
	"WEAPON_MARKSMANRIFLE",
	"WEAPON_MICROSMG",
	"WEAPON_GUSENBERG",
	"WEAPON_MG",
}

function getWeapons()
  local player = GetPlayerPed(-1)

  local ammo_types = {} 

  local weapons = {}
  for k,v in pairs(weapon_types) do
    local hash = GetHashKey(v)
    if HasPedGotWeapon(player,hash) then
      local weapon = {}
      weapons[v] = weapon

      local atype = Citizen.InvokeNative(0x7FEAD38B326B9F74, player, hash)
      if ammo_types[atype] == nil then
        ammo_types[atype] = true
        weapon.ammo = GetAmmoInPedWeapon(player,hash)
      else
        weapon.ammo = 0
      end
    end
  end

  return weapons
end


function SetGears()
	local bone       = nil
	local boneX      = 0.0
	local boneY      = 0.0
	local boneZ      = 0.0
	local boneXRot   = 0.0
	local boneYRot   = 0.0
	local boneZRot   = 0.0
	local playerPed  = GetPlayerPed(-1)
	local model      = nil
	local playerWeapons = getWeapons()
	local weapon 	 = nil
	
	for k,v in pairs(playerWeapons) do
		
		for j=1, #Config.RealWeapons, 1 do
			if Config.RealWeapons[j].name == k then
				
				bone     = Config.RealWeapons[j].bone
				boneX    = Config.RealWeapons[j].x
				boneY    = Config.RealWeapons[j].y
				boneZ    = Config.RealWeapons[j].z
				boneXRot = Config.RealWeapons[j].xRot
				boneYRot = Config.RealWeapons[j].yRot
				boneZRot = Config.RealWeapons[j].zRot
				model    = Config.RealWeapons[j].model
				weapon   = Config.RealWeapons[j].name 
				
				break

			end
		end

		local _wait = true

		SpawnObject(model, {
			x = x,
			y = y,
			z = z
		}, function(obj)
			
			local playerPed = GetPlayerPed(-1)
			local boneIndex = GetPedBoneIndex(playerPed, bone)
			local bonePos 	= GetWorldPositionOfEntityBone(playerPed, boneIndex)

			AttachEntityToEntity(obj, playerPed, boneIndex, boneX, boneY, boneZ, boneXRot, boneYRot, boneZRot, false, false, false, false, 2, true)						

			table.insert(Weapons,{weapon = weapon, obj = obj})

			_wait = false

		end)

		while _wait do
			Wait(5)
		end
    end

end