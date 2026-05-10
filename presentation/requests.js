function initApiRendering() {
  try {
    const apiData = API_DATA;
    
    // Replace {baseUrl} in urls
    const baseUrl = apiData.baseUrl;
    const processData = (reqs) => reqs.map(req => ({
      ...req,
      url: req.url.replace('{baseUrl}', baseUrl)
    }));

    renderRequests(processData(apiData.esp32 || []), 'esp32-requests');
    renderRequests(processData(apiData.mobile || []), 'mobile-requests');
  } catch (error) {
    console.error('Failed to load API data:', error);
  }
}

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
        ${req.response ? `
          <span class="api-label" style="margin-top: 20px;">Example Response</span>
          <div class="api-body-box" style="background: rgba(26,107,92,.1); border: 1px solid rgba(26,107,92,.2); color: #4ade80;">${JSON.stringify(req.response, null, 2)}</div>
        ` : ''}
      </div>
    </div>
  `).join('');
  
  // Show section if it has data
  const section = container.closest('[id$="-section"]');
  if (section) section.style.display = 'block';
}

document.addEventListener('DOMContentLoaded', initApiRendering);
