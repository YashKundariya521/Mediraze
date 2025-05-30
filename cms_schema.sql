-- Clinic Management System (CMS) - PostgreSQL Schema

-- Enum Types for clarity and consistency
CREATE TYPE GENDER_TYPE AS ENUM ('Male', 'Female', 'Other');
CREATE TYPE APPOINTMENT_STATUS_TYPE AS ENUM ('Scheduled', 'Confirmed', 'CheckedIn', 'Completed', 'Cancelled', 'Rescheduled', 'NoShow');
CREATE TYPE VISIT_TYPE AS ENUM ('New', 'FollowUp', 'Emergency');
CREATE TYPE PAYMENT_MODE_TYPE AS ENUM ('Cash', 'UPI', 'Card', 'NetBanking', 'Cheque', 'Insurance', 'Other');
CREATE TYPE PAYMENT_STATUS_TYPE AS ENUM ('Pending', 'Paid', 'PartiallyPaid', 'Failed', 'Refunded');
CREATE TYPE ROLE_NAME_TYPE AS ENUM ('Admin', 'Doctor', 'Receptionist', 'Pharmacist', 'Patient'); -- Patient role for future portal access
CREATE TYPE INVENTORY_UNIT_TYPE AS ENUM ('Strips', 'Bottles', 'Numbers', 'Grams', 'Milliliters', 'Packets');
CREATE TYPE TREATMENT_STATUS_TYPE AS ENUM ('Scheduled', 'InProgress', 'Completed', 'Cancelled');

-- User Management and Access Control
CREATE TABLE Users (
    user_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    username VARCHAR(100) UNIQUE NOT NULL, -- Could be email or a chosen username
    password_hash TEXT NOT NULL,
    email VARCHAR(255) UNIQUE,
    mobile_number VARCHAR(20) UNIQUE,
    is_active BOOLEAN DEFAULT TRUE,
    last_login TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);
CREATE INDEX idx_users_email ON Users(email);
CREATE INDEX idx_users_mobile_number ON Users(mobile_number);

CREATE TABLE Roles (
    role_id SERIAL PRIMARY KEY,
    role_name ROLE_NAME_TYPE UNIQUE NOT NULL,
    description TEXT
);

CREATE TABLE UserRoles (
    user_role_id SERIAL PRIMARY KEY,
    user_id UUID REFERENCES Users(user_id) ON DELETE CASCADE,
    role_id INTEGER REFERENCES Roles(role_id) ON DELETE CASCADE,
    UNIQUE (user_id, role_id), -- A user has a role only once
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);
CREATE INDEX idx_userroles_user_id ON UserRoles(user_id);
CREATE INDEX idx_userroles_role_id ON UserRoles(role_id);

-- Permissions (Optional - for more granular control beyond simple roles)
CREATE TABLE Permissions (
    permission_id SERIAL PRIMARY KEY,
    permission_name VARCHAR(100) UNIQUE NOT NULL, -- e.g., 'create_patient', 'edit_doctor_schedule'
    description TEXT
);

CREATE TABLE RolePermissions (
    role_permission_id SERIAL PRIMARY KEY,
    role_id INTEGER REFERENCES Roles(role_id) ON DELETE CASCADE,
    permission_id INTEGER REFERENCES Permissions(permission_id) ON DELETE CASCADE,
    UNIQUE (role_id, permission_id),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Patient Information
CREATE TABLE Patients (
    patient_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID UNIQUE REFERENCES Users(user_id) ON DELETE SET NULL, -- Link to user account for patient portal
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    date_of_birth DATE NOT NULL,
    gender GENDER_TYPE NOT NULL,
    blood_group VARCHAR(5), -- e.g., O+, A-
    mobile_number VARCHAR(20) UNIQUE NOT NULL,
    email VARCHAR(255) UNIQUE,
    address_line1 TEXT,
    address_line2 TEXT,
    city VARCHAR(100),
    state VARCHAR(100),
    pincode VARCHAR(10),
    emergency_contact_name VARCHAR(200),
    emergency_contact_number VARCHAR(20),
    registration_date TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    photo_url TEXT, -- URL to patient's photo
    allergies TEXT, -- Could be JSONB for structured allergies
    medical_history_summary TEXT, -- Brief summary
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    created_by_user_id UUID REFERENCES Users(user_id) -- User who registered this patient
);
CREATE INDEX idx_patients_mobile_number ON Patients(mobile_number);
CREATE INDEX idx_patients_email ON Patients(email);
CREATE INDEX idx_patients_name ON Patients(first_name, last_name);

-- Doctor Information
CREATE TABLE Doctors (
    doctor_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID UNIQUE NOT NULL REFERENCES Users(user_id) ON DELETE CASCADE, -- Link to user account for login
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    registration_number VARCHAR(100) UNIQUE NOT NULL, -- Medical council registration
    specialization VARCHAR(255),
    qualifications TEXT, -- e.g., "MBBS, MD"
    years_of_experience INTEGER DEFAULT 0,
    consultation_fee NUMERIC(10, 2) DEFAULT 0.00,
    photo_url TEXT,
    bio TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);
CREATE INDEX idx_doctors_registration_number ON Doctors(registration_number);
CREATE INDEX idx_doctors_specialization ON Doctors(specialization);

CREATE TABLE DoctorAvailability (
    availability_id SERIAL PRIMARY KEY,
    doctor_id UUID NOT NULL REFERENCES Doctors(doctor_id) ON DELETE CASCADE,
    day_of_week SMALLINT NOT NULL, -- 0 for Sunday, 1 for Monday, ..., 6 for Saturday
    start_time TIME NOT NULL,
    end_time TIME NOT NULL,
    is_available BOOLEAN DEFAULT TRUE,
    notes TEXT, -- e.g., "Only for emergencies"
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    UNIQUE (doctor_id, day_of_week, start_time, end_time),
    CHECK (end_time > start_time),
    CHECK (day_of_week >= 0 AND day_of_week <= 6)
);
CREATE INDEX idx_doctoravailability_doctor_id ON DoctorAvailability(doctor_id);

-- Appointments
CREATE TABLE Appointments (
    appointment_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    patient_id UUID NOT NULL REFERENCES Patients(patient_id) ON DELETE CASCADE,
    doctor_id UUID NOT NULL REFERENCES Doctors(doctor_id) ON DELETE RESTRICT, -- Don't delete doctor if appointments exist
    appointment_datetime TIMESTAMP WITH TIME ZONE NOT NULL,
    duration_minutes INTEGER DEFAULT 30, -- Default consultation duration
    reason_for_visit TEXT,
    status APPOINTMENT_STATUS_TYPE DEFAULT 'Scheduled',
    notes TEXT, -- Receptionist notes
    booked_by_user_id UUID REFERENCES Users(user_id), -- User who booked it
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);
CREATE INDEX idx_appointments_patient_id ON Appointments(patient_id);
CREATE INDEX idx_appointments_doctor_id ON Appointments(doctor_id);
CREATE INDEX idx_appointments_datetime ON Appointments(appointment_datetime);
CREATE INDEX idx_appointments_status ON Appointments(status);

-- EMR (Electronic Medical Records)
CREATE TABLE Visits (
    visit_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    appointment_id UUID UNIQUE NOT NULL REFERENCES Appointments(appointment_id) ON DELETE CASCADE,
    patient_id UUID NOT NULL REFERENCES Patients(patient_id) ON DELETE CASCADE,
    doctor_id UUID NOT NULL REFERENCES Doctors(doctor_id) ON DELETE RESTRICT,
    visit_datetime TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    visit_type VISIT_TYPE DEFAULT 'New',
    chief_complaints TEXT,
    examination_findings TEXT,
    diagnosis TEXT, -- Could be ICD-10 codes or textual
    advice_given TEXT,
    follow_up_date DATE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);
CREATE INDEX idx_visits_patient_id ON Visits(patient_id);
CREATE INDEX idx_visits_doctor_id ON Visits(doctor_id);
CREATE INDEX idx_visits_appointment_id ON Visits(appointment_id);

CREATE TABLE Prescriptions (
    prescription_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    visit_id UUID NOT NULL REFERENCES Visits(visit_id) ON DELETE CASCADE,
    patient_id UUID NOT NULL REFERENCES Patients(patient_id) ON DELETE CASCADE,
    doctor_id UUID NOT NULL REFERENCES Doctors(doctor_id) ON DELETE RESTRICT,
    prescription_date TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    notes TEXT, -- General notes for the prescription
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);
CREATE INDEX idx_prescriptions_visit_id ON Prescriptions(visit_id);
CREATE INDEX idx_prescriptions_patient_id ON Prescriptions(patient_id);

CREATE TABLE PrescriptionItems (
    prescription_item_id SERIAL PRIMARY KEY,
    prescription_id UUID NOT NULL REFERENCES Prescriptions(prescription_id) ON DELETE CASCADE,
    medicine_id UUID, -- Can be NULL if it's an external medicine not in inventory
    medicine_name VARCHAR(255) NOT NULL, -- Store name even if medicine_id is present for history
    dosage VARCHAR(100), -- e.g., "1 tablet", "10 ml"
    frequency VARCHAR(100), -- e.g., "Twice a day", "SOS"
    duration VARCHAR(100), -- e.g., "7 days", "As needed"
    instructions TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);
CREATE INDEX idx_prescriptionitems_prescription_id ON PrescriptionItems(prescription_id);
CREATE INDEX idx_prescriptionitems_medicine_id ON PrescriptionItems(medicine_id); -- Link to Inventory.Medicines

CREATE TABLE LabResults (
    lab_result_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    visit_id UUID REFERENCES Visits(visit_id) ON DELETE SET NULL,
    patient_id UUID NOT NULL REFERENCES Patients(patient_id) ON DELETE CASCADE,
    doctor_id UUID REFERENCES Doctors(doctor_id) ON DELETE SET NULL, -- Reporting doctor
    test_name VARCHAR(255) NOT NULL,
    result_value TEXT,
    reference_range TEXT,
    result_unit VARCHAR(50),
    result_date DATE NOT NULL,
    notes TEXT,
    attachment_url TEXT, -- URL to scanned lab report PDF/image
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);
CREATE INDEX idx_labresults_patient_id ON LabResults(patient_id);
CREATE INDEX idx_labresults_visit_id ON LabResults(visit_id);

CREATE TABLE TreatmentPlans (
    treatment_plan_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    visit_id UUID NOT NULL REFERENCES Visits(visit_id) ON DELETE CASCADE,
    patient_id UUID NOT NULL REFERENCES Patients(patient_id) ON DELETE CASCADE,
    doctor_id UUID NOT NULL REFERENCES Doctors(doctor_id) ON DELETE RESTRICT,
    plan_details TEXT NOT NULL,
    start_date DATE,
    end_date DATE,
    status VARCHAR(100) DEFAULT 'Active', -- e.g., Active, Completed, Cancelled
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);
CREATE INDEX idx_treatmentplans_patient_id ON TreatmentPlans(patient_id);
CREATE INDEX idx_treatmentplans_visit_id ON TreatmentPlans(visit_id);

-- Ayurveda/Panchkarma Sessions
CREATE TABLE PanchkarmaSessions (
    session_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    visit_id UUID REFERENCES Visits(visit_id) ON DELETE SET NULL, -- Optional link to a consultation visit
    patient_id UUID NOT NULL REFERENCES Patients(patient_id) ON DELETE CASCADE,
    doctor_id UUID REFERENCES Doctors(doctor_id) ON DELETE SET NULL, -- Prescribing doctor
    treatment_name VARCHAR(255) NOT NULL, -- e.g., Abhyanga, Shirodhara
    treatment_date TIMESTAMP WITH TIME ZONE NOT NULL,
    duration_minutes INTEGER,
    therapist_name VARCHAR(200),
    oils_herbs_used TEXT,
    procedure_details TEXT,
    patient_feedback TEXT,
    status TREATMENT_STATUS_TYPE DEFAULT 'Scheduled',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);
CREATE INDEX idx_panchkarmasessions_patient_id ON PanchkarmaSessions(patient_id);
CREATE INDEX idx_panchkarmasessions_doctor_id ON PanchkarmaSessions(doctor_id);
CREATE INDEX idx_panchkarmasessions_treatment_date ON PanchkarmaSessions(treatment_date);

-- Inventory/Medicines
CREATE TABLE MedicineSuppliers (
    supplier_id SERIAL PRIMARY KEY,
    supplier_name VARCHAR(255) NOT NULL,
    contact_person VARCHAR(200),
    mobile_number VARCHAR(20),
    email VARCHAR(255),
    address TEXT,
    gstin VARCHAR(15) UNIQUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);
CREATE INDEX idx_medicinesuppliers_name ON MedicineSuppliers(supplier_name);

CREATE TABLE Medicines (
    medicine_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    medicine_name VARCHAR(255) NOT NULL,
    generic_name VARCHAR(255),
    manufacturer VARCHAR(255),
    category VARCHAR(100), -- e.g., Tablet, Syrup, Ayurvedic Churna
    unit INVENTORY_UNIT_TYPE, -- e.g., Strips, Bottles
    description TEXT,
    hsn_sac_code VARCHAR(20),
    reorder_level INTEGER DEFAULT 10,
    is_active BOOLEAN DEFAULT TRUE, -- To mark discontinued medicines
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);
CREATE INDEX idx_medicines_name ON Medicines(medicine_name);
CREATE UNIQUE INDEX idx_medicines_name_manufacturer ON Medicines(medicine_name, manufacturer); -- Assuming name + manufacturer is unique

CREATE TABLE InventoryBatches (
    batch_id SERIAL PRIMARY KEY,
    medicine_id UUID NOT NULL REFERENCES Medicines(medicine_id) ON DELETE CASCADE,
    supplier_id INTEGER REFERENCES MedicineSuppliers(supplier_id) ON DELETE SET NULL,
    batch_number VARCHAR(100) NOT NULL,
    manufacturing_date DATE,
    expiry_date DATE NOT NULL,
    purchase_price_per_unit NUMERIC(10, 2) NOT NULL,
    selling_price_per_unit NUMERIC(10, 2) NOT NULL,
    quantity_received INTEGER NOT NULL,
    current_stock INTEGER NOT NULL,
    purchase_date DATE DEFAULT CURRENT_TIMESTAMP,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    UNIQUE (medicine_id, batch_number)
);
CREATE INDEX idx_inventorybatches_medicine_id ON InventoryBatches(medicine_id);
CREATE INDEX idx_inventorybatches_expiry_date ON InventoryBatches(expiry_date);
CREATE INDEX idx_inventorybatches_batch_number ON InventoryBatches(batch_number);

-- Billing and Payments
CREATE TABLE Invoices (
    invoice_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    patient_id UUID NOT NULL REFERENCES Patients(patient_id) ON DELETE RESTRICT,
    appointment_id UUID REFERENCES Appointments(appointment_id) ON DELETE SET NULL, -- Link to appointment if bill is for consultation
    invoice_number VARCHAR(50) UNIQUE NOT NULL, -- Auto-generated or manual
    invoice_date DATE NOT NULL DEFAULT CURRENT_DATE,
    due_date DATE,
    subtotal_amount NUMERIC(12, 2) NOT NULL DEFAULT 0.00,
    total_discount_amount NUMERIC(12, 2) DEFAULT 0.00,
    total_tax_amount NUMERIC(12, 2) DEFAULT 0.00, -- Sum of all taxes
    grand_total_amount NUMERIC(12, 2) NOT NULL DEFAULT 0.00,
    amount_paid NUMERIC(12, 2) DEFAULT 0.00,
    balance_due NUMERIC(12, 2) GENERATED ALWAYS AS (grand_total_amount - amount_paid) STORED,
    payment_status PAYMENT_STATUS_TYPE DEFAULT 'Pending',
    notes TEXT,
    created_by_user_id UUID REFERENCES Users(user_id),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);
CREATE INDEX idx_invoices_patient_id ON Invoices(patient_id);
CREATE INDEX idx_invoices_invoice_date ON Invoices(invoice_date);
CREATE INDEX idx_invoices_payment_status ON Invoices(payment_status);

CREATE TABLE InvoiceItems (
    invoice_item_id SERIAL PRIMARY KEY,
    invoice_id UUID NOT NULL REFERENCES Invoices(invoice_id) ON DELETE CASCADE,
    item_type VARCHAR(100) NOT NULL, -- 'Service', 'Medicine', 'Panchkarma'
    item_id UUID, -- FK to Medicines.medicine_id or PanchkarmaSessions.session_id or other relevant table
    item_description TEXT NOT NULL, -- Store description for historical accuracy
    quantity INTEGER NOT NULL DEFAULT 1,
    unit_price NUMERIC(10, 2) NOT NULL,
    discount_percentage NUMERIC(5, 2) DEFAULT 0.00,
    discount_amount NUMERIC(10, 2) GENERATED ALWAYS AS (unit_price * quantity * discount_percentage / 100) STORED,
    taxable_amount NUMERIC(10, 2) GENERATED ALWAYS AS ((unit_price * quantity) - (unit_price * quantity * discount_percentage / 100)) STORED,
    gst_rate_cgst NUMERIC(4, 2) DEFAULT 0.00, -- e.g., 9.00 for 9%
    gst_rate_sgst NUMERIC(4, 2) DEFAULT 0.00,
    gst_rate_igst NUMERIC(4, 2) DEFAULT 0.00,
    cgst_amount NUMERIC(10, 2) GENERATED ALWAYS AS (taxable_amount * gst_rate_cgst / 100) STORED,
    sgst_amount NUMERIC(10, 2) GENERATED ALWAYS AS (taxable_amount * gst_rate_sgst / 100) STORED,
    igst_amount NUMERIC(10, 2) GENERATED ALWAYS AS (taxable_amount * gst_rate_igst / 100) STORED,
    total_item_amount NUMERIC(10, 2) GENERATED ALWAYS AS (taxable_amount + (taxable_amount * gst_rate_cgst / 100) + (taxable_amount * gst_rate_sgst / 100) + (taxable_amount * gst_rate_igst / 100)) STORED,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);
CREATE INDEX idx_invoiceitems_invoice_id ON InvoiceItems(invoice_id);
CREATE INDEX idx_invoiceitems_item_id ON InvoiceItems(item_id); -- If using item_id as FK

CREATE TABLE Payments (
    payment_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    invoice_id UUID REFERENCES Invoices(invoice_id) ON DELETE SET NULL, -- Can have payments not tied to an invoice (e.g., advance)
    patient_id UUID NOT NULL REFERENCES Patients(patient_id) ON DELETE RESTRICT,
    payment_date TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    amount_paid NUMERIC(12, 2) NOT NULL,
    payment_mode PAYMENT_MODE_TYPE NOT NULL,
    transaction_id VARCHAR(255), -- For UPI, Card transaction ID
    payment_gateway_response JSONB, -- Store response from payment gateway
    notes TEXT,
    received_by_user_id UUID REFERENCES Users(user_id),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);
CREATE INDEX idx_payments_invoice_id ON Payments(invoice_id);
CREATE INDEX idx_payments_patient_id ON Payments(patient_id);
CREATE INDEX idx_payments_payment_date ON Payments(payment_date);
CREATE INDEX idx_payments_payment_mode ON Payments(payment_mode);

-- Audit Trail (Simple version)
CREATE TABLE AuditLogs (
    log_id SERIAL PRIMARY KEY,
    user_id UUID REFERENCES Users(user_id) ON DELETE SET NULL,
    action VARCHAR(255) NOT NULL, -- e.g., 'PATIENT_REGISTERED', 'INVOICE_CREATED'
    table_name VARCHAR(100),
    record_id TEXT, -- Can be UUID or integer ID, stored as text
    details JSONB, -- Store old and new values, or other relevant info
    log_timestamp TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);
CREATE INDEX idx_auditlogs_user_id ON AuditLogs(user_id);
CREATE INDEX idx_auditlogs_timestamp ON AuditLogs(log_timestamp);
CREATE INDEX idx_auditlogs_action ON AuditLogs(action);


-- Functions to update 'updated_at' columns
CREATE OR REPLACE FUNCTION trigger_set_timestamp()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = CURRENT_TIMESTAMP;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Apply the trigger to tables with 'updated_at'
CREATE TRIGGER set_timestamp_users BEFORE UPDATE ON Users FOR EACH ROW EXECUTE PROCEDURE trigger_set_timestamp();
CREATE TRIGGER set_timestamp_patients BEFORE UPDATE ON Patients FOR EACH ROW EXECUTE PROCEDURE trigger_set_timestamp();
CREATE TRIGGER set_timestamp_doctors BEFORE UPDATE ON Doctors FOR EACH ROW EXECUTE PROCEDURE trigger_set_timestamp();
CREATE TRIGGER set_timestamp_doctor_availability BEFORE UPDATE ON DoctorAvailability FOR EACH ROW EXECUTE PROCEDURE trigger_set_timestamp();
CREATE TRIGGER set_timestamp_appointments BEFORE UPDATE ON Appointments FOR EACH ROW EXECUTE PROCEDURE trigger_set_timestamp();
CREATE TRIGGER set_timestamp_visits BEFORE UPDATE ON Visits FOR EACH ROW EXECUTE PROCEDURE trigger_set_timestamp();
CREATE TRIGGER set_timestamp_prescriptions BEFORE UPDATE ON Prescriptions FOR EACH ROW EXECUTE PROCEDURE trigger_set_timestamp();
CREATE TRIGGER set_timestamp_lab_results BEFORE UPDATE ON LabResults FOR EACH ROW EXECUTE PROCEDURE trigger_set_timestamp();
CREATE TRIGGER set_timestamp_treatment_plans BEFORE UPDATE ON TreatmentPlans FOR EACH ROW EXECUTE PROCEDURE trigger_set_timestamp();
CREATE TRIGGER set_timestamp_panchkarma_sessions BEFORE UPDATE ON PanchkarmaSessions FOR EACH ROW EXECUTE PROCEDURE trigger_set_timestamp();
CREATE TRIGGER set_timestamp_medicine_suppliers BEFORE UPDATE ON MedicineSuppliers FOR EACH ROW EXECUTE PROCEDURE trigger_set_timestamp();
CREATE TRIGGER set_timestamp_medicines BEFORE UPDATE ON Medicines FOR EACH ROW EXECUTE PROCEDURE trigger_set_timestamp();
CREATE TRIGGER set_timestamp_inventory_batches BEFORE UPDATE ON InventoryBatches FOR EACH ROW EXECUTE PROCEDURE trigger_set_timestamp();
CREATE TRIGGER set_timestamp_invoices BEFORE UPDATE ON Invoices FOR EACH ROW EXECUTE PROCEDURE trigger_set_timestamp();
CREATE TRIGGER set_timestamp_payments BEFORE UPDATE ON Payments FOR EACH ROW EXECUTE PROCEDURE trigger_set_timestamp();

-- Default Roles
INSERT INTO Roles (role_name, description) VALUES
('Admin', 'System Administrator with full access'),
('Doctor', 'Medical doctor with access to patient records and EMR'),
('Receptionist', 'Handles appointments, patient registration, and billing'),
('Pharmacist', 'Manages pharmacy inventory and dispenses medication'),
('Patient', 'Patient access for viewing records, appointments (future portal)')
ON CONFLICT (role_name) DO NOTHING;

-- (Optional) Default Permissions - Add as needed
-- INSERT INTO Permissions (permission_name, description) VALUES ('manage_users', 'Ability to create, edit, delete users');
-- INSERT INTO RolePermissions (role_id, permission_id) SELECT r.role_id, p.permission_id FROM Roles r, Permissions p WHERE r.role_name = 'Admin' AND p.permission_name = 'manage_users';

-- End of Schema
