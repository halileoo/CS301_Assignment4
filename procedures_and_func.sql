CREATE OR REPLACE FUNCTION fn_calculate_rental_days(p_start DATE, p_end DATE)
RETURNS INT
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN GREATEST(1, (p_end - p_start));
END;
$$;

CREATE OR REPLACE FUNCTION fn_calculate_total_price(p_rental_id BIGINT, p_end_date DATE)
RETURNS NUMERIC
LANGUAGE plpgsql
AS $$
DECLARE
    v_start         DATE;
    v_rate          NUMERIC(10,2);
    v_services_cost NUMERIC(10,2);
    v_days          INT;
BEGIN
    SELECT start_date, daily_rate_snapshot
      INTO v_start, v_rate
      FROM rentals
     WHERE id = p_rental_id;

    IF v_start IS NULL THEN
        RAISE EXCEPTION 'Rental % not found', p_rental_id;
    END IF;

    v_days = fn_calculate_rental_days(v_start, p_end_date);

    SELECT COALESCE(SUM(s.price * rs.quantity), 0)
      INTO v_services_cost
      FROM rental_services rs
      JOIN additional_services s ON s.id = rs.service_id
     WHERE rs.rental_id = p_rental_id;

    RETURN v_rate * v_days + v_services_cost;
END;
$$;

CREATE OR REPLACE PROCEDURE sp_close_rental(
    p_rental_id      BIGINT,
    p_actual_return  DATE,
    p_payment_method VARCHAR(20)
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_car_id UUID;
    v_status VARCHAR(20);
    v_total  NUMERIC(12,2);
BEGIN
    SELECT car_id, status
      INTO v_car_id, v_status
      FROM rentals
     WHERE id = p_rental_id
     FOR UPDATE;

    IF v_car_id IS NULL THEN
        RAISE EXCEPTION 'Rental % does not exist', p_rental_id;
    END IF;

    IF v_status NOT IN ('reserved', 'active') THEN
        RAISE EXCEPTION 'Rental % is already % and cannot be closed', p_rental_id, v_status;
    END IF;

    v_total = fn_calculate_total_price(p_rental_id, p_actual_return);

    UPDATE rentals
       SET actual_return_date = p_actual_return,
           total_price        = v_total,
           status             = 'completed'
     WHERE id = p_rental_id;

    INSERT INTO payments (rental_id, amount, payment_method, payment_type)
    VALUES (p_rental_id, v_total, p_payment_method, 'final');
END;
$$;
