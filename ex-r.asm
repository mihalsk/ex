format PE64 console
use64
entry main

include 'win64ax.inc'

section '.data' data readable writable
infmt: db "%u", 0
fmt_out   db "%u", 10, 0 ; Формат вывода - беззнаковый
cmd_pause db 'pause',0        ; Команда паузы
chi: dq 1.0
zna: dq 1.0
er: dq  0.0000001
el: dq  0.0
n: dd 1
x: dd 1
result: dq 1.0
ofmt: db "%u %.10f %.10f",10,0
ofmt2: db "%u",10,0
outfmt: db "%.16f",10,0
section '.text' code executable
proc main
invoke scanf_s,infmt,x
;invoke printf_s,fmt_out, dword[x]
;invoke printf_s,ofmt, dword[n], qword[chi], qword[zna]
finit
fld qword[result]        ;итоговая сумма
fld qword[chi]           ;числитель члена|S
fstp st3                 ;"выдавили" числитель в st3   st2?
fld qword[zna]           ;знаменатель|S||||st4|||
fstp st4                 ;"выдавили" знаменатель в st4   st3?
                         ;S||||st4|st5|||
metka:        ; Цикл
        fld st2                         ;(st4)|S||||st5||
        fild dword[x]                   ;x|(st4)|S|||||st5|   5,6
        fmulp                           ;chi|S|||||st5||       4,5
        fst st3                         ;chi|S||||st5|(st5*)||
        ;fst
        fld st4                         ;(st5*)|chi|S||||st6||  5,6
        fild dword[n]                   ;n|(st5*)|chi|S||||st6|6,7
        fmulp                           ;zna|chi|S||||st6||     5,6
        fst st5                         ;zna|chi|S||||st6|st7|  5,6
        fdivp                           ;el|S||||st5|st6||      4,5
        fld st0
        fabs
        fld qword[er]
        fcomi st0,st1
        ja exit
        fstp qword[er]
        fstp qword[el]                  ;abs el
        faddp                           ;S||||st4|st5|||        3,4
        add dword[n],1          ; n
        invoke printf_s,ofmt, dword[n], qword[el], qword[er]
        jmp metka
exit:
        fstp qword[er]
        fstp qword[el]
        faddp
        fst qword[result]
        invoke printf_s,outfmt,qword[result]  ; Вывод результата
        invoke system,cmd_pause      ; Ожидание нажатия клавиши
        xor rax,rax
ret
endp

section '.idata' import data readable writeable
library msvcrt,'msvcrt.dll'
import  msvcrt,\
        system,'system',\
        scanf_s,'scanf_s',\
        printf_s,'printf_s'