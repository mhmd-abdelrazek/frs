const apiData = {
  esp32: [
    {
      name: "Query User With Fingerprint ID",
      method: "POST",
      url: "https://firestore.googleapis.com/v1/projects/finger-reg-system/databases/(default)/documents:runQuery",
      body: {
        structuredQuery: {
          from: [{ "collectionId": "users" }],
          where: {
            fieldFilter: {
              field: { "fieldPath": "fingerprintId" },
              op: "EQUAL",
              value: { "integerValue": "50" }
            }
          },
          limit: 1
        }
      }
    },
    {
      name: "Get Last Session",
      method: "GET",
      url: "https://firestore.googleapis.com/v1/projects/finger-reg-system/databases/(default)/documents/sessions?orderBy=start_time desc",
      desc: "Retrieves the most recent session to link new attendance records."
    },
    {
      name: "Save Attendance Record",
      method: "POST",
      url: "https://firestore.googleapis.com/v1/projects/finger-reg-system/databases/(default)/documents/records",
      body: {
        fields: {
          name: { "stringValue": "Mohamed Abdelrazek" },
          id: { "stringValue": "session_id_here" },
          start_time: { "timestampValue": "2026-04-30T14:25:25Z" }
        }
      }
    }
  ],
  mobile: []
};

function renderRequests(data, containerId) {
  const container = document.getElementById(containerId);
  if (!container || !data || data.length === 0) return;

  container.innerHTML = data.map(req => `
    <div class="api-card">
      <div class="api-header">
        <span class="api-method method-${req.method.toLowerCase()}">${req.method}</span>
        <span class="api-name">${req.name}</span>
      </div>
      <div class="api-content">
        <span class="api-label">Endpoint</span>
        <div class="api-url-box">${req.url}</div>
        ${req.desc ? `<p style="font-size: 13px; color: var(--muted); margin-top: -10px; margin-bottom: 20px;">${req.desc}</p>` : ''}
        ${req.body ? `
          <span class="api-label">Request Body</span>
          <div class="api-body-box">${JSON.stringify(req.body, null, 2)}</div>
        ` : ''}
      </div>
    </div>
  `).join('');
  
  // Show section if it has data
  const section = container.closest('[id$="-section"]');
  if (section) section.style.display = 'block';
}

function initApiRendering() {
  renderRequests(apiData.esp32, 'esp32-requests');
  renderRequests(apiData.mobile, 'mobile-requests');
}

document.addEventListener('DOMContentLoaded', initApiRendering);

