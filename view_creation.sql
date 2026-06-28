CREATE OR REPLACE VIEW v_active_rentals AS
SELECT
    r.id                                                            AS rental_id,
    c.first_name || ' ' || c.last_name                              AS client_name,
    c.phone                                                          AS client_phone,
    car.make || ' ' || car.model || ' (' || car.license_plate || ')' AS car,
    cat.name                                                         AS category,
    pb.name                                                          AS pickup_branch,
    rb.name                                                          AS return_branch,
    r.start_date,
    r.planned_end_date,
    r.actual_return_date,
    (r.planned_end_date - r.start_date)                              AS planned_days,
    r.daily_rate_snapshot,
    r.total_price,
    r.status
FROM rentals r
JOIN clients        c   ON c.id = r.client_id
JOIN cars           car ON car.id = r.car_id
JOIN car_categories cat ON cat.id = car.category_id
JOIN branches        pb ON pb.id = r.pickup_branch_id
JOIN branches        rb ON rb.id = r.return_branch_id
WHERE r.status IN ('reserved', 'active');
