import sys
import os
import snowflake.connector
import gspread
from dotenv import load_dotenv

# Add the project root to the Python path
project_root = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
sys.path.append(project_root)


dotenv_path = os.path.join(project_root, ".env")
if os.path.exists(dotenv_path):
    load_dotenv(dotenv_path)

google_service_account = os.getenv("GOOGLE_SERVICE_ACCOUNT")

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
    gc = gspread.service_account(google_service_account)
    return gc