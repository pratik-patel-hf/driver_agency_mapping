import os
import sys
# Add the project root directory to Python path
project_root = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
sys.path.append(project_root)

import pandas as pd
import numpy as np
import gspread
from gspread_dataframe import set_with_dataframe
import re
import logging
from config.credentials import get_snowflake_connection, get_gspread_connection

# Set up logging
logging.basicConfig(
    level=logging.INFO,
    format = '%(asctime)s - %(name)s - %(levelname)s - %(message)s'
)
logger = logging.getLogger(__name__)

# Snowflake query
def fetch_data_from_snowflake(query_path):
    """Fetch driver inspection data from Snowflake"""
    logger.info("Connecting to Snowflake...")
    conn = get_snowflake_connection()

    # Directly read the SQL query from the file
    with open(query_path, 'r') as file:
        query = file.read()

    # Create a cursor object
    cur = conn.cursor()

    # Change the role for sensitive data access
    cur.execute("USE ROLE US_OPS_ANALYTICS_ANALYST_SENSITIVE")

    try:
        logger.info("Executing Snowflake query...")
        cur.execute(query)

        # Fetch the results
        results = cur.fetchall()

        # Fetch the column headers
        headers = [desc[0] for desc in cur.description]

        # Create DataFrame
        df = pd.DataFrame(results, columns=headers)
        logger.info(f"Retrieved {len(df)} records from Snowflake")

        return df
    
    except Exception as e:
        logger.error(f"Error fetching data from Snowflake: {str(e)}")
        raise
    finally:
        # CLose the cursor and connection
        cur.close()
        conn.close()
        logger.info("Snowflake connection closed")

def update_google_sheet(df):
    """Update the Google Sheet with cleaned and flagged data"""
    logger.info("Updating Google Sheet")
    try:
        # Get Google credentials
        gc = get_gspread_connection()

        # Open the spreadsheet
        spreadsheet = gc.open("Driver Agency Mapping")
        automated = spreadsheet.worksheet('automated')

        # Clear contents of columns A:R
        logger.info("Clearing existing data from columns A:D...")
        range_to_clear = 'A2:D'
        automated.batch_clear([range_to_clear])

        # Update the worksheet with DataFrame
        logger.info("Updating sheet with new data...")
        set_with_dataframe(automated, df)

        return True
    except Exception as e:
        logger.error(f"Error updating the Google Sheet: {str(e)}")
        raise

def main():
    """Main function to run the full workflow"""
    try:
        logger.info("Starting Driver Mapping process")
        
        # Step 1: Fetch data from Snowflake
        query_path = os.path.join(project_root, 'queries', 'driver_agency_mapping_v2.sql')
        df = fetch_data_from_snowflake(query_path)
        
        # Step 2: Update Google Sheet
        update_google_sheet(df)
        
        logger.info("Process completed successfully")
        return True
    except Exception as e:
        logger.error(f"Error in main process: {str(e)}")
        raise

if __name__ == "__main__":
    main()