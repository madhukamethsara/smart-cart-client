// ── Shared API Client ─────────────────────────────────────────────────────────
// const API_BASE = 'https://iot-smart-cart.damindudhananjitha.workers.dev/api';
const API_BASE = 'http://localhost:8787/api';
const SESSION_KEY = 'nm_session';

async function parseJsonSafely(response) {
  try {
    return await response.json();
  } catch (error) {
    return null;
  }
}

function getSession() {
  try {
    return JSON.parse(localStorage.getItem(SESSION_KEY) || 'null');
  } catch (error) {
    return null;
  }
}

function saveSession(session) {
  localStorage.setItem(SESSION_KEY, JSON.stringify(session));
}

function clearSession() {
  localStorage.removeItem(SESSION_KEY);
}

function getAuthHeaders() {
  const token = getSession()?.token;
  if (!token) return {};
  return {
    Authorization: `Bearer ${token}`,
  };
}

async function apiRequest(path, options = {}) {
  try {
    const mergedHeaders = {
      'Content-Type': 'application/json',
      ...getAuthHeaders(),
      ...(options.headers || {}),
    };

    const response = await fetch(`${API_BASE}${path}`, {
      ...options,
      headers: mergedHeaders,
    });

    const data = await parseJsonSafely(response);

    if (!response.ok) {
      if (!path.startsWith('/auth/') && (response.status === 401 || response.status === 403)) {
        clearSession();
      }

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

// ── Auth Helpers (JWT) ─────────────────────────────────────────────────────────
async function registerUser({ name, password }) {
  const res = await api.post('/auth/signup', {
    name,
    password,
  });

  if (!res?.success) {
    return {
      success: false,
      message: res?.message || 'Registration failed',
      errors: res?.errors || [],
    };
  }

  return {
    success: true,
    message: res.message || 'Registration successful',
    data: res.data || null,
  };
}

async function loginUser({ name, password }) {
  const res = await api.post('/auth/login', {
    name,
    password,
  });

  if (!res?.success || !res?.data?.token || !res?.data?.user) {
    return {
      success: false,
      message: res?.message || 'Invalid credentials',
      errors: res?.errors || [],
    };
  }

  const session = {
    token: res.data.token,
    user: res.data.user,
  };

  saveSession(session);

  return {
    success: true,
    message: res.message || 'Login successful',
    token: session.token,
    user: session.user,
  };
}

function logout() {
  clearSession();
}

function currentUser() {
  return getSession()?.user || null;
}

function isAuthenticated() {
  const session = getSession();
  return Boolean(session?.token && session?.user);
}

async function validateSession() {
  const session = getSession();

  if (!session?.token) {
    clearSession();
    return {
      authenticated: false,
      user: null,
      message: 'Missing session token',
    };
  }

  const res = await api.get('/auth/me');

  if (!res?.success || !res?.data?.user) {
    clearSession();
    return {
      authenticated: false,
      user: null,
      message: res?.message || 'Invalid or expired session',
    };
  }

  const nextSession = {
    token: session.token,
    user: res.data.user,
  };

  saveSession(nextSession);

  return {
    authenticated: true,
    user: nextSession.user,
    message: res.message || 'Session valid',
  };
}

function redirectToDashboard(user = currentUser()) {
  if (!user) {
    window.location.href = 'login.html';
    return;
  }

  if (user.role === 'admin') {
    window.location.href = 'admin.html';
    return;
  }

  if (user.role === 'cashier') {
    window.location.href = 'cashier.html';
    return;
  }

  window.location.href = 'login.html';
}

async function enforceRole(requiredRole) {
  const sessionState = await validateSession();
  const user = sessionState.user;

  if (!sessionState.authenticated || !user) {
    window.location.href = 'login.html';
    return false;
  }

  if (user.role !== requiredRole) {
    redirectToDashboard(user);
    return false;
  }

  return true;
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
  validateSession,
  currentUser,
  getSession,
  isAuthenticated,
  redirectToDashboard,
  enforceRole,
};
