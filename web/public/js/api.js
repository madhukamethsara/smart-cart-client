// ── Shared API Client ─────────────────────────────────────────────────────────
const API_BASE = 'http://localhost:8787/api';

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

// ── Simple Auth Helpers (server-first, localStorage fallback)
async function registerUser({ username, password, role = 'staff' }) {
  try {
    const res = await api.post('/auth/register', { username, password, role });
    if (res && (res.ok || res.id)) return res;
  } catch (e) {}

  const users = JSON.parse(localStorage.getItem('nm_users') || '[]');
  if (users.find(u => u.username === username)) return { ok: false, error: 'User exists' };
  const user = { id: Date.now(), username, password, role };
  users.push(user);
  localStorage.setItem('nm_users', JSON.stringify(users));
  return { ok: true, user };
}

async function loginUser({ username, password }) {
  try {
    const res = await api.post('/auth/login', { username, password });
    if (res && (res.token || res.ok)) return res;
  } catch (e) {}

  const users = JSON.parse(localStorage.getItem('nm_users') || '[]');
  const user = users.find(u => u.username === username && u.password === password);
  if (!user) return { ok: false, error: 'Invalid credentials' };
  const token = 'local-' + btoa(String(user.id));
  const session = { token, user: { id: user.id, username: user.username, role: user.role } };
  localStorage.setItem('nm_session', JSON.stringify(session));
  return { ok: true, token, user: session.user };
}

function logout() {
  localStorage.removeItem('nm_session');
}

function currentUser() {
  try {
    return JSON.parse(localStorage.getItem('nm_session'))?.user || null;
  } catch (e) { return null; }
}

window.auth = { registerUser, loginUser, logout, currentUser };
