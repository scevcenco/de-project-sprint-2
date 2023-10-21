CREATE OR REPLACE VIEW public.shipping_datamart as 
    (SELECT si.shippingid as shippingid,
            si.vendorid as vendorid,
            st.transfer_type as transfer_type,
            DATE_PART('day', AGE(ss.shipping_end_fact_datetime, ss.shipping_start_fact_datetime)) AS full_day_at_shipping,
            (CASE
                WHEN ss.shipping_end_fact_datetime > si.shipping_plan_datetime THEN 1
                ELSE 0
            END) AS is_delay,
            (CASE
                WHEN status = 'finished' THEN 1
                ELSE 0
            END) AS is_shipping_finish,
            (CASE
                WHEN ss.shipping_end_fact_datetime > si.shipping_plan_datetime THEN DATE_PART('day', AGE(ss.shipping_end_fact_datetime, si.shipping_plan_datetime))
                ELSE 0
            END) AS delay_day_at_shipping,
            si.payment_amount as payment_amount,
            (scr.shipping_country_base_rate + sa.agreement_rate + st.shipping_transfer_rate) * si.payment_amount AS vat,
            sa.agreement_commission * si.payment_amount AS profit
       FROM shipping_info si
       JOIN shipping_transfer st
         ON st.id = si.transfer_type_id
       JOIN shipping_agreement sa
         ON sa.agreementid = si.agreementid
       JOIN shipping_country_rates scr
         ON scr.id = si.shipping_country_id
       JOIN shipping_status ss
         ON ss.shippingid = si.shippingid);
    