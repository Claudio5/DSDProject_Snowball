clear all;
close all;
SIZE = 32;
im=imread('facebook.png');
imwrite(im,'snap.bmp');
I=imread('snap.bmp');

%{
threshForPlanes = zeros(3,3);			

for i = 1:3
    threshForPlanes(i,:) = multithresh(I(:,:,i),3);
end

quantPlane = zeros( size(I) );
%}
for i = 1:3
    thresh=linspace(0,255,4);
    val=[0 thresh(2:end) 255];
    %value = [0 threshForPlanes(i,2:end) 255]; 
    %quantPlane(:,:,i) = imquantize(I(:,:,i),threshForPlanes(i,:),value);
    quantPlane(:,:,i) = imquantize(I(:,:,i),thresh,val);
end

quantPlane = uint8(quantPlane);

imshow(quantPlane)

red = quantPlane(:,:,1);
green = quantPlane(:,:,2);
blue = quantPlane(:,:,3);

for i=1:SIZE
    for j=1:SIZE
        if(red(i,j)<16)
            redx(i,2*j-1:2*j)=strcat('0',dec2hex(red(i,j)));
        else
            redx(i,2*j-1:2*j)=dec2hex(red(i,j));
        end
        if(blue(i,j)<16)
            bluex(i,2*j-1:2*j)=strcat('0',dec2hex(blue(i,j)));
        else
            bluex(i,2*j-1:2*j)=dec2hex(blue(i,j));
        end
         if(green(i,j)<16)
            greenx(i,2*j-1:2*j)=strcat('0',dec2hex(green(i,j)));
        else
            greenx(i,2*j-1:2*j)=dec2hex(green(i,j));
        end
        
        im_temp(i,10*j-9:10*j) = strcat('x"',bluex(i,2*j-1:2*j),redx(i,2*j-1:2*j),greenx(i,2*j-1:2*j),'",');
        
        
    end
    im_fin(i,:)=strcat('(',im_temp(i,1:9*SIZE+SIZE-1),')',im_temp(i,10*SIZE));
end

