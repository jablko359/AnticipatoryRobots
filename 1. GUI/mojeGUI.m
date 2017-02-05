function varargout = mojeGUI(varargin)
%MOJEGUI MATLAB 2013a code for mojeGUI.fig
%   Graficzny panel u¿ytkownika dla wizualizacji problemu warunkuów KKT.
%   Cechy i elementy:
%       1) Algorytm szuka minimum z danej funkcji przy okreslonych
%           ograniczeniach oraz badanym zakresie,
%       2) W polu „Wzór” mozna wpisac dowolny wzór przyjmujac oznaczenia na zmienne x1,x2
%           (x3 dla wersji trójwymiarowej),
%       3) Ograniczenia musza byc podawane w postaci znormalizowanej czyli
%           g(x)<=0,
%       4) Krok z jakim jest zrobiona kwantyzacja zmiennych to 0.01 jednostki
%       5) Mozliwy jest do wyboru punkt startowy (tylko w wersji 2 wymiarowej) z którego
%           rozpoczynane sa poszukiwania,
%       3) W programie sa zapisane przyk³ady dla których rozwiazania zosta³y obliczone analitycznie.
%            Mozna je wybrac w obszarze „Przyk³ady do wyboru” (zosta³y one dok³adniej
%            opisane w niniejszym opracowaniu). Opis i rozwiazanie dok³adne pojawia sie w obszarze
%            „Wynik teoretyczny”.
%       7) Rezultat poszukiwania jest zaprezentowany w dualny sposób
%           – Po pierwsze na wykresie dwu-wymiarowym zielonym punktem z czerwona obwódka,
%           – Po drugie w obszarze „Wynik obliczony” gdzie podany jest dok³adny wynik,
%       8) Wykresy prezentuja 3 rzeczy:
%           – Problem w przestrzeni dwuwymiarowej, gdzie wartosc funkcji jest tylko oznaczona
%          kolorami poziomic,
%           – Czesc wspólna wybranych ograniczen (zaznaczona na czarno),
%           – Problem w przestrzeni 3D, gdzie wartosc funkcji jest oprócz koloru poziomic wizualizowana
%          w postaci wartosci na osi 0Z,
%       9) W przypadku wersji dla problemów z trzema zmiennymi(3D) wizualizacja jest wykonywana
%           dla dwóch z trzech z osi. Trzecia zmienna jest ustawiona na sta³e na wartosc
%           znalezionego minimum. W ten sposób tworzone s¹ rzuty przekrojów na kolejne p³aszczyzny.
%          Trzecia os stanowi wartosc funkcji.
%
%       Plik graficzny z opisem przycisków i dzia³ania: "2d_OpisGUI.jpg".
%
% See also: solver, inline2sym, generator_v2

% Last Modified by GUIDE v2.5 05-Feb-2017 02:54:26

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @mojeGUI_OpeningFcn, ...
                   'gui_OutputFcn',  @mojeGUI_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT

function handles = refreshGUI_basedOnConfig(hObject, dict)
handles = guidata(hObject);  %Get the newest GUI 
disp('refreshGUI_basedOnConfig');
for  k = dict.keys()
    %set(handles.controlName, 'String', handles.config('controlName'));
    if isfield(handles, k{1})
        command = ['set(handles.', k{1} ,', ''String'', dict(''', k{1}, '''));'];
        eval(command);
        handles.config(k{1}) = dict(k{1});
    end
end

function handles = getAndUpdateNumberData(hObject, handles, fieldName)
data = str2double(get(hObject, 'String'));
if isnan(data)
    data = handles.config(fieldName);
    errordlg('Input must be a number','Error');
end
handles.config(fieldName) = data;
handles = refreshGUI_basedOnConfig(hObject, handles.config);

% --- Executes just before mojeGUI is made visible.
function mojeGUI_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to mojeGUI (see VARARGIN)

% Choose default command line output for mojeGUI
handles.output = hObject;

%initialise structure of saved values:
handles.config = containers.Map;
handles.config('e_name') = 'Domyslna';
handles.config('e_n') = 8;
handles.config('e_r') = 5;
handles.config('e_space') = 10;
handles.config('e_vmax') = 1;
handles.config('e_amax') = 1;
handles.config('e_simtime') = 8;


handles.config('e_corridorLength') = 5000;
handles.config('e_obstacles') = 12;
handles.config('e_leaks') = 20;

handles.config('e_step') = 40;
handles.stopCondition = false;

handles.axes1.Visible = 'off';
handles.axes2.Visible = 'off';

% Update handles structure
guidata(hObject, handles);
handles = refreshGUI_basedOnConfig(hObject, handles.config);
guidata(hObject, handles);

% UIWAIT makes mojeGUI wait for user response (see UIRESUME)
% uiwait(handles.figure1);

% --- Outputs from this function are returned to the command line.
function varargout = mojeGUI_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

% --- Executes on button press in pb_UruchomSymulacje.
function pb_UruchomSymulacje_Callback(hObject, eventdata, handles)
% hObject    handle to pb_UruchomSymulacje (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Reset stop condition, hide axes
handles.stopCondition = false;
handles.axes1.Visible = 'on';
axes(handles.axes1);
axis off;
handles.axes2.Visible = 'on';
axes(handles.axes2);
axis off;
guidata(hObject, handles);

% Get Parameter for computation
parameters = handles.config;

%Uruchom symulacje:
robotData.n = parameters('e_n');
robotData.r = parameters('e_r');
robotData.space = parameters('e_space');
robotData.vmax = parameters('e_vmax');
robotData.amax = parameters('e_amax');

simTime = 3600*parameters('e_simtime');
corridorLength = parameters('e_corridorLength');
obstacles = parameters('e_obstacles');
leak = parameters('e_leaks');
step = parameters('e_step');
if evalin('base', 'exist(''conf'', ''var'')') > 0 
    conf = evalin('base', 'conf');
    sim(robotData, simTime, corridorLength, obstacles, leak, step, conf, hObject);
else
    msgbox('Brak wczytanego lub wygenerowanego pliku konfiguracji.','Symulacja');
end

disp('Done');

function e_name_Callback(hObject, eventdata, handles)
% hObject    handle to e_name (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
value = get(hObject, 'String');
handles.config('e_name') = value;

% Update handles structure
handles = refreshGUI_basedOnConfig(hObject, handles.config);
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function e_name_CreateFcn(hObject, eventdata, handles)
% hObject    handle to e_name (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function e_n_Callback(hObject, eventdata, handles)
% hObject    handle to e_n (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of e_n as text
%        str2double(get(hObject,'String')) returns contents of e_n as a double

handles = getAndUpdateNumberData(hObject, handles, 'e_n');
% Update handles structure
guidata(hObject, handles);



% --- Executes during object creation, after setting all properties.
function e_n_CreateFcn(hObject, eventdata, handles)
% hObject    handle to e_n (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on button press in pb_ZapiszKonfiguracje.
function pb_ZapiszKonfiguracje_Callback(hObject, eventdata, handles)
% hObject    handle to pb_ZapiszKonfiguracje (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%Stwórz konfiguracje na podstawie wpisanych parametrów:
conf  = handles.config;


%Generuj elementy:
robotData.n = conf('e_n');
robotData.r = conf('e_r');
robotData.space = conf('e_space');
robotData.vmax = conf('e_vmax');
robotData.amax = conf('e_amax');

simTime = 3600*conf('e_simtime');
corridorLength = conf('e_corridorLength');
obstaclesCount = conf('e_obstacles');
leaksCount = conf('e_leaks');
holesCount = 10;
[robots, leaks, obstacles, holes] = init(robotData,simTime,corridorLength,obstaclesCount,leaksCount, holesCount);

conf('robots') = robots;
conf('obstacles') = obstacles;
conf('leaks') = leaks;
conf('holes') = holes;
save(['Konfigruacja_', datestr(now,'ddmmyyyy_HHMMSS')], 'conf');
rehash %update paths,

% Update handles structure
%handles = refreshGUI_basedOnConfig(hObject,handles.config);
guidata(hObject, handles);

% --- Executes on button press in pb_OtworzKonfiguracje.
function pb_OtworzKonfiguracje_Callback(hObject, eventdata, handles)
% hObject    handle to pb_OtworzKonfiguracje (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

[fileName, pathName] = uigetfile({'*.mat'},'Wybierz plik z konfiguracj¹ wygenerowany w poprzednim punkcie.');
if fileName ~= 0
    command = sprintf('load(''%s'')', [pathName,fileName]);
    evalin('base', command);
    if evalin('base', 'exist(''conf'', ''var'')') > 0 
        symParam = evalin('base', 'conf');
        msg = ['Wczytano konfiguracje o nazwie: ', symParam('e_name')];
        msgbox(msg, 'Symulacja');
    else
        msgbox('Bledny plik konfiguracji - prosze wczytac inny plik.','Symulacja');
    end
end

% Update handles structure
handles = refreshGUI_basedOnConfig(hObject, symParam);
guidata(hObject, handles);


% --- If Enable == 'on', executes on mouse press in 5 pixel border.
% --- Otherwise, executes on mouse press in 5 pixel border or over pb_ZapiszKonfiguracje.
function pb_ZapiszKonfiguracje_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to pb_ZapiszKonfiguracje (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



function e_r_Callback(hObject, eventdata, handles)
% hObject    handle to e_r (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of e_r as text
%        str2double(get(hObject,'String')) returns contents of e_r as a double

handles = getAndUpdateNumberData(hObject, handles, 'e_r');
% Update handles structure
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function e_r_CreateFcn(hObject, eventdata, handles)
% hObject    handle to e_r (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pb_ZakonczSymulacje.
function pb_ZakonczSymulacje_Callback(hObject, eventdata, handles)
% hObject    handle to pb_ZakonczSymulacje (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.stopCondition = true;
% Update handles structure
guidata(hObject, handles);



function e_step_Callback(hObject, eventdata, handles)
% hObject    handle to e_step (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of e_step as text
%        str2double(get(hObject,'String')) returns contents of e_step as a double
handles = getAndUpdateNumberData(hObject, handles, 'e_step');
% Update handles structure
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function e_step_CreateFcn(hObject, eventdata, handles)
% hObject    handle to e_step (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function e_space_Callback(hObject, eventdata, handles)
% hObject    handle to e_space (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of e_space as text
%        str2double(get(hObject,'String')) returns contents of e_space as a double
handles = getAndUpdateNumberData(hObject, handles, 'e_space');
% Update handles structure
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function e_space_CreateFcn(hObject, eventdata, handles)
% hObject    handle to e_space (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function e_vmax_Callback(hObject, eventdata, handles)
% hObject    handle to e_vmax (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of e_vmax as text
%        str2double(get(hObject,'String')) returns contents of e_vmax as a double
handles = getAndUpdateNumberData(hObject, handles, 'e_vmax');
% Update handles structure
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function e_vmax_CreateFcn(hObject, eventdata, handles)
% hObject    handle to e_vmax (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function e_amax_Callback(hObject, eventdata, handles)
% hObject    handle to e_amax (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of e_amax as text
%        str2double(get(hObject,'String')) returns contents of e_amax as a double
handles = getAndUpdateNumberData(hObject, handles, 'e_amax');
% Update handles structure
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function e_amax_CreateFcn(hObject, eventdata, handles)
% hObject    handle to e_amax (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function e_simtime_Callback(hObject, eventdata, handles)
% hObject    handle to e_simtime (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of e_simtime as text
%        str2double(get(hObject,'String')) returns contents of e_simtime as a double
handles = getAndUpdateNumberData(hObject, handles, 'e_simtime');
% Update handles structure
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function e_simtime_CreateFcn(hObject, eventdata, handles)
% hObject    handle to e_simtime (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function e_corridorLength_Callback(hObject, eventdata, handles)
% hObject    handle to e_corridorLength (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of e_corridorLength as text
%        str2double(get(hObject,'String')) returns contents of e_corridorLength as a double
handles = getAndUpdateNumberData(hObject, handles, 'e_corridorLength');
% Update handles structure
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function e_corridorLength_CreateFcn(hObject, eventdata, handles)
% hObject    handle to e_corridorLength (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function e_obstacles_Callback(hObject, eventdata, handles)
% hObject    handle to e_obstacles (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of e_obstacles as text
%        str2double(get(hObject,'String')) returns contents of e_obstacles as a double
handles = getAndUpdateNumberData(hObject, handles, 'e_obstacles');
% Update handles structure
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function e_obstacles_CreateFcn(hObject, eventdata, handles)
% hObject    handle to e_obstacles (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function e_leaks_Callback(hObject, eventdata, handles)
% hObject    handle to e_leaks (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of e_leaks as text
%        str2double(get(hObject,'String')) returns contents of e_leaks as a double
handles = getAndUpdateNumberData(hObject, handles, 'e_leaks');
% Update handles structure
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function e_leaks_CreateFcn(hObject, eventdata, handles)
% hObject    handle to e_leaks (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
