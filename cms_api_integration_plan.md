# Clinic Management System (CMS) - API Integration Plan

## 1. Introduction

This document outlines the API integration plan for the Clinic Management System (CMS). It covers integrations with external third-party services (WhatsApp, SMS, UPI Payments) and defines the internal API endpoints for core CMS functionalities. The plan details request/response formats, authentication mechanisms, rate limiting, error handling, and versioning strategies.

All internal APIs will be served over HTTPS and will use JSON for request and response bodies.

## 2. Versioning

All APIs (internal and external, where applicable) will be versioned using a URI path prefix, e.g., `/api/v1/...`. This ensures backward compatibility when introducing breaking changes.

## 3. Authentication

### 3.1. Internal APIs (Service-to-Service and Client-to-API-Gateway)

*   **Method:** JSON Web Tokens (JWT) based on OAuth 2.0 principles.
*   **Flow:**
    1.  Users (Doctors, Receptionists, Admins) authenticate via the `AuthService` (`/api/v1/auth/login`) using credentials (username/password).
    2.  `AuthService` verifies credentials and issues a short-lived JWT (access token) and a long-lived refresh token.
    3.  The access token is sent in the `Authorization` header with the `Bearer` scheme for all subsequent requests to protected internal APIs.
        ```
        Authorization: Bearer <jwt_access_token>
        ```
    4.  The API Gateway validates the JWT. For service-to-service communication, services might also use JWTs or secure tokens/API keys.
    5.  When the access token expires, the client uses the refresh token to obtain a new access token without requiring user re-authentication.
*   **Token Contents (Claims):** User ID, role(s), permissions, expiry time.

### 3.2. External API Integrations

*   Authentication will be specific to each third-party provider, typically involving API keys, secrets, or OAuth2 tokens.
*   These keys will be securely stored in a secrets management system (e.g., HashiCorp Vault, AWS Secrets Manager, GCP Secret Manager) and accessed by the relevant microservices (NotificationService, BillingService).

## 4. Rate Limiting

*   **Purpose:** Protect APIs from abuse and ensure fair usage.
*   **Implementation:** Implemented at the API Gateway level.
*   **Strategy:** Token bucket or leaky bucket algorithm.
*   **Limits (Example):**
    *   Authenticated users: e.g., 100 requests/minute per user.
    *   Per IP (for unauthenticated or specific endpoints): e.g., 20 requests/minute.
    *   Specific limits for resource-intensive operations.
*   **Response:** `429 Too Many Requests` HTTP status code if limits are exceeded.

## 5. Error Handling

*   **Standard HTTP Status Codes:**
    *   `200 OK`: Request successful.
    *   `201 Created`: Resource created successfully.
    *   `204 No Content`: Request successful, no content to return (e.g., for DELETE).
    *   `400 Bad Request`: Invalid request payload, missing parameters, validation errors.
    *   `401 Unauthorized`: Authentication failed or token missing/invalid.
    *   `403 Forbidden`: Authenticated user does not have permission to access the resource.
    *   `404 Not Found`: Resource not found.
    *   `429 Too Many Requests`: Rate limit exceeded.
    *   `500 Internal Server Error`: Generic server-side error.
    *   `502 Bad Gateway`: Error from an upstream service (e.g., external API integration).
    *   `503 Service Unavailable`: Temporary server overload or maintenance.
*   **JSON Error Response Format:**
    ```json
    {
      "error": {
        "code": "VALIDATION_ERROR", // Or "AUTHENTICATION_FAILURE", "NOT_FOUND", etc.
        "message": "A human-readable error message.",
        "details": [ // Optional, for providing more specific error details (e.g., field validation)
          {
            "field": "email",
            "issue": "Invalid email format."
          }
        ]
      }
    }
    ```

## 6. External API Integrations

### 6.1. WhatsApp Business API

*   **Provider:** Via official WhatsApp Business Solution Providers (BSPs) like Twilio, Gupshup, etc.
*   **Purpose:** Send appointment reminders, confirmations, and potentially other notifications.
*   **Responsibility:** `NotificationService`.
*   **Authentication:** API Key and Secret, or other token-based auth provided by the BSP.
*   **Key Functionality:** Sending pre-approved template messages.

#### Endpoints (Conceptual - actual endpoints depend on BSP)

*   **Send Template Message:**
    *   **Method:** `POST`
    *   **Endpoint (BSP):** `https://api.bsp.com/v1/messages`
    *   **Request Body (CMS to BSP):**
        ```json
        {
          "to": "+91XXXXXXXXXX", // Patient's WhatsApp number
          "type": "template",
          "template": {
            "namespace": "your_template_namespace",
            "name": "appointment_reminder", // Pre-approved template name
            "language": {
              "policy": "deterministic",
              "code": "en" // or "hi", "gu"
            },
            "components": [
              {
                "type": "body",
                "parameters": [
                  {"type": "text", "text": "Patient Name"},
                  {"type": "text", "text": "Dr. Doctor Name"},
                  {"type": "text", "text": "10:00 AM, Aug 15, 2024"},
                  {"type": "text", "text": "Clinic Name"}
                ]
              }
            ]
          }
        }
        ```
    *   **Response (BSP to CMS):**
        ```json
        {
          "messages": [{"id": "whatsapp_message_id"}]
          // or error details
        }
        ```
*   **Webhook for Status Updates (BSP to CMS - `NotificationService`):**
    *   **Method:** `POST`
    *   **Endpoint (CMS):** `/api/v1/notifications/whatsapp/status`
    *   **Payload (from BSP):** BSP-specific format indicating message status (sent, delivered, read, failed).
        ```json
        {
          "statuses": [
            {
              "id": "whatsapp_message_id",
              "recipient_id": "+91XXXXXXXXXX",
              "status": "delivered", // sent, delivered, read, failed
              "timestamp": "1678886400",
              "errors": [] // if status is 'failed'
            }
          ]
        }
        ```

### 6.2. SMS Gateway (e.g., TextLocal, MSG91)

*   **Purpose:** Send appointment reminders, OTPs, and other critical alerts, especially as a fallback or for users not on WhatsApp.
*   **Responsibility:** `NotificationService`.
*   **Authentication:** API Key usually sent as a query parameter or header.

#### Endpoints (Conceptual - actual endpoints depend on provider)

*   **Send SMS:**
    *   **Method:** `POST` or `GET`
    *   **Endpoint (Provider):** `https://api.textlocal.in/send/` or `https://api.msg91.com/api/v2/sendsms`
    *   **Request Parameters/Body (CMS to Provider):**
        ```json
        // Example for TextLocal (as query params or form data)
        // apikey: "YOUR_API_KEY"
        // numbers: "91XXXXXXXXXX"
        // message: "Your appointment with Dr. X at Clinic Y is on DATE at TIME."
        // sender: "CLINIC" (Registered Sender ID)

        // Example for MSG91 (JSON body)
        {
          "sender": "SENDERID",
          "route": "4", // Transactional route
          "country": "91",
          "sms": [
            {
              "message": "Your appointment reminder...",
              "to": ["XXXXXXXXXX"]
            }
          ]
        }
        ```
    *   **Response (Provider to CMS):**
        ```json
        // TextLocal example
        {
          "status": "success",
          "message_id": 12345,
          "balance": 500
        }
        // MSG91 example
        {
          "type": "success",
          "message": "SMS sent successfully."
        }
        ```
*   **Webhook for Delivery Reports (Provider to CMS - `NotificationService`):**
    *   **Method:** `POST` or `GET`
    *   **Endpoint (CMS):** `/api/v1/notifications/sms/status`
    *   **Payload (from Provider):** Provider-specific format indicating message delivery status.

### 6.3. UPI Payment Gateway (e.g., Razorpay, Paytm)

*   **Purpose:** Facilitate online payments for appointments, services, and invoice settlements.
*   **Responsibility:** `BillingService`.
*   **Authentication:** API Key ID and Key Secret (e.g., Razorpay).

#### Endpoints (Conceptual - focusing on Razorpay flow)

1.  **Create Order (CMS `BillingService` to Razorpay):**
    *   **Purpose:** Initiate a payment transaction.
    *   **Method:** `POST`
    *   **Endpoint (Razorpay):** `https://api.razorpay.com/v1/orders`
    *   **Authentication:** Basic Auth with `key_id` and `key_secret`.
    *   **Request Body (CMS to Razorpay):**
        ```json
        {
          "amount": 50000, // Amount in paisa (e.g., 500.00 INR)
          "currency": "INR",
          "receipt": "receipt_invoice_123", // Your internal receipt/invoice ID
          "payment_capture": 1, // Auto-capture payment
          "notes": {
            "patient_id": "patient_uuid_123",
            "invoice_id": "invoice_uuid_456"
          }
        }
        ```
    *   **Response (Razorpay to CMS):**
        ```json
        {
          "id": "order_EKwxwAgItmmXdp", // Razorpay Order ID
          "entity": "order",
          "amount": 50000,
          "currency": "INR",
          "receipt": "receipt_invoice_123",
          "status": "created"
          // ... other details
        }
        ```
    *   **CMS Action:** Store `order_id`. This `order_id` is then used by the frontend to initialize Razorpay's checkout.

2.  **Payment Capture & Verification (Razorpay Webhook to CMS `BillingService`):**
    *   **Purpose:** Razorpay notifies CMS about payment success/failure.
    *   **Method:** `POST`
    *   **Endpoint (CMS):** `/api/v1/billing/payments/razorpay/webhook`
    *   **Security:** Verify webhook signature provided by Razorpay in the `X-Razorpay-Signature` header using the shared secret.
    *   **Request Body (Razorpay to CMS - `payment.captured` event example):**
        ```json
        {
          "entity": "event",
          "account_id": "acc_EHotb3hV2L07EH",
          "event": "payment.captured",
          "contains": ["payment"],
          "payload": {
            "payment": {
              "entity": {
                "id": "pay_EKxxtoIsImIFfL", // Razorpay Payment ID
                "order_id": "order_EKwxwAgItmmXdp",
                "amount": 50000,
                "currency": "INR",
                "status": "captured",
                "method": "upi", // upi, card, netbanking etc.
                "vpa": "user@okhdfcbank", // if UPI
                "notes": {
                  "patient_id": "patient_uuid_123",
                  "invoice_id": "invoice_uuid_456"
                }
                // ... other payment details
              }
            }
          },
          "created_at": 1582696930
        }
        ```
    *   **CMS Action:**
        *   Verify signature.
        *   Verify payment details (amount, currency) against the stored order.
        *   Update invoice status to 'Paid'.
        *   Record payment details in the `Payments` table.
        *   Return `200 OK` to Razorpay to acknowledge receipt.

## 7. Internal API Endpoints

These APIs are exposed by their respective microservices and accessed via the API Gateway. All endpoints are prefixed with `/api/v1`.

### 7.1. Patient Service (`/patients`)

*   **`POST /patients`**: Register a new patient.
    *   **Request Body:**
        ```json
        {
          "first_name": "Rajesh",
          "last_name": "Kumar",
          "date_of_birth": "1985-07-20",
          "gender": "Male", // Male, Female, Other
          "mobile_number": "9876543210",
          "email": "rajesh.k@example.com", // Optional
          "address_line1": "123 MG Road",
          "city": "Bangalore",
          "state": "Karnataka",
          "pincode": "560001",
          "emergency_contact_name": "Anita Kumar", // Optional
          "emergency_contact_number": "9876543211", // Optional
          "blood_group": "O+", // Optional
          "allergies": "Dust, Pollen", // Optional, text or structured
          "medical_history_summary": "Hypertension since 2015" // Optional
        }
        ```
    *   **Response:** `201 Created` with patient details (including `patient_id`).
        ```json
        {
          "patient_id": "uuid-patient-123",
          "first_name": "Rajesh",
          // ... other details
          "created_at": "2024-07-30T10:00:00Z"
        }
        ```
*   **`GET /patients`**: List all patients (with pagination and filtering).
    *   **Query Parameters:** `page=1`, `limit=20`, `search_term="Rajesh"`, `mobile_number="9876543210"`
    *   **Response:** `200 OK` with paginated list of patients.
        ```json
        {
          "data": [
            {
              "patient_id": "uuid-patient-123",
              "first_name": "Rajesh", "last_name": "Kumar",
              "mobile_number": "9876543210"
            }
            // ... more patients
          ],
          "pagination": {
            "total_items": 100,
            "total_pages": 5,
            "current_page": 1,
            "limit": 20
          }
        }
        ```
*   **`GET /patients/{patient_id}`**: Get a specific patient's details.
    *   **Response:** `200 OK` with patient details or `404 Not Found`.
*   **`PUT /patients/{patient_id}`**: Update a patient's details.
    *   **Request Body:** Similar to `POST /patients`, with fields to update.
    *   **Response:** `200 OK` with updated patient details or `404 Not Found`.
*   **`DELETE /patients/{patient_id}`**: Delete a patient (soft delete recommended).
    *   **Response:** `204 No Content` or `404 Not Found`.

### 7.2. Appointment Service (`/appointments`)

*   **`POST /appointments`**: Schedule a new appointment.
    *   **Request Body:**
        ```json
        {
          "patient_id": "uuid-patient-123",
          "doctor_id": "uuid-doctor-456",
          "appointment_datetime": "2024-08-15T10:00:00Z", // ISO 8601 format
          "duration_minutes": 30,
          "reason_for_visit": "Fever and cough",
          "status": "Scheduled" // Scheduled, Confirmed, etc.
        }
        ```
    *   **Response:** `201 Created` with appointment details.
*   **`GET /appointments`**: List appointments (with pagination and filters like `doctor_id`, `patient_id`, `date_range_start`, `date_range_end`, `status`).
    *   **Response:** `200 OK` with paginated list.
*   **`GET /appointments/{appointment_id}`**: Get specific appointment details.
    *   **Response:** `200 OK` or `404 Not Found`.
*   **`PUT /appointments/{appointment_id}`**: Update an appointment (e.g., reschedule, change status).
    *   **Request Body:** Fields to update (e.g., `appointment_datetime`, `status`).
    *   **Response:** `200 OK` with updated appointment details or `404 Not Found`.
*   **`DELETE /appointments/{appointment_id}`**: Cancel/delete an appointment.
    *   **Response:** `204 No Content` or `404 Not Found`.

### 7.3. EMR Service (endpoints might be nested under `/patients/{patient_id}/emr`)

#### Visits

*   **`POST /patients/{patient_id}/visits`**: Create a new visit record (linked to an appointment).
    *   **Request Body:**
        ```json
        {
          "appointment_id": "uuid-appointment-789",
          "doctor_id": "uuid-doctor-456",
          "visit_type": "New", // New, FollowUp
          "chief_complaints": "Fever, headache for 2 days.",
          "examination_findings": "Temp: 101F. Throat normal.",
          "diagnosis": "Viral infection, unspecified.",
          "advice_given": "Rest, fluids, Paracetamol SOS.",
          "follow_up_date": "2024-08-18" // Optional
        }
        ```
    *   **Response:** `201 Created` with visit details.
*   **`GET /patients/{patient_id}/visits`**: List all visits for a patient.
*   **`GET /patients/{patient_id}/visits/{visit_id}`**: Get details of a specific visit.
*   **`PUT /patients/{patient_id}/visits/{visit_id}`**: Update visit details.

#### Prescriptions

*   **`POST /visits/{visit_id}/prescriptions`**: Create a new prescription for a visit.
    *   **Request Body:**
        ```json
        {
          "doctor_id": "uuid-doctor-456",
          "notes": "Follow dosage instructions carefully.",
          "items": [
            {
              "medicine_name": "Paracetamol 500mg",
              "medicine_id": "uuid-medicine-abc", // Optional, if from inventory
              "dosage": "1 tablet",
              "frequency": "TDS (Three times a day)",
              "duration": "3 days",
              "instructions": "After food"
            },
            {
              "medicine_name": "Azithromycin 250mg",
              "dosage": "1 tablet",
              "frequency": "OD (Once a day)",
              "duration": "5 days"
            }
          ]
        }
        ```
    *   **Response:** `201 Created` with prescription details.
*   **`GET /visits/{visit_id}/prescriptions`**: List prescriptions for a visit.
*   **`GET /prescriptions/{prescription_id}`**: Get specific prescription details.

#### Lab Results (Conceptual)

*   **`POST /patients/{patient_id}/lab_results`**: Upload/add a lab result.
    *   **Request Body:** (Could be multipart/form-data if uploading files)
        ```json
        {
          "visit_id": "uuid-visit-101", // Optional
          "test_name": "Complete Blood Count (CBC)",
          "result_date": "2024-07-29",
          "result_value": "See attached PDF", // Or structured results
          "attachment_url": "s3://bucket/path/to/report.pdf", // If file uploaded separately
          "notes": "Slightly elevated WBC."
        }
        ```
    *   **Response:** `201 Created`.
*   **`GET /patients/{patient_id}/lab_results`**: List lab results for a patient.

### 7.4. Billing Service (`/billing`)

#### Invoices

*   **`POST /invoices`**: Generate a new invoice.
    *   **Request Body:**
        ```json
        {
          "patient_id": "uuid-patient-123",
          "appointment_id": "uuid-appointment-789", // Optional
          "invoice_date": "2024-08-01",
          "due_date": "2024-08-15", // Optional
          "items": [
            {
              "item_type": "Service", // Service, Medicine, Panchkarma
              "item_description": "Doctor Consultation",
              "quantity": 1,
              "unit_price": 500.00,
              "discount_percentage": 0,
              "gst_rate_cgst": 9.00,
              "gst_rate_sgst": 9.00,
              "gst_rate_igst": 0.00
            },
            {
              "item_type": "Medicine",
              "item_id": "uuid-medicine-abc", // Link to medicine in inventory
              "item_description": "Paracetamol 500mg - 1 Strip",
              "quantity": 1,
              "unit_price": 20.00,
              "discount_percentage": 0,
              "gst_rate_cgst": 2.50, // Example GST for medicine
              "gst_rate_sgst": 2.50
            }
          ],
          "notes": "Payment due upon receipt."
        }
        ```
    *   **Response:** `201 Created` with full invoice details (including calculated totals, taxes, invoice_id, invoice_number).
*   **`GET /invoices`**: List invoices (with pagination and filters like `patient_id`, `status`, `date_range`).
*   **`GET /invoices/{invoice_id}`**: Get specific invoice details.
*   **`PUT /invoices/{invoice_id}/status`**: Update invoice status (e.g., to 'Paid', 'Cancelled').
    *   **Request Body:** `{"status": "Paid", "payment_details": {"mode": "Cash", "amount": 500.00}}`

#### Payments

*   **`POST /payments`**: Record a payment.
    *   **Request Body:**
        ```json
        {
          "invoice_id": "uuid-invoice-xyz", // Optional, if payment is against an invoice
          "patient_id": "uuid-patient-123",
          "amount_paid": 520.00,
          "payment_mode": "UPI", // Cash, UPI, Card, NetBanking
          "transaction_id": "upi_txn_12345", // Optional
          "payment_date": "2024-08-01T11:00:00Z",
          "notes": "Full payment received."
        }
        ```
    *   **Response:** `201 Created` with payment details. This also updates the linked invoice's status.
*   **`GET /payments`**: List payments (with filters).

### 7.5. Inventory Service (`/inventory`)

#### Medicines

*   **`POST /inventory/medicines`**: Add a new medicine to the catalog.
    *   **Request Body:**
        ```json
        {
          "medicine_name": "Crocin Advance Tablet",
          "generic_name": "Paracetamol",
          "manufacturer": "GSK",
          "category": "Tablet",
          "unit": "Strips", // Strips, Bottles, Numbers
          "hsn_sac_code": "30049099",
          "reorder_level": 50
        }
        ```
    *   **Response:** `201 Created`.
*   **`GET /inventory/medicines`**: List medicines (with filters, pagination).
*   **`GET /inventory/medicines/{medicine_id}`**: Get medicine details.
*   **`PUT /inventory/medicines/{medicine_id}`**: Update medicine details.

#### Batches (Stock Management)

*   **`POST /inventory/medicines/{medicine_id}/batches`**: Add a new batch of medicine stock.
    *   **Request Body:**
        ```json
        {
          "supplier_id": "uuid-supplier-789", // Optional
          "batch_number": "BATCHXYZ123",
          "manufacturing_date": "2024-01-01",
          "expiry_date": "2025-12-31",
          "purchase_price_per_unit": 15.50,
          "selling_price_per_unit": 22.00,
          "quantity_received": 200,
          "purchase_date": "2024-07-20"
        }
        ```
    *   **Response:** `201 Created`. Current stock for the medicine is updated.
*   **`GET /inventory/medicines/{medicine_id}/batches`**: List batches for a medicine.
*   **`PUT /inventory/batches/{batch_id}`**: Update batch details (e.g., adjust stock - carefully controlled).
*   **`POST /inventory/dispense`**: Record medicine dispensing (reduces stock).
    *   **Request Body:**
        ```json
        {
          "prescription_item_id": "uuid-presc-item-1", // Optional link
          "invoice_item_id": "uuid-invoice-item-2", // Optional link
          "items": [
            {
              "medicine_id": "uuid-medicine-abc",
              "batch_id": "uuid-batch-def", // Optional, system can pick FIFO/FEFO
              "quantity_dispensed": 2
            }
          ],
          "dispensed_by_user_id": "uuid-user-pharmacist"
        }
        ```
    *   **Response:** `200 OK` or `400 Bad Request` (e.g., insufficient stock).

## 8. Future Considerations

*   **GraphQL:** For more flexible client-side data fetching, especially for dashboards and complex EMR views.
*   **WebSockets:** For real-time updates (e.g., appointment status changes, chat).
*   **Analytics APIs:** Internal endpoints for reporting and data analysis.
*   **FHIR/OpenEHR Compliance:** For EMR data interoperability, relevant internal EMR APIs might need to support these standards.

This API integration plan provides a comprehensive blueprint for the CMS, ensuring robust communication between internal services and with essential external providers. Regular review and updates will be necessary as the system evolves.
```
