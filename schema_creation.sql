CREATE TABLE branches (
    id      SERIAL PRIMARY KEY,
    name    VARCHAR(150) NOT NULL,
    city    VARCHAR(100) NOT NULL,
    address VARCHAR(250) NOT NULL,
    phone   VARCHAR(20)  NOT NULL,
    email   VARCHAR(150),
    CONSTRAINT uq_branches_name_city UNIQUE (name, city)
);

CREATE TABLE car_categories (
    id          SERIAL PRIMARY KEY,
    name        VARCHAR(100) NOT NULL UNIQUE,
    description VARCHAR(500),
    daily_rate  NUMERIC(10,2) NOT NULL CHECK (daily_rate > 0)
);


CREATE TABLE employees (
    id         SERIAL PRIMARY KEY,
    first_name VARCHAR(100) NOT NULL,
    last_name  VARCHAR(100) NOT NULL,
    email      VARCHAR(150) NOT NULL UNIQUE,
    phone      VARCHAR(20)  NOT NULL,
    position   VARCHAR(50)  NOT NULL CHECK (position IN ('manager','agent','mechanic','accountant')),
    branch_id  INT NOT NULL REFERENCES branches(id),
    hire_date  DATE NOT NULL DEFAULT CURRENT_DATE,
    active     BOOLEAN NOT NULL DEFAULT TRUE
);


CREATE TABLE clients (
    id                    SERIAL PRIMARY KEY,
    first_name            VARCHAR(100) NOT NULL,
    last_name             VARCHAR(100) NOT NULL,
    email                 VARCHAR(150) NOT NULL UNIQUE,
    phone                 VARCHAR(20)  NOT NULL UNIQUE,
    driver_license_number VARCHAR(30)  NOT NULL UNIQUE,
    birth_date            DATE NOT NULL,
    registration_date     TIMESTAMP NOT NULL DEFAULT now(),
    CONSTRAINT chk_clients_adult CHECK (birth_date <= CURRENT_DATE - INTERVAL '18 years')
);


CREATE TABLE cars (
    id            SERIAL PRIMARY KEY,
    license_plate VARCHAR(15) NOT NULL UNIQUE,
    vin           CHAR(17)    NOT NULL UNIQUE,
    make          VARCHAR(60) NOT NULL,
    model         VARCHAR(60) NOT NULL,
    year          INT NOT NULL CHECK (year BETWEEN 1980 AND date_part('year', CURRENT_DATE)::INT + 1),
    category_id   INT NOT NULL REFERENCES car_categories(id),
    branch_id     INT NOT NULL REFERENCES branches(id),
    color         VARCHAR(40),
    mileage       INT NOT NULL DEFAULT 0 CHECK (mileage >= 0),
    status        VARCHAR(20) NOT NULL CHECK (status IN ('available','rented','maintenance','retired')),
    created_at    TIMESTAMP NOT NULL DEFAULT now()
);


CREATE TABLE car_insurance (
    id              SERIAL PRIMARY KEY,
    car_id          INT NOT NULL UNIQUE REFERENCES cars(id),
    policy_number   VARCHAR(50) NOT NULL UNIQUE,
    insurer_name    VARCHAR(150) NOT NULL,
    start_date      DATE NOT NULL,
    end_date        DATE NOT NULL,
    coverage_amount NUMERIC(12,2) NOT NULL CHECK (coverage_amount > 0),
    CONSTRAINT chk_insurance_dates CHECK (end_date > start_date)
);

CREATE TABLE additional_services (
    id          SERIAL PRIMARY KEY,
    name        VARCHAR(100) NOT NULL UNIQUE,
    description VARCHAR(300),
    price       NUMERIC(10,2) NOT NULL CHECK (price >= 0)
);


CREATE TABLE rentals (
    id                  SERIAL PRIMARY KEY,
    client_id           INT NOT NULL REFERENCES clients(id),
    car_id              INT NOT NULL REFERENCES cars(id),
    employee_id         INT NOT NULL REFERENCES employees(id),
    pickup_branch_id    INT NOT NULL REFERENCES branches(id),
    return_branch_id    INT NOT NULL REFERENCES branches(id),
    start_date          DATE NOT NULL,
    planned_end_date    DATE NOT NULL,
    actual_return_date  DATE,
    daily_rate_snapshot NUMERIC(10,2),
    total_price         NUMERIC(12,2),
    status              VARCHAR(20) NOT NULL CHECK (status IN ('reserved','active','completed','cancelled')),
    created_at          TIMESTAMP NOT NULL DEFAULT now(),
    CONSTRAINT chk_rentals_dates  CHECK (planned_end_date > start_date),
    CONSTRAINT chk_rentals_return CHECK (actual_return_date >= start_date)
);


CREATE TABLE payments (
    id             SERIAL PRIMARY KEY,
    rental_id      INT NOT NULL REFERENCES rentals(id),
    amount         NUMERIC(10,2) NOT NULL CHECK (amount > 0),
    payment_date   TIMESTAMP NOT NULL DEFAULT now(),
    payment_method VARCHAR(20) NOT NULL CHECK (payment_method IN ('cash','card','online')),
    payment_type   VARCHAR(20) NOT NULL CHECK (payment_type IN ('deposit','final','penalty'))
);


CREATE TABLE rental_services (
    rental_services_id SERIAL PRIMARY KEY,
    rental_id  INT NOT NULL REFERENCES rentals(id),
    service_id INT NOT NULL REFERENCES additional_services(id),
    quantity   INT NOT NULL DEFAULT 1 CHECK (quantity > 0)
);

CREATE TABLE maintenance_records (
    id               SERIAL PRIMARY KEY,
    car_id           INT NOT NULL REFERENCES cars(id),
    service_date     DATE NOT NULL DEFAULT CURRENT_DATE,
    description      VARCHAR(500) NOT NULL,
    cost             NUMERIC(10,2) NOT NULL CHECK (cost >= 0),
    odometer_reading INT NOT NULL CHECK (odometer_reading >= 0)
);
