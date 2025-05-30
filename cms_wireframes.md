# Clinic Management System (CMS) - UI Wireframes

This document outlines the UI wireframes for a web-based Clinic Management System (CMS) designed for Indian clinics and Ayurvedic wellness centers. The wireframes prioritize clarity, simplicity, mobile-responsiveness, and real-world workflows.

## General Principles

*   **Mobile-First Approach:** Design for smaller screens first, then adapt for larger screens.
*   **Clean & Minimalist UI:** Avoid clutter and unnecessary elements.
*   **Intuitive Navigation:** Easy to find information and perform actions.
*   **Indian Context:** Use Indian currency (₹), date formats (DD/MM/YYYY), and incorporate elements like UPI payment flows and GST logic.
*   **Performance:** Optimized for fast loading on slow internet connections.

## Color Palette (Suggested)

*   **Primary:** Shades of Blue (calm, trustworthy)
*   **Secondary:** Shades of Green (wellness, nature)
*   **Accent:** Orange or Yellow (attention-grabbing for CTAs)
*   **Neutral:** Greys and Whites (backgrounds, text)

## Typography (Suggested)

*   Use clear, legible sans-serif fonts like Open Sans, Lato, or Roboto.

## Icons

*   Use universally understood icons for actions and navigation.

---

## Screens

### 1. Login Panels (Role-based)

*   **Objective:** Allow different user roles (Doctor, Receptionist, Admin) to log in.
*   **Layout (Mobile & Desktop):**
    *   Clinic Logo
    *   Welcome Message (e.g., "Welcome to [Clinic Name] CMS")
    *   Tabs/Buttons for "Doctor", "Receptionist", "Admin"
    *   Username/Email/Mobile Number field
    *   Password field
    *   "Forgot Password?" link
    *   "Login" button
    *   (Optional) "Register New Clinic" link for Admins or a separate super-admin panel.

    **Admin Login Specifics:**
    *   May have additional fields for Clinic ID if managing multiple clinics.

    **Receptionist Login Specifics:**
    *   May have a dropdown to select branch if the clinic has multiple locations.

    **Doctor Login Specifics:**
    *   Standard username/password.

### 2. Dashboard

*   **Objective:** Provide a quick overview of key clinic activities for the logged-in user. Content will vary based on role.
*   **Layout (Mobile & Desktop - Card-based):**
    *   **Header:**
        *   Clinic Name/Logo
        *   User Profile Icon (with logout option)
        *   Date Picker (default to Today)
        *   (Desktop) Main Navigation Menu (collapsible on mobile)
    *   **Key Metrics (Cards - Admin/Receptionist):**
        *   **Today's Appointments:**
            *   Count (e.g., "25 Appointments")
            *   Quick link to "View All Appointments"
        *   **Revenue Today:**
            *   Amount (e.g., "₹15,000")
            *   Quick link to "View Billing"
        *   **New Patients Today:**
            *   Count (e.g., "5 New Patients")
            *   Quick link to "Patient Registration"
        *   **Total Patients:**
            *   Count (e.g., "1200 Total Patients")
    *   **Key Metrics (Cards - Doctor):**
        *   **Today's Appointments:**
            *   Count (e.g., "10 Appointments for Dr. [Name]")
            *   List of next 2-3 upcoming patients with time slots.
        *   **Pending Tasks:**
            *   (e.g., "3 Visit Summaries to complete")
    *   **Quick Actions (Buttons/Links):**
        *   "Book New Appointment"
        *   "Register New Patient"
        *   "Search Patient"
    *   **Appointments List (Today - for Receptionist/Doctor):**
        *   Patient Name
        *   Time
        *   Status (Scheduled, Checked-in, Completed, Cancelled)
        *   Quick action buttons (e.g., "Check-in", "View EMR", "Generate Bill")
    *   **(Optional) Recent Activity Feed:**
        *   (e.g., "Patient [Name] registered", "Invoice #123 generated")

### 3. Patient Registration & OPD Form

*   **Objective:** Capture new patient details and information for their Out-Patient Department (OPD) visit.
*   **Layout (Mobile & Desktop - Multi-step form or tabbed interface for clarity):**
    *   **Header:** "Register New Patient" / "Patient OPD Form"
    *   **Section 1: Basic Information**
        *   Full Name (First, Middle, Last)
        *   Date of Birth (DD/MM/YYYY) - Age calculated automatically
        *   Gender (Male, Female, Other)
        *   Mobile Number (with OTP verification option)
        *   Email Address (Optional)
        *   Address (Street, Area, City, State, Pincode)
        *   Emergency Contact Name & Number (Optional)
        *   Photo (Upload option)
        *   Unique Patient ID (auto-generated or manual entry option)
    *   **Section 2: OPD Visit Details (if combined, otherwise separate flow after registration)**
        *   Visit Date & Time (auto-filled, editable)
        *   Consulting Doctor (Dropdown list of doctors)
        *   Department (e.g., General, Ayurveda, Panchkarma)
        *   Chief Complaints (Text area)
        *   Brief History (Text area)
        *   Referred By (Optional)
        *   Type of Visit (New / Follow-up)
    *   **Section 3: Health Metrics (Optional, can be filled by nurse/assistant)**
        *   Height (cm/ft)
        *   Weight (kg)
        *   Blood Pressure (Systolic/Diastolic)
        *   Temperature (°C/°F)
        *   Pulse Rate (bpm)
        *   SpO2 (%)
        *   Allergies (Text area, tagging preferred)
    *   **Action Buttons:**
        *   "Save Patient" / "Save & Proceed to Billing" / "Save & Book Appointment"
        *   "Cancel"

### 4. Appointment Booking

*   **Objective:** Schedule, reschedule, and manage patient appointments.
*   **Layout (Mobile & Desktop):**
    *   **Header:** "Book Appointment"
    *   **Patient Search/Selection:**
        *   Search bar for existing patients (by Name, Mobile, Patient ID)
        *   Option to "Register New Patient" if not found.
        *   Selected Patient Display: Name, Age, Gender.
    *   **Doctor Selection:**
        *   Dropdown or list of doctors.
        *   Filter by department/specialty.
    *   **Calendar View:**
        *   Monthly/Weekly/Daily view.
        *   Highlight doctor's available slots.
        *   Busy slots clearly marked.
        *   Navigation to previous/next month/week/day.
    *   **Time Slot Selection:**
        *   List of available time slots for the selected date and doctor.
    *   **Appointment Details:**
        *   Reason for Visit (Text area, optional)
        *   Appointment Type (Consultation, Follow-up, Panchkarma Session)
    *   **Communication Preference:**
        *   Toggle/Checkbox for "Send WhatsApp Confirmation"
        *   Toggle/Checkbox for "Send SMS Confirmation"
        *   (Note: Requires integration with WhatsApp Business API / SMS gateway)
    *   **Action Buttons:**
        *   "Confirm Booking"
        *   "Cancel"
    *   **Existing Appointments View (List/Table):**
        *   Filter by Date, Doctor, Status.
        *   Columns: Patient Name, Time, Doctor, Status, Actions (Reschedule, Cancel, Mark as Completed).

### 5. Doctor Profile with Schedule and Availability

*   **Objective:** Allow viewing and managing a doctor's profile, schedule, and availability.
*   **Layout (Mobile & Desktop):**
    *   **Header:** "Doctor Profile - Dr. [Name]" (View mode) / "Manage Schedule" (Edit mode for Doctor/Admin)
    *   **Section 1: Doctor Information (Viewable by all, editable by Doctor/Admin)**
        *   Photo
        *   Full Name
        *   Specialization(s)
        *   Qualification(s)
        *   Years of Experience
        *   Contact Number (Clinic specific)
        *   Email Address (Clinic specific)
        *   Brief Bio (Optional)
    *   **Section 2: Availability Settings (Editable by Doctor/Admin)**
        *   Default Working Days (Checkboxes: Mon, Tue, Wed, Thu, Fri, Sat, Sun)
        *   Default Working Hours (e.g., 9:00 AM - 1:00 PM, 4:00 PM - 7:00 PM) for each selected day.
        *   Slot Duration (Dropdown: 15 min, 30 min, etc.)
        *   Option to set specific availability for certain dates (e.g., for holidays, special camps).
        *   "Save Changes" button for this section.
    *   **Section 3: Calendar View (Public/Receptionist View)**
        *   Shows the doctor's schedule with booked appointments and available slots.
        *   Similar to the calendar in Appointment Booking but focused on one doctor.
    *   **Section 4: My Appointments (For logged-in Doctor)**
        *   List of today's/upcoming appointments.
        *   Quick links to patient EMR.

### 6. EMR (Electronic Medical Record) View

*   **Objective:** Provide a comprehensive view of a patient's medical history, visit summaries, and prescriptions.
*   **Layout (Mobile & Desktop - Tabbed interface for different EMR sections):**
    *   **Header:**
        *   Patient Name, Age, Gender, Patient ID
        *   Allergies (prominently displayed)
        *   Quick link to "New Visit Entry" / "New Prescription"
    *   **Tabs:**
        *   **Visit History:**
            *   Chronological list of past visits.
            *   Each entry shows: Date, Doctor, Chief Complaint (summary), View Details button.
        *   **Visit Summary (for a selected visit):**
            *   Date & Time of Visit
            *   Consulting Doctor
            *   Chief Complaints
            *   Observations/Examination Findings
            *   Diagnosis (ICD-10 codes if applicable, or text)
            *   Advice Given
            *   Follow-up Date (if any)
            *   Option to "Edit Visit Summary" (if privileged)
        *   **Prescriptions:**
            *   Chronological list of past prescriptions.
            *   Each entry shows: Date, Doctor, View/Print Prescription button.
            *   **Prescription Detail (when viewing/creating):**
                *   Clinic Header (Name, Address, Contact)
                *   Doctor's Name & Registration Number
                *   Patient Name, Age, Gender, Date
                *   Rx (Symbol)
                *   Medicine Name, Dosage, Frequency, Duration, Remarks (Table format)
                *   Dietary Advice
                *   Lifestyle Advice
                *   Lab Tests Recommended (if any)
                *   Digital Signature of Doctor (if integrated)
                *   "Print Prescription" button
                *   "Email/Send to Patient" button
        *   **Lab Reports:**
            *   List of uploaded lab reports.
            *   Date, Test Name, Uploaded By, View/Download button.
            *   "Upload New Report" button.
        *   **Treatment History (especially for Ayurveda/Panchkarma):**
            *   Link to Ayurveda/Panchkarma Treatment Log section.
        *   **Patient Notes:**
            *   General notes about the patient not tied to a specific visit.

### 7. Ayurveda/Panchkarma Treatment Log

*   **Objective:** Track specific Ayurvedic treatments and Panchkarma procedures.
*   **Layout (Mobile & Desktop):**
    *   **Header:** "Ayurveda/Panchkarma Log for [Patient Name]"
    *   Link to main EMR view.
    *   "Add New Treatment Entry" button.
    *   **Treatment Log Table/List:**
        *   Date of Treatment
        *   Treatment Name (e.g., Abhyanga, Shirodhara, Vamana, Virechana) - Dropdown/Searchable list.
        *   Prescribing Doctor
        *   Therapist(s) Performing
        *   Oils/Herbs Used (Text area or structured input)
        *   Duration of Treatment
        *   Key Observations/Patient Feedback during treatment
        *   Post-Treatment Advice
        *   Status (Scheduled, In Progress, Completed, Cancelled)
        *   Next Scheduled Date (if part of a series)
        *   Actions (Edit, View Details, Mark as Completed)
    *   **When adding/editing an entry (Modal or separate page):**
        *   All the fields listed above as form inputs.
        *   Option to link to a specific Panchkarma package if applicable.

### 8. Billing & Invoicing Page

*   **Objective:** Generate bills, manage payments, and handle GST calculations.
*   **Layout (Mobile & Desktop):**
    *   **Header:** "Billing & Invoicing"
    *   **Sub-sections/Tabs:** "Create Invoice", "View Invoices", "Payment History"
    *   **Create Invoice:**
        *   Search Patient (Name, ID, Mobile)
        *   Select Patient (auto-fills patient details)
        *   Invoice Date (DD/MM/YYYY - default to today)
        *   Due Date (DD/MM/YYYY - optional)
        *   Invoice Number (auto-generated, configurable format)
        *   **Line Items (Table):**
            *   "Add Service/Item" button
            *   S.No.
            *   Service/Item Description (e.g., "Consultation Fee", "Abhyanga Treatment", "Medicine Name") - Searchable from a predefined list or manual entry.
            *   HSN/SAC Code (Optional, for GST)
            *   Quantity
            *   Unit Price (₹)
            *   Discount (%) (per item or overall)
            *   Amount (₹) (auto-calculated)
            *   GST Rate (%) (Dropdown: 0%, 5%, 12%, 18%, 28%, or custom)
            *   CGST (₹) (auto-calculated)
            *   SGST (₹) (auto-calculated)
            *   IGST (₹) (auto-calculated, if applicable for inter-state)
            *   Total Amount (₹) (per item, auto-calculated)
        *   **Summary:**
            *   Subtotal (₹)
            *   Total Discount (₹)
            *   Total GST (₹)
            *   Grand Total (₹)
            *   Amount Paid (₹) (Input field)
            *   Payment Mode (Dropdown: Cash, UPI, Card, Net Banking, Cheque, Other)
                *   If UPI: Field for UPI Transaction ID.
                *   If Card: Fields for Card Type, Last 4 digits.
                *   If Cheque: Field for Cheque Number, Bank Name.
            *   Balance Due (₹) (auto-calculated)
        *   Notes/Terms & Conditions (Text area)
        *   **Action Buttons:**
            *   "Save & Print Invoice"
            *   "Save & Send via Email/WhatsApp"
            *   "Record Payment"
            *   "Generate Proforma Invoice"
    *   **View Invoices (Table):**
        *   Filters: Date Range, Patient, Payment Status (Paid, Partially Paid, Unpaid).
        *   Columns: Invoice #, Date, Patient Name, Amount, Payment Status, Actions (View, Print, Edit, Cancel, Send Reminder).

### 9. Pharmacy Inventory Management

*   **Objective:** Manage medicine stock, track expiry dates, and handle procurement.
*   **Layout (Mobile & Desktop - Tabbed interface or separate sections):**
    *   **Header:** "Pharmacy Inventory"
    *   **Tabs/Sections:** "Stock View", "Add New Stock", "Suppliers", "Purchase Orders", "Reports"
    *   **Stock View (Table):**
        *   Filters: Search by Medicine Name, Batch No., Supplier.
        *   Alerts for Low Stock, Near Expiry items.
        *   Columns:
            *   Medicine Name
            *   Batch Number
            *   Supplier Name
            *   Manufacturing Date (MM/YYYY)
            *   Expiry Date (MM/YYYY) - Highlight if near expiry.
            *   Purchase Price (₹)
            *   Selling Price (₹)
            *   Current Stock Quantity
            *   Unit (e.g., Strips, Bottles, Numbers)
            *   Rack/Location (Optional)
            *   Actions (Edit, View Details, Adjust Stock)
    *   **Add New Stock / Stock Entry Form:**
        *   Medicine Name (Search from existing or add new)
        *   Batch Number
        *   Supplier (Select from list or add new)
        *   Manufacturing Date
        *   Expiry Date
        *   Quantity Received
        *   Purchase Price per Unit
        *   Selling Price per Unit
        *   Invoice Number (from supplier)
        *   Payment Status to Supplier
        *   "Save Stock" button
    *   **Dispense Medicine (Could be a separate interface linked from Billing or EMR):**
        *   Search Medicine
        *   Select Batch (FIFO or based on expiry)
        *   Enter Quantity to Dispense
        *   Automatically deducts from stock.
    *   **Suppliers (CRUD):**
        *   Supplier Name, Contact Person, Mobile, Email, Address, GSTIN.
    *   **Purchase Orders (Basic):**
        *   Create PO for suppliers.
        *   Track PO status (Pending, Partially Received, Received).
    *   **Reports:**
        *   Low Stock Report
        *   Expiry Report
        *   Stock Movement Report
        *   Sales Report (by medicine)

---

## Workflow Considerations:

*   **Receptionist:** Focus on Registration, Appointment Booking, Billing, basic patient EMR view.
*   **Doctor:** Focus on Dashboard (their appointments), EMR (viewing history, creating visit summaries, prescriptions), managing their schedule.
*   **Admin:** Overview of all functions, user management, clinic settings, advanced reports, inventory management oversight.

This structure provides a comprehensive yet clean approach to the CMS. Each section can be further detailed with specific field validations and interaction behaviors during the detailed design phase.
The next step would be to get feedback on these wireframes and then potentially create visual mockups.Okay, I have created the initial `cms_wireframes.md` file with the descriptions of each screen. This should provide a good foundation for reviewing the UI structure and flow.
