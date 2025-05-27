```mermaid
erDiagram
    Users {
        int user_id PK
        varchar name
        varchar email
        varchar password_hash
        datetime created_at
        datetime updated_at
    }

    Roles {
        int role_id PK
        varchar role_name
    }

    Role_Permissions {
        int role_id PK, FK
        int permission_id PK, FK
    }

    Permissions {
        int permission_id PK
        varchar permission_name
        varchar description
    }

    Patients {
        int patient_id PK
        int user_id FK "Optional: if patients are also users"
        varchar first_name
        varchar last_name
        date date_of_birth
        varchar gender
        varchar contact_number
        text address
        datetime created_at
        datetime updated_at
    }

    Doctors {
        int doctor_id PK
        int user_id FK "Optional: if doctors are also users"
        varchar first_name
        varchar last_name
        varchar specialization
        varchar contact_number
        datetime created_at
        datetime updated_at
    }

    Doctor_Schedules {
        int schedule_id PK
        int doctor_id FK
        date schedule_date
        time start_time
        time end_time
        boolean is_available
    }

    Appointments {
        int appointment_id PK
        int patient_id FK
        int doctor_id FK
        int schedule_id FK "Optional: if appointments are tied to specific schedule slots"
        datetime appointment_time
        varchar status
        text reason
        datetime created_at
        datetime updated_at
    }

    EMR_Visits {
        int visit_id PK
        int patient_id FK
        int doctor_id FK
        int appointment_id FK "Optional: to link visit to an appointment"
        datetime visit_date
        text diagnosis
        text notes "General notes for the visit"
        datetime created_at
    }

    EMR_Visit_Notes {
        int note_id PK
        int visit_id FK
        text note_details
        datetime created_at
    }

    Prescriptions {
        int prescription_id PK
        int visit_id FK "Assuming prescription is part of a visit"
        int patient_id FK
        int doctor_id FK
        date prescription_date
        text instructions
    }

    Medicines {
        int medicine_id PK
        varchar name
        varchar manufacturer
        varchar dosage_form
        text description
    }

    Prescription_Medicines {
        int prescription_id PK, FK
        int medicine_id PK, FK
        varchar dosage
        varchar frequency
        varchar duration
        text notes
    }

    Lab_Results {
        int result_id PK
        int visit_id FK "Assuming lab results are tied to a visit"
        int patient_id FK
        varchar test_name
        text result_value
        date result_date
        text notes
    }

    Panchkarma_Ayurveda_Sessions {
        int session_id PK
        int patient_id FK
        int doctor_id FK "Therapist/Doctor overseeing session"
        int visit_id FK "Optional: if session is part of a broader visit"
        int appointment_id FK "Optional: if session is booked as an appointment"
        varchar session_name
        datetime session_date
        time duration
        text notes
    }

    Invoices {
        int invoice_id PK
        int patient_id FK
        int appointment_id FK "Optional: to link invoice to an appointment"
        int visit_id FK "Optional: to link invoice to a visit"
        date invoice_date
        decimal total_amount
        varchar status
        datetime created_at
    }

    Invoice_Items {
        int item_id PK
        int invoice_id FK
        int medicine_id FK "Optional: if item is a medicine"
        int session_id FK "Optional: if item is a Panchkarma session"
        varchar item_description
        int quantity
        decimal unit_price
        decimal gst_rate "Consider using gst_slab_id FK instead"
        int gst_slab_id FK "Optional: if using GST slabs"
        decimal total_item_amount
    }

    GST_Rate_Slabs {
        int gst_slab_id PK
        varchar slab_name
        decimal rate_percentage
        text description
    }

    Payments {
        int payment_id PK
        int invoice_id FK
        decimal amount_paid
        date payment_date
        varchar payment_method
        varchar transaction_id
        varchar status
    }

    Languages {
        int language_id PK
        varchar language_code
        varchar language_name
    }

    Translations {
        int translation_id PK "Or composite PK (language_id, text_key)"
        int language_id FK
        varchar text_key
        text translated_text
    }

    Users ||--o{ Patients : "can be (optional)"
    Users ||--o{ Doctors : "can be (optional)"
    Users }o--|| Roles : "has one"
    Roles ||--|{ Role_Permissions : "has many"
    Role_Permissions }|--|| Permissions : "maps to"

    Patients ||--|{ Appointments : "requests"
    Doctors ||--|{ Appointments : "assigned to"
    Doctors ||--|{ Doctor_Schedules : "has"
    Doctor_Schedules o--|| Appointments : "can lead to (optional)"

    Patients ||--|{ EMR_Visits : "has many"
    Doctors ||--|{ EMR_Visits : "conducts"
    Appointments o--|| EMR_Visits : "can result in (optional)"
    EMR_Visits ||--|{ EMR_Visit_Notes : "has many"

    EMR_Visits ||--o{ Prescriptions : "can have"
    Patients ||--|{ Prescriptions : "receives"
    Doctors ||--|{ Prescriptions : "issues"

    Prescriptions ||--|{ Prescription_Medicines : "details"
    Medicines ||--|{ Prescription_Medicines : "lists"

    EMR_Visits ||--o{ Lab_Results : "can have"
    Patients ||--|{ Lab_Results : "associated with"

    Patients ||--|{ Panchkarma_Ayurveda_Sessions : "undergoes"
    Doctors ||--o{ Panchkarma_Ayurveda_Sessions : "oversees (optional)"
    EMR_Visits o--|| Panchkarma_Ayurveda_Sessions : "can include (optional)"
    Appointments o--|| Panchkarma_Ayurveda_Sessions : "can be (optional)"

    Patients ||--|{ Invoices : "receives"
    Appointments o--|| Invoices : "can generate (optional)"
    EMR_Visits o--|| Invoices : "can generate (optional)"
    Invoices ||--|{ Invoice_Items : "contains"
    Invoice_Items o--|| Medicines : "can be (optional)"
    Invoice_Items o--|| Panchkarma_Ayurveda_Sessions : "can be (optional)"
    Invoice_Items o--o{ GST_Rate_Slabs : "uses (optional)"

    Invoices ||--|{ Payments : "has"

    Languages ||--|{ Translations : "has many for"
```
