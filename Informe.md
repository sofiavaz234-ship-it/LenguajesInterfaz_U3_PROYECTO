# Informe - Proyecto Unidad 2 y 3

**Materia:** Lenguajes de Interfaz | **Alumnas:** Natalia Lopez Ibarra, Frida Sofia Vega Vazquez | **Docente:** Dr. Jose Luis Medina Jimenez

## 1. Negocio elegido
Tienda de maquillaje "Glamour Makeup Sinaloa": cosmeticos con codigo `ABC-123` (ej. `LAB-101` labial, `RIM-202` rimel).

## 2. Regla adicional: descuento por cantidad (mayoreo)
- **Cuando se aplica:** en una venta (un solo producto) de **3 o mas unidades**.
- **Calculo:** se multiplica el importe base por 90 y se divide entre 100 (`(importe_base * 90) / 100` con `DIV` entero, descartando fracciones de centavo).
- **Por que asi:** al multiplicar por 90 y dividir entre 100 en aritmetica entera se obtiene directamente el 90% del importe total (10% de descuento) truncando cualquier fraccion de centavo, sin superar el limite de 32 bits en las ventas permitidas.
- **Caso que aplica:** 3 x RIM-202 (145.00) = 435.00 * 90 / 100 = **391.50 MXN**.
- **Caso que no aplica:** 2 x RIM-202 = **290.00 MXN**.
- **Truncamiento:** 3 x BAS-303 (320.99) = 962.97 * 90 / 100 = **866.67 MXN** (se descartan los .003 centavos restantes).
- Los **ingresos de la sesion** suman el importe final (ya con descuento).

## 3. Organizacion de datos en memoria
`catalogo` = 10 registros de 44 bytes (440 bytes). Se recorre con ESI sumando `TAM_REGISTRO`.

| Offset | Campo | Tamano |
|---|---|---|
| 0 | Codigo `ABC-123` + 00h | 8 |
| 8 | Nombre (max 25 + 00h) | 26 |
| 34 | Precio en centavos | DWORD |
| 38 | Existencia (0-100) | DWORD |
| 42 | Estado (0 libre, 1 ocupado) | BYTE |
| 43 | Relleno | BYTE |

Otras variables: `ingresosSesion` (centavos), `cantidadProductos`, buffers `bufEntrada` (30), `bufSalida` (30), `bufCatTxt` (2000), `bufMovTxt` (3000), `bufVenTxt` (3000) y temporales `tempCantidad` y `tempTotal` para calcular importes antes de afectar el inventario.

## 4. Formato de los archivos de respaldo y reporte
- **`catalogo.dat`:** archivo binario de 440 bytes donde se vuelca directamente el arreglo `catalogo` en RAM mediante `WriteToFile` y se recupera al iniciar con `ReadFromFile` (`CargarCatalogo`), recalculando `cantidadProductos` con los registros que tengan estado = 1.
- **Archivos `.txt` (`catalogo.txt`, `movimientos.txt`, `ventas.txt`):** texto plano legible desde el Bloc de notas separados por ` | ` y terminados en CR LF (`0Dh, 0Ah`).

```text
LAB-101 | Labial Mate Rojo | 189.50 MXN | 25
RIM-202 | Rimel Waterproof | 145.00 MXN | 40
```

## 5. Decisiones del codigo
- Todo se captura con `ReadString` (EDX = buffer, ECX = maximo, EAX = longitud) y se convierte con rutinas propias (`ConvertirTextoANum` y `ParsePrecioCentavos`).
- Precio: acumula digitos (x10 + digito), cuenta decimales (hasta 2), rechaza vacio, simbolos, mas de un punto decimal, tercer decimal y valores fuera de 0.01-9999.99; si hay 0 o 1 decimal escala a centavos multiplicando por 100 o 10.
- Una operacion rechazada vuelve al menu o pide corregir el dato sin modificar el catalogo.

## 6. Fuentes 
- Irvine, K. R. *Assembly Language for x86 Processors* (7a ed.): capitulo de aritmetica entera (MUL, DIV), de procedimientos/pila, macros y de E/S de archivos (CreateOutputFile, OpenInputFile, WriteToFile, ReadFromFile, CloseFile).
- Apuntes y practicas de la Unidad 2 y Unidad 3 (repositorio del curso).

---

## Version de la Unidad 3

Para esta version se reorganizo y limpio el codigo del proyecto (`main.asm`) conservando las mismas funciones, validaciones y la regla del 10% de descuento en mayoreo, pero sustituyendo las partes repetidas por procedimientos mas cortos, macros y la directiva `USES`.

### 1. Tabla de antes y despues

| Parte del programa | Problema detectado (Unidad 2) | Cambio realizado (Unidad 3) | Beneficio |
|---|---|---|---|
| Entrada y salida de los procedimientos | Cada procedimiento tenia entre 4 y 12 lineas manuales de `push` y `pop`, y habia que repetir todos los `pop` antes de cada `ret` cuando ocurria un error. | Se aplico `USES` en los 26 procedimientos secundarios, dejando fuera los registros que devuelven resultados (`EAX`, `ESI`, `ECX`, `EDI`, `EDX`). | Se quitaron alrededor de 85 lineas repetidas y la pila queda equilibrada al salir en cualquier `ret`. |
| Escritura en los archivos `movimientos.txt` y `ventas.txt` | Habia dos procedimientos casi iguales (`AnexarAMovimientos` y `AnexarAVentas`) y bloques repetidos de 18 lineas para armar cada renglon. | Se juntaron en un solo procedimiento (`AnexarCadenaAlFinal`) y se extrajeron `RegistrarMovimientoInventario` y `RegistrarVentaArchivo`. | El armado de los renglones para los archivos `.txt` quedo en un solo lugar y se redujo a la mitad. |
| Mensajes y lectura en pantalla | Se repetian mas de 30 pares de `mov edx, OFFSET ...` / `call WriteString` y 6 lecturas con `ReadString`. | Se hicieron las macros `mImprimir` y `mLeerCadena`. | Cada mensaje o lectura ocupa una sola linea sin agregar llamadas extra de `CALL` y `RET`. |
| Busqueda del fin de cadena (`0`) | Habia 4 ciclos iguales (`BuscFinMov`, `BuscFinVen`, `BuscFin`, `BuscFin2`) avanzando punteros hasta encontrar el cero final. | Se cambiaron por la macro `mIrAlFinCadena` declarando sus etiquetas internas con `LOCAL`. | Evita repetir ciclos de recorrido y evita errores de etiquetas duplicadas al usar la macro varias veces. |
| Opciones de `RegistrarProducto`, `RecibirMercancia` y `VenderProducto` | Eran procedimientos muy largos (de 90 a 110 lineas) que mezclaban lectura, validacion, busqueda y el calculo del descuento. | Se separaron en `ValidarFormatoCodigo`, `BuscarEspacioLibre`, `SolicitarYBuscarProducto`, `CapturarCantidadPositiva`, `CalcularTotalVenta` y `MostrarProductoLinea`. | Las opciones del menu quedaron mas cortas y faciles de revisar paso a paso. |
| Copia de cadenas y guardado de archivos `.txt` | Se repetia el bloque `push esi / mov edi / rep movsb / pop esi` y 3 llamadas seguidas en `GuardarArchivosSistema`. | Se definieron las macros `mCopiarBloque` y `mGuardarArchivo`. | Cuida que no se pierda el puntero del producto (`ESI`) y hace mas corto el guardado de archivos. |

### 2. Fragmentos representativos

Todos los ejemplos estan en el archivo **`main.asm`**.

**A. Procedimiento reutilizado (`RegistrarMovimientoInventario`)**
Se usa tanto en `RecibirMercancia` (mandando `strEntradaTag`) como en `VenderProducto` (mandando `strSalidaTag`):

```assembly
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
```

**B. Macro con `LOCAL` y sus puntos de uso (`mIrAlFinCadena`)**
Lleva `LOCAL` para que MASM cree etiquetas distintas cada vez que se usa en el codigo:

```assembly
; Definicion de la macro
mIrAlFinCadena MACRO regPtr
    LOCAL CicloFin, ListoFin
CicloFin:
    cmp BYTE PTR [regPtr], 0
    je ListoFin
    inc regPtr
    jmp CicloFin
ListoFin:
ENDM

; Punto de uso 1 (en AnexarCadenaAlFinal)
AnexarCadenaAlFinal PROC USES eax esi edi
    mIrAlFinCadena edi
CopiarAlFinal:
    ...

; Punto de uso 2 y 3 (en FormatearMonedaCadena)
    mov edi, OFFSET bufSalida
    mIrAlFinCadena edi
    mov BYTE PTR [edi], '.'
    ...
    mov edi, OFFSET bufSalida
    mIrAlFinCadena edi
    mov BYTE PTR [edi], ' '
```

**C. Procedimiento que aplica `USES` (`CalcularTotalVenta`)**
Conserva `EBX` y `ECX`, mientras que `EAX` (importe final) y `EDX` (`DL` = aviso de si hubo descuento) quedan fuera de `USES` porque ahi se regresan los resultados:

```assembly
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
```

### 3. Por que se eligio macro o procedimiento y comparacion de lineas

- **Por que macro o procedimiento:** Se usaron **macros** (`mImprimir`, `mLeerCadena`, `mCopiarBloque`, `mIrAlFinCadena`, `mGuardarArchivo`) para bloques cortos de 2 a 6 instrucciones que se repetian mucho, donde hacer un `CALL` meteria trabajo extra innecesario en la pila. En cambio, se hicieron **procedimientos** para las partes que llevan ciclos, validaciones o cuentas (`ValidarFormatoCodigo`, `CalcularTotalVenta`, `RegistrarMovimientoInventario`, etc.) para no repetir esas instrucciones en el ejecutable.
- **Criterio de conteo de lineas:** Se contaron solo las **lineas efectivas de codigo fuente** en los dos archivos `.asm` (directivas, variables, macros e instrucciones), sin contar renglones en blanco ni comentarios (`;`).

| Seccion del archivo `.asm` | Unidad 2 (`main.asm` original) | Unidad 3 (`main.asm` actualizado) | Diferencia |
|---|---|---|---|
| Directivas (`INCLUDE`, `EQU`) | 3 | 3 | 0 |
| Definicion de Macros | 0 | 33 | +33 |
| Seccion `.data` | 50 | 50 | 0 |
| Seccion `.code` | 799 | 645 | -154 |
| **Total de lineas efectivas** | **852** | **731** | **-121 (-14.2%)** |

Dejaron de repetirse los `push` y `pop` manuales en cada procedimiento, la rutina duplicada para agregar texto a los archivos, el armado de renglones de movimientos, los ciclos de fin de cadena y las lecturas e impresiones en consola. Aunque el archivo `.asm` bajo **121 lineas**, MASM copia las instrucciones de cada macro en cada lugar donde se llama; por eso, el ahorro real de instrucciones al compilar viene de los procedimientos nuevos, mientras que las macros ayudan a que el codigo fuente se lea mas claro.

### 4. Tabla de pruebas actualizada

| Caso | Entrada | Resultado esperado | Resultado obtenido |
|---|---|---|---|
| Registro valido | Opcion `1` -> `LAB-101`, `Labial Mate`, `250.50` | Guarda el producto con existencia `0` en `catalogo.dat` y `catalogo.txt`. | Muestra *"Operacion realizada con exito."* y agrega `LAB-101 \| Labial Mate \| 250.50 MXN \| 0`. |
| Registro rechazado (formato / duplicado / precio) | Codigo `ab-1`, luego `LAB-101` repetido, luego `LAB-102` con precio `0.00` y `15000.00` | Rechaza formato invalido, no deja repetir codigo y pide precio entre `0.01` y `9999.99`. | Muestra los mensajes de error y pide corregir el dato sin borrar lo ya se habia escrito. |
| Busqueda (existente e inexistente) | Opcion `3` -> `XXX-999`; luego `LAB-101` | Avisa que `XXX-999` no existe y vuelve al menu; encuentra `LAB-101`. | Con `XXX-999` imprime *"Error: Codigo no encontrado."*; con `LAB-101` pasa a pedir la cantidad. |
| Entrada de mercancia (aceptada y rechazada) | Opcion `3` -> `LAB-101` -> `20`; luego otra entrada de `85` | Sube la existencia a `20` y guarda `[ENTRADA]` en `movimientos.txt`; rechaza `85` por pasar de `100`. | La existencia queda en `20`, `movimientos.txt` guarda `Cantidad actual: 20` y rechaza `85` por pasar el limite de 100. |
| Venta aceptada (menos de 3 unidades) | Opcion `4` -> `LAB-101` -> `2` | Cobra `501.00 MXN` sin descuento, baja existencia a `18` y guarda en los `.txt`. | La existencia baja a `18`; `ventas.txt` guarda `[VENTA] Codigo: LAB-101 \| Importe: 501.00 MXN`. |
| Regla adicional del negocio (mayoreo de 3 o mas unidades) | Opcion `4` -> `LAB-101` -> `4` | Importe base `1002.00 MXN`, aplica 10% (`901.80 MXN`), muestra aviso y baja existencia a `14`. | Muestra *">> AVISO: Descuento de mayoreo (10%) aplicado."*, cobra `901.80 MXN` y deja existencia en `14`. |
| Ventas rechazadas (sin stock / stock insuficiente) | Opcion `4` -> `LAB-102` (existencia `0`); luego `LAB-101` (existencia `14`) con cantidad `20` | No deja vender `LAB-102` y rechaza vender `20` piezas de `LAB-101`. | Imprime *"no tiene existencias para vender"* en `LAB-102` y *"No hay suficiente existencia"* en `LAB-101`. |
| Resumen, guardado y carga persistente | Opcion `5`, Opcion `6` (Salir), abrir de nuevo el `.exe` y Opcion `2` | Muestra `14` unidades, inventario `3507.00 MXN`, ingresos `1402.80 MXN`; al reiniciar conserva los datos. | El resumen muestra las cantidades exactas y al volver a abrir el programa carga `LAB-101` y `LAB-102` desde `catalogo.dat`. |

### 5. Instrucciones de compilacion y ejecucion

1. Abrir el proyecto (`GlamourMakeup.sln`) en **Visual Studio** con MASM activado y la libreria **Irvine32** configurada en `C:\Irvine`.
2. Revisar que la plataforma este en **x86** (32 bits).
3. Compilar con `Ctrl + Shift + B` y correr con `Ctrl + F5`.
4. Si se compila desde la consola (Developer Command Prompt for VS):

```bat
ml /c /coff /Zi /I C:\Irvine main.asm
link /SUBSYSTEM:CONSOLE /LIBPATH:C:\Irvine main.obj Irvine32.lib kernel32.lib user32.lib
main.exe
```
