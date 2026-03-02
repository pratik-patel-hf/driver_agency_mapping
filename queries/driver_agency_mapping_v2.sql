-- Destination Depots --
WITH hub_mapping AS (
    SELECT * FROM (VALUES
        ('CHICAGO', 'CHIIL', 'IL', 'Chicago'),
        ('SLC1', 'SCIUT', 'UT', 'Salt Lake City'),
        ('SEA1', 'KENWA', 'WA', 'Seattle'),
        ('PHX1', 'TOLAZ', 'AZ', 'Phoenix'),
        ('ATL1', 'SMYGA', 'GA', 'Smyrna'),
        ('BOS1', 'BOSMA', 'MA', 'Boston'),
        ('STL1', 'SUNMO', 'MO', 'St Louis'),
        ('DFW1', 'DALTX', 'TX', 'Dallas'),
        ('MSP1', 'MINMN', 'MN', 'Minneapolis'),
        ('CLE1', 'CLEOH', 'OH', 'Cleveland'),
        ('FLL1', 'FTLFL', 'FL', 'Ft Lauderdale'),
        ('DCA1', 'WDCMD', 'MD', 'Landover'),
        ('DTW1', 'MADMI', 'MI', 'Detroit'),
        ('PIT1', 'PITPA', 'PA', 'Pittsburgh'),
        ('PDX1', 'MILOR', 'OR', 'Portland'),
        ('EWR1', 'FAINJ', 'NJ', 'Fairfield'),
        ('CMH1', 'LEWOH', 'OH', 'Columbus'),
        ('BNA1', 'BNATN', 'TN', 'Nashville'),
        ('MCI1', 'KANMO', 'MO', 'Kansas City'),
        ('ROC1', 'RCHNY', 'NY', 'Rochester'),
        ('DEN1', 'AURCO', 'CO', 'Denver')
        ) AS t(hub, destination_depot, state, city)
    ),

-- Order Based Driver Table -- 
driver_data AS (
    SELECT 
        DISTINCT COALESCE(external_employee_code,driver_code) AS combined_dc,
        external_employee_code,
        carrier_code,
        driver_code,
        RIGHT(COALESCE(external_employee_code, driver_code), 5) AS driver_code_suffix,
        hm.destination_depot,
        hellofresh_week,
        ord.hub as ord_hub,
        di.hub AS di_hub,
        hm.hub AS hm_hub
    FROM US_OPS_ANALYTICS.FAREYE.ORDER_BASED_EVENT ord
    LEFT JOIN US_OPS_ANALYTICS.FAREYE.DRIVER_INSPECTION di
        ON external_employee_code = driver_code
    LEFT JOIN us_ops_analytics.dimensions.date_dimension dd
        ON default_delivery_date = dd.date_string_backwards
    LEFT JOIN hub_mapping hm
        ON di.hub = LOWER(hm.hub)
        OR ord.hub = LOWER(hm.hub)
    WHERE default_delivery_date >= DATEADD(week, -110, CURRENT_DATE())
),

-- Mapping Logic -- 
driver_agency_mapping AS (
    SELECT 
        dd.*,
        CASE
        -- AURCO --
        WHEN destination_depot = 'AURCO' AND driver_code_suffix = '_f_hf' THEN 'DSP-Frayt AURCO'
        WHEN destination_depot = 'AURCO' AND driver_code_suffix = 'f)_hf' THEN 'DSP-Frayt AURCO'

        -- BNATN --
        WHEN destination_depot = 'BNATN' AND driver_code_suffix = 'em_hf' THEN 'DSP-DropOff BNATN'
        WHEN destination_depot = 'BNATN' AND driver_code_suffix = '_d_hf' THEN 'DSP-DropOff BNATN'
        WHEN destination_depot = 'BNATN' AND driver_code_suffix = 'd)_hf' THEN 'DSP-DropOff BNATN'
        WHEN destination_depot = 'BNATN' AND driver_code_suffix = '_h_hf' THEN 'DSP-Hungry BNATN'
        WHEN destination_depot = 'BNATN' AND driver_code_suffix = '_g_hf' THEN 'DSP-Pace BNATN'
        WHEN destination_depot = 'BNATN' AND driver_code_suffix = '_p_hf' THEN 'DSP-Pace BNATN'
        WHEN destination_depot = 'BNATN' AND driver_code_suffix = 'p)_hf' THEN 'DSP-Pace BNATN'
        WHEN destination_depot = 'BNATN' AND driver_code_suffix = '_f_hf' THEN 'DSP-Frayt BNATN'

        -- BOSMA --
        WHEN destination_depot = 'BOSMA' AND driver_code_suffix = '_c_hf' AND hellofresh_week >= '2025-W30' THEN 'DSP-Chronim BOSMA'
        WHEN destination_depot = 'BOSMA' AND driver_code_suffix = '_c_hf' AND hellofresh_week < '2025-W29' THEN 'DSP-Cornucopia'
        WHEN destination_depot = 'BOSMA' and driver_code_suffix = 'C)_hf' AND hellofresh_week < '2025-W29' THEN 'DSP-Cornucopia'
        WHEN destination_depot = 'BOSMA' and driver_code_suffix = 'c)_hf' AND hellofresh_week < '2025-W29' THEN 'DSP-Cornucopia'
        WHEN destination_depot = 'BOSMA' AND driver_code_suffix = 'da_hf' THEN 'DSP-DeliveryAuthority BOSMA'
        WHEN destination_depot = 'BOSMA' AND driver_code_suffix = '_f_hf' THEN 'DSP-Frayt BOSMA'
        WHEN destination_depot = 'BOSMA' AND driver_code_suffix = '_h_hf' THEN 'DSP-Hungry BOSMA'

        -- CHIIL -- 
        WHEN destination_depot = 'CHIIL' AND driver_code_suffix = 'da_hf' THEN 'DSP-DeliveryAuthority CHIIL'
        WHEN destination_depot = 'CHIIL' AND driver_code_suffix = '_y_hf' THEN 'DSP-DeliveryAuthority CHIIL'
        WHEN destination_depot = 'CHIIL' AND driver_code_suffix = '_c_hf' THEN 'DSP-Chronim CHIIL'

        -- CLEOH -- 
        WHEN destination_depot = 'CLEOH' AND driver_code_suffix = '_c_hf' THEN 'DSP-Chronim CLEOH'
        WHEN destination_depot = 'CLEOH' AND driver_code_suffix = '_f_hf' THEN 'DSP-Frayt CLEOH'
        WHEN destination_depot = 'CLEOH' AND driver_code_suffix = 'f)_hf' THEN 'DSP-Frayt CLEOH'
        WHEN destination_depot = 'CLEOH' AND combined_dc LIKE '%.' AND carrier_code = 'FRAYT' THEN 'DSP-Frayt CLEOH'

        -- DALTX --
        WHEN destination_depot = 'DALTX' AND driver_code_suffix = '_d_hf' THEN 'DSP-DropOff DALTX'
        when destination_depot = 'DALTX' AND driver_code_suffix = '_f_hf' THEN 'DSP-Frayt DALTX'
        WHEN destination_depot = 'DALTX' and driver_code_suffix = '_c_hf' THEN 'DSP-Chronim DALTX'

        -- FAINJ --
        WHEN destination_depot = 'FAINJ' AND driver_code_suffix = '_d_hf' THEN 'DSP-DropOff FAINJ'
        WHEN destination_depot = 'FAINJ' AND driver_code_suffix = 'lb_hf' THEN 'DSP-DropOff FAINJ'
        WHEN destination_depot = 'FAINJ' AND driver_code_suffix = 'zl_hf' THEN 'DSP-NetZero FAINJ'
        WHEN destination_depot = 'FAINJ' AND driver_code_suffix = 'mc_hf' THEN 'DSP-M2C FAINJ'
        WHEN destination_depot = 'FAINJ' AND driver_code_suffix = '2c_hf' THEN 'DSP-M2C FAINJ'
        WHEN destination_depot = 'FAINJ' AND driver_code_suffix = '_u_hf' THEN 'DSP-UltimateLogistics FAINJ'
        WHEN destination_depot = 'FAINJ' AND driver_code_suffix = 'u__hf' THEN 'DSP-UltimateLogistics FAINJ'
        WHEN destination_depot = 'FAINJ' AND driver_code_suffix = 'u)_hf' THEN 'DSP-UltimateLogistics FAINJ'
        
        -- FTLFL --
        WHEN destination_depot = 'FTLFL' AND driver_code_suffix = '_d_hf' AND hellofresh_week <'2025-W08' THEN 'DSP-DCALogistics'
        WHEN destination_depot = 'FTLFL' AND driver_code_suffix = '_d_hf' AND hellofresh_week >='2025-W08' THEN 'DSP-DropOff FTLFL'

        -- KANMO --
        WHEN destination_depot = 'KANMO' AND driver_code_suffix = '_f_hf' THEN 'DSP-Frayt KANMO'
        WHEN destination_depot = 'KANMO' AND driver_code_suffix = '_h_hf' THEN 'DSP-Hungry KANMO'
        
        -- LEWOH -- 
        WHEN destination_depot = 'LEWOH' AND driver_code_suffix = '_f_hf' THEN 'DSP-Frayt LEWOH'
        WHEN destination_depot = 'LEWOH' AND driver_code_suffix = 'f)_hf' THEN 'DSP-Frayt LEWOH'
        
        -- MADMI --
        WHEN destination_depot = 'MADMI' AND driver_code_suffix = '_d_hf' THEN 'DSP-DropOff MADMI'
        WHEN destination_depot = 'MADMI' AND driver_code_suffix = '_p_hf' THEN 'DSP-PCSCourier'
        WHEN destination_depot = 'MADMI' AND driver_code_suffix = 'd)_hf' THEN 'DSP-DropOff MADMI'
        WHEN destination_depot = 'MADMI' AND driver_code_suffix = '_c_hf' THEN 'DSP-Chronim MADMI'
        
        -- MILOR -- 
        WHEN destination_depot = 'MILOR' AND driver_code_suffix = '_f_hf' THEN 'DSP-Frayt MILOR'
        WHEN destination_depot = 'MILOR' and driver_code_suffix = 'f)_hf' THEN 'DSP-Frayt MILOR'
        
        -- MINMN --
        WHEN destination_depot = 'MINMN' AND driver_code_suffix = '_c_hf' THEN 'DSP-Chronim MINMN'
        WHEN destination_depot = 'MINMN' AND driver_code_suffix = '_f_hf' THEN 'DSP-Frayt MINMN'
        WHEN destination_depot = 'MINMN' AND driver_code_suffix = 'da_hf' THEN 'DSP-DeliveryAuthority MINMN'
        WHEN destination_depot = 'MINMN' AND driver_code_suffix = '_w_hf' THEN 'DSP-Winnesota'
        
        -- PITPA --
        WHEN destination_depot = 'PITPA' AND driver_code_suffix = '_c_hf' THEN 'DSP-Chronim PITPA'
        WHEN destination_depot = 'PITPA' AND driver_code_suffix = '_d_hf' THEN 'DSP-DropOff PITPA'
        WHEN destination_depot = 'PITPA' AND driver_code_suffix = '_f_hf' AND hellofresh_week < '2025-W04' THEN 'DSP-FrontDoorCarrier'
        WHEN destination_depot = 'PITPA' AND driver_code_suffix = '_f_hf' AND hellofresh_week >= '2025-W04' THEN 'DSP-Frayt PITPA'
        
        -- RCHNY --
        WHEN destination_depot = 'RCHNY' AND driver_code_suffix = '_d_hf' THEN 'DSP-DropOff RCHNY'
        WHEN destination_depot = 'RCHNY' AND driver_code_suffix = 'dr_hf' THEN 'DSP-DropOff RCHNY'
        WHEN destination_depot = 'RCHNY' AND driver_code_suffix = 'db_hf' THEN 'DSP-DropOff RCHNY'
        WHEN destination_depot = 'RCHNY' AND driver_code_suffix = 'ds_hf' THEN 'DSP-DropOff RCHNY'
        WHEN destination_depot = 'RCHNY' AND driver_code_suffix = 'dg_hf' THEN 'DSP-DropOff RCHNY'
        WHEN destination_depot = 'RCHNY' and driver_code_suffix = '_r_hf' THEN 'DSP-DropOff RCHNY'
        
        -- SCIUT --
        WHEN destination_depot = 'SCIUT' AND driver_code_suffix = '_f_hf' THEN 'DSP-Frayt SCIUT'
        WHEN destination_depot = 'SCIUT' AND driver_code_suffix = '_c_hf' THEN 'DSP-Chronim SCIUT'
        
        -- SMYGA --
        WHEN destination_depot = 'SMYGA' AND driver_code_suffix = '_a_hf' THEN 'DSP-ATLCourier'
        WHEN destination_depot = 'SMYGA' AND driver_code_suffix = '_d_hf' THEN 'DSP-DropOff SMYGA'
        WHEN destination_depot = 'SMYGA' AND driver_code_suffix = 'bh_hf' THEN 'DSP-DropOff SMYGA'
        WHEN destination_depot = 'SMYGA' AND driver_code_suffix = 'sa_hf' THEN 'DSP-DropOff SMYGA'
        WHEN destination_depot = 'SMYGA' AND driver_code_suffix = 'au_hf' THEN 'DSP-DropOff SMYGA'
        WHEN destination_depot = 'SMYGA' AND driver_code_suffix = 'co_hf' THEN 'DSP-DropOff SMYGA'
        WHEN destination_depot = 'SMYGA' AND driver_code_suffix = 'sv_hf' THEN 'DSP-DropOff SMYGA'
        WHEN destination_depot = 'SMYGA' AND driver_code_suffix = 'hu_hf' THEN 'DSP-DropOff SMYGA'
        WHEN destination_depot = 'SMYGA' AND driver_code_suffix = 'hs_hf' THEN 'DSP-DropOff SMYGA'
        WHEN destination_depot = 'SMYGA' AND driver_code_suffix = 'ol_hf' THEN 'DSP-DropOff SMYGA'
        WHEN destination_depot = 'SMYGA' AND driver_code_suffix = 'ug_hf' THEN 'DSP-DropOff SMYGA'
        WHEN destination_depot = 'SMYGA' AND driver_code_suffix = '_g_hf' THEN 'DSP-Pace'
                
        -- SUNMO --
        WHEN destination_depot = 'SUNMO' AND driver_code_suffix = '_f_hf' THEN 'DSP-Frayt SUNMO'
        WHEN destination_depot = 'SUNMO' AND driver_code_suffix = '_c_hf' THEN 'DSP-Chronim SUNMO'
        
        -- TOLAZ --
        WHEN destination_depot = 'TOLAZ' AND driver_code_suffix = '_c_hf' THEN 'DSP-Chronim TOLAZ'
        WHEN destination_depot = 'TOLAZ' AND driver_code_suffix = '_h_hf' THEN 'DSP-Hungry'
        WHEN destination_depot = 'TOLAZ' AND driver_code_suffix = '_d_hf' THEN 'DSP-DropOff TOLAZ'
        WHEN destination_depot = 'TOLAZ' AND driver_code_suffix = '_f_hf' THEN 'DSP-Frayt TOLAZ'
        
        -- WDCMD -- 
        WHEN destination_depot = 'WDCMD' AND driver_code_suffix = '_d_hf' THEN 'DSP-FalconExpress WDCMD'
        
        -- Staffmark --
        WHEN driver_code_suffix = '_s_hf' THEN 'Staffmark'
        WHEN driver_code_suffix = 'sm_hf' THEN 'Staffmark'
        WHEN driver_code_suffix = 's)_hf' THEN 'Staffmark'
        WHEN RIGHT(combined_dc,9) = '(s)-hf_hf' THEN 'Staffmark'
        WHEN driver_code_suffix = 's2_hf' THEN 'Staffmark'
        WHEN RIGHT(combined_dc,7) = '(s)__hf' THEN 'Staffmark'
        
        -- Trillum -- 
        WHEN driver_code_suffix = 't)_hf' THEN 'Trillium'
        WHEN driver_code_suffix = '_t_hf' THEN 'Trillium'
        WHEN driver_code_suffix = 't__hf' THEN 'Trillium'

        -- GIG --
        WHEN combined_dc LIKE '%.' AND carrier_code = 'ROADIE' THEN 'GIG-ROADIE'
        WHEN combined_dc LIKE '%.' AND carrier_code = 'UBER' THEN 'GIG-UBER'

        -- NonPeriod driver_codes being marked as GIG
        WHEN combined_dc LIKE '%_hf' AND (carrier_code IN ('ROADIE','UBER')) THEN 'TestUser'
        WHEN combined_dc NOT LIKE '%.' AND carrier_code = 'ROADIE' THEN 'GIG-ROADIE'
        WHEN combined_dc NOT LIKE '%.' AND carrier_code = 'UBER' THEN 'GIG-UBER'

        -- Test User -- 
        WHEN driver_code = 'mcistandbydriver_01_hf' THEN 'TestUser'
        WHEN driver_code = 'phxstandbydriver_01_hf' THEN 'TestUser'
        WHEN driver_code = 'phxstandbydriver_02_hf' THEN 'TestUser'
        WHEN driver_code = 'tcdriver101_hf' THEN 'TestUser'
        WHEN driver_code = 'tcdriver1_hf' THEN 'TestUser'
        WHEN driver_code = 'tcdriver2_hf' THEN 'TestUser'
        WHEN driver_code = 'tcdriver100_hf' THEN 'TestUser'
        ELSE null
    END AS driver_agency,
    FROM driver_data dd
    ),

-- Filtered Selection -- 
filtered_mapping AS (
SELECT
    combined_dc as driver_code,
    driver_agency,
    destination_depot,
    hellofresh_week,
    ROW_NUMBER() OVER (
        PARTITION BY combined_dc, COALESCE(driver_agency, 'UNKNOWN'), destination_depot 
        ORDER BY hellofresh_week ASC
    ) AS rn
FROM driver_agency_mapping
WHERE combined_dc IS NOT NULL
    AND (driver_agency IS NOT NULL OR NOT EXISTS (
        SELECT 1 
        FROM driver_agency_mapping d2 
        WHERE d2.combined_dc = driver_agency_mapping.combined_dc 
        AND d2.driver_agency IS NOT NULL
    ))
)

-- Final Selection -- 
SELECT
    driver_code,
    driver_agency,
    destination_depot,
    hellofresh_week
FROM filtered_mapping
WHERE rn = 1
    AND driver_agency NOT IN ('GIG-ROADIE', 'GIG-UBER')
ORDER BY hellofresh_week ASC