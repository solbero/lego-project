%++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
% EulerForward(IntOldValue, FunctionValue, TimeStep)
%
% Generell implementering av Euler's forovermetode som funksjon
% av tid. Denne funksjonen tar inn en gammel integralverdi, en funksjonsverdi
% og et tidssteg. Den returnerer en ny integralverdi.
%
% Input:
% IntOldValue - gammel integralverdi
% FunctionValue - funksjonsverdi
% TimeStep - tidssteg
%
% Output:
% IntNewValue - ny integralverdi
%
% Eksempel:
% IntNewValue = EulerFremover(IntOldValue, FunctionValue, TimeStep)
%
%--------------------------------------------------------------------------

function IntNewValue = EulerForward(IntOldValue, FunctionValue, TimeStep)
    IntNewValue = IntOldValue + FunctionValue * TimeStep;
end