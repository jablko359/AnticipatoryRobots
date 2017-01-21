function [] = generator_v2( s_func, s_ogr, DIMENSION )
%GENERATOR_V2 Skrypt tworz¹cy funkcje z warunkami KKT.
%   Proces generowania jest ca³kowicie automatyczny.
%   Z postaci tekstowej funkcji analizwoanej i ograniczeñ funkcja tworzy
%   nowy plik "kktsystem_gen.m" zawierajacy wszystkie warunki KKT.
%   Wykonuje siê tu symboliczne ró¿niczkowanie.
%   
%   Konwencja nazw zmiennych: x1,x2,x3...
%   Argumenty:
%       1) s_func - funkcja symboliczna 
%       2) s_ogr - cell array z ograniczeniami - moze byæ ich dowolnie
%       du¿o. 
%       3) DIMENSION - rz¹d systemu. Iloœæ wymiarów, ilosæ zmiennych
%       x1,x2,... .
%
% See also: solver, inline2sym, mojeGUI

%get number of limitations
NUM_OGR = size(s_ogr);
NUM_OGR = NUM_OGR(2)

% generate kktsystem file
disp('Generating kktsystem File');
% create a file
fid = fopen( 'kktsystem_gen.m', 'wt' );

%prepare variables
x = sym('x', [(DIMENSION + 2 * NUM_OGR) 1]);

%covert to inline and convert inline to symbolic
in_func = inline(s_func);
sym_func = inline2sym(in_func) ;
for i = 1 : NUM_OGR
    in_ogr{i} = inline(s_ogr{i});
    sym_ogr{i} = inline2sym(in_ogr{i});
end

% derviative
for i = 1 : DIMENSION
    sym_func_dif{i} = diff(sym_func,x(i));
end

for ogr_ind = 1 : NUM_OGR
    for var_ind = 1 : DIMENSION
        sym_ogr_dif{ogr_ind,var_ind} = diff(sym_ogr{ogr_ind},x(var_ind)); %rozniczkuj ogr 1 po zmiennnie 1 (x1)
    end
end
% back to inline -- in order to evaluate
% inline_ogr_1_dif_x1 = inline(sym_ogr_1_dif_x1);
% convert to text
% char_func_dif_x1 = char(sym_func_dif_x1);
%% prepare file 
fprintf( fid,'function F2 = kktsystem_gen(x)');
fprintf(fid, sprintf('\n\n'));

%% prepare kktsyst
for i = 1: DIMENSION
    sym_warunek(i) = sym_func_dif{i} + sym_ogr_dif{1,i} * x(DIMENSION + 1) + sym_ogr_dif{2,i} * x(DIMENSION + 2) + sym_ogr_dif{3,i} * x(DIMENSION + 3);
end

for i = 1: NUM_OGR
    sym_warunek(DIMENSION + i) = x(DIMENSION + i)*sym_ogr{i}+ x(DIMENSION + NUM_OGR + i)^2;
end

for i = 1: NUM_OGR
    sym_warunek(DIMENSION + NUM_OGR + i) = x(DIMENSION + i) * x(DIMENSION + NUM_OGR + i);
end

%% prepare file
fprintf( fid,'F2=[');

for i = 1 : (DIMENSION + 2 * NUM_OGR)
    temp_char = char(sym_warunek(i)); %convert to char
    
    for k = (DIMENSION + 2 * NUM_OGR) : (-1) :  1 %%inverted because x(1) and x(10)
        temp_char = strrep(temp_char,['x' num2str(k)],['x(' num2str(k) ')']); %change x1 to x(1) etc.
    end
    temp_char = strrep(temp_char,' ', ''); %remove whitespace
    
    fprintf( fid,'%s;',temp_char);
    if i < (DIMENSION + 2 * NUM_OGR)
        fprintf(fid, sprintf('\n'));
    end
end
fprintf( fid,'];');

%close file
status = fclose(fid);
if(status == 0)
    disp('Succesfully generated');
else
    disp('Error when closing file');
end

end