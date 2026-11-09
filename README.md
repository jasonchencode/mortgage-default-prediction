# Mortgage Credit Risk Prediction and Automated Loan Decisioning

## Python environment

Create the local virtual environment (Python 3.14):

```sh
python3 -m venv .venv
```

Activate it on macOS/Linux:

```sh
source .venv/bin/activate
```

In your IDE, select `.venv/bin/python` as the Python interpreter.
Run `deactivate` to leave the environment.

## PostgreSQL credentials

Store your local connection settings in `.env`. Fill in `PGUSER` and
`PGPASSWORD`, and adjust `PGHOST`, `PGPORT`, and `PGDATABASE` to match your
database. The database name defaults to `mortgage_default`.

`.env` is excluded from Git. Keep real credentials there; `.env.example` is
the template for sharing the required settings. On a fresh checkout, run:

```sh
cp .env.example .env
```

Creating this file does not create the database or automatically load the
settings into Python; your connection script will need to load them.
