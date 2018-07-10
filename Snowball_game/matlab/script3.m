clear all;
close all;
SIZE = 32;
im=imread('snapvrai.jpg');

%im=cat(3,[0,255;0,255],[0,0;255,255],[255,0;0,255]);
imshow(im);
red = im(:,:,1);
green = im(:,:,2);
blue = im(:,:,3);

for i=1:SIZE
    for j=1:SIZE
        im_temp(i,7*j-6:7*j)=rgb2hex([im(i,j,3) im(i,j,1) im(i,j,2)]);  
        %im_temp(i,10*j-9:10*j) = strcat('x"',bluex(i,2*j-1:2*j),redx(i,2*j-1:2*j),greenx(i,2*j-1:2*j),'",');
        
        imag(i,j,:)=hex2rgb(im_temp(i,7*j-6:7*j),255);
    end
    %im_fin(i,:)=strcat('(',im_temp(i,1:9*SIZE+SIZE-1),')',im_temp(i,10*SIZE));
end
