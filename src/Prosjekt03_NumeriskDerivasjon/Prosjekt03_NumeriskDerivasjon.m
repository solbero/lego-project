%++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
% Prosjekt01_NumeriskIntegrasjon
%
% Hensikten med programmet er å integrere signal fra lyssensor
% Følgende sensorer brukes:
% - Lyssensor
%
%--------------------------------------------------------------------------


%++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
%                EXPERIMENT SETUP AND DATA FILENAME
%
% Alltid lurt å rydde workspace opp først
clear; close all
% Skal prosjektet gjennomføres online mot EV3 eller mot lagrede data?
online = false;
% Skal prosjektet lagre data etter en sesjon?
save_files = false;
% Spesifiser et beskrivende filnavn for lagring av måledata
filename_mat = '../Prosjekt01_NumeriskIntegrasjon/data/Prosjekt01_NumeriskIntegrasjon_Sinus2.mat';
filename_csv = 'data/Prosjekt03_NumeriskDerivasjon_2.csv';
%--------------------------------------------------------------------------


% +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
%                      INITIALIZE EQUIPMENT
% Initialiser styrestikke, sensorer og motorer.
%
% Spesifiser hvilke sensorer og motorer som brukes.
% I Matlab trenger du generelt ikke spesifisere porten de er tilkoplet.
% Unntaket fra dette er dersom bruke 2 like sensorer, hvor du må
% initialisere 2 sensorer med portnummer som argument.
% Eksempel:
% mySonicSensor_1 = sonicSensor(mylego,3);
% mySonicSensor_2 = sonicSensor(mylego,4);

% For ryddig og oversiktlig kode, kan det være lurt å slette
% de sensorene og motoren som ikke brukes.

if online

    % LEGO EV3 og styrestikke
    mylego = legoev3('USB');
    joystick = vrjoystick(1);

    % sensorer
    myColorSensor = colorSensor(mylego);

else
    % Dersom online=false lastes datafil.
    load(filename_mat)
end

disp('Equipment initialized.')
%----------------------------------------------------------------------


%++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
%                       SPECIFY FIGURE SIZE
fig1=figure;
screen = get(0,'Screensize');
set(fig1,'Position',[1,0.3*screen(4),0.6*screen(3), 0.6*screen(4)])
set(0,'defaultTextInterpreter','latex');
set(0,'defaultAxesFontSize',14)
set(0,'defaultTextFontSize',16)
%----------------------------------------------------------------------


% setter skyteknapp til 0, og tellevariabel k=1
JoyMainSwitch=0;
k=1;
Ts = zeros;
Avstand = zeros;
Avstand_IIR = zeros;
Fart = zeros;
Fart_IIR = zeros;


while ~JoyMainSwitch
    %+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    %                       GET TIME AND MEASUREMENT
    % Få tid og målinger fra sensorer, motorer og joystick
    %
    % For ryddig og oversiktlig kode, kan det være lurt å slette
    % de sensorene og motoren som ikke brukes.

    if online
        if k==1
            tic
            Tid(1) = 0;
        else
            Tid(k) = toc;
        end

        % sensorer (bruk ikke Lys(k) og LysDirekte(k) samtidig)
        Lys(k) = double(readLightIntensity(myColorSensor,'reflected'));

        % Data fra styrestikke. Utvid selv med andre knapper og akser.
        % Bruk filen joytest.m til å finne koden for de andre
        % knappene og aksene.
        [JoyAxes,JoyButtons] = HentJoystickVerdier(joystick);
        JoyMainSwitch = JoyButtons(1);

    else
        % online=false
        % Når k er like stor som antall elementer i datavektoren Tid,
        % simuleres det at bryter på styrestikke trykkes inn.
        if k==numel(Tid)
            JoyMainSwitch=1;
        end

        % simulerer EV3-Matlab kommunikasjon i online=false
        % pause(0.01)

    end
    %--------------------------------------------------------------




    % +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    %             CONDITIONS, CALCULATIONS AND SET MOTOR POWER
    % Gjør matematiske beregninger og motorkraftberegninger
    % hvis motor er tilkoplet.
    % Kaller IKKE på en funksjon slik som i Python.

    % Tilordne målinger til variabler
    Alpha = 0.03;
    Avstand(k) = Lys(k);    
    
    % Spesifisering av initialverdier
    if k==1
        % Initialverdier
        Ts(1) = 0.01;  % nominell verdi
        Avstand_IIR(1) = Avstand(k);
        Fart(1) = 0;
        Fart_IIR(1) = 0;
    else
        Ts(k) = Tid(k) - Tid(k-1);
        Avstand_IIR(k) = IIR_filter_STB(Avstand_IIR(k-1), Avstand(k), Alpha);
        % Deriverer mht. Avstand og Avstand_IIR
        Fart(k) = NumericDerivation(Avstand(k-1), Avstand(k), Ts(k));
        Fart_IIR(k) = NumericDerivation(Avstand_IIR(k-1), Avstand_IIR(k), Ts(k));
    end
    %--------------------------------------------------------------



    %++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    %                  PLOT DATA
    % Denne seksjonen plasseres enten i while-lokka eller rett etterpå.
    % Dette kan enkelt gjøres ved flytte de 5 nederste linjene
    % før "end"-kommandoen nedenfor opp før denne seksjonen.
    %
    % Husk at syntaksen plot(Tid(1:k),data(1:k))
    % gir samme opplevelse i online=0 og online=1 siden
    % hele datasettet (1:end) eksisterer i den lagrede .mat fila

    if online
        % aktiver fig1
        figure(fig1)

        subplot(3,1,1)
        plot(Tid,Avstand,'b',Tid,Avstand_IIR,'r');
        title(['Avstandsm\aa ling r\aa data og filtrert data. Alpha=',num2str(Alpha)])
        ylabel('[m]')
        xlabel('Tid [sek]')

        subplot(3,1,2)
        plot(Tid,Fart,'m');
        title('Fart')
        ylabel('[m/s]')
        xlabel('Tid [sek]')

        subplot(3,1,3)
        plot(Tid,Fart_IIR,'g');
        title('Fart IIR')
        ylabel('[m/s]')
        xlabel('Tid [sek]')

        % tegn nå (viktig kommando)
        drawnow
    end
    %--------------------------------------------------------------

    % For å flytte PLOT DATA etter while-lokken, er det enklest å
    % flytte de neste 5 linjene (til og med "end") over PLOT DATA.
    % For å indentere etterpå, trykk Ctrl-A/Cmd-A og deretter Crtl-I/Cmd-I
    %
    % Oppdaterer tellevariabel
    k = k + 1;
end


% aktiver fig1
figure(fig1)

sgtitle(['Eksperiment utf\o rt ved gjennomsnittlig $T_s$ =',num2str(round(mean(Ts),4))])

subplot(3,1,1)
plot(Tid,Avstand,'b',Tid,Avstand_IIR,'r');
title(['Avstandsm\aa ling r\aa data og filtrert data. Alpha=',num2str(Alpha)])
ylabel('[m]')
xlabel('Tid [sek]')
legend('Rådata','IIR')

subplot(3,1,2)
plot(Tid,Fart,'m');
title('Fart')
ylabel('[m/s]')
xlabel('Tid [sek]')

subplot(3,1,3)
plot(Tid,Fart_IIR,'g');
title('Fart IIR')
ylabel('[m/s]')
xlabel('Tid [sek]')
%++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
%                  SAVE DATA
% Denne seksjonen lagrer dataene etter en sesjon.
% Dataene blir lagret i samme mappe som kildefilen.

if save_files == true
    % Lagre .mat-fil
    save(filename_mat, 'Tid', 'Lys', 'Fart', 'Fart_IIR');
    % Lagre .csv-fil
    csv_data = [Tid', Fart', Fart_IIR']; % Transpose
    table = array2table(csv_data, "VariableNames",{'t', 'speed', 'speed_iir'}); % Converter til tabell med overskrifter
    writetable(table, filename_csv); % Skriv ut fil
end