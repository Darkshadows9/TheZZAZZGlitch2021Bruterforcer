#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <stdbool.h>

//gcc -Wall -pedantic -O3 "Bruteforce.c" -o "Bruteforce.exe"

//These are the original map starting positions, but I'm subtracting one from the definition to make code later simpler.
//#define MAP_X 0x0001
//#define MAP_Y 0x0002
#define MAP_X 0x0000
#define MAP_Y 0x0001

//Screen size shows 5*5 blocks of the map
#define SCREEN_SIZE 5 * 5

uint8_t test_screen[SCREEN_SIZE] = 		{0x00, 0x00, 0x00, 0x00, 0x00,
										0x00, 0x00, 0x00, 0x00, 0x00,
										0x00, 0x00, 0x00, 0x00, 0x00,
										0x00, 0x00, 0x00, 0x00, 0x00,
										0x00, 0x00, 0x00, 0x00, 0x00};

uint8_t success_screen[SCREEN_SIZE] =	{0x0B, 0x0B, 0x0B, 0x74, 0x0A,
										0x0F, 0x0B, 0x0F, 0x0A, 0x0A,
										0x0F, 0x0F, 0x0A, 0x0A, 0x0B,
										0x0F, 0x0B, 0x0A, 0x0A, 0x0A,
										0x0B, 0x0B, 0x0A, 0x0A, 0x74};

//Variables used at various points throughout execution
uint8_t hNPCSpriteOffset = 0x00;
uint8_t hMultiplicand = 0x00;
uint8_t hFindPathNumSteps = 0x00;
uint8_t hFindPathFlags = 0x54;
uint8_t hDivideBuffer = 0x00;
uint8_t hPowerOf10 = 0x00;
uint8_t hNPCPlayerRelativePosPerspective = 0x00;

//D170
uint8_t chunk_buffer[0x80] = {0x0F, 0x0F, 0x0F, 0x0F, 0x0F, 0x0F, 0x0F, 0x0F, 0x0F, 0x0F, 0x0F, 0x0F, 0x0F, 0x0F, 0x0F, 0x0F, 0x0F, 0x0F, 0x0F, 0x0F, 0x0F, 0x0F, 0x0F, 0x0F, 0x0F, 0x0F, 0x0F, 0x0F, 0x0F, 0x0F, 0x0F, 0x0F, 0x0F, 0x0F, 0x0F, 0x0F, 0x0F, 0x0F, 0x0F, 0x0F, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00};

//DD0C
uint8_t secret_salt[0x80] = {0x05, 0x0B, 0x06, 0x00, 0x0E, 0x05, 0x0B, 0x03, 0x09, 0x0E, 0x00, 0x00, 0x00, 0x0C, 0x00, 0x00, 0x00, 0x0C, 0x05, 0x06, 0x06, 0x0D, 0x0A, 0x09, 0x09, 0x0B, 0x06, 0x00, 0x00, 0x05, 0x0A, 0x00, 0x05, 0x0B, 0x06, 0x00, 0x0B, 0x06, 0x09, 0x07, 0x00, 0x09, 0x07, 0x0A, 0x00, 0x05, 0x0A, 0x00, 0x00, 0x09, 0x06, 0x00, 0x03, 0x06, 0x0C, 0x05, 0x00, 0x09, 0x0F, 0x0A, 0x00, 0x05, 0x0A, 0x00, 0x05, 0x0A, 0x00, 0x00, 0x0F, 0x06, 0x05, 0x03, 0x09, 0x0F, 0x0A, 0x00, 0x00, 0x0C, 0x00, 0x00, 0x05, 0x0B, 0x03, 0x06, 0x0E, 0x00, 0x00, 0x0D, 0x09, 0x06, 0x00, 0x0C, 0x00, 0x0D, 0x03, 0x0A, 0x00, 0x09, 0x06, 0x00, 0x06, 0x05, 0x0A, 0x05, 0x09, 0x0F, 0x06, 0x0C, 0x00, 0x0C, 0x09, 0x0A, 0x00, 0x0C, 0x00, 0x00, 0x03, 0x0F, 0x07, 0x03, 0x00, 0x0D, 0x0A, 0x00, 0x00, 0x0C, 0x00, 0x00};

//D800
uint8_t map_buffer[0x240] = {0};

uint8_t seed[4] = {0x65, 0x21, 0xE0, 0xA1};
uint8_t seed_scramble[4] = {0x00, 0x00, 0x00, 0x01};
uint8_t wXCoord = 0x00;
uint8_t wYCoord = 0x00;

void getInitPlayerPosition()
{
	//Check if any blocks are 0x0A, IE all flatland tiles
	for(wYCoord = 0; wYCoord < 0x08; wYCoord++)
	{
		for(wXCoord = 0; wXCoord < 0x08; wXCoord++)
		{
			if(chunk_buffer[(wYCoord * 0x08) + wXCoord] == 0x0A)
			{
				return;
			}
		}
	}
	//If we didn't find a starting position before, these will be set as a default
	wXCoord = 0x04;
	wYCoord = 0x04;
	/*
	printf("No valid starting tile: 0x");
	for(int i = 0; i < 4; i++)
	{
		printf("%02X", seed[i]);
	}
	printf("\n");
	*/
	return;
}

void writeOffsetChunkBuffer(uint8_t b)
{
	uint16_t hl = ((b & 0x0F) * 8) + (b >> 4);
	chunk_buffer[hl] = hFindPathNumSteps;
	return;
}

void fillChunkBuffer()
{
	for(int i = 0; i < 0x40; i++)
	{
		chunk_buffer[i] = 0x0F;
	}
	return;
}

void fillMapBuffer()
{
	for(int i = 0; i < 0x240; i++)
	{
		map_buffer[i] = 0x54;
	}
	return;
}

uint8_t scrambleDAB()
{
	seed_scramble[0]++;
	seed_scramble[1] = (seed_scramble[0] ^ seed_scramble[3]) ^ seed_scramble[1];
	seed_scramble[2] += seed_scramble[1];
	seed_scramble[3] = ((seed_scramble[2] >> 1) ^ seed_scramble[1]) + seed_scramble[3];
	return seed_scramble[3];
}

//Load original seed and scramble it
uint8_t loadAndScrambleDAB(uint8_t de, uint16_t bc)
{
	seed_scramble[0] = (de >> 8) ^ seed[0];
	seed_scramble[1] = (de & 0xFF) ^ seed[1];
	seed_scramble[2] = (bc >> 8) ^ seed[2];
	seed_scramble[3] = (bc & 0xFF) ^ seed[3];
	uint8_t return_value = 0;
	for(int i = 0; i < 0x10; i++)
	{
		return_value = scrambleDAB();
	}
	return return_value;
}

void initGenerator(uint16_t map_gen_x, uint16_t map_gen_y)
{
	uint16_t bc = ((map_gen_x & 0x03) << 8) + (map_gen_y & 0x03);
	uint16_t hl = map_gen_y & 0xFFFC;
	uint16_t de = map_gen_x & 0xFFFC;
	loadAndScrambleDAB(de, hl);
	de = (scrambleDAB() & 0x07) << 4;
	bc = (((bc & 0xFF) * 4) + (bc >> 8)) & 0xFF;
	bc = secret_salt[bc + de] | (scrambleDAB() & 0x30);
	hNPCSpriteOffset = (bc & 0xFF);
	uint8_t h = map_gen_y >> 8;
	uint8_t l = map_gen_y & 0xFF;
	uint8_t d = map_gen_x >> 8;
	uint8_t e = map_gen_x & 0xFF;
	uint8_t result = e | l;
	result &= 0xFC;
	result |= d;
	result |= h;
	if(result == 0x00)
	{
		hNPCSpriteOffset = bc & 0x000F;
	}
	return;
}

void funA98F()
{
	for(uint16_t hl = 0x08, de = 0x48, c = 0x30; c > 0; hl++, de++, c--)
	{
		chunk_buffer[de] = chunk_buffer[hl];
	}
	for(uint16_t hl = 0x08, de = 0x48, c = 0x30; c > 0; hl++, de++, c--)
	{
		if(chunk_buffer[de] == hFindPathNumSteps)
		{
			uint8_t a = hl & 0x07;
			if((a != 0x00) && (a != 0x07))
			{
				uint8_t b = scrambleDAB();
				if((b & 0x01) == 0x01) //funA983
				{
					chunk_buffer[hl - 1] = hFindPathNumSteps;
				}
				if((b & 0x02) == 0x02) //funA989
				{
					chunk_buffer[hl + 1] = hFindPathNumSteps;
				}
				if((b & 0x04) == 0x04) //funA96B
				{
					chunk_buffer[hl - 8] = hFindPathNumSteps;
				}
				if((b & 0x08) == 0x08) //funA977
				{
					chunk_buffer[hl + 8] = hFindPathNumSteps;
				}
			}
		}
	}
	return;
}

void funA8D6(uint8_t b, uint8_t c, uint8_t d, uint8_t e, uint8_t a)
{
	do
	{
		a = scrambleDAB();
		a &= 0x07;
	} while((a == 0x00) || (a == 0x07));
	a = (a << 4) + (a >> 4);
	d = a;
	do
	{
		a = scrambleDAB();
		a &= 0x07;
	} while((a == 0x00) || (a == 0x07));
	d |= a;
	uint8_t pushed_b = d;
	uint8_t pushed_c = c;
	uint8_t pushed_d = d;
	uint8_t pushed_e = e;
	c = d;
	for(int i = 0; i < 2; i++)
	{
		if(i == 1)
		{
			b = pushed_b;
			c = pushed_c;
			d = pushed_d;
			e = pushed_e;
		}
		hFindPathNumSteps = e;
		a = b >> 4;
		d = a;
		a = c;
		a >>= 4;
		if(a <= d)
		{
			d = 0xF0;
		}
		else
		{
			d = 0x10;
		}
		e = b & 0x0F;
		if((c & 0x0F) < (e & 0x0F))
		{
			e = 0xFF;
		}
		else
		{
			e = 0x01;
		}
		do
		{
			writeOffsetChunkBuffer(b);
			uint8_t h = (b >> 4);
			a = c >> 4;
			if(a != h)
			{
				b += d;
			}
			writeOffsetChunkBuffer(b);
			h = b & 0x0F;
			a = c & 0x0F;
			if(a != h)
			{
				b += e;
			}
			writeOffsetChunkBuffer(b);
		} while(b != c);
	}
	return;
}

void funA9D3(uint8_t b, uint8_t c)
{
	hFindPathNumSteps = b;
	uint8_t d = 0x30;
	uint8_t e = 0x40;
	for(uint16_t hl = 0x0; e > 0; hl++, e--)
	{
		if(chunk_buffer[hl] != b)
		{
			continue;
		}
		b = hFindPathNumSteps;
		if(scrambleDAB() >= d)
		{
			continue;
		}
		chunk_buffer[hl] = c;
	}
	return;
}

void funAA14(uint8_t b, uint8_t c)
{
	hFindPathNumSteps = b;
	uint16_t hl = 0x08;
	for(uint8_t d = 0x20, e = 0x30; e > 0; hl++, e--)
	{
		if(chunk_buffer[hl] != b)
		{
			continue;
		}
		uint8_t a = hl & 0x07;
		if((a == 0) || (a == 7))
		{
			continue;
		}
		b = hFindPathNumSteps;
		if(scrambleDAB() < d)
		{
			continue;
		}
		if((hFindPathFlags != 0) && (hFindPathFlags != chunk_buffer[hl - 0x08]))
		{
			continue;
		}
		if((hPowerOf10 != 0) && (hPowerOf10 != chunk_buffer[hl + 0x08]))
		{
			continue;
		}
		if((hDivideBuffer != 0) && (hDivideBuffer != chunk_buffer[hl - 0x01]))
		{
			continue;
		}
		if((hNPCPlayerRelativePosPerspective != 0) && (hNPCPlayerRelativePosPerspective != chunk_buffer[hl + 0x01]))
		{
			continue;
		}
		chunk_buffer[hl] = c;
	}
	return;
}

void funA9EF(uint8_t b, uint8_t c)
{
	uint8_t d = 0x40;
	uint8_t e = 0x30;
	hFindPathNumSteps = b;
	for(uint16_t hl = 0x8; e > 0; hl++, e--)
	{
		uint8_t a = hl & 0x07;
		if((a ==  0x0) || (a ==  0x07) || (chunk_buffer[hl] != b))
		{
			continue;
		}
		if(scrambleDAB() < d)
		{
			chunk_buffer[hl] = c;
		}
	}
	return;
}

void finishGenerating()
{
	funA9D3(0x0A, 0x0B);
	hFindPathNumSteps = 0x0B;
	funA98F();
	hFindPathFlags = 0x0F;
	hPowerOf10 = 0x0A;
	hDivideBuffer = 0x00;
	hNPCPlayerRelativePosPerspective = 0x00;
	funAA14(0x0F, 0x6C);
	hFindPathFlags = 0x0A;
	hPowerOf10 = 0x0F;
	funAA14(0x0F, 0x6F);
	hFindPathFlags = 0x00;
	hPowerOf10 = 0x00;
	hDivideBuffer = 0x0A;
	hNPCPlayerRelativePosPerspective = 0x0F;
	funAA14(0x0F, 0x6E);
	hDivideBuffer = 0x0F;
	hNPCPlayerRelativePosPerspective = 0x0A;
	funAA14(0x0F, 0x6D);
	funA9D3(0x0A, 0x74);
	funA9D3(0x0A, 0x7A);
	funA9EF(0x6C, 0x33);
	funA9EF(0x6D, 0x32);
	funA9EF(0x6E, 0x60);
	funA9EF(0x6F, 0x34);
	return;
}

//This doesn't write to the main map buffer as far as I know
/*
uint16_t funAB63(uint16_t hl, uint8_t a)
{
	uint16_t bc = hl;
	uint8_t h = hl >> 8;
	uint8_t l = hl & 0xFF;
	l <<= 1;
	h = (h << 1) | (h >> 7);
	l <<= 1;
	h = (h << 1) | (h >> 7);
	l <<= 1;
	h = (h << 1) | (h >> 7);
	l <<= 1;
	h = (h << 1) | (h >> 7);
	l <<= 1;
	h = (h << 1) | (h >> 7);
	hl = (h << 8) + l;
	hl += bc + a;
	return hl;
}

void funABA6(uint16_t hl, uint16_t de)
{
	//AB7F
	hl = 0x1505;
	hl = funAB63(hl, de >> 8);
	hl = funAB63(hl, de & 0xFF);
	hl = funAB63(hl, MAP_X & 0xFF);
	hl = funAB63(hl, MAP_X >> 8);
	hl = funAB63(hl, MAP_Y & 0xFF);
	hl = funAB63(hl, MAP_Y >> 8);
	hl = hl & 0x3FFF;
	de = hl;

	//DC48
	hl = 0xB700;
	uint8_t c = de & 0x07;
	de = (((de >> 1) & 0xFF00) + ((de >> 1) & 0xFF) + ((de << 7) & 0xFF));
	de = (((de >> 1) & 0xFF00) + ((de >> 1) & 0xFF) + ((de << 7) & 0xFF));
	de = (((de >> 1) & 0xFF00) + ((de >> 1) & 0xFF) + ((de << 7) & 0xFF));
	uint8_t b = 0x0;
	c++;
	uint8_t carry = true;
	do
	{
		uint8_t next_carry = b >> 7;
		b = (b << 1);
		if(carry)
		{
			b = (b << 1) + 0x01;
		}
		carry = next_carry;
		c--;
	} while(c > 0);
	hl += de;
	b = 0x10;
	c = 0x00;
	if((de >> 8) != 0x00)
	{
		b = 0x00;
	}
	return;
}
*/

void generateChunk(uint16_t map_gen_x, uint16_t map_gen_y)
{
	initGenerator(map_gen_x, map_gen_y);
	fillChunkBuffer();
	if((hNPCSpriteOffset & 0x08) ==  0x08)
	{
		hMultiplicand = 0x40;
	}
	else if((hNPCSpriteOffset & 0x04) ==  0x04)
	{
		hMultiplicand = 0x47;
	}
	else if((hNPCSpriteOffset & 0x02) ==  0x02)
	{
		hMultiplicand = 0x04;
	}
	else if((hNPCSpriteOffset & 0x01) ==  0x01)
	{
		hMultiplicand = 0x74;
	}
	loadAndScrambleDAB(map_gen_x, map_gen_y);
	uint8_t b = hMultiplicand;
	uint8_t c = 0x74;
	uint8_t d = hNPCSpriteOffset;
	uint8_t e = 0x0A;
	uint8_t a = hNPCSpriteOffset;
	if((d & 0x1) == 0x1)
	{
		funA8D6(b, c, d, e, a);
	}
	c = 0x04;
	if((d & 0x2) == 0x2)
	{
		funA8D6(b, c, d, e, a);
	}
	c = 0x47;
	if((d & 0x4) == 0x4)
	{
		funA8D6(b, c, d, e, a);
	}
	c = 0x40;
	if((d & 0x8) == 0x8)
	{
		funA8D6(b, c, d, e, a);
	}
	hFindPathNumSteps = 0x0A;
	funA98F();
	if((d & 0x08) == 0x08)
	{
		b = 0x30;
		writeOffsetChunkBuffer(b);
		b = 0x40;
		writeOffsetChunkBuffer(b);
	}
	if((d & 0x04) == 0x04)
	{
		b = 0x37;
		writeOffsetChunkBuffer(b);
		b = 0x47;
		writeOffsetChunkBuffer(b);
	}
	if((d & 0x02) == 0x02)
	{
		b = 0x03;
		writeOffsetChunkBuffer(b);
		b = 0x04;
		writeOffsetChunkBuffer(b);
	}
	if((d & 0x01) == 0x01)
	{
		b = 0x73;
		writeOffsetChunkBuffer(b);
		b = 0x74;
		writeOffsetChunkBuffer(b);
	}
	finishGenerating();
	//Unsure of the purpose of this section, but it's not used by map generation, so I don't really care that much.
	/*
	uint16_t hl = 0;
	de = 0;
	do
	{
		if(chunk_buffer[hl] == 0x33) funABA6(hl, de);
		if(chunk_buffer[hl] == 0x32) funABA6(hl, de);
		if(chunk_buffer[hl] == 0x60) funABA6(hl, de);
		if(chunk_buffer[hl] == 0x34) funABA6(hl, de);
		if(chunk_buffer[hl] == 0x08) funABA6(hl, de);
		de++;

		if((de & 0xFF) != 0x08)
		{
			continue;
		}
		de = (de + 0x0100) & 0xFF00;
		if((de >> 8) == 0x08)
		{
			continue;
		}
		break;
	} while(true);
	*/
	return;
}

void copyMapChunk(uint16_t copy_index)
{
	for(uint8_t y = 0; y < 8; y++)
	{
		for(uint8_t x = 0; x < 8; x++)
		{
			map_buffer[copy_index] = chunk_buffer[(y * 8) + x];
			copy_index++;
		}
		
		copy_index += 0x10; //go past two chunks to get back to the proper column
	}
	return;
}

void generateMap()
{
	//Wipe the buffer from last time
	fillMapBuffer();
	//Generate the map
	for(int y = 0; y < 3; y++)
	{
		for(int x = 0; x < 3; x++)
		{
			generateChunk(MAP_X + x, MAP_Y + y);
			copyMapChunk((y * 0xC0) + (x * 0x08));
			if((x == 1) && (y == 1))
			{
				//The original program did this when the whole map was generated, but it's certainly possible with only the center chunk.
				getInitPlayerPosition();
			}
		}
	}
	//The generator for some reason zeroes out this address so there you go I guess, now it's a perfect match.
	map_buffer[0x87] = 0x00;
	return;
}

void testScreen()
{
	//Copy bytes into the test array
	//0x96 is earliest block screen could possibly see on spawn
	uint16_t copy_index = 0x96 + wXCoord + (wYCoord * 0x18);
	for(uint8_t y = 0; y < 5; y++)
	{
		for(uint8_t x = 0; x < 5; x++)
		{
			test_screen[(y * 5) + x] = map_buffer[copy_index];
			copy_index++;
		}
		copy_index += 0x13; //Shift down a row in the map to get the next part of the screen
	}

	//Check for a match with the pre-defined screenshot
	for(uint8_t i = 0; i < 25; i++)
	{
		if(test_screen[i] != success_screen[i])
		{
			break;
		}
		//Tell the user we found a success and end the search!
		if(i == 24)
		{
			printf("Bingo! 0x");
			for(uint8_t j = 0; j < 4; j++)
			{
				printf("%02X", seed[j]);
			}
			printf("\n");
			exit(EXIT_SUCCESS);
		}
	}
	return;
}

void incrementSeed()
{
	//Increment
	seed[3] += 0x10;
	//Carry check
	if(seed[3] == 0x01)
	{
		for(int i = 2; i > -1; i--)
		{
			seed[i]++;
			//If we carry the highest byte, let the user know the program is still running
			if(i == 0)
			{
				printf("0x");
				for(int i = 0; i < 4; i++)
				{
					printf("%02X", seed[i]);
				}
				printf("\n");
			}
			//Handle carry by checking for overflow
			if(seed[i] != 0x00)
			{
				break;
			}
		}
	}
	return;
}

int main()
{
	//We use this to check at the end if we've searched the entire seed space
	uint8_t starting_seed[4] = {0x65, 0x21, 0xE0, 0xA1};
	printf("Starting from seed: 0x");
	for(uint8_t i = 0; i < 4; i++)
	{
		seed[i] = starting_seed[i];
		printf("%02X", starting_seed[i]);
	}
	printf("\n");

	while(true)
	{
		generateMap();
		testScreen();
		incrementSeed();

		//Check if we've searched the entire address space yet
		for(int i = 0; i < 4; i++)
		{
			if(seed[i] != starting_seed[i])
			{
				break;
			}
			else if(i == 3)
			{
				printf("Finished searching.\n");
				exit(EXIT_SUCCESS);
			}
		}
	}
	return EXIT_FAILURE;
}

/*
uint8_t random(uint8_t *hRandomDiv, uint8_t *hRandomAdd, uint8_t *hRandomSub, bool *c)
{
	uint8_t result = *hRandomAdd + *hDivider;
	if(*c)
	{
		result++;
	}
	*c = (result < *hRandomAdd) ? true : false;
	*hRandomAdd = result;

	result = *hRandomSub - *hDivider;
	if(*c)
	{
		result--;
	}
	*c = (result > *hRandomSub) ? true : false;
	*hRandomSub = result;

	return *hRandomAdd;
}
*/