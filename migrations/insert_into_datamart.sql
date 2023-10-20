INSERT INTO public.shipping_datamart(shippingid,
                                     vendorid,
                                     transfer_type,
                                     full_day_at_shipping,
                                     is_delay,
                                     is_shipping_finish,
                                     delay_day_at_shipping,
                                     payment_amount,
                                     vat,
                                     profit)
     SELECT si.shippingid,
            vendorid,
            transfer_type,
            DATE_PART('day', AGE(shipping_end_fact_datetime, shipping_start_fact_datetime)) AS full_day_at_shipping,
            CASE
                WHEN shipping_end_fact_datetime > shipping_plan_datetime THEN 1
                ELSE 0
            END AS is_delay,
            CASE
                WHEN status = 'finished' THEN 1
                ELSE 0
            END AS is_shipping_finish,
            CASE
                WHEN shipping_end_fact_datetime > shipping_plan_datetime THEN DATE_PART('day', AGE(shipping_end_fact_datetime, shipping_plan_datetime))
                ELSE 0
            END AS delay_day_at_shipping,
            payment_amount,
            (shipping_country_base_rate + agreement_rate + shipping_transfer_rate) * payment_amount AS vat,
            agreement_commission * payment_amount AS profit
       FROM shipping_info si
       JOIN shipping_transfer st
         ON st.id = si.transfer_type_id
       JOIN shipping_agreement sa
         ON sa.agreementid = si.agreementid
       JOIN shipping_country_rates scr
         ON scr.id = si.shipping_country_id
       JOIN shipping_status ss
         ON ss.shippingid = si.shippingid;