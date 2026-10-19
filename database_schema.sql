-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Create universities table
CREATE TABLE universities (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    name TEXT NOT NULL,
    city TEXT NOT NULL,
    type TEXT NOT NULL CHECK (type IN ('public', 'private')),
    website TEXT NOT NULL,
    logo_url TEXT,
    source_link TEXT NOT NULL,
    last_verified DATE NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create programs table
CREATE TABLE programs (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    university_id UUID NOT NULL REFERENCES universities(id) ON DELETE CASCADE,
    name TEXT NOT NULL,
    degree_level TEXT NOT NULL,
    duration TEXT NOT NULL,
    tuition_fee DECIMAL(10, 2) NOT NULL,
    fee_period TEXT NOT NULL CHECK (fee_period IN ('semester', 'year')),
    registration_fee DECIMAL(10, 2),
    deadline DATE,
    eligibility TEXT,
    source_link TEXT NOT NULL,
    last_verified DATE NOT NULL,
    status TEXT NOT NULL DEFAULT 'pending' CHECK (status IN ('pending', 'approved')),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Enable Row Level Security
ALTER TABLE universities ENABLE ROW LEVEL SECURITY;
ALTER TABLE programs ENABLE ROW LEVEL SECURITY;

-- Create policy for universities: anyone can read approved universities
CREATE POLICY "Universities are viewable by everyone"
    ON universities FOR SELECT
    USING (true);

-- Create policy for programs: anyone can read only approved programs
CREATE POLICY "Only approved programs are viewable"
    ON programs FOR SELECT
    USING (status = 'approved');

-- Create index on programs status for better query performance
CREATE INDEX idx_programs_status ON programs(status);
CREATE INDEX idx_programs_university_id ON programs(university_id);

-- Insert sample universities with fake data
INSERT INTO universities (name, city, type, website, logo_url, source_link, last_verified) VALUES
('University of Engineering and Technology, Lahore', 'Lahore', 'public', 'https://uet.edu.pk', 'https://example.com/uet-logo.png', 'https://uet.edu.pk/admissions', '2026-10-01'),
('Lahore University of Management Sciences', 'Lahore', 'private', 'https://lums.edu.pk', 'https://example.com/lums-logo.png', 'https://lums.edu.pk/admissions', '2026-10-01'),
('National University of Sciences and Technology', 'Islamabad', 'public', 'https://nust.edu.pk', 'https://example.com/nust-logo.png', 'https://nust.edu.pk/admissions', '2026-10-01'),
('Quaid-i-Azam University', 'Islamabad', 'public', 'https://qau.edu.pk', 'https://example.com/qau-logo.png', 'https://qau.edu.pk/admissions', '2026-10-01'),
('Aga Khan University', 'Karachi', 'private', 'https://aku.edu', 'https://example.com/aku-logo.png', 'https://aku.edu/admissions', '2026-10-01');

-- Insert sample programs (approved status)
INSERT INTO programs (university_id, name, degree_level, duration, tuition_fee, fee_period, registration_fee, deadline, eligibility, source_link, last_verified, status) VALUES
-- UET Lahore programs
((SELECT id FROM universities WHERE name = 'University of Engineering and Technology, Lahore'), 'Computer Science', 'Bachelors', '4 years', 85000.00, 'semester', 50000.00, '2026-08-15', 'FSc Pre-Engineering with 60% marks', 'https://uet.edu.pk/cs', '2026-10-01', 'approved'),
((SELECT id FROM universities WHERE name = 'University of Engineering and Technology, Lahore'), 'Electrical Engineering', 'Bachelors', '4 years', 90000.00, 'semester', 50000.00, '2026-08-15', 'FSc Pre-Engineering with 60% marks', 'https://uet.edu.pk/ee', '2026-10-01', 'approved'),
-- LUMS programs
((SELECT id FROM universities WHERE name = 'Lahore University of Management Sciences'), 'Computer Science', 'Bachelors', '4 years', 450000.00, 'semester', 150000.00, '2026-06-30', 'FSc with 85% marks + LUMS Admission Test', 'https://lums.edu.pk/cs', '2026-10-01', 'approved'),
((SELECT id FROM universities WHERE name = 'Lahore University of Management Sciences'), 'Business Administration', 'Bachelors', '4 years', 420000.00, 'semester', 150000.00, '2026-06-30', 'FSc with 80% marks + LUMS Admission Test', 'https://lums.edu.pk/bba', '2026-10-01', 'approved'),
-- NUST programs
((SELECT id FROM universities WHERE name = 'National University of Sciences and Technology'), 'Computer Science', 'Bachelors', '4 years', 120000.00, 'semester', 35000.00, '2026-07-15', 'FSc Pre-Engineering with 70% marks + NET', 'https://nust.edu.pk/cs', '2026-10-01', 'approved'),
((SELECT id FROM universities WHERE name = 'National University of Sciences and Technology'), 'Electrical Engineering', 'Bachelors', '4 years', 110000.00, 'semester', 35000.00, '2026-07-15', 'FSc Pre-Engineering with 70% marks + NET', 'https://nust.edu.pk/ee', '2026-10-01', 'approved'),
-- QAU programs
((SELECT id FROM universities WHERE name = 'Quaid-i-Azam University'), 'Computer Science', 'Bachelors', '4 years', 45000.00, 'semester', 25000.00, '2026-08-01', 'FSc Pre-Engineering with 50% marks', 'https://qau.edu.pk/cs', '2026-10-01', 'approved'),
((SELECT id FROM universities WHERE name = 'Quaid-i-Azam University'), 'Physics', 'Bachelors', '4 years', 40000.00, 'semester', 25000.00, '2026-08-01', 'FSc Pre-Medical/Engineering with 50% marks', 'https://qau.edu.pk/physics', '2026-10-01', 'approved'),
-- AKU programs
((SELECT id FROM universities WHERE name = 'Aga Khan University'), 'Medical Sciences', 'Bachelors', '5 years', 850000.00, 'year', 300000.00, '2026-06-01', 'FSc Pre-Medical with 85% marks + AKU Admission Test', 'https://aku.edu/medical', '2026-10-01', 'approved'),
((SELECT id FROM universities WHERE name = 'Aga Khan University'), 'Nursing', 'Bachelors', '4 years', 550000.00, 'year', 200000.00, '2026-06-01', 'FSc Pre-Medical with 70% marks + AKU Admission Test', 'https://aku.edu/nursing', '2026-10-01', 'approved');
