name "Somma tra due numeri presi in input (di CRISTIAN SOMMA 3^BII)"

; NOTA:
; Non sono riuscito a stampare il risultato in console, percio' sara' necessario guardare
; nel debugger la variabile chiamata num1 per poter sapere il risultato della somma.

data segment
    num1 DB ?   ; Inizializzo senza valore (?) il primo numero da 1 byte (DB)
    num2 DB ?   ; Inizializzo senza valore il secondo numero.
    sum DB ?    ; Inizializzo la variabile che conterra' la somma dei due numeri
    msg1 DB "Inserire il primo numero: $"   ; Primo messaggio, la stringa termina sempre con $
    msg2 DB "Inserire il secondo numero: $" ; Come per msg1
    msg3 DB "Guardare il debugger nella variabile sum il valore della somma.$"
    endMsg DB "Premere qualunque tasto per uscire...$"
ends

stack segment
    dw   128  dup(0)
ends

code segment
start:

    MOV AX, data ; Muovo nel registro ax il riferimento al data segment
    MOV DS, AX  ; Assegno al registro il valore di ax, ovvero la reference al data segment

    MOV AX, 0000h   ; Inizializzo il registro ax a zero per ripulirlo
    LEA DX, msg1    ; Muovo nel data register l'indirizzo della stringa che voglio stampare
    CALL print  ; Stampo la riga all'indirizzo aggiunto in dx in precedenza
    CALL return ; Con call richiamo la subroutine "return"            
    
    CALL input  ; Chiamo la subroutine di input per il primo numero            
    SUB AL, 30h ; Sottraggo al codice ASCII 48 (30h) per ottenere il valore effettivo inserito
    MOV num1, AL    ; Salvo il valore in input, che si trova in al nella variabile num1
    MOV sum, AL ; sposto nella variabile sum il valore del primo numero per poi fare la somma
    CALL return
        
    LEA DX, msg2    ; Salvo nel registro dx l'indirizzo di memoria della variabile msg2
    CALL print  ; stampo msg2
    CALL return ; a capo riga
    
    CALL input  ; input del secondo numero
    SUB AL, 30h ; Sottraggo al codice ASCII 48 per avere il valore numerico
    MOV num2, AL    ; salva nella variabile num2 il valore del registro al
    
    ; SOMMA QUI SOTTO:
    ADD sum, AL    ; addizione del contenuto della variabile SUM e del registro al che contiene il secondo numero
    
    CALL return
    
    LEA DX, msg3    ; stampo msg3 che dice di guardare il debugger
    CALL print 
    CALL return
    
    LEA DX, endMsg  ; stampa la stringa finale per uscire
    CALL print
    CALL input  ; input per uscire dalla console
    
    MOV AX, 4c00h ; Ritorna al sistema operativo il controllo
    int 21h    
ENDS    ; Fine della routine principale

;------------------------------------------------------

print PROC NEAR ; creo una funzione print per stampare il valore all'indirizzo inserito in anticipo nel DX    
    MOV AH, 9   ; Con 9 dico all'interrupt di stampare una stringa che termina con $
    int 21h ; Interrupt 21   
    RET
ENDP

;------------------------------------------------------

input PROC NEAR
    MOV AH, 01h   ; Con 1 l'interrupt aspetta in input un carattere, che viene scritto in al
    int 21h
    RET
ENDP
;------------------------------------------------------

return PROC NEAR    ; Creo una subroutine per evitare di dover riscrivere ogni volta le funzioni interrupt 
    MOV DL, 0Ah ; Muovo in dl il codice ASCII hex del ritorno a capo (\n)
    MOV AH, 02h   ; Con 2 l'interrupt stampa un carattere avendo il suo codice ASCII
    int 21h
                
    MOV DL, 0Dh ; Muovo in dl il codice ASCII hex del carriage return (\r)
    MOV AH, 02h ; Stampo il carattere
    int 21h
    RET ; Ritorno alla routine Main 

ENDP    ; Indico la fine della subroutine con endp (end procedure)

;------------------------------------------------------

end start
