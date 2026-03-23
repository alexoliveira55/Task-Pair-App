/* ============================================
   Task Pair App - Shared JavaScript
   ============================================ */

// --- Mock Data ---
const MockData = {
  currentUser: {
    id: 'user1',
    name: 'Alice Johnson',
    email: 'alice@example.com',
    photoUrl: null
  },

  partner: {
    id: 'user2',
    name: 'Bob Smith',
    email: 'bob@example.com',
    photoUrl: null
  },

  pair: {
    id: 'pair1',
    user1Id: 'user1',
    user2Id: 'user2',
    user1Name: 'Alice Johnson',
    user2Name: 'Bob Smith',
    createdAt: '2026-01-15',
    status: 'active'
  },

  scores: {
    user1: { current: 720, goal: 1000, weeklyAvg: 85 },
    user2: { current: 580, goal: 1000, weeklyAvg: 72 }
  },

  tasks: [
    {
      id: 't1', name: 'Clean kitchen', description: 'Wash dishes, wipe counters, sweep floor',
      executorId: 'user1', requesterId: 'user2', status: 'pending',
      recurrence: 'daily', points: 15, scheduledTime: '08:00',
      dueDate: '2026-03-23', expectedDuration: 30,
      reward: null
    },
    {
      id: 't2', name: 'Grocery shopping', description: 'Buy weekly groceries from the list',
      executorId: 'user2', requesterId: 'user1', status: 'in_progress',
      recurrence: 'weekly', points: 25, scheduledTime: '10:00',
      dueDate: '2026-03-25', expectedDuration: 60,
      reward: null
    },
    {
      id: 't3', name: 'Walk the dog', description: 'Morning walk, at least 30 minutes',
      executorId: 'user1', requesterId: 'user2', status: 'done',
      recurrence: 'daily', points: 10, scheduledTime: '07:00',
      dueDate: '2026-03-23', expectedDuration: 30,
      reward: null
    },
    {
      id: 't4', name: 'Pay bills', description: 'Pay electricity, water, internet',
      executorId: 'user2', requesterId: 'user1', status: 'pending',
      recurrence: 'monthly', points: 20, scheduledTime: '14:00',
      dueDate: '2026-03-28', expectedDuration: 15,
      reward: null
    },
    {
      id: 't5', name: 'Vacuum living room', description: 'Vacuum all carpets and under furniture',
      executorId: 'user1', requesterId: 'user2', status: 'pending_validation',
      recurrence: 'weekly', points: 15, scheduledTime: '09:00',
      dueDate: '2026-03-23', expectedDuration: 20,
      reward: null
    },
    {
      id: 't6', name: 'Prepare dinner', description: 'Cook a healthy dinner for both',
      executorId: 'user2', requesterId: 'user1', status: 'pending',
      recurrence: 'daily', points: 20, scheduledTime: '18:00',
      dueDate: '2026-03-23', expectedDuration: 45,
      reward: 'Movie night'
    }
  ],

  executions: [
    { id: 'e1', taskId: 't3', executorId: 'user1', startedAt: '2026-03-23 07:05', finishedAt: '2026-03-23 07:38', duration: 33, notes: 'Went to the park' },
    { id: 'e2', taskId: 't5', executorId: 'user1', startedAt: '2026-03-23 09:10', finishedAt: '2026-03-23 09:28', duration: 18, notes: 'Also cleaned under sofa' },
    { id: 'e3', taskId: 't2', executorId: 'user2', startedAt: '2026-03-23 10:15', finishedAt: null, duration: null, notes: '' }
  ],

  validations: [
    { id: 'v1', taskId: 't5', taskName: 'Vacuum living room', executorName: 'Alice Johnson', executionId: 'e2', percentage: null, notes: '', status: 'pending', executedAt: '2026-03-23 09:28' },
    { id: 'v2', taskId: 't3', taskName: 'Walk the dog', executorName: 'Alice Johnson', executionId: 'e1', percentage: 90, notes: 'Great job!', status: 'approved', executedAt: '2026-03-23 07:38' }
  ],

  rewards: [
    { id: 'r1', name: 'Movie Night', description: 'Choose a movie and watch together', pointsRequired: 200, currentPoints: 180, unlocked: false, icon: '🎬' },
    { id: 'r2', name: 'Restaurant Dinner', description: 'Dinner at your favorite restaurant', pointsRequired: 500, currentPoints: 500, unlocked: true, icon: '🍽️' },
    { id: 'r3', name: 'Spa Day', description: 'A relaxing day at the spa', pointsRequired: 1000, currentPoints: 720, unlocked: false, icon: '💆' },
    { id: 'r4', name: 'Weekend Getaway', description: 'A weekend trip together', pointsRequired: 2000, currentPoints: 720, unlocked: false, icon: '✈️' },
    { id: 'r5', name: 'Sleep In', description: 'Sleep in while partner handles morning tasks', pointsRequired: 100, currentPoints: 100, unlocked: true, icon: '😴' }
  ],

  weeklyScores: [
    { week: 'W1', user1: 120, user2: 95 },
    { week: 'W2', user1: 145, user2: 130 },
    { week: 'W3', user1: 110, user2: 155 },
    { week: 'W4', user1: 160, user2: 120 },
    { week: 'W5', user1: 95, user2: 80 },
    { week: 'W6', user1: 90, user2: 0 /* current week */ }
  ],

  invites: [
    { id: 'inv1', fromName: 'Charlie Brown', fromEmail: 'charlie@example.com', status: 'pending', date: '2026-03-22' }
  ]
};

// --- Navigation Helper ---
function navigateTo(page) {
  window.location.href = page;
}

// --- Bottom Navigation Renderer ---
function renderBottomNav(activePage) {
  const navItems = [
    { page: 'dashboard.html', icon: '🏠', label: 'Home' },
    { page: 'tasks.html', icon: '📋', label: 'Tasks' },
    { page: 'execution.html', icon: '▶️', label: 'Execute' },
    { page: 'validation.html', icon: '✅', label: 'Validate' },
    { page: 'rewards.html', icon: '🏆', label: 'Rewards' }
  ];

  const nav = document.createElement('nav');
  nav.className = 'bottom-nav';
  nav.innerHTML = navItems.map(item =>
    `<a href="${item.page}" class="${activePage === item.page ? 'active' : ''}">
      <span class="nav-icon">${item.icon}</span>
      ${item.label}
    </a>`
  ).join('');

  document.querySelector('.app-container').appendChild(nav);
}

// --- Top Bar Renderer ---
function renderTopBar(title, options = {}) {
  const { backPage, actions } = options;
  const bar = document.createElement('header');
  bar.className = 'top-bar';

  let html = '';
  if (backPage) {
    html += `<button class="back-btn" onclick="navigateTo('${backPage}')">&larr;</button>`;
  }
  html += `<h1>${title}</h1>`;
  if (actions) {
    html += actions;
  }
  bar.innerHTML = html;

  const container = document.querySelector('.app-container');
  container.insertBefore(bar, container.firstChild);
}

// --- Modal Helpers ---
function openModal(modalId) {
  const el = document.getElementById(modalId);
  if (el) el.classList.add('active');
}

function closeModal(modalId) {
  const el = document.getElementById(modalId);
  if (el) el.classList.remove('active');
}

// Close modal on overlay click
document.addEventListener('click', function(e) {
  if (e.target.classList.contains('modal-overlay')) {
    e.target.classList.remove('active');
  }
});

// --- Utility: Get Status Badge ---
function statusBadge(status) {
  const map = {
    'pending': '<span class="badge badge-pending">Pending</span>',
    'in_progress': '<span class="badge badge-active">In Progress</span>',
    'done': '<span class="badge badge-done">Done</span>',
    'pending_validation': '<span class="badge badge-pending">Awaiting Validation</span>',
    'overdue': '<span class="badge badge-overdue">Overdue</span>',
    'approved': '<span class="badge badge-done">Approved</span>',
    'locked': '<span class="badge badge-locked">Locked</span>',
    'unlocked': '<span class="badge badge-unlocked">Unlocked</span>',
    'active': '<span class="badge badge-active">Active</span>'
  };
  return map[status] || `<span class="badge">${status}</span>`;
}

// --- Utility: Format date ---
function formatDate(dateStr) {
  if (!dateStr) return '';
  const d = new Date(dateStr);
  return d.toLocaleDateString('en-US', { month: 'short', day: 'numeric' });
}

// --- Utility: Get user display name ---
function userName(userId) {
  return userId === 'user1' ? MockData.currentUser.name : MockData.partner.name;
}

// --- Utility: Get initials ---
function getInitials(name) {
  return name.split(' ').map(w => w[0]).join('').substring(0, 2).toUpperCase();
}

// --- Toast notification ---
function showToast(message, type = 'success') {
  const toast = document.createElement('div');
  toast.style.cssText = `
    position: fixed; top: 20px; left: 50%; transform: translateX(-50%);
    background: ${type === 'success' ? 'var(--success)' : type === 'error' ? 'var(--error)' : 'var(--primary)'};
    color: white; padding: 12px 24px; border-radius: 8px; font-size: 14px;
    font-weight: 600; box-shadow: 0 4px 12px rgba(0,0,0,0.2); z-index: 999;
    animation: slideDown 0.3s ease;
  `;
  toast.textContent = message;
  document.body.appendChild(toast);
  setTimeout(() => {
    toast.style.opacity = '0';
    toast.style.transition = 'opacity 0.3s';
    setTimeout(() => toast.remove(), 300);
  }, 2500);
}

// --- Recurrence label ---
function recurrenceLabel(type) {
  const map = { daily: 'Daily', weekly: 'Weekly', monthly: 'Monthly', once: 'Once', 'every_x_days': 'Custom' };
  return map[type] || type;
}
