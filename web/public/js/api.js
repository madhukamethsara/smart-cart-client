// ── Shared API Client ─────────────────────────────────────────────────────────
const API_BASE = '/api';

const api = {
  async get(path) {
    const res = await fetch(API_BASE + path);
    return res.json();
  },
  async post(path, body) {
    const res = await fetch(API_BASE + path, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(body),
    });
    return res.json();
  },
  async put(path, body) {
    const res = await fetch(API_BASE + path, {
      method: 'PUT',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(body),
    });
    return res.json();
  },
  async del(path) {
    const res = await fetch(API_BASE + path, { method: 'DELETE' });
    return res.json();
  },
};

// ── UI Helpers ────────────────────────────────────────────────────────────────
function showAlert(el, message, type = 'info') {
  const icons = { success: '✅', danger: '❌', warning: '⚠️', info: 'ℹ️' };
  el.className = `alert alert-${type}`;
  el.innerHTML = `<span>${icons[type]}</span> ${message}`;
  el.classList.remove('hidden');
  setTimeout(() => el.classList.add('hidden'), 5000);
}

function formatCurrency(amount) {
  return '$' + parseFloat(amount).toFixed(2);
}

function formatDate(dateStr) {
  return new Date(dateStr).toLocaleString();
}
