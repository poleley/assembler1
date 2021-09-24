.386 ; директива, предписывающая Ассемблеру использовать
; набор операций для процессора 80386.
.MODEL FLAT, STDCALL ; плоская модель, вызов процедур по соглашению
; в Windows x32
EXTRN GetStdHandle@4:PROC ; стандартный дескриптор ввода-вывода
EXTRN WriteConsoleA@20:PROC ; вывод текста
EXTRN CharToOemA@8:PROC					; перекодировка
EXTRN ReadConsoleA@20:PROC				; ввод
EXTRN ExitProcess@4:PROC				; выход
EXTRN lstrlenA@4:PROC					; определение длинны строки

.DATA									; сегмент данных
DOUT DD ?								; дескриптор вывода
DIN DD ?								; дескриптор ввода
STRN1 DB "Введите 1 число: ",13,10,0	; выводимая строка
STRN2 DB "Введите 2 число: ",13,10,0	; выводимая строка
BUF DB 35 dup (?)						; буфер для вводимых/выводимых строк
LENS DD ?								; количество выведенных символов
										;два вводимых числа
NUMEROS_A DD ?							; первое
NUMEROS_B DD ?							; второе
										; переменные для хранения констант - оснований систем счисления
EIGHT DD 8								; для 8
TEN DD 10								; для 10
FL DB 0									; флаг для хранения знака первого числа
FL2 DB 0								; флаг для хранения знака второго числа

.CODE									; сегмент кода

MAIN PROC								; метка точки входа
										; перекодируем строку STRN
PUSH OFFSET STRN1						; параметры функции помещаются в стек
PUSH OFFSET STRN1
CALL CharToOemA@8						; вызов функции перекодировки
										; получим дескриптор ввода
PUSH -10
CALL GetStdHandle@4
MOV DIN, EAX							; переместить результат из регистра EAX
										; в ячейку памяти с именем DIN
										; получим дескриптор вывода
PUSH -11
CALL GetStdHandle@4
MOV DOUT, EAX

INPUT1:
MOV FL,0
										; вывод строки
PUSH OFFSET STRN1						; в стек помещается указатель на строку
CALL lstrlenA@4							; длина в EAX
										; вызов функции WriteConsoleA для вывода строки STRN
PUSH 0									; в стек помещается 5-й (резервный) параметр 
PUSH OFFSET LENS						; 4-й параметр, кол-во дейст-но выведенных символов
PUSH EAX								; 3-й параметр, кол-во выводимых символов
PUSH OFFSET STRN1						; 2-й параметр, буфер, в котором текст
PUSH DOUT								; 1-й параметр, дескриптор вывода
CALL WriteConsoleA@20
										; ввод строки
PUSH 0									; в стек помещается 5-й параметр
PUSH OFFSET LENS 
PUSH 35 
PUSH OFFSET BUF 
PUSH DIN								; 1-й параметр
CALL ReadConsoleA@20
										;обработка 1-го числа (строка в буфере)
SUB LENS, 2								; вычитаем символы LF и CR (10 и 13)
MOV ECX, LENS							; счетчик цикла - количество необработанных символов в ECX
MOV ESI, OFFSET BUF						; начало строки хранится в переменной BUF перемещено в ESI
XOR BX, BX								; обнулить регистр BX командой XOR,
										; выполняющей побитно операцию «исключающее или»
XOR AX, AX								; обнулить регистр AX

MOV BL, [ESI]							; поместить 1 символ из введенной строки в регистр
										; BL, используя косвенную адресацию
SUB BL, '0'								; вычесть из введенного символа код нуля
JNS CONVERT_1							; переход, если число положительное
INC(FL)									; если число отрицательное флаг=1
INC ESI									; перейти на следующий символ строки
SUB LENS, 1
MOV ECX, LENS							; счетчик цикла - количество необработанных символов в ECX


CONVERT_1:								; метка начала тела цикла
MOV BL, [ESI]							; поместить символ из введенной строки в регистр
SUB BL, '0'								; вычесть из введенного символа код нуля
										; запрос повтора ввода если цифра из буфера больше 7
CMP BL,7 
JA INPUT1
MUL EIGHT								; умножить значение AX на 8, р-тат – в AX
ADD AX, BX								; добавить к полученному в AX числу новую цифру
INC ESI									; перейти на следующий символ строки
LOOP CONVERT_1							; перейти на следующую итерацию цикла (ECX--)

MOV NUMEROS_A, EAX						; полученное число в память

										;кодировка строки стрн2
PUSH OFFSET STRN2
PUSH OFFSET STRN2
CALL CharToOemA@8						; вызов функции перекодировки

INPUT2:
MOV FL2,0
										;вывод строки
PUSH OFFSET STRN2						; в стек помещается указатель на строку
CALL lstrlenA@4
PUSH 0									; 5-й параметр
PUSH OFFSET LENS 
PUSH EAX 
PUSH OFFSET STRN2
PUSH DOUT								; 1-й параметр
CALL WriteConsoleA@20
										; ввод строки
PUSH 0									; 5-й параметр
PUSH OFFSET LENS 
PUSH 35 
PUSH OFFSET BUF 
PUSH DIN								; 1-й параметр
CALL ReadConsoleA@20
										;обработка строки
SUB LENS, 2								; вычитание символов
MOV ECX, LENS							; счетчик цикла
MOV ESI, OFFSET BUF						; начало строки хранится в переменной BUF
XOR BX, BX								; обнулить регистр BX 
XOR AX, AX								; обнулить регистр AX

MOV BL, [ESI]							; поместить символ из введенной строки в регистр BL
SUB BL, '0'								; вычесть из введенного символа код нуля
JNS CONVERT_2							; переход, если число положительное
INC(FL2)								; если число отрицательное флаг=1
INC ESI									; перейти на следующий символ строки
SUB LENS, 1
MOV ECX, LENS							; счетчик цикла - количество необработанных символов в ECX

CONVERT_2:								; метка начала тела цикла
MOV BL, [ESI]							; поместить символ из введенной строки в регистр BL
SUB BL, '0'								; вычесть из введенного символа код нуля
										; запрос повтора ввода если цифра из буфера больше 7
CMP BL,7
JA INPUT2
MUL EIGHT								; умножить значение AX на 8, результат – в AX
ADD AX, BX								; добавить к полученному в AX числу новую цифру
INC ESI									; перейти на следующий символ строки
LOOP CONVERT_2							; перейти на следующую итерацию цикла

MOV NUMEROS_B, EAX						; второе число

										; умножение чисел
MOV EAX, NUMEROS_A						; первое число в регистр
MOV EBX, NUMEROS_B						; второе число в регистр
IMUL EAX, EBX							; умножим, результат в EAX
										; вывод результата
CDQ										; приведём тип к 64-х битному (EAX распространяется на EDX)
XOR EDI, EDI							; обнуление

MOV ESI,OFFSET BUF						; начало строки хранится в переменной BUF

.WHILE EAX>=TEN							; пока число >= 10
DIV TEN									; результат в EAX, остаток в EDX
										;поместить в строку
ADD EDX, '0'							; добавить код нуля
PUSH EDX								; складываем перекодированный остаток в стек
ADD EDI, 1								; прибавим единицу
XOR EDX, EDX							; обнуление
.ENDW									; конец цикла

ADD EAX, '0'							; прибавление кода нуля
PUSH EAX								; в стек
ADD EDI, 1								; прибавить единицу

										;инвертируем строку
MOV ECX, EDI							; кол-во цифр в ECX

										;определение знака рез-тата
MOV BH, FL
MOV BL, FL2
ADD BH, BL
MOV FL, BH

CMP FL,1 
JNZ CONVERT_3							; если флаг не равен 1, рез-тат положительный
PUSH "-"
POP [ESI]								; очищаем стек?
INC ESI

CONVERT_3:								; начало цикла
POP [ESI]								; из стека
INC ESI									; увел ESI на 1
LOOP CONVERT_3							; конец цикла

PUSH OFFSET BUF							; в стек помещается указатель на строку
CALL lstrlenA@4
PUSH 0									; в стек помещается 5-й параметр
PUSH OFFSET LENS 
PUSH EAX 
PUSH OFFSET BUF 
PUSH DOUT								; 1-й параметр
CALL WriteConsoleA@20


; выход из программы
PUSH 0 ; параметр: код выхода
CALL ExitProcess@4
MAIN ENDP
END MAIN
