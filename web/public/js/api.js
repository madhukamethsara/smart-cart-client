// ── Shared API Client ─────────────────────────────────────────────────────────
const API_BASE = 'http://localhost:8787/api';

async function parseJsonSafely(response) {
  try {
    return await response.json();
  } catch (error) {
    return null;
  }
}

async function apiRequest(path, options = {}) {
  try {
    const response = await fetch(`${API_BASE}${path}`, {
      headers: {
        'Content-Type': 'application/json',
        ...(options.headers || {}),
      },
      ...options,
    });

    const data = await parseJsonSafely(response);

    if (!response.ok) {
      return {
        success: false,
        status: response.status,
        message: data?.message || 'Request failed',
        errors: data?.errors || [],
        data: data?.data || null,
      };
    }

    return data || {
      success: true,
      message: 'Request completed successfully',
    };
  } catch (error) {
    return {
      success: false,
      status: 0,
      message: 'Unable to connect to the server',
      errors: [],
      data: null,
    };
  }
}

const api = {
  async get(path) {
    return await apiRequest(path, {
      method: 'GET',
    });
  },

  async post(path, body) {
    return await apiRequest(path, {
      method: 'POST',
      body: JSON.stringify(body),
    });
  },

  async put(path, body) {
    return await apiRequest(path, {
      method: 'PUT',
      body: JSON.stringify(body),
    });
  },

  async del(path) {
    return await apiRequest(path, {
      method: 'DELETE',
    });
  },
};

// ── UI Helpers ────────────────────────────────────────────────────────────────
function showAlert(el, message, type = 'info') {
  const icons = {
    success: '✅',
    danger: '❌',
    warning: '⚠️',
    info: 'ℹ️',
  };

  el.className = `alert alert-${type}`;
  el.innerHTML = `<span>${icons[type] || 'ℹ️'}</span> ${message}`;
  el.classList.remove('hidden');

  setTimeout(() => {
    el.classList.add('hidden');
  }, 5000);
}

function formatCurrency(amount) {
  const value = Number(amount || 0);
  return `$${value.toFixed(2)}`;
}

function formatDate(dateStr) {
  if (!dateStr) return '—';

  const date = new Date(dateStr);
  if (Number.isNaN(date.getTime())) return 'Invalid date';

  return date.toLocaleString();
}

// ── Local Storage Helpers ─────────────────────────────────────────────────────
function getLocalUsers() {
  try {
    return JSON.parse(localStorage.getItem('nm_users') || '[]');
  } catch (error) {
    return [];
  }
}

function saveLocalUsers(users) {
  localStorage.setItem('nm_users', JSON.stringify(users));
}

function saveSession(session) {
  localStorage.setItem('nm_session', JSON.stringify(session));
}

function getSession() {
  try {
    return JSON.parse(localStorage.getItem('nm_session') || 'null');
  } catch (error) {
    return null;
  }
}

// ── Simple Auth Helpers (server-first, localStorage fallback) ────────────────
async function registerUser({ username, password, role = 'staff' }) {
  try {
    const serverRes = await api.post('/auth/register', {
      username,
      password,
      role,
    });

    if (serverRes?.success || serverRes?.ok || serverRes?.id || serverRes?.user) {
      return {
        success: true,
        message: serverRes.message || 'User registered successfully',
        data: serverRes,
      };
    }
  } catch (error) {
    // fallback continues below
  }

  const users = getLocalUsers();

  const existingUser = users.find((user) => user.username === username);
  if (existingUser) {
    return {
      success: false,
      message: 'User already exists',
    };
  }

  const user = {
    id: Date.now(),
    username,
    password,
    role,
  };

  users.push(user);
  saveLocalUsers(users);

  return {
    success: true,
    message: 'User registered locally',
    user,
  };
}

async function loginUser({ username, password }) {
  try {
    const serverRes = await api.post('/auth/login', {
      username,
      password,
    });

    if (serverRes?.token || serverRes?.success || serverRes?.ok) {
      const session = {
        token: serverRes.token || `server-${Date.now()}`,
        user: serverRes.user || {
          username,
          role: serverRes.role || 'staff',
        },
      };

      saveSession(session);

      return {
        success: true,
        message: serverRes.message || 'Login successful',
        token: session.token,
        user: session.user,
      };
    }
  } catch (error) {
    // fallback continues below
  }

  const users = getLocalUsers();
  const user = users.find(
    (item) => item.username === username && item.password === password
  );

  if (!user) {
    return {
      success: false,
      message: 'Invalid credentials',
    };
  }

  const session = {
    token: `local-${btoa(String(user.id))}`,
    user: {
      id: user.id,
      username: user.username,
      role: user.role,
    },
  };

  saveSession(session);

  return {
    success: true,
    message: 'Login successful (local)',
    token: session.token,
    user: session.user,
  };
}

function logout() {
  localStorage.removeItem('nm_session');
}

function currentUser() {
  return getSession()?.user || null;
}

// compatibility helpers expected by older admin page
async function safeGet(path) {
  try {
    const res = await api.get(path);
    // If server returned a wrapper with `data`, preserve it
    if (res && (res.data !== undefined || res.success !== undefined || res.status !== undefined)) {
      return res;
    }
    // If server returned raw array/object, normalize to { data }
    return { success: true, data: res };
  } catch (err) {
    return { success: false, data: null };
  }
}

window.API_BASE_URL = API_BASE;
window.safeGet = safeGet;

window.api = api;
window.auth = {
  registerUser,
  loginUser,
  logout,
  currentUser,
};