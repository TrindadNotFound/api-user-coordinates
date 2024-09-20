--SQL script
CREATE TABLE public.userdata (
	id SERIAL NOT NULL,
	name varchar NULL,
	city varchar NULL,
	coordinates varchar NULL,
	CONSTRAINT userdata_pk PRIMARY KEY (id)
);

