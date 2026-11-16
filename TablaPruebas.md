# Tabla de pruebas (Unidad 3)

Con datos de prueba: `LAB-101` $189.50 x25, `RIM-202` $145.00 x40, `BAS-303` $320.99 x12, `SOM-404` $275.00 x2.

| # | Prueba | Entrada | Resultado esperado | Obtenido |
|---|---|---|---|---|
| 1 | Carga inicial | Iniciar con `catalogo.dat` en la carpeta del proyecto | Carga los 4 productos desde binario; Opcion 2 muestra los 4 registros | Opcion 2 despliega `LAB-101`, `RIM-202`, `BAS-303` y `SOM-404` con sus precios y existencias |
| 2 | Alta valida | Opcion `1` -> `PER-505` / `Delineador Negro` / `99.90` | "Operacion realizada con exito."; aparece con 99.90 MXN y existencia 0 | Registrado correctamente y guardado en `catalogo.dat` y `catalogo.txt` |
| 3 | Alta duplicada | Opcion `1` -> `LAB-101` | "Error: Codigo duplicado. Ya existe en el catalogo." | Rechazado y vuelve a pedir el codigo |
| 4 | Codigo invalido | `lab-101`, `LAB101`, `LA1-123`, vacio | "Error: Dato invalido o formato incorrecto." | Todos rechazados por `ValidarFormatoCodigo` |
| 5 | Nombre invalido | Enter vacio en nombre | Vuelve a pedir el nombre sin avanzar al precio | Repite la lectura hasta que se escriba al menos 1 caracter |
| 6 | Precio entero | `185` | Se guarda como `185.00 MXN` (18500 centavos) | Mostrado en consulta como `185.00 MXN` |
| 7 | Precio con decimales | `185.50`, `12.05`, `12.5` | `185.50`, `12.05`, `12.50 MXN` | Formateados correctamente con 2 decimales |
| 8 | Precio invalido | `12.555`, `12.`, `.50`, `$12`, `1,200`, `abc`, vacio | "Error: Dato invalido o formato incorrecto." | Rechazados por `ParsePrecioCentavos` |
| 9 | Precio fuera de rango | `0`, `0.00`, `10000` | Rechazado por estar fuera de 0.01 - 9999.99 | Rechazado y pide corregir unicamente el precio |
| 10 | Precio limite | `0.01` y `9999.99` | Aceptados | Guardados sin error |
| 11 | Inventario lleno | Dar de alta hasta 10 productos y elegir Opcion 1 | "Error: Inventario lleno (Max 10)." | Bloquea el registro 11 y regresa al menu |
| 12 | Buscar existente (en entrada/venta) | Opcion `3` -> `RIM-202` | Localiza `RIM-202` y pasa a pedir cantidad | `SolicitarYBuscarProducto` lo encuentra y pide cantidad |
| 13 | Buscar inexistente | Opcion `3` -> `ZZZ-999` | "Error: Codigo no encontrado." | Muestra el error y regresa al menu |
| 14 | Entrada valida | Opcion `3` -> `LAB-101`, cantidad `10` | Existencia sube de 25 a 35 y graba en `movimientos.txt` | Existencia en 35 y `[ENTRADA]` registrada en `movimientos.txt` |
| 15 | Entrada excesiva | Opcion `3` -> `LAB-101`, cantidad `76` (35+76 > 100) | "Error: La cantidad ingresada supera el limite maximo permitida (Max 100)." | Rechazada; existencia sigue en 35 |
| 16 | Entrada invalida | Cantidad `0`, `-5`, `abc`, vacio | "Error: Dato invalido o formato incorrecto." | Rechazadas por `CapturarCantidadPositiva` |
| 17 | Venta sin descuento | Opcion `4` -> `LAB-101`, cantidad `1` | Base 189.50, final 189.50; existencia baja en 1; ingresos +189.50 | Cobrado `189.50 MXN` sin descuento y guardado en `ventas.txt` |
| 18 | Venta con descuento (>= 3) | Opcion `4` -> `RIM-202`, cantidad `3` | Base 435.00, descuento 10%, final `391.50 MXN`; existencia 37 | Muestra aviso de descuento de mayoreo y cobra `391.50 MXN` |
| 19 | Descuento con fraccion | Opcion `4` -> `BAS-303`, cantidad `3` | Base 962.97 * 90 / 100 = `866.67 MXN` (centavos truncados) | Cobrado `866.67 MXN` y existencia baja a 9 |
| 20 | Venta rechazada (stock insuficiente) | Opcion `4` -> `SOM-404`, cantidad `3` (hay 2) | "Error: No hay suficiente existencia en inventario para esta venta." | Venta bloqueada; existencia sigue en 2 |
| 21 | Venta rechazada (sin stock) | Opcion `4` -> `PER-505` (existencia 0) | "Error: El producto no tiene existencias para vender." | Regresa directo al menu sin pedir cantidad |
| 22 | Venta cantidad invalida | Cantidad `0` o `abc` | "Error: Dato invalido o formato incorrecto." | Rechazada y vuelve a pedir la cantidad |
| 23 | Resumen | Opcion `5` | Muestra unidades totales disponibles, valor del inventario e ingresos de la sesion | Despliega los tres totales calculados correctamente |
| 24 | Persistencia al salir y reabrir | Opcion `6` (Salir), volver a ejecutar `.exe` y elegir Opcion `2` | Conserva todos los cambios de productos y existencias; ingresos inician en 0.00 MXN | Carga `catalogo.dat` automaticamente con las existencias actualizadas |
| 25 | Archivo ausente | Borrar `catalogo.dat` y ejecutar `.exe` | Inicia sin error con catalogo vacio | Menu abre normal y Opcion 2 no muestra productos |
| 26 | Opcion de menu invalida | `9`, `ab`, vacio | "Error: Dato invalido o formato incorrecto." y vuelve al menu | Muestra el error y repite el menu |
