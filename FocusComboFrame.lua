local COMBOFRAME_FADE_IN = 0.3;
local COMBOFRAME_FADE_OUT = 0.5;
local COMBOFRAME_HIGHLIGHT_FADE_IN = 0.4;
local COMBOFRAME_SHINE_FADE_IN = 0.3;
local COMBOFRAME_SHINE_FADE_OUT = 0.4;
local FOCUS_COMBO_FRAME_LAST_NUM_POINTS = 0;
local UIFrameFade = UIFrameFade
local UIFrameFadeOut = UIFrameFadeOut
local UIFrameFadeIn = UIFrameFadeIn
local GetComboPoints = GetComboPoints

function FocusComboFrame_OnLoad(self)
	self:RegisterEvent("PLAYER_FOCUS_CHANGED");
	self:RegisterUnitEvent("UNIT_POWER_FREQUENT", "player");
	self:RegisterUnitEvent("UNIT_MAXPOWER", "player");
	self:RegisterEvent("PLAYER_ENTERING_WORLD");
	-- init alpha
	self.ComboPoints[1].Highlight:SetAlpha(0);
	self.ComboPoints[1].Shine:SetAlpha(0);

	FocusComboFrame_UpdateMax(self);
end

function FocusComboFrame_OnEvent(self, event, ...)
	if ( event == "PLAYER_FOCUS_CHANGED" ) then
		FocusComboFrame_Update(self);
	elseif ( event == "UNIT_POWER_FREQUENT" ) then
		local unit = ...;
		if ( unit == PlayerFrame.unit ) then
			FocusComboFrame_Update(self);
		end
	elseif ( event == "UNIT_MAXPOWER" or event == "PLAYER_ENTERING_WORLD" ) then
		FocusComboFrame_UpdateMax(self);
	end
end

function FocusComboFrame_UpdateMax(self)
	self.maxComboPoints = UnitPowerMax(PlayerFrame.unit, Enum.PowerType.ComboPoints);

	-- First hide all combo points
	for i = 1, #self.ComboPoints do
		self.ComboPoints[i]:Hide();
	end

	FocusComboFrame_Update(self);
end

function FocusComboFrame_Update(self)

	if (not self.maxComboPoints) then
		-- -- This can happen if we are showing combo points on the player frame (which doesn't use ComboFrame) and we exit a vehicle.
		return;
	end

	local comboPoints = GetComboPoints(PlayerFrame.unit, "focus");
	local comboPoint, comboPointHighlight, comboPointShine;

	if ( comboPoints > 0 ) then
		if ( not self:IsShown() ) then
			self:Show();
			UIFrameFadeIn(self, COMBOFRAME_FADE_IN);
		end

		local comboIndex = 1;
		for i=1, self.maxComboPoints do
			local fadeInfo = {};
			comboPoint = self.ComboPoints[comboIndex];
			comboPointHighlight = comboPoint.Highlight;
			comboPointShine = comboPoint.Shine;
			if ( i <= comboPoints ) then
				if ( i > FOCUS_COMBO_FRAME_LAST_NUM_POINTS ) then
					-- Fade in the highlight and set a function that triggers when it is done fading
					fadeInfo.mode = "IN";
					fadeInfo.timeToFade = COMBOFRAME_HIGHLIGHT_FADE_IN;
					fadeInfo.finishedFunc = ComboPointShineFadeIn;
					fadeInfo.finishedArg1 = comboPointShine;
					UIFrameFade(comboPointHighlight, fadeInfo);
				end
			else
				if ( ENABLE_COLORBLIND_MODE == "1" ) then
					comboPoint:Hide();
				end
				comboPointHighlight:SetAlpha(0);
				comboPointShine:SetAlpha(0);
			end
			comboPoint:Show();
			comboIndex = comboIndex + 1;
		end
	else
		self.ComboPoints[1].Highlight:SetAlpha(0);
		self.ComboPoints[1].Shine:SetAlpha(0);
		self:Hide();
	end
	FOCUS_COMBO_FRAME_LAST_NUM_POINTS = comboPoints;
end

function FocusComboPointShineFadeIn(frame)
	-- Fade in the shine and then fade it out with the ComboPointShineFadeOut function
	local fadeInfo = {};
	fadeInfo.mode = "IN";
	fadeInfo.timeToFade = COMBOFRAME_SHINE_FADE_IN;
	fadeInfo.finishedFunc = ComboPointShineFadeOut;
	fadeInfo.finishedArg1 = frame;
	UIFrameFade(frame, fadeInfo);
end

--hack since a frame can't have a reference to itself in it
function FocusComboPointShineFadeOut(frame)
	UIFrameFadeOut(frame, COMBOFRAME_SHINE_FADE_OUT);
end
