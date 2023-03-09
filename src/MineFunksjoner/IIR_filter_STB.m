%% IIR_filter (PreviousValue, CurrentValue, Alpha)
%
% Spesify PreviousValue, CurrentValue and Alpha as INT
function [FilterdValue]=IIR_filter (PreviousValue, CurrentRawData, Alpha)
FilterdValue = (1-Alpha)*PreviousValue + Alpha*CurrentRawData;
end