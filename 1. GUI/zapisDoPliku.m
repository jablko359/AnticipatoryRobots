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

%% prepare file 
fprintf( fid,'function F2 = kktsystem_gen(x)');
fprintf(fid, sprintf('\n\n'));

%close file
status = fclose(fid);
if(status == 0)
    disp('Succesfully generated');
else
    disp('Error when closing file');
end

end