section .data

    separator_line: db '_|_____|_____|_____|_', 10, 0
    regular_line: db ' |     |     |     | ', 10, 0
    line_with_value: db '%c|  %c  |  %c  |  %c  | ', 10, 0

section .text
    global _game

    extern _printf
    extern _malloc

_game:
    push ebp
    mov ebp, esp

    push 16
    call _malloc
    add esp, 4
    push eax
    call initialize_board
    call print_board
end:
    pop eax
    pop ebp
    ret

print_board:
    push ebp
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

    mov ebx, [ebp + 12]             ; address of values
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
    mov al, [ebx + 2]
    push eax
    mov al, [ebx + 1]
    push eax
    mov al, [ebx]
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
    mov al, [ebx + 8]
    push eax
    mov al, [ebx + 7]
    push eax
    mov al, [ebx + 6]
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
    mov byte [ebx + eax], 'x'
    pop ecx
    loop assign_value
    mov byte [ebx], 'x'

    pop ebp
    ret