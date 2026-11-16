# Proyecto U3 - Sistema de Ventas e Inventario (Glamour Makeup Sinaloa)

- **Materia:** Lenguajes de Interfaz - Unidad 3
- **Alumna:** Natalia Lopez Ibarra y Frida Sofia Vega Vazquez
- **Horario:** 9am-10am y 8am-9am
- **Docente:** Dr. Jose Luis Medina Jimenez

Programa de consola en ensamblador x86 de 32 bits (MASM) con la libreria Irvine32. Administra el inventario y las ventas de una tienda de maquillaje: hasta 10 productos (maximo 100 unidades por articulo), importes en centavos enteros y salida en MXN. Regla adicional: 10% de descuento en ventas de 3 o mas unidades (mayoreo).

En esta version de la Unidad 3 se limpio y reorganizo el codigo fuente dividiendo las tareas repetidas en **procedimientos modulares**, agregando **macros parametrizadas** (con `LOCAL` para etiquetas internas) y aplicando la directiva **`USES`** para conservar registros y mantener equilibrada la pila.

## Archivos
| Archivo | Descripcion |
|---|---|
| `GlamourMakeup_U3.asm` | Programa completo actualizado (procedimientos, macros y `USES`) |
| `GlamourMakeup.sln` / `.vcxproj` | Archivos del proyecto de Visual Studio |
| `catalogo.dat` | Archivo binario de respaldo para conservar el inventario entre ejecuciones |
| `catalogo.txt` | Reporte de prueba en texto plano con los productos registrados |
| `movimientos.txt` | Bitacora de entradas y salidas de mercancia |
| `ventas.txt` | Registro de ventas realizadas con su importe final |
| `Informe.md` | Negocio, regla adicional, memoria, formatos, tabla de pruebas y seccion **Version de la Unidad 3** |

## Menu
1. Registrar Producto  2. Consultar Inventario  3. Recibir Mercancia  4. Vender Producto  5. Mostrar Resumen  6. Salir

## Compilacion (Visual Studio 2022 + plantilla Irvine32 de la clase)
1. Abre la solucion `GlamourMakeup.sln` (o usa la plantilla Irvine32 de clase agregando `GlamourMakeup_U3.asm`).
2. Verifica que la plataforma este en **x86 (Win32)**, Debug.
3. Compila y ejecuta con **Ctrl + F5**.
4. Si deseas precargar datos de prueba, coloca `catalogo.dat` en la **carpeta del proyecto** (donde esta el `.vcxproj`, que es el directorio de trabajo de VS). Al registrar, recibir o vender mercancia, el sistema crea y actualiza automaticamente `catalogo.dat`, `catalogo.txt`, `movimientos.txt` y `ventas.txt`.

## Formato de los archivos de respaldo y reporte
- **`catalogo.dat`:** volcado binario de 440 bytes (10 registros de 44 bytes) que se carga automaticamente al iniciar el programa.
- **`catalogo.txt`:** texto plano legible en Bloc de notas con formato `CODIGO | NOMBRE | PRECIO MXN | EXISTENCIA`:
```text
LAB-101 | Labial Mate Rojo | 189.50 MXN | 25
RIM-202 | Rimel Waterproof | 145.00 MXN | 40
```

## Pruebas rapidas
- **Archivo ausente:** borra o renombra `catalogo.dat` y ejecuta; el programa inicia con el catalogo vacio sin marcar error.
- **Regla de mayoreo (10% descuento):** registra un producto, ingresa al menos 5 unidades en la opcion 3 y vende 3 o mas piezas en la opcion 4 para comprobar el aviso del 10% y el descuento aplicado en `ventas.txt`.
