# Proyecto U3 - Sistema de Ventas e Inventario (Glamour Makeup Sinaloa)

- **Materia:** Lenguajes de Interfaz - Unidad 3
- **Alumnas:** Natalia Lopez Ibarra y Frida Sofia Vega Vazquez
- **Horario:** 9am-10am y 8am-9am
- **Docente:** Dr. Jose Luis Medina Jimenez

Programa de consola en ensamblador x86 de 32 bits (MASM) con la libreria Irvine32. Administra el inventario y las ventas de una tienda de maquillaje: hasta 10 productos (maximo 100 unidades por articulo), importes en centavos enteros y salida en MXN. Regla adicional: 10% de descuento en ventas de 3 o mas unidades (mayoreo).

Para esta entrega de la Unidad 3 se reorganizo el codigo fuente en `main.asm` extrayendo tareas repetidas en **procedimientos**, sustituyendo secuencias cortas por **macros** (usando `LOCAL` para etiquetas internas) y aplicando **`USES`** para equilibrar la pila.

## Archivos
| Archivo | Descripcion |
|---|---|
| `main.asm` | Codigo fuente completo refactorizado (procedimientos, macros y `USES`) |
| `GlamourMakeup.sln` / `.vcxproj` | Archivos del proyecto de Visual Studio |
| `catalogo.dat` | Archivo binario de respaldo para conservar el inventario entre ejecuciones |
| `catalogo.txt` | Reporte de inventario en texto plano legible en Bloc de notas |
| `movimientos.txt` | Bitacora de entradas y salidas de mercancia |
| `ventas.txt` | Registro de ventas realizadas con su importe final |
| `Informe.md` | Negocio, regla adicional, memoria, formatos, decisiones y seccion **Version de la Unidad 3** |
| `TablaPruebas.md` | Tabla de pruebas actualizada (Entrada / Resultado esperado / Obtenido) |

## Menu
1. Registrar Producto  2. Consultar Inventario  3. Recibir Mercancia  4. Vender Producto  5. Mostrar Resumen  6. Salir

## Compilacion (Visual Studio 2022 + plantilla Irvine32 de la clase)
1. Abre la solucion `GlamourMakeup.sln` (o usa la plantilla Irvine32 de clase sustituyendo el `.asm` por `main.asm`).
2. Plataforma **x86 (Win32)**, Debug.
3. Compila y ejecuta (`Ctrl + F5`).
4. Si deseas iniciar con datos precargados, coloca `catalogo.dat` en la **carpeta del proyecto** (donde esta el `.vcxproj`). Al registrar, recibir o vender mercancia, el sistema crea y actualiza automaticamente `catalogo.dat`, `catalogo.txt`, `movimientos.txt` y `ventas.txt`.

## Formato de los archivos de reporte
- **`catalogo.dat`:** volcado binario de 440 bytes que se carga automaticamente al iniciar el programa.
- **`catalogo.txt`:** texto plano con formato `CODIGO | NOMBRE | PRECIO MXN | EXISTENCIA`:
```text
LAB-101 | Labial Mate Rojo | 189.50 MXN | 25
RIM-202 | Rimel Waterproof | 145.00 MXN | 40
```

## Pruebas rapidas
- **Archivo ausente:** borra o renombra `catalogo.dat` y ejecuta; el programa arranca con el catalogo vacio sin marcar error.
- **Regla de mayoreo (10% descuento):** registra un producto, ingresa al menos 5 unidades en la opcion 3 y vende 3 o mas piezas en la opcion 4 para comprobar el aviso del 10% y el descuento aplicado en `ventas.txt`.
