clear all;
close all;

im=imread('snap.png');

imshow(im);

red = im(:,:,1);
green = im(:,:,2);
blue = im(:,:,3);

redx = dec2hex(red);
greenx = dec2hex(green);
bluex = dec2hex(blue);

im_final=char(ones(32,32*9));


im_rgb = strcat('x"',bluex,redx,greenx,'"');

for i =1:32
    for j=1:32*9
       
        im_final(i,j)=strcat(im_rgb((i-1)*32+j,:));    
            
     
    end 
end 
%{
for i = 1:32
    idij(i,:)=strcat(im_rgb(i,:),',')
end
%}