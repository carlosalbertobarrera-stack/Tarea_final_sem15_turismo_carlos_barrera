-- =============================================================
-- PRÁCTICA: Base de Datos de Gestión de Alojamientos Turísticos
-- Base de datos: accommodations_tourism (PostgreSQL)
-- Archivo: consultas_sql.sql
-- Descripción: 20 consultas SQL guiadas (INSERT, SELECT, UPDATE,
--              DELETE, JOIN, LEFT JOIN, AGG, HAVING, Subconsulta)
-- =============================================================

-- =============================================================
-- 01 - INSERT: Insertar propietario
-- Agregar un nuevo propietario a la tabla owners
-- =============================================================
INSERT INTO owners (
    first_name, last_name, company_name, email, phone,
    tax_id, address_line1, city, country, created_at, updated_at
)
VALUES (
    'Carlos', 'Mendoza', 'Hospedajes Mendoza S.A.',
    'cmendoza@example.com', '+503-2222-1234',
    'SV-12345678', 'Calle Principal 45', 'San Salvador', 'El Salvador',
    CURRENT_TIMESTAMP, CURRENT_TIMESTAMP
);


-- =============================================================
-- 02 - INSERT: Insertar alojamiento
-- Crear alojamiento vinculado al propietario recién insertado
-- (asume que el nuevo owner_id es el último generado)
-- =============================================================
INSERT INTO accommodations (
    owner_id, accommodation_type_id, location_id, name, description,
    max_guests, bedroom_count, bathroom_count,
    base_price_per_night, currency_code,
    check_in_time, check_out_time, is_active,
    created_at, updated_at
)
VALUES (
    (SELECT owner_id FROM owners WHERE email = 'cmendoza@example.com'),
    1, 1,
    'Hotel Mendoza El Salvador',
    'Hotel boutique con vista al volcán',
    8, 4, 3, 120.00, 'USD',
    '14:00:00', '12:00:00', TRUE,
    CURRENT_TIMESTAMP, CURRENT_TIMESTAMP
);


-- =============================================================
-- 03 - INSERT: Huésped y reserva
-- Registrar un nuevo huésped y su reserva
-- =============================================================

-- 03a: Insertar huésped
INSERT INTO guests (
    first_name, last_name, email, phone,
    date_of_birth, nationality, created_at, updated_at
)
VALUES (
    'Lucía', 'Ramírez', 'lucia.ramirez@example.com', '+503-7777-8888',
    '1990-03-15', 'El Salvador',
    CURRENT_TIMESTAMP, CURRENT_TIMESTAMP
);

-- 03b: Registrar reserva para el nuevo huésped
INSERT INTO bookings (
    guest_id, accommodation_id, booking_status_id,
    check_in_date, check_out_date,
    adult_count, child_count,
    subtotal_amount, tax_amount, discount_amount, total_amount,
    booking_reference, booked_at, created_at, updated_at
)
VALUES (
    (SELECT guest_id FROM guests WHERE email = 'lucia.ramirez@example.com'),
    (SELECT accommodation_id FROM accommodations WHERE name = 'Hotel Mendoza El Salvador'),
    2,
    '2026-07-10', '2026-07-15',
    2, 0,
    600.00, 72.00, 0.00, 672.00,
    'BK-ELSV0001',
    CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP
);


-- =============================================================
-- 04 - INSERT: Insertar pago
-- Registrar el pago de la reserva recién creada
-- =============================================================
INSERT INTO payments (
    booking_id, payment_date, amount,
    payment_method, payment_status,
    transaction_reference, created_at
)
VALUES (
    (SELECT booking_id FROM bookings WHERE booking_reference = 'BK-ELSV0001'),
    CURRENT_TIMESTAMP, 672.00,
    'CreditCard', 'Completed',
    'TXN-ELSV-2026-0001',
    CURRENT_TIMESTAMP
);


-- =============================================================
-- 05 - SELECT: Alojamientos activos
-- Filtrar todos los alojamientos con is_active = TRUE
-- =============================================================
SELECT
    accommodation_id,
    name,
    base_price_per_night,
    currency_code,
    max_guests,
    bedroom_count,
    is_active
FROM accommodations
WHERE is_active = TRUE
ORDER BY accommodation_id;


-- =============================================================
-- 06 - SELECT: Huéspedes por país
-- Filtrar huéspedes por nacionalidad italiana
-- =============================================================
SELECT
    guest_id,
    first_name,
    last_name,
    email,
    nationality
FROM guests
WHERE nationality IN ('Italia', 'Italien', 'Italy')
ORDER BY last_name;


-- =============================================================
-- 07 - SELECT: Reservas por fechas
-- Uso de BETWEEN para filtrar check-in en un rango de fechas
-- =============================================================
SELECT
    booking_id,
    guest_id,
    accommodation_id,
    check_in_date,
    check_out_date,
    total_amount,
    booking_reference
FROM bookings
WHERE check_in_date BETWEEN '2025-06-01' AND '2025-07-31'
ORDER BY check_in_date;


-- =============================================================
-- 08 - UPDATE: Actualizar precio
-- Modificar el precio por noche del alojamiento con id = 1
-- =============================================================
UPDATE accommodations
SET
    base_price_per_night = 399.99,
    updated_at = CURRENT_TIMESTAMP
WHERE accommodation_id = 1;


-- =============================================================
-- 09 - UPDATE: Estado de reserva
-- Actualizar el estado de la reserva con id = 5 a Confirmado
-- =============================================================
UPDATE bookings
SET
    booking_status_id = 2,   -- 2 = Confirmed
    updated_at = CURRENT_TIMESTAMP
WHERE booking_id = 5;


-- =============================================================
-- 10 - DELETE: Eliminar reseña
-- Eliminar la reseña con review_id = 1
-- =============================================================
DELETE FROM reviews
WHERE review_id = 1;


-- =============================================================
-- 11 - JOIN: Reservas + huésped
-- INNER JOIN entre bookings y guests
-- =============================================================
SELECT
    b.booking_id,
    b.booking_reference,
    g.first_name || ' ' || g.last_name AS huesped,
    g.email,
    g.nationality,
    b.check_in_date,
    b.check_out_date,
    b.total_amount
FROM bookings b
INNER JOIN guests g ON b.guest_id = g.guest_id
ORDER BY b.booking_id
LIMIT 15;


-- =============================================================
-- 12 - JOIN: Alojamiento completo
-- INNER JOIN múltiple: accommodations + types + owners + locations
-- =============================================================
SELECT
    a.accommodation_id,
    a.name                                     AS alojamiento,
    at.type_name                               AS tipo,
    o.first_name || ' ' || o.last_name        AS propietario,
    l.city                                     AS ciudad,
    l.country                                  AS pais,
    a.base_price_per_night                     AS precio_noche,
    a.currency_code
FROM accommodations a
INNER JOIN accommodation_types at ON a.accommodation_type_id = at.accommodation_type_id
INNER JOIN owners o              ON a.owner_id               = o.owner_id
INNER JOIN locations l           ON a.location_id            = l.location_id
ORDER BY a.accommodation_id;


-- =============================================================
-- 13 - JOIN: Pagos + reservas
-- JOIN combinado entre payments y bookings
-- =============================================================
SELECT
    p.payment_id,
    p.booking_id,
    b.booking_reference,
    p.amount,
    p.payment_method,
    p.payment_status,
    b.check_in_date,
    b.total_amount AS total_reserva
FROM payments p
INNER JOIN bookings b ON p.booking_id = b.booking_id
ORDER BY p.payment_id
LIMIT 15;


-- =============================================================
-- 14 - LEFT JOIN: Sin reseñas (incluye NULLs)
-- Todos los alojamientos, incluyendo los que no tienen reseñas
-- =============================================================
SELECT
    a.accommodation_id,
    a.name         AS alojamiento,
    r.review_id,
    r.rating,
    r.review_title
FROM accommodations a
LEFT JOIN reviews r ON a.accommodation_id = r.accommodation_id
ORDER BY a.accommodation_id;


-- =============================================================
-- 15 - LEFT JOIN: Sin reservas
-- Alojamientos que no tienen ninguna reserva (filtrar NULL)
-- =============================================================
SELECT
    a.accommodation_id,
    a.name                  AS alojamiento,
    a.base_price_per_night,
    a.is_active
FROM accommodations a
LEFT JOIN bookings b ON a.accommodation_id = b.accommodation_id
WHERE b.booking_id IS NULL
ORDER BY a.accommodation_id;


-- =============================================================
-- 16 - AGG: Total ingresos
-- SUM de total_amount agrupado por alojamiento
-- =============================================================
SELECT
    a.accommodation_id,
    a.name                   AS alojamiento,
    COUNT(b.booking_id)      AS total_reservas,
    SUM(b.total_amount)      AS ingresos_totales,
    a.currency_code
FROM accommodations a
INNER JOIN bookings b ON a.accommodation_id = b.accommodation_id
GROUP BY a.accommodation_id, a.name, a.currency_code
ORDER BY ingresos_totales DESC;


-- =============================================================
-- 17 - AGG: Promedio rating
-- AVG del rating agrupado por alojamiento
-- =============================================================
SELECT
    a.accommodation_id,
    a.name                          AS alojamiento,
    COUNT(r.review_id)              AS total_resenas,
    ROUND(AVG(r.rating)::NUMERIC, 2) AS promedio_rating,
    MIN(r.rating)                   AS rating_min,
    MAX(r.rating)                   AS rating_max
FROM accommodations a
INNER JOIN reviews r ON a.accommodation_id = r.accommodation_id
GROUP BY a.accommodation_id, a.name
ORDER BY promedio_rating DESC;


-- =============================================================
-- 18 - AGG: Top alojamientos
-- COUNT de reservas por alojamiento + LIMIT para obtener el top 5
-- =============================================================
SELECT
    a.accommodation_id,
    a.name              AS alojamiento,
    COUNT(b.booking_id) AS total_reservas
FROM accommodations a
INNER JOIN bookings b ON a.accommodation_id = b.accommodation_id
GROUP BY a.accommodation_id, a.name
ORDER BY total_reservas DESC
LIMIT 5;


-- =============================================================
-- 19 - HAVING: Más de 3 reservas
-- GROUP BY + HAVING para filtrar alojamientos con más de 3 reservas
-- =============================================================
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


-- =============================================================
-- 20 - Subconsulta: Alojamiento más caro
-- Subquery para encontrar el alojamiento con mayor precio por noche
-- =============================================================
SELECT
    accommodation_id,
    name                    AS alojamiento,
    base_price_per_night    AS precio_por_noche,
    currency_code,
    max_guests,
    bedroom_count
FROM accommodations
WHERE base_price_per_night = (
    SELECT MAX(base_price_per_night)
    FROM accommodations
);

-- =============================================================
-- FIN DEL ARCHIVO - 20 consultas completadas
-- =============================================================
