create extension if not exists pgcrypto;

-- Основные справочники и пользователи

create table public.clinics (
  id uuid primary key default gen_random_uuid(),
  legacy_id integer unique,
  ogrn text,
  short_name text not null,
  full_name text,
  address text,
  phone text,
  email text,
  postal_index integer,
  chief_doctor_name text,
  deputy_chief_doctor_name text,
  created_at timestamptz not null default now()
);

create table public.doctors (
  id uuid primary key default gen_random_uuid(),
  legacy_id integer unique,
  clinic_id uuid references public.clinics(id) on delete set null,
  profile_id uuid unique,
  last_name text not null,
  first_name text not null,
  middle_name text,
  specialization text,
  birth_date date,
  legacy_created_at date,
  created_at timestamptz not null default now()
);

create table public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  role text not null check (role in ('admin', 'doctor')),
  full_name text,
  clinic_id uuid references public.clinics(id) on delete set null,
  doctor_id uuid references public.doctors(id) on delete set null,
  is_active boolean not null default true,
  created_at timestamptz not null default now()
);

-- Пациенты и обследования

create table public.patients (
  id uuid primary key default gen_random_uuid(),
  legacy_id integer unique,
  clinic_id uuid references public.clinics(id) on delete set null,
  card_number text not null unique,
  polis text,
  snils text,
  last_name text not null,
  first_name text not null,
  middle_name text,
  gender_id integer,
  birth_date date,
  region text,
  city text,
  street text,
  house integer,
  room integer,
  postal_index integer,
  job text,
  job_title text,
  is_disabled boolean not null default false,
  insurance_org_name text,
  education text,
  disability_group integer,
  raw_payload jsonb,
  created_at timestamptz not null default now(),
  constraint patients_disability_group_check
    check (disability_group is null or disability_group between 1 and 3)
);

create table public.examinations (
  id uuid primary key default gen_random_uuid(),
  patient_id uuid not null references public.patients(id) on delete cascade,
  doctor_id uuid references public.doctors(id) on delete set null,
  clinic_id uuid references public.clinics(id) on delete set null,
  exam_datetime timestamptz not null,
  status text not null default 'in_progress'
    check (status in ('in_progress', 'completed')),
  notes text,
  created_by uuid references auth.users(id) on delete set null,
  legacy_patient_record_id integer unique,
  legacy_number_card text,
  legacy_datetime timestamp,
  created_at timestamptz not null default now(),
  unique(patient_id, exam_datetime)
);

-- Диагностические таблицы обследования

create table public.exam_star1 (
  id uuid primary key default gen_random_uuid(),
  examination_id uuid not null unique references public.examinations(id) on delete cascade,
  legacy_id integer unique,
  p1 integer not null default 0,
  p2 integer not null default 0,
  p3 integer not null default 0,
  p4 integer not null default 0,
  rp1 integer not null default 0,
  rp2 integer not null default 0,
  rp3 integer not null default 0,
  rp4 integer not null default 0,
  r1 integer not null default 0,
  r2 integer not null default 0,
  r3 integer not null default 0,
  r4 integer not null default 0,
  gi1 integer not null default 0,
  gi2 integer not null default 0,
  gi3 integer not null default 0,
  gi4 integer not null default 0,
  e1 integer not null default 0,
  e2 integer not null default 0,
  e3 integer not null default 0,
  e4 integer not null default 0,
  vb1 integer not null default 0,
  vb2 integer not null default 0,
  vb3 integer not null default 0,
  vb4 integer not null default 0,
  v1 integer not null default 0,
  v2 integer not null default 0,
  v3 integer not null default 0,
  v4 integer not null default 0,
  c1 integer not null default 0,
  c2 integer not null default 0,
  c3 integer not null default 0,
  c4 integer not null default 0,
  f1 integer not null default 0,
  f2 integer not null default 0,
  f3 integer not null default 0,
  f4 integer not null default 0,
  ig1 integer not null default 0,
  ig2 integer not null default 0,
  ig3 integer not null default 0,
  ig4 integer not null default 0,
  legacy_number_card text,
  legacy_datetime timestamp,
  raw_payload jsonb,
  created_at timestamptz not null default now()
);

create table public.exam_star2 (
  id uuid primary key default gen_random_uuid(),
  examination_id uuid not null unique references public.examinations(id) on delete cascade,
  legacy_id integer unique,
  mc1 integer not null default 0,
  mc2 integer not null default 0,
  mc3 integer not null default 0,
  mc4 integer not null default 0,
  mc5 integer not null default 0,
  tr1 integer not null default 0,
  tr2 integer not null default 0,
  tr3 integer not null default 0,
  tr4 integer not null default 0,
  tr5 integer not null default 0,
  r5 integer not null default 0,
  gi5 integer not null default 0,
  e5 integer not null default 0,
  vb5 integer not null default 0,
  v5 integer not null default 0,
  c5 integer not null default 0,
  f5 integer not null default 0,
  ig5 integer not null default 0,
  p5 integer not null default 0,
  rp5 integer not null default 0,
  legacy_number_card text,
  legacy_datetime timestamp,
  raw_payload jsonb,
  created_at timestamptz not null default now()
);

create table public.exam_energy (
  id uuid primary key default gen_random_uuid(),
  examination_id uuid not null unique references public.examinations(id) on delete cascade,
  legacy_id integer unique,
  result text not null,
  value_origin text not null default 'derived',
  logic_code text,
  logic_snapshot jsonb,
  selected_cells jsonb,
  legacy_number_card text,
  legacy_datetime timestamp,
  raw_payload jsonb,
  created_at timestamptz not null default now()
);

create table public.exam_p9 (
  id uuid primary key default gen_random_uuid(),
  examination_id uuid not null unique references public.examinations(id) on delete cascade,
  legacy_id integer unique,
  result text not null,
  direction text,
  value_origin text not null default 'derived',
  logic_code text,
  logic_snapshot jsonb,
  legacy_number_card text,
  legacy_datetime timestamp,
  raw_payload jsonb,
  created_at timestamptz not null default now()
);

create table public.exam_e42 (
  id uuid primary key default gen_random_uuid(),
  examination_id uuid not null unique references public.examinations(id) on delete cascade,
  legacy_id integer unique,
  chi_cun_left text not null default 'Вэй',
  e42_left text not null default 'Вэй',
  chi_cun_right text not null default 'Вэй',
  e42_right text not null default 'Вэй',
  selected_cells jsonb,
  value_origin text not null default 'derived',
  logic_code text,
  logic_snapshot jsonb,
  legacy_number_card text,
  legacy_datetime timestamp,
  raw_payload jsonb,
  created_at timestamptz not null default now()
);

create table public.exam_foot (
  id uuid primary key default gen_random_uuid(),
  examination_id uuid not null unique references public.examinations(id) on delete cascade,
  legacy_id integer unique,
  foot_status text not null,
  selected_cells jsonb,
  value_origin text not null default 'derived',
  logic_code text,
  logic_snapshot jsonb,
  legacy_number_card text,
  legacy_datetime timestamp,
  raw_payload jsonb,
  created_at timestamptz not null default now()
);

create table public.exam_indexrecord (
  id uuid primary key default gen_random_uuid(),
  examination_id uuid not null unique references public.examinations(id) on delete cascade,
  legacy_id integer unique,
  key_values jsonb not null,
  legacy_number_card text,
  legacy_datetime timestamp,
  raw_payload jsonb,
  created_at timestamptz not null default now()
);

create table public.exam_crossrecord (
  id uuid primary key default gen_random_uuid(),
  examination_id uuid not null unique references public.examinations(id) on delete cascade,
  legacy_id integer unique,
  key_values jsonb not null,
  legacy_number_card text,
  legacy_datetime timestamp,
  raw_payload jsonb,
  created_at timestamptz not null default now()
);

create table public.exam_circlerecord (
  id uuid primary key default gen_random_uuid(),
  examination_id uuid not null unique references public.examinations(id) on delete cascade,
  legacy_id integer unique,
  key_values jsonb not null,
  legacy_number_card text,
  legacy_datetime timestamp,
  raw_payload jsonb,
  created_at timestamptz not null default now()
);

create table public.exam_balancerecord (
  id uuid primary key default gen_random_uuid(),
  examination_id uuid not null unique references public.examinations(id) on delete cascade,
  legacy_id integer unique,
  key_values jsonb not null,
  legacy_number_card text,
  legacy_datetime timestamp,
  raw_payload jsonb,
  created_at timestamptz not null default now()
);

-- Индексы для связей, поиска и проверок RLS

create index clinics_short_name_idx on public.clinics(short_name);
create index doctors_clinic_id_idx on public.doctors(clinic_id);
create index doctors_profile_id_idx on public.doctors(profile_id);
create index profiles_clinic_id_idx on public.profiles(clinic_id);
create index profiles_doctor_id_idx on public.profiles(doctor_id);
create index patients_clinic_id_idx on public.patients(clinic_id);
create index patients_card_number_idx on public.patients(card_number);
create index examinations_patient_id_idx on public.examinations(patient_id);
create index examinations_clinic_id_idx on public.examinations(clinic_id);
create index examinations_doctor_id_idx on public.examinations(doctor_id);
create index examinations_created_by_idx on public.examinations(created_by);

-- Триггер регистрации: каждый новый пользователь получает профиль врача

create or replace function public.handle_new_user()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  insert into public.profiles (id, role, full_name, is_active)
  values (
    new.id,
    'doctor',
    nullif(trim(coalesce(new.raw_user_meta_data->>'full_name', '')), ''),
    true
  )
  on conflict (id) do update
  set
    full_name = coalesce(public.profiles.full_name, excluded.full_name),
    is_active = coalesce(public.profiles.is_active, true);

  return new;
end;
$$;

drop trigger if exists on_auth_user_created on auth.users;

create trigger on_auth_user_created
after insert on auth.users
for each row
execute function public.handle_new_user();

-- Вспомогательные функции для RLS

create or replace function public.is_admin()
returns boolean
language sql
stable
security definer
set search_path = public
as $$
  select exists (
    select 1
    from public.profiles p
    where p.id = auth.uid()
      and p.role = 'admin'
      and p.is_active = true
  );
$$;

create or replace function public.is_active_doctor()
returns boolean
language sql
stable
security definer
set search_path = public
as $$
  select exists (
    select 1
    from public.profiles p
    where p.id = auth.uid()
      and p.role = 'doctor'
      and p.is_active = true
      and p.clinic_id is not null
  );
$$;

create or replace function public.current_clinic_id()
returns uuid
language sql
stable
security definer
set search_path = public
as $$
  select p.clinic_id
  from public.profiles p
  where p.id = auth.uid()
    and p.is_active = true
  limit 1;
$$;

create or replace function public.current_doctor_id()
returns uuid
language sql
stable
security definer
set search_path = public
as $$
  select p.doctor_id
  from public.profiles p
  where p.id = auth.uid()
    and p.is_active = true
  limit 1;
$$;

create or replace function public.can_access_examination(target_examination_id uuid)
returns boolean
language sql
stable
security definer
set search_path = public
as $$
  select exists (
    select 1
    from public.examinations e
    where e.id = target_examination_id
      and public.is_active_doctor()
      and e.clinic_id = public.current_clinic_id()
  );
$$;

-- Включение Row Level Security

alter table public.clinics enable row level security;
alter table public.doctors enable row level security;
alter table public.profiles enable row level security;
alter table public.patients enable row level security;
alter table public.examinations enable row level security;
alter table public.exam_star1 enable row level security;
alter table public.exam_star2 enable row level security;
alter table public.exam_energy enable row level security;
alter table public.exam_p9 enable row level security;
alter table public.exam_e42 enable row level security;
alter table public.exam_foot enable row level security;
alter table public.exam_indexrecord enable row level security;
alter table public.exam_crossrecord enable row level security;
alter table public.exam_circlerecord enable row level security;
alter table public.exam_balancerecord enable row level security;

-- RLS-политики для профилей

create policy profiles_select_self_or_admin
on public.profiles
for select
to authenticated
using (id = auth.uid() or public.is_admin());

create policy profiles_insert_admin
on public.profiles
for insert
to authenticated
with check (public.is_admin());

create policy profiles_update_admin
on public.profiles
for update
to authenticated
using (public.is_admin())
with check (true);

create policy profiles_update_self_doctor
on public.profiles
for update
to authenticated
using (
  id = auth.uid()
  and role = 'doctor'
  and is_active = true
)
with check (
  id = auth.uid()
  and role = 'doctor'
  and is_active = true
  and clinic_id is not distinct from public.current_clinic_id()
  and (
    doctor_id is null
    or doctor_id = public.current_doctor_id()
    or exists (
      select 1
      from public.doctors d
      where d.id = doctor_id
        and d.profile_id = auth.uid()
    )
  )
);

create policy profiles_delete_admin
on public.profiles
for delete
to authenticated
using (public.is_admin());

-- RLS-политики для клиник

create policy clinics_select_admin_or_own_doctor
on public.clinics
for select
to authenticated
using (
  public.is_admin()
  or (
    public.is_active_doctor()
    and id = public.current_clinic_id()
  )
);

create policy clinics_insert_admin
on public.clinics
for insert
to authenticated
with check (public.is_admin());

create policy clinics_update_admin
on public.clinics
for update
to authenticated
using (public.is_admin())
with check (public.is_admin());

create policy clinics_delete_admin
on public.clinics
for delete
to authenticated
using (public.is_admin());

-- RLS-политики для врачей

create policy doctors_select_admin_or_clinic_or_self
on public.doctors
for select
to authenticated
using (
  public.is_admin()
  or profile_id = auth.uid()
  or id = public.current_doctor_id()
  or (
    public.is_active_doctor()
    and clinic_id = public.current_clinic_id()
  )
);

create policy doctors_insert_admin_or_self
on public.doctors
for insert
to authenticated
with check (
  public.is_admin()
  or (
    public.is_active_doctor()
    and profile_id = auth.uid()
    and clinic_id = public.current_clinic_id()
  )
);

create policy doctors_update_admin_or_self
on public.doctors
for update
to authenticated
using (
  public.is_admin()
  or profile_id = auth.uid()
  or id = public.current_doctor_id()
)
with check (
  public.is_admin()
  or (
    profile_id = auth.uid()
    and clinic_id is not distinct from public.current_clinic_id()
  )
  or (
    id = public.current_doctor_id()
    and clinic_id is not distinct from public.current_clinic_id()
  )
);

create policy doctors_delete_admin
on public.doctors
for delete
to authenticated
using (public.is_admin());

-- RLS-политики для пациентов

create policy patients_select_doctor_own_clinic
on public.patients
for select
to authenticated
using (
  public.is_active_doctor()
  and clinic_id = public.current_clinic_id()
);

create policy patients_insert_doctor_own_clinic
on public.patients
for insert
to authenticated
with check (
  public.is_active_doctor()
  and clinic_id = public.current_clinic_id()
);

create policy patients_update_doctor_own_clinic
on public.patients
for update
to authenticated
using (
  public.is_active_doctor()
  and clinic_id = public.current_clinic_id()
)
with check (
  public.is_active_doctor()
  and clinic_id = public.current_clinic_id()
);

create policy patients_delete_doctor_own_clinic
on public.patients
for delete
to authenticated
using (
  public.is_active_doctor()
  and clinic_id = public.current_clinic_id()
);

-- RLS-политики для обследований

create policy examinations_select_doctor_own_clinic
on public.examinations
for select
to authenticated
using (
  public.is_active_doctor()
  and clinic_id = public.current_clinic_id()
);

create policy examinations_insert_doctor_own_clinic
on public.examinations
for insert
to authenticated
with check (
  public.is_active_doctor()
  and clinic_id = public.current_clinic_id()
  and exists (
    select 1
    from public.patients p
    where p.id = patient_id
      and p.clinic_id = public.current_clinic_id()
  )
);

create policy examinations_update_doctor_own_clinic
on public.examinations
for update
to authenticated
using (
  public.is_active_doctor()
  and clinic_id = public.current_clinic_id()
)
with check (
  public.is_active_doctor()
  and clinic_id = public.current_clinic_id()
  and exists (
    select 1
    from public.patients p
    where p.id = patient_id
      and p.clinic_id = public.current_clinic_id()
  )
);

create policy examinations_delete_doctor_own_clinic
on public.examinations
for delete
to authenticated
using (
  public.is_active_doctor()
  and clinic_id = public.current_clinic_id()
);

-- RLS-политики для диагностических таблиц, связанных через examination_id

create policy exam_star1_access_own_clinic
on public.exam_star1
for all
to authenticated
using (public.can_access_examination(examination_id))
with check (public.can_access_examination(examination_id));

create policy exam_star2_access_own_clinic
on public.exam_star2
for all
to authenticated
using (public.can_access_examination(examination_id))
with check (public.can_access_examination(examination_id));

create policy exam_energy_access_own_clinic
on public.exam_energy
for all
to authenticated
using (public.can_access_examination(examination_id))
with check (public.can_access_examination(examination_id));

create policy exam_p9_access_own_clinic
on public.exam_p9
for all
to authenticated
using (public.can_access_examination(examination_id))
with check (public.can_access_examination(examination_id));

create policy exam_e42_access_own_clinic
on public.exam_e42
for all
to authenticated
using (public.can_access_examination(examination_id))
with check (public.can_access_examination(examination_id));

create policy exam_foot_access_own_clinic
on public.exam_foot
for all
to authenticated
using (public.can_access_examination(examination_id))
with check (public.can_access_examination(examination_id));

create policy exam_indexrecord_access_own_clinic
on public.exam_indexrecord
for all
to authenticated
using (public.can_access_examination(examination_id))
with check (public.can_access_examination(examination_id));

create policy exam_crossrecord_access_own_clinic
on public.exam_crossrecord
for all
to authenticated
using (public.can_access_examination(examination_id))
with check (public.can_access_examination(examination_id));

create policy exam_circlerecord_access_own_clinic
on public.exam_circlerecord
for all
to authenticated
using (public.can_access_examination(examination_id))
with check (public.can_access_examination(examination_id));

create policy exam_balancerecord_access_own_clinic
on public.exam_balancerecord
for all
to authenticated
using (public.can_access_examination(examination_id))
with check (public.can_access_examination(examination_id));