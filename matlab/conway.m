% Conway's game of life
% Matthias Thumann, 2021

clc
clear
close all
format

%%%%%%%%%%%%%
% Example 1 %
%%%%%%%%%%%%%
N = 30;
cells = zeros(N, N);
cells(14,13) = 1;
cells(14,14) = 1;
cells(14,15) = 1;
cells(13,14) = 1;
cells(15,14) = 1;

%%%%%%%%%%%%%
% Example 2 %
%%%%%%%%%%%%%
% N = 40;
% cells = zeros(N, N);
% cells(2:N-1, 2:N-1) = randi([0 1], N-2);

%%%%%%%%%%%%%
% Example 3 %
%%%%%%%%%%%%%
% N = 40;
% cells = zeros(N, N);
% for i=2:N-1
%     for j=2:N-1
%         if rand < 0.1
%             cells(i,j) = 1;
%         end
%     end
% end

figure
while true
    next_cells = cells;
    imagesc(cells)
    pause(0.3)
    
    % Boundary condition: all edges are zero
    for i=2:N-1
        for j=2:N-1
            % Each cell has eight neighbors
            neighbors = sum(sum(cells(i-1:i+1, j-1:j+1))) - cells(i, j);
            
            % Cell alive
            if cells(i,j) == 1
                % Cell alive, only one neighbor alive
                % -> die
                if neighbors < 2
                    next_cells(i,j) = 0;
                % Cell alive, two or three neighbors alive
                % -> stay alive

                % Cell alive, > three neighbors alive
                % -> die
                elseif neighbors > 3
                    next_cells(i,j) = 0;
                end
            % Cell dead    
            else
                % Cell dead, 3 neighbors alive
                % -> revive
                if neighbors == 3
                    next_cells(i,j) = 1;
                end
            end
        end
    end
    
    % If nothing changed, stop
    if next_cells == cells
        break
    end
    
    cells = next_cells;
end