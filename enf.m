function [y0,y] = enf(x, BlockSize, Overlap, Window, Zeropad, Fs, Frequency)
%--------------------INPUT SEGMENTATION-----------------------------
blocknum = floor(length(x)/BlockSize); %floor is used since any remaining samples are killed off
overlapcount = round((Overlap)*BlockSize);
%determining the number of Blocks for 1 dimensional array
if (Overlap == 1 || Overlap == 0)
  y1 = repmat([1:1:BlockSize],blocknum,1);%works
else
columns_matrix = repmat([0:BlockSize-overlapcount:length(x)-BlockSize].',1,BlockSize);
blocks_available = size(columns_matrix,1);                  %number of Blocks that can be created based on the overlap factor (number of rows)
rows_matrix = repmat([1:1:BlockSize],blocks_available,1);    %creates 'blocks_available' number of blocks based on the overlap factor
y1 = rows_matrix + columns_matrix;
end
%y1 is the index array all that needs to be done is to modify x to be x(y1)
   y1 = x(y1);

% Windowing
   if(strcmp(Window,"Hamming") == 1)
      window = repmat(hamming(BlockSize).',blocks_available,1);
   elseif(strcmp(Window,"hanning") == 1)
      window = repmat(hanning(BlockSize).',blocks_available,1);
   elseif(strcmp(Window,"blackman") == 1)
      window = repmat(blackman(BlockSize).',blocks_available,1);
   else
      window = 1;
   end
y1 = y1.*window;

%ZeroPadding Matrix
padding = zeros(blocks_available,Zeropad);
y1 = [y1 padding]; %It appends the number of zeroes from the first matrix to another


y1 = abs(fft(y1,BlockSize+Zeropad,2));
% ----------END OF INPUT SEGMENTATION--------------------------------

%Creating Frequency Bins
N = BlockSize+Zeropad;  %Total Block Size

k = [1:N];              %Dummy index array for creating the frequency array

F = (k-1)*Fs/N;          %Frequency Array

%NarrowBand Region Array
nb0 = find(F == Frequency-1);
nb1 = find(F == Frequency+1);
narrowband = nb0:nb1; %THE NARROWBAND REGION (indices that correspond to the Frequency values)
NarrowbandFreq = F(narrowband);
%this is a matrix containing only the values for which the frequency value occurs in each block

%Calculating Max Energy
y1 = y1(:,narrowband); %in the matrix y1, this will give all the rows from indices 'nb0' to 'nb1' since nb0:nb1 starts at nb0 and increments by 1 until it reaches nb1
MaxEnergy = max(y1,[],2).'; %returns the maximum energy in each row of the energy matrix WITHIN THE NARROWBAND (it is transposed since it normally returns it as a column vector so it is transposed to make it a row vector


y0 = MaxEnergy; % MAX ENERGY IS OUPUTTED

%Weighted Energy
surf(y1) %PLOTS THE SURFACE PLOT OF y1 WITH ONLY INDICES FROM THE NARROWBAND
NarrowbandFreq = F(narrowband);
WeightedEnergy = (sum((NarrowbandFreq.*y1),2)./sum(y1,2)).'; %it is transposed so it is a Mx1 row vector

y = WeightedEnergy; % WEIGHTED ENERGY OUTPUTTED

