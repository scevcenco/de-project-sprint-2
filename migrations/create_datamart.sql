DROP TABLE IF EXISTS public.shipping_datamart;
CREATE TABLE public.shipping_datamart(
    PRIMARY KEY (shippingid),
    shippingid              BIGINT,
    vendorid                BIGINT,
    transfer_type           TEXT,
    full_day_at_shipping    INTEGER,
    is_delay                SMALLINT,
    is_shipping_finish      SMALLINT,
    delay_day_at_shipping   INTEGER,
    payment_amount          NUMERIC(14, 3),
    vat                     DOUBLE PRECISION,
    profit                  DOUBLE PRECISION,
                            CHECK (is_delay IS NOT NULL AND is_delay IN (1, 0)),
                            CHECK (is_shipping_finish IS NOT NULL AND is_shipping_finish IN (1, 0))
);
CREATE INDEX shipping_datamart_id_index ON public.shipping_datamart(shippingid);