[README.md](https://github.com/user-attachments/files/28673254/README.md)
# 🏨 Gestión de Alojamientos Turísticos — Práctica SQL

> Base de datos relacional para la gestión de alojamientos turísticos. Este repositorio contiene las **20 consultas SQL guiadas** desarrolladas sobre la base de datos `accommodations_tourism` en PostgreSQL.

---

## 📋 Descripción general

Este proyecto forma parte de una práctica guiada de SQL. El archivo `consultas_sql.sql` contiene las 20 consultas solicitadas, organizadas por número y categoría, y diseñadas para ejecutarse sin errores sobre **PostgreSQL 14 o superior**.

La base de datos incluye 13 tablas interrelacionadas con datos de propietarios, alojamientos, huéspedes, reservas, pagos, reseñas, habitaciones y servicios. Cada consulta está delimitada por un bloque de comentarios descriptivo con número y título.

---

## 📦 Archivos del repositorio

| Archivo | Descripción |
|---|---|
| `consultas_sql.sql` | Las 20 consultas SQL listas para ejecutar en PostgreSQL |
| `accommodation_database_restore_ORIGINAL__1_.sql` | Script de restauración completo (esquema + datos) |
| `README.md` | Este documento |

---

## 🗂️ Esquema de la base de datos

La base de datos `accommodations_tourism` contiene **13 tablas**:

### Tablas principales

```
owners                    — Propietarios de alojamientos
accommodations            — Alojamientos registrados
guests                    — Huéspedes
bookings                  — Reservas
payments                  — Pagos
reviews                   — Reseñas de huéspedes
rooms                     — Habitaciones por alojamiento
locations                 — Ubicaciones geográficas
```

### Tablas auxiliares

```
accommodation_types       — Tipos: Hotel, Hostel, Villa, etc.
accommodation_amenities   — Servicios por alojamiento (tabla pivote)
amenities                 — Catálogo de servicios (WiFi, Pool, etc.)
booking_statuses          — Estados: Pending, Confirmed, Cancelled…
booking_guests            — Huéspedes adicionales por reserva
```

### Relaciones clave

```
owners ──────────── accommodations (1:N)
accommodations ──── bookings        (1:N)
accommodations ──── rooms           (1:N)
guests ──────────── bookings        (1:N)
bookings ────────── payments        (1:N)
bookings ────────── reviews         (1:1)
locations ───────── accommodations  (1:N)
accommodation_types  accommodations (1:N)
```

---

## 📝 Las 20 consultas

| N° | Categoría | Operación | Resultado |
|---|---|---|---|
| 01 | `INSERT` | Insertar propietario | Carlos Mendoza / El Salvador ✓ |
| 02 | `INSERT` | Insertar alojamiento vinculado | Hotel Mendoza — $120/noche ✓ |
| 03 | `INSERT` | Registrar huésped y reserva | Lucía Ramírez / BK-ELSV0001 ✓ |
| 04 | `INSERT` | Registrar pago | $672.00 CreditCard Completed ✓ |
| 05 | `SELECT` | Alojamientos activos | 19 alojamientos activos ✓ |
| 06 | `SELECT` | Huéspedes por nacionalidad | 2 huéspedes italianos ✓ |
| 07 | `SELECT` | Reservas con `BETWEEN` | 17 reservas jun–jul 2025 ✓ |
| 08 | `UPDATE` | Modificar precio por noche | $354.37 → $399.99 ✓ |
| 09 | `UPDATE` | Actualizar estado de reserva | Pending → Confirmed ✓ |
| 10 | `DELETE` | Eliminar reseña con `WHERE` | review_id = 1 eliminada ✓ |
| 11 | `JOIN` | Reservas + huésped (INNER JOIN) | 100 reservas con datos de huésped ✓ |
| 12 | `JOIN` | Alojamiento completo (JOIN múltiple) | 21 alojamientos con tipo, propietario y ubicación ✓ |
| 13 | `JOIN` | Pagos + reservas combinados | 90 pagos con referencia y estado ✓ |
| 14 | `LEFT JOIN` | Alojamientos incluyendo NULLs | Todos los alojamientos con o sin reseñas ✓ |
| 15 | `LEFT JOIN` | Alojamientos sin reservas | 0 sin reservas (todos tienen al menos 1) ✓ |
| 16 | `AGG` | Total ingresos con `SUM` | Charming Stay los bajos — $14,876 ✓ |
| 17 | `AGG` | Promedio rating con `AVG` | Luxury Getaway los altos — rating 5.0 ✓ |
| 18 | `AGG` | Top 5 con `COUNT + LIMIT` | Charming Stay: 9 reservas ✓ |
| 19 | `HAVING` | Más de 3 reservas (`GROUP BY + HAVING`) | 19 alojamientos cumplen la condición ✓ |
| 20 | `Subconsulta` | Alojamiento más caro (subquery) | Panoramic Suite Ville — $597.44 MXN ✓ |

---

## ⚙️ Instalación y ejecución

### Requisitos previos

- PostgreSQL 14 o superior instalado
- Cliente psql, pgAdmin 4 o DBeaver Community

### Paso 1 — Crear la base de datos

```sql
psql -U postgres -c "CREATE DATABASE accommodations_tourism
  WITH TEMPLATE=template0
  ENCODING='UTF8'
  LOCALE_PROVIDER=libc
  LOCALE='en_US.UTF-8';"
```

### Paso 2 — Restaurar el esquema y los datos

```bash
psql -U postgres -d accommodations_tourism \
     -f accommodation_database_restore_ORIGINAL__1_.sql
```

### Paso 3 — Ejecutar las consultas

```bash
psql -U postgres -d accommodations_tourism \
     -f consultas_sql.sql
```

> **Nota:** También puede abrir `consultas_sql.sql` directamente en **pgAdmin** o **DBeaver** y ejecutar cada consulta individualmente para capturar las pantallas del entregable PDF.

---

## 🔍 Ejemplo de consultas

### Consulta 12 — JOIN múltiple: alojamiento completo

```sql
-- ============================================================
-- 12 - JOIN: Alojamiento completo
-- INNER JOIN múltiple: accommodations + types + owners + locations
-- ============================================================
SELECT
    a.accommodation_id,
    a.name                                  AS alojamiento,
    at.type_name                            AS tipo,
    o.first_name || ' ' || o.last_name     AS propietario,
    l.city                                  AS ciudad,
    l.country                               AS pais,
    a.base_price_per_night                  AS precio_noche,
    a.currency_code
FROM accommodations a
INNER JOIN accommodation_types at ON a.accommodation_type_id = at.accommodation_type_id
INNER JOIN owners o              ON a.owner_id               = o.owner_id
INNER JOIN locations l           ON a.location_id            = l.location_id
ORDER BY a.accommodation_id;
```

### Consulta 19 — GROUP BY + HAVING

```sql
-- ============================================================
-- 19 - HAVING: Más de 3 reservas
-- GROUP BY + HAVING para filtrar alojamientos con > 3 reservas
-- ============================================================
SELECT
    a.accommodation_id,
    a.name                  AS alojamiento,
    COUNT(b.booking_id)     AS total_reservas,
    SUM(b.total_amount)     AS ingresos_totales
FROM accommodations a
INNER JOIN bookings b ON a.accommodation_id = b.accommodation_id
GROUP BY a.accommodation_id, a.name
HAVING COUNT(b.booking_id) > 3
ORDER BY total_reservas DESC;
```

### Consulta 20 — Subconsulta: alojamiento más caro

```sql
-- ============================================================
-- 20 - SUBCONSULTA: Alojamiento con el precio más alto
-- ============================================================
SELECT
    accommodation_id,
    name                    AS alojamiento,
    base_price_per_night    AS precio_por_noche,
    currency_code,
    max_guests
FROM accommodations
WHERE base_price_per_night = (
    SELECT MAX(base_price_per_night)
    FROM accommodations
);
```

---

## 📊 Datos de la base de datos

| Tabla | Registros |
|---|---|
| `owners` | 20 |
| `accommodations` | 20 |
| `guests` | 100 |
| `bookings` | 100 |
| `payments` | 90 |
| `reviews` | 60 |
| `rooms` | ~100 |
| `locations` | 20 |

---

## 📤 Entregables

- [x] `consultas_sql.sql` — Archivo con las 20 consultas, separadas por comentarios, compatible con PostgreSQL 14+
- [ ] `capturas.pdf` — Una captura por consulta mostrando ejecución y resultado en pgAdmin / DBeaver / psql

---

## 🛠️ Tecnologías

![PostgreSQL](https://img.shields.io/badge/PostgreSQL-14%2B-336791?style=flat-square&logo=postgresql&logoColor=white)
![SQL](https://img.shields.io/badge/SQL-Estándar-4479A1?style=flat-square)

---

## 📄 Licencia

Proyecto académico — Práctica guiada de SQL sobre bases de datos de gestión de alojamientos turísticos.
