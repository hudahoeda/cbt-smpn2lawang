alter table public.banksoals
    add code16_max integer default 0 not null;

alter table public.hasil_ujians
    add code16_correct integer default 0 not null;

alter table public.hasil_ujians
    add code16_wrong integer default 0 not null;

alter table public.hasil_ujians
    add code16_point numeric(19, 2) default 0 not null;

alter table public.hasil_ujians
    add code16_void integer default 0 not null;

alter table public.jawaban_pesertas
    add paper_code varchar(100);

alter table public.soals
    add paper_answer boolean default false not null;

create table public.shortcuts
(
    id          char(26)     not null
        constraint shortcuts_pk
            primary key,
    user_id     char(36)     not null,
    name        varchar(255) not null,
    destination text         not null,
    icon        text
);


INSERT INTO public.menus (code, title, "order") VALUES ('0025A', 'Daftar shortcut', 36001);
INSERT INTO public.menus (code, title, "order") VALUES ('0025B', 'Tambah shortcut', 36002);
INSERT INTO public.menus (code, title, "order") VALUES ('0025C', 'Delete shortcut', 36003);
INSERT INTO public.role_menus (role_code, menu_code) VALUES ('EVIL', '0025B');
INSERT INTO public.role_menus (role_code, menu_code) VALUES ('EVIL', '0025A');
INSERT INTO public.role_menus (role_code, menu_code) VALUES ('EVIL', '0025C');
INSERT INTO public.role_menus (role_code, menu_code) VALUES ('EVAL', '0025B');
INSERT INTO public.role_menus (role_code, menu_code) VALUES ('EVAL', '0025A');
INSERT INTO public.role_menus (role_code, menu_code) VALUES ('EVAL', '0025C');
INSERT INTO public.role_menus (role_code, menu_code) VALUES ('OPRA', '0025A');
INSERT INTO public.role_menus (role_code, menu_code) VALUES ('OPRA', '0025C');
INSERT INTO public.role_menus (role_code, menu_code) VALUES ('OPRA', '0025B');
INSERT INTO public.settings (code, value) VALUES ('AUTO_BLOCK', 'Y');