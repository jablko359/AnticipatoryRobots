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

% Last Modified by GUIDE v2.5 19-Jun-2014 18:55:26

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


% --- Executes just before mojeGUI is made visible.
function mojeGUI_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to mojeGUI (see VARARGIN)

% Choose default command line output for mojeGUI
handles.output = hObject;

handles.out.ogr1 = '-x1';
handles.out.ogr2 =  '-x2';
handles.out.ogr3 = 'x1^2 + x2^2 - 1';
handles.out.wzor = '(x1-2)^2+x2^2';
% handles.out.typ = 1;

handles.out.x1_from = -2;
handles.out.x1_to = 2;
handles.out.x2_from = -2;
handles.out.x2_to = 2;

set(handles.x1_from, 'String', handles.out.x1_from);
set(handles.x1_to, 'String', handles.out.x1_to);
set(handles.x2_from, 'String', handles.out.x2_from);
set(handles.x2_to, 'String', handles.out.x2_to);

set(handles.wzor, 'String', handles.out.wzor);
set(handles.ograniczenie1, 'String', handles.out.ogr1);
set(handles.ograniczenie2, 'String', handles.out.ogr2);
set(handles.ograniczenie3, 'String', handles.out.ogr3);
% set(handles.popupmenu2, 'Value', handles.out.typ);

% Update handles structure
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


% --- Executes on button press in pushbutton1.
function pushbutton1_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get Parameter for computation
s_func = handles.out.wzor;
% typ = handles.out.typ;
s_ogr = {handles.out.ogr1, handles.out.ogr2, handles.out.ogr3};
% generator(funkcja,ogr);
generator_v2(s_func,s_ogr,2);
%Do computation - solver
x0=[1;1; 1;1;1; 1;1;1;];
options=optimset('Display','iter');
% options=optimset('Display','final');
% x=fsolve(@kktsystem2,x0,options);

rehash

x=fsolve(@kktsystem_gen, x0, options)

% format bank
% x1=x(1);
% x2=x(2);
% lambda1=x(3);
% lambda2=x(4);
% lambda3=x(5);
% s1=x(6);
% s2=x(7);
% s3=x(8);
% x=[x1 x2 lambda1 lambda2 lambda3 s1 s2 s3];

wynik_x = x(1);
wynik_y = x(2);
res = sprintf('(x1,x2) = (%.1f, %.1f)',wynik_x, wynik_y);
disp(res);
set(handles.text10, 'String', res);

%Show the results
x1=handles.out.x1_from:0.01:handles.out.x1_to;
x2=handles.out.x2_from:0.01:handles.out.x2_to;
[X1_mesh, X2_mesh]=meshgrid(x1,x2);

% Change number operator to matrix operator
s_func = strrep(s_func, '^', '.^'); s_func = strrep(s_func, '*', '.*'); s_func = strrep(s_func, '/', './');
s_ogr = strrep(s_ogr, '^', '.^'); s_ogr = strrep(s_ogr, '*', '.*'); s_ogr = strrep(s_ogr, '/', './');
% Create inline functions
in_func = inline(s_func,'x1','x2');
in_ogr_1 = inline(char(s_ogr(1)),'x1','x2');
in_ogr_2 = inline(char(s_ogr(2)),'x1','x2');
in_ogr_3 = inline(char(s_ogr(3)),'x1','x2');
%Compute values of functions
s_func = in_func(X1_mesh,X2_mesh); 
ogr1 = in_ogr_1(X1_mesh,X2_mesh) <= 0;
ogr2 = in_ogr_2(X1_mesh,X2_mesh) <= 0;
ogr3 = in_ogr_3(X1_mesh,X2_mesh) <= 0;

axes(handles.axes1);
cla; % Clear current axis
colormap hot;
hold on, grid on;
title('Wykres 2D z ograniczeniami');
axis auto;
z4=contour(x1,x2,s_func);
z1=contour(x1,x2,ogr1);
z2=contour(x1,x2,ogr2);
z3=contour(x1,x2,ogr3);

plot(wynik_x,wynik_y,'--rs','LineWidth',5,'MarkerSize',10,'MarkerFaceColor', 'g');
hold off;

axes(handles.axes3); %plot ograniczenia
cla; % Clear current axis
grid on;
axis auto;
sum_ogr  = double(ogr1)+double(ogr2)+double(ogr3);
mask = (sum_ogr == 3);
sum_ogr = sum_ogr.*mask;
contourf(x1,x2,double(sum_ogr)*(-1));
title('Ograniczenia');

axes(handles.axes2); % 3d
cla; % Clear current axis
mesh(X1_mesh,X2_mesh,s_func);
title('Wykres 3D');
colormap hot;
colorbar;

hold on; grid on;
z1 = contour(x1,x2,ogr1);
z2 = contour(x1,x2,ogr2);
z3 = contour(x1,x2,ogr3);
hold off;
disp ('Done');
% axes(handles.axes1);
% cla; % Clear current axis
% switch typ
%     case 1  %step
%         plot(0:1,0:1);
%     case 2  %impulse
%         plot(0:5,0:5);
% end


function wzor_Callback(hObject, eventdata, handles)
% hObject    handle to wzor (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

wzor = get(hObject, 'String');
% if isnan(wzor)
%     set(hObject, 'String', 0);
%     errordlg('Input must be a number','Error');
% end

handles.out.wzor = wzor;
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function wzor_CreateFcn(hObject, eventdata, handles)
% hObject    handle to wzor (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function ograniczenie1_Callback(hObject, eventdata, handles)
% hObject    handle to ograniczenie1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

ogr = get(hObject, 'String')
if(isempty(ogr))
    ogr = '0*x1';
end
handles.out.ogr1 = ogr;
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function ograniczenie1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ograniczenie1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on selection change in popupmenu2.
function popupmenu2_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenu2 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu2
popup_sel_index = get(hObject, 'Value');
handles.out.typ = popup_sel_index;
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function popupmenu2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function ograniczenie2_Callback(hObject, eventdata, handles)
% hObject    handle to ograniczenie2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of ograniczenie2 as text
%        str2double(get(hObject,'String')) returns contents of ograniczenie2 as a double
ogr = get(hObject, 'String');
if(isempty(ogr))
    ogr = '0*x1';
end
handles.out.ogr2 = ogr;
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function ograniczenie2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ograniczenie2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function ograniczenie3_Callback(hObject, eventdata, handles)
% hObject    handle to ograniczenie3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of ograniczenie3 as text
%        str2double(get(hObject,'String')) returns contents of ograniczenie3 as a double
ogr = get(hObject, 'String');
if(isempty(ogr))
    ogr = '0*x1';
end
handles.out.ogr3 = ogr;
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function ograniczenie3_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ograniczenie3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in domyslnyPrzyklad.
function domyslnyPrzyklad_Callback(hObject, eventdata, handles)
% hObject    handle to domyslnyPrzyklad (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.out.ogr1 = '-x1';
handles.out.ogr2 =  '-x2';
handles.out.ogr3 = 'x1^2 + x2^2 - 1';
handles.out.wzor = '(x1-2)^2+x2^2';

handles.out.x1_from = -5;
handles.out.x1_to = 5;
handles.out.x2_from = -5;
handles.out.x2_to = 5;

set(handles.x1_from, 'String', handles.out.x1_from);
set(handles.x1_to, 'String', handles.out.x1_to);
set(handles.x2_from, 'String', handles.out.x2_from);
set(handles.x2_to, 'String', handles.out.x2_to);

guidata(hObject, handles);

set(handles.wzor, 'String', handles.out.wzor);
set(handles.ograniczenie1, 'String', handles.out.ogr1);
set(handles.ograniczenie2, 'String', handles.out.ogr2);
set(handles.ograniczenie3, 'String', handles.out.ogr3);

set(handles.opisWyniku, 'String', sprintf('Rozwiazaniem teoretycznym jest (1,0).'));



function x1_from_Callback(hObject, eventdata, handles)
% hObject    handle to x1_from (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of x1_from as text
%        str2double(get(hObject,'String')) returns contents of x1_from as a double
data = str2double(get(hObject,'String'));
if isnan(data)
    set(hObject, 'String', 0);
    errordlg('Input must be a number','Error');
else
    handles.out.x1_from = data;
    guidata(hObject, handles);
end



% --- Executes during object creation, after setting all properties.
function x1_from_CreateFcn(hObject, eventdata, handles)
% hObject    handle to x1_from (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function x1_to_Callback(hObject, eventdata, handles)
% hObject    handle to x1_to (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of x1_to as text
%        str2double(get(hObject,'String')) returns contents of x1_to as a double
data = str2double(get(hObject,'String'));
if isnan(data)
    set(hObject, 'String', 0);
    errordlg('Input must be a number','Error');
else
    handles.out.x1_to = data;
    guidata(hObject, handles);
end

% --- Executes during object creation, after setting all properties.
function x1_to_CreateFcn(hObject, eventdata, handles)
% hObject    handle to x1_to (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function x2_from_Callback(hObject, eventdata, handles)
% hObject    handle to x2_from (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of x2_from as text
%        str2double(get(hObject,'String')) returns contents of x2_from as a double
data = str2double(get(hObject,'String'));
if isnan(data)
    set(hObject, 'String', 0);
    errordlg('Input must be a number','Error');
else
    handles.out.x2_from = data;
    guidata(hObject, handles);
end

% --- Executes during object creation, after setting all properties.
function x2_from_CreateFcn(hObject, eventdata, handles)
% hObject    handle to x2_from (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function x2_to_Callback(hObject, eventdata, handles)
% hObject    handle to x2_to (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of x2_to as text
%        str2double(get(hObject,'String')) returns contents of x2_to as a double
data = str2double(get(hObject,'String'));
if isnan(data)
    set(hObject, 'String', 0);
    errordlg('Input must be a number','Error');
else
    handles.out.x2_to = data;
    guidata(hObject, handles);
end

% --- Executes during object creation, after setting all properties.
function x2_to_CreateFcn(hObject, eventdata, handles)
% hObject    handle to x2_to (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in przykladV1.
function przykladV1_Callback(hObject, eventdata, handles)
% hObject    handle to przykladV1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.out.ogr1 = 'x1 + x2 - 4';
handles.out.ogr2 = '0*x1';
handles.out.ogr3 = '0*x1';
% Optymalne: (1,3);
handles.out.wzor = '(x1-2)^2+(x2-4)^2';

handles.out.x1_from = -5;
handles.out.x1_to = 5;
handles.out.x2_from = -5;
handles.out.x2_to = 5;
guidata(hObject, handles);

set(handles.x1_from, 'String', handles.out.x1_from);
set(handles.x1_to, 'String', handles.out.x1_to);
set(handles.x2_from, 'String', handles.out.x2_from);
set(handles.x2_to, 'String', handles.out.x2_to);

set(handles.wzor, 'String', handles.out.wzor);
set(handles.ograniczenie1, 'String', handles.out.ogr1);

set(handles.ograniczenie2, 'String', '');
set(handles.ograniczenie3, 'String', '');

set(handles.opisWyniku, 'String', sprintf('Rozwiazaniem teoretycznym jest (1,3).'));



% --- Executes on button press in przykladV2.
function przykladV2_Callback(hObject, eventdata, handles)
% hObject    handle to przykladV2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.out.ogr1 = 'x1 + x2 - 8';
handles.out.ogr2 = '-x1';
handles.out.ogr3 = '-x2';

handles.out.wzor = '-(x1-2)^2-(x2-4)^2';
%Spelnia 7 punktow - optymalne (8,0)
handles.out.x1_from = -9;
handles.out.x1_to = 9;
handles.out.x2_from = -9;
handles.out.x2_to = 9;

set(handles.x1_from, 'String', handles.out.x1_from);
set(handles.x1_to, 'String', handles.out.x1_to);
set(handles.x2_from, 'String', handles.out.x2_from);
set(handles.x2_to, 'String', handles.out.x2_to);
guidata(hObject, handles);

set(handles.wzor, 'String', handles.out.wzor);
set(handles.ograniczenie1, 'String', handles.out.ogr1);
set(handles.ograniczenie2, 'String', handles.out.ogr2);
set(handles.ograniczenie3, 'String', handles.out.ogr3);

set(handles.opisWyniku, 'String', sprintf('Rozwiazaniem teoretycznym jest (8,0).\nAle warunki spelnia te¿: (3,5),(2,4),(0,4),(2,0),(0,0),(0,8),(8,0). '));


% --- Executes on button press in przykladV3.
function przykladV3_Callback(hObject, eventdata, handles)
% hObject    handle to przykladV3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.out.ogr1 = 'x1+x2-6';
handles.out.ogr2 = '6-2*x1-x2';
handles.out.ogr3 = '-x2';
handles.out.wzor = '10*(x1-3.5)^2+20*(x2-4)^2';
handles.out.x1_from = -7;
handles.out.x1_to = 7;
handles.out.x2_from = -7;
handles.out.x2_to = 7;
% Optimum (2.5, 3.5);
set(handles.x1_from, 'String', handles.out.x1_from);
set(handles.x1_to, 'String', handles.out.x1_to);
set(handles.x2_from, 'String', handles.out.x2_from);
set(handles.x2_to, 'String', handles.out.x2_to);
guidata(hObject, handles);

set(handles.wzor, 'String', handles.out.wzor);
set(handles.ograniczenie1, 'String', handles.out.ogr1);
set(handles.ograniczenie2, 'String', handles.out.ogr2);
set(handles.ograniczenie3, 'String', handles.out.ogr3);

set(handles.opisWyniku, 'String', 'Rozwiazaniem teoretycznym jest (2.5,3.5).');



function edit13_Callback(hObject, eventdata, handles)
% hObject    handle to edit13 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit13 as text
%        str2double(get(hObject,'String')) returns contents of edit13 as a double


% --- Executes during object creation, after setting all properties.
function edit13_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit13 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit14_Callback(hObject, eventdata, handles)
% hObject    handle to edit14 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit14 as text
%        str2double(get(hObject,'String')) returns contents of edit14 as a double


% --- Executes during object creation, after setting all properties.
function edit14_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit14 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
