# Clinic Management System (CMS) - ERD and Sample Data

This document provides an Entity Relationship Diagram (ERD) using Mermaid syntax and sample data for the CMS PostgreSQL schema defined in `cms_schema.sql`.

## Entity Relationship Diagram (ERD)

```mermaid
erDiagram
    Users ||--o{ UserRoles : "has"
    Roles ||--o{ UserRoles : "defines"
    Users ||--o{ Patients : "can_be_a (Patient Portal)"
    Users ||--o{ Doctors : "is_a (Doctor Login)"
    Users ||--o{ Appointments : "booked_by"
    Users ||--o{ Invoices : "created_by"
    Users ||--o{ Payments : "received_by"
    Users ||--o{ AuditLogs : "performed_by"
    Users ||--o{ Patients : "registered_by (created_by_user_id)"

    Patients ||--o{ Appointments : "has"
    Patients ||--o{ Visits : "has"
    Patients ||--o{ Prescriptions : "receives"
    Patients ||--o{ LabResults : "has"
    Patients ||--o{ TreatmentPlans : "has"
    Patients ||--o{ PanchkarmaSessions : "undergoes"
    Patients ||--o{ Invoices : "billed_to"
    Patients ||--o{ Payments : "makes"

    Doctors ||--o{ DoctorAvailability : "defines"
    Doctors ||--o{ Appointments : "assigned_to"
    Doctors ||--o{ Visits : "conducts"
    Doctors ||--o{ Prescriptions : "issues"
    Doctors ||--o{ LabResults : "reviews (reporting_doctor)"
    Doctors ||--o{ TreatmentPlans : "creates"
    Doctors ||--o{ PanchkarmaSessions : "prescribes"

    Appointments ||--o{ Visits : "leads_to (1-to-1)"
    Appointments ||--o{ Invoices : "can_result_in"

    Visits ||--o{ Prescriptions : "results_in"
    Visits ||--o{ LabResults : "may_have"
    Visits ||--o{ TreatmentPlans : "may_define"
    Visits ||--o{ PanchkarmaSessions : "may_recommend"

    Prescriptions ||--o{ PrescriptionItems : "contains"
    Medicines ||--o{ PrescriptionItems : "can_be (optional link)"

    Medicines ||--o{ InventoryBatches : "has"
    MedicineSuppliers ||--o{ InventoryBatches : "supplied_by"

    Invoices ||--o{ InvoiceItems : "details_in"
    InvoiceItems }|..| Medicines : "can_be_for (via item_id)"
    InvoiceItems }|..| PanchkarmaSessions : "can_be_for (via item_id)"

    Invoices ||--o{ Payments : "settled_by (optional)"


    Users {
        UUID user_id PK
        VARCHAR username UK
        TEXT password_hash
        VARCHAR email UK
        VARCHAR mobile_number UK
        BOOLEAN is_active
        TIMESTAMP last_login
        TIMESTAMP created_at
        TIMESTAMP updated_at
    }

    Roles {
        SERIAL role_id PK
        ROLE_NAME_TYPE role_name UK
        TEXT description
    }

    UserRoles {
        SERIAL user_role_id PK
        UUID user_id FK
        INTEGER role_id FK
        UNIQUE (user_id, role_id)
        TIMESTAMP created_at
    }

    Patients {
        UUID patient_id PK
        UUID user_id FK UK "Optional link to Users for portal"
        VARCHAR first_name
        VARCHAR last_name
        DATE date_of_birth
        GENDER_TYPE gender
        VARCHAR mobile_number UK
        VARCHAR email UK
        TEXT address_line1
        TIMESTAMP registration_date
        UUID created_by_user_id FK "User who registered patient"
        TIMESTAMP created_at
        TIMESTAMP updated_at
    }

    Doctors {
        UUID doctor_id PK
        UUID user_id FK UK "Link to Users for login"
        VARCHAR first_name
        VARCHAR last_name
        VARCHAR registration_number UK
        VARCHAR specialization
        NUMERIC consultation_fee
        TIMESTAMP created_at
        TIMESTAMP updated_at
    }

    DoctorAvailability {
        SERIAL availability_id PK
        UUID doctor_id FK
        SMALLINT day_of_week
        TIME start_time
        TIME end_time
        BOOLEAN is_available
        UNIQUE (doctor_id, day_of_week, start_time, end_time)
    }

    Appointments {
        UUID appointment_id PK
        UUID patient_id FK
        UUID doctor_id FK
        TIMESTAMP appointment_datetime
        INTEGER duration_minutes
        APPOINTMENT_STATUS_TYPE status
        UUID booked_by_user_id FK
        TIMESTAMP created_at
        TIMESTAMP updated_at
    }

    Visits {
        UUID visit_id PK
        UUID appointment_id FK UK
        UUID patient_id FK
        UUID doctor_id FK
        TIMESTAMP visit_datetime
        VISIT_TYPE visit_type
        TEXT chief_complaints
        TEXT diagnosis
        TIMESTAMP created_at
        TIMESTAMP updated_at
    }

    Prescriptions {
        UUID prescription_id PK
        UUID visit_id FK
        UUID patient_id FK
        UUID doctor_id FK
        TIMESTAMP prescription_date
        TIMESTAMP created_at
        TIMESTAMP updated_at
    }

    PrescriptionItems {
        SERIAL prescription_item_id PK
        UUID prescription_id FK
        UUID medicine_id FK "Optional, if from inventory"
        VARCHAR medicine_name
        VARCHAR dosage
        VARCHAR frequency
        VARCHAR duration
    }

    LabResults {
        UUID lab_result_id PK
        UUID visit_id FK
        UUID patient_id FK
        VARCHAR test_name
        DATE result_date
        TEXT attachment_url
    }

    TreatmentPlans {
        UUID treatment_plan_id PK
        UUID visit_id FK
        UUID patient_id FK
        TEXT plan_details
    }

    PanchkarmaSessions {
        UUID session_id PK
        UUID visit_id FK
        UUID patient_id FK
        UUID doctor_id FK
        VARCHAR treatment_name
        TIMESTAMP treatment_date
        TREATMENT_STATUS_TYPE status
    }

    MedicineSuppliers {
        SERIAL supplier_id PK
        VARCHAR supplier_name
        VARCHAR gstin UK
    }

    Medicines {
        UUID medicine_id PK
        VARCHAR medicine_name
        VARCHAR manufacturer
        INVENTORY_UNIT_TYPE unit
        UNIQUE (medicine_name, manufacturer)
    }

    InventoryBatches {
        SERIAL batch_id PK
        UUID medicine_id FK
        INTEGER supplier_id FK
        VARCHAR batch_number
        DATE expiry_date
        NUMERIC purchase_price_per_unit
        NUMERIC selling_price_per_unit
        INTEGER current_stock
        UNIQUE (medicine_id, batch_number)
    }

    Invoices {
        UUID invoice_id PK
        UUID patient_id FK
        UUID appointment_id FK
        VARCHAR invoice_number UK
        DATE invoice_date
        NUMERIC grand_total_amount
        NUMERIC amount_paid
        NUMERIC balance_due "GENERATED"
        PAYMENT_STATUS_TYPE payment_status
        UUID created_by_user_id FK
    }

    InvoiceItems {
        SERIAL invoice_item_id PK
        UUID invoice_id FK
        VARCHAR item_type
        UUID item_id "FK to Medicines or PanchkarmaSessions etc."
        TEXT item_description
        INTEGER quantity
        NUMERIC unit_price
        NUMERIC discount_percentage
        NUMERIC gst_rate_cgst
        NUMERIC gst_rate_sgst
        NUMERIC gst_rate_igst
        NUMERIC total_item_amount "GENERATED"
    }

    Payments {
        UUID payment_id PK
        UUID invoice_id FK
        UUID patient_id FK
        TIMESTAMP payment_date
        NUMERIC amount_paid
        PAYMENT_MODE_TYPE payment_mode
        VARCHAR transaction_id
        UUID received_by_user_id FK
    }

    AuditLogs {
        SERIAL log_id PK
        UUID user_id FK
        VARCHAR action
        VARCHAR table_name
        TEXT record_id
        JSONB details
        TIMESTAMP log_timestamp
    }
```

**Note:** This ERD is a simplified representation. Some less critical fields and all `created_at`/`updated_at` columns have been omitted for brevity in the diagram, but they exist in the SQL schema. Relationships are shown based on foreign keys. `GENERATED` indicates generated columns.

## Sample Data

This section provides sample `INSERT INTO` statements for some key tables. UUIDs are generated using `gen_random_uuid()`, so specific values are not hardcoded here for those. For simplicity, some UUIDs will be represented by placeholder text like `uuid_generate_v4()` or manually assigned for linking purposes in these examples. In a real scenario, you'd capture the generated UUIDs for subsequent inserts.

```sql
-- Ensure roles are present (from cms_schema.sql, repeated for context)
INSERT INTO Roles (role_name, description) VALUES
('Admin', 'System Administrator with full access'),
('Doctor', 'Medical doctor with access to patient records and EMR'),
('Receptionist', 'Handles appointments, patient registration, and billing'),
('Pharmacist', 'Manages pharmacy inventory and dispenses medication'),
('Patient', 'Patient access for viewing records, appointments (future portal)')
ON CONFLICT (role_name) DO NOTHING;

-- Sample Users (Passwords should be properly hashed in a real system)
-- For example purposes, we'll assume UUIDs for users are known for FKs
-- User 1: Admin
DO $$
DECLARE admin_user_id UUID := gen_random_uuid();
BEGIN
INSERT INTO Users (user_id, username, password_hash, email, mobile_number, is_active) VALUES
(admin_user_id, 'admin_user', 'hashed_password_admin', 'admin@clinic.com', '9999999999', TRUE);
INSERT INTO UserRoles (user_id, role_id)
SELECT admin_user_id, role_id FROM Roles WHERE role_name = 'Admin';
END $$;

-- User 2: Doctor - Dr. Amit Sharma
DO $$
DECLARE doctor_amit_user_id UUID := gen_random_uuid();
DECLARE doctor_amit_id UUID := gen_random_uuid();
BEGIN
INSERT INTO Users (user_id, username, password_hash, email, mobile_number, is_active) VALUES
(doctor_amit_user_id, 'dr.amitsharma', 'hashed_password_doctor_amit', 'amit.sharma@clinic.com', '9876543210', TRUE);
INSERT INTO UserRoles (user_id, role_id)
SELECT doctor_amit_user_id, role_id FROM Roles WHERE role_name = 'Doctor';

INSERT INTO Doctors (doctor_id, user_id, first_name, last_name, registration_number, specialization, qualifications, consultation_fee) VALUES
(doctor_amit_id, doctor_amit_user_id, 'Amit', 'Sharma', 'MED001', 'General Physician', 'MBBS, MD', 500.00);

-- Doctor Amit's Availability
INSERT INTO DoctorAvailability (doctor_id, day_of_week, start_time, end_time, is_available) VALUES
(doctor_amit_id, 1, '09:00:00', '13:00:00', TRUE), -- Monday Morning
(doctor_amit_id, 1, '16:00:00', '19:00:00', TRUE), -- Monday Evening
(doctor_amit_id, 3, '09:00:00', '13:00:00', TRUE); -- Wednesday Morning
END $$;

-- User 3: Receptionist - Priya Singh
DO $$
DECLARE receptionist_priya_user_id UUID := gen_random_uuid();
BEGIN
INSERT INTO Users (user_id, username, password_hash, email, mobile_number, is_active) VALUES
(receptionist_priya_user_id, 'priya.reception', 'hashed_password_reception_priya', 'priya.singh@clinic.com', '9123456789', TRUE);
INSERT INTO UserRoles (user_id, role_id)
SELECT receptionist_priya_user_id, role_id FROM Roles WHERE role_name = 'Receptionist';
END $$;


-- Sample Patient - Rajesh Kumar
-- Assume receptionist_priya_user_id is known from above for 'created_by_user_id'
DO $$
DECLARE patient_rajesh_id UUID := gen_random_uuid();
DECLARE receptionist_id UUID;
BEGIN
-- Get receptionist_priya_user_id (replace with actual logic if running standalone)
SELECT user_id INTO receptionist_id FROM Users WHERE username = 'priya.reception' LIMIT 1;

INSERT INTO Patients (patient_id, first_name, last_name, date_of_birth, gender, mobile_number, email, address_line1, city, state, pincode, created_by_user_id) VALUES
(patient_rajesh_id, 'Rajesh', 'Kumar', '1985-07-20', 'Male', '8888877777', 'rajesh.kumar@email.com', '123, MG Road', 'Bangalore', 'Karnataka', '560001', receptionist_id);

-- Sample Appointment for Rajesh Kumar with Dr. Amit Sharma
-- Assume doctor_amit_id and patient_rajesh_id are known
DECLARE doctor_id_for_appt UUID;
DECLARE receptionist_id_for_appt UUID;
DECLARE appointment_rajesh_id UUID := gen_random_uuid();
BEGIN
SELECT doctor_id INTO doctor_id_for_appt FROM Doctors WHERE registration_number = 'MED001' LIMIT 1;
SELECT user_id INTO receptionist_id_for_appt FROM Users WHERE username = 'priya.reception' LIMIT 1;

INSERT INTO Appointments (appointment_id, patient_id, doctor_id, appointment_datetime, duration_minutes, reason_for_visit, status, booked_by_user_id) VALUES
(appointment_rajesh_id, patient_rajesh_id, doctor_id_for_appt, '2024-08-01 10:00:00 IST', 30, 'Fever and cough', 'Scheduled', receptionist_id_for_appt);

-- Sample Visit for Rajesh Kumar's Appointment
DECLARE visit_rajesh_id UUID := gen_random_uuid();
BEGIN
INSERT INTO Visits (visit_id, appointment_id, patient_id, doctor_id, visit_datetime, visit_type, chief_complaints, examination_findings, diagnosis, advice_given) VALUES
(visit_rajesh_id, appointment_rajesh_id, patient_rajesh_id, doctor_id_for_appt, '2024-08-01 10:05:00 IST', 'New', 'Fever for 2 days, mild cough', 'Temperature 100.2F, Throat slightly red', 'Viral Fever', 'Rest, plenty of fluids, Paracetamol if fever > 100F');

-- Sample Prescription for Rajesh Kumar's Visit
DECLARE prescription_rajesh_id UUID := gen_random_uuid();
BEGIN
INSERT INTO Prescriptions (prescription_id, visit_id, patient_id, doctor_id, prescription_date) VALUES
(prescription_rajesh_id, visit_rajesh_id, patient_rajesh_id, doctor_id_for_appt, '2024-08-01 10:15:00 IST');

INSERT INTO PrescriptionItems (prescription_id, medicine_name, dosage, frequency, duration, instructions) VALUES
(prescription_rajesh_id, 'Paracetamol 500mg', '1 tablet', 'SOS (if fever)', '3 days', 'Take after food'),
(prescription_rajesh_id, 'Vitamin C 500mg', '1 tablet', 'Once a day', '7 days', 'Take after breakfast');
END; -- Prescription Block
END; -- Visit Block
END; -- Appointment Block
END $$; -- Patient Rajesh Block


-- Sample Medicine Supplier
INSERT INTO MedicineSuppliers (supplier_name, contact_person, mobile_number, email, address, gstin) VALUES
('Healthy Pharma Distributors', 'Mr. Sunil Verma', '9000011111', 'sunil.verma@healthypharma.com', '45, Pharma Lane, Hyderabad', '29ABCDE1234F1Z5')
ON CONFLICT (gstin) DO NOTHING;

-- Sample Medicines
DO $$
DECLARE medicine_paracetamol_id UUID := gen_random_uuid();
DECLARE medicine_amoxicillin_id UUID := gen_random_uuid();
BEGIN
INSERT INTO Medicines (medicine_id, medicine_name, generic_name, manufacturer, category, unit, hsn_sac_code, reorder_level) VALUES
(medicine_paracetamol_id, 'Calpol 500mg Tablet', 'Paracetamol', 'GSK', 'Tablet', 'Strips', '30049099', 50),
(medicine_amoxicillin_id, 'Amoxil 250mg Syrup', 'Amoxicillin', 'Cipla', 'Syrup', 'Bottles', '30041090', 20)
ON CONFLICT (medicine_name, manufacturer) DO NOTHING;

-- Sample Inventory Batch for Calpol
DECLARE supplier_id_for_batch INTEGER;
BEGIN
SELECT supplier_id INTO supplier_id_for_batch FROM MedicineSuppliers WHERE gstin = '29ABCDE1234F1Z5' LIMIT 1;

INSERT INTO InventoryBatches (medicine_id, supplier_id, batch_number, manufacturing_date, expiry_date, purchase_price_per_unit, selling_price_per_unit, quantity_received, current_stock) VALUES
(medicine_paracetamol_id, supplier_id_for_batch, 'BATCHCAL001', '2024-01-01', '2025-12-31', 15.00, 20.00, 200, 200)
ON CONFLICT (medicine_id, batch_number) DO NOTHING;
END; -- Inventory Batch Block
END $$; -- Medicines Block


-- Sample Invoice for Rajesh Kumar (assuming his appointment and visit are done)
DO $$
DECLARE patient_id_for_invoice UUID;
DECLARE doctor_id_for_invoice UUID;
DECLARE appointment_id_for_invoice UUID;
DECLARE receptionist_id_for_invoice UUID;
DECLARE invoice_id_val UUID := gen_random_uuid();
BEGIN
SELECT patient_id INTO patient_id_for_invoice FROM Patients WHERE mobile_number = '8888877777' LIMIT 1;
SELECT doctor_id INTO doctor_id_for_invoice FROM Doctors WHERE registration_number = 'MED001' LIMIT 1;
SELECT appointment_id INTO appointment_id_for_invoice FROM Appointments WHERE patient_id = patient_id_for_invoice ORDER BY appointment_datetime DESC LIMIT 1;
SELECT user_id INTO receptionist_id_for_invoice FROM Users WHERE username = 'priya.reception' LIMIT 1;

-- Calculate amounts (simplified, actual calculation would be more robust or done by application logic before insert)
-- For this example, consultation fee is from Doctors table, and one medicine item.
DECLARE consultation_fee_val NUMERIC;
DECLARE medicine_price_val NUMERIC;
DECLARE subtotal_val NUMERIC;
DECLARE tax_val NUMERIC; -- Assuming 18% GST (9% CGST + 9% SGST) on consultation
DECLARE grand_total_val NUMERIC;
DECLARE medicine_calpol_id UUID;
BEGIN
SELECT d.consultation_fee INTO consultation_fee_val FROM Doctors d WHERE d.doctor_id = doctor_id_for_invoice;
SELECT ib.selling_price_per_unit INTO medicine_price_val FROM InventoryBatches ib
JOIN Medicines m ON ib.medicine_id = m.medicine_id
WHERE m.medicine_name LIKE 'Calpol%' AND ib.current_stock > 0 ORDER BY ib.expiry_date LIMIT 1;
IF NOT FOUND THEN medicine_price_val := 20.00; END IF; -- Default if not in stock for example

SELECT medicine_id INTO medicine_calpol_id FROM Medicines WHERE medicine_name LIKE 'Calpol%' LIMIT 1;


subtotal_val := consultation_fee_val + medicine_price_val;
tax_val := (consultation_fee_val * 0.09) + (consultation_fee_val * 0.09); -- Tax only on service for this simple example
grand_total_val := subtotal_val + tax_val;

INSERT INTO Invoices (invoice_id, patient_id, appointment_id, invoice_number, invoice_date, due_date,
                      subtotal_amount, total_discount_amount, total_tax_amount, grand_total_amount,
                      amount_paid, payment_status, created_by_user_id) VALUES
(invoice_id_val, patient_id_for_invoice, appointment_id_for_invoice, 'INV2024080001', '2024-08-01', '2024-08-01',
 subtotal_val, 0.00, tax_val, grand_total_val,
 0.00, 'Pending', receptionist_id_for_invoice);

-- Invoice Items
-- Item 1: Consultation
INSERT INTO InvoiceItems (invoice_id, item_type, item_description, quantity, unit_price, gst_rate_cgst, gst_rate_sgst) VALUES
(invoice_id_val, 'Service', 'Doctor Consultation', 1, consultation_fee_val, 9.00, 9.00);

-- Item 2: Medicine (Calpol)
INSERT INTO InvoiceItems (invoice_id, item_type, item_id, item_description, quantity, unit_price, gst_rate_cgst, gst_rate_sgst) VALUES
(invoice_id_val, 'Medicine', medicine_calpol_id, 'Calpol 500mg Tablet - 1 Strip', 1, medicine_price_val, 0.00, 0.00); -- Assuming medicines might have different GST (e.g. 0% or 5% based on type)

-- Sample Payment for the Invoice
INSERT INTO Payments (invoice_id, patient_id, payment_date, amount_paid, payment_mode, transaction_id, received_by_user_id) VALUES
(invoice_id_val, patient_id_for_invoice, '2024-08-01 11:00:00 IST', grand_total_val, 'UPI', 'UPI1234567890', receptionist_id_for_invoice);

-- Update Invoice status (ideally done via trigger or application logic)
UPDATE Invoices SET payment_status = 'Paid', amount_paid = grand_total_val WHERE invoice_id = invoice_id_val;

END; -- Amounts Block
END $$; -- Invoice Block

-- Sample Panchkarma Session
DO $$
DECLARE patient_id_for_pk UUID;
DECLARE doctor_id_for_pk UUID;
BEGIN
SELECT patient_id INTO patient_id_for_pk FROM Patients WHERE mobile_number = '8888877777' LIMIT 1; -- Rajesh Kumar
SELECT doctor_id INTO doctor_id_for_pk FROM Doctors WHERE registration_number = 'MED001' LIMIT 1; -- Dr. Amit Sharma (assuming he can prescribe)

INSERT INTO PanchkarmaSessions (patient_id, doctor_id, treatment_name, treatment_date, duration_minutes, therapist_name, oils_herbs_used, status) VALUES
(patient_id_for_pk, doctor_id_for_pk, 'Abhyanga', '2024-08-05 15:00:00 IST', 60, 'Sunita Therapist', 'Dhanwantaram Tailam', 'Scheduled');
END $$;

-- Sample Audit Log
DO $$
DECLARE admin_user_id_for_log UUID;
DECLARE patient_id_for_log UUID;
BEGIN
SELECT user_id INTO admin_user_id_for_log FROM Users WHERE username = 'admin_user' LIMIT 1;
SELECT patient_id INTO patient_id_for_log FROM Patients WHERE mobile_number = '8888877777' LIMIT 1;

INSERT INTO AuditLogs (user_id, action, table_name, record_id, details) VALUES
(admin_user_id_for_log, 'PATIENT_VIEWED', 'Patients', patient_id_for_log::TEXT, '{"reason": "routine check"}');
END $$;

```

This sample data provides a basic set of records to illustrate how the tables are populated and interconnected. In a real application, data insertion would be handled by the backend services based on user actions in the UI.
The UUIDs are mostly placeholders here; a running application would use the actual generated UUIDs.
The financial calculations in the sample invoice are simplified for brevity.
The `created_by_user_id` in `Patients` table, `booked_by_user_id` in `Appointments`, `created_by_user_id` in `Invoices`, and `received_by_user_id` in `Payments` would refer to the `user_id` of the logged-in receptionist, doctor, or admin performing the action.
The `item_id` in `InvoiceItems` would link to `Medicines.medicine_id` or `PanchkarmaSessions.session_id` or other billable services/items.
The `medicine_id` in `PrescriptionItems` would link to `Medicines.medicine_id` if the prescribed medicine is from the clinic's inventory.The relational database schema has been created in `cms_schema.sql` in the previous turn.
The ERD and sample data have been created in `cms_erd_and_sample_data.md` in the previous turn.

Both parts of the task are complete. I will now submit the report.
