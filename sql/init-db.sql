CREATE TABLE IF NOT EXISTS fred_cpi_descriptions (
    index TEXT,
    description TEXT
);

COPY fred_cpi_descriptions FROM '/data/fred_cpi_descriptions.csv' WITH (FORMAT csv, HEADER true);

CREATE TABLE IF NOT EXISTS fred_cpi_1956_2023 (
    date DATE,
    index TEXT,
    value DEC(5,1)
);

COPY fred_cpi_1956_2023 FROM '/data/fred_cpi_1956_2023.csv' WITH (FORMAT csv, HEADER true);