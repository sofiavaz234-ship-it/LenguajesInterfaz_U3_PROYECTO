; Materia: Lenguajes de Interfaz
; Alumnas: Frida Sofia Vega Vazquez y Natalia Lopez Ibarra
; Horario: 8 a 9 am
; Docente: Dr. José Luis Medina Jiménez
; Proyecto: Sistema de Ventas e Inventario - Glamour Makeup Sinaloa 
;------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
INCLUDE Irvine32.inc

TAM_REGISTRO  EQU 44
MAX_PRODUCTOS EQU 10

mImprimir MACRO cadena
    mov edx, OFFSET cadena
    call WriteString
ENDM

mLeerCadena MACRO buffer, tamano
    mov edx, OFFSET buffer
    mov ecx, tamano
    call ReadString
ENDM

mCopiarBloque MACRO origen, destino, numBytes
    push esi
    push edi
    push ecx
    mov edi, destino
    mov esi, OFFSET origen
    mov ecx, numBytes
    cld
    rep movsb
    pop ecx
    pop edi
    pop esi
ENDM

mIrAlFinCadena MACRO regPtr
    LOCAL CicloFin, ListoFin
CicloFin:
    cmp BYTE PTR [regPtr], 0
    je ListoFin
    inc regPtr
    jmp CicloFin
ListoFin:
ENDM

mGuardarArchivo MACRO nombreArchivo, bufferTexto
    mov edx, OFFSET nombreArchivo
    mov esi, OFFSET bufferTexto
    call EscribirCadenaEnArchivo
ENDM

.data
    nomCatDat BYTE "catalogo.dat", 0
    nomCatTxt BYTE "catalogo.txt", 0
    nomMovTxt BYTE "movimientos.txt", 0
    nomVenTxt BYTE "ventas.txt", 0
    
    archivoHandle DWORD ?

    ingresosSesion    DWORD 0
    cantidadProductos DWORD 0
    catalogo          BYTE 440 DUP(0)
    
    bufCatTxt BYTE 2000 DUP(0)
    bufMovTxt BYTE 3000 DUP(0)
    bufVenTxt BYTE 3000 DUP(0)
    
    msgMenu         BYTE 0Ah, 0Dh, "--- GLAMOUR MAKEUP SINALOA ---", 0Ah, 0Dh
                    BYTE "1. Registrar Producto", 0Ah, 0Dh
                    BYTE "2. Consultar Inventario", 0Ah, 0Dh
                    BYTE "3. Recibir Mercancia", 0Ah, 0Dh
                    BYTE "4. Vender Producto", 0Ah, 0Dh
                    BYTE "5. Mostrar Resumen", 0Ah, 0Dh
                    BYTE "6. Salir", 0Ah, 0Dh
                    BYTE "Elige una opcion (1-6): ", 0
                    
    msgPedirCodigo  BYTE "Ingresa codigo (ABC-123): ", 0
    msgPedirNombre  BYTE "Nombre del cosmetico: ", 0
    msgPedirPrecio  BYTE "Precio en MXN (ej. 450.50): ", 0
    msgPedirCant    BYTE "Cantidad: ", 0
    
    msgErrorGen     BYTE "Error: Dato invalido o formato incorrecto.", 0Ah, 0Dh, 0
    msgExito        BYTE "Operacion realizada con exito.", 0Ah, 0Dh, 0
    msgLleno        BYTE "Error: Inventario lleno (Max 10).", 0Ah, 0Dh, 0
    msgNoEncontrado BYTE "Error: Codigo no encontrado.", 0Ah, 0Dh, 0
    msgDuplicado    BYTE "Error: Codigo duplicado. Ya existe en el catalogo.", 0Ah, 0Dh, 0
    msgMaxAlcanzado BYTE "Error: El producto ya tiene la existencia maxima (100 unidades).", 0Ah, 0Dh, 0
    msgExcedeMax    BYTE "Error: La cantidad ingresada supera el limite maximo permitida (Max 100).", 0Ah, 0Dh, 0
    msgSinStock     BYTE "Error: El producto no tiene existencias para vender.", 0Ah, 0Dh, 0
    msgNoSuficiente BYTE "Error: No hay suficiente existencia en inventario para esta venta.", 0Ah, 0Dh, 0
    msgDescuento    BYTE ">> AVISO: Descuento de mayoreo (10%) aplicado.", 0Ah, 0Dh, 0
    msgMXN          BYTE " MXN", 0
    msgSeparador    BYTE " | ", 0
    
    msgResumen      BYTE 0Ah, 0Dh, "--- RESUMEN DEL NEGOCIO ---", 0Ah, 0Dh, 0
    msgUnidades     BYTE "Unidades totales disponibles: ", 0
    msgTotalInv     BYTE "Valor total del inventario:   ", 0
    msgTotalIngr    BYTE "Ingresos totales de la sesion:", 0
    
    bufEntrada      BYTE 30 DUP(0)
    bufSalida       BYTE 30 DUP(0)
    
    tempCantidad    DWORD ?
    tempTotal       DWORD ?

    strEntradaTag   BYTE "[ENTRADA] Codigo: ", 0
    strSalidaTag    BYTE "[SALIDA]  Codigo: ", 0
    strVentaTag     BYTE "[VENTA]   Codigo: ", 0
    strCantTag      BYTE " | Cantidad actual: ", 0
    strImpTag       BYTE " | Importe: ", 0
    strCRLF         BYTE 0Dh, 0Ah, 0

.code
main PROC
    call CargarCatalogo

MenuLoop:
    mImprimir msgMenu
    mLeerCadena bufEntrada, SIZEOF bufEntrada
    
    cmp eax, 1
    jne OpcionInvalida
    
    mov al, bufEntrada[0]
    cmp al, '1'
    je OpcionAlta
    cmp al, '2'
    je OpcionConsultar
    cmp al, '3'
    je OpcionRecibir
    cmp al, '4'
    je OpcionVender
    cmp al, '5'
    je OpcionResumen
    cmp al, '6'
    je FinPrograma
    
OpcionInvalida:
    mImprimir msgErrorGen
    jmp MenuLoop

OpcionAlta:
    call RegistrarProducto
    jmp MenuLoop
OpcionConsultar:
    call ConsultarInventario
    jmp MenuLoop
OpcionRecibir:
    call RecibirMercancia
    jmp MenuLoop
OpcionVender:
    call VenderProducto
    jmp MenuLoop
OpcionResumen:
    call MostrarResumen
    jmp MenuLoop

FinPrograma:
    exit
main ENDP

CargarCatalogo PROC USES eax ecx edx esi
    mov edx, OFFSET nomCatDat
    call OpenInputFile
    cmp eax, INVALID_HANDLE_VALUE
    je FinCargar

    mov archivoHandle, eax
    mov edx, OFFSET catalogo
    mov ecx, SIZEOF catalogo
    call ReadFromFile

    mov eax, archivoHandle
    call CloseFile

    mov cantidadProductos, 0
    mov esi, OFFSET catalogo
    mov ecx, MAX_PRODUCTOS
CicloContar:
    cmp BYTE PTR [esi+42], 1
    jne SigContar
    inc cantidadProductos
SigContar:
    add esi, TAM_REGISTRO
    loop CicloContar

FinCargar:
    ret
CargarCatalogo ENDP

GuardarRespaldoDat PROC USES eax ecx edx
    mov edx, OFFSET nomCatDat
    call CreateOutputFile
    cmp eax, INVALID_HANDLE_VALUE
    je FinGuardarDat

    mov archivoHandle, eax
    mov edx, OFFSET catalogo
    mov ecx, SIZEOF catalogo
    call WriteToFile

    mov eax, archivoHandle
    call CloseFile

FinGuardarDat:
    ret
GuardarRespaldoDat ENDP

BuscarProducto PROC USES ebx ecx edi
    mov esi, OFFSET catalogo
    mov ecx, MAX_PRODUCTOS

CicloBusq:
    cmp BYTE PTR [esi+42], 1
    jne SigBusq

    push ecx
    push esi
    push edi
    mov edi, OFFSET bufEntrada
    mov ecx, 7
    repe cmpsb
    pop edi
    pop esi
    pop ecx
    je Encontrado

SigBusq:
    add esi, TAM_REGISTRO
    loop CicloBusq

    mov eax, 0
    ret

Encontrado:
    mov eax, 1
    ret
BuscarProducto ENDP

SolicitarYBuscarProducto PROC USES ecx edx
    mImprimir msgPedirCodigo
    mLeerCadena bufEntrada, 10

    call BuscarProducto
    cmp eax, 1
    je FinSolBusq

    mImprimir msgNoEncontrado
    mov eax, 0

FinSolBusq:
    ret
SolicitarYBuscarProducto ENDP

ValidarFormatoCodigo PROC USES esi
    cmp eax, 7
    jne FormatoInvalido

    cmp BYTE PTR [esi], 'A'
    jb FormatoInvalido
    cmp BYTE PTR [esi+2], 'Z'
    ja FormatoInvalido
    cmp BYTE PTR [esi+3], '-'
    jne FormatoInvalido
    cmp BYTE PTR [esi+4], '0'
    jb FormatoInvalido
    cmp BYTE PTR [esi+6], '9'
    ja FormatoInvalido

    clc
    ret

FormatoInvalido:
    stc
    ret
ValidarFormatoCodigo ENDP

BuscarEspacioLibre PROC USES eax ecx
    mov esi, OFFSET catalogo
    mov ecx, MAX_PRODUCTOS

CicloLibre:
    cmp BYTE PTR [esi+42], 0
    je EncontradoLibre
    add esi, TAM_REGISTRO
    loop CicloLibre

    stc
    ret

EncontradoLibre:
    clc
    ret
BuscarEspacioLibre ENDP

ObtenerLongitud PROC USES eax esi
    mov ecx, 0
CicloL:
    mov al, [esi]
    cmp al, 0
    je FinL
    inc ecx
    inc esi
    jmp CicloL
FinL:
    ret
ObtenerLongitud ENDP

EscribirCadenaEnArchivo PROC USES eax ebx ecx edx esi
    call ObtenerLongitud
    cmp ecx, 0
    je FinEscribir

    push ecx
    call CreateOutputFile
    cmp eax, INVALID_HANDLE_VALUE
    je ErrorCrear

    mov archivoHandle, eax
    pop ecx
    mov eax, archivoHandle
    mov edx, esi
    call WriteToFile

    mov eax, archivoHandle
    call CloseFile
    jmp FinEscribir

ErrorCrear:
    pop ecx
FinEscribir:
    ret
EscribirCadenaEnArchivo ENDP

GuardarArchivosSistema PROC USES eax edx esi
    call GuardarRespaldoDat
    call ActualizarBufferCatalogo

    mGuardarArchivo nomCatTxt, bufCatTxt
    mGuardarArchivo nomMovTxt, bufMovTxt
    mGuardarArchivo nomVenTxt, bufVenTxt
    ret
GuardarArchivosSistema ENDP

AnexarCadena PROC USES eax esi
CicloAnx:
    mov al, [esi]
    cmp al, 0
    je FinAnx
    mov [edi], al
    inc esi
    inc edi
    jmp CicloAnx
FinAnx:
    mov BYTE PTR [edi], 0
    ret
AnexarCadena ENDP

AnexarCadenaAlFinal PROC USES eax esi edi
    mIrAlFinCadena edi
CopiarAlFinal:
    mov al, [esi]
    cmp al, 0
    je FinAnxFinal
    mov [edi], al
    inc esi
    inc edi
    jmp CopiarAlFinal
FinAnxFinal:
    mov BYTE PTR [edi], 0
    ret
AnexarCadenaAlFinal ENDP

RegistrarMovimientoInventario PROC USES eax edx esi edi
    push esi
    mov edi, OFFSET bufMovTxt
    mov esi, edx
    call AnexarCadenaAlFinal
    pop esi

    mov edi, OFFSET bufMovTxt
    call AnexarCadenaAlFinal

    push esi
    mov esi, OFFSET strCantTag
    call AnexarCadenaAlFinal
    pop esi

    mov eax, [esi+38]
    mov edi, OFFSET bufSalida
    call ConvertirNumATexto

    mov edi, OFFSET bufMovTxt
    mov esi, OFFSET bufSalida
    call AnexarCadenaAlFinal

    mov esi, OFFSET strCRLF
    call AnexarCadenaAlFinal
    ret
RegistrarMovimientoInventario ENDP

RegistrarVentaArchivo PROC USES eax edx esi edi
    push eax
    push esi

    mov edi, OFFSET bufVenTxt
    mov esi, OFFSET strVentaTag
    call AnexarCadenaAlFinal

    pop esi
    call AnexarCadenaAlFinal

    mov esi, OFFSET strImpTag
    call AnexarCadenaAlFinal

    pop eax
    call FormatearMonedaCadena

    mov esi, OFFSET bufSalida
    call AnexarCadenaAlFinal

    mov esi, OFFSET strCRLF
    call AnexarCadenaAlFinal
    ret
RegistrarVentaArchivo ENDP

ActualizarBufferCatalogo PROC USES eax ebx ecx edx esi edi
    mov edi, OFFSET bufCatTxt
    mov BYTE PTR [edi], 0

    mov esi, OFFSET catalogo
    mov ecx, MAX_PRODUCTOS

CicloCat:
    cmp BYTE PTR [esi+42], 1
    jne SigCat

    push esi
    call AnexarCadena
    mov esi, OFFSET msgSeparador
    call AnexarCadena
    pop esi

    push esi
    add esi, 8
    call AnexarCadena
    mov esi, OFFSET msgSeparador
    call AnexarCadena
    pop esi

    push esi
    mov eax, [esi+34]
    call FormatearMonedaCadena
    mov esi, OFFSET bufSalida
    call AnexarCadena
    mov esi, OFFSET msgSeparador
    call AnexarCadena
    pop esi

    push esi
    mov eax, [esi+38]
    push edi
    mov edi, OFFSET bufSalida
    call ConvertirNumATexto
    pop edi
    mov esi, OFFSET bufSalida
    call AnexarCadena
    mov esi, OFFSET strCRLF
    call AnexarCadena
    pop esi

SigCat:
    add esi, TAM_REGISTRO
    loop CicloCat
    ret
ActualizarBufferCatalogo ENDP

MostrarProductoLinea PROC USES eax edx edi
    mov edx, esi
    call WriteString
    mImprimir msgSeparador

    lea edx, [esi+8]
    call WriteString
    mImprimir msgSeparador

    mov eax, [esi+34]
    call ImprimirMoneda
    mImprimir msgSeparador

    mov eax, [esi+38]
    mov edi, OFFSET bufSalida
    call ConvertirNumATexto
    mImprimir bufSalida
    call Crlf
    ret
MostrarProductoLinea ENDP

CapturarCantidadPositiva PROC USES ecx edx esi
PedirCantCiclo:
    mImprimir msgPedirCant
    mLeerCadena bufEntrada, 5

    mov esi, OFFSET bufEntrada
    call ConvertirTextoANum
    cmp eax, 0
    ja CantValida

    mImprimir msgErrorGen
    jmp PedirCantCiclo

CantValida:
    ret
CapturarCantidadPositiva ENDP

CalcularTotalVenta PROC USES ebx ecx
    mul ebx

    cmp ebx, 3
    jb NoAplicaDescuento

    mov ecx, 90
    mul ecx
    mov ecx, 100
    mov edx, 0
    div ecx
    mov dl, 1
    ret

NoAplicaDescuento:
    mov dl, 0
    ret
CalcularTotalVenta ENDP

RegistrarProducto PROC USES eax ebx ecx edx esi edi
    cmp cantidadProductos, MAX_PRODUCTOS
    jae ErrorLleno

PedirCod:
    mImprimir msgPedirCodigo
    mLeerCadena bufEntrada, 10

    mov esi, OFFSET bufEntrada
    call ValidarFormatoCodigo
    jc ErrFormat

    call BuscarProducto
    cmp eax, 1
    je ErrDuplicado

    call BuscarEspacioLibre
    jc ErrorLleno

    mCopiarBloque bufEntrada, esi, 8

PedirNom:
    mImprimir msgPedirNombre
    mLeerCadena bufEntrada, 26
    cmp eax, 0
    je PedirNom

    lea edi, [esi+8]
    mCopiarBloque bufEntrada, edi, 26

PedirPre:
    mImprimir msgPedirPrecio
    mLeerCadena bufEntrada, 15

    push esi
    mov esi, OFFSET bufEntrada
    call ParsePrecioCentavos
    pop esi
    jc ErrPrecio

    mov [esi+34], eax
    mov DWORD PTR [esi+38], 0
    mov BYTE PTR [esi+42], 1
    inc cantidadProductos

    call GuardarArchivosSistema
    mImprimir msgExito
    ret

ErrorLleno:
    mImprimir msgLleno
    ret

ErrDuplicado:
    mImprimir msgDuplicado
    jmp PedirCod

ErrPrecio:
    mImprimir msgErrorGen
    jmp PedirPre

ErrFormat:
    mImprimir msgErrorGen
    jmp PedirCod
RegistrarProducto ENDP

ConsultarInventario PROC USES eax ecx edx esi
    mov ecx, MAX_PRODUCTOS
    mov esi, OFFSET catalogo

CicloCons:
    cmp BYTE PTR [esi+42], 1
    jne SiguienteCons
    call MostrarProductoLinea
SiguienteCons:
    add esi, TAM_REGISTRO
    loop CicloCons
    ret
ConsultarInventario ENDP

RecibirMercancia PROC USES eax ebx ecx edx esi edi
    call SolicitarYBuscarProducto
    cmp eax, 0
    je FinRecibir

    cmp DWORD PTR [esi+38], 100
    jae YaLleno

PedirCantRec:
    call CapturarCantidadPositiva

    mov ebx, [esi+38]
    add ebx, eax
    cmp ebx, 100
    ja ErrExcede100

    mov [esi+38], ebx

    mov edx, OFFSET strEntradaTag
    call RegistrarMovimientoInventario

    call GuardarArchivosSistema
    mImprimir msgExito
    ret

YaLleno:
    mImprimir msgMaxAlcanzado
    ret

ErrExcede100:
    mImprimir msgExcedeMax
    jmp PedirCantRec

FinRecibir:
    ret
RecibirMercancia ENDP

VenderProducto PROC USES eax ebx ecx edx esi edi
    call SolicitarYBuscarProducto
    cmp eax, 0
    je FinVender

    cmp DWORD PTR [esi+38], 0
    je SinStock

PedirCantVen:
    call CapturarCantidadPositiva
    mov tempCantidad, eax

    cmp eax, [esi+38]
    ja ErrNoSuficiente

    mov eax, [esi+34]
    mov ebx, tempCantidad
    call CalcularTotalVenta

    cmp dl, 1
    jne SinAvisoDesc
    mImprimir msgDescuento
SinAvisoDesc:
    mov tempTotal, eax
    add ingresosSesion, eax
    mov ebx, tempCantidad
    sub [esi+38], ebx

    mov edx, OFFSET strSalidaTag
    call RegistrarMovimientoInventario

    mov eax, tempTotal
    call RegistrarVentaArchivo

    call GuardarArchivosSistema
    mImprimir msgExito
    ret

SinStock:
    mImprimir msgSinStock
    ret

ErrNoSuficiente:
    mImprimir msgNoSuficiente
    jmp PedirCantVen

FinVender:
    ret
VenderProducto ENDP

MostrarResumen PROC USES eax ebx ecx edx esi
    mov tempTotal, 0
    mov tempCantidad, 0
    
    mov esi, OFFSET catalogo
    mov ecx, MAX_PRODUCTOS
CicloRes:
    cmp BYTE PTR [esi+42], 1
    jne SigRes
    
    mov eax, [esi+38]
    add tempCantidad, eax
    mov ebx, [esi+34]
    mul ebx
    add tempTotal, eax
SigRes:
    add esi, TAM_REGISTRO
    loop CicloRes

    mImprimir msgResumen
    
    mImprimir msgUnidades
    mov eax, tempCantidad
    mov edi, OFFSET bufSalida
    call ConvertirNumATexto
    mImprimir bufSalida
    call Crlf

    mImprimir msgTotalInv
    mov eax, tempTotal
    call ImprimirMoneda
    call Crlf

    mImprimir msgTotalIngr
    mov eax, ingresosSesion
    call ImprimirMoneda
    call Crlf
    ret
MostrarResumen ENDP

ConvertirTextoANum PROC USES ebx ecx edx esi
    mov eax, 0
    mov ebx, 10

CicloTex:
    mov cl, [esi]
    cmp cl, 0
    je FinTex
    cmp cl, '0'
    jb ErrorTex
    cmp cl, '9'
    ja ErrorTex

    sub cl, '0'
    movzx edx, cl
    push edx
    mul ebx
    pop edx
    add eax, edx
    inc esi
    jmp CicloTex

ErrorTex:
    mov eax, 0
FinTex:
    ret
ConvertirTextoANum ENDP

ParsePrecioCentavos PROC USES ebx ecx edx esi
    mov eax, 0
    mov ebx, 10
    mov ecx, 0
    mov edx, 0

CicloParse:
    mov cl, [esi]
    cmp cl, 0
    je FinParse
    cmp cl, '.'
    jne NoPunto

    cmp edx, 1
    je ErrParse
    mov edx, 1
    jmp SigChar

NoPunto:
    cmp cl, '0'
    jb ErrParse
    cmp cl, '9'
    ja ErrParse

    push edx
    sub cl, '0'
    movzx edx, cl
    push edx
    mul ebx
    pop edx
    add eax, edx
    pop edx

    cmp edx, 1
    jne SigChar
    inc ch

SigChar:
    inc esi
    jmp CicloParse

FinParse:
    cmp ch, 0
    je Mult100
    cmp ch, 1
    je Mult10
    cmp ch, 2
    je OkParse
    jmp ErrParse

Mult100:
    mov ebx, 100
    mul ebx
    jmp OkParse

Mult10:
    mov ebx, 10
    mul ebx

OkParse:
    cmp eax, 1
    jb ErrParse
    cmp eax, 999999
    ja ErrParse

    clc
    ret

ErrParse:
    stc
    ret
ParsePrecioCentavos ENDP

ConvertirNumATexto PROC USES eax ebx ecx edx edi
    mov ecx, 0
    mov ebx, 10
CicloDividir:
    mov edx, 0
    div ebx
    add dl, '0'
    push edx
    inc ecx
    cmp eax, 0
    jne CicloDividir
CicloSacar:
    pop edx
    mov [edi], dl
    inc edi
    loop CicloSacar
    mov BYTE PTR [edi], 0
    ret
ConvertirNumATexto ENDP

FormatearMonedaCadena PROC USES eax ebx edx edi
    mov ebx, 100
    mov edx, 0
    div ebx

    mov edi, OFFSET bufSalida
    call ConvertirNumATexto

    mov edi, OFFSET bufSalida
    mIrAlFinCadena edi

    mov BYTE PTR [edi], '.'
    inc edi

    cmp edx, 10
    jae CentavosNormales
    mov BYTE PTR [edi], '0'
    inc edi

CentavosNormales:
    mov eax, edx
    call ConvertirNumATexto

    mov edi, OFFSET bufSalida
    mIrAlFinCadena edi

    mov BYTE PTR [edi], ' '
    mov BYTE PTR [edi+1], 'M'
    mov BYTE PTR [edi+2], 'X'
    mov BYTE PTR [edi+3], 'N'
    mov BYTE PTR [edi+4], 0
    ret
FormatearMonedaCadena ENDP

ImprimirMoneda PROC USES eax edx
    call FormatearMonedaCadena
    mImprimir bufSalida
    ret
ImprimirMoneda ENDP

END main