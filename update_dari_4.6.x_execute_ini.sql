alter table public.soal_summaries
    add discrimination numeric(19, 8) default 0 not null;
alter table public.soal_summaries
    add distractor text;

INSERT INTO public.agamas (id, kode, nama, created_at, updated_at) VALUES ('7c03497a-6df3-46db-9ff9-99a9c7b49b14', 'KONG_HU_CU', 'Kong Hu Cu', '2026-05-01 20:12:06', '2026-05-01 20:12:08');
INSERT INTO public.agamas (id, kode, nama, created_at, updated_at) VALUES ('338dddd4-91b7-4a3c-b7d1-cb0979f222d8', 'KEPERCAYAAN_YME', 'Kepercayaan Terhadap Tuhan Yang Maha Esa', '2026-05-01 20:14:54', '2026-05-01 20:14:55');
