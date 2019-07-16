% Convert .INV file obtained from Res2dinv into .MOD file for Res2dmod
%
% IMPORTANT NOTES
% 1. Reduces number of different model resistivities to a max. of 10
% 2. Needs at least 9 rows of model blocks
% 3. Inversion must have been carried out with refined model (i.e., two 
%    model blocks between adjacent electrodes)
% 4. Inversion must have been carried out with extended model (i.e., without
%    larger side blocks
% 
% Matthias Bucker, May 2019
% Last update 16/07/2019
clear all; close all; clc;

%% INPUT DATA (PLEASE EDIT)

FileName = 'D0.inv';   % File name
nr0 = 9; % <= 9!                    % Initial/approx. number of different 
                                    % model resistivites (max. 9)
nn = 20;                            % Number of depth levels
ary = 3;                            % Array type (1=Wenner alpha, 2=pole-pole, 3=dipole-dipole, 4=Wenner beta, 5=Wenner Gamma, 6=inline pole-dipole, 7=Wenner-Schlumberger, 8=equatorial dipole-dipole

%% MAIN (EDIT WITH CAUTION)

% Read model data from inversion file (.INV)
[x,d,mm] = read_inv(FileName);

% Sort resistivity values into nr0 logarithmically equidistant bins and
% replace block resistivities by bin numbers (1 through nr0)
MM = log10(mm);
minM = min(min(MM));
MM = MM-minM;
nfac = (nr0)/max(max(MM));
MM = round(MM.*nfac); 
RR = round(10.^(MM./nfac+minM));    % Compute bin resistivities (not needed)
R = unique(RR);                     % Resistivities of non-empty bins
% Remove empty bins and relabel
[M,~,indMMval] = unique(MM);
MMnew = reshape(indMMval,size(MM)); 
MMnew = MMnew-1;                    % Labels start from "0"

% Compile general information
nelec = (size(x,2)+1)/2;            % Number of electrodes
nspac = x(3)-x(1);                  % Unit electrode spacing
ncol = size(MM,2);                  % Number of model columns
nlin = size(MM,1);                  % Number of model lines
nr = length(R);                     % Number of model resistivities
x1 = x(1);                          % Position of first electrode

% Write model file
% Open file for writing
fidw = fopen([FileName(1:end-4) '.mod'],'wt');
% Write lines
% Title
fprintf(fidw,['Source file: ' FileName '\n']); 
% Number of electrodes, number of levels
fprintf(fidw,'%g,%g\n',nelec,nn); 
% "0" indicates no water layer
fprintf(fidw,'0\n'); 
% Electrode spacing
fprintf(fidw,'%g\n',nspac); 
% "2" indicates user-defined block depths
fprintf(fidw,'2\n'); 
% Position of the first electrode (m), number of blocks, number of model 
% resistivity values
fprintf(fidw,'%g,%g,%g\n',x1,ncol,nr);
% Number of nodes between adjacent electrodes
fprintf(fidw,'2\n'); 
% Resistivity values (Ohm.m)
fprintf(fidw,'%g, ',R(1:end-1));
fprintf(fidw,'%g\n',R(end));
% Number of lines of model blocks	
fprintf(fidw,'%d\n',nlin);
% Depths of the lower limits of the model blocks
fprintf(fidw,'%.3g, ',d(1:end-1));
fprintf(fidw,'%.3g\n',d(end));									
% Resistivity labels of model blocks
fprintf(fidw,[repmat('%d',[1 ncol]) '\n'],MMnew');
% Array type
fprintf(fidw,'%g\n',ary);
% Some taling zeros
fprintf(fidw,repmat('0\n',[1 6]));

fclose('all');