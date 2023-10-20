DROP TABLE IF EXISTS public.shipping_status;
DROP TABLE IF EXISTS public.shipping_info;
DROP TABLE IF EXISTS public.shipping_transfer;
DROP TABLE IF EXISTS public.shipping_agreement;
DROP TABLE IF EXISTS public.shipping_country_rates;

--shipping_country_rates
CREATE TABLE public.shipping_country_rates(
    PRIMARY KEY(id),
    id                          SERIAL,
    shipping_country            TEXT,
    shipping_country_base_rate  NUMERIC(14, 3)
);
CREATE INDEX shipping_country_index ON public.shipping_country_rates(shipping_country);

--shipping_agreement
CREATE TABLE public.shipping_agreement(
    PRIMARY KEY (agreementid),
    agreementid             INTEGER,
    agreement_number        TEXT,
    agreement_rate          NUMERIC(14, 3),
    agreement_commission    NUMERIC(14, 3)
);
CREATE INDEX shipping_agreement_number_index ON public.shipping_agreement(agreement_number);

--shipping_transfer
CREATE TABLE public.shipping_transfer(
    PRIMARY KEY (id),
    id                      SERIAL,
    transfer_type           TEXT,
    transfer_model          TEXT,
    shipping_transfer_rate  NUMERIC(14, 3)
);
CREATE INDEX shipping_transfer_type_index ON public.shipping_transfer(transfer_type);


--shipping_info
CREATE TABLE public.shipping_info(
    PRIMARY KEY (shippingid),
    shippingid              BIGINT,
    vendorid                BIGINT,
    payment_amount          NUMERIC(14, 3),
    shipping_plan_datetime  TIMESTAMP,
    transfer_type_id        BIGINT,
    shipping_country_id     BIGINT,
    agreementid             INTEGER,
    FOREIGN KEY (transfer_type_id)
        REFERENCES public.shipping_transfer(id) ON UPDATE CASCADE,
    FOREIGN KEY (shipping_country_id)
        REFERENCES public.shipping_country_rates(id) ON UPDATE CASCADE,
    FOREIGN KEY (agreementid)
        REFERENCES public.shipping_agreement(agreementid) ON UPDATE CASCADE
);
CREATE INDEX shipping_info_id_index ON public.shipping_info(shippingid);

--shipping_status
CREATE TABLE public.shipping_status(
    PRIMARY KEY (shippingid),
    shippingid                      BIGINT,
    status                          TEXT,
    state                           TEXT,
    shipping_start_fact_datetime    TIMESTAMP,
    shipping_end_fact_datetime      TIMESTAMP,
                                    CHECK (status in ('in_progress', 'finished')),
                                    CHECK (state in ('booked','fulfillment', 'queued', 'transition', 'pending', 'recieved', 'returned'))
);

CREATE INDEX shipping_status_id_index ON public.shipping_status(shippingid);