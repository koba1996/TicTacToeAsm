// nasm -fwin32 tictactoe.asm
// gcc main.c tictactoe.obj -o main
// main

extern void game(void);

int main(int argc, char** argv) {
    game();
    return 0;
}