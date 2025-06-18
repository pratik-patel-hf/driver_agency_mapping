# Driver Agency Mapping

This project automates the process of mapping driver codes to their respective agencies using data from Snowflake and updates a Google Sheet with the results.

## Features

- Fetches driver and agency mapping data from Snowflake using a parameterized SQL query.
- Processes and cleans the data using pandas.
- Updates a Google Sheet ("Driver Agency Mapping") with the latest mapping results.

## Project Structure

```
.
├── config/
│   ├── __init__.py
│   ├── credentials.py
│   └── google_service_account.json
├── main/
│   ├── __init__.py
│   └── main.py
├── queries/
│   ├── driver_agency_mapping.sql
│   └── driver_agency_mapping_testing.sql
├── .env
├── .gitignore
├── .python-version
├── pyproject.toml
├── README.md
├── requirements.txt
├── uv.lock
```

## Setup

1. **Python Version**  
   This project requires Python 3.12 (see [.python-version](.python-version)).

2. **Install Dependencies**  
   Install all required packages using [uv](https://github.com/astral-sh/uv):
   ```sh
   uv pip install -r requirements.txt
   ```

3. **Google Service Account**  
   Place your Google service account JSON key in the `config/` directory and update the path in [`config/credentials.py`](config/credentials.py) if necessary.

4. **Snowflake Credentials**  
   The Snowflake connection uses SSO (`externalbrowser`). Make sure you have access and update credentials in [`config/credentials.py`](config/credentials.py) if needed.

## Usage

Run the main script to fetch data from Snowflake and update the Google Sheet:

```sh
python main/main.py
```

## Configuration

- **Snowflake Connection:**  
  Managed in [`config/credentials.py`](config/credentials.py) via the `get_snowflake_connection()` function.
- **Google Sheets Connection:**  
  Managed in [`config/credentials.py`](config/credentials.py) via the `get_gspread_connection()` function.

## SQL Query

The mapping logic is defined in [`queries/driver_agency_mapping.sql`](queries/driver_agency_mapping.sql). You can modify this file to adjust mapping rules or add new logic.

## Logging

The script uses Python's `logging` module to provide info and error messages during execution.

## Troubleshooting

- Ensure your Snowflake and Google credentials are correct and accessible.
- If you encounter permission errors, check your access to the Snowflake warehouse and Google Sheet.
- For debugging, review the log output in your terminal.

## License

This project is for internal use at HelloFresh and is not licensed for external distribution.

---

*For questions or issues, contact the project maintainer.*