const graphs = {
  overview: `
flowchart TD
START([Start]) --> INIT[Setup System]
INIT --> READY[Ready State]
READY --> SCAN[Scan Fingerprint]
SCAN --> CHECK_SCAN{Fingerprint Found?}

CHECK_SCAN -->|No| SCAN
CHECK_SCAN -->|Yes| FOUND[Fingerprint ID Detected]
FOUND --> GETUSER[Fetch User From Firestore]
GETUSER --> CHECK_USER_REQ{Request Success?}

CHECK_USER_REQ -->|No| USER_ERR[Show Error 5s]
USER_ERR --> READY

CHECK_USER_REQ -->|Yes| UPLOAD[Upload Attendance]
UPLOAD --> CHECK_UPLOAD{Upload Success?}

CHECK_UPLOAD -->|No| UPLOAD_ERR[Show Upload Error 5s]
UPLOAD_ERR --> READY

CHECK_UPLOAD -->|Yes| SUCCESS[Show Success]
SUCCESS --> READY
`,

  init: `
flowchart TD
A1[Serial Begin]
A2[Init LEDs + Buzzer]
A3[Show Error Red LED ON]
A4[Connect WiFi]
A5[Sync Time NTP]
A6[Init Fingerprint Sensor]
A7{Fingerprint Init OK?}
A8[Print Error + Halt]
A9[Get Latest Session ID]
A10{Session ID Found?}
A11[Retry after 1 sec]
A12[Show Ready Blue LED ON]

A1 --> A2 --> A3 --> A4 --> A5 --> A6 --> A7
A7 -->|No| A8
A7 -->|Yes| A9 --> A10
A10 -->|No| A11 --> A9
A10 -->|Yes| A12
`,

  ready: `
flowchart TD
B1[Read Fingerprint Image]
B2[Convert Image]
B3[Search Fingerprint]
B4{Valid Fingerprint?}

B1 --> B2 --> B3 --> B4
B4 -->|No| B1
B4 -->|Yes| FOUND[Fingerprint Found]
FOUND --> OUT((To USER))
`,

  user: `
flowchart TD
C1[Query Firestore by fingerprint_id]
C2[Parse JSON Response]
C3{User Exists?}
C4[Extract name + national_id]
C5[Return Empty User]

IN((Fingerprint ID)) --> C1 --> C2 --> C3
C3 -->|Yes| C4 --> OUT1((To RECORD))
C3 -->|No| C5 --> OUT2((To RECORD))
`,

  record: `
flowchart TD
D1[Build Attendance JSON]
D2[Add User Data]
D3[Add Session ID]
D4[Add Current Time]
D5[POST to Firestore]
D6{Upload Success?}

IN((From USER)) --> D1 --> D2 --> D3 --> D4 --> D5 --> D6
D6 -->|Yes| S1[Green LED + Success]
D6 -->|No| S2[Show Error]

S1 --> READY1((Back To READY))
S2 --> READY2((Back To READY))
`
};

document.addEventListener('DOMContentLoaded', () => {
  Object.keys(graphs).forEach(id => {
    const container = document.getElementById('mermaid-' + id);
    if (container) {
      container.textContent = graphs[id];
    }
  });

  mermaid.init(undefined, document.querySelectorAll('.mermaid'));
});