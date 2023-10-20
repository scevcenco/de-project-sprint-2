--country

INSERT INTO public.shipping_country_rates(shipping_country,
                                          shipping_country_base_rate)
     SELECT DISTINCT shipping_country, shipping_country_base_rate
                FROM shipping;

--agreement

INSERT INTO public.shipping_agreement(agreementid,
                                      agreement_number,
                                      agreement_rate,
                                      agreement_commission)
     SELECT DISTINCT 
            t[1]::INTEGER,
            t[2],
            t[3]::NUMERIC(14, 3),
            t[4]::NUMERIC(14, 3)
       FROM 
            (SELECT REGEXP_SPLIT_TO_ARRAY(vendor_agreement_description, ':') AS t
               FROM shipping) g;

--transfer

INSERT INTO public.shipping_transfer(transfer_type,
                                     transfer_model,
                                     shipping_transfer_rate)
     SELECT DISTINCT
            t[1],
            t[2],
            shipping_transfer_rate::NUMERIC(14, 3)
       FROM 
            (SELECT shipping_transfer_rate,
                    REGEXP_SPLIT_TO_ARRAY(shipping_transfer_description, ':') AS t
               FROM shipping) g;

--shipping info

INSERT INTO public.shipping_info(shippingid,
                                 vendorid,
                                 payment_amount,
                                 shipping_plan_datetime,
                                 transfer_type_id,
                                 shipping_country_id,
                                 agreementid)
     SELECT shippingid,
            vendorid,
            payment_amount,
            shipping_plan_datetime,
            st.id AS transfer_type_id,
            scr.id AS shipping_country_id,
            agreementid
       FROM 
            (SELECT DISTINCT
                    shippingid,
                    vendorid,
                    payment_amount,
                    shipping_plan_datetime,
                    (REGEXP_SPLIT_TO_ARRAY(vendor_agreement_description, ':'))[1]::INTEGER AS agreementid,
                    (REGEXP_SPLIT_TO_ARRAY(shipping_transfer_description, ':'))[1] AS transfer_type,
                    (REGEXP_SPLIT_TO_ARRAY(shipping_transfer_description, ':'))[2] AS transfer_model,
                    shipping_country 
               FROM shipping) AS t
               JOIN shipping_transfer st
                 ON st.transfer_type = t.transfer_type
                    AND st.transfer_model = t.transfer_model
               JOIN shipping_country_rates scr
                 ON scr.shipping_country = t.shipping_country;


--status

WITH t AS (
    SELECT shippingid,
           MAX(state_datetime) m_dt,
           MAX(shipping_start_fact_datetime) start_dt,
           MAX(shipping_end_fact_datetime) end_dt
      FROM 
           (SELECT shippingid,
                   state_datetime,
                   state,
                   status, 
                   CASE
                       WHEN STATE = 'booked' THEN state_datetime
                   END AS shipping_start_fact_datetime,
                   CASE
                       WHEN STATE = 'recieved' THEN state_datetime
                   END AS shipping_end_fact_datetime
              FROM shipping) s
     GROUP BY shippingid)

INSERT INTO public.shipping_status(shippingid,
                                   status,
                                   state,
                                   shipping_start_fact_datetime,
                                   shipping_end_fact_datetime)
     SELECT t.shippingid,
            status,
            state,
            start_dt,
            end_dt
       FROM shipping s 
       JOIN t
         ON t.shippingid = s.shippingid
            AND t.m_dt = s.state_datetime;