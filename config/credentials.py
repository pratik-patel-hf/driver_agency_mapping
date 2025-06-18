import os
import snowflake.connector
import gspread


def get_snowflake_connection():
    # Create a connection object to our Snowflake instance
    # The connection parameters are defined by the environment variables
    conn = snowflake.connector.connect(
        user = "pratik.patel@hellofresh.com",
        account = "oo69432.eu-west-1",
        authenticator = "externalbrowser",
        warehouse='US_OPS_ANALYTICS',
        database='FAREYE',
        #schema='your-schema'
    )
    return conn


def get_gspread_connection():
    gc = gspread.service_account(filename=r'C:\Users\PratikPatel\Desktop\HFDN - Reporting\python\driver_agency_mapping\config\driver-inspection-report-4ec3b6478af2.json')
    spreadsheet = gc.open("Driver Agency Mapping")
    automated = spreadsheet.worksheet('automated')
    return gc