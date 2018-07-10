clear all;
close all;
SIZE = 32;
im=imread('snap_p2.png');
imwrite(im,'snap_p2.bmp');
I=imread('snap_p2.bmp');

%im=cat(3,[0,255;0,255],[0,0;255,255],[255,0;0,255]);
imshow(I);
red = I(:,:,1);
green = I(:,:,2);
blue = I(:,:,3);

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
        
        im_temp(i,10*j-9:10*j) = strcat('x"',redx(i,2*j-1:2*j),greenx(i,2*j-1:2*j),bluex(i,2*j-1:2*j),'",');
        
        
    end
    im_fin(i,:)=strcat('(',im_temp(i,1:9*SIZE+SIZE-1),')',im_temp(i,10*SIZE));
end


