# CivicLoop 🏙️
### A Smarter Way to Report, Track, and Resolve Civic Issues

CivicLoop is a civic issue management platform that connects citizens, municipal staff, and administrators through one digital workflow. It helps citizens report local problems, enables staff to manage assigned issues, and gives administrators tools to oversee issue resolution.

The goal is simple: **make civic problem reporting more transparent, organized, and actionable.**

---

## 📌 The Problem

Civic issues such as damaged roads, overflowing garbage, broken streetlights, and drainage problems often go unreported or are difficult to track.

Traditional reporting processes can make it challenging to:
- Report a problem with clear details and photo evidence.
- Track the status of a reported issue.
- Route issues to the appropriate staff.
- Monitor staff activity and resolution progress.
- Maintain accountability throughout the process.

## 💡 Our Solution

CivicLoop brings these activities into a single platform with role-based workflows for citizens, staff, and administrators.

Citizens can submit issues and follow their progress. Staff can handle assigned issues, while administrators can manage reports, assign responsibility, and oversee the workflow.

## ✨ Key Features

### 📝 Civic Issue Reporting
- Submit civic issues with relevant details.
- Support for photo-based evidence where available.
- Keep issue information organized for review and follow-up.

### 🔄 Issue Lifecycle Management
- Track issues through their workflow.
- Allow authorized users to take appropriate actions.
- Make issue status and responsibility easier to manage.

### 👥 Role-Based Access
CivicLoop is designed around three user roles:

| Role | Main responsibilities |
|---|---|
| **Citizen** | Report civic problems and follow their progress. |
| **Staff** | View assigned issues and perform permitted workflow actions. |
| **Administrator** | Oversee issues, assign work, manage staff, and monitor activity. |

### 🛠️ Administrative Dashboard
The administration workflow includes:
- Reviewing reported issues.
- Viewing issue statistics.
- Assigning issues to staff.
- Rejecting issues when appropriate.
- Provisioning staff accounts.
- Managing staff active status.

### 🤖 AI-Assisted Triage
The project includes AI-related backend services and tests intended to support issue triage. This can help explore how AI may assist in organizing and processing civic reports.

AI availability depends on the backend configuration and the required API credentials.

---

## 🧭 How to Use CivicLoop

### 1. Citizen workflow
1. Open the application.
2. Access the citizen-facing experience.
3. Submit a report with the issue details.
4. Add photo evidence if the reporting form supports it.
5. Follow the issue through its available status updates.

### 2. Staff workflow
1. Access the application using an authorized staff account.
2. View the issues assigned to you.
3. Review the issue details.
4. Perform the actions available to your role.
5. Keep the issue workflow updated as work progresses.

### 3. Administrator workflow
1. Access the administrative dashboard using an authorized administrator account.
2. Review reported issues and dashboard statistics.
3. Assign suitable issues to staff members.
4. Reject inappropriate or invalid reports when necessary.
5. Provision staff accounts and manage their active status.
6. Monitor the overall issue management workflow.

*Available screens and actions depend on the configured application version, backend, and user permissions.*

---

## 🏗️ Technology Stack

| Technology | Purpose |
|---|---|
| **Flutter** | Cross-platform application UI |
| **Dart** | Application and backend development language |
| **Serverpod** | Dart backend framework and API layer |
| **PostgreSQL** | Relational data storage through the backend |
| **Gemini API** | AI-assisted functionality, when configured |
| **Git & GitHub** | Version control and project collaboration |

---

## 📂 Project Structure

```text
civicLoop-serverpod/
├── civicloop_flutter/
│   ├── lib/
│   │   ├── main.dart
│   │   └── screens/
│   ├── pubspec.yaml
│   └── ...
│
├── civicloop_server/
│   ├── lib/
│   ├── migrations/
│   ├── test/
│   └── pubspec.yaml
│
├── pubspec.yaml
├── pubspec.lock
└── README.md
```

**Main components:**
- `civicloop_flutter/` — Flutter client application and screens.
- `civicloop_server/` — Serverpod backend, endpoints, services, and database migrations.
- `civicloop_server/migrations/` — Database schema changes.
- `civicloop_server/test/` — Backend unit, integration, and AI-related tests.

---

🏗️ System Architecture

CivicLoop separates the user interface, backend business rules, and persistent data.

+------------------------------------------------+
|             Flutter Application                |
|                                                |
| Citizen UI | Administrator UI | Employee UI    |
+-----------------------+------------------------+
                        |
                        v
+------------------------------------------------+
|             Generated Serverpod Client        |
|             Typed API Communication            |
+-----------------------+------------------------+
                        |
                        v
+------------------------------------------------+
|                Serverpod Backend               |
|                                                |
| Endpoints | Authentication | Authorization     |
| Issue Services | Staff Services | AI Services   |
+-----------------------+------------------------+
                        |
             +----------+-----------+
             |                      |
             v                      v
+------------------------+  +--------------------+
|      PostgreSQL        |  |   Gemini API       |
| Persistent Application |  | AI-Assisted Triage |
| Data                   |  | (When Configured)  |
+------------------------+  +--------------------+



## 🚀 Getting Started

Follow these steps to run the project locally.

### Prerequisites

Install the following tools:

- [Flutter SDK](https://docs.flutter.dev/get-started/install)
- [Dart SDK](https://dart.dev/get-dart) — included with Flutter in a standard Flutter installation
- [Docker Desktop](https://www.docker.com/products/docker-desktop/) or another supported setup for the required services
- [Serverpod CLI](https://serverpod.dev/)
- [Git](https://git-scm.com/)

A compatible Android emulator, physical device, or other supported Flutter target is also required to run the client.

### Step 1: Clone the repository

```bash
git clone https://github.com/pranav-n29/civicLoop-serverpod.git
cd civicLoop-serverpod
```

### Step 2: Set up the backend

Open a terminal in the repository root and start the required Serverpod services using the configuration supplied with the project.

```bash
cd civicloop_server
```

Install the Dart dependencies:

```bash
dart pub get
```

Check the Serverpod configuration and the project's service setup before starting the backend. Configure the database connection and any other required services for your local environment.

Start the server using the Serverpod CLI:

```bash
serverpod start
```

If your local setup uses a separate Docker Compose workflow or environment-specific configuration, follow that configuration first.

### Step 3: Configure the Flutter client

Open a second terminal:

```bash
cd civicLoop-serverpod/civicloop_flutter
```

If you are already in the repository root, use:

```bash
cd civicloop_flutter
```

Install dependencies:

```bash
flutter pub get
```

Ensure that the generated Serverpod client is present and that its connection settings point to your running backend. Use the appropriate host address for your target: an Android emulator, physical device, or desktop environment may require different network settings.

### Step 4: Run the application

Check that Flutter can detect your target:

```bash
flutter devices
```

Then run:

```bash
flutter run
```

The application should launch on the selected device when the backend, client configuration, and required services are set up correctly.

---

## 🔐 Configuration and API Keys

Some features may require environment-specific settings or external API credentials.

- Configure database and service connections using the project's Serverpod configuration.
- Configure the Gemini API key if you want to run the AI-assisted functionality.
- Keep API keys, passwords, and other secrets out of source control.
- Do not commit local secret files or production credentials to GitHub.

Use environment variables or the configuration mechanism supported by the relevant service. Never publish real API keys in this README.

---

## 🧪 Testing

The backend contains tests covering several parts of the application, including issue management and AI-related functionality.

From the backend directory, install dependencies and run:

```bash
dart pub get
dart test
```

Integration or live AI tests may require a running backend, configured services, database access, or valid API credentials. Run those tests according to their requirements.

To check the Flutter application for static analysis issues:

```bash
cd civicloop_flutter
flutter analyze
```

To run Flutter tests, if available:

```bash
flutter test
```

---

## 🌱 Why CivicLoop Matters

CivicLoop aims to make civic issue management more accessible and accountable by connecting the people who report problems with the people responsible for addressing them.

Its role-based approach helps organize responsibility, while issue tracking and administrative oversight provide a foundation for a more transparent reporting process.

### Expected impact
- Easier civic issue reporting.
- Better visibility into issue progress.
- Clearer assignment of responsibility.
- More organized staff workflows.
- Opportunities to use AI to assist with report triage.

These are the goals of the platform; actual resolution speed and real-world impact depend on adoption, operational processes, and deployment.

---

## 🔮 Future Improvements

Potential areas for further development include:
- Live notifications when issue statuses change.
- Map-based issue discovery and location visualization.
- More detailed analytics and resolution-time reporting.
- Improved accessibility and multilingual support.
- Stronger integration with municipal service systems.
- Expanded AI-assisted categorization and prioritization.

---

## 🤝 Contributing

Contributions and feedback are welcome.

1. Fork the repository.
2. Create a feature branch.
3. Make your changes.
4. Test the changes locally.
5. Open a pull request describing what changed and why.

Please avoid committing credentials, generated secrets, or machine-specific configuration files.

---

## 👨‍💻 Project Information

**Project:** CivicLoop  
**Repository:** [pranav-n29/civicLoop-serverpod](https://github.com/pranav-n29/civicLoop-serverpod)  
**Purpose:** Civic issue reporting and role-based issue management  
**Client:** Flutter  
**Backend:** Serverpod with Dart

---

## 📄 License

No license has been specified here. Check the repository for an existing `LICENSE` file before reusing, modifying, or distributing this project. If you intend to make it open source, choose and add an appropriate license.

---

**CivicLoop — Report it. Track it. Resolve it.** 🏙️
