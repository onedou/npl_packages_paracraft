--[[
Title: Skin Page
Author(s): LiXizhi
Date: 2014/9/10
Desc: 
Use Lib:
-------------------------------------------------------
NPL.load("(gl)script/apps/Aries/Creator/Game/Areas/SkinPage.lua");
local SkinPage = commonlib.gettable("MyCompany.Aries.Creator.Game.Desktop.SkinPage");
SkinPage.ShowPage();
-------------------------------------------------------
]]
NPL.load("(gl)script/apps/Aries/Creator/Game/Entity/PlayerSkins.lua");
NPL.load("(gl)script/apps/Aries/Creator/Game/Entity/EntityManager.lua");
NPL.load("(gl)script/apps/Aries/Creator/Game/Entity/PlayerAssetFile.lua");
local PlayerAssetFile = commonlib.gettable("MyCompany.Aries.Game.EntityManager.PlayerAssetFile")
local EntityManager = commonlib.gettable("MyCompany.Aries.Game.EntityManager");
local PlayerSkins = commonlib.gettable("MyCompany.Aries.Game.EntityManager.PlayerSkins")
local pe_gridview = commonlib.gettable("Map3DSystem.mcml_controls.pe_gridview");

local SkinPage = commonlib.gettable("MyCompany.Aries.Creator.Game.Desktop.SkinPage");

local page;
local cur_skin;
local cur_entity;
function SkinPage.OnInit()
	page = document:GetPageCtrl();
	if(not SkinPage.official_ds) then
		SkinPage.official_ds = PlayerSkins:GetSkinDS();
	end
	
	local skin = SkinPage.GetCurSkin();
	cur_skin = nil;
	if(skin) then
		if(tonumber(skin)) then
			SkinPage.select_skin_index = tonumber(skin);
		else
			local ds = SkinPage.official_ds;
			for i = 1,#ds do
				if(ds[i]["filename"] == skin or ds[i]["alias"] == skin) then
					SkinPage.select_skin_index = i;
					break;
				end
			end
		end
	else
		SkinPage.select_skin_index = nil;
	end
end

function SkinPage.GetCurSkin()
	local player = EntityManager.GetFocus();
	local skin;
	if(player and player.GetSkin) then
		skin = player:GetSkin();
	end
	return skin;
end

function SkinPage.ShowPage(entity)
	cur_entity = entity;
	local params = {
			url = "script/apps/Aries/Creator/Game/Areas/SkinPage.html", 
			name = "SkinPage.ShowPage", 
			isShowTitleBar = false,
			DestroyOnClose = true,
			--bToggleShowHide=true, 
			style = CommonCtrl.WindowFrame.ContainerStyle,
			allowDrag = true,
			enable_esc_key = true,
			--bShow = bShow,
			click_through = false, 
			zorder = -1,
			app_key = MyCompany.Aries.Creator.Game.Desktop.App.app_key, 
			directPosition = true,
				align = "_ct",
				x = -500/2,
				y = -400/2,
				width = 500,
				height = 400,
		};
	System.App.Commands.Call("File.MCMLWindowFrame", params);
end

function SkinPage.OnChangeAvatarModel()
    local EntityManager = commonlib.gettable("MyCompany.Aries.Game.EntityManager");
    NPL.load("(gl)script/apps/Aries/Creator/Game/GUI/OpenAssetFileDialog.lua");
	
	local OpenAssetFileDialog = commonlib.gettable("MyCompany.Aries.Game.GUI.OpenAssetFileDialog");
    local lastFilename = EntityManager.GetPlayer():GetMainAssetPath();
	lastFilename = PlayerAssetFile:GetNameByFilename(lastFilename)

	if(page) then
		page:CloseWindow();
	end

	OpenAssetFileDialog.ShowPage("", function(filename)
		if(filename) then
			local filepath = PlayerAssetFile:GetValidAssetByString(filename);
			if(filepath and lastFilename~=filename) then
				if(SkinPage.GetEntity() == EntityManager.GetPlayer()) then
					GameLogic.RunCommand("/avatar "..filename);
				end
			end
		end
	end, lastFilename, L"选择模型文件", "model");
end

-- clicked a block
function SkinPage.ChangeSkin(index)
	local filename = PlayerSkins:GetSkinByID(index-1);
	cur_skin = filename;
	local player_node = page:GetNode("MyPlayer");
	local obj_params = player_node.obj_params;
	obj_params.ReplaceableTextures = {[2] = filename};
	local canvasCtl = player_node.Canvas3D_ctl;
	if(canvasCtl) then
		if(obj_params.AssetFile ~= PlayerAssetFile:GetFilenameByName("default") and obj_params.AssetFile~=PlayerAssetFile:GetFilenameByName("actor")) then
			obj_params.AssetFile = PlayerAssetFile:GetFilenameByName("default");
		end
		canvasCtl:ShowModel(obj_params);
	end

	local gridview_node = page:GetNode("gvwSkins");
	pe_gridview.DataBind(gridview_node, "gvwSkins", false);
end

function SkinPage.GetEntity()
	return cur_entity or EntityManager.GetPlayer();
end

function SkinPage.OnOK()
	if(cur_skin) then
		local player = SkinPage.GetEntity();
		if(player and player.SetSkin) then
			local filename = player:GetMainAssetPath();
			if(filename ~= PlayerAssetFile:GetFilenameByName("default") or filename~=PlayerAssetFile:GetFilenameByName("actor")) then
				player:SetMainAssetPath(PlayerAssetFile:GetFilenameByName("default"))
			end
			player:SetSkin(cur_skin);
		end
	end
end