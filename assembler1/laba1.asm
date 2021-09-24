.386 ; ���������, �������������� ���������� ������������
; ����� �������� ��� ���������� 80386.
.MODEL FLAT, STDCALL ; ������� ������, ����� �������� �� ����������
; � Windows x32
EXTRN GetStdHandle@4:PROC ; ����������� ���������� �����-������
EXTRN WriteConsoleA@20:PROC ; ����� ������
EXTRN CharToOemA@8:PROC					; �������������
EXTRN ReadConsoleA@20:PROC				; ����
EXTRN ExitProcess@4:PROC				; �����
EXTRN lstrlenA@4:PROC					; ����������� ������ ������

.DATA									; ������� ������
DOUT DD ?								; ���������� ������
DIN DD ?								; ���������� �����
STRN1 DB "������� 1 �����: ",13,10,0	; ��������� ������
STRN2 DB "������� 2 �����: ",13,10,0	; ��������� ������
BUF DB 35 dup (?)						; ����� ��� ��������/��������� �����
LENS DD ?								; ���������� ���������� ��������
										;��� �������� �����
NUMEROS_A DD ?							; ������
NUMEROS_B DD ?							; ������
										; ���������� ��� �������� �������� - ��������� ������ ���������
EIGHT DD 8								; ��� 8
TEN DD 10								; ��� 10
FL DB 0									; ���� ��� �������� ����� ������� �����
FL2 DB 0								; ���� ��� �������� ����� ������� �����

.CODE									; ������� ����

MAIN PROC								; ����� ����� �����
										; ������������ ������ STRN
PUSH OFFSET STRN1						; ��������� ������� ���������� � ����
PUSH OFFSET STRN1
CALL CharToOemA@8						; ����� ������� �������������
										; ������� ���������� �����
PUSH -10
CALL GetStdHandle@4
MOV DIN, EAX							; ����������� ��������� �� �������� EAX
										; � ������ ������ � ������ DIN
										; ������� ���������� ������
PUSH -11
CALL GetStdHandle@4
MOV DOUT, EAX

INPUT1:
MOV FL,0
										; ����� ������
PUSH OFFSET STRN1						; � ���� ���������� ��������� �� ������
CALL lstrlenA@4							; ����� � EAX
										; ����� ������� WriteConsoleA ��� ������ ������ STRN
PUSH 0									; � ���� ���������� 5-� (���������) �������� 
PUSH OFFSET LENS						; 4-� ��������, ���-�� �����-�� ���������� ��������
PUSH EAX								; 3-� ��������, ���-�� ��������� ��������
PUSH OFFSET STRN1						; 2-� ��������, �����, � ������� �����
PUSH DOUT								; 1-� ��������, ���������� ������
CALL WriteConsoleA@20
										; ���� ������
PUSH 0									; � ���� ���������� 5-� ��������
PUSH OFFSET LENS 
PUSH 35 
PUSH OFFSET BUF 
PUSH DIN								; 1-� ��������
CALL ReadConsoleA@20
										;��������� 1-�� ����� (������ � ������)
SUB LENS, 2								; �������� ������� LF � CR (10 � 13)
MOV ECX, LENS							; ������� ����� - ���������� �������������� �������� � ECX
MOV ESI, OFFSET BUF						; ������ ������ �������� � ���������� BUF ���������� � ESI
XOR BX, BX								; �������� ������� BX �������� XOR,
										; ����������� ������� �������� ������������ ���
XOR AX, AX								; �������� ������� AX

MOV BL, [ESI]							; ��������� 1 ������ �� ��������� ������ � �������
										; BL, ��������� ��������� ���������
SUB BL, '0'								; ������� �� ���������� ������� ��� ����
JNS CONVERT_1							; �������, ���� ����� �������������
INC(FL)									; ���� ����� ������������� ����=1
INC ESI									; ������� �� ��������� ������ ������
SUB LENS, 1
MOV ECX, LENS							; ������� ����� - ���������� �������������� �������� � ECX


CONVERT_1:								; ����� ������ ���� �����
MOV BL, [ESI]							; ��������� ������ �� ��������� ������ � �������
SUB BL, '0'								; ������� �� ���������� ������� ��� ����
										; ������ ������� ����� ���� ����� �� ������ ������ 7
CMP BL,7 
JA INPUT1
MUL EIGHT								; �������� �������� AX �� 8, �-��� � � AX
ADD AX, BX								; �������� � ����������� � AX ����� ����� �����
INC ESI									; ������� �� ��������� ������ ������
LOOP CONVERT_1							; ������� �� ��������� �������� ����� (ECX--)

MOV NUMEROS_A, EAX						; ���������� ����� � ������

										;��������� ������ ����2
PUSH OFFSET STRN2
PUSH OFFSET STRN2
CALL CharToOemA@8						; ����� ������� �������������

INPUT2:
MOV FL2,0
										;����� ������
PUSH OFFSET STRN2						; � ���� ���������� ��������� �� ������
CALL lstrlenA@4
PUSH 0									; 5-� ��������
PUSH OFFSET LENS 
PUSH EAX 
PUSH OFFSET STRN2
PUSH DOUT								; 1-� ��������
CALL WriteConsoleA@20
										; ���� ������
PUSH 0									; 5-� ��������
PUSH OFFSET LENS 
PUSH 35 
PUSH OFFSET BUF 
PUSH DIN								; 1-� ��������
CALL ReadConsoleA@20
										;��������� ������
SUB LENS, 2								; ��������� ��������
MOV ECX, LENS							; ������� �����
MOV ESI, OFFSET BUF						; ������ ������ �������� � ���������� BUF
XOR BX, BX								; �������� ������� BX 
XOR AX, AX								; �������� ������� AX

MOV BL, [ESI]							; ��������� ������ �� ��������� ������ � ������� BL
SUB BL, '0'								; ������� �� ���������� ������� ��� ����
JNS CONVERT_2							; �������, ���� ����� �������������
INC(FL2)								; ���� ����� ������������� ����=1
INC ESI									; ������� �� ��������� ������ ������
SUB LENS, 1
MOV ECX, LENS							; ������� ����� - ���������� �������������� �������� � ECX

CONVERT_2:								; ����� ������ ���� �����
MOV BL, [ESI]							; ��������� ������ �� ��������� ������ � ������� BL
SUB BL, '0'								; ������� �� ���������� ������� ��� ����
										; ������ ������� ����� ���� ����� �� ������ ������ 7
CMP BL,7
JA INPUT2
MUL EIGHT								; �������� �������� AX �� 8, ��������� � � AX
ADD AX, BX								; �������� � ����������� � AX ����� ����� �����
INC ESI									; ������� �� ��������� ������ ������
LOOP CONVERT_2							; ������� �� ��������� �������� �����

MOV NUMEROS_B, EAX						; ������ �����

										; ��������� �����
MOV EAX, NUMEROS_A						; ������ ����� � �������
MOV EBX, NUMEROS_B						; ������ ����� � �������
IMUL EAX, EBX							; �������, ��������� � EAX
										; ����� ����������
CDQ										; ������� ��� � 64-� ������� (EAX ���������������� �� EDX)
XOR EDI, EDI							; ���������

MOV ESI,OFFSET BUF						; ������ ������ �������� � ���������� BUF

.WHILE EAX>=TEN							; ���� ����� >= 10
DIV TEN									; ��������� � EAX, ������� � EDX
										;��������� � ������
ADD EDX, '0'							; �������� ��� ����
PUSH EDX								; ���������� ���������������� ������� � ����
ADD EDI, 1								; �������� �������
XOR EDX, EDX							; ���������
.ENDW									; ����� �����

ADD EAX, '0'							; ����������� ���� ����
PUSH EAX								; � ����
ADD EDI, 1								; ��������� �������

										;����������� ������
MOV ECX, EDI							; ���-�� ���� � ECX

										;����������� ����� ���-����
MOV BH, FL
MOV BL, FL2
ADD BH, BL
MOV FL, BH

CMP FL,1 
JNZ CONVERT_3							; ���� ���� �� ����� 1, ���-��� �������������
PUSH "-"
POP [ESI]								; ������� ����?
INC ESI

CONVERT_3:								; ������ �����
POP [ESI]								; �� �����
INC ESI									; ���� ESI �� 1
LOOP CONVERT_3							; ����� �����

PUSH OFFSET BUF							; � ���� ���������� ��������� �� ������
CALL lstrlenA@4
PUSH 0									; � ���� ���������� 5-� ��������
PUSH OFFSET LENS 
PUSH EAX 
PUSH OFFSET BUF 
PUSH DOUT								; 1-� ��������
CALL WriteConsoleA@20


; ����� �� ���������
PUSH 0 ; ��������: ��� ������
CALL ExitProcess@4
MAIN ENDP
END MAIN
