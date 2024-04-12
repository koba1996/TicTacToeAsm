section .data

    separator_line: db ' _|_____|_____|_____|_', 10, 0
    regular_line: db '  |     |     |     | ', 10, 0
    line_with_value: db ' %c|  %c  |  %c  |  %c  | ', 10, 0
    which_player: db ' Next move is Player %c', 10, 0
    player_won: db ' Player %c won the game!', 0
    draw_msg: db ' It is a draw!', 0
    string_sign: db '%s', 0
    invalid_input_msg: db ' Invalid input, try again! (valid is "a1", "b2", etc.)', 10, 0
    occupied_square_msg: db ' That square is already occupied, try again!', 10, 0
    next_coordinate: db ' Please provide the coordinates of your next move!', 10, ' ', 0
    ping: db 'ping', 10, 0

section .text
    global _game

    extern _printf
    extern _scanf
    extern _malloc
    extern _free

_game:
    push ebp
    mov ebp, esp
    push 12
    call _malloc
    add esp, 4
    push eax
    call initialize_board
    call start_game
    push eax
    push dword [esp + 4]
    call print_board
    add esp, 4
    cmp dword [esp], ' '
    je end_draw
    push player_won
end:
    call _printf
    add esp, 8
    call _free
    add esp, 4
    pop ebp
    ret

end_draw:
    push draw_msg
    jmp end

start_game:
    push ebp                    ; start_game(char* board)
    mov ebp, esp
    push dword [ebp + 8]
one_turn:
    push dword 'o'
    call one_turn_for_player
    cmp eax, 1
    je game_over
    cmp eax, 2
    je game_over_draw
    add esp, 4
    push dword 'x'
    call one_turn_for_player
    cmp eax, 1
    je game_over
    add esp, 4
    jmp one_turn
game_over:
    pop eax
    add esp, 4
    pop ebp
    ret

game_over_draw:
    mov dword [esp], ' '
    jmp game_over

one_turn_for_player:
    push ebp                    ; one_turn_for_player(char player, char* board)
    mov ebp, esp

    push dword [ebp + 12]
    call print_board
    push dword [ebp + 8]
    call print_which_player
    call get_user_input
    push eax
    call update_board
    add esp, 4
    call check_win
    cmp eax, 1
    je game_won
    add esp, 4
    call check_draw
    cmp eax, 1
    je game_draw
    add esp, 4
    mov eax, 0
end_turn:
    pop ebp
    ret

game_won:
    add esp, 8
    mov eax, 1
    jmp end_turn

game_draw:
    add esp, 4
    mov eax, 2
    jmp end_turn

check_draw:
    push ebp
    mov ebp, esp

    push dword [ebp + 8]
    push dword ' '
    mov ecx, 8
is_square_empty:
    push ecx
    call check_one_square
    cmp eax, 1
    je _not_draw
    pop ecx
    loop is_square_empty
    mov eax, 1
draw:
    add esp, 8

    pop ebp
    ret

_not_draw:
    add esp, 4
    mov eax, 0
    jmp draw

check_win:
    push ebp                    ; check_win (char player, char* board)
    mov ebp, esp

    push dword [ebp + 12]
    push dword [ebp + 8]
    push dword 4
    call check_one_square
    cmp eax, 1
    je check_middles
check_a1:
    mov dword [esp], 0
    call check_one_square
    cmp eax, 1
    je check_bottom_lefts
check_c3:
    mov dword [esp], 8
    call check_one_square
    cmp eax, 1
    je check_top_rights
won:
    mov esp, ebp
    pop ebp
    ret

check_middles:
    push dword 0
    push dword 8
    call check_one_combination  ; a1-c3
    cmp eax, 1
    je won
    mov dword [esp], 7
    mov dword [esp + 4], 1
    call check_one_combination  ; a2-c2
    cmp eax, 1
    je won
    mov dword [esp], 6
    mov dword [esp + 4], 2
    call check_one_combination  ; a3-c1
    cmp eax, 1
    je won
    mov dword [esp], 5
    mov dword [esp + 4], 3
    call check_one_combination  ; b1-b3
    cmp eax, 1
    je won
    add esp, 8
    jmp check_a1

check_bottom_lefts:
    push dword 1
    push dword 2
    call check_one_combination  ; a1-a3
    cmp eax, 1
    je won
    mov dword [esp], 3
    mov dword [esp + 4], 6
    call check_one_combination  ; a1-c1
    cmp eax, 1
    je won
    add esp, 8
    jmp check_c3

check_top_rights:
    push dword 7
    push dword 6
    call check_one_combination  ; c1-c3
    cmp eax, 1
    je won
    mov dword [esp], 5
    mov dword [esp + 4], 2
    call check_one_combination  ; a3-c3
    jmp won

check_one_combination:
    push ebp                    ; check_one_combination(int first, int second, int third, char player, char* board)
    mov ebp, esp

    push dword [ebp + 24]
    push dword [ebp + 20]
    push dword [ebp + 16]
    call check_one_square
    cmp eax, 1
    jne no_combination
    pop eax
    push dword [ebp + 12]
    call check_one_square
    cmp eax, 1
    jne no_combination
    pop eax
    push dword [ebp + 8]
    call check_one_square

no_combination:
    add esp, 12
    pop ebp
    ret

check_one_square:
    push ebp                    ; check_one_square(int offset, char player, char* board)
    mov ebp, esp

    mov eax, 0
    mov ebx, [ebp + 16]
    mov edx, [ebp + 12]
    mov ecx, [ebp + 8]
    add ebx, ecx
    cmp byte [ebx], dl
    jne no_match
    mov eax, 1
no_match:
    pop ebp
    ret

update_board:
    push ebp                ; update_board(int number_of_square, char player, char* squares)
    mov ebp, esp

    mov ebx, [ebp + 16]
    add dword ebx, [ebp + 8]
    mov eax, [ebp + 12]
    mov byte [ebx], al

    pop ebp
    ret

get_user_input:
    push ebp                    ; here we have a funny situation
    mov ebp, esp                ; this subroutine is called with player sign sitting on ebp + 8
    
    push dword [ebp + 12]       ; because the subroutine before it and after it needs that argument
    push dword 0                ; so instead of popping and pushing player sign again
    push next_coordinate        ; we will just ignore it here
    call _printf                ; so the signiture is get_user_input(char player, char* board)
    mov dword [esp], 4          ; makes you think... your code is more efficient because you pass an unused argument
    call _malloc
    mov [esp], eax
    push string_sign
get_valid_input:
    call _scanf
    mov ebx, [esp + 4]
    mov eax, 0
    mov byte al, [ebx]
    cmp eax, 97                 ; check if row is between a-c
    jb invalid_input
    cmp eax, 99
    ja invalid_input
    sub eax, 97
    mov dl, 3
    mul dl
    mov [esp + 8], eax
    mov edx, 0
    mov dl, [ebx + 1]
    cmp edx, 49                 ; check if col is between 1-3
    jb invalid_input
    cmp edx, 51
    ja invalid_input
    sub edx, 49
    add [esp + 8], edx
    mov eax, [esp + 12]
    add eax, [esp + 8]
    mov eax, [eax]
    cmp al, ' '                 ; check if the square is empty
    jne occupied_square
    add esp, 4
    call _free
    mov eax, [esp + 4]
    add esp, 12

    pop ebp
    ret

occupied_square:
    push occupied_square_msg
    call _printf
    add esp, 4
    jmp get_valid_input

invalid_input:
    push invalid_input_msg
    call _printf
    add esp, 4
    jmp get_valid_input

print_which_player:
    push ebp
    mov ebp, esp

    push dword [ebp + 8]
    push which_player
    call _printf
    add esp, 8

    pop ebp
    ret

print_board:
    push ebp                ; print_board(char* values)
    mov ebp, esp

    push dword [ebp + 8]
    mov ecx, 3
print_one_line:
    push ecx
    push separator_line
    call _printf
    mov dword [esp], regular_line
    call _printf
    add esp, 4
    call print_line_with_value
    pop ecx
    loop print_one_line
    push separator_line
    call _printf
    add esp, 4
    push dword 0
    call print_line_with_value
    add esp, 8

    pop ebp
    ret

print_line_with_value:
    push ebp
    mov ebp, esp

    mov ebx, [ebp + 12]             ; print_line_with_value(int num_of_line, char* values)
    push dword [ebp + 8]
    cmp byte [esp], 3
    je print_first_line
    cmp byte [esp], 2
    je print_second_line
    cmp byte [esp], 1
    je print_third_line
    cmp byte [esp], 0
    je print_last_line
finish_print_line_with_value:
    add esp, 4

    pop ebp
    ret

print_first_line:
    mov al, [ebx + 8]
    push eax
    mov al, [ebx + 7]
    push eax
    mov al, [ebx + 6]
    push eax
    push dword 'c'
    push dword line_with_value
    call _printf
    add esp, 20
    jmp finish_print_line_with_value

print_second_line:
    mov al, [ebx + 5]
    push eax
    mov al, [ebx + 4]
    push eax
    mov al, [ebx + 3]
    push eax
    push dword 'b'
    push dword line_with_value
    call _printf
    add esp, 20
    jmp finish_print_line_with_value

print_third_line:
    mov al, [ebx + 2]
    push eax
    mov al, [ebx + 1]
    push eax
    mov al, [ebx]
    push eax
    push dword 'a'
    push dword line_with_value
    call _printf
    add esp, 20
    jmp finish_print_line_with_value

print_last_line:
    mov al, '3'
    push eax
    mov al, '2'
    push eax
    mov al, '1'
    push eax
    push dword ' '
    push dword line_with_value
    call _printf
    add esp, 20
    jmp finish_print_line_with_value

initialize_board:
    push ebp
    mov ebp, esp

    mov ebx, [ebp + 8]
    mov byte [ebx + 9], 0
    mov ecx, 8
assign_value:
    push ecx
    mov eax, [esp]
    mov byte [ebx + eax], ' '
    pop ecx
    loop assign_value
    mov byte [ebx], ' '

    pop ebp
    ret

print_ping:
    push ebp
    mov ebp, esp

    push ping
    call _printf
    add esp, 4

    pop ebp
    ret