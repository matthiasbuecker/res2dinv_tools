function [x,ld,m] = read_inv(FileName)
% READ_INV  Read .INV file with Res2Dinv inversion results.
% 
% Output
% x:    X positions of right edge of model blocks [m]
% m:    Inverted model block resistivities [Ohm.m]
% ld:   Layer depths [m]
%
% Matthias Buecker, May 2019
% Last update 16/07/2019

%% Main function
fid=fopen(FileName,'r');                    	% Open file for reading
if fid~=(-1)                                   	% Check if file has been opened 
    
    % Search file for last iteration
    inv = 0;                                    % Initialize interation count
    while ~feof(fid)
        tline=fgetl(fid);                       % Gets the next text line, returns a text string
        if strcmp(tline,['ITERATION ' num2str(inv+1)])
            inv = inv+1;                        % Increase iteration count
            position = ftell(fid);              % Remember position in file
        end
    end
    % Set position in file back to last iteration
    fseek(fid,position,'bof');
    
    % Loop to read in layers of block model
    layer = 0;                                  % Layer count
    while ~feof(fid)
        tline=fgetl(fid);
        if strcmp(tline,['LAYER ' num2str(layer+1)])
            layer = layer+1;
            tline = fgetl(fid);
            out = textscan(tline,'%d,%f');
            nb = out{1,1};                      % Number of blocks in layer
            if ~isempty(out{1,2})
                ld(layer) = out{1,2};           % Layer depth (the last has none)
            end
            % Read block x positions and resistivites 
            for ii = 1:nb-1
                tline = fgetl(fid);
                out = textscan(tline,'%f,%f');
                x(layer,ii) = out{1,1};
                m(layer,ii) = out{1,2};
            end   
            % Last resistivity (there is no x position for the last point)
            tline = fgetl(fid);
            out = textscan(tline,'%f');
            m(layer,nb) = out{1,1};
            x(layer,nb) = 2*x(layer,nb-1)-x(layer,nb-2); % Extrapolate last x position
        end
    end
	ld = [ld, 2*ld(end)-ld(end-1)]; % Extrapolate last layer depth  
    x = unique(x)';
    if x(1)>0
        x = [0,x];                      % Make sure x = 0 is included
    end
else
   disp(['dmread: File ' FileName ' not opened!']) 
end
fclose('all');                                      % Close all open files
end