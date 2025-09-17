# 🎉 SWE EventBoard

SWE EventBoard is a mobile application designed for the **Department of Software Engineering** at DIU to centralize all **seminars, webinars, club activities, and departmental events**.  
Students can view and enroll in events, while organizers and admins can create, manage, and approve events — making event management simple, transparent, and engaging.

---

## 🚀 Features
- 👨‍🎓 **Students**: View upcoming events, enroll, and get reminders
- 🎤 **Organizers (Clubs & Dept.)**: Create, update, and manage events with role-based authentication
- 🛡️ **Admin**: Approve events, monitor analytics, and oversee all activities
- 🔔 Push & Email Notifications for updates
- 📊 Event analytics, reports, and feedback system

---

## 📲 User Screens & Workflows

### 🧑‍🎓 Student Screens
- Event List
- Event Details
- Enrollment Confirmation
- My Enrollments

📸 *Screenshots here:* 

| Dashboard | Event Details | Role Selection |
|-----------|---------------|----------------|
| ![Student Home](screenshots/student/student_dashboard.png) | ![Student Event Details](screenshots/student/s_event_details.png) | ![Role Selection](screenshots/student/role_selection.png) |

| Signup | Enrollments | Profile |
|--------|-------------|---------|
| ![Student Signup](screenshots/student/s_signup.png) | ![Student Enrollment](screenshots/student/student_enrollments.png) | ![Student Profile](screenshots/student/s_profile.png) |

| Payment | Notifications |
|---------|---------------|
| ![Student Payment](screenshots/student/s_payment.png) | ![Student Notification](screenshots/student/s_notify.png) |

---

### 🎤 Organizer Screens
- Organizer Dashboard
- Create Event Form
- Manage Events (Edit/Delete)
- View Participants

📸 *Screenshots here:*

| Dashboard | Merchandise | Edit Event |
|-----------|-------------|------------|
| ![Organizer Dashboard](screenshots/organizer/o_dashboard.png) | ![Organizer Merchandise](screenshots/organizer/o_add_march.png) | ![Organizer Edit Event](screenshots/organizer/o_edit_event.png) |

| Event Management (1) | Event Management (2) | Notifications |
|-----------------------|-----------------------|---------------|
| ![Organizer Event Management](screenshots/organizer/o_events_1.png) | ![Organizer Event Management](screenshots/organizer/o_events_2.png) | ![Organizer Notification](screenshots/organizer/o_notify.png) |

| Profile | Signup |
|---------|--------|
| ![Organizer Profile](screenshots/organizer/o_profile.png) | ![Organizer Signup](screenshots/organizer/o_signup.png) |


---

### 🛡️ Admin Screens
- Admin Dashboard
- Event Approval
- Reports & Analytics
- Feedback Management

📸 *Screenshots here:*  

| Dashboard | Event Details | Event Management (1) |
|-----------|---------------|-----------------------|
| ![Admin Dashboard](screenshots/admin/a_dashboard.png) | ![Admin Event Details](screenshots/admin/a_event_details.png) | ![Admin Event Management](screenshots/admin/a_events_1.png) |

| Event Management (2) | Organizer Management (1) | Organizer Management (2) |
|-----------------------|--------------------------|--------------------------|
| ![Admin Event Management](screenshots/admin/a_events_2.png) | ![Admin Organizer Management](screenshots/admin/a_org_1.png) | ![Admin Organizer Management](screenshots/admin/a_org_2.png) |

| User Management | Profile |
|-----------------|---------|
| ![Admin User Management](screenshots/admin/a_users.png) | ![Admin Organizer Profile](screenshots/admin/a_profile.png) |

---

## 🛠️ Tech Stack
- **Flutter** – Frontend
- **Firebase** – Authentication & Database
- **Firebase** – Push Notifications
- **Getx** – State Management
- **MVC Architecture****

---

## ⚙️ Installation

1. Clone the repo:
   ```bash
   git clone https://github.com/Ahmad61-6/swe_eventboard.git
   cd swe_eventboard
