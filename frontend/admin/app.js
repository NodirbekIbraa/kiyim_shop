/* VESTRA · Aurora Console — shared shell + helpers */
'use strict';

const TOKEN = localStorage.getItem('vestra_token');
if (!TOKEN && !location.pathname.endsWith('login.html')) location.href = '/admin/login.html';
const UNAME = localStorage.getItem('vestra_name') || 'Admin';

/* minimalist inline line-icons (stroke = currentColor) */
const ICON = {
  dashboard:'<svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8"><rect x="3" y="3" width="7" height="9" rx="1.5"/><rect x="14" y="3" width="7" height="5" rx="1.5"/><rect x="14" y="12" width="7" height="9" rx="1.5"/><rect x="3" y="16" width="7" height="5" rx="1.5"/></svg>',
  orders:'<svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8"><path d="M8 3h8l3 4v12a2 2 0 01-2 2H7a2 2 0 01-2-2V7z"/><path d="M8 8h8M8 12h8M8 16h5"/></svg>',
  customers:'<svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8"><circle cx="9" cy="8" r="3.2"/><path d="M3.5 20a5.5 5.5 0 0111 0"/><path d="M16 5.5a3 3 0 010 5.6M17.5 20a5.5 5.5 0 00-3-4.9"/></svg>',
  products:'<svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8"><path d="M12 3l8 4.5v9L12 21l-8-4.5v-9z"/><path d="M4 7.5l8 4.5 8-4.5M12 12v9"/></svg>',
  reports:'<svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8"><path d="M4 20V4M4 20h16"/><path d="M8 16v-4M12 16V8M16 16v-6" stroke-linecap="round"/></svg>',
  logout:'<svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8"><path d="M14 8V6a2 2 0 00-2-2H6a2 2 0 00-2 2v12a2 2 0 002 2h6a2 2 0 002-2v-2"/><path d="M18 12H9m9 0l-3-3m3 3l-3 3" stroke-linecap="round" stroke-linejoin="round"/></svg>',
};

const NAV = [
  ['dashboard','Dashboard','dashboard.html'],
  ['orders','Buyurtmalar','orders.html'],
  ['customers','Mijozlar','customers.html'],
  ['products','Mahsulotlar','products.html'],
  ['reports','Hisobotlar','reports.html'],
];

function mountNav(active) {
  const links = NAV.map(([key,label,href]) =>
    `<a class="nav-link ${key===active?'active':''}" href="${href}"><span class="ni">${ICON[key]}</span>${label}</a>`
  ).join('');
  const initials = UNAME.trim().split(/\s+/).map(w=>w[0]).join('').toUpperCase().slice(0,2);
  const html = `
  <header class="topnav">
    <div class="nav-brand">
      <div class="brand-mark">N</div>
      <div class="brand-word">NODIR<span>Aurora Console</span></div>
    </div>
    <nav class="nav-links">${links}</nav>
    <div class="nav-user">
      <div class="u-chip">
        <div class="u-meta" style="text-align:right">
          <div class="u-name">${esc(UNAME)}</div>
          <div class="u-role">Administrator</div>
        </div>
        <div class="u-av">${initials}</div>
      </div>
      <button class="icon-btn" title="Chiqish" onclick="logout()">${ICON.logout}</button>
    </div>
  </header>`;
  document.body.insertAdjacentHTML('afterbegin', html);
}

function logout(){ localStorage.clear(); location.href='/admin/login.html'; }

/* ── helpers ── */
function money(v){ return '£'+parseFloat(v||0).toFixed(2).replace(/\B(?=(\d{3})+(?!\d))/g, ','); }
function esc(s){ return String(s==null?'':s).replace(/[&<>"']/g, c=>({'&':'&amp;','<':'&lt;','>':'&gt;','"':'&quot;',"'":'&#39;'}[c])); }
function dateShort(d){ return d ? new Date(d).toLocaleDateString('uz-UZ',{day:'2-digit',month:'short',year:'numeric'}) : '—'; }
function timeAgo(d){
  const s=Math.floor((Date.now()-new Date(d))/1000);
  if(s<60) return s+'s oldin';
  if(s<3600) return Math.floor(s/60)+'daq oldin';
  if(s<86400) return Math.floor(s/3600)+'soat oldin';
  return Math.floor(s/86400)+' kun oldin';
}
async function api(path, opts={}){
  const res = await fetch(path, { headers:{'Content-Type':'application/json','Authorization':'Bearer '+TOKEN}, ...opts });
  if(res.status===401||res.status===403){ localStorage.clear(); location.href='/admin/login.html'; return null; }
  return res;
}
let _tw;
function toast(msg,type='success'){
  if(!_tw){ _tw=document.createElement('div'); _tw.className='toast-wrap'; document.body.appendChild(_tw); }
  const t=document.createElement('div'); t.className='toast '+type; t.textContent=msg;
  _tw.appendChild(t); setTimeout(()=>t.remove(),2800);
}

/* status colors shared by charts */
const STATUS_COLORS={pending:'#FBBF24',processing:'#60A5FA',shipped:'#A78BFA',delivered:'#34D399',cancelled:'#F87171'};
const STATUS_UZ={pending:'Kutilmoqda',processing:'Jarayonda',shipped:'Yuborildi',delivered:'Yetkazildi',cancelled:'Bekor qilindi'};
