/*
 * main.c
 *
 *  Created on: 1 mai 2017
 *      Author: loureiro
 */

#include <stdio.h>
#include "xparameters.h"
#include "xbasic_types.h"
#include "xstatus.h"
#include "xil_exception.h"
#include "xgpio.h"
#include "mb_interface.h"
#include "snowball_parameters.h"
#include "math.h"

XGpio PushButtons;
XGpio GpioLeds;
Xint32 keyb_code;
Xint32 code_new;
Xint32 buzz_en=0;

typedef struct {
	Xint32 posX;
	Xint32 speedX;
	Xint32 posX_pre_throw;
	Xint32 health;

} Player;

typedef struct {
	Xint32 posX;
	Xint32 posY;
	Xint32 visible;
	Xint32 init_angle;
	Xint32 angle_pre_throw;
	Xint32 init_t;
	Xint32 pente;

}Ball;

Player player1;
Player player2;

Ball ball1;
Ball ball2;
Xuint32 count3 = 0;

int player1_over = 0;
int player2_over = 0;

void initGame()
{
	player1.posX =120;
	player1.speedX = 15;
	player1.posX_pre_throw = 0;
	player1.health = 5;

	player2.posX = 520-PLAYER_WIDTH;
	player2.speedX = 15;
	player2.posX_pre_throw = 0;
	player2.health = 5;

	ball1.posX = player1.posX + PLAYER_WIDTH;
	ball1.posY = SCREEN_HEIGHT - 160 -PLAYER_HEIGHT;
	ball1.visible = 0;
	ball1.init_angle = 45;
	ball1.init_t = 1;
	ball1.angle_pre_throw = ball1.init_angle;
	ball1.pente = 1;

	ball2.posX = player2.posX;
	ball2.posY = SCREEN_HEIGHT - 160 -PLAYER_HEIGHT;
	ball2.visible = 0;
	ball2.init_angle = 180-45;
	ball2.init_t = 1;
	ball2.angle_pre_throw = ball2.init_angle;
	ball2.pente = 1;


}

void update_ball1()
{
	ball1.posX = player1.posX + PLAYER_WIDTH;
}

void update_ball2()
{
	ball2.posX = player2.posX;
}

void restart_game()
{
	initGame();

	setPlayer1X(player1.posX);
	setPlayer2X(player2.posX);
	setHealthBar1(player1.health);
	setHealthBar2(player2.health);
}


void restart_ball1()
{
	ball1.posX = player1.posX + PLAYER_WIDTH;
	ball1.posY = SCREEN_HEIGHT - 160 -PLAYER_HEIGHT;
	ball1.visible = 0;
	ball1.init_angle = 45;
	ball1.init_t = 1;
}

void restart_ball2()
{
	ball2.posX = player2.posX ;
	ball2.posY = SCREEN_HEIGHT - 160 -PLAYER_HEIGHT;
	ball2.visible = 0;
	ball2.init_angle = 180-45;
	ball2.init_t = 1;
}

void ballistic_calculation1()
{

	static float t1=0;

	if(ball1.init_t)
	{
		t1 = 0;
		ball1.init_t = 0;
	}
	t1+=INCREMENT;


	ball1.posX = (Xint32)(BALL_SPEED*t1*cos(ball1.angle_pre_throw*M_PI/180))+ player1.posX_pre_throw + PLAYER_WIDTH;
	ball1.posY = (Xint32)(BALL_ACCELERATION * t1*t1/2 -BALL_SPEED*t1*sin(ball1.angle_pre_throw*M_PI/180))+SCREEN_HEIGHT - 160 -PLAYER_HEIGHT;

}

void ballistic_calculation2()
{

	static float t2=0;

	if(ball2.init_t)
	{
		t2 = 0;
		ball2.init_t = 0;
	}

	t2+=INCREMENT;


	ball2.posX = (Xint32)(-1)*(BALL_SPEED*t2*cos(ball2.angle_pre_throw*M_PI/180))+ player2.posX_pre_throw;
	ball2.posY = (Xint32)(BALL_ACCELERATION * t2*t2/2 - BALL_SPEED*t2*sin(ball2.angle_pre_throw*M_PI/180))+SCREEN_HEIGHT - 160 -PLAYER_HEIGHT;

}

XStatus setupGPIO()
{
	XStatus status;

	status = XGpio_Initialize(&PushButtons, XPAR_PUSH_BUTTONS_5BIT_DEVICE_ID);
	if(status != XST_SUCCESS)
		return XST_FAILURE;
	// We don't need to set Data Direction. GPIO is by default Input

	return XST_SUCCESS;
}

void drawGame()
{
	setPlayer1X(player1.posX);
	setPlayer2X(player2.posX);
	setHealthBar1(player1.health);
	setHealthBar2(player2.health);
	setArrowAngle1(ball1.pente);
	setArrowAngle2(ball2.pente);

}

void hit_player1()
{
	player1.health--;

	setHealthBar2(player2.health);
}

void hit_player2()
{
	player2.health--;

	setHealthBar2(player2.health);

}

void boundaries_ball1()
{
	//right hole
	if((ball1.posX + RADIUS > BASE_RIGHT && ball1.posY + RADIUS> WALL_UP && ball1.posX+RADIUS<WALL_RIGHT))
		ball1.posX=BASE_RIGHT-RADIUS;

	//Top Wall right
	else if(ball1.posX + RADIUS > BASE_RIGHT && ball1.posX - RADIUS < WALL_RIGHT && ball1.posY + RADIUS > WALL_UP)
		ball1.posY = WALL_UP -RADIUS;

	//player2 side
	else if(ball1.posX + RADIUS > player2.posX && ball1.posX-RADIUS <player2.posX+PLAYER_WIDTH && ball1.posY + RADIUS > WALL_DOWN - PLAYER_HEIGHT)
		ball1.posX = player2.posX - RADIUS;

	//player2 top
	else if(ball1.posX + RADIUS > player2.posX && ball1.posX-RADIUS <player2.posX + PLAYER_WIDTH && ball1.posY + RADIUS > WALL_DOWN - PLAYER_HEIGHT)
		ball1.posY = WALL_DOWN-PLAYER_HEIGHT - RADIUS;

	//base player1
	else if(ball1.posX +RADIUS < WALL_LEFT && ball1.posY + RADIUS > WALL_DOWN)
		ball1.posY = WALL_DOWN - RADIUS;

	//base player2
	else if(ball1.posX +RADIUS > WALL_RIGHT && ball1.posY + RADIUS > WALL_DOWN)
		ball1.posY = WALL_DOWN - RADIUS;

	//wall left side
	else if(ball1.posX + RADIUS > WALL_LEFT && ball1.posX-RADIUS <BASE_LEFT && ball1.posY + RADIUS > WALL_UP)
		ball1.posX = WALL_LEFT - RADIUS;

	//wall left top
	else if(ball1.posX +RADIUS > WALL_LEFT && ball1.posX - RADIUS < BASE_LEFT && ball1.posY + RADIUS > WALL_UP)
		ball1.posY = WALL_UP - RADIUS;

	//base

	if(((ball1.posX + RADIUS) > player2.posX && (ball1.posX - RADIUS) < (player2.posX + PLAYER_WIDTH) && (ball1.posY + RADIUS) == (WALL_DOWN-PLAYER_HEIGHT))||
		(ball1.posX + RADIUS == player2.posX  && ball1.posY + RADIUS > WALL_DOWN - PLAYER_HEIGHT))
	{

		buzz_en = 1;
		setCounter(DO1);
		setEnable(buzz_en);
		restart_ball1();
		hit_player2();

		if(!player2.health)
		{
			int counter3 = 0;
			int verbose = 0;

			while(counter3++ < 600000)
			{

				if(!(counter3%100000))
				{
					verbose++;
					if(verbose%2)
					{
						setCounter(FA1);
						XGpio_DiscreteWrite(&GpioLeds, 1, 0xFF);
					}
					else
					{
						setCounter(LA1);
						XGpio_DiscreteWrite(&GpioLeds, 1, 0x00);
					}
				}
			}

			restart_game();
			XGpio_DiscreteWrite(&GpioLeds, 1, 0x00);
		}

	}

	else if((ball1.posX + RADIUS == BASE_RIGHT && ball1.posY > WALL_UP)||(ball1.posX+RADIUS>BASE_RIGHT && ball1.posX -RADIUS < WALL_RIGHT && (ball1.posY+RADIUS)==WALL_UP)
			|| (ball1.posY+RADIUS == WALL_DOWN && ball1.posX+RADIUS > WALL_RIGHT) ||
			(ball1.posX+RADIUS==WALL_LEFT  && ball1.posY+RADIUS > WALL_UP) || (ball1.posX>WALL_LEFT && ball1.posX < BASE_LEFT && ball1.posY+RADIUS == WALL_UP)
			|| ball1.posX + RADIUS < 0 || ball1.posX-RADIUS > SCREEN_WIDTH ||ball1.posY-RADIUS > SCREEN_HEIGHT || (ball1.posY+RADIUS == WALL_DOWN && ball1.posX+RADIUS < WALL_LEFT ) )
	{

		restart_ball1();
	}
}



void boundaries_ball2()
{
	//left hole
	if((ball2.posX - RADIUS < BASE_LEFT && ball2.posY - RADIUS> WALL_UP && ball2.posX+RADIUS>WALL_LEFT))
		ball2.posX=BASE_LEFT+RADIUS;

	//Top Wall left
	else if(ball2.posX - RADIUS < BASE_LEFT && ball2.posX + RADIUS > WALL_LEFT && ball2.posY + RADIUS > WALL_UP)
		ball2.posY = WALL_UP -RADIUS;

	//player1 side
	else if(ball2.posX - RADIUS < player1.posX+PLAYER_WIDTH && ball2.posX+RADIUS >player1.posX && ball2.posY + RADIUS > WALL_DOWN - PLAYER_HEIGHT)
		ball2.posX = player1.posX + RADIUS+PLAYER_WIDTH;

	//player1 top
	else if(ball2.posX - RADIUS > player1.posX+PLAYER_WIDTH && ball2.posX+RADIUS <player1.posX && ball2.posY + RADIUS > WALL_DOWN - PLAYER_HEIGHT)
		ball2.posY = WALL_DOWN-PLAYER_HEIGHT - RADIUS;

	//base player2
	else if(ball2.posX -RADIUS > WALL_RIGHT && ball2.posY + RADIUS > WALL_DOWN)
		ball2.posY = WALL_DOWN - RADIUS;

	//base player1
	else if(ball2.posX -RADIUS < WALL_LEFT && ball2.posY + RADIUS > WALL_DOWN)
		ball2.posY = WALL_DOWN - RADIUS;

	//wall right side
	else if(ball2.posX - RADIUS < WALL_RIGHT && ball2.posX+RADIUS >BASE_RIGHT && ball2.posY + RADIUS > WALL_UP)
		ball2.posX = WALL_RIGHT + RADIUS;

	//wall right top
	else if(ball2.posX -RADIUS < WALL_RIGHT && ball2.posX +RADIUS > BASE_RIGHT && ball2.posY + RADIUS > WALL_UP)
		ball2.posY = WALL_UP - RADIUS;


	if(((ball2.posX - RADIUS) > player1.posX && (ball2.posX + RADIUS) < (player1.posX +PLAYER_WIDTH) && (ball2.posY + RADIUS) == (WALL_DOWN-PLAYER_HEIGHT))||
		(ball2.posX - RADIUS == player1.posX+PLAYER_WIDTH  && ball2.posY + RADIUS > WALL_DOWN - PLAYER_HEIGHT))
	{
		setCounter(RE1);
		buzz_en = 1;
		setEnable(buzz_en);

		restart_ball2();
		hit_player1();

		if(!player1.health)
		{
			int counter3 = 0;
			int verbose = 0;

			while(counter3++ < 600000)
			{

				if(!(counter3%100000))
				{
					verbose++;
					if(verbose%2)
					{
						setCounter(MI1);
						XGpio_DiscreteWrite(&GpioLeds, 1, 0xFF);
					}
					else
					{
						setCounter(SOL1);
						XGpio_DiscreteWrite(&GpioLeds, 1, 0x00);
					}
				}
			}

			restart_game();
			XGpio_DiscreteWrite(&GpioLeds, 1, 0x00);
		}
	}

	else if((ball2.posX - RADIUS == BASE_LEFT && ball2.posY > WALL_UP)||(ball2.posX-RADIUS<BASE_LEFT && ball2.posX +RADIUS > WALL_LEFT && (ball2.posY+RADIUS)==WALL_UP)
			||  (ball2.posY + RADIUS == WALL_DOWN && ball2.posX-RADIUS > WALL_RIGHT)||(ball2.posY+RADIUS == WALL_DOWN && ball2.posX-RADIUS < WALL_LEFT) ||
			(ball2.posX-RADIUS==WALL_RIGHT  && ball2.posY+RADIUS > WALL_UP) || (ball2.posX<WALL_RIGHT && ball2.posX > BASE_RIGHT && ball2.posY+RADIUS == WALL_UP)
			|| ball2.posX + RADIUS < 0 || ball2.posX-RADIUS > SCREEN_WIDTH ||ball2.posY-RADIUS > SCREEN_HEIGHT )


	{

		restart_ball2();
	}
}

void rotate_angle1()
{

	static int up=1;

	if(ball1.pente +1 >= 8)
		up=0;
	if(ball1.pente -1 < 0)
		up = 1;

	if(up)
		ball1.pente = ball1.pente + 1;
	else
		ball1.pente = ball1.pente - 1;




}

void rotate_angle2()
{

	static int up=0;

	if(ball2.pente +1 >= 8)
		up=0;
	if(ball2.pente -1 < 0)
		up = 1;

	if(up)
		ball2.pente = ball2.pente + 1;
	else
		ball2.pente = ball2.pente - 1;




}

void snowballUpdateHandler(void)
{
	static int angle_counter = 0;
	// Read the state of the buttons

	static int check = 0;
	Xuint32 buttons = XGpio_DiscreteRead(&PushButtons, 1);

	keyb_code=(Xint32)(getAsciiCode(4));
	code_new = (Xint32)getAsciiNew(0);

	xil_printf("code : %d\r\n", keyb_code);
	xil_printf("new : %d\r\n", code_new);

	if(!code_new && keyb_code!=0)
	{

			while(!code_new)
				code_new = (Xint32)getAsciiNew(0);
			keyb_code=(Xint32)getAsciiCode(4);
			check = 1;
	}


	if(buttons == RIGHT_BUTTON_MASK || ((keyb_code == RIGHT_P1_1 || keyb_code == RIGHT_P1_2) && check))//code_new==0))
	{
		if(player1.posX + player1.speedX<=WALL_LEFT-PLAYER_WIDTH)
			player1.posX = player1.posX + player1.speedX;
		else
			player1.posX = WALL_LEFT-PLAYER_WIDTH;
	}
	if(buttons == LEFT_BUTTON_MASK|| ((keyb_code == LEFT_P1_1 || keyb_code == LEFT_P1_2) && check))//code_new==0))
	{
		if(player1.posX-player1.speedX >= player1.speedX)
			player1.posX = player1.posX - player1.speedX;
		else
			player1.posX = 0;
	}
	if(buttons == UP_BUTTON_MASK || ((keyb_code == RIGHT_P2_1 || keyb_code == RIGHT_P2_2) && check))//code_new==0))
	{
		if(player2.posX + player2.speedX <= SCREEN_WIDTH-PLAYER_WIDTH)
			player2.posX = player2.posX + player2.speedX;
		else
			player2.posX = SCREEN_WIDTH-PLAYER_WIDTH;
	}
	if(buttons == DOWN_BUTTON_MASK || ((keyb_code == LEFT_P2_1 || keyb_code == LEFT_P2_2) && check))//code_new==0))
	{
		if(player2.posX - player2.speedX >= WALL_RIGHT+player1.speedX)
			player2.posX = player2.posX - player2.speedX;
		else
			player2.posX = WALL_RIGHT;
	}

	if(buttons == RESTART_BUTTON_MASK || ((keyb_code == HIT_P1_1 || keyb_code == HIT_P1_2)  && check))//code_new==0))
	{

		if(ball1.visible==0)
		{
			player1.posX_pre_throw=player1.posX;
			ball1.angle_pre_throw = atan(ball1.pente)*180/M_PI;
			ball1.visible=1;
		}
	}
	if(((keyb_code == HIT_P2_1 || keyb_code == HIT_P2_2) && check))//code_new==0))
	{
		if(ball2.visible==0)
		{
			player2.posX_pre_throw=player2.posX;
			ball2.angle_pre_throw = atan(ball2.pente)*180/M_PI;
			ball2.visible=1;

		}

	}

	 check = 0;
	boundaries_ball1();
	boundaries_ball2();

	if(++angle_counter>=3)
	{
		rotate_angle1();
		angle_counter = 0;
		rotate_angle2();
	}

	setBall1(ball1.visible);
	setBall2(ball2.visible);

	if(ball1.visible == 0)
		update_ball1();
	if(ball2.visible == 0)
		update_ball2();


	drawGame();
}

void ballUpdateHandler(void)
{
	if(ball1.visible==1)
		ballistic_calculation1();

	if(ball2.visible==1)
		ballistic_calculation2();


	setBall1X(ball1.posX);
	setBall1Y(ball1.posY);
	setBall2X(ball2.posX);
	setBall2Y(ball2.posY);
}

void interruptHandler(void *data)
{
	static Xuint32 count1 = 0;
	static Xuint32 count2 = 0;



	if(buzz_en)
	{
		count2++;
		if(count2==250)
			setCounter(LA1);
		if(count2 == 500)
		{
			buzz_en = 0;
			setEnable(buzz_en);
			count2 = 0;
		}
	}

	if(count1==17)
	{
		snowballUpdateHandler();
		ballUpdateHandler();
		count1 = 0;
	}

	count1++;
}

XStatus setupTimer()
{
	Xil_ExceptionInit();

	Xil_ExceptionRegisterHandler(XIL_EXCEPTION_ID_INT, &interruptHandler, NULL);

	Xil_ExceptionEnable();

	return XST_SUCCESS;
}

int main()
{
   print("--------------------------\n\r");
   print("--- Welcome to Snowball---\n\r");
   print("--------------------------\n\r");

   XStatus status;

   status = setupTimer();
   if(status != XST_SUCCESS)
	   return XST_FAILURE;
   status = setupGPIO();
   if(status != XST_SUCCESS)
   	   return XST_FAILURE;

	XStatus status_led;

	status_led =  XGpio_Initialize(&GpioLeds, XPAR_LEDS_8BIT_DEVICE_ID);
	if (status_led != XST_SUCCESS)
	{
		xil_printf("ERROR initializing GPIO\r\n");
		return XST_FAILURE;
	}

	XGpio_SetDataDirection (&GpioLeds, 1, 0x00);
	XGpio_DiscreteWrite(&GpioLeds, 1, 0x00);


   initGame();
   drawGame();

   //Endlessly loop here. All the actions happens in the interrupt controller.
   while(1)
   {

	}

   print("-------------------\n\r");
   print("--- Snow never ends\n\r");
   print("-------------------\n\r");

   // We should never arrive here!!!
   return 0;
}
