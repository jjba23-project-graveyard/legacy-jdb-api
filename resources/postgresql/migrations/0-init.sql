DROP TABLE IF EXISTS clients;
CREATE TABLE clients(
identifier UUID NOT NULL,
display_name VARCHAR(1024) NOT NULL,
phone_number VARCHAR(512) NOT NULL,
email_address VARCHAR(1024) NOT NULL,
password_hash VARCHAR NOT NULL,
password_reset_token VARCHAR NULL,
created_at TIMESTAMPTZ NOT NULL,
updated_at TIMESTAMPTZ NULL,
UNIQUE(identifier),
PRIMARY KEY (identifier)
);

DROP TABLE IF EXISTS managers;
CREATE TABLE managers(
identifier UUID NOT NULL,
display_name VARCHAR(1024) NOT NULL,
phone_number VARCHAR(512) NOT NULL,
email_address VARCHAR NOT NULL,
password_hash VARCHAR NOT NULL,
password_reset_token VARCHAR NULL,
created_at TIMESTAMPTZ NOT NULL,
updated_at TIMESTAMPTZ NULL,
UNIQUE(identifier),
PRIMARY KEY (identifier)
);

DROP TABLE IF EXISTS activities;
CREATE TABLE activities(
identifier UUID NOT NULL,
display_name VARCHAR(1024) NOT NULL,
description VARCHAR NOT NULL,
timeslot_gen_mode VARCHAR NOT NULL,
unit_cost VARCHAR NOT NULL,
created_by UUID NOT NULL REFERENCES managers(identifier),
created_at TIMESTAMPTZ NOT NULL,
updated_at TIMESTAMPTZ NULL,
UNIQUE(identifier),
PRIMARY KEY (identifier)
);

DROP TABLE IF EXISTS requests;
CREATE TABLE requests(
identifier UUID NOT NULL,
created_by UUID NOT NULL REFERENCES clients(identifier),
activity_identifier UUID NOT NULL REFERENCES activities(identifier),
slot_start TIMESTAMPTZ NOT NULL,
slot_end TIMESTAMPTZ NOT NULL,
request_amount INT NOT NULL,
created_at TIMESTAMPTZ NOT NULL,
updated_at TIMESTAMPTZ NULL,
UNIQUE(identifier),
PRIMARY KEY (identifier)
);

DROP TABLE IF EXISTS payments;
CREATE TABLE payments(
identifier UUID NOT NULL,
request_identifier UUID NOT NULL REFERENCES requests(identifier),
payment_amount DECIMAL(12,4) NOT NULL,
currency VARCHAR(100) NOT NULL,
payment_status VARCHAR NOT NULL,
created_at TIMESTAMPTZ NOT NULL,
updated_at TIMESTAMPTZ NULL,
UNIQUE(identifier),
PRIMARY KEY (identifier)
);

DROP TABLE IF EXISTS reservations;
CREATE TABLE reservations(
identifier UUID NOT NULL,
client_identifier UUID NOT NULL REFERENCES clients(identifier),
payment_identifier UUID NULL REFERENCES payments(identifier),
activity_identifier UUID NOT NULL REFERENCES activities(identifier),
slot_start TIMESTAMPTZ NOT NULL,
slot_end TIMESTAMPTZ NOT NULL,
created_at TIMESTAMPTZ NOT NULL,
UNIQUE(identifier),
UNIQUE(client_identifier, payment_identifier, activity_identifier),
PRIMARY KEY (identifier)
);

DROP TABLE IF EXISTS offline_ranges;
CREATE TABLE offline_ranges (
identifier UUID NOT NULL,
activity_identifier UUID NOT NULL REFERENCES activities(identifier),
slot_start TIMESTAMPTZ NOT NULL,
slot_end TIMESTAMPTZ NOT NULL,
created_by UUID NOT NULL REFERENCES managers(identifier),
created_at TIMESTAMPTZ NOT NULL,
updated_at TIMESTAMPTZ NULL,
UNIQUE(identifier),
PRIMARY KEY (identifier)
);

DROP TABLE IF EXISTS activities_managers;
CREATE TABLE activities_managers (
identifier UUID NOT NULL,
activity_identifier UUID NOT NULL REFERENCES activities(identifier),
manager_identifier UUID NOT NULL REFERENCES managers(identifier),
created_at TIMESTAMPTZ NOT NULL,
UNIQUE(identifier),
UNIQUE(activity_identifier, manager_identifier),
PRIMARY KEY (identifier)
);
