%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Program Name : Counting-Coin in Live Video(?mage Processing)                
% Author       : M.Fatih Altunta?                                             
% Description  : This program just tracks all coin, finding values of coin,
%   collecting all coin values and numbers of coin and draws a circle around
%   Then writes values of coin in centre of coins  and 
%   writes collect values of coin and number of coins in scen
%   in this program used Turkish coin https://en.wikipedia.org/wiki/Coins_of_Turkey
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



vidDevice = imaq.VideoDevice('macvideo', 1, 'YCbCr422_1280x720', ... % Acquire input video stream
                    'ROI', [1 1 640 480], ...
                    'ReturnedColorSpace', 'rgb');
vidInfo = imaqhwinfo(vidDevice);  % Acquire input video propert 

circle = vision.ShapeInserter('Shape','Circles',...
                                        'BorderColor', 'Custom', ... % Set Red box handling on count
                                        'CustomBorderColor', [1 0 0], ...
                                        'Fill', true, ...
                                        'FillColor', 'Custom', ...
                                        'CustomFillColor', [1 0 0], ...
                                        'Opacity', 0.4);
htextins = vision.TextInserter('Text', 'Number of count : %2d --  1TL : %2d  + 0,5 tl: %2d  + 0,25 tl: %2d + 0,1 tl: %2d + 0.05tl : %2d ', ... % Set text for number of distinct counts  
                                    'Location',  [7 2], ...
                                    'Color', [1 1 1], ... 
                                    'FontSize', 13);
htextinsCent = vision.TextInserter('Text',  '  %3d  _Kurus',...   ', ... % set text  value of count in centroid of count
                                    'LocationSource', 'Input port', ...
                                    'Color', [1 1 0], ... 
                                    'FontSize', 14);
hVideoIn = vision.VideoPlayer('Name', 'Final Video', ... % Output video player
                                'Position', [100 100 vidInfo.MaxWidth+20 vidInfo.MaxHeight+30]);
nFrame = 0; % Frame number initialization


numberofobjects=0;% numberofcount number initialization
count=0;%
valueofcount=0;% number of value initialization
numbersofcounts=zeros(1,5);


while(nFrame < 350)
                    rgbFrame = step(vidDevice);  % Acquire single frame
                    rgbFrame = flipdim(rgbFrame,2); % obtain the mirror image for displaying,
              

                    I = rgb2gray(rgbFrame); % Converting greyscale image
                    threshold = graythresh(I); % Obtain trehshold for converting binary imag
                    bw = im2bw(I,threshold); % Converting greyscale image
                    z=find(bw);     %complementaring image by  intensity of background
                    if(length(z) >154000)
                         bw=~bw;
                    end
                    bw = bwareaopen(bw,50); %wiping white regions that is smal 50 pixels
                    se = strel('disk',2);
                    bw = imclose(bw,se);%Morphologically close image
                    bw = imfill(bw,'holes'); %filing holes in image 
                    
          rgbFrame(1:20,1:480,:) = 0; % put a black region on the output stream
          [B,L] = bwboundaries(bw,'noholes');
          stats = regionprops(bw,'Area','Centroid');
          threshold = 0.70;
          % Count the number of blobs
          vidIn2 = step(htextins,rgbFrame,[uint8(numberofobjects) numbersofcounts(1,1) numbersofcounts(1,2) numbersofcounts(1,3) numbersofcounts(1,4) numbersofcounts(1,5)]); % Count the number of blobs
          numbersofcounts=zeros(1,5);
          count=0;
          wholearea =zeros(length(B),1);
            for k = 1:length(B)

              boundary = B{k};
              delta_sq = diff(boundary).^2;
              perimeter = sum(sqrt(sum(delta_sq,2)));
              areas = stats(k).Area;
              if(areas>15000);
                  break;
              end
              
              metric = 4*pi*areas/perimeter^2;%%Metric calculation that using deciding  objects which is circle or not.
              if metric > threshold 
                  
                   count=count+1;
                   wholearea(count,1)=areas;%Inserting areas of Coin in Frame 
                   wholearea=sort(wholearea);
                   i=1;
                   while(i<=length(wholearea))
                       if(wholearea(i,1)~=0)
                          minarea= wholearea(i,1); % 5 Turkish Coin area in frame (in turkish Kurus)
                          break;
                       end
                       i=i+1;
                   end
                   maxarea=wholearea(length(wholearea),1); % 100 Turkis Coins area in frame
                   diffvalue=(maxarea-minarea)/8.65-10;% 8.65 is Turkish Coins diameter differences  between 100(The biggest coin) Tc and 5(The smallest coin) Tc
             
                    %This  conditions  using  for detecting type of
                    %coins by areas and diffvalue(differences of diametter)
                  if(areas<=(diffvalue+minarea-50) && areas>=(minarea-50))
                      valueofcount=5;
                       numbersofcounts(1,5)=numbersofcounts(1,5)+1;
                   % 5 Turkish Coin(in turkish Kurus)
                   
                  else if(areas>=(diffvalue+minarea-50) && areas<=(3*diffvalue+minarea-50))
                           valueofcount=10;
                           numbersofcounts(1,4)=numbersofcounts(1,4)+1;
                   %10 Turkish Coin(in turkish Kurus)
                   
                  else if(areas>=(3*diffvalue+minarea-50) && areas<=(6.15*diffvalue+minarea-50))
                           valueofcount=25;
                           numbersofcounts(1,3)=numbersofcounts(1,3)+1;
                     %25 Turkish Coin(in turkish Kurus)
                     
                   else if(areas>=(6.15*diffvalue+minarea-50) && areas<=(8.65*diffvalue+minarea-50)) 
                            numbersofcounts(1,2)=numbersofcounts(1,2)+1;
                            valueofcount=50;
                      %50 Turkish Coin(in turkish Kurus)
                      
                   else if(areas>=(8.65*diffvalue+minarea-50))
                                  numbersofcounts(1,1)=numbersofcounts(1,1)+1;
                                    valueofcount=100;
                        %100 Turkish Coin(in turkish Kurus)
                            end
                         end
                       end
                      end
                  end
              
                             
                  valueofcount=uint16(valueofcount);
                  centroid = stats(k).Centroid;
                  centroid = uint16(centroid);
                  % Instert the circle  on Coin
                  radii = sqrt(areas/pi);
                  vidIn2 = step(circle, vidIn2, [centroid,radii]); 
                  % Write the value of Coin   on centroids
                  centX = centroid(1,1); centY = centroid(1,2);
                  vidIn2 = step(htextinsCent, vidIn2, valueofcount, [centX-6 centY-9]); 
                      
              end
            end
            numberofobjects=count;
            

    

    step(hVideoIn, vidIn2);% Output video stream
    nFrame = nFrame+1;
    
   
end
%% Clearing Memory
release(hVideoIn); 
release(vidDevice);

clc;