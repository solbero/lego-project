%% NumericDerivation (PreviousValue, CurrentValue, TimeStep)
%
% Spesify PreviousValue, CurrentValue and TimeStep as INT
function [DerivatedValue]=NumericDerivation (PreviousValue, CurrentValue, TimeStep)
DerivatedValue = (CurrentValue - PreviousValue) / TimeStep;
end