
-- Lab work №2. university_main

-- Сначала удаляем таблицы, если они есть (в правильном порядке)
DROP TABLE IF EXISTS student_records CASCADE;
DROP TABLE IF EXISTS class_schedule CASCADE;
DROP TABLE IF EXISTS student_book_loans CASCADE;
DROP TABLE IF EXISTS library_books CASCADE;
DROP TABLE IF EXISTS grade_scale CASCADE;
DROP TABLE IF EXISTS semester_calendar CASCADE;
DROP TABLE IF EXISTS courses CASCADE;
DROP TABLE IF EXISTS professors CASCADE;
DROP TABLE IF EXISTS students CASCADE;
DROP TABLE IF EXISTS departments CASCADE;

-- =========================
-- Создаём таблицы заново
-- =========================

-- Студенты
CREATE TABLE students (
  student_id     serial PRIMARY KEY,
  first_name     varchar(50) NOT NULL,
  middle_name    varchar(30),
  last_name      varchar(50) NOT NULL,
  email          varchar(100),
  phone          varchar(20),
  date_of_birth  date,
  enrollment_date date,
  gpa            numeric(3,2) DEFAULT 0.00,
  is_active      boolean,
  student_status varchar(20) DEFAULT 'ACTIVE',
  graduation_year smallint,
  advisor_id     integer
);

-- Преподаватели
CREATE TABLE professors (
  professor_id     serial PRIMARY KEY,
  first_name       varchar(50),
  last_name        varchar(50),
  department_id    integer,
  department_code  char(5),
  email            varchar(100),
  office_number    varchar(20),
  hire_date        date,
  salary           numeric(14,2),
  is_tenured       boolean DEFAULT false,
  years_experience smallint,
  last_promotion_date date,
  research_area    text
);

-- Курсы
CREATE TABLE courses (
  course_id            serial PRIMARY KEY,
  department_id        integer,
  course_code          varchar(10),
  course_title         varchar(100),
  description          text,
  credits              smallint DEFAULT 3,
  difficulty_level     smallint,
  max_enrollment       integer,
  course_fee           numeric(10,2),
  lab_required         boolean DEFAULT false,
  is_online            boolean,
  prerequisite_course_id integer,
  created_at           timestamp
);

-- Расписание занятий
CREATE TABLE class_schedule (
  schedule_id     serial PRIMARY KEY,
  course_id       integer,
  professor_id    integer,
  classroom       varchar(30),
  room_capacity   integer,
  class_date      date,
  start_time      time,
  end_time        time,
  session_type    varchar(15),
  equipment_needed text
);

-- Успеваемость студентов
CREATE TABLE student_records (
  record_id            serial PRIMARY KEY,
  student_id           integer,
  course_id            integer,
  semester             varchar(20),
  year                 integer,
  grade                varchar(5),
  attendance_percentage numeric(4,1),
  extra_credit_points  numeric(4,1) DEFAULT 0.0,
  submission_timestamp timestamp with time zone,
  final_exam_date      date
);

-- Департаменты
CREATE TABLE departments (
  department_id    serial PRIMARY KEY,
  department_name  varchar(100),
  department_code  char(5),
  building         varchar(50),
  phone            varchar(15),
  budget           numeric(14,2),
  established_year integer
);

-- Книги
CREATE TABLE library_books (
  book_id             serial PRIMARY KEY,
  isbn                char(13),
  title               varchar(200),
  author              varchar(100),
  publisher           varchar(100),
  publication_date    date,
  price               numeric(10,2),
  is_available        boolean,
  acquisition_timestamp timestamp
);

-- Выданные книги
CREATE TABLE student_book_loans (
  loan_id      serial PRIMARY KEY,
  student_id   integer,
  book_id      integer,
  loan_date    date,
  due_date     date,
  return_date  date,
  fine_amount  numeric(8,2),
  loan_status  varchar(20)
);

-- Шкала оценок
CREATE TABLE grade_scale (
  grade_id       serial PRIMARY KEY,
  letter_grade   char(2),
  min_percentage numeric(4,1),
  max_percentage numeric(4,1),
  gpa_points     numeric(3,2),
  description    text
);

-- Календарь семестров
CREATE TABLE semester_calendar (
  semester_id          serial PRIMARY KEY,
  semester_name        varchar(20),
  academic_year        integer,
  start_date           date,
  end_date             date,
  registration_deadline timestamp with time zone,
  is_current           boolean
);

